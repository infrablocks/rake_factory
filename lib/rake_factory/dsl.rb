require_relative 'defaults'
require_relative 'parameter'
require_relative 'parameters'

module RakeFactory
  module DSL
    def defaults
      @defaults ||= Defaults.new
    end

    def default_name(name)
      defaults.name = name
    end

    def default_argument_names(argument_names)
      defaults.argument_names = argument_names
    end

    def default_prerequisites(prerequisites)
      defaults.prerequisites = prerequisites
    end

    def default_order_only_prerequisites(order_only_prerequisites)
      defaults.order_only_prerequisites = order_only_prerequisites
    end

    def parameters
      @parameters ||= Parameters.new
    end

    def parameter(name, options = {})
      parameter_definition =
          Parameter.new(name, options[:default], options[:required])
      attr_accessor(parameter_definition.name)
      parameters.add(parameter_definition)
    end
  end
end