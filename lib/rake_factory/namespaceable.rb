module RakeFactory
  module Namespaceable
    def self.prepended(base)
      super(base)
      base.class_eval do
        parameter(:namespace,
            transform: lambda { |name|
              name = name.to_s if name.kind_of?(Symbol)
              name = name.to_str if name.respond_to?(:to_str)
              unless name.kind_of?(String) || name.nil?
                raise ArgumentError,
                    "Expected a String or Symbol for a namespace name"
              end
              name
            })
      end
    end

    def around_define(application)
      if namespace
        application.in_namespace(namespace) do
          super(application)
        end
      else
        super(application)
      end
    end
  end
end
