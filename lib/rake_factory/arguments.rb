module RakeFactory
  module Arguments
    def initialize(*args, &configuration_block)
      arity = self.method(:initialize).super_method.arity
      super(*args.slice(0, arity), &configuration_block)
      process_arguments(args)
    end

    def process_arguments(args)
      opts = args.first || {}
      opts.each { |key, value| set_if_parameter(key, value) }
    end

    private

    def set_if_parameter(key, value)
      if self.respond_to?("#{key}=")
        self.send("#{key}=", value)
      end
    end
  end
end
