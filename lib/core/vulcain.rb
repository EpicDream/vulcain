# -*- encoding : utf-8 -*-
require "amqp"
require "json"
require "headless"
require "selenium-webdriver"

headless = Headless.new
headless.start

module Vulcain
  DISPATCHER_HOST = "127.0.0.1"
  DISPATCHER_USER = "guest"
  DISPATCHER_PASSWORD = "guest"
  DISPATCHER_VULCAINS_QUEUE = "vulcains-queue" #DO NOT CHANGE WITHOUT CHANGE ON VULCAIN-API
  USER = "guest"
  PASSWORD = "guest"
  HOST = "127.0.0.1"
  
  @@exchanger = nil
  
  def exchanger
    return @@exchanger if @@exchanger
    connection = AMQP::Session.connect(host:DISPATCHER_HOST, username:DISPATCHER_USER, password:DISPATCHER_PASSWORD)
    channel = AMQP::Channel.new(connection)
    channel.on_error do |channel, channel_close|
      raise "Can't open channel to dispatcher MQ on #{DISPATCHER_HOST}"
    end
    @@exchanger = channel.headers("amq.match", :durable => true)
  end
  
  def mount_exchanger
    exchanger
  end
  
  def spawn_new_worker id
    Worker.new(id).start
  end
  
  def reload code
    path = File.join(File.dirname(__FILE__), 'strategies.rb')
    File.open(path, "w") { |f| f.write(code) }
    load path
  end
  
  extend self
end

require_relative 'amqp_runner'
require_relative 'worker'
require_relative 'exchangers'
require_relative 'state_machine'

Vulcain.spawn_new_worker("1")