module Minitestify
  module Mutations
    class Base
      attr_reader :file, :rails

      def initialize file:, rails: false, **args
        @file = file
        @rails = rails
      end
    end
  end
end
