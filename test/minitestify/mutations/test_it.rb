require "test_helper"
require "debug"
require "minitestify/spec"

class Minitestify::Mutations::TestIt < Minitest::Test
  def test_it
    from = <<~RUBY
      class CalculatorTest < Minitest::Test
        it "can add" do
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

  def test_it_rails
    from = <<~RUBY
      class CalculatorTest < Minitest::Test
        it "can add" do
          expect(testing).to eq(true)
        end
      end
    RUBY
    expected = <<~RUBY
      class CalculatorTest < Minitest::Test
        test "can add" do
          assert_equal(true, testing)
        end
      end
    RUBY
    spec = Minitestify::Spec.new(file: "test", source: from, rails: true)
    assert_equal(expected, spec.to_test_code)
  end
end
