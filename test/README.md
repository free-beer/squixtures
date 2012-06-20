# Squixtures Test
This directory contains files used in testing the Squixtures library. The
process of preparing for and running these tests is outlined below.

## Preparing The Test Database
The test files expect that a test database will have been created before they
are run. To assist in this process the details needed to create the test
database have been encapsulated into a set of Sequel migrations that are stored
in the db/migrations sudirectory of the test folder. To create the database for
testing the library with SQLite3 you would use a command such as the following
to create the test database...

    $> sequel -m db/migrations sqlite://db/squixtures.db

The command given above assumes that it is being executed from the test folder
with the main project folder. This will create a new database file in a file
called squixtures.db in the db subdirectory. To create the test database for
Postgres is a little more convoluted but would following a series of commands
such as the following...

    $> createdb -E UTF-8 -U postgres squixtures
    $> sequel -m db/migrations postgres://postgres:password@localhost:5432/squixtures

The second command assumes that the password for the postgres user is password,
alter this as necessary. To roll a migration back completely you can use a
command such as...

    $> sequel -m db/migrations postgres://postgres:password@localhost:5432/squixtures -M 0

## Executing A Test
All of the tests are stored as Ruby source files within the test subdirectory
of the main project folder. To execute any of the tests you would use a command
such as the following...

    $> ruby -I../lib squixtures_include_tests.rb

Again, it is assumed this command is executed from within the test folder. The
command specifies an include path to the squixtures lib folder which allows for
execution of the tests without the library actually being installed. If you have
the library installed and simply want to execute the tests then drop the '-I'
parameter from the command.
