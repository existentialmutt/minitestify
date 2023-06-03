require "test_helper"
require "debug"
require "minitestify/spec"

class Minitestify::Mutations::TestDescribe < Minitest::Test
  def test_describe_class
    from = <<~RUBY
      describe Calculator do
      end
    RUBY
    expected = <<~RUBY
      class CalculatorTest < Minitest::Test
      end
    RUBY
    spec = Minitestify::Spec.new(file: "test", source: from)
    assert_equal(expected, spec.to_test_code)
  end

  def test_describe_string
    from = <<~RUBY
      describe "my calculator" do
      end
    RUBY
    expected = <<~RUBY
      class MyCalculatorTest < Minitest::Test
      end
    RUBY
    spec = Minitestify::Spec.new(file: "test", source: from)
    assert_equal(expected, spec.to_test_code)
  end

  def test_context_string
    from = <<~RUBY
      describe Calculator do
        context "when adding" do
        end
      end
    RUBY
    expected = <<~RUBY
      class CalculatorTest < Minitest::Test
        class WhenAddingTest < Minitest::Test
        end
      end
    RUBY
    spec = Minitestify::Spec.new(file: "test", source: from)
    assert_equal(expected, spec.to_test_code)
  end
end
