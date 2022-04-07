# frozen_string_literal: true

module RakeFactory
  module Definable
    def inherited(inheritor)
      super(inheritor)
      inheritor.singleton_class.class_eval do
        define_method :define do |*args, &block|
          inheritor.new(*args, &block).define_on(Rake.application)
        end
      end
    end
  end
end
