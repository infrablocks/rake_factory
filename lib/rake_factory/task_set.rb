require 'rake/tasklib'

require_relative 'parameters'
require_relative 'definable'
require_relative 'defaults'

module RakeFactory
  class TaskSet < ::Rake::TaskLib
    extend Parameters
    extend Definable

    include Defaults
    include Arguments

    def define_on(application)
      self
    end
  end
end
