# Squixtures

Squixtures is a library that provides a simple data fixtures facility, ala
the fixtures generally used in unit tests. The library came abut because it
is quite difficult to make use of Rails fixtures outside of the Rails
framework itself.

The Squixtures library makes use of the Sequel library in an attempt to
attain database independence. At the moment it has only been coded for and
tested with SQLite3 and Postgres. Squixtures also makes use of the LogJam
library to centralize it's logging.

## Installation

Add this line to your application's Gemfile:

    gem 'squixtures'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install squixtures

## Usage

Squixtures is a library so the first thing to do is to incorporated it
into the file where you plan to use it. This can be done with a simple
require such as the following...

    require 'rubygems'
    require 'squixtures'

Squixtures is based around amodule so how you deploy it will depend heavily
on how you want to use it. If, for example, you only want to deploy fixtures
once, when a class definition is loaded, you can use the extend statement
to incorporate the functionality at the class level and then invoke the
fixtures you want. For example...

    class MyClass
        # Extend the class with Squixtures functionality.
        extend Squixtures::Fixtures

        # Load the fixtures required.
        fixtures :users, :accounts, :orders
    end

Alternatively, if you want the fixtures reloaded regularly, say as part of
the set up process for a unit test, you would include the squixtures
functionality like this...

    class TestMyClass
        # Incorporate the Squixtures functionality.
        include Squixtures::Fixtures

        def setup
            # Load the desired fixtures.
            fixtures :users, :accounts, :orders
        end
    end

By default the Squixtures fixture loader empties the target table between
fixture loads. This feature is configurable but you should be aware of it
as it could cause data loss. Squixtures currently only recognises YAML
style fixtures which, as an example, follow this format...

    one:
        id: 1
        email: jsmith@blah.com
        password: password
        status: 1
        created_at: <%= Time.now %>
        updated_at: <%= Time.now %>

A file containing this would define a single record made up of 6 fields.
The first line specifies the record name and isn't really relevant except
in that it must be unique within the file that defines it. Note that the
fixture files are run through ERB as part of the load process so it's
possible to include simple Ruby statements into the definitions. In the
example above Ruby code is used to generate values for the created_at
and updated_at field values.

## Platform Independence
The Sequel library has been used in minimize the amount of RDBMS specific code
exists in the library. Unfortunately, it's impossible to be complete free of
such considerations. There are two main areas where the underlying database
system impinges on the code...

    * Database connections. The Sequel library requires a URL like string to
      obtain a database connection. The form and content of this string are
      very much dictated by the underlying database.

    * Referential integrity. Database systems which enforce strict referential
      integrity can make the injection of fixtures more difficult, especially
      in the case where the data model has circular references. This can, in
      part, be avoided by proper ordering of the fixtures load. This is not
      a complete solution however and the Squixtures library takes steps to
      deactivate relational integrity temporarily where this will alleviate
      the issue. Unfortunately the facilities for doing this are very much
      specific to the database.

At the moment the Squixtures library only supports (i.e. has been tested with)
the SQLite3 and Postgres databases. Adding support for additional databases
would require that the library be extended to accommodate the specified database
in the areas detailed above.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
