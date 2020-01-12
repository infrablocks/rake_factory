require 'rake/tasklib'

require_relative 'parameters'
require_relative 'definable'
require_relative 'defaults'

module RakeFactory
  class TaskSet < ::Rake::TaskLib
    extend Definable

    include Parameters
    include Configurable
    include Arguments

    class TaskDefinition
      attr_accessor :klass, :args, :overrides, :block

      def initialize(klass, *args, &block)
        self.klass = klass
        self.args = args
        self.block = block
        self.overrides = {}
      end

      def with_overrides(overrides)
        self.overrides = overrides
        self
      end

      def define_on(application)
        self.klass.new(*resolved_args, &self.block)
            .define_on(application)
      end

      private

      def resolved_args
        initial_args = self.args.empty? && self.overrides ?
            [self.overrides] : self.args

        unless initial_args.first && initial_args.first.is_a?(Hash)
          return initial_args
        end

        other_args = initial_args.drop(1)
        merged_parameters = initial_args.first.merge(self.overrides)
        merged_parameters = merged_parameters.include?(:name_parameter) ?
            {name: self.overrides[merged_parameters[:name_parameter]]}
                .merge(merged_parameters) :
            merged_parameters

        [merged_parameters, *other_args]
      end
    end

    class << self
      def tasks
        @tasks ||= []
      end

      def task(klass, *args, &block)
        tasks << TaskDefinition.new(klass, *args, &block)
      end
    end

    def define_on(application)
      invoke_configuration_block
      parameter_values = self.parameter_values
      self.class.tasks.each do |task_definition|
        task_definition
            .with_overrides(parameter_values)
            .define_on(application)
      end
      self
    end
  end
end
