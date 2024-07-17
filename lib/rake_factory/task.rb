# frozen_string_literal: true

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

      define_task(application)
      add_description
      add_creator(creator)

      self
    end

    def method_missing(method, ...)
      if @task.respond_to?(method)
        @task.send(method, ...)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      @task.respond_to?(method) || super
    end

    private

    def parameter_view(args)
      ParameterView.new(self, self.class, self.class, args)
    end

    def define_task(application)
      @task = application.define_task(
        Rake::Task,
        name,
        argument_names => prerequisites,
        order_only: order_only_prerequisites
      ) do |_, args|
        invoke_configuration_block_on(parameter_view(args), args)
        check_parameter_requirements
        invoke_actions(args)
      end
    end

    def add_description
      @task.add_description(description)
    end

    def add_creator(creator)
      @task.instance_eval do
        define_singleton_method(:creator) { creator }
      end
    end
  end
end
