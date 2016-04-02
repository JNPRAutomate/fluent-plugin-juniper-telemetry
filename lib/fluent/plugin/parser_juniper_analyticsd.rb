require 'juniper_telemetry_lib.rb'

module Fluent
  class TextParser
    class JuniperAnalyticsdParser < Parser

      Plugin.register_parser("juniper_analyticsd", self)

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

        payload = JSON.parse(text)
        time = Engine.now

        ## Extract contextual info
        record_type = payload["record-type"]
        record_time = payload["time"]
        device_name = payload["router-id"]
        port_name = payload["port"]

        ## Record time is in microsecond and until 0.14 Fluentd do not support lower than 1s
        ## We need to trim record time for now to fit fluentd
        json_time = (record_time/1000000).to_i

        if record_type == 'traffic-stats'

          ## Delete contextual info
          payload.delete("record-type")
          payload.delete("time")
          payload.delete("router-id")
          payload.delete("port")

          payload.each do |key, value|
            record = {}

            if output_format.to_s == 'flat'
              full_name = "device.#{clean_up_name(device_name)}.interface.#{clean_up_name(port_name)}.type.#{key}"

              record[full_name.downcase]= value

            elsif output_format.to_s == 'structured'
              record['device'] = device_name
              record['type'] = record_type + '.' + key
              record['interface'] = port_name
              record['value'] = value

            elsif output_format.to_s == 'statsd'

              full_name = "interface.#{clean_up_name(port_name)}.type.#{key}"
              record[:statsd_type] = 'gauge'
              record[:statsd_key] = full_name.downcase
              record[:statsd_gauge] = value
            else
                $log.warn "Output_format '#{output_format.to_s}' not supported for #{record_type}"
            end

            yield json_time, record
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

              full_name = "device.#{clean_up_name(device_name)}.interface.#{clean_up_name(port_name)}.queue.#{key}"

              record[full_name.downcase]= value

            elsif output_format.to_s == 'structured'
              record['device'] = device_name
              record['type'] = record_type + '.' + key
              record['interface'] = port_name
              record['value'] = value

            elsif output_format.to_s == 'statsd'
              full_name = "interface.#{clean_up_name(port_name)}.queue.#{key}"
              record[:statsd_type] = 'gauge'
              record[:statsd_key] = full_name.downcase
              record[:statsd_gauge] = value

            else
              $log.warn "Output_format '#{output_format.to_s}' not supported for #{record_type}"
            end

            yield json_time, record
          end
        else
          $log.warn "Recard type '#{record_type}' not supported"
        end
      end
    end
  end
end
