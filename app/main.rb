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
      args.state.tick_count % (args.grid.right - $solid_square[:w])
    
    $canvas_rt.solids << $solid_square
    args.outputs.sprites << $canvas_sprite
    
    args.outputs.labels << {
      y: args.grid.top,
      text: "Hold [SPACE] to force redeclaration of render target on every tick."
    } << {
      y: args.grid.top - 20,
      text: "Last passed square solid's X coordinate: #{$solid_square[:x]}."
    } << {
      y: args.grid.top - 40,
      text: "#{$canvas_rt.solids.size} objects have piled up in render target waiting to get rasterized."
    } << {
      y: args.grid.top - 60,
      text: "Hold [ENTER] to try clearing the render target. It doesn't help rasterizing."
    }
  end
end
