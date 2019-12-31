require 'spec_helper'

describe RakeFactory::Task do
  it 'adds an attribute reader and writer for each parameter specified' do
    class TestTask5ae0 < RakeFactory::Task
      parameter :spinach
      parameter :lettuce
    end

    test_task = TestTask5ae0.define
    test_task.spinach = 'healthy'
    test_task.lettuce = 'dull'

    expect(test_task.spinach).to eq('healthy')
    expect(test_task.lettuce).to eq('dull')
  end

  it 'defaults the parameters to the provided defaults when not specified' do
    class TestTask2fbb < RakeFactory::Task
      parameter :spinach, default: 'green'
      parameter :lettuce, default: 'crisp'
    end

    test_task = TestTask2fbb.define

    expect(test_task.spinach).to eq('green')
    expect(test_task.lettuce).to eq('crisp')
  end

  it 'throws RequiredParameterUnset exception on execution if required ' +
      'parameters are nil' do
    class TestTaskEcf2 < RakeFactory::Task
      parameter :spinach, required: true
      parameter :lettuce, required: true
    end

    test_task = TestTaskEcf2.define

    expect {
      Rake::Task[test_task.name].invoke
    }.to raise_error { |error|
      expect(error).to be_a(RakeFactory::RequiredParameterUnset)
      expect(error.message).to match('spinach')
      expect(error.message).to match('lettuce')
    }
  end

  it 'allows the provided block to configure the task on execution' do
    class TestTaskE083 < RakeFactory::Task
      parameter :spinach
      parameter :lettuce
    end

    test_task = TestTaskE083.define do |t|
      t.spinach = 'healthy'
      t.lettuce = 'green'
    end

    Rake::Task[test_task.name].invoke

    expect(test_task.spinach).to eq('healthy')
    expect(test_task.lettuce).to eq('green')
  end

  it 'uses the name of the class as task name by default' do
    class TestTask0e90 < RakeFactory::Task
    end

    TestTask0e90.define

    expect(Rake::Task.task_defined?(:test_task0e90)).to(be(true))
  end

  it 'uses the specified default name when provided' do
    class TestTaskB781 < RakeFactory::Task
      default_name :some_default_name
    end

    TestTaskB781.define

    expect(Rake::Task.task_defined?(:some_default_name)).to(be(true))
  end

  it 'uses the name passed in the options argument when supplied' do
    class TestTask46c8 < RakeFactory::Task
    end

    TestTask46c8.define(name: :some_name)

    expect(Rake::Task.task_defined?(:some_name)).to(be(true))
  end

  it 'overrides specified default name when name passed in the options ' +
      'argument' do
    class TestTask502f < RakeFactory::Task
      default_name :some_default_name
    end

    TestTask502f.define(name: :some_specific_name)

    expect(Rake::Task.task_defined?(:some_specific_name)).to(be(true))
  end

  it 'has no argument names by default' do
    class TestTaskFb8b < RakeFactory::Task
    end

    test_task = TestTaskFb8b.define
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.arg_names).to(eq([]))
  end

  it 'uses the specified argument names when provided' do
    class TestTaskAa81 < RakeFactory::Task
      default_argument_names [:first, :second]
    end

    test_task = TestTaskAa81.define
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.arg_names).to(eq([:first, :second]))
  end

  it 'uses the argument names passed in the options argument when supplied' do
    class TestTask10d6 < RakeFactory::Task
    end

    test_task = TestTask10d6.define(
        argument_names: [:first_argument, :second_argument])
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.arg_names)
        .to(eq([:first_argument, :second_argument]))
  end

  it 'overrides specified default argument names when argument names passed ' +
      'in the options argument' do
    class TestTask502f < RakeFactory::Task
      default_argument_names [:first, :second]
    end

    test_task = TestTask502f.define(
        argument_names: [:third, :fourth])
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.arg_names)
        .to(eq([:third, :fourth]))
  end

  it 'has no prerequisites by default' do
    class TestTask72c1 < RakeFactory::Task
    end

    test_task = TestTask72c1.define
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.prerequisites).to(eq([]))
  end

  it 'uses the specified prerequisites when provided' do
    class TestTaskAa81 < RakeFactory::Task
      default_prerequisites ["some:first", "some:second"]
    end

    test_task = TestTaskAa81.define
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.prerequisites).to(eq(["some:first", "some:second"]))
  end

  it 'uses the prerequisites passed in the options argument when supplied' do
    class TestTask9f61 < RakeFactory::Task
    end

    test_task = TestTask9f61.define(
        prerequisites: ["some:first", "some:second"])
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.prerequisites)
        .to(eq(["some:first", "some:second"]))
  end

  it 'overrides specified prerequisites when prerequisites passed in the ' +
      'options argument' do
    class TestTaskCf83 < RakeFactory::Task
      default_prerequisites ["some:first", "some:second"]
    end

    test_task = TestTaskCf83.define(
        prerequisites: ["some:third", "some:fourth"])
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.prerequisites)
        .to(eq(["some:third", "some:fourth"]))
  end

  it 'has no order only prerequisites by default' do
    class TestTaskB368 < RakeFactory::Task
    end

    test_task = TestTaskB368.define
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.order_only_prerequisites).to(eq([]))
  end

  it 'uses the specified order only prerequisites when provided' do
    class TestTask4ba6 < RakeFactory::Task
      default_order_only_prerequisites ["some:first", "some:second"]
    end

    test_task = TestTask4ba6.define
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.order_only_prerequisites)
        .to(eq(["some:first", "some:second"]))
  end

  it 'uses the order only prerequisites passed in the options argument ' +
      'when supplied' do
    class TestTaskA8d1 < RakeFactory::Task
    end

    test_task = TestTaskA8d1.define(
        order_only_prerequisites: ["some:first", "some:second"])
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.order_only_prerequisites)
        .to(eq(["some:first", "some:second"]))
  end

  it 'overrides specified order only prerequisites when order only ' +
      'prerequisites passed in the options argument' do
    class TestTaskE4d6 < RakeFactory::Task
      default_order_only_prerequisites ["some:first", "some:second"]
    end

    test_task = TestTaskE4d6.define(
        order_only_prerequisites: ["some:third", "some:fourth"])
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.order_only_prerequisites)
        .to(eq(["some:third", "some:fourth"]))
  end

  it 'allows actions to be defined on the task' do
    action_arguments = {}

    task_klass = Class.new(RakeFactory::Task) do
      default_argument_names [:first, :second]

      action { action_arguments[:first] = [] }
      action { |t| action_arguments[:second] = [t] }
      action { |t, args| action_arguments[:third] = [t, args] }
    end

    test_task = task_klass.define(name: :test_task)
    rake_task = Rake::Task[test_task.name]

    rake_task.invoke("1", "2")

    expect(action_arguments[:first]).to(eq([]))
    expect(action_arguments[:second]).to(eq([test_task]))
    expect(action_arguments[:third])
        .to(match([test_task, hash_including(first: "1", second: "2")]))
  end
end
