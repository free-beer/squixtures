#! /usr/bin/env ruby
# Copyright (c), 2012 Peter Wood

require 'erb'
require 'yaml'

module Squixtures
   # This class represents a single fixtures and provides the functionality
   # to load it's contents into the database.
   class Fixture
      # Add logging to the class.
      LogJam.apply(self, 'squixtures')

      # Constructor for the Fixture class.
      #
      # ==== Parameters
      # name::           The name of the fixture. This will be used to work out
      #                  the fixture file and table names.
      # configuration::  The configuration to be used by the Fixture.
      def initialize(name, configuration)
         @name          = name
         @configuration = configuration
      end

      # This method attempts to locate a fixture file, load it's contents and
      # then insert the details held with the fixture file into the database.
      #
      # ==== Parameters
      # connection::  The database connection to be used to insert the fixture
      #               details into the database.
      def load(connection)
         Fixture.log.debug "Loading the #{@name} fixture."
         fixture_path = file_path
         if fixture_path.nil?
             raise SquixtureError.new("Unable to locate a data file for the #{@name} fixture.")
         end

         begin
            Fixture.log.debug "Loading the data for the #{@name} fixture from #{fixture_path}."
            content = File.open(fixture_path, "r") {|file| file.readlines.join("")}
            #Fixture.log.debug "Read:\n#{content}"
            entries = YAML.load(ERB.new(content).result)
            if entries && entries.size > 0
               data_set = connection[@name.intern]
               data_set.delete if @configuration[:clear_tables]
               entries.each do |key, values|
                  data_set.insert(convert_values(values))
               end
            end
         rescue => error
             message = "Load of the #{@name} fixture failed."
             Fixture.log.error "#{message}\nCause: #{error}\n" + error.backtrace.join("\n")
             raise SquixtureError.new(message, error)
         end
      end

      # This method returns the name of the database table that the fixture
      # will load data into.
      def table_name
         @name.to_s
      end

      # This method fetches the path and name of the file that the fixture
      # will load it's data from. This will be nil if a file cannot be located
      # for the fixture.
      def file_path
         path = nil
         @configuration[:search_paths].find do |entry|
             full_path = "#{entry}/#{@name}.yml"
             Fixture.log.debug "Checking for the existence of #{full_path}."
             path = full_path if File.exist?(full_path)
             !path.nil?
         end
         path.nil? ? path : File.expand_path(path)
      end

      private

      # This method converts a standard string keyed hash into a symbol keyed
      # one.
      #
      # ==== Parameters
      # input::  The Hash to be converted.
      def convert_values(input)
         output = {}
         input.each {|key, value| output[key.intern] = value} if input
         output
      end
   end
end