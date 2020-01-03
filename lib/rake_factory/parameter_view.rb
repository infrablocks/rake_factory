module RakeFactory
  class ParameterView
    attr_reader(:task)

    def initialize(task, args)
      self.instance_eval do
        task.class.parameter_set.each do |parameter|
          define_singleton_method parameter.reader_method do
            task.send(parameter.reader_method)
          end

          if parameter.configurable?
            define_singleton_method parameter.writer_method do |value|
              resolved_value = lambda do |t|
                value.respond_to?(:call) ?
                    value.call(*[t, args].slice(0, value.arity)) :
                    value
              end
              task.send(parameter.writer_method, resolved_value)
            end
          end
        end
      end
    end
  end
end
