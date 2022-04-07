# frozen_string_literal: true

module RakeFactory
  module Configurable
    def self.included(base)
      base.class_eval do
        attr_accessor(:configuration_block)
      end
    end

    def initialize(*args, &configuration_block)
      arity = method(:initialize).super_method.arity
      super(*args.slice(0, arity), &configuration_block)
      process_configuration_block(configuration_block)
    end

    def process_configuration_block(configuration_block)
      set_if_value_present(:configuration_block, configuration_block)
    end

    def invoke_configuration_block_on(target, args)
      return unless configuration_block

      params = args ? [target, args] : [target]
      configuration_block.call(
        *params.slice(0, configuration_block.arity)
      )
    end

    private

    def set_if_value_present(key, value)
      send("#{key}=", value) if respond_to?("#{key}=") && !value.nil?
    end
  end
end
