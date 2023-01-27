# frozen_string_literal: true

module RakeFactory
  class RequiredParameterUnset < ::StandardError
  end

  class DependencyTaskMissing < ::StandardError
  end
end
