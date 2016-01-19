module Fluent
    class TextParser
        class JuniperAnalyticsdParser < Parser

            Plugin.register_parser("juniper_analyticsd", self)

            config_param :time_format, :string, :default => nil
            config_param :output_format, :string, :default => 'structured'

            # This method is called after config_params have read configuration parameters
            def configure(conf)
                super
                @time_parser = TimeParser.new(@time_format)
            end

            def parse(text)

                payload = JSON.parse(text)
                time = Engine.now

                ## Extract contextual info
                record_type = payload["record-type"]
                record_time = payload["time"]
                device_name = payload["router-id"]
                port_name = payload["port"]
                port_name.gsub!('/', '_')
                port_name.gsub!(':', '_')

                if record_type == 'traffic-stats'

                    ## Delete contextual info
                    payload.delete("record-type")
                    payload.delete("time")
                    payload.delete("router-id")
                    payload.delete("port")

                    payload.each do |key, value|
                        record = {}

                        if output_format.to_s == 'flat'
                            full_name = "device." + device_name + ".interface." + port_name + '.type.' + key
                            record[full_name.downcase]= value

                        elsif output_format.to_s == 'structured'
                            record['device'] = device_name
                            record['type'] = record_type + '.' + key
                            record['interface'] = port_name
                            record['value'] = value
                        elsif output_format.to_s == 'statsd'

                            full_name = "interface." + port_name + '.type.' + key
                            record[:statsd_type] = 'gauge'
                            record[:statsd_key] = full_name.downcase
                            record[:statsd_gauge] = value
                        else
                            puts "output_format not supported"
                        end

                        yield time, record
                    end
                elsif record_type == 'queue-stats'

                    ## Delete contextual info
                    payload.delete("record-type")
                    payload.delete("time")
                    payload.delete("router-id")
                    payload.delete("port")

                    payload.each do |key, value|
                        record = {}

                        if output_format.to_s == 'flat'
                            full_name = "device." + device_name + ".interface." + port_name + '.queue.' + key
                            record[full_name.downcase]= value

                        elsif output_format.to_s == 'structured'
                            record['device'] = device_name
                            record['type'] = record_type + '.' + key
                            record['interface'] = port_name
                            record['value'] = value

                        elsif output_format.to_s == 'statsd'
                            full_name = "interface." + port_name + '.queue.' + key
                            record[:statsd_type] = 'gauge'
                            record[:statsd_key] = full_name.downcase
                            record[:statsd_gauge] = value
                        else
                            puts "output_format not supported"
                        end

                        yield time, record
                    end
                else
                    puts "record_type is : " + record_type
                    puts payload.inspect
                end
            end
        end
    end
end
