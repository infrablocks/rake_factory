* Allow parameter reads to be memoized
* More clearly distinguish between construction and runtime parameters
  - Parameter types:
    - definition-time parameter: must be set before definition of the task.
    - invocation-time parameter: can be set before or after definition of the 
      task; can be set in configuration block.
  - Parameter value types:
    - static value: do not depend on task set / task / runtime arguments.
    - dynamic value: require task set / task / runtime arguments in order to be
      resolved.
  - For tasks:
    - definition-time parameters can have static values and dynamic values of 
      arity zero or one, optionally taking the task itself
    - invocation-time parameters can have static values and dynamic values of 
      arity zero, one or two, optionally taking the task itself and the runtime
      arguments
  - For task sets:
    - all parameters are definition-time