# -*- encoding : utf-8 -*-
require "amqp"
require "json"
require "selenium-webdriver"
require "yaml"

module Vulcain
  DISPATCHER_VULCAINS_QUEUE = "vulcains-queue" #DO NOT CHANGE WITHOUT CHANGE ON VULCAIN-API
  LOGGING_QUEUE = "logging-queue" #DO NOT CHANGE WITHOUT CHANGE ON VULCAIN-API
  VULCAIN_QUEUE = lambda { |vulcain_id| "vulcain-#{vulcain_id}" }
  CONFIG = YAML.load_file File.join(File.dirname(__FILE__), '../../config/vulcain.yml')
  @@exchanger = nil
  
  def exchanger
    return @@exchanger if @@exchanger
    config = CONFIG['dispatcher']
    connection = AMQP::Session.connect(host:config['host'], username:config['user'], password:config['password'])
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
