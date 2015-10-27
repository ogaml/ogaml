type t = 
  | Invalid_enum
  | Invalid_value
  | Invalid_operation
  | Invalid_framebuffer_operation
  | Out_of_memory
  | Stack_underflow
  | Stack_overflow

external get : unit -> t option = "caml_gl_get_error"

