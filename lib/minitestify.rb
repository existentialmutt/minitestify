# frozen_string_literal: true

require_relative "minitestify/version"
require "syntax_tree"

# Starting off with a spike to convert a simple rspec example

module Minitestify
  class Error < StandardError
  end

  class Spike
    def initialize
      src = SyntaxTree.read("lib/calculator_spec.rb")
      prog = SyntaxTree.parse(src)
      @result_nodes = []

      prog.statements.body.each do |node|
        case node
        in SyntaxTree::Command[
             message: SyntaxTree::Ident[value: "describe"],
             arguments: SyntaxTree::Args[
               parts: [
                 SyntaxTree::VarRef[value: SyntaxTree::Const[value: value]]
               ]
             ]
           ]
          handle_describe node, value
        else
          handle_node node
        end

        maxwidth = SyntaxTree::DEFAULT_PRINT_WIDTH
        options = SyntaxTree::Formatter::Options.new
        formatter =
          SyntaxTree::Formatter.new("", [], maxwidth, options: options)
        new_prog =
          prog.copy statements: prog.statements.copy(body: @result_nodes)

        new_prog.format(formatter)

        formatter.flush
        print formatter.output.join
      end
    end

    def handle_node(node)
      @result_nodes << node
    end

    def handle_describe(node, value)
      class_node =
        SyntaxTree::ClassDeclaration.new(
          constant:
            SyntaxTree::ConstRef.new(
              constant:
                SyntaxTree::Const.new(
                  value: "#{value}Test",
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

      @result_nodes << class_node
    end
  end
end

Minitestify::Spike.new
