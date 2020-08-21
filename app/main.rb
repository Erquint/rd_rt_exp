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
      borders: {},
      sprites: {},
      RTs: {},
      mouse: {},
      labels: {},
      timing: {},
      subject: {}
    }
    
    $state[:solids][:square] = {
      w: 400,
      h: 400,
      r: 255,
      g: 255,
      b: 255
    }.instance_eval {
      self[:diagonal] = Math.sqrt(
        self[:w]**2 +
        self[:h]**2
      ).ceil # Needs generalizing.
      self
    }
    
    $state[:RTs][:square] = args.render_target :rt_square
    $state[:RTs][:square].width = $state[:solids][:square][:w]
    $state[:RTs][:square].height = $state[:solids][:square][:h]
    $state[:RTs][:square].solids << $state[:solids][:square]
    
    $state[:sprites][:square] = {
      w: $state[:solids][:square][:w],
      h: $state[:solids][:square][:h],
      path: :rt_square
    }
    
    $state[:RTs][:circle] = args.render_target :rt_circle
    $state[:RTs][:circle].width =
      $state[:solids][:square][:diagonal]
    $state[:RTs][:circle].height =
      $state[:solids][:square][:diagonal]
    
    # square = center $state[:sprites][:square], args
    # Note: `center` dupes!
    square = $state[:sprites][:square].dup
    square[:x] = $state[:RTs][:circle].width / 2 - square[:w] / 2
    square[:y] = $state[:RTs][:circle].height / 2 - square[:h] / 2
    # There's got to be a better way!
    
    square[:angle] ||= 0
    square[:r] = 255
    square[:g] = 0
    square[:b] = 0
    fine = 10
    (90 * fine).times do |i|
      square = square.dup
      square[:angle] += 1 / fine
      $state[:RTs][:circle].sprites << square
    end
    
    $state[:sprites][:circle] = {
      w: $state[:solids][:square][:diagonal],
      h: $state[:solids][:square][:diagonal],
      path: :rt_circle
    }
    
    $state[:borders][:rectangle] = {
      w: args.grid.right,
      h: args.grid.top,
      r: 255
    }
    
    $state[:sprites][:canvas] = {
      w: args.grid.right,
      h: args.grid.top,
      path: :rt_canvas
    }
    
    $state[:labels][:frametime] = {
      y: args.grid.top
    }
    
    $state[:subject] = $state[:sprites][:circle]
    
    center! $state[:subject], args
    $state[:timing][:time] = Time.now
    $state[:timing][:frametimes] = SizedArray.new
  end
  if args.state.tick_count > 0
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
    
    $state[:RTs][:canvas] = args.render_target :rt_canvas
    $state[:RTs][:canvas].sprites << $state[:sprites][:circle]
    $state[:RTs][:canvas].borders << $state[:borders][:rectangle]
    
    args.outputs.sprites << $state[:sprites][:canvas]
    args.outputs.labels << $state[:labels][:frametime]
  end
end
