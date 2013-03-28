# encoding: utf-8
require "rubygems"
require "amqp"
 
AMQP.start(:host => "127.0.0.1", :username => "guest", :password => "guest") do |connection|
  # puts connection.inspect
  puts AMQP::Session.connect(:host => "178.32.212.201", :username => "guest", :password => "guest").inspect
  channel = AMQP::Channel.new(connection)
  
  channel.on_error do |ch, channel_close|
    puts "A channel-level exception: #{channel_close.inspect}"
  end

  exchange = channel.headers("amq.match", :durable => true)
  
  count_1 = 0
  count_2 = 0
  
  channel.queue.bind(exchange, :arguments => { 'x-match' => 'all', :dispatcher => "1"}).subscribe do |metadata, payload|
    puts "Dispatcher vulcain 1 received message : #{payload}" #voir #{metadata.inspect}
    exchange.publish "Vulcain 1 commande moi ça stp #{count_1 += 1}",   :headers => { :vulcain => "1"}
  end
  
  channel.queue.bind(exchange, :arguments => { 'x-match' => 'all', :dispatcher => "2"}).subscribe do |metadata, payload|
    puts "Dispatcher vulcain 2 received message : #{payload}"
    exchange.publish "Vulcain 2 commande moi ça stp #{count_2 += 1}",   :headers => { :vulcain => "2"}
  end

  exchange.publish "Vulcain 1 commande moi ça stp 0",   :headers => { :vulcain => "1"}
  exchange.publish "Vulcain 2 commande moi ça stp 0",   :headers => { :vulcain => "2"}

  show_stopper = Proc.new do
    $stdout.puts "Stopping..."
    connection.close {
      EventMachine.stop { exit }
    }
  end

  Signal.trap "INT", show_stopper
end

puts "here"
