# frozen_string_literal: true

require_relative "minitestify/version"
require "syntax_tree"
require "dry/inflector"

module Minitestify
  class Error < StandardError
  end
end
