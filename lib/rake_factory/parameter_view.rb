# frozen_string_literal: true

require_relative 'values'

module RakeFactory
  class ParameterView
    attr_reader(:task)

    def initialize(target, reader_class, writer_class, runtime_arguments)
      instance_eval do
        define_reader_methods(target, reader_class)
        define_writer_methods(target, writer_class, runtime_arguments)
      end
      self.class.instance_eval do
        define_singleton_method :parameter_set do
          reader_class.parameter_set
        end
      end
    end

    private

    def define_reader_methods(target, reader_class)
      reader_class.parameter_set.each do |parameter|
        define_reader_method(target, parameter)
      end
    end

    def define_reader_method(target, parameter)
      define_singleton_method parameter.reader_method do
        target.send(parameter.reader_method)
      end
    end

    def define_writer_methods(target, writer_class, runtime_arguments)
      writer_class.parameter_set.each do |parameter|
        define_writer_method(target, parameter, runtime_arguments)
      end
    end

    def define_writer_method(target, parameter, runtime_arguments)
      return unless parameter.configurable?

      define_singleton_method parameter.writer_method do |value|
        return unless target.respond_to?(parameter.writer_method)

        target.send(
          parameter.writer_method,
          Values.resolve(value).append_argument(runtime_arguments)
        )
      end
    end
  end
end
