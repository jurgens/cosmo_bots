class Game

  attr_accessor :status
  attr_accessor :players
  attr_accessor :commands
  attr_accessor :current_table
  attr_accessor :new_table

  def initialize(x, y)
    @x = x
    @y = y
    @players = []
    @status = 'stopped'
    @commands = []
  end

  def join(player)
    players << initialize_player(player)
  end

  def initialize_player(player)
    player.x = rand(@x)
    player.y = rand(@y)

    player
  end

  def leave(player)
    self.players.delete(player)
  end

  def start
    self.status = 'started'
  end

  def tick
    return unless @status == 'started'

    puts " priocess commands"
    @commands.each do |c|
      player, cmd = c
      case cmd 
      when 'up'
        player.y = player.y + 1
      when 'down'
        player.y = player.y - 1
      when 'left'
        player.x = player.x - 1
      when 'right'
        player.x = player.x + 1
      else
        # do nothing
      end
      puts " --- new player status #{player.inspect}"
    end
    self.commands = []
  end

  def command(player, data)
    if players.include?(player)
      @commands.delete_if{ |e| e[0] == player } # delete previous 
      @commands << [player, data]
    else
      raise 'hacking attempt?'  
    end
  end

  def status_for(player)
    { player: {name: player.name, x: player.x, y: player.y} }.to_json
  end

  def print_table
    puts Terminal::Table.new rows: table_to_render(build_table)
  end

  def table_to_render(table)
    table_to_render = table.dup
    (0..@x).each do |x|
      (0..@y).each do |y|
        table_to_render[x][y] = table_to_render[x][y].nil? ? '.' : '@'
      end
    end
    table_to_render
  end

  def build_table
    table = []

    (0..@x).each do |x|
      (0..@y).each do |y|
        table[x] ||= []
        table[x][y] = nil
      end
    end

    players.each do |p|
      table[p.x][p.y] = p
    end

    table
  end
end
