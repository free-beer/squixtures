#! /usr/bin/env ruby
# Copyright (c), 2012 Peter Wood

require "logjam"
require "sequel"
require "squixtures/version"
require "squixtures/exceptions"
require "squixtures/fixture"
require "squixtures/fixtures"
require "squixtures/loader"

module Squixtures
   # Definition of the default fixtures directory.
   DEFAULT_FIXTURES_DIR                = "#{Dir.getwd}/test/fixtures"

    # Definition for the default database configuration file name.
   DEFAULT_DATABASE_CFG_FILE           = "database.yml"

   # Definition of the default configuration search paths.
   DEFAULT_CFG_SEARCH_PATHS            = ["#{Dir.getwd}/config",
                                          "#{Dir.getwd}/test/fixtures",
                                          Dir.getwd]

   # Definition of the configuration defaults.
   CONFIGURATION_DEFAULTS              = {:clear_tables  => true,
                                          :database      => nil,
                                          :environment   => "test",
                                          :search_paths  => DEFAULT_CFG_SEARCH_PATHS,
                                          :transactional => false}

   # Module configuration store.
   @@configuration                     = {}.merge(CONFIGURATION_DEFAULTS)

   # This method performs the actual configuration and load of a set of
   # fixtures.
   #
   # ==== Parameters
   # *names::  The list of fixture names to be loaded.
   def self.fixtures(*names)
      load_database_configuration if !@@configuration[:database]
      Loader.new(@@configuration).load(*names)
   end

   # This method allows the configuration of the Squixtures module.
   def self.configuration=(configuration)
      @@configuration = CONFIGURATION_DEFAULTS.merge(configuration)
   end

   # This method fetches configuration associated with the Squixtures module.
   # Note that, due to the late loading of the database configuration, the
   # connection details will not be available until after a load.
   def self.configuration
      @@configuration
   end

   # This method is used to set the environment that the Squixtures module
   # will use when loading fixtures. Note that calling this method will also
   # invoke an immediate reload of database adapter/connection details.
   #
   # ==== Parameters
   # setting::  A String, usually one of "test", "development" or "production"
   #            but can be anything else as long as it matches an entry in the
   #            database configuration settings.
   def self.environment=(setting)
      @@configuration[:environment] = setting
      Squixtures.load_database_configuration
   end

   # This method fetches the current environment setting for the Squixtures
   # module.
   def self.environment
      @@configuration[:environment]
   end

   # This method loads the database configuration details into the current
   # Squixtures configuration.
   def self.load_database_configuration
      log = LogJam.get_logger("squixtures")
      log.debug "Loading database configuration."
      success = @@configuration[:search_paths].find do |path|
         found     = false
         file_path = "#{path}/#{DEFAULT_DATABASE_CFG_FILE}"
         log.debug "Checking for the existence of #{file_path}."
         if File.exist?(file_path)
            begin
               log.debug "#{file_path} exists, attempting a load."
               settings    = YAML.load_file(file_path)
               environment = @@configuration[:environment]
               if settings.include?(environment)
                  @@configuration[:database] = settings[environment]
                  found = true
                  log.debug "Database configuration loaded from #{file_path}."
               else
                  log.warn "The #{file_path} database configuration does not contain a #{environment} entry."
               end
            rescue => error
               log.warn "Load of the #{file_path} database configuration file failed."
            end
         end
         found
      end

      if !success
         raise SquixtureError.new("Unable to locate a database configuration file.")
      end
   end
end
