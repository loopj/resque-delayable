module ResqueDelayable
  module Serializer
    class ActiveRecordSerializer
      PREFIX = "ActiveRecord"
      MATCHER = Regexp.new("^#{PREFIX}_(\\w+)_(\\d+)$")

      class << self
        def serialize_match(object)
          object.is_a?(ActiveRecord::Base)
        end

        def deserialize_match(object)
          object.class == String && MATCHER.match(object)
        end

        def serialize(object)
          "#{PREFIX}_#{object.class}_#{object.id}"
        end
        
        def deserialize(object)
          match = MATCHER.match(object)
          match[1].constantize.find_by_id(match[2])
        end
      end
    end
  end
end

ResqueDelayable::ACTIVE_SERIALIZERS << ResqueDelayable::Serializer::ActiveRecordSerializer
ActiveRecord::Base.send :include, ResqueDelayable
