require 'rubygems'
require 'squixtures'
require 'test/unit'
require 'stringio'
require 'yaml'

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

   private

   def clear_all_tables
      @connection[:order_products].delete
      @connection[:orders].delete
      @connection[:products].delete
      @connection[:categories].delete
      @connection[:users].delete
   end
end