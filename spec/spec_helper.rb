# frozen_string_literal: true

require 'bundler/setup'
require 'pp'
require 'rspec'
require 'cocoapods'

module Kernel
  # Like describe, but makes all private/protected instance methods of the clazz public
  def describe_with_private_methods(clazz, *additional_desc, &block)
    if clazz.is_a?(Module)
      methods = clazz.private_instance_methods(false) + clazz.protected_methods(false)
      clazz.send(:public, *methods)
    end
    describe(clazz, *additional_desc, &block)
  end
end

module Pod
  # Disable the wrapping so the output is deterministic in the tests.
  #
  UI.disable_wrap = true

  # Redirects the messages to an internal store.
  #
  module UI
    @output = ''
    @warnings = ''

    class << self
      attr_accessor :output
      attr_accessor :warnings

      def puts(message = '')
        @output << "#{message}\n"
      end

      def warn(message = '', _actions = [])
        @warnings << "#{message}\n"
      end

      def print(message)
        @output << message
      end
    end
  end
end
