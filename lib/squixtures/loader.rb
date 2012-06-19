#! /usr/bin/env ruby
# Copyright (c), 2012 Peter Wood

require 'stringio'
require 'pp'

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
         names.each do |name|
            fixtures << Fixture.new(name, @configuration)
         end

         # Connect to the database.
         url        = generate_connection_url
         Loader.log.debug "Database Connection URL: #{url}"
         connection = Sequel.connect(url)

         # Perform the actual load.
         begin
            Loader.log.debug "Calling before_load as precursor to fixture load."
            before_load(fixtures, connection)

            Loader.log.debug "Starting fixtures load."
            fixtures.each do |fixture|
               if @configuration[:transactional]
                  connection.transaction {fixture.load(connection)}
               else
                  fixture.load(connection)
               end                  
            end

            Loader.log.debug "Calling after_load after fixtures have been loaded."
            after_load(fixtures, connection)
         end
      end

      private

      # This method is used internally by the class to perform any actions
      # prior to actually loading the data into the database.
      #
      # ==== Parameters
      # fixtures::    A collection of the fixtures to be loaded.
      # connection::  The database connection.
      def before_load(fixtures, connection)
         adapter = @configuration[:database]["adapter"]
         postgres_before_load(fixtures, connection) if adapter == 'postgresql'
      end

      # This method is used internally by the class to perform any actions
      # immediately after all the fixture data has been loaded.
      #
      # ==== Parameters
      # fixtures::    A collection of the fixtures that was loaded.
      # connection::  The database connection.
      def after_load(fixtures, connection)
         adapter = @configuration[:database]["adapter"]
         postgres_after_load(fixtures, connection) if adapter == 'postgresql'
      end

      # This method is used internally by the class to generate the URL that
      # will be used to connect to the database.
      def generate_connection_url
         settings = @configuration[:database]
         adapter  = settings["adapter"]
         Loader.log.debug "Database adapter is '#{adapter}'."
         case adapter
            when 'postgresql'
               generate_postgres_url(settings)

            when 'sqlite3'
               generate_sqlite_url(settings)

            else
               raise SquixtureError.new("Unsupported database adapter #{adapter} encountered.")
         end
      end

      # This method is used internally by the class to generate a connection URL
      # for the Postgres RDBMS.
      #
      # ==== Parameters
      # settings::  The database configuration settings to be used to generate
      #             the URL.
      def generate_postgres_url(settings)
         url = StringIO.new
         url << "postgres://"
         if settings.include?("username")
            url << settings["username"]
            url << ":#{settings['password']}" if settings.include?("password")
         end
         url << "@"
         if settings.include?("host")
            url << "@#{settings['host']}"
            url << ":#{settings['port']}" if settings.include?("port")
         end
         url << "/#{settings['database']}" if settings.include?("database")
         url.string
      end

      # This method is used internally by the class to generate a connection URL
      # for the Postgres RDBMS.
      #
      # ==== Parameters
      # settings::  The database configuration settings to be used to generate
      #             the URL.
      def generate_sqlite_url(settings)
         url = StringIO.new
         url << "sqlite://#{settings['database']}"
         url.string
      end

      # This method is invoked just prior to a fixtures load and turns off the
      # referential integrity in all of the tables being loaded to ease the
      # loading process.
      def postgres_before_load(fixtures, connection)
         fixtures.each do |fixture|
            connection.run("alter table #{fixture.table_name} disable trigger all")
         end
      end

      # This method is invoked just after to a fixtures load and turns on the
      # referential integrity in all of the tables that were loaded.
      def postgres_after_load(fixtures, connection)
         fixtures.each do |fixture|
            connection.run("alter table #{fixture.table_name} enable trigger all")
         end
      end
   end
end