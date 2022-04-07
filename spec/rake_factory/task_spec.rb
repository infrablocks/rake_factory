# frozen_string_literal: true

require 'spec_helper'

describe RakeFactory::Task do
  include_context 'rake'

  # rubocop:disable RSpec/MultipleExpectations
  it 'adds an attribute reader and writer for each parameter specified' do
    test_task_klass = Class.new(described_class) do
      parameter :spinach
      parameter :lettuce
    end

    test_task = test_task_klass.define(name: :some_task_name)
    test_task.spinach = 'healthy'
    test_task.lettuce = 'dull'

    expect(test_task.spinach).to eq('healthy')
    expect(test_task.lettuce).to eq('dull')
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  it 'defaults the parameters to the provided defaults when not specified' do
    test_task_klass = Class.new(described_class) do
      parameter :spinach, default: 'green'
      parameter :lettuce, default: false
    end

    test_task = test_task_klass.define(name: :some_task_name)

    expect(test_task.spinach).to eq('green')
    expect(test_task.lettuce).to be(false)
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  it 'throws RequiredParameterUnset exception on execution if required ' \
     'parameters are nil' do
    test_task_klass = Class.new(described_class) do
      parameter :spinach, required: true
      parameter :lettuce, required: true
    end

    test_task = test_task_klass.define(name: :some_task_name)

    expect do
      Rake::Task[test_task.name].invoke
    end.to(raise_error do |error|
      expect(error).to be_a(RakeFactory::RequiredParameterUnset)
      expect(error.message).to match('spinach')
      expect(error.message).to match('lettuce')
    end)
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  it 'sets parameters when passed to define' do
    test_task_klass = Class.new(described_class) do
      parameter :spinach
      parameter :lettuce
    end

    test_task = test_task_klass.define(
      name: :some_task_name,
      spinach: 'green',
      lettuce: 'crisp'
    )

    expect(test_task.spinach).to(eq('green'))
    expect(test_task.lettuce).to(eq('crisp'))
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  it 'ignores unknown parameters passed to define' do
    test_task_klass = Class.new(described_class) do
      parameter :spinach
      parameter :lettuce
    end

    test_task = test_task_klass.define(
      name: :some_task_name,
      cabbage: 'yummy',
      lettuce: 'crisp'
    )

    expect(test_task).not_to(respond_to(:cabbage))
    expect(test_task.spinach).to(be_nil)
    expect(test_task.lettuce).to(eq('crisp'))
  end
  # rubocop:enable RSpec/MultipleExpectations

  it 'overwrites default values when nil parameter passed to define' do
    test_task_klass = Class.new(described_class) do
      parameter :spinach, default: :kale
    end

    test_task = test_task_klass.define(
      name: :some_task_name,
      spinach: nil
    )

    expect(test_task.spinach).to(be_nil)
  end

  it 'retains parameter values passed to define as lambdas' do
    test_task_klass = Class.new(described_class) do
      parameter :call_me_maybe
    end

    test_task = test_task_klass.define(
      name: :some_task_name,
      call_me_maybe: ->(thing1, thing2) { thing1 * thing2 }
    )

    expect(test_task.call_me_maybe.call(3, 5)).to(eq(15))
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'allows parameter values passed to define to be dynamic, optionally ' \
     'receiving the task' do
    test_task_klass = Class.new(described_class) do
      default_name :some_task_name

      parameter :spinach
      parameter :lettuce
    end

    test_task = test_task_klass.define(
      spinach: dynamic { 'Some lazy spinach value.' },
      lettuce: dynamic { |t| "Lettuce for #{t.name}." }
    )

    expect(test_task.spinach).to(eq('Some lazy spinach value.'))
    expect(test_task.lettuce).to(eq('Lettuce for some_task_name.'))
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  it 'allows the provided block to configure the task on invocation' do
    test_task_klass = Class.new(described_class) do
      parameter :spinach
      parameter :lettuce
    end

    test_task = test_task_klass.define(name: :some_task_name) do |t|
      t.spinach = 'healthy'
      t.lettuce = 'green'
    end

    Rake::Task[test_task.name].invoke

    expect(test_task.spinach).to eq('healthy')
    expect(test_task.lettuce).to eq('green')
  end
  # rubocop:enable RSpec/MultipleExpectations

  it 'retains parameter values passed in configuration block as lambdas' do
    test_task_klass = Class.new(described_class) do
      parameter :call_me_maybe
    end

    test_task = test_task_klass.define(name: :some_task_name) do |t|
      t.call_me_maybe = ->(thing1, thing2) { thing1 * thing2 }
    end

    test_task.invoke

    expect(test_task.call_me_maybe.call(3, 5)).to(eq(15))
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'allows parameter values passed in configuration block to be dynamic, ' \
     'optionally receiving the task and runtime arguments' do
    test_task_klass = Class.new(described_class) do
      default_name :some_task_name

      parameter :spinach
      parameter :lettuce
      parameter :cabbage
    end

    test_task = test_task_klass.define(argument_names: [:a]) do |to|
      to.spinach = dynamic { 'Some lazy spinach value.' }
      to.lettuce = dynamic { |ti| "Lettuce for #{ti.name}." }
      to.cabbage = dynamic do |ti, args|
        "Cabbage for #{ti.name}:#{args.a}."
      end
    end

    Rake::Task[test_task.name].invoke('thing')

    expect(test_task.spinach).to(eq('Some lazy spinach value.'))
    expect(test_task.lettuce).to(eq('Lettuce for some_task_name.'))
    expect(test_task.cabbage).to(eq('Cabbage for some_task_name:thing.'))
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  it 'passes provided arguments to configuration block when requested' do
    test_task_klass = Class.new(described_class) do
      parameter :spinach
      parameter :lettuce
    end

    test_task = test_task_klass
                .define(name: :some_task_name,
                        argument_names: %i[a b]) do |t, args|
      t.spinach = "healthy-#{args.a}"
      t.lettuce = "green-#{args.b}"
    end

    Rake::Task[test_task.name].invoke('colour', 'fresh')

    expect(test_task.spinach).to eq('healthy-colour')
    expect(test_task.lettuce).to eq('green-fresh')
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable Lint/ConstantDefinitionInBlock
  # rubocop:disable RSpec/LeakyConstantDeclaration
  it 'uses the name of the class as task name by default' do
    class ClassNameTestTask < RakeFactory::Task
    end

    ClassNameTestTask.define

    expect(Rake.application)
      .to(have_task_defined('class_name_test_task'))
  end
  # rubocop:enable RSpec/LeakyConstantDeclaration
  # rubocop:enable Lint/ConstantDefinitionInBlock

  it 'uses the specified default name when provided' do
    test_task_klass = Class.new(described_class) do
      default_name :some_default_name
    end

    test_task_klass.define

    expect(Rake.application)
      .to(have_task_defined('some_default_name'))
  end

  it 'uses the name passed in the options argument when supplied' do
    test_task_klass = Class.new(described_class)

    test_task_klass.define(name: :some_specific_name)

    expect(Rake.application)
      .to(have_task_defined('some_specific_name'))
  end

  it 'overrides specified default name when name passed in the options ' \
     'argument' do
    test_task_klass = Class.new(described_class) do
      default_name :some_default_name
    end

    test_task_klass.define(name: :some_specific_name)

    expect(Rake.application)
      .to(have_task_defined('some_specific_name'))
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'does not allow the name to be configured in the configuration block' do
    test_task_klass = Class.new(described_class) do
      default_name :some_default_name
    end

    test_task = test_task_klass.define do |t|
      t.name = :some_specific_name
    end

    expect do
      Rake::Task[test_task.name].invoke
    end.to(raise_error do |error|
      expect(error).to be_a(NoMethodError)
      expect(error.message).to match('name')
    end)
  end
  # rubocop:enable RSpec/MultipleExpectations

  it 'allows the name to be read in the configuration block' do
    test_task_klass = Class.new(described_class) do
      default_name :some_default_name

      parameter :some_parameter
    end

    test_task = test_task_klass.define(name: :some_specific_name) do |t|
      t.some_parameter = "#{t.name}_parameter"
    end
    rake_task = Rake::Task[test_task.name]
    rake_task.invoke

    expect(test_task.some_parameter)
      .to(eq('some_specific_name_parameter'))
  end

  it 'has no argument names by default' do
    test_task_klass = Class.new(described_class)

    test_task = test_task_klass.define(name: :some_task_name)
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.arg_names).to(eq([]))
  end

  it 'uses the specified argument names when provided' do
    test_task_klass = Class.new(described_class) do
      default_argument_names %i[first second]
    end

    test_task = test_task_klass.define(name: :some_task_name)
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.arg_names).to(eq(%i[first second]))
  end

  it 'uses the argument names passed in the options argument when supplied' do
    test_task_klass = Class.new(described_class)

    test_task = test_task_klass.define(
      name: :some_task_name,
      argument_names: %i[first_argument second_argument]
    )
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.arg_names)
      .to(eq(%i[first_argument second_argument]))
  end

  it 'overrides specified default argument names when argument names passed ' \
     'in the options argument' do
    test_task_klass = Class.new(described_class) do
      default_argument_names %i[first second]
    end

    test_task = test_task_klass.define(
      argument_names: %i[third fourth]
    )
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.arg_names)
      .to(eq(%i[third fourth]))
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'does not allow the argument names to be configured in the ' \
     'configuration block' do
    test_task_klass = Class.new(described_class)

    test_task = test_task_klass.define(name: :some_task_name) do |t|
      t.argument_names = %i[first second]
    end

    expect do
      Rake::Task[test_task.name].invoke
    end.to(raise_error do |error|
      expect(error).to be_a(NoMethodError)
      expect(error.message).to match('argument_names=')
    end)
  end
  # rubocop:enable RSpec/MultipleExpectations

  it 'allows the argument names to be read in the configuration block' do
    test_task_klass = Class.new(described_class) do
      default_argument_names %i[first second]

      parameter :some_parameter
    end

    test_task = test_task_klass.define(
      name: :some_task_name,
      argument_names: %i[third fourth]
    ) do |t|
      t.some_parameter = t.argument_names.concat(%i[fifth sixth])
    end
    rake_task = Rake::Task[test_task.name]
    rake_task.invoke

    expect(test_task.some_parameter)
      .to(eq(%i[third fourth fifth sixth]))
  end

  it 'has no prerequisites by default' do
    test_task_klass = Class.new(described_class)

    test_task = test_task_klass.define(name: :some_task_name)
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.prerequisites).to(eq([]))
  end

  it 'uses the specified prerequisites when provided' do
    test_task_klass = Class.new(described_class) do
      default_prerequisites %w[some:first some:second]
    end

    test_task = test_task_klass.define(name: :some_task_name)
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.prerequisites).to(eq(%w[some:first some:second]))
  end

  it 'uses the prerequisites passed in the options argument when supplied' do
    test_task_klass = Class.new(described_class)

    test_task = test_task_klass.define(
      name: :some_task_name,
      prerequisites: %w[some:first some:second]
    )
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.prerequisites)
      .to(eq(%w[some:first some:second]))
  end

  it 'overrides specified prerequisites when prerequisites passed in the ' \
     'options argument' do
    test_task_klass = Class.new(described_class) do
      default_prerequisites %w[some:first some:second]
    end

    test_task = test_task_klass.define(
      name: :some_task_name,
      prerequisites: %w[some:third some:fourth]
    )
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.prerequisites)
      .to(eq(%w[some:third some:fourth]))
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'does not allow the prerequisites to be configured in the ' \
     'configuration block' do
    test_task_klass = Class.new(described_class)

    test_task = test_task_klass.define do |t|
      t.prerequisites = %w[some:first some:second]
    end

    expect do
      Rake::Task[test_task.name].invoke
    end.to(raise_error do |error|
      expect(error).to be_a(NoMethodError)
      expect(error.message).to match('prerequisites=')
    end)
  end
  # rubocop:enable RSpec/MultipleExpectations

  it 'allows the prerequisites to be read in the configuration block' do
    namespace :some do
      task :third
      task :fourth
    end

    test_task_klass = Class.new(described_class) do
      default_prerequisites %w[some:first some:second]

      parameter :some_parameter
    end

    test_task = test_task_klass.define(
      name: :some_task_name,
      prerequisites: %w[some:third some:fourth]
    ) do |t|
      t.some_parameter = t.prerequisites.concat(%w[some:fifth some:sixth])
    end
    rake_task = Rake::Task[test_task.name]
    rake_task.invoke

    expect(test_task.some_parameter)
      .to(eq(%w[some:third some:fourth some:fifth some:sixth]))
  end

  it 'has no order only prerequisites by default' do
    test_task_klass = Class.new(described_class)

    test_task = test_task_klass.define
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.order_only_prerequisites).to(eq([]))
  end

  it 'uses the specified order only prerequisites when provided' do
    test_task_klass = Class.new(described_class) do
      default_order_only_prerequisites %w[some:first some:second]
    end

    test_task = test_task_klass.define(name: :some_task_name)
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.order_only_prerequisites)
      .to(eq(%w[some:first some:second]))
  end

  it 'uses the order only prerequisites passed in the options argument ' \
     'when supplied' do
    test_task_klass = Class.new(described_class)

    test_task = test_task_klass.define(
      name: :some_task_name,
      order_only_prerequisites: %w[some:first some:second]
    )
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.order_only_prerequisites)
      .to(eq(%w[some:first some:second]))
  end

  it 'overrides specified order only prerequisites when order only ' \
     'prerequisites passed in the options argument' do
    test_task_klass = Class.new(described_class) do
      default_order_only_prerequisites %w[some:first some:second]
    end

    test_task = test_task_klass.define(
      name: :some_task_name,
      order_only_prerequisites: %w[some:third some:fourth]
    )
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.order_only_prerequisites)
      .to(eq(%w[some:third some:fourth]))
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'does not allow the order only prerequisites to be configured in the ' \
     'configuration block' do
    test_task_klass = Class.new(described_class)

    test_task = test_task_klass.define(name: :some_task_name) do |t|
      t.order_only_prerequisites = %w[some:first some:second]
    end

    expect do
      Rake::Task[test_task.name].invoke
    end.to(raise_error do |error|
      expect(error).to be_a(NoMethodError)
      expect(error.message).to match('order_only_prerequisites=')
    end)
  end
  # rubocop:enable RSpec/MultipleExpectations

  it 'allows the order only prerequisites to be read in the configuration ' \
     'block' do
    namespace :some do
      task :third
      task :fourth
    end

    test_task_klass = Class.new(described_class) do
      default_order_only_prerequisites %w[some:first some:second]

      parameter :some_parameter
    end

    test_task = test_task_klass.define(
      name: :some_task_name,
      order_only_prerequisites: %w[some:third some:fourth]
    ) do |t|
      t.some_parameter =
        t.order_only_prerequisites.concat(%w[some:fifth some:sixth])
    end
    rake_task = Rake::Task[test_task.name]
    rake_task.invoke

    expect(test_task.some_parameter)
      .to(eq(%w[some:third some:fourth some:fifth some:sixth]))
  end

  it 'does not set a description on the task by default' do
    test_task_klass = Class.new(described_class)

    test_task = test_task_klass.define
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.comment).to(be_nil)
  end

  it 'uses the specified default description when provided' do
    test_task_klass = Class.new(described_class) do
      default_description 'Some task that does some thing.'
    end

    test_task = test_task_klass.define(name: :some_task_name)
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.full_comment)
      .to(eq('Some task that does some thing.'))
  end

  it 'uses the description passed in the options argument when supplied' do
    test_task_klass = Class.new(described_class)

    test_task = test_task_klass.define(
      name: :some_task_name,
      description: 'Some task that does a specific thing.'
    )
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.full_comment)
      .to(eq('Some task that does a specific thing.'))
  end

  it 'overrides specified default description when name passed in the '\
     'options argument' do
    test_task_klass = Class.new(described_class) do
      default_description 'Some task that does some thing.'
    end

    test_task = test_task_klass.define(
      name: :some_task_name,
      description: 'Some task that does a specific thing.'
    )
    rake_task = Rake::Task[test_task.name]

    expect(rake_task.full_comment)
      .to(eq('Some task that does a specific thing.'))
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'does not allow the description to be configured in the ' \
     'configuration block' do
    test_task_klass = Class.new(described_class)

    test_task = test_task_klass.define(name: :some_task_name) do |t|
      t.description = 'Some task description.'
    end

    expect do
      Rake::Task[test_task.name].invoke
    end.to(raise_error do |error|
      expect(error).to be_a(NoMethodError)
      expect(error.message).to match('description=')
    end)
  end
  # rubocop:enable RSpec/MultipleExpectations

  it 'allows the description to be read in the configuration ' \
     'block' do
    test_task_klass = Class.new(described_class) do
      default_description 'Some default description'

      parameter :some_parameter
    end

    test_task = test_task_klass.define(
      name: :some_task_name,
      description: 'Some specific description'
    ) do |t|
      t.some_parameter = "Parameter for: #{t.description}"
    end
    rake_task = Rake::Task[test_task.name]
    rake_task.invoke

    expect(test_task.some_parameter)
      .to(eq('Parameter for: Some specific description'))
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'allows actions to be defined on the task' do
    action_arguments = {}

    task_klass = Class.new(described_class) do
      default_argument_names %i[first second]

      action { action_arguments[:first] = [] }
      action { |t| action_arguments[:second] = [t] }
      action { |t, args| action_arguments[:third] = [t, args] }
    end

    test_task = task_klass.define(name: :test_task)
    rake_task = Rake::Task[test_task.name]

    rake_task.invoke('1', '2')

    expect(action_arguments[:first]).to(eq([]))
    expect(action_arguments[:second]).to(eq([test_task]))
    expect(action_arguments[:third])
      .to(match([test_task, hash_including(first: '1', second: '2')]))
  end
  # rubocop:enable RSpec/MultipleExpectations

  it 'exposes FileUtils methods to actions' do
    task_klass = Class.new(described_class) do
      action do
        mkdir_p 'example/path'
      end
    end

    test_task = task_klass.define(name: :test_task)
    rake_task = Rake::Task[test_task.name]

    allow(test_task).to(receive(:mkdir_p))

    rake_task.invoke

    expect(test_task)
      .to(have_received(:mkdir_p)
            .with('example/path'))
  end

  it 'exposes the scope on the task argument to actions' do
    scope = nil

    task_klass = Class.new(described_class) do
      action { |t| scope = t.scope }
    end

    namespace :test do
      namespace :ns do
        task_klass.define(name: :test_task)
      end
    end

    rake_task = Rake::Task['test:ns:test_task']
    rake_task.invoke

    expect(scope)
      .to(eq(
            Rake::Scope.new('ns',
                            Rake::Scope.new('test',
                                            Rake::Scope::EMPTY))
          ))
  end
end
