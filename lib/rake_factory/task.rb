require 'rake/tasklib'
require 'active_support'
require 'active_support/core_ext/string/inflections'

require_relative 'dsl'

module RakeFactory
  class Task < ::Rake::TaskLib
    extend DSL

    attr_accessor(
        :name,
        :argument_names,
        :prerequisites,
        :order_only_prerequisites)

    def self.inherited(inheritor)
      inheritor.class_eval do
        name = inheritor.name

        default_name name.demodulize.underscore unless name.nil?
        default_argument_names []
        default_prerequisites []
        default_order_only_prerequisites []
      end
    end

    def initialize(*args, &block)
      setup_defaults
      process_arguments(args)
      process_block(block)
      check_required
      define
    end

    def setup_defaults
      self.class.defaults.apply_to(self)
      self.class.parameters.apply_defaults_to(self)
    end

    def process_arguments(args)
      opts = args.first || {}

      set_if_present(:name, opts)
      set_if_present(:argument_names, opts)
      set_if_present(:prerequisites, opts)
      set_if_present(:order_only_prerequisites, opts)
    end

    def process_block(block)
      block.call(self) if block
    end

    def check_required
      self.class.parameters.enforce_requirements_of(self)
    end

    def define
    end

    private

    def set_if_present(key, opts)
      self.send("#{key}=", opts[key]) unless opts[key].nil?
    end
  end
end