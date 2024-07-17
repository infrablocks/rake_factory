# frozen_string_literal: true

module RakeFactory
  module Namespaceable
    # rubocop:disable Metrics/MethodLength
    def self.prepended(base)
      super
      base.class_eval do
        parameter(:namespace, transform: lambda { |name|
          name = name.to_s if name.is_a?(Symbol)
          name = name.to_str if name.respond_to?(:to_str)
          unless name.is_a?(String) || name.nil?
            raise ArgumentError,
                  'Expected a String or Symbol for a namespace name'
          end
          name
        })
      end
    end
    # rubocop:enable Metrics/MethodLength

    def around_define(application)
      if namespace
        application.in_namespace(namespace) do
          super(application)
        end
      else
        super
      end
    end
  end
end
