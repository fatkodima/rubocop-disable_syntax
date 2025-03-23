# frozen_string_literal: true

require_relative "lib/rubocop/disable_syntax/version"

Gem::Specification.new do |spec|
  spec.name = "rubocop-disable_syntax"
  spec.version = RuboCop::DisableSyntax::VERSION
  spec.authors = ["fatkodima"]
  spec.email = ["fatkodima123@gmail.com"]

  spec.summary = "A RuboCop plugin that allows to disable some unfavorite ruby syntax, " \
                 "such as `unless`, safe navigation etc."
  spec.homepage = "https://github.com/fatkodima/rubocop-disable_syntax"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir["**/*.{md,txt}", "{lib,config}/**/*"]
  spec.require_paths = ["lib"]

  spec.metadata["default_lint_roller_plugin"] = "RuboCop::DisableSyntax::Plugin"

  spec.add_dependency "lint_roller"
  spec.add_dependency "rubocop", ">= 1.72.0"
end
