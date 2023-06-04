require_relative "base"

module Minitestify
  module Mutations
    class BeTruthy < Base
      def add_mutation!(visitor)
        expect_be_truthy_search =
          'CommandCall[
          receiver: CallNode[
            message: Ident[value: "expect"],
          ],
          operator: Period[value: "."],
          message: Ident[value: "to"],
          arguments: Args[
            parts: [VCall[
              value: Ident[value: "be_truthy"]
            ]]
          ]
        ]'
        visitor.mutate(expect_be_truthy_search) do |node|
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
                SyntaxTree::VCall[
                  value: SyntaxTree::Ident[value: "be_truthy"],
                ]
              ]
            ]
          ]

          SyntaxTree::CallNode.new(
            message:
            SyntaxTree::Ident.new(
              value: "assert",
              location: node.location
            ),
            arguments:
            SyntaxTree::ArgParen.new(
              arguments:
              SyntaxTree::Args.new(
                parts: [actual_expr],
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
