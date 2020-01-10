require_relative 'parameter_set'

module RakeFactory
  module Parameters
    def self.included(base)
      base.extend(ClassMethods)
    end

    def check_parameter_requirements
      self.class.parameter_set.enforce_requirements_on(self)
    end

    module ClassMethods
      def parameter_set
        @parameter_set ||= ParameterSet.new
      end

      def parameter(name, options = {})
        parameter = parameter_set.add(name, options)
        parameter.define_on(self)
      end
    end
  end
end
