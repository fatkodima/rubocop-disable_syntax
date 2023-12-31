# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Forbid some unfavorite ruby syntax, such as `unless`, safe navigation etc.
      #
      # @safety
      #   Autocorrection is unsafe because there is a different operator precedence
      #   between logical operators (`&&`, `||` and `!`) and semantic operators (`and`, `or` and `not`),
      #   and that might change the behavior.
      #
      # You can set syntax you want to disable via `DisableSyntax`.
      # Available are: 'unless', 'ternary', 'safe_navigation', 'endless_methods',
      # 'arguments_forwarding', 'numbered_parameters', 'pattern_matching',
      # 'shorthand_hash_syntax', 'and_or_not', 'until', and 'percent_literals'.
      #
      # @example DisableSyntax: ['unless']
      #   # bad
      #   do_something unless condition
      #
      #   # good
      #   do_something if !condition
      #
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
          on_send(node)
        end

        def on_send(node)
          if !arguments_forwarding_allowed? && arguments_forwarding?(node)
            add_offense(node, message: "Do not use arguments forwarding.")
          elsif node.prefix_not? && !and_or_not_allowed?
            add_offense(node, message: "Use `!` instead of `not`.") do |corrector|
              corrector.replace(node.loc.selector, "!")
            end
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

        def on_numblock(node)
          if !numbered_parameters_allowed?
            add_offense(node, message: "Do not use numbered parameters.")
          end
        end

        def on_case_match(node)
          if !pattern_matching_allowed?
            add_offense(node, message: "Do not use pattern matching.")
          end
        end

        def on_hash(node)
          return if shorthand_hash_syntax_allowed? || node.pairs.none?(&:value_omission?)

          add_offense(node, message: "Do not use shorthand hash syntax.") do |corrector|
            node.pairs.each do |pair|
              if pair.value_omission?
                hash_key_source = pair.key.source
                corrector.replace(pair, "#{hash_key_source}: #{hash_key_source}")
              end
            end
          end
        end

        def on_and(node)
          if node.semantic_operator? && !and_or_not_allowed?
            add_offense(node, message: "Use `#{node.alternate_operator}` instead of `#{node.operator}`.") do |corrector|
              corrector.replace(node.loc.operator, node.alternate_operator)
            end
          end
        end
        alias on_or on_and

        def on_until(node)
          return if until_allowed?

          add_offense(node, message: "Do not use `until`.") do |corrector|
            corrector.replace(node.loc.keyword, "while")
            corrector.wrap(node.condition, "!(", ")")
          end
        end

        def on_array(node)
          if node.percent_literal? && !percent_literals_allowed?
            add_offense(node, message: "Do not use `%` literals for arrays.")
          end
        end

        def on_regexp(node)
          if node.percent_r_literal? && !percent_literals_allowed?
            add_offense(node, message: "Do not use `%` literals for regexes.")
          end
        end

        def on_str(node)
          if !percent_literals_allowed? && str_percent_literal?(node)
            add_offense(node, message: "Do not use `%` literals for strings.")
          end
        end

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

          def arguments_forwarding_allowed?
            !disable_syntax.include?("arguments_forwarding")
          end

          def arguments_forwarding?(send_node)
            send_node.arguments.any? do |arg|
              (arg.block_pass_type? && arg.source == "&") || # foo(&)
                arg.forwarded_args_type? || # foo(...)
                arg.forwarded_restarg_type? || # foo(*)
                (arg.hash_type? && arg.source == "**") # foo(**)
            end
          end

          def numbered_parameters_allowed?
            !disable_syntax.include?("numbered_parameters")
          end

          def pattern_matching_allowed?
            !disable_syntax.include?("pattern_matching")
          end

          def shorthand_hash_syntax_allowed?
            !disable_syntax.include?("shorthand_hash_syntax")
          end

          def and_or_not_allowed?
            !disable_syntax.include?("and_or_not")
          end

          def until_allowed?
            !disable_syntax.include?("until")
          end

          def percent_literals_allowed?
            !disable_syntax.include?("percent_literals")
          end

          def str_percent_literal?(node)
            if node.loc.respond_to?(:begin) && node.loc.begin
              node.loc.begin.source.start_with?("%")
            end
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
