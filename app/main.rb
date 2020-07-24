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
  center = {
    x: input[:x] + input[:w] / 2,
    y: input[:y] + input[:h] / 2
  }
  input[:w] = function.call(input[:w])
  input[:h] = function.call(input[:h])
  input[:x] = center[:x] - input[:w] / 2
  input[:y] = center[:y] - input[:h] / 2
  true
end

def tick args
  if args.state.tick_count == 0 then
    $state = {}
    solid = {
      x: 0,
      y: 0,
      w: 50,
      h: 50,
      r: 0,
      g: 0,
      b: 0,
      a: 255
    }
    $state[:sprite] = {
      x: 0,
      y: 0,
      w: 50,
      h: 50,
      path: solid,
      angle: 0,
      r: 0,
      g: 0,
      b: 0,
      a: 255,
      tile_x: 0,
      tile_y: 0,
      tile_w: -1,
      tile_h: -1,
      flip_vertically: false,
      flip_horizontally: false,
      angle_anchor_x: 0.5,
      angle_anchor_y: 0.5
    }
    center! $state[:sprite], args
    $state[:angleΔ] = 45
  end
  
  case args.inputs.mouse.wheel&.y&.positive?
  when true
    # $state[:angleΔ] -= 1
    scale! $state[:sprite], lambda{|size| size + 10}
  when false
    # $state[:angleΔ] += 1
    scale! $state[:sprite], lambda{|size| size - 10}
  end
  
  $state[:angleΔ] += 0.1
  $state[:sprite][:angle] += $state[:angleΔ]
  
  args.outputs.sprites << $state[:sprite]
  # args.outputs.solids << solid
  # args.outputs.borders << border
end
