require "test_helper"
require "debug"
require "minitestify/spec"

class Minitestify::Mutations::TestBeFalsey < Minitest::Test
  def test_be_falsey
    from = <<~RUBY
      class CalculatorTest < Minitest::Test
        def test_can_add
          testing = false
          expect(testing).to be_falsey
        end
      end
    RUBY
    expected = <<~RUBY
      class CalculatorTest < Minitest::Test
        def test_can_add
          testing = false
          refute(testing)
        end
      end
    RUBY
    spec = Minitestify::Spec.new(file: "test", source: from)
    assert_equal(expected, spec.to_test_code)
  end
end
