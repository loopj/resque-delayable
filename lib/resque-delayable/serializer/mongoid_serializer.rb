module ResqueDelayable
  module Serializer
    class MongoidSerializer
      PREFIX = "Mongoid"
      MATCHER = Regexp.new("^#{PREFIX}_([^_]+)_([^_]+)$")

      class << self
        def serialize_match(object)
          object.is_a?(Mongoid::Document)
        end

        def deserialize_match(object)
          object.class == String && MATCHER.match(object)
        end
        
        def serialize(object)
          "#{PREFIX}_#{object.class}_#{object.id}"
        end
        
        def deserialize(object)
          match = MATCHER.match(object)
          match[1].constantize.find_by_id(id)
        end
      end
    end
  end
end

ResqueDelayable::ACTIVE_SERIALIZERS << ResqueDelayable::Serializer::MongoidSerializer
Mongoid::Document.send :include, ResqueDelayable