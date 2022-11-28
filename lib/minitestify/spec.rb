# frozen_string_literal: true

require "minitestify"

module Minitestify
  class Spec
    def initialize(file:)
      @file = file
    end

    def to_test_filepath
      @file.gsub "spec", "test"
      # TODO be smarter here and dissect the file path
      # replacing only the spec dir (if present)
      # and the _spec.rb suffix
    end

    def to_test_code
      source = SyntaxTree.read(@file)
      program = SyntaxTree.parse(source)

      visitor = SyntaxTree::Visitor::MutationVisitor.new
      inflector = Dry::Inflector.new

      # describe -> class
      visitor.mutate("Command[ message: Ident[value: \"describe\"] ]") do |node|
        node => SyntaxTree::Command[

          message: SyntaxTree::Ident[value: "describe"],
          arguments: SyntaxTree::Args[
            parts: [SyntaxTree::VarRef[value: SyntaxTree::Const[value: value]]]
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
          name:
            SyntaxTree::Ident.new(
              value: "test_#{value.gsub(" ", "_")}",
              location: node.location
            ),
          params: SyntaxTree::Params,
          bodystmt: node.child_nodes.last.bodystmt,
          location: node.location
        )
      end

      expect_eq_search =
        'CommandCall[
          receiver: CallNode[
            message: Ident[value: "expect"]
          ],
          operator: Period[value: "."],
          message: Ident[value: "to"],
          arguments: Args[
            parts: [ CallNode[
              message: Ident[value: "eq"]
              ]
            ]
          ]
        ]'
      visitor.mutate(expect_eq_search) do |node|
        node => SyntaxTree::CommandCall[
          receiver: SyntaxTree::CallNode[
            receiver: nil,
            operator: nil,
            message: SyntaxTree::Ident[value: "expect"],
            arguments: SyntaxTree::ArgParen[
              arguments: SyntaxTree::Args[parts: [actual_expr]]
            ]
          ],
          operator: SyntaxTree::Period[value: "."],
          message: SyntaxTree::Ident[value: "to"],
          arguments: SyntaxTree::Args[
            parts: [
              SyntaxTree::CallNode[
                receiver: nil,
                operator: nil,
                message: SyntaxTree::Ident[value: "eq"],
                arguments: SyntaxTree::ArgParen[
                  arguments: SyntaxTree::Args[parts: [expected_expr]]
                ]
              ]
            ]
          ]
        ]

        SyntaxTree::CallNode.new(
          message:
            SyntaxTree::Ident.new(
              value: "assert_equal",
              location: node.location
            ),
          arguments:
            SyntaxTree::ArgParen.new(
              arguments:
                SyntaxTree::Args.new(
                  parts: [expected_expr, actual_expr],
                  location: node.location
                ),
              location: node.location
            ),
          location: node.location,
          receiver: nil,
          operator: nil
        )
      end

      SyntaxTree::Formatter.format(source, program.accept(visitor))
    end
  end
end
