module RakeFactory
  class Parameter
    attr_reader(:name, :default, :required, :transform)
    attr_writer(:default)

    def initialize(name, options)
      @name = name
      @default = options[:default] || nil
      @required = options[:required] || false
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
        attr_reader parameter.reader_method
        define_method parameter.writer_method do |value|
          instance_variable_set(
              parameter.instance_variable,
              parameter.transform.call(value))
        end
      end
    end

    def apply_default_to(instance)
      instance.send(writer_method, @default) unless @default.nil?
    end

    def dissatisfied_by?(instance)
      value = instance.send(reader_method)
      @required && value.nil?
    end

    def satisfied_by?(instance)
      !dissatisfied_by?(instance)
    end
  end
end