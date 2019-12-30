require_relative 'exceptions'

module RakeFactory
  class Parameters
    def initialize
      @parameters = {}
    end

    def add(definition)
      @parameters[definition.name] = definition
    end

    def apply_defaults_to(instance)
      @parameters.values.each do |parameter|
        parameter.apply_default_to(instance)
      end
    end

    def enforce_requirements_of(instance)
      dissatisfied = @parameters.values.reject do |parameter|
        parameter.satisfied_by?(instance)
      end
      unless dissatisfied.empty?
        names = dissatisfied.map(&:name)
        names_string = names.join(',')
        maybe_plural = names.length > 1 ? 's' : ''

        raise RequiredParameterUnset,
            "Required parameter#{maybe_plural} #{names_string} unset."
      end
    end
  end
end