module RakeFactory
  module Configurable
    def self.included(base)
      base.class_eval do
        attr_accessor(:configuration_block)
      end
    end

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