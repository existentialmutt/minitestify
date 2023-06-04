require "test_helper"
require "debug"
require "minitestify/spec"

class Minitestify::Mutations::TestBeTruthy < Minitest::Test
  def test_be_truthy
    from = <<~RUBY
      class CalculatorTest < Minitest::Test
        def test_can_add
          testing = false
          expect(testing).to be_truthy
        end
      end
    RUBY
    expected = <<~RUBY
      class CalculatorTest < Minitest::Test
        def test_can_add
          testing = false
          assert(testing)
        end
      end
    RUBY
    spec = Minitestify::Spec.new(file: "test", source: from)
    assert_equal(expected, spec.to_test_code)
  end
end
