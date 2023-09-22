# frozen_string_literal: true

require "rubocop"

require_relative "rubocop/disable_syntax"
require_relative "rubocop/disable_syntax/version"
require_relative "rubocop/disable_syntax/inject"

RuboCop::DisableSyntax::Inject.defaults!

require_relative "rubocop/cop/style/disable_syntax"
