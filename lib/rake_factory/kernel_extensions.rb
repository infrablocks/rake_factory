# frozen_string_literal: true

require_relative 'values'

module Kernel
  def dynamic(&block)
    RakeFactory::DynamicValue.new(&block)
  end

  def static(value)
    RakeFactory::StaticValue.new(value)
  end
end
