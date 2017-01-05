class Player

  attr_accessor :x
  attr_accessor :y
  attr_accessor :name

  def initialize
    self.name = nil
  end

  def has_name?
    !name.nil? && name.length > 0
  end

  def set_name(name)
    self.name = name
  end
end
