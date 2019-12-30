module RakeFactory
  class Defaults
    attr_reader :name
    attr_accessor(
        :argument_names,
        :prerequisites,
        :order_only_prerequisites)

    def name=(name)
      @name = name.to_sym
    end

    def apply_to(instance)
      instance.send("name=", name)
      instance.send("argument_names=", argument_names)
      instance.send("prerequisites=", prerequisites)
      instance.send("order_only_prerequisites=", order_only_prerequisites)
    end
  end
end