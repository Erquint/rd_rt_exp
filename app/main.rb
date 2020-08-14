# --window_width 800 --window_height 600

class GTK::Console
  def render_help args, top
  end
end

class SizedArray
  include Enumerable
  
  attr_reader :limit
  
  def initialize limit = 60, size = 0, default = nil
    raise 'Argument `size` cannot be greater than `limit`!' if
      size > limit
    @limit = limit
    @array = Array.new size, default
  end
  
  def []= *args
    @array.[]= *args
  end
  
  def [] *args
    @array.[] *args
  end
  
  def to_s *args
    @array.to_s *args
  end
  
  def size
    @array.size
  end
  
  def each &block
    @array.each &block
  end
  
  def limit= limit
    @limit = limit
    limit!
  end
  
  def push *obj
    @array.push *obj
    limit!
  end
  
  def << obj
    @array << obj
    limit!
  end
  
  def median
    return 0 if self.size < 1
    return self[0] if self.size == 1
    sorted = sort
    middleFloor = (self.size - 1) / 2
    output = sorted[middleFloor]
    output = (output + sorted[middleFloor + 1]) / 2.0 if
      self.size.even?
    output
  end
  
  private
  
  def limit!
    offset = self.size - @limit
    offset.times do @array.shift end
    @array
  end
end

def center input, args
  output = input.dup
  center! output, args
  output
end

def center! input, args
  input[:x] = args.grid.center.x - input[:w] / 2
  input[:y] = args.grid.center.y - input[:h] / 2
  true
end

def scale input, function
  output = input.dup
  scale! output, function
  output
end

def scale! input, function
  center = {# Getting current center.
    x: input[:x] + input[:w] / 2,
    y: input[:y] + input[:h] / 2
  }
  # Getting current diagonal…
  diagonal = Math.sqrt(input[:w]**2 + input[:h]**2)
  # …and quotient.
  quotient = input[:w] / input[:h]
  # Designating the new diagonal.
  diagonal = function.call diagonal
  # Prevent disappearing.
  diagonal = 1 if diagonal < 1
  # Fitting width for new diagonal…
  input[:w] = diagonal * quotient /
    Math.sqrt(quotient**2 + 1)
  # …and height with respect to quotient.
  input[:h] = diagonal            /
    Math.sqrt(quotient**2 + 1)
  # Recentering…
  input[:x] = center[:x] - input[:w] / 2
  # …on both axes.
  input[:y] = center[:y] - input[:h] / 2
  true
end

def tick args
  if args.state.tick_count == 1
    $state = {
      solids: {},
      sprites: {},
      borders: {},
      RTs: {},
      mouse: {},
      labels: {},
      toggles: {},
      timing: {},
      subject: {},
      angleΔ: 45
    }
    
    $state[:solids][:square] = {
    x: 0,
    y: 0,
    w: 500,
    h: 500,
    r: 255,
    g: 255,
    b: 255,
    a: 255
    }
    
    $state[:RTs][:square] = args.render_target :rt_square
    $state[:RTs][:square].width = $state[:solids][:square][:w]
    $state[:RTs][:square].height = $state[:solids][:square][:h]
    $state[:RTs][:square].solids << $state[:solids][:square]
    
    $state[:sprites][:square] = {
      x: 0,
      y: 0,
      w: $state[:solids][:square][:w],
      h: $state[:solids][:square][:h],
      path: :rt_square,
      angle: 0,
      r: 255,
      g: 255,
      b: 255,
      a: 255,
      angle_anchor_x: 0.5,
      angle_anchor_y: 0.5,
      source_x: 0,
      source_y: 0,
      source_w: $state[:solids][:square][:w],
      source_h: $state[:solids][:square][:h]
    }
    
    $state[:sprites][:square][:diagonal] = Math.sqrt(
      $state[:sprites][:square][:w]**2 +
      $state[:sprites][:square][:h]**2
    ).ceil
    # Needs generalizing.
    
    $state[:RTs][:circle] = args.render_target :rt_circle
    $state[:RTs][:circle].width =
      $state[:sprites][:square][:diagonal]
    $state[:RTs][:circle].height =
      $state[:sprites][:square][:diagonal]
    
    # square = center $state[:sprites][:square], args
    # Note: `center` dupes!
    square = $state[:sprites][:square].dup
    square[:x] = $state[:RTs][:circle].width / 2 - square[:w] / 2
    square[:y] = $state[:RTs][:circle].height / 2 - square[:h] / 2
    # There's got to be a better way!
    
    square[:r] = 255
    square[:g] = 0
    square[:b] = 0
    fine = 10
    (90 * fine).times do |i|
      square = square.dup
      square[:angle] += 1 / fine
      $state[:RTs][:circle].sprites << square
    end
    
=begin
    puts $state[:RTs][:circle].sprites
    square = center $state[:sprites][:square], args
    scale! square, lambda {|size| size - 200}
    (90 * fine).times do |i|
      square = square.dup
      square[:angle] += 1 / fine
      $state[:RTs][:circle].sprites << square
    end
