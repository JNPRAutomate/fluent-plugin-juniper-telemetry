require 'juniper_telemetry_lib.rb'
require 'protobuf'
require 'resource.pb.rb'

module Fluent
  class TextParser
    class JuniperJtiParser < Parser

      Plugin.register_parser("juniper_jti_oc", self)

      # This method is called after config_params have read configuration parameters
      def configure(conf)
        super
      end

      def parse(text)

        ## Decode GBP packet
        oc_msg =  Resource::Resource.decode(text)

        resource = ""

        $log.debug  " Message : " + oc_msg.inspect.to_s
        #
        # ## Extract device name & Timestamp
        # device_name = jti_msg.system_id
        # gpb_time = epoc_to_sec(jti_msg.timestamp)




      end
    end
  end
end
