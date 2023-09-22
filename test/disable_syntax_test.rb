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
              "unless"
            ],
            "DisableSyntax" => Array(list)
          }
        },
        "#{Dir.pwd}/.rubocop.yml"
      )

      @cop = RuboCop::Cop::Style::DisableSyntax.new(configuration)
    end
end
