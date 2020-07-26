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
		$state = {
			solids: {},
			sprites: {},
			RTs: {},
			mouse: {},
			labels: {},
			toggles: {}
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
			y: 40,
			text: "[R] for WHEE",
		}
	
		$state[:angleΔ] = 45
		$state[:subject] = $state[:sprites][:circle]
	end
	
	$state[:mouse][:held] = true if args.inputs.mouse.down
	$state[:mouse][:held] = false if args.inputs.mouse.up
	
	if $state[:mouse][:held] then
		$state[:subject][:x] += args.inputs.mouse.point.x - $state[:mouse][:x]
		$state[:subject][:y] += args.inputs.mouse.point.y - $state[:mouse][:y]
	end
	
	$state[:mouse][:x] = args.inputs.mouse.point.x
	$state[:mouse][:y] = args.inputs.mouse.point.y
	
	case args.inputs.mouse.wheel&.y&.positive?
	when true
		scale! $state[:subject], lambda{|size| size + 10}
	when false
		scale! $state[:subject], lambda{|size| size - 10}
	end
	
	if args.inputs.keyboard.key_down.r then
		$state[:toggles][:whee] = !$state[:toggles][:whee]
	end
	
	if $state[:toggles][:whee] then
		$state[:angleΔ] += 0.1
		$state[:subject][:angle] += $state[:angleΔ]
	end
	
	if args.state.tick_count % (60 * 10) == 0 then
		puts $state.to_s + "\n\n"
	end
	
	args.outputs.sprites << $state[:subject]
	args.outputs.labels << $state[:labels][:whee]
end
