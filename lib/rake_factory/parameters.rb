require_relative 'parameter_set'

module RakeFactory
  module Parameters
    def parameter_set
      @parameter_set ||= ParameterSet.new
    end

    def parameter(name, options = {})
      parameter = parameter_set.add(name, options)
      parameter.define_on(self)
    end
  end
end