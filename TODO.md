* Allow extenders to define action(s) within Task
* Define description within Task 
* Split parameters into:
  - Static parameters: passed in at task construction time, as part of the 
    options map
  - Dynamic parameters: configurable via a block which has access to the task 
    and arguments, or passed in at task construction time, as part of the 
    options map
* Create TaskSet base class
