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
  PROCESS_NAME = "vulcain.worker.sh"
  MESSAGES_VERBS = {:reload => 'reload'}
  ADMIN_MESSAGES_STATUSES = {
    started:'started', reloaded:'reloaded', abort:'abort', failure:'failure', terminate:'terminate'
  }
  
  def spawn_new_worker
    Worker.new(vid).start
  end
  
  def reload code
    path = File.join(File.dirname(__FILE__), 'strategies.rb')
    File.open(path, "w") { |f| f.write(code) }
    load path
  end
  
  def vid
    "#{CONFIG['host']}|#{Process.pid}"
  end
  
  extend self
end

require_relative 'amqp_runner'
require_relative 'worker'
require_relative 'exchangers'
require_relative 'state_machine'
