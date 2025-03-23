# frozen_string_literal: true

require "lint_roller"

module RuboCop
  module DisableSyntax
    # A plugin that integrates RuboCop Disable Syntax with RuboCop's plugin system.
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: "rubocop-disable_syntax",
          version: VERSION,
          homepage: "https://github.com/fatkodima/rubocop-disable_syntax",
          description: "A RuboCop plugin that allows to disable some unfavorite ruby syntax, " \
                       "such as `unless`, safe navigation etc."
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: Pathname.new(__dir__).join("../../../config/default.yml")
        )
      end
    end
  end
end
