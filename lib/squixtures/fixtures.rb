#! /usr/bin/env ruby
# Copyright (c), 2012 Peter Wood

module Squixtures
	# This module is intended for inclusion into other classes to enable them
	# with fixture functionality.
	module Fixtures
		# This method is really just a wrapper around the Suxtures::fixtures
		# method.
		#
		# === Parameters
		# names::  The name of the fixtures to be loaded.
		def fixtures(*names)
			Squixtures.fixtures(*names)
		end
	end
end