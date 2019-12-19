# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rake_tasklib/version'

Gem::Specification.new do |spec|
  spec.name = 'rake_tasklib'
  spec.version = RakeTaskLib::VERSION
  spec.authors = ['Toby Clemson']
  spec.email = ['tobyclemson@gmail.com']

  spec.summary = 'An enhanced tasklib to aid in creating custom rake tasks.'
  spec.description = 'Provides an enhanced tasklib base class to allow ' +
      'declarative definition of rake tasks.'
  spec.homepage = 'https://github.com/infrablocks/rake_tasklib'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5.1'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'gem-release', '~> 2.0'
  spec.add_development_dependency 'activesupport', '~> 5.2'
  spec.add_development_dependency 'fakefs', '~> 0.18'
  spec.add_development_dependency 'simplecov', '~> 0.16'
end
