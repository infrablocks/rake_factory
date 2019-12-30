* Split parameters into:
  - Static parameters: passed in at task construction time, as part of the 
    options map
  - Dynamic parameters: configurable via a block which has access to the task 
    and arguments, or passed in at task construction time, as part of the 
    options map
* Define description and task within Task and allow extenders to define action
* Create separate Task and TaskSet base classes
* Pull out parameter / bootstrap logic completely since both Task and TaskSet
  will want it
* Although, for TaskSet, there isn't really a concept of dynamic...
* Rename library
