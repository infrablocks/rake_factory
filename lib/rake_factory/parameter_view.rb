module RakeFactory
  class ParameterView
    attr_reader(:task)

    def initialize(task)
      self.instance_eval do
        task.class.parameter_set.each do |parameter|
          define_singleton_method parameter.reader_method do
            task.send(parameter.reader_method)
          end

          if parameter.configurable?
            define_singleton_method parameter.writer_method do |value|
              task.send(parameter.writer_method, value)
            end
          end
        end
      end
    end
  end
end