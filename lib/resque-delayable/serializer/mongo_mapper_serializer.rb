module ResqueDelayable
  module Serializer
    class MongoMapperSerializer
      PREFIX = "MongoMapper"
      MATCHER = Regexp.new("^#{PREFIX}_([^_]+)_([^_]+)_([^_]+)$")

      class << self
        def serialize_match(object)
          object.is_a?(MongoMapper::Document)
        end

        def deserialize_match(object)
          object.class == String && MATCHER.match(object)
        end
        
        def serialize(object)
          "#{PREFIX}_#{object.class}_#{object.id.class}_#{object.id}"
        end
        
        def deserialize(object)
          match = MATCHER.match(object)

          id = match[3]
          id = id.to_i if match[2] == "Fixnum"
          
          match[1].constantize.find_by_id(id)
        end
      end
    end
  end
end

ResqueDelayable::ACTIVE_SERIALIZERS << ResqueDelayable::Serializer::MongoMapperSerializer
MongoMapper::Document.send :include, ResqueDelayable