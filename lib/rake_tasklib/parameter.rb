module RakeTaskLib
  class Parameter
    attr_reader :name

    def initialize(name, default = nil, required = false)
      @name = name.to_sym
      @default = default
      @required = required
    end

    def writer_method
      "#{name}="
    end

    def reader_method
      name
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