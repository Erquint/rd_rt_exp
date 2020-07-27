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
  output[:x] = args.grid.center.x - input[:w] / 2
  output[:y] = args.grid.center.y - input[:h] / 2
  output
end

def center! input, args
  input[:x] = args.grid.center.x - input[:w] / 2
  input[:y] = args.grid.center.y - input[:h] / 2
  true
end

def scale input, function
  output = input.dup
  center = {
    x: output[:x] + output[:w] / 2,
    y: output[:y] + output[:h] / 2
  }
  output[:w] = function.call(output[:w])
  output[:h] = function.call(output[:h])
  output[:x] = center[:x] - output[:w] / 2
  output[:y] = center[:y] - output[:h] / 2
  output
end

def scale! input, function
  center = {# Getting current center.
    x: input[:x] + input[:w] / 2,
    y: input[:y] + input[:h] / 2
  }
  diagonal = input[:w]**2 + input[:h]**2 # Getting current diagonal…
  quotient = input[:w] / input[:h] # …and quotient.
  diagonal = function.call(diagonal) # Designating the new diagonal.
  diagonal = 1 if diagonal < 1 # Prevent disappearing.
  input[:w] = Math.sqrt(diagonal) * quotient /
    Math.sqrt(quotient**2 + 1) # Fitting width for new diagonal…
  input[:h] = Math.sqrt(diagonal)            /
    Math.sqrt(quotient**2 + 1) # …and height with respect to quitient.
  input[:x] = center[:x] - input[:w] / 2 # Recentering…
  input[:y] = center[:y] - input[:h] / 2 # …on both axes.
  true
end

def tick args
  if args.state.tick_count == 0
    $state = {
      solids: {},
      sprites: {},
      RTs: {},
      mouse: {},
      labels: {},
      toggles: {},
      timing: {},
      angleΔ: 45
    }
    
    $state[:solids][:square] = {
    x: 0,
    y: 0,
    w: 1280,
    h: 720,
    r: 255,
    g: 0,
    b: 0,
    a: 255
    }
    
    $state[:RTs][:circle] = args.render_target :rt_circle
    $state[:RTs][:circle].solids << $state[:solids][:square]
    $state[:RTs][:circle].width = 1280
    $state[:RTs][:circle].height = 720
    
    $state[:sprites][:circle] = {
      x: 0,
      y: 0,
      w: 1280,
      h: 720,
      path: :rt_circle,
      angle: 0,
      r: 128,
      g: 128,
      b: 128,
      a: 128,
      flip_vertically: false,
      flip_horizontally: false,
      angle_anchor_x: 0.5,
      angle_anchor_y: 0.5,
      source_x: 0,
      source_y: 0,
      source_w: 1280,
      source_h: 720
    }
    
    $state[:labels][:whee] = {
      x: 20,
      y: args.grid.top - 10,
      text: "[R] for WHEE",
    }
    
    $state[:labels][:frametime] = {
      x: 20,
      y: args.grid.top - 30,
      text: "",
    }
    
    $state[:subject] = $state[:sprites][:circle]
    
    center! $state[:subject], args
    $state[:timing][:time] = Time.now
    $state[:timing][:frametimes] = SizedArray.new
  end
  
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
    scale! $state[:subject], lambda{|size| size + 50000}
  when false
    scale! $state[:subject], lambda{|size| size - 50000}
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
  
  args.outputs.sprites << $state[:subject]
  args.outputs.labels << $state[:labels][:whee]
  args.outputs.labels << $state[:labels][:frametime]
end
