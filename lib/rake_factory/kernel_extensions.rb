# frozen_string_literal: true

require_relative 'values'

module Kernel
  def dynamic(&)
    RakeFactory::DynamicValue.new(&)
  end

  def static(value)
    RakeFactory::StaticValue.new(value)
  end
end
