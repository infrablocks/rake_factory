# frozen_string_literal: true

module RakeFactory
  module Values
    def self.resolve(value)
      case value
      when RakeFactory::DynamicValue, RakeFactory::StaticValue
        value
      else
        RakeFactory::StaticValue.new(value)
      end
    end

    module FactoryMethods
      def dynamic(&block)
        DynamicValue.new(&block)
      end

      def static(value)
        StaticValue.new(value)
      end
    end
  end

  class DynamicValue
    def initialize(pre_arguments = [], post_arguments = [], &block)
      @block = block
      @pre_arguments = pre_arguments
      @post_arguments = post_arguments
    end

    def prepend_argument(argument)
      self.class.new(
        [argument, *@pre_arguments], @post_arguments, &@block
      )
    end

    def append_argument(argument)
      self.class.new(
        @pre_arguments, [*@post_arguments, argument], &@block
      )
    end

    def evaluate(arguments)
      resolved_arguments = [*@pre_arguments, *arguments, *@post_arguments]
      @block.call(*resolved_arguments.slice(0, @block.arity))
    end
  end

  class StaticValue
    def initialize(value)
      @value = value
    end

    def prepend_argument(_)
      self
    end

    def append_argument(_)
      self
    end

    def evaluate(*_)
      @value
    end
  end
end
