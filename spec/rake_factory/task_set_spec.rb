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
      default_name :some_task_name

      parameter :spinach
      parameter :lettuce
    end

    test_task_set = TestTaskSetA777.define(
        spinach: lambda { "Some lazy spinach value." },
        lettuce: lambda { |t| "Lettuce for #{t.name}." })

    expect(test_task_set.spinach).to(eq("Some lazy spinach value."))
    expect(test_task_set.lettuce).to(eq("Lettuce for some_task_name."))
  end
end
