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
  PROCESS_NAME = "vulcain.worker.sh"
  
  @@exchanger = nil

  def exchanger
    return @@exchanger if @@exchanger
    connection = AMQP::Session.connect(configuration)
    channel = AMQP::Channel.new(connection)
    channel.on_error(&channel_error_handler)
    @@exchanger = channel.headers("amq.match", :durable => true)
  end
  
  def mount_exchanger
    exchanger
  end
  
  def spawn_new_worker
    Worker.new(next_vulcain_id).start
  end
  
  def reload code
    path = File.join(File.dirname(__FILE__), 'strategies.rb')
    File.open(path, "w") { |f| f.write(code) }
    load path
  end
  
  def next_vulcain_id
    "#{CONFIG['host']}-#{Process.pid}"
  end
  
  def configuration
    config = CONFIG['dispatcher']
    { host:config['host'], username:config['user'], password:config['password'] }
  end
  
  def channel_error_handler
    Proc.new do |channel, channel_close|
      raise "Can't open channel to dispatcher MQ on #{CONFIG['dispatcher']['host']}"
    end
  end
  
  extend self
end

require_relative 'amqp_runner'
require_relative 'worker'
require_relative 'exchangers'
require_relative 'state_machine'
