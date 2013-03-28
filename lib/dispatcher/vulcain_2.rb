# encoding: utf-8
require "rubygems"
require "amqp"
 
AMQP.start(:host => "127.0.0.1", :username => "guest", :password => "guest") do |connection|
  channel   = AMQP::Channel.new(connection)
  
  channel.on_error do |ch, channel_close|
    puts "A channel-level exception: #{channel_close.inspect}"
  end

  exchange = channel.headers("amq.match", :durable => true)

  channel.queue.bind(exchange, :arguments => { 'x-match' => 'all', :vulcain => "2"}).subscribe do |metadata, payload|
    puts "Vulcain 2 received message : #{payload}" #voir #{metadata.inspect}
    EM.add_timer(2) do
      exchange.publish "Cher dispatcher Vulcain 2 a commandé",   :headers => { :dispatcher => "2"}
    end
  end

  show_stopper = Proc.new do
    $stdout.puts "Stopping..."
    connection.close {
      EventMachine.stop { exit }
    }
  end

  Signal.trap "INT", show_stopper
end
