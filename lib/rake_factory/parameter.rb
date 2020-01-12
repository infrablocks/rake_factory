module RakeFactory
  class Parameter
    attr_reader(
        :name,
        :default,
        :required,
        :configurable,
        :transform)
    attr_writer(:default)

    def initialize(name, options)
      @name = name
      @default = options[:default] || nil
      @required = options[:required] || false
      @configurable =
          options[:configurable].nil? ? true : !!options[:configurable]
      @transform = options[:transform] || lambda { |x| x }
    end

    def writer_method
      "#{name}="
    end

    def reader_method
      name
    end

    def instance_variable
      "@#{name}"
    end

    def define_on(klass)
      parameter = self
      klass.class_eval do
        define_method parameter.writer_method do |value|
          instance_variable_set(parameter.instance_variable, value)
        end

        define_method parameter.reader_method do
          stored_value = instance_variable_get(parameter.instance_variable)
          resolved_value = stored_value.respond_to?(:call) ?
              stored_value.call(*[self].slice(0, stored_value.arity)) :
              stored_value
          transformed_value = parameter.transform.call(resolved_value)
          transformed_value
        end
      end
    end

    def apply_default_to(instance)
      instance.send(writer_method, @default) unless @default.nil?
    end

    def read_from(instance)
      instance.send(reader_method)
    end

    def configurable?
      @configurable
    end

    def dissatisfied_by?(instance)
      @required && read_from(instance).nil?
    end

    def satisfied_by?(instance)
      !dissatisfied_by?(instance)
    end
  end
end