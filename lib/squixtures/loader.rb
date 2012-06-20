#! /usr/bin/env ruby
# Copyright (c), 2012 Peter Wood

require 'stringio'

module Squixtures
   # This class encapsulates the functionality to load multiple fixtures.
   class Loader
      # Add logging to the class.
      LogJam.apply(self, "squixtures")

      # Constructor the Loader class.
      #
      # ==== Parameters
      # configuration::  The configuration to be used by the loader to load
      #                  fixtures.
      def initialize(configuration)
         @configuration = configuration
      end

      # This method performs the actual work of loading the fixture data
      # specified.
      #
      # ==== Parameters
      # *names::  A collection of the fixture names to be loaded.
      def load(*names)
         # Generate the list of fixtures to be loaded.
         fixtures = []

         # Expand :all to a list of fixture names.
         if names.size == 1 && names[0] == :all
            names         = []
            fixtures_path = Squixtures.find_fixtures_dir
            if !fixtures_path.nil?
               Dir.glob("#{fixtures_path}/*.yml").each do |file_path|
                  file_name = File.basename(file_path)
                  extension = File.extname(file_name)
                  names << file_name[0, file_name.length - extension.length].intern
               end
            end
         end

         names.each do |name|
            fixtures << Fixture.new(name, @configuration)
         end

         # Connect to the database.
         url        = Squixtures.get_connection_url(@configuration[:database])
         Loader.log.debug "Database Connection URL: #{url}"
         connection = Sequel.connect(url)

         # Create the database helper class.
         helper = HelperFactory.create_helper(@configuration[:database])

         # Perform the actual load.
         begin
            Loader.log.debug "Calling before_load as precursor to fixture load."
            helper.before_load(fixtures, connection)

            Loader.log.debug "Starting fixtures load."
            fixtures.each do |fixture|
               if @configuration[:transactional]
                  connection.transaction {fixture.load(connection)}
               else
                  fixture.load(connection)
               end                  
            end

            Loader.log.debug "Calling after_load after fixtures have been loaded."
            helper.after_load(fixtures, connection)
         end
      end
   end
end