# frozen_string_literal: true

require "pathname"
require "minitestify"
require "minitestify/mutations/base"
require "minitestify/mutations/describe"
require "minitestify/mutations/it"
require "minitestify/mutations/eq"
require "minitestify/mutations/be_truthy"
require "minitestify/mutations/be_falsey"
require "minitestify/mutations/be_empty"

module Minitestify
  class Spec
    attr_reader :rails, :file, :source

    def initialize(file:, source: nil, rails: false)
      @file = file
      @source = source || SyntaxTree.read(@file)
      @rails = rails
    end

    def to_test_filepath
      path = Pathname.new(file)
      parts = path.each_filename.map do |part|
        if part == "spec"
          "test"
        else
          part.gsub("_spec.rb", "_test.rb")
        end
      end

      parts.unshift("/") if path.absolute?
      Pathname.new("").join(*parts).to_s
    end

    def to_test_code
      program = SyntaxTree.parse(@source)

      visitor = SyntaxTree::Visitor::MutationVisitor.new

      args = {
        file: file,
        rails: rails
      }

      Mutations::Describe.new(**args).add_mutation!(visitor)
      Mutations::It.new(**args).add_mutation!(visitor)
      Mutations::Eq.new(**args).add_mutation!(visitor)
      Mutations::BeTruthy.new(**args).add_mutation!(visitor)
      Mutations::BeFalsey.new(**args).add_mutation!(visitor)
      Mutations::BeEmpty.new(**args).add_mutation!(visitor)

      SyntaxTree::Formatter.format(@source, program.accept(visitor))
    end
  end
end
