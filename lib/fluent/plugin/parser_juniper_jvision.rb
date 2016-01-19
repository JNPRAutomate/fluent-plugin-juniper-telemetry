require 'protobuf'
require 'jvision_top.pb.rb'
require 'port.pb.rb'

module Fluent
    class TextParser
        class JuniperJvisionParser < Parser

            Plugin.register_parser("juniper_jvision", self)

            config_param :time_format, :string, :default => nil
            config_param :output_format, :string, :default => 'structured'

            # This method is called after config_params have read configuration parameters
            def configure(conf)
                super

                @time_parser = TimeParser.new(@time_format)
            end

            # This is the main method. The input "text" is the unit of data to be parsed.
            # If this is the in_tail plugin, it would be a line. If this is for in_syslog,
            # it is a single syslog message.
            def parse(text)

                puts "Inside juniper_jvision"

                jvision_msg =  TelemetryStream.decode(text)

                ## Extract device name and cleanup
                device_name = jvision_msg.system_id
                device_name.gsub!('.', '_')

                time = Engine.now

                ## Extract sensor
                jnpr_sensor = jvision_msg.enterprise.juniperNetworks
                datas = JSON.parse(jnpr_sensor.to_json)

                ### Support for message int-phy
                if jvision_msg.sensor_name == "int-phy"

                    datas['jnpr_interface_ext']['interface_stats'].each do |datas|

                        ## Extract interface name and clean up
                        interface_name = datas['if_name']
                        interface_name.gsub!('/', '_')
                        interface_name.gsub!(':', '_')

                        init_time = datas['init_time']

                        ## Clean up current object
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
                                            name = "device." + device_name + ".interface." + interface_name + "." + section + "." + queue_number + "." + type
                                            record = { name => value }

                                        elsif output_format.to_s == 'structured'
                                            record['device'] = device_name
                                            record['interface'] = interface_name
                                            record['type'] = section + '.' + type
                                            record['egress_queue'] = queue_number
                                            record['value'] = value
                                        else
                                            puts "output_format not supported"
                                        end

                                        yield time, record
                                    end
                                end
                            else
                                data.each do |type,value|

                                    record = {}
                                    if output_format.to_s == 'flat'
                                        name = "device." + device_name + ".interface." + interface_name + "." + section + "." + type
                                        record = { name => value }

                                    elsif output_format.to_s == 'structured'
                                        record['device'] = device_name
                                        record['interface'] = interface_name
                                        record['type'] = section + '.' + type
                                        record['value'] = value
                                    else
                                        puts "output_format not supported"
                                    end

                                    yield time, record
                                end
                            end
                        end
                    end
                else
                    puts "Unsupported sensor : " + jvision_msg.sensor_name
                end
            end
        end
    end
end
