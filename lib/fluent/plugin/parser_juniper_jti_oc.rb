require 'juniper_telemetry_lib.rb'
require 'protobuf'
require 'open-config.pb.rb'

module Fluent
  class TextParser
    class JuniperJtiParser < Parser

      Plugin.register_parser("juniper_jti_oc", self)

      # This method is called after config_params have read configuration parameters
      def configure(conf)
        super
      end

      def parse(text)

        # $log.info  "juniper_jti_oc/ Starting Parse "
        time = Engine.now

        ## Decode GBP packet
        oc_msg =  OpenConfigData.decode(text)

        # $log.info  "Object #{oc_msg.inspect.to_s}"

        device_id = oc_msg.system_id
        component_id = oc_msg.component_id
        gpb_time = epoc_to_sec(oc_msg.timestamp)

        oc_msg.kv.each do |kv|

          record = {}

          # Add device and component id
          record['device'] = device_id
          record['component'] = component_id

          # Extract type info
          type = kv.key.match(/([a-zA-Z\-\_]*)$/)
          record['type'] = type

          # Extract Value
          record['value'] = kv.int_value

          # Try to extract attribute information
          # Check how it will looks with multiple attribute per string
          attribute = kv.key.match(/\/([^\/]*)\[([A-Za-z0-9\-]*)\=([^\[]*)\]/)
          if attribute
            if attribute[2] == "name"
              record[attribute[1]] = attribute[3]
            end
          end
          yield gpb_time, record
        end
      end
    end
  end
end
