#include "utils.h"
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

CAMLprim value
caml_image_load_from_file(value filename)
{
  CAMLparam1(filename);

  CAMLlocal2(result, px);

  stbi_set_flip_vertically_on_load(1);

  int x,y,chan;

  char* pixels = stbi_load(String_val(filename), &x, &y, &chan, STBI_rgb_alpha);

  if(pixels && x && y) {
    result = caml_alloc(3,0);
    px = caml_alloc_string(x * y * 4);

    memcpy(String_val(px), pixels, x * y * 4);

    Store_field(result, 0, px);
    Store_field(result, 1, Val_int(x));
    Store_field(result, 2, Val_int(y));

    stbi_image_free(pixels);

    CAMLreturn(Val_some(result));

  }

  else {

    CAMLreturn(Val_none);

  }
}


CAMLprim value
caml_image_load_error(value unit)
{
  CAMLparam0();

  CAMLreturn(caml_copy_string(stbi_failure_reason()));
}
