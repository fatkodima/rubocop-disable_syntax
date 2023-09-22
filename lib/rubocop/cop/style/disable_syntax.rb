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

        def on_csend(node)
          if !safe_navigation_allowed?
            add_offense(node, message: "Do not use `&.`.")
          end
        end

        def on_def(node)
          if node.endless? && !endless_methods_allowed?
            add_offense(node, message: "Do not use endless methods.") do |corrector|
              arguments = node.arguments.any? ? node.arguments.source : ""

              corrector.replace(node, <<~RUBY.strip)
                def #{node.method_name}#{arguments}
                  #{node.body.source}
                end
              RUBY
            end
          end
        end
        alias on_defs on_def

        private
          def unless_allowed?
            !disable_syntax.include?("unless")
          end

          def ternary_allowed?
            !disable_syntax.include?("ternary")
          end

          def safe_navigation_allowed?
            !disable_syntax.include?("safe_navigation")
          end

          def endless_methods_allowed?
            !disable_syntax.include?("endless_methods")
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
