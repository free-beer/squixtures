require 'rubygems'
require 'squixtures'
require 'test/unit'
require 'stringio'
require 'turn'
require 'yaml'

LogJam.configure({:loggers => [{:default => true,
                                :file    => "sqixtures.log",
                                :level   => "DEBUG",
                                :name    => "main"}]})

class TestSquixturesInclude < Test::Unit::TestCase
   include Squixtures::Fixtures

   def setup
      settings = YAML.load_file("./config/database.yml")
      url      = Squixtures.get_connection_url(settings['test'])
      @connection = Sequel.connect(url)
      clear_all_tables
   end

   def teardown
      @connection.disconnect
   end

   def test_single_fixture_load
      fixtures :users

      users = @connection[:users]
      assert_equal(3, users.all.count)

      user = users[:id => 1]
      assert(!user.nil?)
      assert_equal("jsmith@blah.com", user[:email])
      assert_equal("password", user[:passwd])
      assert_equal(1, user[:status])
      assert(!user[:created].nil?)
      assert(user[:updated].nil?)

      user = users[:id => 2]
      assert(!user.nil?)
      assert_equal("joe.bloggs@lalala.org", user[:email])
      assert_equal("blurgh", user[:passwd])
      assert_equal(1, user[:status])
      assert(!user[:created].nil?)
      assert(user[:updated].nil?)

      user = users[:id => 3]
      assert(!user.nil?)
      assert_equal("a.stanton@good.bad.ugly.com", user[:email])
      assert_equal("heyhey!", user[:passwd])
      assert_equal(-1, user[:status])
      assert(!user[:created].nil?)
      assert(!user[:updated].nil?)
      assert(user[:created] != user[:updated])
   end

   def test_all_fixtures_load
      fixtures :all

      users = @connection[:users]
      assert_equal(3, users.all.count)

      categories = @connection[:categories]
      assert_equal(4, categories.all.count)

      products = @connection[:products]
      assert_equal(4, products.all.count)

      orders = @connection[:orders]
      assert_equal(3, orders.all.count)

      order_products = @connection[:order_products]
      assert_equal(5, order_products.all.count)
   end

   def test_with_clear_tables_off
      users = @connection[:users]
      users.insert(:id      => 1000,
                   :email   => 'fblack@outthere.com',
                   :passwd  => 'obscure',
                   :status  => 1,
                   :created => Time.now)

      Squixtures.configuration[:clear_tables] = false
      fixtures :users

      assert_equal(4, users.all.count)

      user = users[:id => 1000]
      assert(!user.nil?)
      Squixtures.configuration[:clear_tables] = true
   end

   def test_loading_from_alternative_fixtures_dir
      Squixtures.fixtures_dir = "#{Dir.getwd}/test/fixtures/alternative"
      fixtures :users

      users = @connection[:users]
      assert_equal(2, users.all.count)

      user = users[:id => 10]
      assert(!user.nil?)

      user = users[:id => 11]
      assert(!user.nil?)
      Squixtures.fixtures_dir = nil
   end

   def test_transactional_load_with_failure
      Squixtures.fixtures_dir  = "#{Dir.getwd}/test/fixtures/alternative"
      Squixtures.transactional = true

      # Should fail on second fixture but load first without issue.
      assert_raise(Squixtures::SquixtureError) do
         fixtures :users, :categories
      end

      users = @connection[:users]
      assert_equal(2, users.all.count)

      categories = @connection[:categories]
      assert_equal(0, categories.all.count)

      Squixtures.transactional = false
      Squixtures.fixtures_dir  = nil
   end

   private

   def clear_all_tables
      @connection[:order_products].delete
      @connection[:orders].delete
      @connection[:products].delete
      @connection[:categories].delete
      @connection[:users].delete
   end
end