=end
    
    $state[:sprites][:circle] = {
      x: 0,
      y: 0,
      w: $state[:sprites][:square][:diagonal],
      h: $state[:sprites][:square][:diagonal],
      path: :rt_circle,
      angle: 0,
      r: 255,
      g: 255,
      b: 255,
      a: 255,
      angle_anchor_x: 0.5,
      angle_anchor_y: 0.5,
      source_x: 0,
      source_y: 0,
      source_w: $state[:sprites][:square][:diagonal],
      source_h: $state[:sprites][:square][:diagonal]
    }
    
    $state[:borders][:reclangle] = {
    x: 0,
    y: 0,
    w: 800,
    h: 600,
    r: 255,
    g: 0,
    b: 0,
    a: 255
    }
    
    $state[:RTs][:canvas] = args.render_target :rt_canvas
    $state[:RTs][:canvas].width = $state[:borders][:reclangle][:w]
    $state[:RTs][:canvas].height = $state[:borders][:reclangle][:h]
    
    center! $state[:sprites][:circle], args
    
    $state[:labels][:whee] = {
      x: 20,
      y: args.grid.top - 10,
      text: "[R] for WHEE",
    }
    
    $state[:labels][:frametime] = {
      x: 20,
      y: args.grid.top - 30,
      text: '',
    }
    
    $state[:subject] = $state[:sprites][:circle]
    
    center! $state[:subject], args
    $state[:timing][:time] = Time.now
    $state[:timing][:frametimes] = SizedArray.new
    
  end
  if args.state.tick_count > 0
    # For sake of debugging an issue related to this condition:
    # Mode 1: `if args.state.tick_count > 0`
    # Mode 2: `if args.state.tick_count > 1`
    
    $state[:timing][:frametimes] <<
      Time.now - $state[:timing][:time]
    $state[:timing][:time] = Time.now
    mdn = $state[:timing][:frametimes].median
    $state[:labels][:frametime][:text] =
      "T/F: %.0f mspf" % (mdn * 1000)
    
    $state[:mouse][:held] = true if args.inputs.mouse.down
    $state[:mouse][:held] = false if args.inputs.mouse.up
    
    if $state[:mouse][:held]
      $state[:subject][:x] +=
        args.inputs.mouse.point.x - $state[:mouse][:x]
      $state[:subject][:y] +=
        args.inputs.mouse.point.y - $state[:mouse][:y]
    end
    
    $state[:mouse][:x] = args.inputs.mouse.point.x
    $state[:mouse][:y] = args.inputs.mouse.point.y
    
    case args.inputs.mouse.wheel&.y&.positive?
    when true
      scale! $state[:subject], lambda {|size| size + 50}
    when false
      scale! $state[:subject], lambda {|size| size - 50}
    end
    
    if args.inputs.keyboard.key_down.r
      $state[:toggles][:whee] = !$state[:toggles][:whee]
    end
    
    if $state[:toggles][:whee]
      $state[:angleΔ] += 0.1
      $state[:subject][:angle] += $state[:angleΔ]
    end
    
    if args.inputs.keyboard.key_down.zero
      puts $state.to_s + "\n\n"
    end
    
    # $state[:RTs][:canvas].clear
    
    # Some animation debug code.
    $state[:sprites][:circle][:x] =
      args.state.tick_count % ($state[:borders][:reclangle][:w] / 2)
    $state[:sprites][:circle][:y] =
      args.state.tick_count % ($state[:borders][:reclangle][:h] / 2)
    tempDebugLabel = {
      x: args.grid.center.x - 150,
      y: args.grid.center.y,
      text: "Circle's coordinates: %.0f, %.0f" %
        [$state[:sprites][:circle][:x], $state[:sprites][:circle][:y]],
    }
    args.outputs.labels << tempDebugLabel
    
    $state[:RTs][:canvas].sprites << $state[:sprites][:circle]
    $state[:RTs][:canvas].borders << $state[:borders][:reclangle]
=begin
    if args.state.tick_count < 10
      puts args.state.tick_count
      puts $state[:RTs][:canvas].sprites[0][:x]
      puts $state[:RTs][:canvas].sprites[0][:y]
    end
=end
    
    $state[:sprites][:canvas] = {
      x: 0,
      y: 0,
      w: $state[:borders][:reclangle][:w],
      h: $state[:borders][:reclangle][:h],
      path: :rt_canvas,
      angle: 0,
      r: 255,
      g: 255,
      b: 255,
      a: 255,
      angle_anchor_x: 0.5,
      angle_anchor_y: 0.5,
      source_x: 0,
      source_y: 0,
      source_w: $state[:borders][:reclangle][:w],
      source_h: $state[:borders][:reclangle][:h]
    }
    # This `puts` shows sprites heaping but not getting rasterized…
    puts $state[:RTs][:canvas].sprites if args.state.tick_count < 10
    
    args.outputs.sprites << $state[:sprites][:canvas]
    args.outputs.labels << $state[:labels][:whee]
    args.outputs.labels << $state[:labels][:frametime]
=begin
    $state[:subject][:x] = 0
    $state[:subject][:x] =
      args.state.tick_count % ($state[:borders][:reclangle][:w])
    $state[:subject][:w] = $state[:sprites][:canvas][:w]
    $state[:subject][:y] = 0
    $state[:subject][:h] = $state[:sprites][:canvas][:h]
    args.outputs.primitives << $state[:subject]
=end
  end
end
