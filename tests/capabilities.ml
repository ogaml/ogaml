open OgamlGraphics
open OgamlMath
open OgamlUtils

let () =
  Log.info Log.stdout "Beginning capabilities tests..."

let settings = OgamlCore.ContextSettings.create ()

let window = 
  Window.create ~width:100 ~height:100 ~settings ~title:"" () 
  |> Utils.handle_window_creation

let context = Window.context window

let capabilities = Context.capabilities context

let () = 
  Log.info Log.stdout "Maximal 3D texture size: %i" capabilities.Context.max_3D_texture_size;
  Log.info Log.stdout "Maximal array texture layers: %i" capabilities.Context.max_array_texture_layers;
  Log.info Log.stdout "Maximal color texture samples: %i" capabilities.Context.max_color_texture_samples; 
  Log.info Log.stdout "Maximal cubemap texture size: %i" capabilities.Context.max_cube_map_texture_size; 
  Log.info Log.stdout "Maximal depth texture samples: %i" capabilities.Context.max_depth_texture_samples; 
  Log.info Log.stdout "Maximal elements indices: %i" capabilities.Context.max_elements_indices; 
  Log.info Log.stdout "Maximal elements vertices: %i" capabilities.Context.max_elements_vertices; 
  Log.info Log.stdout "Maximal integer samples: %i" capabilities.Context.max_integer_samples; 
  Log.info Log.stdout "Maximal renderbuffer size: %i" capabilities.Context.max_renderbuffer_size; 
  Log.info Log.stdout "Maximal texture buffer size: %i" capabilities.Context.max_texture_buffer_size; 
  Log.info Log.stdout "Maximal texture image units: %i" capabilities.Context.max_texture_image_units; 
  Log.info Log.stdout "Maximal texture size: %i" capabilities.Context.max_texture_size;
  Log.info Log.stdout "Maximal color attachments: %i" capabilities.Context.max_color_attachments
