require_relative 'vulcain'
require File.join(File.dirname(__FILE__), "strategies/rue_du_commerce")

User = Struct.new(:firstname, :lastname, :email, :address, :city, :postalcode, :birthday, :gender)
Account = Struct.new(:email, :password)
user = User.new("Mad", "Max", "madmax_1180@yopmail.com", "12 rue des Lilas", "Paris", "75002", Date.parse("1985-10-10"), 0)
account = Account.new("madmax_1180@yopmail.com", "shopelia")

# strategy = RueDuCommerce::ACCOUNT
# strategy.context = {user:user, password:"shopelia"}
# strategy.run
strategy = RueDuCommerce::LOGIN
strategy.context = {account:account}
strategy.run

