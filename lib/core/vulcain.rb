# -*- encoding : utf-8 -*-
# /!\ DO NOT CHANGE QUEUES NAMES WITHOUT CHANGE ON VULCAIN API

require "amqp"
require "json"
require "selenium-webdriver"
require "yaml"

module Vulcain
  DISPATCHER_VULCAINS_QUEUE = "vulcains-queue"
  LOGGING_QUEUE = "logging-queue"
  ADMIN_QUEUE = "admin-queue"
  VULCAIN_QUEUE = lambda { |vulcain_id| "vulcain-#{vulcain_id}" }
  CONFIG = YAML.load_file File.join(File.dirname(__FILE__), '../../config/vulcain.yml')
  PING_INTERVAL = 30
  
  def spawn_new_worker
    Worker.new(vid).start
  end
  
  def reload code
    path = File.join(File.dirname(__FILE__), 'robots.rb')
    File.open(path, "w") { |f| f.write(code) }
    sleep(0.5)
    load path
  end
  
  def vid
    "#{CONFIG['host']}|#{Process.pid}"
  end
  
  def messager=messager
    @@messager = messager
  end
  
  def messager
    @@messager
  end
  
  def robot=robot
    @@robot = robot
  end
  
  def robot
    @@robot
  end
  
  def killed=status
    @@killed = status
  end
  
  def killed?
    defined?(@@killed) && @@killed
  end
  
  extend self
end

require_relative 'amqp_runner'
require_relative 'worker'
require_relative 'exchangers'
require_relative 'state_machine'
require_relative 'messager'
