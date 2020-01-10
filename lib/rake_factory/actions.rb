module RakeFactory
  module Actions
    def self.included(base)
      base.extend(ClassMethods)
    end

    def invoke_actions(args)
      self.class.actions.each do |action|
        self.instance_exec(*[self, args].slice(0, action.arity), &action)
      end
    end

    module ClassMethods
      def actions
        @actions ||= []
      end

      def action(&action_block)
        actions << action_block
      end
    end
  end
end
