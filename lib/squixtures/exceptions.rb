#! /usr/bin/env ruby
# Copyright (c), 2012 Peter Wood

require 'stringio'

module Squixtures
   # This class provides the exception class used by the Squixtures library.
   class SquixtureError < StandardError
      # Attribute accessor/mutator declarations.
      attr_accessor :verbose

      # Constructor for the SquixtureError class.
      #
      # ==== Parameters
      # message::  The message to be associated with the error.
      # cause::    Any underlying exception to be associated with the error.
      #            Defaults to nil.
      def initialize(message, cause=nil, verbose=true)
         super(message)
         @cause   = cause
         @verbose = verbose
      end

      # This method fetches a stringified interpretation of an exception.
      def to_s()
         text = StringIO.new
         text << super
         if @verbose
            text << "\n" + self.backtrace.join("\n")
            if !@cause.nil?
               text << "\n\nCause: #{@cause}"
               text << "\n" + @cause.backtrace.join("\n")
            end
         end
         text.string
      end
   end
end