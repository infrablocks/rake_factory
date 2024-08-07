# frozen_string_literal: true

require_relative 'parameter'
require_relative 'exceptions'

module RakeFactory
  class ParameterSet
    def initialize
      @parameter_set = {}
    end

    def add(name, options)
      parameter = Parameter.new(name, options)
      @parameter_set[parameter.name] = parameter
      parameter
    end

    def find(name)
      @parameter_set[name.to_sym]
    end

    def each(&)
      @parameter_set.values.each(&)
    end

    def update_default_for(name, value)
      find(name).default = value
    end

    def apply_defaults_to(instance)
      @parameter_set.each_value do |parameter|
        parameter.apply_default_to(instance)
      end
    end

    def enforce_requirements_on(instance)
      dissatisfied = @parameter_set.values.reject do |parameter|
        parameter.satisfied_by?(instance)
      end
      return if dissatisfied.empty?

      names = dissatisfied.map(&:name)
      names_string = names.join(',')
      pluralisation_string = names.length > 1 ? 's' : ''

      raise RequiredParameterUnset,
            "Required parameter#{pluralisation_string} #{names_string} unset."
    end

    def read_from(instance)
      @parameter_set.reduce({}) do |acc, (key, parameter)|
        acc.merge({ key => parameter.read_from(instance) })
      end
    end
  end
end
