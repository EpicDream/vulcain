require_relative 'vulcain'
require File.join(File.dirname(__FILE__), "strategies/rue_du_commerce")

PRODUCT_URL = "http://m.rueducommerce.fr/fiche-produit/Galaxytab2-P5110-16Go-Blanc-OP"

User = Struct.new(:firstname, :lastname, :email, :address, :city, :postalcode, :birthday, :gender)
Account = Struct.new(:email, :password)
Order = Struct.new(:product_url, :card_number, :card_crypto, :expire_month, :expire_year)

user = User.new("Mad", "Max", "madmax_1191@yopmail.com", "12 rue des Lilas", "Paris", "75002", Date.parse("1985-10-10"), 0)
account = Account.new("madmax_1180@yopmail.com", "shopelia")
order = Order.new(PRODUCT_URL, "87989898", "345", "01", "16")
driver = Driver.new
context = {user:user, password:"shopelia", account:account, order:order}

#RueDuCommerce.new(driver, context).account.run
 RueDuCommerce.new(driver, context).login.run
 RueDuCommerce.new(driver, context).order.run

#driver.quit