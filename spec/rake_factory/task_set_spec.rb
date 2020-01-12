require 'spec_helper'

describe RakeFactory::TaskSet do
  include_context :rake

  it 'adds an attribute reader and writer for each parameter specified' do
    class TestTaskSet1b16 < RakeFactory::TaskSet
      parameter :spinach
      parameter :lettuce
    end

    test_task_set = TestTaskSet1b16.define
    test_task_set.spinach = 'healthy'
    test_task_set.lettuce = 'dull'

    expect(test_task_set.spinach).to eq('healthy')
    expect(test_task_set.lettuce).to eq('dull')
  end

  it 'defaults the parameters to the provided defaults when not specified' do
    class TestTaskSet2786 < RakeFactory::TaskSet
      parameter :spinach, default: 'green'
      parameter :lettuce, default: 'crisp'
    end

    test_task_set = TestTaskSet2786.define

    expect(test_task_set.spinach).to eq('green')
    expect(test_task_set.lettuce).to eq('crisp')
  end

  it 'ignores unknown parameters passed to define' do
    class TestTaskSet3cef < RakeFactory::TaskSet
      parameter :spinach
      parameter :lettuce
    end

    test_task_set = TestTaskSet3cef.define(cabbage: 'yummy', lettuce: 'crisp')

    expect(test_task_set).not_to(respond_to(:cabbage))
    expect(test_task_set.spinach).to(eq(nil))
    expect(test_task_set.lettuce).to(eq('crisp'))
  end

  it 'allows parameters to be passed to define as lambdas accepting the task' do
    class TestTaskSetA777 < RakeFactory::TaskSet
      parameter :thing, default: "some thing"

      parameter :spinach
      parameter :lettuce
    end

    test_task_set = TestTaskSetA777.define(
        spinach: lambda { "Some lazy spinach value." },
        lettuce: lambda { |t| "Lettuce for #{t.thing}." })

    expect(test_task_set.spinach).to(eq("Some lazy spinach value."))
    expect(test_task_set.lettuce).to(eq("Lettuce for some thing."))
  end

  it 'allows the provided block to configure the task on execution' do
    class TestTaskSetDe23 < RakeFactory::TaskSet
      parameter :spinach
      parameter :lettuce
    end

    test_task = TestTaskSetDe23.define do |t|
      t.spinach = 'healthy'
      t.lettuce = 'green'
    end

    expect(test_task.spinach).to eq('healthy')
    expect(test_task.lettuce).to eq('green')
  end

  it 'allows parameters to be set as lambdas accepting the task and ' +
      'arguments in the configuration block' do
    class TestTaskSet690c < RakeFactory::TaskSet
      parameter :cabbage, default: "whatever"
      parameter :spinach
      parameter :lettuce
    end

    test_task = TestTaskSet690c.define do |c|
      c.spinach = lambda { "Some lazy spinach value." }
      c.lettuce = lambda { |t| "Lettuce for #{t.cabbage}." }
    end

    expect(test_task.spinach).to(eq("Some lazy spinach value."))
    expect(test_task.lettuce).to(eq("Lettuce for whatever."))
  end

  it 'defines task specified by classname' do
    class TestTaskFb8c < RakeFactory::Task

    end

    class TestTaskSet09b7 < RakeFactory::TaskSet
      task TestTaskFb8c
    end

    TestTaskSet09b7.define

    expect(Rake::Task.task_defined?("test_task_fb8c")).to(be(true))
  end

  it 'passes arguments through to the task at definition time' do
    class TestTask56bd < RakeFactory::Task
      parameter :thing1
      parameter :thing2
    end

    class TestTaskSet9121 < RakeFactory::TaskSet
      task TestTask56bd, thing1: "yay", thing2: "woohoo"
    end

    TestTaskSet9121.define
    rake_task = Rake::Task["test_task56bd"]
    test_task = rake_task.creator

    expect(test_task.thing1).to(eq("yay"))
    expect(test_task.thing2).to(eq("woohoo"))
  end

  it 'passes parameters defined on the task set to the task at definition ' +
      'time' do
    class TestTaskDeec < RakeFactory::Task
      parameter :thing1
    end

    class TestTaskSet38ae < RakeFactory::TaskSet
      parameter :thing1
      parameter :thing2

      task TestTaskDeec
    end

    TestTaskSet38ae.define(thing1: "yay")
    rake_task = Rake::Task["test_task_deec"]
    test_task = rake_task.creator

    expect(test_task.thing1).to(eq("yay"))
  end

  it 'passes provided configuration block to task on definition' do
    class TestTask522f < RakeFactory::Task
      parameter :thing1
    end

    class TestTaskSet2445 < RakeFactory::TaskSet
      task TestTask522f do |t|
        t.thing1 = 'yippee'
      end
    end

    TestTaskSet2445.define
    rake_task = Rake::Task["test_task522f"]
    test_task = rake_task.creator

    rake_task.invoke

    expect(test_task.thing1).to(eq('yippee'))
  end

  it 'passes arguments to configuration block when task executes' do
    class TestTask86d2 < RakeFactory::Task
      parameter :argument_names, default: [:arg]
      parameter :thing
    end

    class TestTaskSet000c < RakeFactory::TaskSet
      task TestTask86d2 do |t, args|
        t.thing = "thing-#{args.arg}"
      end
    end

    TestTaskSet000c.define
    rake_task = Rake::Task["test_task86d2"]
    test_task = rake_task.creator

    rake_task.invoke('wat')

    expect(test_task.thing).to(eq('thing-wat'))
  end

  it 'allows task name to be configured based on parameter of task set' do
    class TestTask28d8 < RakeFactory::Task
    end

    class TestTaskSet6468 < RakeFactory::TaskSet
      parameter :test_task_name

      task TestTask28d8, name_parameter: :test_task_name
    end

    TestTaskSet6468.define(test_task_name: 'some_task_name')

    expect(Rake::Task.task_defined?('some_task_name')).to(be(true))
    expect(Rake::Task.task_defined?('test_task28d8')).to(be(false))
  end
end
