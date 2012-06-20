#! /usr/bin/env ruby
# Copyright (c), 2012 Peter Wood

module Squixtures
   module HelperFactory
      # This method fetches an appropriate database helper instance based on the
      # database connection details provided. The method will raise an exception
      # if an unrecognised database type is encountered.
      #
      # ==== Parameters
      # settings::  A Hash of the database connection settings.
      def self.create_helper(settings)
         adapter = settings['adapter']
         helper  = nil
         case adapter
            when 'postgresql'
               helper = PostgresHelper.new

            when 'sqlite3'
               helper = SQLite3Helper.new
         end

         if helper.nil?
            raise SquixturesError.new("Unrecognised database adapter '#{adapter}' encountered.")
         end
         helper
      end
   end
end