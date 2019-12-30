require 'rake/tasklib'

require_relative 'parameters'
require_relative 'defaults'

module RakeFactory
  class Task < ::Rake::TaskLib
    extend Parameters
    extend Defaults

    def initialize(*args, &configuration_block)
      setup_defaults
      process_arguments(args)
      define_task(&configuration_block)
    end

    def setup_defaults
      self.class.parameter_set.apply_defaults_to(self)
    end

    def process_arguments(args)
      opts = args.first || {}

      set_if_present(:name, opts)
      set_if_present(:argument_names, opts)
      set_if_present(:prerequisites, opts)
      set_if_present(:order_only_prerequisites, opts)
    end

    def process_configuration_block(configuration_block, args)
      if configuration_block
        configuration_block.call(
            *[self, args].slice(0, configuration_block.arity))
      end
    end

    def check_required
      self.class.parameter_set.enforce_requirements_of(self)
    end

    def define_task(&configuration_block)
      task(
          name,
          argument_names => prerequisites,
          order_only: order_only_prerequisites
      ) do |_, args|
        process_configuration_block(configuration_block, args)
        check_required
      end
    end

    private

    def set_if_present(key, opts)
      self.send("#{key}=", opts[key]) unless opts[key].nil?
    end
  end
end