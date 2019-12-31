module RakeFactory
  module Actions
    def actions
      @actions ||= []
    end

    def action(&action_block)
      actions << action_block
    end
  end
end
