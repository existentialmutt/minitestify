require "test_helper"
require "debug"
require "minitestify/spec"

class Minitestify::Mutations::TestEq < Minitest::Test
  def test_eq
    from = <<~RUBY
      class CalculatorTest < Minitest::Test
        def test_can_add
          expect(testing).to eq(true)
        end
      end
    RUBY
    expected = <<~RUBY
      class CalculatorTest < Minitest::Test
        def test_can_add
          assert_equal(true, testing)
        end
      end
    RUBY
    spec = Minitestify::Spec.new(file: "test", source: from)
    assert_equal(expected, spec.to_test_code)
  end
end
