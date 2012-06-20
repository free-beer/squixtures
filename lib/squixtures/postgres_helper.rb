#! /usr/bin/env ruby
# Copyright (c), 2012 Peter Wood

require 'stringio'

module Squixtures
   # A class to contain elements specific to the Postgres system.
   class PostgresHelper
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
         PostgresHelper.log.debug "PostgresHelper.before_load called."
         fixtures.each do |fixture|
            connection.run("alter table #{fixture.table_name} disable trigger all")
         end
      end

      # This method is invoked immediately after a fixture load completes and
      # performs all clean up necessary.
      #
      # ==== Parameters
      # fixtures::    A collection of the fixture objects to be loaded.
      # connection::  The database connection that the load will be performed
      #               through.
      def after_load(fixtures, connection)
         PostgresHelper.log.debug "PostgresHelper.after_load called."
         fixtures.each do |fixture|
            connection.run("alter table #{fixture.table_name} enable trigger all")
         end
      end

      # This method converts a typical set of database connection settings, such
      # as those in a Rails database.yml file, into the URL to be used to connect
      # to a Postgres database using the Sequel library.
      #
      # ==== Parameters
      # settings::  A Hash of the settings that will be used to generate the
      #             connection URL.
      def self.get_connection_url(settings)
         url = StringIO.new
         url << "postgres://"
         if settings.include?("username")
            url << settings["username"]
            url << ":#{settings['password']}" if settings.include?("password")
         end
         url << "@"
         if settings.include?("host")
            url << "#{settings['host']}"
            url << ":#{settings['port']}" if settings.include?("port")
         end
         url << "/#{settings['database']}" if settings.include?("database")
         url.string
      end
   end
end