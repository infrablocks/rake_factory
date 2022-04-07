# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/string/inflections'

require_relative 'parameters'

module RakeFactory
  module Defaults
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      include Parameters

      def inherited(inheritor)
        super(inheritor)
        inheritor.class_eval do
          name_parameter
          argument_names_parameter
          prerequisites_parameter
          order_only_prerequisites_parameter
          description_parameter

          maybe_set_default_name(inheritor)
        end
      end

      def default_name(name)
        parameter_set.update_default_for(:name, name)
      end

      def default_argument_names(argument_names)
        parameter_set.update_default_for(:argument_names, argument_names)
      end

      def default_prerequisites(prerequisites)
        parameter_set.update_default_for(:prerequisites, prerequisites)
      end

      def default_order_only_prerequisites(order_only_prerequisites)
        parameter_set
          .update_default_for(
            :order_only_prerequisites, order_only_prerequisites
          )
      end

      def default_description(description)
        parameter_set.update_default_for(:description, description)
      end

      private

      def maybe_set_default_name(inheritor)
        return if inheritor.name.nil?

        default_name inheritor.name.demodulize.underscore
      end

      def description_parameter
        parameter(:description,
                  configurable: false)
      end

      def order_only_prerequisites_parameter
        parameter(:order_only_prerequisites,
                  configurable: false,
                  default: [])
      end

      def prerequisites_parameter
        parameter(:prerequisites,
                  configurable: false,
                  default: [])
      end

      def argument_names_parameter
        parameter(:argument_names,
                  configurable: false,
                  default: [])
      end

      def name_parameter
        parameter(:name,
                  configurable: false,
                  transform: ->(n) { n.respond_to?(:to_sym) ? n.to_sym : n })
      end
    end
  end
end
