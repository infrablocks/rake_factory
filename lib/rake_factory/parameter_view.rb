require_relative 'values'

module RakeFactory
  class ParameterView
    attr_reader(:task)

    def initialize(target, reader_class, writer_class, runtime_arguments)
      self.instance_eval do
        reader_class.parameter_set.each do |parameter|
          define_singleton_method parameter.reader_method do
            target.send(parameter.reader_method)
          end
        end
        writer_class.parameter_set.each do |parameter|
          if parameter.configurable?
            define_singleton_method parameter.writer_method do |value|
              if target.respond_to?(parameter.writer_method)
                target.send(
                    parameter.writer_method,
                    Values.resolve(value).append_argument(runtime_arguments))
              end
            end
          end
        end
      end
      self.class.instance_eval do
        define_singleton_method :parameter_set do
          reader_class.parameter_set
        end
      end
    end
  end
end
