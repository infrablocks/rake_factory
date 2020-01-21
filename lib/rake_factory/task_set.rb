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

    class << self
      def tasks
        @tasks ||= []
      end

      def task(klass, *args, &block)
        tasks << TaskSpecification.new(klass, args, &block)
      end
    end

    def define_on(application)
      around_define(application) do
        self.class.tasks.each do |task_definition|
          task_definition
              .for_task_set(self)
              .define_on(application)
        end
      end
      self
    end

    def around_define(application)
      yield
    end

    private

    class TaskArguments
      attr_reader :arguments, :task_set

      def initialize(arguments, task_set)
        @arguments = arguments || []
        @task_set = task_set
      end

      def parameter_overrides
        task_set&.parameter_values || {}
      end

      def parameter_hash
        arguments.first.is_a?(Hash) ?
            arguments.first :
            {}
      end

      def resolve
        if arguments.empty?
          return [parameter_overrides]
        end

        if arguments.first.is_a?(Hash)
          return [
              parameter_overrides
                  .merge(process_parameter_hash(arguments.first)),
              *arguments.drop(1)
          ]
        end

        arguments
      end

      private

      def process_parameter_hash(parameter_hash)
        parameter_hash.reduce({}) do |acc, (name, value)|
          resolved_value = lambda do |t|
            value.respond_to?(:call) ?
                value.call(*[task_set, t].slice(0, value.arity)) :
                value
          end
          acc.merge({name => resolved_value})
        end
      end
    end

    class TaskSpecification
      attr_reader :klass, :args, :block

      def initialize(klass, args, &block)
        @klass = klass
        @args = args
        @block = block
      end

      def for_task_set(task_set)
        TaskDefinition.new(klass, args, task_set, &block)
      end
    end

    class TaskDefinition
      attr_reader :task_set, :klass, :args, :block

      def initialize(klass, args, task_set, &block)
        @task_set = task_set
        @klass = klass
        @args = args
        @block = block
      end

      def define_on(application)
        if should_define?
          klass.new(*resolve_arguments, &resolve_block).define_on(application)
        end
      end

      private

      def task_arguments
        TaskArguments.new(args, task_set)
      end

      def should_define?
        task_arguments.parameter_hash.include?(:define_if) ?
            task_arguments.parameter_hash[:define_if].call(task_set) :
            true
      end

      def resolve_arguments
        task_arguments.resolve
      end

      def resolve_block
        lambda do |t, args|
          if block.respond_to?(:call)
            block.call(*[task_set, t, args].slice(0, block.arity))
          end
          if task_set.configuration_block.respond_to?(:call)
            view = ParameterView.new(t, t.class, task_set.class, args)
            task_set.invoke_configuration_block_on(view, args)
          end
        end
      end
    end

    private_constant :TaskArguments
    private_constant :TaskSpecification
    private_constant :TaskDefinition
  end
end
