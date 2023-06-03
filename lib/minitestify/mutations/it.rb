require_relative "base"

module Minitestify
  module Mutations
    class It < Base
      def add_mutation!(visitor)
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

          if rails
            SyntaxTree::Command.new(
              message: SyntaxTree::Ident.new(value: "test", location: node.message.location),
              arguments: node.arguments,
              block: node.block,
              location: node.location
            )
          else
            SyntaxTree::DefNode.new(
              target: nil,
              operator: nil,
              name:
              SyntaxTree::Ident.new(
                value: "test_#{value.tr("'", "").gsub(/\W/, "_").downcase}",
                location: node.location
              ),
              params: SyntaxTree::Params,
              bodystmt: node.child_nodes.last.bodystmt,
              location: node.location
            )
          end
        end
      end
    end
  end
end
