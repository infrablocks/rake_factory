require 'rake/tasklib'

require_relative 'parameters'
require_relative 'parameter_view'
require_relative 'actions'
require_relative 'defaults'

module RakeFactory
  class Task < ::Rake::TaskLib
    extend Parameters
    extend Actions
    extend Defaults

    attr_accessor(:configuration_block)

    def self.inherited(inheritor)
      super(inheritor)
      inheritor.singleton_class.class_eval do
        define_method :define do |*args, &block|
          inheritor.new(*args, &block).define_on(Rake.application)
        end
      end
    end

    def initialize(*args, &configuration_block)
      setup_parameter_defaults
      process_arguments(args)
      process_configuration_block(configuration_block)
    end

    def setup_parameter_defaults
      self.class.parameter_set.apply_defaults_to(self)
    end

    def process_arguments(args)
      opts = args.first || {}
      opts.each { |key, value| set_if_value_present(key, value) }
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

    def check_parameter_requirements
      self.class.parameter_set.enforce_requirements_on(self)
    end

    def invoke_actions(args)
      self.class.actions.each do |action|
        self.instance_exec(*[self, args].slice(0, action.arity), &action)
      end
    end

    def define_on(application)
      @task = application.define_task(
          Rake::Task,
          name,
          argument_names => prerequisites,
          order_only: order_only_prerequisites
      ) do |_, args|
        invoke_configuration_block(args)
        check_parameter_requirements
        invoke_actions(args)
      end
      @task.add_description(description)

      self
    end

    def method_missing(method, *args, &block)
      if @task.respond_to?(method)
        @task.send(method, *args, &block)
      else
        super(method, *args, &block)
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
