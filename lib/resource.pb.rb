# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf'

module Resource
  ::Protobuf::Optionable.inject(self) { ::Google::Protobuf::FileOptions }

  ##
  # Message Classes
  #
  class AttributeStats < ::Protobuf::Message; end
  class Resource < ::Protobuf::Message; end


  ##
  # Message Fields
  #
  class AttributeStats
    required :string, :name, 1
    optional :int64, :int64_v, 8
    repeated ::Resource::AttributeStats, :attribute, 32
  end

  class Resource
    optional :uint64, :timestamp, 1
    optional :string, :data_id, 2
    repeated ::Resource::AttributeStats, :attribute, 5
  end

end

