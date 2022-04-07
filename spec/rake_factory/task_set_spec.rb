# frozen_string_literal: true

require 'spec_helper'

describe RakeFactory::TaskSet do
  include_context 'rake'

  # rubocop:disable RSpec/MultipleExpectations
  it 'adds an attribute reader and writer for each parameter specified' do
    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      parameter :spinach
      parameter :lettuce
    end

    test_task_set = test_task_set_klass.define
    test_task_set.spinach = 'healthy'
    test_task_set.lettuce = 'dull'

    expect(test_task_set.spinach).to eq('healthy')
    expect(test_task_set.lettuce).to eq('dull')
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  it 'defaults the parameters to the provided defaults when not specified' do
    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      parameter :spinach, default: 'green'
      parameter :lettuce, default: 'crisp'
    end

    test_task_set = test_task_set_klass.define

    expect(test_task_set.spinach).to eq('green')
    expect(test_task_set.lettuce).to eq('crisp')
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  it 'ignores unknown parameters passed to define' do
    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      parameter :spinach
      parameter :lettuce
    end

    test_task_set = test_task_set_klass.define(
      cabbage: 'yummy',
      lettuce: 'crisp'
    )

    expect(test_task_set).not_to(respond_to(:cabbage))
    expect(test_task_set.spinach).to(be_nil)
    expect(test_task_set.lettuce).to(eq('crisp'))
  end
  # rubocop:enable RSpec/MultipleExpectations

  it 'overwrites default values when nil parameter passed to define' do
    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      parameter :spinach, default: :kale
    end

    test_task_set = test_task_set_klass.define(spinach: nil)

    expect(test_task_set.spinach).to(be_nil)
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'allows parameter values passed to define to be dynamic, optionally ' \
     'accepting the task set' do
    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      parameter :thing, default: 'some thing'

      parameter :spinach
      parameter :lettuce
    end

    test_task_set = test_task_set_klass.define(
      spinach: dynamic { 'Some lazy spinach value.' },
      lettuce: dynamic { |ts| "Lettuce for #{ts.thing}." }
    )

    expect(test_task_set.spinach).to(eq('Some lazy spinach value.'))
    expect(test_task_set.lettuce).to(eq('Lettuce for some thing.'))
  end
  # rubocop:enable RSpec/MultipleExpectations

  it 'defines task specified by classname' do
    test_task_klass = Class.new(RakeFactory::Task) do
      default_name :some_task_name
    end

    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      task test_task_klass
    end

    test_task_set_klass.define

    expect(Rake.application)
      .to(have_task_defined('some_task_name'))
  end

  it 'defines task in specified namespace when provided' do
    test_task_klass = Class.new(RakeFactory::Task) do
      default_name :some_task_name
    end

    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      prepend RakeFactory::Namespaceable

      task test_task_klass
    end

    test_task_set_klass.define(namespace: :some_namespace)

    expect(Rake.application)
      .to(have_task_defined('some_namespace:some_task_name'))
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'passes arguments through to the task at definition time' do
    test_task_klass = Class.new(RakeFactory::Task) do
      default_name :some_task_name

      parameter :thing1
      parameter :thing2
    end

    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      task test_task_klass, thing1: 'yay', thing2: 'woohoo'
    end

    test_task_set_klass.define

    rake_task = Rake::Task['some_task_name']
    test_task = rake_task.creator

    expect(test_task.thing1).to(eq('yay'))
    expect(test_task.thing2).to(eq('woohoo'))
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  it 'allows parameter values passed to task spec to be dynamic, optionally ' \
     'accepting the task set' do
    test_task_klass = Class.new(RakeFactory::Task) do
      default_name :some_task_name
      parameter :thing1
      parameter :thing2
    end

    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      parameter :other_thing

      task test_task_klass,
           thing1: dynamic { |ts| "yay-#{ts.other_thing}" },
           thing2: dynamic { |ts| "woohoo-#{ts.other_thing}" }
    end

    test_task_set_klass.define(other_thing: 'yippee')
    rake_task = Rake::Task['some_task_name']
    test_task = rake_task.creator

    expect(test_task.thing1).to(eq('yay-yippee'))
    expect(test_task.thing2).to(eq('woohoo-yippee'))
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  it 'prefers task spec parameter values over task set parameter values' do
    test_task_klass = Class.new(RakeFactory::Task) do
      default_name :some_task_name

      parameter :thing1
      parameter :thing2
    end

    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      parameter :thing1, default: 'goodo'
      parameter :thing2, default: 'yip'

      task test_task_klass,
           thing1: dynamic { |ts|
             "yay-#{ts.thing1}"
           },
           thing2: dynamic { |ts|
             "woohoo-#{ts.thing2}"
           }
    end

    test_task_set_klass.define
    rake_task = Rake::Task['some_task_name']
    test_task = rake_task.creator

    expect(test_task.thing1).to(eq('yay-goodo'))
    expect(test_task.thing2).to(eq('woohoo-yip'))
  end
  # rubocop:enable RSpec/MultipleExpectations

  it 'passes parameters defined on the task set to the task at definition ' \
     'time' do
    test_task_klass = Class.new(RakeFactory::Task) do
      default_name :some_task_name

      parameter :thing1
    end

    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      parameter :thing1
      parameter :thing2

      task test_task_klass
    end

    test_task_set_klass.define(thing1: 'yay')
    rake_task = Rake::Task['some_task_name']
    test_task = rake_task.creator

    expect(test_task.thing1).to(eq('yay'))
  end

  it 'calls configuration block passed to task set on task at invocation ' \
     'time' do
    test_task_klass = Class.new(RakeFactory::Task) do
      default_name :some_task_name

      parameter :lettuce
    end

    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      parameter :spinach
      parameter :lettuce

      task test_task_klass
    end

    test_task_set_klass.define do |t|
      t.spinach = 'healthy'
      t.lettuce = 'green'
    end

    rake_task = Rake::Task['some_task_name']
    test_task = rake_task.creator

    rake_task.invoke

    expect(test_task.lettuce).to eq('green')
  end

  it 'passes arguments to configuration block passed to task set at ' \
     'task invocation time' do
    test_task_klass = Class.new(RakeFactory::Task) do
      default_name :some_task_name

      parameter :lettuce
    end

    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      parameter :argument_names, default: []

      parameter :spinach
      parameter :lettuce

      task test_task_klass
    end

    test_task_set_klass.define(argument_names: [:thing]) do |t, args|
      t.spinach = "healthy-#{args.thing}"
      t.lettuce = "green-#{args.thing}"
    end

    rake_task = Rake::Task['some_task_name']
    test_task = rake_task.creator

    rake_task.invoke('vegetables')

    expect(test_task.lettuce).to eq('green-vegetables')
  end

  it 'allows parameter values passed in the configuration block to be ' \
     'dynamic, optionally accepting the task' do
    test_task_klass = Class.new(RakeFactory::Task) do
      default_name :some_task_name

      parameter :cabbage, default: 'whatever'
      parameter :lettuce
    end

    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      parameter :spinach
      parameter :lettuce

      task test_task_klass
    end

    test_task_set_klass.define do |t|
      t.spinach = dynamic { 'Some lazy spinach value.' }
      t.lettuce = dynamic { |lazy_t| "Lettuce for #{lazy_t.cabbage}." }
    end

    rake_task = Rake::Task['some_task_name']
    test_task = rake_task.creator

    rake_task.invoke

    expect(test_task.lettuce).to(eq('Lettuce for whatever.'))
  end

  it 'calls configuration block provided to task spec with task set and ' \
     'task at invocation time' do
    test_task_klass = Class.new(RakeFactory::Task) do
      default_name :some_task_name

      parameter :thing1
    end

    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      parameter :thing2

      task test_task_klass do |ts, t|
        t.thing1 = "#{ts.thing2}-yippee"
      end
    end

    test_task_set_klass.define(thing2: 'yay')
    rake_task = Rake::Task['some_task_name']
    test_task = rake_task.creator

    rake_task.invoke

    expect(test_task.thing1).to(eq('yay-yippee'))
  end

  it 'passes arguments to task spec configuration block when task is invoked' do
    test_task_klass = Class.new(RakeFactory::Task) do
      default_name :some_task_name

      parameter :argument_names, default: [:arg]
      parameter :thing
    end

    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      parameter :other_thing

      task test_task_klass do |ts, t, args|
        t.thing = "#{ts.other_thing}-#{args.arg}"
      end
    end

    test_task_set_klass.define(other_thing: 'yay')
    rake_task = Rake::Task['some_task_name']
    test_task = rake_task.creator

    rake_task.invoke('wat')

    expect(test_task.thing).to(eq('yay-wat'))
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'allows task name to be configured based on task set' do
    test_task_klass = Class.new(RakeFactory::Task) do
      default_name :other_task_name
    end

    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      parameter :test_task_name

      task test_task_klass, name: dynamic { |ts| ts.test_task_name }
    end

    test_task_set_klass.define(test_task_name: 'some_task_name')

    expect(Rake::Task.task_defined?('some_task_name')).to(be(true))
    expect(Rake::Task.task_defined?('other_task_name')).to(be(false))
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  it 'uses the provided lambda to determine whether or not to define the ' \
     'task when supplied' do
    test_task_1_klass = Class.new(RakeFactory::Task) do
      default_name :task_1_name
    end
    test_task_2_klass = Class.new(RakeFactory::Task) do
      default_name :task_2_name
    end

    test_task_set_klass = Class.new(RakeFactory::TaskSet) do
      parameter :vegetable

      task test_task_1_klass, define_if: ->(ts) { ts.vegetable == 'turnip' }
      task test_task_2_klass, define_if: ->(ts) { ts.vegetable == 'carrot' }
    end

    test_task_set_klass.define(vegetable: 'carrot')

    expect(Rake.application)
      .not_to(have_task_defined('task_1_name'))
    expect(Rake.application)
      .to(have_task_defined('task_2_name'))
  end
  # rubocop:enable RSpec/MultipleExpectations
end
