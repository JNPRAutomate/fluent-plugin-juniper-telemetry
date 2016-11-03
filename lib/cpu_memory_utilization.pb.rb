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
class CpuMemoryUtilization < ::Protobuf::Message; end
class CpuMemoryUtilizationSummary < ::Protobuf::Message; end
class CpuMemoryUtilizationPerApplication < ::Protobuf::Message; end


##
# Message Fields
#
class CpuMemoryUtilization
  repeated ::CpuMemoryUtilizationSummary, :utilization, 1
end

class CpuMemoryUtilizationSummary
  optional :string, :name, 1
  optional :uint64, :size, 2
  optional :uint64, :bytes_allocated, 3
  optional :int32, :utilization, 4
  repeated ::CpuMemoryUtilizationPerApplication, :application_utilization, 5
end

class CpuMemoryUtilizationPerApplication
  optional :string, :name, 1
  optional :uint64, :bytes_allocated, 2
  optional :uint64, :allocations, 3
  optional :uint64, :frees, 4
  optional :uint64, :allocations_failed, 5
end


##
# Extended Message Fields
#
class ::JuniperNetworksSensors < ::Protobuf::Message
  optional ::CpuMemoryUtilization, :".cpu_memory_util_ext", 1, :extension => true
end

