require "test_helper"
require "debug"
require "minitestify/spec"

class Minitestify::Mutations::TestBeEmpty < Minitest::Test
  def test_be_falsey
    from = <<~RUBY
      class CalculatorTest < Minitest::Test
        def test_can_add
          expect(user.errors[:invitation_code]).to be_empty
        end
      end
    RUBY
    expected = <<~RUBY
      class CalculatorTest < Minitest::Test
        def test_can_add
          assert_empty(user.errors[:invitation_code])
        end
      end
    RUBY
    spec = Minitestify::Spec.new(file: "test", source: from)
    assert_equal(expected, spec.to_test_code)
  end
end
