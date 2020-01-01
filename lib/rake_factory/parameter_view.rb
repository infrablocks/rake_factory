module RakeFactory
  class ParameterView
    attr_reader(:task)

    def initialize(task)
      configurable_parameters =
          task.class.parameter_set.where_configurable

      self.instance_eval do
        configurable_parameters.each do |parameter|
          define_singleton_method parameter.reader_method do
            task.send(parameter.reader_method)
          end

          define_singleton_method parameter.writer_method do |value|
            task.send(parameter.writer_method, value)
          end
        end
      end
    end
  end
end