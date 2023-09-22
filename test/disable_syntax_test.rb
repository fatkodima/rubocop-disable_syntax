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
              "arguments_forwarding"
            ],
            "DisableSyntax" => Array(list)
          }
        },
        "#{Dir.pwd}/.rubocop.yml"
      )

      @cop = RuboCop::Cop::Style::DisableSyntax.new(configuration)
    end
end
