# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      class DisableSyntax < Base
        extend AutoCorrector

        def on_if(node)
          if node.unless? && !unless_allowed?
            add_offense(node, message: "Do not use `unless`.") do |corrector|
              corrector.replace(node.loc.keyword, "if")
              corrector.wrap(node.condition, "!(", ")")
            end
          elsif node.ternary? && !ternary_allowed?
            add_offense(node, message: "Do not use ternary operator.")
          end
        end

        private
          def unless_allowed?
            !disable_syntax.include?("unless")
          end

          def ternary_allowed?
            !disable_syntax.include?("ternary")
          end

          def disable_syntax
            @disable_syntax ||= begin
              supported_disable_syntax = cop_config.fetch("SupportedDisableSyntax", [])
              disable_syntax = cop_config.fetch("DisableSyntax", [])
              if (extra_syntax = disable_syntax - supported_disable_syntax).any?
                raise "Unknown `DisableSyntax` value(s): #{extra_syntax.join(', ')}"
              end

              disable_syntax
            end
          end
      end
    end
  end
end
