# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf'


##
# Message Classes
#
class OpenConfigData < ::Protobuf::Message; end
class KeyValue < ::Protobuf::Message; end


##
# Message Fields
#
class OpenConfigData
  optional :string, :system_id, 1
  optional :uint32, :component_id, 2
  optional :uint32, :sub_component_id, 3
  optional :string, :path, 4
  optional :uint64, :sequence_number, 5
  optional :uint64, :timestamp, 6
  repeated ::KeyValue, :kv, 7
end

class KeyValue
  optional :string, :key, 1
  optional :double, :double_value, 5
  optional :int64, :int_value, 6
  optional :uint64, :uint_value, 7
  optional :sint64, :sint_value, 8
  optional :bool, :bool_value, 9
  optional :string, :str_value, 10
  optional :bytes, :bytes_value, 11
end

