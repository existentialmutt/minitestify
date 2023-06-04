# frozen_string_literal: true

require "test_helper"
require "debug"
require "minitestify/spec"

class Minitestify::TestSpec < Minitest::Test
  def test_to_test_filepath
    assert_equal("test/calculator_test.rb",
      Minitestify::Spec.new(file: "spec/calculator_spec.rb", source: "").to_test_filepath)
    assert_equal("/test/calculator_test.rb",
      Minitestify::Spec.new(file: "/spec/calculator_spec.rb", source: "").to_test_filepath)
    assert_equal("test/some_spec_directory/calculator_test.rb",
      Minitestify::Spec.new(file: "spec/some_spec_directory/calculator_spec.rb", source: "").to_test_filepath)
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

    spec = Minitestify::Spec.new(file: "spec/calculator_spec.rb")
    assert_equal(expected, spec.to_test_code)
  end
end
