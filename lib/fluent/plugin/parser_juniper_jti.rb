require 'protobuf'
require 'jvision_top.pb.rb'
require 'port.pb.rb'

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

                jvision_msg =  TelemetryStream.decode(text)


                resource = ""

                ## Extract device name & Timestamp
                device_name = jvision_msg.system_id
                gpb_time = jvision_msg.timestamp

                ## Extract sensor
                jnpr_sensor = jvision_msg.enterprise.juniperNetworks
                datas = JSON.parse(jnpr_sensor.to_json)

                ## Go over each Sensor
                datas.each do |sensor, sensor_data|

                    ##############################################################
                    ### Support for resource /junos/system/linecard/interface/  ##
                    ##############################################################
                    if sensor == "jnpr_interface_ext"

                        resource = "/junos/system/linecard/interface/"

                        datas[sensor]['interface_stats'].each do |datas|

                            ## Extract interface name and clean up
                            interface_name = datas['if_name']

                            ## Clean up Current object
                            datas.delete("if_name")
                            datas.delete("init_time")
                            datas.delete("snmp_if_index")

                            datas.each do |section, data|

                                ## egress_queue_info is an Array
                                if data.kind_of?(Array)
                                    data.each do |queue|

                                        queue_number = queue['queue_number']

                                        ## Cleanup Queue
                                        queue.delete("queue_number")

                                        queue.each do |type,value|

                                            record = {}
                                            if output_format.to_s == 'flat'
                                                name = "device.#{clean_up_name(device_name).to_s}.interface.#{clean_up_name(interface_name).to_s}.#{section.to_s}.#{queue_number.to_s}.#{type.to_s}"
                                                record = { name => value }

                                            elsif output_format.to_s == 'structured'
                                                record['device'] = device_name
                                                record['interface'] = interface_name
                                                record['type'] = section + '.' + type
                                                record['egress_queue'] = queue_number.to_s
                                                record['value'] = value
                                            else
                                                $log.warn "Output_format '#{output_format.to_s}' not supported for resource : #{resource}"
                                            end

                                            yield gpb_time, record
                                        end
                                    end
                                else
                                    data.each do |type,value|

                                        record = {}
                                        if output_format.to_s == 'flat'
                                            name = "device.#{clean_up_name(device_name).to_s}.interface.#{clean_up_name(interface_name).to_s}.#{section.to_s}.#{type.to_s}"
                                            record = { name => value }

                                        elsif output_format.to_s == 'structured'
                                            record['device'] = device_name
                                            record['interface'] = interface_name
                                            record['type'] = section + '.' + type
                                            record['value'] = value

                                        else
                                            $log.warn "Output_format '#{output_format.to_s}' not supported for resource : #{resource}"
                                        end

                                        yield gpb_time, record
                                    end
                                end
                            end
                        end
                    else
                        $log.warn  "Unsupported sensor : " + sensor
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
        end
    end
end
