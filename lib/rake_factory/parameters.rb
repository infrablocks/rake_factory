# frozen_string_literal: true

require_relative 'parameter_set'

module RakeFactory
  module Parameters
    def self.included(base)
      base.extend(ClassMethods)
    end

    def initialize(*args, &configuration_block)
      arity = method(:initialize).super_method.arity
      super(*args.slice(0, arity), &configuration_block)
      setup_parameter_defaults
    end

    def parameter_values
      self.class.parameter_set.read_from(self)
    end

    def setup_parameter_defaults
      self.class.parameter_set.apply_defaults_to(self)
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
