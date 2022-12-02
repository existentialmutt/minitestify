# frozen_string_literal: true

require "test_helper"
require "minitestify/spec"

class Minitestify::TestSpec < Minitest::Test
  def setup
    @spec = Minitestify::Spec.new(file: "spec/calculator_spec.rb")
  end

  def test_to_test_filepath
    assert_equal("test/calculator_test.rb", @spec.to_test_filepath)
  end

  def test_to_test_code
    expected = <<~RUBY
      class CalculatorTest < Minitest::Test
        def test_can_add
          calculator = Calculator.new
          assert_equal(2, calculator.add(1, 1))
        end
      end
    RUBY
    assert_equal(expected, @spec.to_test_code)
  end
end
