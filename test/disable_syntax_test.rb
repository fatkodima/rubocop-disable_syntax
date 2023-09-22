# frozen_string_literal: true

require "test_helper"

class DisableSyntaxTest < Minitest::Test
  def setup
    configure_cop
  end

  def test_accepts_unless_by_default
    assert_no_offenses(<<~RUBY)
      foo unless condition
    RUBY
  end

  def test_accepts_if
    disable_syntax("unless")

    assert_no_offenses(<<~RUBY)
      foo if condition
    RUBY
  end

  def test_registers_offense_when_unless_is_disabled
    disable_syntax("unless")

    assert_offense(<<~RUBY)
      foo unless condition
      ^^^^^^^^^^^^^^^^^^^^ Do not use `unless`.
    RUBY

    assert_correction(<<~RUBY)
      foo if !(condition)
    RUBY
  end

  def test_accepts_ternary_by_default
    assert_no_offenses(<<~RUBY)
      condition ? foo : bar
    RUBY
  end

  def test_registers_offense_when_ternary_is_disabled
    disable_syntax("ternary")

    assert_offense(<<~RUBY)
      condition ? foo : bar
      ^^^^^^^^^^^^^^^^^^^^^ Do not use ternary operator.
    RUBY
  end

  def test_accepts_safe_navigation_by_default
    assert_no_offenses(<<~RUBY)
      obj&.foo
    RUBY
  end

  def test_accepts_method_calls
    disable_syntax("safe_navigation")

    assert_no_offenses(<<~RUBY)
      obj.foo
    RUBY
  end

  def test_registers_offense_when_safe_navigation_is_disabled
    disable_syntax("safe_navigation")

    assert_offense(<<~RUBY)
      obj&.foo
      ^^^^^^^^ Do not use `&.`.
    RUBY
  end

  def test_accepts_endless_methods_by_default
    assert_no_offenses(<<~RUBY)
      def foo = 1
    RUBY
  end

  def test_accepts_regular_methods
    disable_syntax("endless_methods")

    assert_no_offenses(<<~RUBY)
      def foo
        1
      end
    RUBY
  end

  def test_registers_offense_when_endless_methods_are_disabled
    disable_syntax("endless_methods")

    assert_offense(<<~RUBY)
      def foo = 1
      ^^^^^^^^^^^ Do not use endless methods.
    RUBY

    assert_correction(<<~RUBY)
      def foo
        1
      end
    RUBY
  end

  def test_accepts_arguments_forwarding_by_default
    assert_no_offenses(<<~RUBY)
      def foo(*) bar(*) end
      def foo(**) bar(**) end
      def foo(&) bar(&) end
      def foo(...) bar(...) end
    RUBY
  end

  def test_accepts_named_arguments_forwarding
    disable_syntax("arguments_forwarding")

    assert_no_offenses(<<~RUBY)
      def foo(*args) bar(*args) end
      def foo(**options) bar(**options) end
      def foo(&block) bar(&block) end
    RUBY
  end

  def test_registers_offense_when_arguments_forwarding_is_disabled
    disable_syntax("arguments_forwarding")

    assert_offense(<<~RUBY)
      def foo(*)
        bar(*)
        ^^^^^^ Do not use arguments forwarding.
      end

      def foo(**)
        bar(**)
        ^^^^^^^ Do not use arguments forwarding.
      end

      def foo(&)
        bar(&)
        ^^^^^^ Do not use arguments forwarding.
      end

      def foo(...)
        bar(...)
        ^^^^^^^^ Do not use arguments forwarding.
      end

      def foo(arg, *)
        bar(*)
        ^^^^^^ Do not use arguments forwarding.
      end
    RUBY
  end

  def test_accepts_numbered_parameters_by_default
    assert_no_offenses(<<~RUBY)
      foo.each { puts _1 }
    RUBY
  end

  def test_registers_offense_when_numbered_parameters_are_disabled
    disable_syntax("numbered_parameters")

    assert_offense(<<~RUBY)
      foo.each { puts _1 }
      ^^^^^^^^^^^^^^^^^^^^ Do not use numbered parameters.
    RUBY
  end

  def test_accepts_pattern_matching_by_default
    assert_no_offenses(<<~RUBY)
      case foo
      in bar
        baz
      end
    RUBY
  end

  def test_registers_offense_when_pattern_matching_is_disabled
    disable_syntax("pattern_matching")

    assert_offense(<<~RUBY)
      case foo
      ^^^^^^^^ Do not use pattern matching.
      in bar
        baz
      end
    RUBY
  end

  def test_accepts_shorthand_hash_syntax_by_default
    assert_no_offenses(<<~RUBY)
      x = 1
      { x: }
    RUBY
  end

  def test_accepts_hash_literals
    disable_syntax("shorthand_hash_syntax")

    assert_no_offenses(<<~RUBY)
      { x: x }
    RUBY
  end

  def test_registers_offense_when_shorthand_hash_syntax_is_disabled
    disable_syntax("shorthand_hash_syntax")

    assert_offense(<<~RUBY)
      x = 1
      { x: }
      ^^^^^^ Do not use shorthand hash syntax.
    RUBY

    assert_correction(<<~RUBY)
      x = 1
      { x: x }
    RUBY
  end

  def test_accepts_semantic_operators_by_default
    assert_no_offenses(<<~RUBY)
      x and y
      x or y
      not x
    RUBY
  end

  def test_registers_offense_when_and_or_not_is_disabled
    disable_syntax("and_or_not")

    assert_offense(<<~RUBY)
      x and y
      ^^^^^^^ Use `&&` instead of `and`.
      x or y
      ^^^^^^ Use `||` instead of `or`.
      not x
      ^^^^^ Use `!` instead of `not`.
    RUBY

    assert_correction(<<~RUBY)
      x && y
      x || y
      ! x
    RUBY
  end

  def test_accepts_until_by_default
    assert_no_offenses(<<~RUBY)
      foo until condition
    RUBY
  end

  def test_registers_offense_when_until_is_disabled
    disable_syntax("until")

    assert_offense(<<~RUBY)
      foo until condition
      ^^^^^^^^^^^^^^^^^^^ Do not use `until`.
    RUBY

    assert_correction(<<~RUBY)
      foo while !(condition)
    RUBY
  end

  def test_raises_when_unknown_disable_syntax_directive_is_set
    disable_syntax("unknown")

    error = assert_raises(RuntimeError) do
      assert_no_offenses("foo unless condition")
    end

    assert_equal "Unknown `DisableSyntax` value(s): unknown", error.message
  end

  private
    def configure_cop
      disable_syntax([])
    end

    def disable_syntax(list)
      configuration = RuboCop::Config.new(
        {
          "Style/DisableSyntax" => {
            "SupportedDisableSyntax" => [
              "unless",
              "ternary",
              "safe_navigation",
              "endless_methods",
              "arguments_forwarding",
              "numbered_parameters",
              "pattern_matching",
              "shorthand_hash_syntax",
              "and_or_not",
              "until"
            ],
            "DisableSyntax" => Array(list)
          }
        },
        "#{Dir.pwd}/.rubocop.yml"
      )

      @cop = RuboCop::Cop::Style::DisableSyntax.new(configuration)
    end
end
