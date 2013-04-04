# -*- encoding : utf-8 -*-
require "selenium-webdriver"
require "amqp"
require "json"

module Vulcain
  DISPATCHER_HOST = "127.0.0.1"
  DISPATCHER_USER = "guest"
  DISPATCHER_PASSWORD = "guest"
  DISPATCHER_VULCAINS_QUEUE = "vulcains-queue"
  USER = "guest"
  PASSWORD = "guest"
  HOST = "127.0.0.1"
  
  @@dispatcher = nil
  @@required_strategies = []
  
  def dispatcher
    return @@dispatcher if @@dispatcher
    connection = AMQP::Session.connect(host:DISPATCHER_HOST, username:DISPATCHER_USER, password:DISPATCHER_PASSWORD)
    channel = AMQP::Channel.new(connection)
    channel.on_error do |channel, channel_close|
      raise "Can't open channel to dispatcher MQ on #{DISPATCHER_HOST}"
    end
    exchange = channel.headers("amq.match", :durable => true)
  end
  
  def spawn_new_worker id
    Worker.new(id).start
  end
  
  def load code
    File.open(File.join(File.dirname(__FILE__), 'strategies.rb'), "w") { |f| f.write(code) }
    require_relative 'strategies'
  end
  
  extend self
end

require_relative 'amqp_runner'
require_relative 'worker'

Vulcain.spawn_new_worker("1")