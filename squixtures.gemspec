# -*- encoding: utf-8 -*-
require File.expand_path('../lib/squixtures/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Peter Wood"]
  gem.email         = ["ruby@blacknorth.com"]
  gem.description   = %q{Squixtures is a library that provides a data fixtures facility ala the fixtures typically used in unit tests. The library makes use of the Sequel library to provide a degree of database independence (needs more work) and use the LogJam library to unify logging output.}
  gem.summary       = %q{Simple fixtures functionality.}
  gem.homepage      = ""

  gem.add_dependency('sequel', '>= 3.36.1')
  gem.add_dependency('logjam', '>= 0.0.3')

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "squixtures"
  gem.require_paths = ["lib"]
  gem.version       = Squixtures::VERSION
end
