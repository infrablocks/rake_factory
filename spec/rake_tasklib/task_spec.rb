require 'spec_helper'

describe RakeTaskLib::Task do
  it 'adds an attribute reader and writer for each parameter specified' do
    class TestTask5ae0 < RakeTaskLib::Task
      parameter :spinach
      parameter :lettuce
    end

    test_task = TestTask5ae0.new
    test_task.spinach = 'healthy'
    test_task.lettuce = 'dull'

    expect(test_task.spinach).to eq('healthy')
    expect(test_task.lettuce).to eq('dull')
  end

  it 'defaults the parameters to the provided defaults when not specified' do
    class TestTask2fbb < RakeTaskLib::Task
      parameter :spinach, default: 'green'
      parameter :lettuce, default: 'crisp'
    end

    test_task = TestTask2fbb.new

    expect(test_task.spinach).to eq('green')
    expect(test_task.lettuce).to eq('crisp')
  end

  it 'throws RequiredParameterUnset exception on initialisation if required ' +
      'parameters are nil' do
    class TestTaskEcf2 < RakeTaskLib::Task
      parameter :spinach, required: true
      parameter :lettuce, required: true
    end

    expect {
      TestTaskEcf2.new
    }.to raise_error { |error|
      expect(error).to be_a(RakeTaskLib::RequiredParameterUnset)
      expect(error.message).to match('spinach')
      expect(error.message).to match('lettuce')
    }
  end

  it 'allows the provided block to configure the task' do
    class TestTaskE083 < RakeTaskLib::Task
      parameter :spinach
      parameter :lettuce
    end

    test_task = TestTaskE083.new do |t|
      t.spinach = 'healthy'
      t.lettuce = 'green'
    end

    expect(test_task.spinach).to eq('healthy')
    expect(test_task.lettuce).to eq('green')
  end

  it 'uses the name of the class as task name by default' do
    class TestTask0e90 < RakeTaskLib::Task
    end

    test_task = TestTask0e90.new

    expect(test_task.name).to(eq(:test_task0e90))
  end

  it 'uses the specified default name when provided' do
    class TestTaskB781 < RakeTaskLib::Task
      default_name :some_default_name
    end

    test_task = TestTaskB781.new

    expect(test_task.name).to(eq(:some_default_name))
  end

  it 'uses the name passed in the options argument when supplied' do
    class TestTask46c8 < RakeTaskLib::Task
    end

    test_task = TestTask46c8.new(name: :some_name)

    expect(test_task.name).to(eq(:some_name))
  end

  it 'overrides specified default name when name passed in the options ' +
      'argument' do
    class TestTask502f < RakeTaskLib::Task
      default_name :some_default_name
    end

    test_task = TestTask502f.new(name: :some_specific_name)

    expect(test_task.name).to(eq(:some_specific_name))
  end

  it 'has no argument names by default' do
    class TestTaskFb8b < RakeTaskLib::Task
    end

    test_task = TestTaskFb8b.new

    expect(test_task.argument_names).to(eq([]))
  end

  it 'uses the specified argument names when provided' do
    class TestTaskAa81 < RakeTaskLib::Task
      default_argument_names [:first, :second]
    end

    test_task = TestTaskAa81.new

    expect(test_task.argument_names).to(eq([:first, :second]))
  end

  it 'uses the argument names passed in the options argument when supplied' do
    class TestTask10d6 < RakeTaskLib::Task
    end

    test_task = TestTask10d6.new(
        argument_names: [:first_argument, :second_argument])

    expect(test_task.argument_names)
        .to(eq([:first_argument, :second_argument]))
  end

  it 'overrides specified default argument names when argument names passed ' +
      'in the options argument' do
    class TestTask502f < RakeTaskLib::Task
      default_argument_names [:first, :second]
    end

    test_task = TestTask502f.new(
        argument_names: [:third, :fourth])

    expect(test_task.argument_names)
        .to(eq([:third, :fourth]))
  end

  it 'has no prerequisites by default' do
    class TestTask72c1 < RakeTaskLib::Task
    end

    test_task = TestTask72c1.new

    expect(test_task.prerequisites).to(eq([]))
  end

  it 'uses the specified prerequisites when provided' do
    class TestTaskAa81 < RakeTaskLib::Task
      default_prerequisites ["some:first", "some:second"]
    end

    test_task = TestTaskAa81.new

    expect(test_task.prerequisites).to(eq(["some:first", "some:second"]))
  end

  it 'uses the prerequisites passed in the options argument when supplied' do
    class TestTask9f61 < RakeTaskLib::Task
    end

    test_task = TestTask9f61.new(prerequisites: ["some:first", "some:second"])

    expect(test_task.prerequisites)
        .to(eq(["some:first", "some:second"]))
  end

  it 'overrides specified prerequisites when prerequisites passed in the ' +
      'options argument' do
    class TestTaskCf83 < RakeTaskLib::Task
      default_prerequisites ["some:first", "some:second"]
    end

    test_task = TestTaskCf83.new(
        prerequisites: ["some:third", "some:fourth"])

    expect(test_task.prerequisites)
        .to(eq(["some:third", "some:fourth"]))
  end

  it 'has no order only prerequisites by default' do
    class TestTaskB368 < RakeTaskLib::Task
    end

    test_task = TestTaskB368.new

    expect(test_task.order_only_prerequisites).to(eq([]))
  end

  it 'uses the specified order only prerequisites when provided' do
    class TestTask4ba6 < RakeTaskLib::Task
      default_order_only_prerequisites ["some:first", "some:second"]
    end

    test_task = TestTask4ba6.new

    expect(test_task.order_only_prerequisites)
        .to(eq(["some:first", "some:second"]))
  end

  it 'uses the order only prerequisites passed in the options argument ' +
      'when supplied' do
    class TestTaskA8d1 < RakeTaskLib::Task
    end

    test_task = TestTaskA8d1.new(
        order_only_prerequisites: ["some:first", "some:second"])

    expect(test_task.order_only_prerequisites)
        .to(eq(["some:first", "some:second"]))
  end

  it 'overrides specified order only prerequisites when order only ' +
      'prerequisites passed in the options argument' do
    class TestTaskE4d6 < RakeTaskLib::Task
      default_order_only_prerequisites ["some:first", "some:second"]
    end

    test_task = TestTaskE4d6.new(
        order_only_prerequisites: ["some:third", "some:fourth"])

    expect(test_task.order_only_prerequisites)
        .to(eq(["some:third", "some:fourth"]))
  end
end
