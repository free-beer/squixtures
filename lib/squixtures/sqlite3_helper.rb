#! /usr/bin/env ruby
# Copyright (c), 2012 Peter Wood

module Squixtures
   # A class to contain elements specific to the SQLite3 system.
   class SQLite3Helper
      # Add logging to the class.
      LogJam.apply(self, "squixtures")

      # This method is invoked immediately before a fixture load starts and
      # performs all work necessary to facilitate the load.
      #
      # ==== Parameters
      # fixtures::    A collection of the fixture objects to be loaded.
      # connection::  The database connection that the load will be performed
      #               through.
      def before_load(fixtures, connection)
         SQLite3Helper.log.debug "SQLite3Helper.before_load called."
         connection.run("PRAGMA foreign_keys = OFF")
      end

      # This method is invoked immediately after a fixture load completes and
      # performs all clean up necessary.
      #
      # ==== Parameters
      # fixtures::    A collection of the fixture objects to be loaded.
      # connection::  The database connection that the load will be performed
      #               through.
      def after_load(fixtures, connection)
         SQLite3Helper.log.debug "SQLite3Helper.after_load called."
         connection.run("PRAGMA foreign_keys = ON")
      end

      # This method is an instance level version of the get_connection_url
      # method declared at the class level.
      def get_connection_url(settings)
         SQLite3Helper.get_connection_url(settings)
      end

      # This method converts a typical set of database connection settings, such
      # as those in a Rails database.yml file, into the URL to be used to connect
      # to a Postgres database using the Sequel library.
      #
      # ==== Parameters
      # settings::  A Hash of the settings that will be used to generate the
      #             connection URL.
      def self.get_connection_url(settings)
         "sqlite://#{settings['database']}"
      end
   end
end