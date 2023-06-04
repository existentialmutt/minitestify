require_relative "base"

module Minitestify
  module Mutations
    class Describe < Base
      def add_mutation!(visitor)
        inflector = Dry::Inflector.new

        # describe|context -> class
        describe_node = ->(node) do
          case node
          in SyntaxTree::Command[
            message: SyntaxTree::Ident[value: "describe"],
            arguments: SyntaxTree::Args[
              parts: [SyntaxTree::VarRef[value: SyntaxTree::Const[value: value]]]
            ]
          ] => node
          in SyntaxTree::Command[
            message: SyntaxTree::Ident[value: "describe"],
            arguments: SyntaxTree::Args[
              SyntaxTree::StringLiteral[
                parts: [SyntaxTree::TStringContent[value: value]]
              ]
            ]
          ] => node
          in SyntaxTree::Command[
            message: SyntaxTree::Ident[value: "context"],
            arguments: SyntaxTree::Args[
              SyntaxTree::StringLiteral[
                parts: [SyntaxTree::TStringContent[value: value]]
              ]
            ]
          ] => node
          end

          value = value.tr("'", "").gsub(/\W/, "_")

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

        visitor.mutate("Command[ message: Ident[value: \"describe\"] ]", &describe_node)
        visitor.mutate("Command[ message: Ident[value: \"context\"] ]", &describe_node)
      end
    end
  end
end
