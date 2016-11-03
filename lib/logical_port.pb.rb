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
class LogicalPort < ::Protobuf::Message; end
class LogicalInterfaceInfo < ::Protobuf::Message; end
class IngressInterfaceStats < ::Protobuf::Message; end
class EgressInterfaceStats < ::Protobuf::Message; end
class OperationalState < ::Protobuf::Message; end
class ForwardingClassAccounting < ::Protobuf::Message; end


##
# Message Fields
#
class LogicalPort
  repeated ::LogicalInterfaceInfo, :interface_info, 1
end

class LogicalInterfaceInfo
  required :string, :if_name, 1
  required :uint64, :init_time, 2
  optional :uint32, :snmp_if_index, 3
  optional :string, :parent_ae_name, 4
  optional ::IngressInterfaceStats, :ingress_stats, 5
  optional ::EgressInterfaceStats, :egress_stats, 6
  optional ::OperationalState, :op_state, 7
end

class IngressInterfaceStats
  required :uint64, :if_packets, 1
  required :uint64, :if_octets, 2
  optional :uint64, :if_ucast_packets, 3
  required :uint64, :if_mcast_packets, 4
  repeated ::ForwardingClassAccounting, :if_fc_stats, 5
end

class EgressInterfaceStats
  required :uint64, :if_packets, 1
  required :uint64, :if_octets, 2
end

class OperationalState
  optional :string, :operational_status, 1
end

class ForwardingClassAccounting
  optional :string, :if_family, 1
  optional :uint32, :fc_number, 2
  optional :uint64, :if_packets, 3
  optional :uint64, :if_octets, 4
end


##
# Extended Message Fields
#
class ::JuniperNetworksSensors < ::Protobuf::Message
  optional ::LogicalPort, :".jnprLogicalInterfaceExt", 7, :extension => true
end

