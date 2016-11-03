# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf'


##
# Imports
#
require 'telemetry_top.pb'


##
# Message Classes
#
class GPort < ::Protobuf::Message; end
class InterfaceInfos < ::Protobuf::Message; end
class InterfaceStats < ::Protobuf::Message; end
class IngressInterfaceErrors < ::Protobuf::Message; end
class QueueStats < ::Protobuf::Message; end


##
# Message Fields
#
class GPort
  repeated ::InterfaceInfos, :interface_stats, 1
end

class InterfaceInfos
  required :string, :if_name, 1
  required :uint64, :init_time, 2
  optional :uint32, :snmp_if_index, 3
  optional :string, :parent_ae_name, 4
  repeated ::QueueStats, :egress_queue_info, 5
  repeated ::QueueStats, :ingress_queue_info, 6
  optional ::InterfaceStats, :ingress_stats, 7
  optional ::InterfaceStats, :egress_stats, 8
  optional ::IngressInterfaceErrors, :ingress_errors, 9
end

class InterfaceStats
  required :uint64, :if_pkts, 1
  required :uint64, :if_octets, 2
  required :uint64, :if_1sec_pkts, 3
  required :uint64, :if_1sec_octets, 4
  required :uint64, :if_uc_pkts, 5
  required :uint64, :if_mc_pkts, 6
  required :uint64, :if_bc_pkts, 7
end

class IngressInterfaceErrors
  optional :uint64, :if_in_errors, 1
  optional :uint64, :if_in_qdrops, 2
  optional :uint64, :if_in_frame_errors, 3
  optional :uint64, :if_in_discards, 4
  optional :uint64, :if_in_runts, 5
  optional :uint64, :if_in_l3_incompletes, 6
  optional :uint64, :if_in_l2chan_errors, 7
  optional :uint64, :if_in_l2_mismatch_timeouts, 8
  optional :uint64, :if_in_fifo_errors, 9
  optional :uint64, :if_in_resource_errors, 10
end

class QueueStats
  optional :uint32, :queue_number, 1
  optional :uint64, :packets, 2
  optional :uint64, :bytes, 3
  optional :uint64, :tail_drop_packets, 4
  optional :uint64, :rl_drop_packets, 5
  optional :uint64, :rl_drop_bytes, 6
  optional :uint64, :red_drop_packets, 7
  optional :uint64, :red_drop_bytes, 8
  optional :uint64, :avg_buffer_occupancy, 9
  optional :uint64, :cur_buffer_occupancy, 10
  optional :uint64, :peak_buffer_occupancy, 11
  optional :uint64, :allocated_buffer_size, 12
end


##
# Extended Message Fields
#
class ::JuniperNetworksSensors < ::Protobuf::Message
  optional ::GPort, :".jnpr_interface_ext", 3, :extension => true
end

