# --window_width 800 --window_height 600

# DR GTK 1.14
# c0a19ce1fa25044fcf0289bcd6e6f1d64988075d


# I shouldn't be doing it like this but here we go again…
module Giatros
  module Initialize
    def initialize args_hash
      args_hash.each{|key, value|
        instance_variable_set("@#{key}", value)
      }
    end
  end
  
  module Serialize
    def serialize
      instance_variables.map{|key|
        [key.to_s[1..-1].to_sym, instance_variable_get(key)]
      }.to_h
    end
    
    def inspect
      serialize.to_s
    end
    
    def to_s
      serialize.to_s
    end
  end
  
  module Rectangle
    def w= arg
      @w = arg
      calc_diagonal
    end
    
    def h= arg
      @h = arg
      calc_diagonal
    end
    
    private
    
    def calc_diagonal
      # @diagonal = Math.sqrt(@w**2 + @h**2).ceil
      @diagonal = GTK::Geometry.distance({x: @x, y: @y}, {x: @x + @w, y: @y + @h}).ceil
    end
  end
  
  class SolidBorder
    include Initialize
    include Serialize
    include Rectangle
    
    attr_accessor :x, :y, :r, :g, :b, :a
    attr_reader :w, :h, :diagonal, :fill, :primitive_marker
    
    def initialize args_hash
      super
      @x ||= 0
      @y ||= 0
      @w ||= 50
      @h ||= 50
      @r ||= 255
      @g ||= 255
      @b ||= 255
      @a ||= 255
      @fill ||= false
      calc_diagonal
      calc_primitive_marker
    end
    
    def fill= arg
      @fill = arg
      calc_primitive_marker
    end
    
    private
    
    def calc_primitive_marker
      @primitive_marker = @fill ? :solid : :border
    end
  end
end

include Giatros

def tick args
  args.state.tick_count == 1 && while true; end
  if args.state.tick_count == 0
    $state = {
      solids: {},
      borders: {},
      sprites: {},
      RTs: {},
      mouse: {},
      labels: {},
      timing: {},
      subject: {}
    }
    args.state.mundane = $state
    
    $state[:solids][:leftSquare] = SolidBorder.new({
      fill: true,
      w: args.grid.w / 10,
      h: args.grid.h / 10,
      x: args.grid.w / 3,
      y: args.grid.center.y,
      r: 255,
      g: 0,
      b: 0,
    })
    $state[:solids][:rightSquare] = $state[:solids][:leftSquare].dup
    $state[:solids][:rightSquare].x = 2 * args.grid.w / 3
    
    $state[:sprites][:rightSquare] = {
      w: args.grid.w,
      h: args.grid.h,
      path: :rt_rightSquare
    }
  $state[:labels][:tick_count] = {
    x: args.grid.center.x,
    y: args.grid.center.y,
    text: args.state.tick_count,
  }
  end
  $state[:RTs][:rightSquare] = args.render_target :rt_rightSquare
  
  $state[:RTs][:rightSquare].primitives << $state[:solids][:rightSquare]
  
  $state[:labels][:tick_count][:text] = args.state.tick_count
  
  args.outputs.primitives << $state[:solids][:leftSquare]
  args.outputs.sprites << $state[:sprites][:rightSquare]
  args.outputs.labels << $state[:labels][:tick_count]
end
