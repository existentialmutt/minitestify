# frozen_string_literal: true

require "minitestify"
require "minitestify/version"
require "minitestify/spec"
require "optparse"

module Minitestify::CLI
  module_function def run
    options = {}
    save = false
    OptionParser
      .new do |parser|
        parser.banner = "Usage: minitestify [options] <spec_files>"

        parser.on("-v", "--version", "Print version") do |v|
          puts(Minitestify::VERSION)
          exit
        end

        parser.on("-h", "--help", "Prints this help") do
          puts(parser)
          exit
        end

        parser.on("-r", "--rails", "Use more railsy syntax") do
          options[:rails] = true
        end

        parser.on("-s", "--save", "Replace spec with test in path & file name. Write to new file") do
          save = true
        end
      end
      .parse!

    ARGV.each do |file|
      spec = Minitestify::Spec.new(file: file, **options)
      if save
        puts("Writing to #{spec.to_test_filepath}")
        File.write(spec.to_test_filepath, spec.to_test_code)
      else
        puts(spec.to_test_code)
      end
    end
    puts
  end
end
