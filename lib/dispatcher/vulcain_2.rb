# encoding: utf-8
require "rubygems"
require "amqp"
require File.join(File.dirname(__FILE__), "../core/vulcain")
require File.join(File.dirname(__FILE__), "../core/strategies/rue_du_commerce/rue_du_commerce")
USER_ACCOUNT_PASSWORD = "shopelia2013"
User = Struct.new(:firstname, :lastname, :email, :address, :city, :postalcode, :birthday, :gender, :telephone)
Order = Struct.new(:product_url, :card_number, :card_crypto, :expire_month, :expire_year, :holder, :account_password)


IP_DISPATCHER = "176.31.231.202"

AMQP.start(:host => "127.0.0.1", :username => "guest", :password => "guest") do |connection|
  channel_dispatcher = AMQP::Channel.new(AMQP::Session.connect(:host => IP_DISPATCHER, :username => "guest", :password => "guest"))
  channel_dispatcher.on_error do |ch, channel_close|
    puts "A channel_dispatcher-level exception: #{channel_close.inspect}"
  end
  exchange_dispatcher = channel_dispatcher.headers("amq.match", :durable => true)

  channel = AMQP::Channel.new(connection)
  
  channel.on_error do |ch, channel_close|
    puts "A channel_dispatcher-level exception: #{channel_close.inspect}"
  end
  exchange = channel.headers("amq.match", :durable => true)


  channel.queue.bind(exchange, :arguments => { 'x-match' => 'all', :vulcain => "2"}).subscribe do |metadata, payload|
    puts "Vulcain 2 received message : #{payload}" #voir #{metadata.inspect}
    user = User.new("Mad", "Max", "alfred01@yopmail.com", "12 rue des Lilas", "Paris", "75019", Date.parse("1985-10-01"), 0, "0650151515")
    driver = Driver.new
    order = Order.new("http://musique.fnac.com/a5549347/Jean-Louis-Murat-Toboggan-Edition-limitee-CD-album#bl=MUVari%c3%a9t%c3%a9-fran%c3%a7aiseBLO2", "87989898", "345", "01", "2016", "ROGER RABBIT", USER_ACCOUNT_PASSWORD)
    context = {user:user, order:order, driver:driver}
    # Fnac.new(driver, context).account.run
    Fnac.new(driver, context).login.run
    # Fnac.new(driver, context).order.run

    
    exchange_dispatcher.publish "Cher dispatcher Vulcain 2 s'est loggé à FNAC",  :headers => { :dispatcher => "2"}
  end

  show_stopper = Proc.new do
    $stdout.puts "Stopping..."
    connection.close {
      EventMachine.stop { exit }
    }
  end

  Signal.trap "INT", show_stopper
end
