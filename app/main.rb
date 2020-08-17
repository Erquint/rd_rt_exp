def tick args
  if args.state.tick_count == 1
    $solid_square = {
      w: 500,
      h: 500
    }
    
    $canvas_sprite = {
      w: args.grid.right,
      h: args.grid.top,
      path: :rt_canvas,
    }
    
    $canvas_rt = args.render_target :rt_canvas
  end
  if args.state.tick_count > 0
    if args.inputs.keyboard.key_held.enter
      $canvas_rt.clear
    end
    
    if args.inputs.keyboard.key_held.space
      $canvas_rt = args.render_target :rt_canvas
    end
    
    $solid_square[:x] =
      args.state.tick_count % ($canvas_sprite[:w] - $solid_square[:w])
    
    $canvas_rt.solids << $solid_square
    args.outputs.sprites << $canvas_sprite
    
    args.outputs.labels << {
      y: $canvas_sprite[:h],
      text: "Hold [SPACE] to force redeclaration of render target on every tick."
    }
    args.outputs.labels << {
      y: $canvas_sprite[:h] - 20,
      text: "Last passed square solid's X coordinate: #{$solid_square[:x]}."
    }
    args.outputs.labels << {
      y: $canvas_sprite[:h] - 40,
      text: "#{$canvas_rt.solids.size - 1} objects have piled up waiting for rasterization."
    }
    args.outputs.labels << {
      y: $canvas_sprite[:h] - 60,
      text: "Hold [ENTER] to try clearing the render target. It doesn't help rasterizing."
    }
  end
end
