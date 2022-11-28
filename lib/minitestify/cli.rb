# frozen_string_literal: true

require "dry/cli"
require "minitestify"
require "minitestify/version"
require "minitestify/spec"

module Minitestify::CLI
  module Commands
    extend Dry::CLI::Registry

    class Version < Dry::CLI::Command
      desc "Print version"

      def call(*)
        puts Minitestify::VERSION
      end
    end

    class Print < Dry::CLI::Command
      desc "Convert one or more specs to minitest and print to standard out"

      argument :files, type: :array, required: true, desc: "Spec files to convert"

      example [
        "spec/dog_spec.rb # Generates dog_test.rb and prints to standard out"
      ]

      def call(files:, **)
        files.each do |file|
          spec = Minitestify::Spec.new(file: file)
          puts "# #{spec.to_test_filepath}"
          puts spec.to_test_code
          puts
        end
      end
    end

    register "version", Version, aliases: ["v", "-v", "--version"]
    register "print", Print, aliases: ["p", "-p", "--print"]
  end
end
