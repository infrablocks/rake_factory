require 'rake/tasklib'

require_relative 'parameters'
require_relative 'parameter_view'
require_relative 'actions'
require_relative 'configurable'
require_relative 'defaults'
require_relative 'definable'
require_relative 'arguments'

module RakeFactory
  class Task < ::Rake::TaskLib
    extend Definable

    include Parameters
    include Configurable
    include Defaults
    include Arguments
    include Actions

    def define_on(application)
      creator = self

      @task = application.define_task(
          Rake::Task,
          name,
          argument_names => prerequisites,
          order_only: order_only_prerequisites
      ) do |_, args|
        view = ParameterView.new(self, self.class, self.class, args)
        invoke_configuration_block_on(view, args)
        check_parameter_requirements
        invoke_actions(args)
      end
      @task.add_description(description)
      @task.instance_eval do
        define_singleton_method(:creator) { creator }
      end

      self
    end

    def method_missing(method, *args, &block)
      if @task.respond_to?(method)
        @task.send(method, *args, &block)
      else
        super(method, *args, &block)
      end
    end
  end
end
