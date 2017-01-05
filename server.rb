#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require 'json'
require 'terminal-table'

require __dir__ + '/lib/player'
require __dir__ + '/lib/game'

class Server

  attr_accessor :connections

  def initialize
    @connections = []
    @game = Game.new(10, 10)
  end

  def start
    @signature = EventMachine.start_server('0.0.0.0', 10000, Connection) do |con|
      con.server = self
      @connections << con
    end
  end

  def join(player, json, &block)

    if json['name'].nil?
      response = { error: "please provide your name" }
    else
      player.set_name(json['name'])
      @game.join(player)
      @game.start
      response = {success: true}
    end

    block.call response.to_json
  end

  def command(player, data)
    puts " received cmd from #{player.name} #{data.inspect}"
    @game.command player, data
  end

  def disconnect(connection)
    @game.leave(connection.player)
    connections.delete(connection)
  end

  def tick
    puts "\e[H\e[2J"
    puts " Clients: #{connections.size}"

    @game.tick
    @game.print_table

    @connections.each do |c|
      if c.player.has_name?
        c.send_data @game.status_for(c.player)
      end
    end
  end
end

class Connection < EventMachine::Connection
  attr_accessor :server
  attr_accessor :player

  def post_init
    @player = Player.new
  end

  def receive_data(data)
    json = JSON.parse(data.strip)

    if player.has_name?
      server.command player, json
    else
      server.join(player, json) do |resp|
        send_data resp
      end
    end
  rescue JSON::ParserError
    send_data 'invalid format ' + $!.to_s
  end

  def unbind
    server.disconnect(self)
  end
end

EventMachine::run {
  s = Server.new
  s.start
  puts "New server listening"
  EM.add_periodic_timer(1) do
    s.tick
  end
}
