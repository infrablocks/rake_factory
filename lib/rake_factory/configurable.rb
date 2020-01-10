module RakeFactory
  module Configurable
    attr_accessor(:configuration_block)

    def initialize(*args, &configuration_block)
      arity = self.method(:initialize).super_method.arity
      super(*args.slice(0, arity), &configuration_block)
      process_configuration_block(configuration_block)
    end

    def process_configuration_block(configuration_block)
      set_if_value_present(:configuration_block, configuration_block)
    end

    def invoke_configuration_block(args)
      if configuration_block
        view = ParameterView.new(self, args)
        configuration_block.call(
            *[view, args].slice(0, configuration_block.arity))
      end
    end

    private

    def set_if_value_present(key, value)
      if self.respond_to?("#{key}=") && !value.nil?
        self.send("#{key}=", value)
      end
    end
  end
end