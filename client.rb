#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require 'json'

class Bot

  attr_accessor :name
  attr_accessor :x 
  attr_accessor :y

  def initialize(name)
    self.name = name
  end

  def current_status(json)
    puts " -- json #{json.inspect}"
    unless json['player'].nil?
      self.x = json['player']['x'].to_i
      self.y = json['player']['y'].to_i
    end
  end

  def command
    move = ['up', 'left', 'right', 'down'].sample
    { cmd: move }
  end
end

class Connection < EventMachine::Connection

  attr_accessor :bot

  def initialize(*args)
    super
    self.bot = Bot.new('jurgen')
    send_data({ name: bot.name }.to_json)
  end

  def receive_data(data)
    json = JSON.parse(data.strip)
    bot.current_status(json)

    send_data bot.command.to_json
  end
end

EventMachine.run do
  EventMachine.connect '127.0.0.1', 10000, Connection
end
