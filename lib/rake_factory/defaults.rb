require 'active_support'
require 'active_support/core_ext/string/inflections'

require_relative 'parameters'

module RakeFactory
  module Defaults
    include Parameters

    def inherited(inheritor)
      inheritor.class_eval do
        parameter :name, transform: lambda { |n| n.to_sym }
        parameter :argument_names, default: []
        parameter :prerequisites, default: []
        parameter :order_only_prerequisites, default: []

        unless inheritor.name.nil?
          default_name inheritor.name.demodulize.underscore
        end
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
              :order_only_prerequisites, order_only_prerequisites)
    end
  end
end