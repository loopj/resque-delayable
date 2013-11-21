module ResqueDelayable
  require "set"

  ACTIVE_SERIALIZERS = Set.new

  require "resque-delayable/delayed_method"

  def self.included(base)
    base.extend(ClassMethods)
    super
  end
  
  def self.serialize_object(object)
    if [Hash, HashWithIndifferentAccess].include?(object.class)
      object.inject(HashWithIndifferentAccess.new) {|doc, (k,v)| doc[k] = serialize_object(v); doc}
    elsif [Set, Array].include?(object.class)
      object.map {|v| serialize_object(v)}
    else
      ACTIVE_SERIALIZERS.each do |serializer|
        return serializer.serialize(object) if serializer.serialize_match(object)
      end
      
      object
    end
  end

  def self.deserialize_object(object)
    if [Hash, HashWithIndifferentAccess].include?(object.class)
      object.inject(HashWithIndifferentAccess.new) {|doc, (k,v)| doc[k] = deserialize_object(v); doc}
    elsif [Set, Array].include?(object.class)
      object.map {|v| deserialize_object(v)}
    else
      ACTIVE_SERIALIZERS.each do |serializer|
        return serializer.deserialize(object) if serializer.deserialize_match(object)
      end

      object
    end
  end

  module ClassMethods
    def rdelay(options = {})
      return DelayedMethod.new(self, nil, options)
    end

    def perform(cmd, instance, *args)
      deserialized_args = ::ResqueDelayable.deserialize_object(args)

      if instance
        # Instance method 
        deserialized_instance = ::ResqueDelayable.deserialize_object(instance)
        if deserialized_instance
          deserialized_instance.send(cmd, *deserialized_args)
        else
          puts "ResqueDelayable couldn't find instance '#{instance}' to peform method '#{cmd}' on"
        end
      else
        # Class method
        send(cmd, *deserialized_args)
      end
    end
  
    def queue
      @queue ||= self.name
    end
  end

  def rdelay(options = {})
    return DelayedMethod.new(self.class, self, options)
  end
end

# Serialization plugins
require "resque-delayable/serializer/active_record_serializer"  if defined? ActiveRecord::Base
require "resque-delayable/serializer/mongo_mapper_serializer"   if defined? MongoMapper::Document
require "resque-delayable/serializer/mongoid_serializer"        if defined? Mongoid::Document
