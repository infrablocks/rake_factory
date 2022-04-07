# frozen_string_literal: true

require_relative 'values'

module RakeFactory
  class Parameter
    attr_accessor :default
    attr_reader :name, :required, :configurable, :transform

    def initialize(name, options)
      @name = name
      @default = options[:default]
      @required = options[:required] || false
      @transform = options[:transform] || ->(x) { x }
      @configurable =
        options[:configurable].nil? ? true : !!options[:configurable]
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
          parameter.set(self, value)
        end

        define_method parameter.reader_method do
          parameter.get(self)
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

    def set(target, value)
      target.instance_variable_set(instance_variable, value)
    end

    def get(target)
      stored_value = target.instance_variable_get(instance_variable)
      resolved_value = Values.resolve(stored_value).evaluate([target])
      transform.call(resolved_value)
    end
  end
end
