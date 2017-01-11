#include "utils.h"
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

CAMLprim value
caml_image_load_from_file(value filename)
{
  CAMLparam1(filename);

  CAMLlocal2(result, px);
  
  int x,y,chan;

  char* pixels;

  stbi_set_flip_vertically_on_load(1);

  pixels = stbi_load(String_val(filename), &x, &y, &chan, STBI_rgb_alpha);

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


CAMLprim value
caml_image_write_png(value filename, value size, value chan, value stride, value data)
{
  CAMLparam5(filename, size, chan, stride, data);

  int w,h;

  w = Int_val(Field(size,0));
  h = Int_val(Field(size,1));
  stbi_write_png(String_val(filename), w, h, Int_val(chan), String_val(data), Int_val(stride));

  CAMLreturn(Val_unit);
}
