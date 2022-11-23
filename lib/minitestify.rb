# frozen_string_literal: true

require_relative "minitestify/version"
require "syntax_tree"
require "dry/inflector"

# Starting off with a spike to convert a simple rspec example

module Minitestify
  class Error < StandardError
  end

  class Spike
    def initialize
      source = SyntaxTree.read("lib/calculator_spec.rb")
      program = SyntaxTree.parse(source)

      visitor = SyntaxTree::Visitor::MutationVisitor.new
      inflector = Dry::Inflector.new

      # describe -> class
      visitor.mutate(
        "Command[ message: Ident[value: \"describe\"] ]"
      ) do |node|
        node => SyntaxTree::Command[
          message: SyntaxTree::Ident[value: "describe"],
          arguments: SyntaxTree::Args[
            parts: [
              SyntaxTree::VarRef[
                value: SyntaxTree::Const[value: value]
              ]
            ]
          ]
        ]

        SyntaxTree::ClassDeclaration.new(
          constant:
            SyntaxTree::ConstRef.new(
              constant:
                SyntaxTree::Const.new(
                  value: "#{inflector.camelize_upper(value)}Test",
                  location: node.location
                ),
              location: node.location
            ),
          superclass:
            SyntaxTree::ConstPathRef.new(
              parent:
                SyntaxTree::VarRef.new(
                  value:
                    SyntaxTree::Const.new(
                      value: "Minitest",
                      location: node.location
                    ),
                  location: node.location
                ),
              constant:
                SyntaxTree::Const.new(value: "Test", location: node.location),
              location: node.location
            ),
          bodystmt: node.child_nodes.last.bodystmt,
          location: node.location
        )
      end

      # it -> def
      visitor.mutate("Command[message: Ident[value: \"it\"]]") do |node|
        node => SyntaxTree::Command[
          message: SyntaxTree::Ident[value: "it"],
          arguments: SyntaxTree::Args[
            parts: [
              SyntaxTree::StringLiteral[
                parts: [SyntaxTree::TStringContent[value: value]]
              ]
            ]
          ]
        ]

        SyntaxTree::DefNode.new(
          target: nil,
          operator: nil,
          name: SyntaxTree::Ident.new(value: "test_#{value.gsub(" ", "_")}", location: node.location),
          params: SyntaxTree::Params,
          bodystmt: node.child_nodes.last.bodystmt,
          location: node.location
        )
      end

      print SyntaxTree::Formatter.format(source, program.accept(visitor))
    end
  end
end

Minitestify::Spike.new
