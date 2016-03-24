require 'protobuf'
require 'jvision_top.pb.rb'
require 'port.pb.rb'
require 'logical_port.pb.rb'
require 'firewall.pb.rb'

module Fluent
    class TextParser
        class JuniperJtiParser < Parser

            Plugin.register_parser("juniper_jti", self)

            config_param :output_format, :string, :default => 'structured'

            # This method is called after config_params have read configuration parameters
            def configure(conf)
                super

                ## Check if "output_format" has a valid value
                unless  @output_format.to_s == "structured" ||
                        @output_format.to_s == "flat" ||
                        @output_format.to_s == "statsd"

                    raise ConfigError, "output_format value '#{@output_format}' is not valid. Must be : structured, flat or statsd"
                end
            end

            def parse(text)

                ## Decode GBP packet
                jti_msg =  TelemetryStream.decode(text)

                resource = ""

                ## Extract device name & Timestamp
                device_name = jti_msg.system_id
                gpb_time = jti_msg.timestamp

                ## Extract sensor
                begin
                  jnpr_sensor = jti_msg.enterprise.juniperNetworks
                  datas_sensors = JSON.parse(jnpr_sensor.to_json)
                  $log.debug  "Extract sensor data from " + device_name
                rescue
                  $log.warn   "Unable to extract sensor data sensor from jti_msg.enterprise.juniperNetworks, something went wrong"
                  $log.debug  "Unable to extract sensor data sensor from jti_msg.enterprise.juniperNetworks, Data Dump : " + jti_msg.inspect.to_s
                  return
                end

                ## Go over each Sensor
                datas_sensors.each do |sensor, s_data|

                    # Save all info extracted on a list
                    sensor_data = []

                    ##############################################################
                    ### Support for resource /junos/system/linecard/interface/  ##
                    ##############################################################
                    if sensor == "jnpr_interface_ext"

                      resource = "/junos/system/linecard/interface/"

                      datas_sensors[sensor]['interface_stats'].each do |datas|

                        # Catch Exception during parsing
                        begin
                          ## Extract interface name and clean up
                          # interface_name = datas['if_name']
                          sensor_data.push({ 'device' => device_name  })
                          sensor_data.push({ 'interface' => datas['if_name']  })

                          # Check if the interface has a parent
                          if datas.key?('parent_ae_name')
                            sensor_data.push({ 'interface_parent' =>  datas['parent_ae_name']  })
                            datas.delete("parent_ae_name")
                          end

                          ## Clean up Current object
                          datas.delete("if_name")
                          datas.delete("init_time")
                          datas.delete("snmp_if_index")

                          datas.each do |section, data|

                            ## egress_queue_info is an Array
                            if data.kind_of?(Array)
                              data.each do |queue|

                                ## Save and Cleanup Queue number
                                sensor_data.push({ 'egress_queue' => queue['queue_number']  })
                                queue.delete("queue_number")

                                queue.each do |type,value|
                                  sensor_data.push({ 'type' => section + '.' + type  })
                                  sensor_data.push({ 'value' => value  })

                                  record = build_record(output_format, sensor_data)
                                  yield gpb_time, record
                                end
                              end
                            else
                              data.each do |type,value|
                                sensor_data.push({ 'type' => section + '.' + type  })
                                sensor_data.push({ 'value' => value  })

                                record = build_record(output_format, sensor_data)
                                yield gpb_time, record
                              end
                            end
                          end
                        rescue
                          $log.warn   "Unable to parse " + sensor + " sensor, an error occured.."
                          $log.debug  "Unable to parse " + sensor + " sensor, Data Dump : " + datas.inspect.to_s
                        end

                      end
                    elsif sensor == "jnpr_firewall_ext"

                      resource = "/junos/system/xxx"

                      datas_sensors[sensor]['firewall_stats'].each do |datas|

                        begin
                          ## Extract interface name and clean up
                          sensor_data.push({ 'device' => device_name  })
                          sensor_data.push({ 'filter_name' => datas['filter_name']  })

                          ## Clean up Current object
                          # datas.delete("filter_name")

                          $log.warn  "Sensor Filter : " + datas['filter_name']

                        rescue
                          $log.warn   "Unable to parse " + sensor + " sensor, an error occured.."
                          $log.debug  "Unable to parse " + sensor + " sensor, Data Dump : " + datas.inspect.to_s
                        end
                      end
                    elsif sensor == "jnprLogicalInterfaceExt"

                      resource = "/junos/system/xxx"

                      datas_sensors[sensor]['interface_info'].each do |datas|

                        begin
                          ## Extract interface name and clean up
                          sensor_data.push({ 'device' => device_name  })
                          sensor_data.push({ 'interface' => datas['if_name']  })

                          ## Clean up Current object
                          datas.delete("if_name")
                          datas.delete("init_time")
                          datas.delete("snmp_if_index")
                          datas.delete("op_state")

                          datas.each do |section, data|

                            data.each do |type, value|

                              sensor_data.push({ 'type' => section + '.' + type  })
                              sensor_data.push({ 'value' => value  })

                              record = build_record(output_format, sensor_data)
                              yield gpb_time, record

                            end
                          end
                        rescue
                          $log.warn   "Unable to parse " + sensor + " sensor, an error occured.."
                          $log.debug  "Unable to parse " + sensor + " sensor, Data Dump : " + datas.inspect.to_s
                        end
                      end
                    else
                        $log.warn  "Unsupported sensor : " + sensor
                        # puts datas_sensors[sensor].inspect.to_s
                    end
                end
            end

            def clean_up_name(name)

                tmp = name
                ## Clean up device name and interface name to remove restricted caracter
                tmp.gsub!('/', '_')
                tmp.gsub!(':', '_')
                tmp.gsub!('.', '_')

                return tmp
            end

            def build_record(type, data)

              if type.to_s == 'flat'

                # initialize variables
                name = ""
                sensor_value = ""

                ## Concatene all key/value into a string and stop at "value"
                data.each do |entry|
                  entry.each do |key, value|

                    if key == "value"
                      sensor_value = value
                      next
                    end

                    if name == ""
                      name = key + "." + clean_up_name(value).to_s
                    else
                      name = name + "." + key + "." + clean_up_name(value).to_s
                    end
                  end
                end

                record = { name => sensor_value }
                return record

              elsif output_format.to_s == 'structured'
                record = {}
                ## Convert list into Hash
                ## Each entry on the list is a hash with 1 key/value
                data.each do |entry|
                  entry.each do |key, value|
                    record[key] = value
                  end
                end

                return record
              else
                $log.warn "Output_format '#{type.to_s}' not supported"
              end
            end
        end
    end
end
