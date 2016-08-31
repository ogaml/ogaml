
module Window = struct

  type t

  let create ~width ~height ~title ~settings = 
	assert false 
	
  let set_title win s = 
	assert false

  let close win = 
	assert false

  let destroy win = 
	assert false

  let size win = 
	assert false

  let rect win = 
	assert false

  let resize win v = 
	assert false

  let toggle_fullscreen win = 
	assert false

  let is_open win = 
	assert false

  let has_focus win = 
	assert false

  let poll_event win = 
	assert false

  let display win = 
	assert false

end


module Keyboard = struct

  let is_pressed kcode = 
	assert false

  let is_shift_down () = 
	assert false

  let is_ctrl_down () = 
	assert false

  let is_alt_down () = 
	assert false

end


module Mouse = struct

  let position () = 
	assert false

  let relative_position win = 
	assert false

  let set_position s = 
	assert false

  let set_relative_position win s = 
	assert false

  let is_pressed but = 
	assert false

end
