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

  it 'overwrites default values when nil parameter passed to define' do
    class TestTaskSetAed5 < RakeFactory::Task
      parameter :spinach, default: :kale
    end

    test_task_set = TestTaskSetAed5.define(spinach: nil)

    expect(test_task_set.spinach).to(eq(nil))
  end

  it 'allows parameter values passed to define to be dynamic, optionally ' +
      'accepting the task set' do
    class TestTaskSetA777 < RakeFactory::TaskSet
      parameter :thing, default: "some thing"

      parameter :spinach
      parameter :lettuce
    end

    test_task_set = TestTaskSetA777.define(
        spinach: dynamic { "Some lazy spinach value." },
        lettuce: dynamic { |ts| "Lettuce for #{ts.thing}." })

    expect(test_task_set.spinach).to(eq("Some lazy spinach value."))
    expect(test_task_set.lettuce).to(eq("Lettuce for some thing."))
  end

  it 'defines task specified by classname' do
    class TestTaskE7f9 < RakeFactory::Task
    end

    class TestTaskSetC384 < RakeFactory::TaskSet
      task TestTaskE7f9
    end

    TestTaskSetC384.define

    expect(Rake::Task.task_defined?("test_task_e7f9")).to(be(true))
  end

  it 'defines task in specified namespace when provided' do
    class TestTaskFb8c < RakeFactory::Task
    end

    class TestTaskSet09b7 < RakeFactory::TaskSet
      prepend RakeFactory::Namespaceable

      task TestTaskFb8c
    end

    TestTaskSet09b7.define(namespace: :some_namespace)

    expect(Rake::Task.task_defined?("some_namespace:test_task_fb8c"))
        .to(be(true))
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

  it 'allows parameter values passed to task spec to be dynamic, optionally ' +
      'accepting the task set' do
    class TestTask12bb < RakeFactory::Task
      parameter :thing1
      parameter :thing2
    end

    class TestTaskSetD053 < RakeFactory::TaskSet
      parameter :other_thing

      task TestTask12bb,
          thing1: dynamic { |ts| "yay-#{ts.other_thing}" },
          thing2: dynamic { |ts| "woohoo-#{ts.other_thing}" }
    end

    TestTaskSetD053.define(other_thing: 'yippee')
    rake_task = Rake::Task["test_task12bb"]
    test_task = rake_task.creator

    expect(test_task.thing1).to(eq("yay-yippee"))
    expect(test_task.thing2).to(eq("woohoo-yippee"))
  end

  it 'prefers task spec parameter values over task set parameter values' do
    class TestTaskFd10 < RakeFactory::Task
      parameter :thing1
      parameter :thing2
    end

    class TestTaskSetCa50 < RakeFactory::TaskSet
      parameter :thing1, default: 'goodo'
      parameter :thing2, default: 'yip'

      task TestTaskFd10,
          thing1: dynamic { |ts|
            "yay-#{ts.thing1}"
          },
          thing2: dynamic { |ts|
            "woohoo-#{ts.thing2}"
          }
    end

    TestTaskSetCa50.define
    rake_task = Rake::Task["test_task_fd10"]
    test_task = rake_task.creator

    expect(test_task.thing1).to(eq("yay-goodo"))
    expect(test_task.thing2).to(eq("woohoo-yip"))
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

  it 'calls configuration block passed to task set on task at invocation ' +
      'time' do
    class TestTaskBe4f < RakeFactory::Task
      parameter :lettuce
    end

    class TestTaskSetDe23 < RakeFactory::TaskSet
      parameter :spinach
      parameter :lettuce

      task TestTaskBe4f
    end

    TestTaskSetDe23.define do |t|
      t.spinach = 'healthy'
      t.lettuce = 'green'
    end

    rake_task = Rake::Task["test_task_be4f"]
    test_task = rake_task.creator

    rake_task.invoke

    expect(test_task.lettuce).to eq('green')
  end

  it 'passes arguments to configuration block passed to task set at ' +
      'task invocation time' do
    class TestTaskFfdd < RakeFactory::Task
      parameter :lettuce
    end

    class TestTaskSet6856 < RakeFactory::TaskSet
      parameter :argument_names, default: []

      parameter :spinach
      parameter :lettuce

      task TestTaskFfdd
    end

    TestTaskSet6856.define(argument_names: [:thing]) do |t, args|
      t.spinach = "healthy-#{args.thing}"
      t.lettuce = "green-#{args.thing}"
    end

    rake_task = Rake::Task["test_task_ffdd"]
    test_task = rake_task.creator

    rake_task.invoke("vegetables")

    expect(test_task.lettuce).to eq('green-vegetables')
  end

  it 'allows parameter values passed in the configuration block to be ' +
      'dynamic, optionally accepting the task' do
    class TestTaskF730 < RakeFactory::Task
      parameter :cabbage, default: "whatever"
      parameter :lettuce
    end

    class TestTaskSet690c < RakeFactory::TaskSet
      parameter :spinach
      parameter :lettuce

      task TestTaskF730
    end

    TestTaskSet690c.define do |t|
      t.spinach = dynamic { "Some lazy spinach value." }
      t.lettuce = dynamic { |lazy_t| "Lettuce for #{lazy_t.cabbage}." }
    end

    rake_task = Rake::Task["test_task_f730"]
    test_task = rake_task.creator

    rake_task.invoke

    expect(test_task.lettuce).to(eq("Lettuce for whatever."))
  end

  it 'calls configuration block provided to task spec with task set and ' +
      'task at invocation time' do
    class TestTask522f < RakeFactory::Task
      parameter :thing1
    end

    class TestTaskSet2445 < RakeFactory::TaskSet
      parameter :thing2

      task TestTask522f do |ts, t|
        t.thing1 = "#{ts.thing2}-yippee"
      end
    end

    TestTaskSet2445.define(thing2: 'yay')
    rake_task = Rake::Task["test_task522f"]
    test_task = rake_task.creator

    rake_task.invoke

    expect(test_task.thing1).to(eq('yay-yippee'))
  end

  it 'passes arguments to task spec configuration block when task is invoked' do
    class TestTask86d2 < RakeFactory::Task
      parameter :argument_names, default: [:arg]
      parameter :thing
    end

    class TestTaskSet000c < RakeFactory::TaskSet
      parameter :other_thing

      task TestTask86d2 do |ts, t, args|
        t.thing = "#{ts.other_thing}-#{args.arg}"
      end
    end

    TestTaskSet000c.define(other_thing: 'yay')
    rake_task = Rake::Task["test_task86d2"]
    test_task = rake_task.creator

    rake_task.invoke('wat')

    expect(test_task.thing).to(eq('yay-wat'))
  end

  it 'allows task name to be configured based on task set' do
    class TestTask28d8 < RakeFactory::Task
    end

    class TestTaskSet6468 < RakeFactory::TaskSet
      parameter :test_task_name

      task TestTask28d8, name: dynamic { |ts| ts.test_task_name }
    end

    TestTaskSet6468.define(test_task_name: 'some_task_name')

    expect(Rake::Task.task_defined?('some_task_name')).to(be(true))
    expect(Rake::Task.task_defined?('test_task28d8')).to(be(false))
  end

  it 'uses the provided lambda to determine whether or not to define the ' +
      'task when supplied' do
    class TestTaskC5e9 < RakeFactory::Task
    end

    class TestTaskD6af < RakeFactory::Task
    end

    class TestTaskSetDf8a < RakeFactory::TaskSet
      parameter :vegetable

      task TestTaskC5e9, define_if: ->(ts) { ts.vegetable == "turnip" }
      task TestTaskD6af, define_if: ->(ts) { ts.vegetable == "carrot" }
    end

    TestTaskSetDf8a.define(vegetable: 'carrot')

    expect(Rake::Task.task_defined?('test_task_c5e9')).to(be(false))
    expect(Rake::Task.task_defined?('test_task_d6af')).to(be(true))
  end
end
