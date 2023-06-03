require_relative "base"

module Minitestify
  module Mutations
    class Eq < Base
      def add_mutation!(visitor)
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
      end
    end
  end
end
