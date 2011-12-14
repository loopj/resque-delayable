module ResqueDelayable
  require "resque"

  begin
    require "resque/scheduler"
  rescue LoadError
  end

  class DelayedMethod
    attr_accessor :klass
    attr_accessor :instance
    attr_accessor :options

    def initialize(klass, instance = nil, options = {})
      unless instance.nil? || ResqueDelayable::ACTIVE_SERIALIZERS.any? {|klass| klass.serialize_match(instance) }
        raise "Cannot serialize instances of this type (#{instance.class}). Consider creating a serializer."
      end

      self.klass = klass
      self.instance = instance
      self.options = options
    end
  
    def dequeue(method, *parameters)
      ::Resque.dequeue(self.klass, method, ::ResqueDelayable::serialize_object(self.instance), *::ResqueDelayable::serialize_object(parameters))
    end

    def method_missing(method, *parameters)
      if instance.nil?
        raise NoMethodError.new("undefined method '#{method}' for #{self.klass}", method, parameters) unless klass.respond_to?(method)
      else
        raise NoMethodError.new("undefined method '#{method}' for #{self.instance}", method, parameters) unless instance.respond_to?(method)
      end

      if self.options[:run_at]
        if ::Resque.respond_to?(:enqueue_at)
          ::Resque.enqueue_at(self.options[:run_at], self.klass, method, ::ResqueDelayable::serialize_object(self.instance), *::ResqueDelayable::serialize_object(parameters))
        else
          raise "Cannot use run_at, resque-scheduler not installed"
        end
      elsif self.options[:run_in]
        if ::Resque.respond_to?(:enqueue_in)
          ::Resque.enqueue_in(self.options[:run_in], self.klass, method, ::ResqueDelayable::serialize_object(self.instance), *::ResqueDelayable::serialize_object(parameters))
        else
          raise "Cannot use run_in, resque-scheduler not installed"
        end
      else
        ::Resque.enqueue(self.klass, method, ::ResqueDelayable::serialize_object(self.instance), *::ResqueDelayable::serialize_object(parameters))
      end

      true
    end
  end
end