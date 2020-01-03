require 'spec_helper'

describe RakeFactory::Task do
  include_context :rake

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

  it 'sets parameters when passed to define' do
    class TestTask6b63 < RakeFactory::Task
      parameter :spinach
      parameter :lettuce
    end

    test_task = TestTask6b63.define(spinach: 'green', lettuce: 'crisp')

    expect(test_task.spinach).to(eq('green'))
    expect(test_task.lettuce).to(eq('crisp'))
  end

  it 'ignores unknown parameters passed to define' do
    class TestTask6b63 < RakeFactory::Task
      parameter :spinach
      parameter :lettuce
    end

    test_task = TestTask6b63.define(cabbage: 'yummy', lettuce: 'crisp')

    expect(test_task).not_to(respond_to(:cabbage))
    expect(test_task.spinach).to(eq(nil))
    expect(test_task.lettuce).to(eq('crisp'))
  end

  it 'allows parameters to be passed to define as lambdas accepting the task' do
    class TestTaskA37c < RakeFactory::Task
      default_name :some_task_name

      parameter :spinach
      parameter :lettuce
    end

    test_task = TestTaskA37c.define(
        spinach: lambda { "Some lazy spinach value." },
        lettuce: lambda { |t| "Lettuce for #{t.name}."})

    expect(test_task.spinach).to(eq("Some lazy spinach value."))
    expect(test_task.lettuce).to(eq("Lettuce for some_task_name."))
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

  it 'allows parameters to be set as lambdas accepting the task and ' +
      'arguments in the configuration block' do
    class TestTaskA37c < RakeFactory::Task
      default_name :some_task_name

      parameter :spinach
      parameter :lettuce
      parameter :cabbage
    end

    test_task = TestTaskA37c.define(argument_names: [:a]) do |c|
        c.spinach = lambda { "Some lazy spinach value." }
        c.lettuce = lambda { |t| "Lettuce for #{t.name}."}
        c.cabbage = lambda { |t, args| "Cabbage for #{t.name}:#{args.a}."}
    end

    Rake::Task[test_task.name].invoke('thing')

    expect(test_task.spinach).to(eq("Some lazy spinach value."))
    expect(test_task.lettuce).to(eq("Lettuce for some_task_name."))
    expect(test_task.cabbage).to(eq("Cabbage for some_task_name:thing."))
  end

  it 'passes provided arguments to configuration block when requested' do
    class TestTaskFb44 < RakeFactory::Task
      parameter :spinach
      parameter :lettuce
    end

    test_task = TestTaskFb44
        .define(argument_names: [:a, :b]) do |t, args|
      t.spinach = "healthy-#{args.a}"
      t.lettuce = "green-#{args.b}"
    end

    Rake::Task[test_task.name].invoke("colour", "fresh")

    expect(test_task.spinach).to eq('healthy-colour')
    expect(test_task.lettuce).to eq('green-fresh')
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

  it 'does not allow the name to be configured in the configuration block' do
    class TestTaskFe1e < RakeFactory::Task
    end

    test_task = TestTaskFe1e.define do |t|
      t.name = :some_name
    end

    expect {
      Rake::Task[test_task.name].invoke
    }.to raise_error { |error|
      expect(error).to be_a(NoMethodError)
      expect(error.message).to match('name')
    }
  end

  it 'allows the name to be read in the configuration block' do
    class TestTask6825 < RakeFactory::Task
      default_name :some_default_name

      parameter :some_parameter
    end

    test_task = TestTask6825.define(name: :some_specific_name) do |t|
      t.some_parameter = "#{t.name}_parameter"
    end
    rake_task = Rake::Task[test_task.name]
    rake_task.invoke

    expect(test_task.some_parameter)
        .to(eq('some_specific_name_parameter'))
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
    class TestTask678d < RakeFactory::Task
      default_argument_names [:first, :second]
    end

    test_task = TestTask678d.define(
        argument_names: [:third, :fourth])
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.arg_names)
        .to(eq([:third, :fourth]))
  end

  it 'does not allow the argument names to be configured in the ' +
      'configuration block' do
    class TestTask6168 < RakeFactory::Task
    end

    test_task = TestTask6168.define do |t|
      t.argument_names = [:first, :second]
    end

    expect {
      Rake::Task[test_task.name].invoke
    }.to raise_error { |error|
      expect(error).to be_a(NoMethodError)
      expect(error.message).to match('argument_names=')
    }
  end

  it 'allows the argument names to be read in the configuration block' do
    class TestTask89c0 < RakeFactory::Task
      default_argument_names [:first, :second]

      parameter :some_parameter
    end

    test_task = TestTask89c0.define(argument_names: [:third, :fourth]) do |t|
      t.some_parameter = t.argument_names.concat([:fifth, :sixth])
    end
    rake_task = Rake::Task[test_task.name]
    rake_task.invoke

    expect(test_task.some_parameter)
        .to(eq([:third, :fourth, :fifth, :sixth]))
  end

  it 'has no prerequisites by default' do
    class TestTask72c1 < RakeFactory::Task
    end

    test_task = TestTask72c1.define
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.prerequisites).to(eq([]))
  end

  it 'uses the specified prerequisites when provided' do
    class TestTask74b7 < RakeFactory::Task
      default_prerequisites ["some:first", "some:second"]
    end

    test_task = TestTask74b7.define
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

  it 'does not allow the prerequisites to be configured in the ' +
      'configuration block' do
    class TestTask78eb < RakeFactory::Task
    end

    test_task = TestTask78eb.define do |t|
      t.prerequisites = ["some:first", "some:second"]
    end

    expect {
      Rake::Task[test_task.name].invoke
    }.to raise_error { |error|
      expect(error).to be_a(NoMethodError)
      expect(error.message).to match('prerequisites=')
    }
  end

  it 'allows the prerequisites to be read in the configuration block' do
    namespace :some do
      task :third
      task :fourth
    end

    class TestTask77fa < RakeFactory::Task
      default_prerequisites ["some:first", "some:second"]

      parameter :some_parameter
    end

    test_task = TestTask77fa.define(
        prerequisites: ["some:third", "some:fourth"]
    ) do |t|
      t.some_parameter = t.prerequisites.concat(["some:fifth", "some:sixth"])
    end
    rake_task = Rake::Task[test_task.name]
    rake_task.invoke

    expect(test_task.some_parameter)
        .to(eq(["some:third", "some:fourth", "some:fifth", "some:sixth"]))
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

  it 'does not allow the order only prerequisites to be configured in the ' +
      'configuration block' do
    class TestTask863f < RakeFactory::Task
    end

    test_task = TestTask863f.define do |t|
      t.order_only_prerequisites = ["some:first", "some:second"]
    end

    expect {
      Rake::Task[test_task.name].invoke
    }.to raise_error { |error|
      expect(error).to be_a(NoMethodError)
      expect(error.message).to match('order_only_prerequisites=')
    }
  end

  it 'allows the order only prerequisites to be read in the configuration ' +
      'block' do
    namespace :some do
      task :third
      task :fourth
    end

    class TestTaskE846 < RakeFactory::Task
      default_order_only_prerequisites ["some:first", "some:second"]

      parameter :some_parameter
    end

    test_task = TestTaskE846.define(
        order_only_prerequisites: ["some:third", "some:fourth"]
    ) do |t|
      t.some_parameter =
          t.order_only_prerequisites.concat(["some:fifth", "some:sixth"])
    end
    rake_task = Rake::Task[test_task.name]
    rake_task.invoke

    expect(test_task.some_parameter)
        .to(eq(["some:third", "some:fourth", "some:fifth", "some:sixth"]))
  end

  it 'does not set a description on the task by default' do
    class TestTask1eb3 < RakeFactory::Task
    end

    test_task = TestTask1eb3.define
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.comment).to(be_nil)
  end

  it 'uses the specified default description when provided' do
    class TestTaskBd2b < RakeFactory::Task
      default_description "Some task that does some thing."
    end

    test_task = TestTaskBd2b.define
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.full_comment).to(eq("Some task that does some thing."))
  end

  it 'uses the description passed in the options argument when supplied' do
    class TestTask9531 < RakeFactory::Task
    end

    test_task = TestTask9531.define(
        description: "Some task that does a specific thing.")
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.full_comment)
        .to(eq("Some task that does a specific thing."))
  end

  it 'overrides specified default name when name passed in the options ' +
      'argument' do
    class TestTaskCa72 < RakeFactory::Task
      default_description "Some task that does some thing."
    end

    test_task = TestTaskCa72.define(
        description: "Some task that does a specific thing.")
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.full_comment)
        .to(eq("Some task that does a specific thing."))
  end

  it 'does not allow the description to be configured in the ' +
      'configuration block' do
    class TestTask0c7b < RakeFactory::Task
    end

    test_task = TestTask0c7b.define do |t|
      t.description = "Some task description."
    end

    expect {
      Rake::Task[test_task.name].invoke
    }.to raise_error { |error|
      expect(error).to be_a(NoMethodError)
      expect(error.message).to match('description=')
    }
  end

  it 'allows the description to be read in the configuration ' +
      'block' do
    class TestTask6452 < RakeFactory::Task
      default_description "Some default description"

      parameter :some_parameter
    end

    test_task = TestTask6452.define(
        description: "Some specific description"
    ) do |t|
      t.some_parameter = "Parameter for: #{t.description}"
    end
    rake_task = Rake::Task[test_task.name]
    rake_task.invoke

    expect(test_task.some_parameter)
        .to(eq("Parameter for: Some specific description"))
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

  it 'exposes FileUtils methods to actions' do
    task_klass = Class.new(RakeFactory::Task) do
      action do
        mkdir_p "example/path"
      end
    end

    test_task = task_klass.define(name: :test_task)
    rake_task = Rake::Task[test_task.name]

    expect(test_task).to(receive(:mkdir_p).with("example/path"))

    rake_task.invoke
  end
end
