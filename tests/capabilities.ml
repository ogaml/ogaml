open OgamlGraphics
open OgamlMath

let () =
  Printf.printf "Beginning capabilities tests...\n%!"

let settings = OgamlCore.ContextSettings.create ()

let window = Window.create ~width:100 ~height:100 ~settings ~title:"" ()

let context = Window.context window

let capabilities = Context.capabilities context

let print_opt ppf o = 
  match o with
  | None -> Printf.printf "unsupported"
  | Some v -> Printf.printf "%i" v

let () = 
  Printf.printf "Capabilities : \n";
  Printf.printf "\tMaximal 3D texture size : %i\n%!" capabilities.Context.max_3D_texture_size;
  Printf.printf "\tMaximal array texture layers : %i\n%!" capabilities.Context.max_array_texture_layers;
  Printf.printf "\tMaximal color texture samples : %i\n%!" capabilities.Context.max_color_texture_samples; 
  Printf.printf "\tMaximal cubemap texture size : %i\n%!" capabilities.Context.max_cube_map_texture_size; 
  Printf.printf "\tMaximal depth texture samples : %i\n%!" capabilities.Context.max_depth_texture_samples; 
  Printf.printf "\tMaximal elements indices : %i\n%!" capabilities.Context.max_elements_indices; 
  Printf.printf "\tMaximal elements vertices : %i\n%!" capabilities.Context.max_elements_vertices; 
  Printf.printf "\tMaximal framebuffer width : %a\n%!" print_opt capabilities.Context.max_framebuffer_width; 
  Printf.printf "\tMaximal framebuffer height : %a\n%!" print_opt capabilities.Context.max_framebuffer_height; 
  Printf.printf "\tMaximal framebuffer layers : %a\n%!" print_opt capabilities.Context.max_framebuffer_layers; 
  Printf.printf "\tMaximal framebuffer samples : %a\n%!" print_opt capabilities.Context.max_framebuffer_samples; 
  Printf.printf "\tMaximal integer samples : %i\n%!" capabilities.Context.max_integer_samples; 
  Printf.printf "\tMaximal renderbuffer size : %i\n%!" capabilities.Context.max_renderbuffer_size; 
  Printf.printf "\tMaximal texture buffer size : %i\n%!" capabilities.Context.max_texture_buffer_size; 
  Printf.printf "\tMaximal texture image units : %i\n%!" capabilities.Context.max_texture_image_units; 
  Printf.printf "\tMaximal texture size : %i\n%!" capabilities.Context.max_texture_size;
  Printf.printf "\tMaximal color attachments : %i\n%!" capabilities.Context.max_color_attachments; 
