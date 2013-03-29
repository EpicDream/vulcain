# encoding: utf-8
require "rubygems"
require "amqp"
 
IP_DISPATCHER = "127.0.0.1"
VULCAIN_1_IP = "178.32.212.23"
VULCAIN_2_IP = "178.32.210.202"

AMQP.start(:host => IP_DISPATCHER, :username => "guest", :password => "guest") do |connection|
  # puts connection.inspect
  channel_vulcain_1 = AMQP::Channel.new(AMQP::Session.connect(:host => VULCAIN_1_IP, :username => "guest", :password => "guest"))
  channel_vulcain_2 = AMQP::Channel.new(AMQP::Session.connect(:host => VULCAIN_2_IP, :username => "guest", :password => "guest"))
  channel_dispatcher = AMQP::Channel.new(connection)
  
  channel_dispatcher.on_error do |ch, channel_close|
    puts "A channel_dispatcher-level exception: #{channel_close.inspect}"
  end
  channel_vulcain_1.on_error do |ch, channel_close|
    puts "A channel_vulcain_1-level exception: #{channel_close.inspect}"
  end
  channel_vulcain_2.on_error do |ch, channel_close|
    puts "A channel_vulcain_2-level exception: #{channel_close.inspect}"
  end

  exchange_dispatcher = channel_dispatcher.headers("amq.match", :durable => true)
  exchange_vulcain_1 = channel_vulcain_1.headers("amq.match", :durable => true)
  exchange_vulcain_2 = channel_vulcain_2.headers("amq.match", :durable => true)
  
  count_1 = 0
  count_2 = 0
  
  channel_dispatcher.queue.bind(exchange_dispatcher, :arguments => { 'x-match' => 'all', :dispatcher => "1"}).subscribe do |metadata, payload|
    puts "Dispatcher vulcain 1 received message : #{payload}" #voir #{metadata.inspect}
    exchange_vulcain_1.publish "Vulcain 1 commande moi ça stp #{count_1 += 1}",   :headers => { :vulcain => "1"}
  end
  
  channel_dispatcher.queue.bind(exchange_dispatcher, :arguments => { 'x-match' => 'all', :dispatcher => "2"}).subscribe do |metadata, payload|
    puts "Dispatcher vulcain 2 received message : #{payload}"
    exchange_vulcain_2.publish "Vulcain 2 commande moi ça stp #{count_2 += 1}",   :headers => { :vulcain => "2"}
  end

  exchange_vulcain_1.publish "Vulcain 1 commande moi ça stp 0",   :headers => { :vulcain => "1"}
  exchange_vulcain_2.publish "Vulcain 2 commande moi ça stp 0",   :headers => { :vulcain => "2"}

  show_stopper = Proc.new do
    $stdout.puts "Stopping..."
    connection.close {
      EventMachine.stop { exit }
    }
  end

  Signal.trap "INT", show_stopper
end
