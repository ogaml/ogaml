#include <caml/bigarray.h>
#include "utils.h"
#define STB_TRUETYPE_IMPLEMENTATION
#include "stb_truetype.h"

CAMLprim value
caml_stb_load_font(value filename)
{
  CAMLparam1(filename);

  long size;
  unsigned char* fontBuffer;
  FILE* fontFile = fopen(String_val(filename), "rb");
  stbtt_fontinfo* info;

  fseek(fontFile, 0, SEEK_END);
  size = ftell(fontFile);
  fseek(fontFile, 0, SEEK_SET);

  fontBuffer = malloc(size);

  fread(fontBuffer, size, 1, fontFile);
  fclose(fontFile);

  info = malloc(sizeof(stbtt_fontinfo));
  stbtt_InitFont(info, fontBuffer, 0);

  CAMLreturn((value)info);
}


CAMLprim value
caml_stb_kern_advance(value info, value c1, value c2)
{
  CAMLparam3(info, c1, c2);
  CAMLreturn(
    Val_int(
      stbtt_GetCodepointKernAdvance((stbtt_fontinfo*)info, 
                                              Int_val(c1), 
                                              Int_val(c2))
    )
  );
}


CAMLprim value
caml_stb_scale(value info, value px)
{
  CAMLparam2(info, px);
  CAMLreturn(
    caml_copy_double(
      stbtt_ScaleForPixelHeight((stbtt_fontinfo*)info, 
                                          Int_val(px))
    )
  );
}


CAMLprim value
caml_stb_metrics(value info)
{
  CAMLparam1(info);
  CAMLlocal1(res);

  int ascent, descent, linegap;
  stbtt_GetFontVMetrics((stbtt_fontinfo*)info, &ascent, &descent, &linegap);

  res = caml_alloc(3, 0);
  Store_field(res, 0, Val_int(ascent));
  Store_field(res, 1, Val_int(descent));
  Store_field(res, 2, Val_int(linegap));
  
  CAMLreturn(res);
}


CAMLprim value
caml_stb_hmetrics(value info, value code)
{
  CAMLparam2(info, code);
  
  int advance, bearing;
  stbtt_GetCodepointHMetrics((stbtt_fontinfo*)info, Int_val(code), &advance, &bearing);

  CAMLreturn(Int_pair(advance,bearing));
}


CAMLprim value
caml_stb_box(value info, value code)
{
  CAMLparam2(info, code);
  CAMLlocal1(res);

  int x0, y0, x1, y1;
  if(!stbtt_GetCodepointBox((stbtt_fontinfo*)info, Int_val(code), &x0, &y0, &x1, &y1)) {
    x0 = 0;
    y0 = 0;
    x1 = 0;
    y1 = 0;
  }

  res = caml_alloc(4,0);
  Store_field(res, 0, Val_int(x0));
  Store_field(res, 1, Val_int(y0));
  Store_field(res, 2, Val_int(x1 - x0));
  Store_field(res, 3, Val_int(y1 - y0));

  CAMLreturn(res);
}


CAMLprim value
caml_stb_bitmap(value info, value code, value scale)
{
  CAMLparam3(info, code, scale);
  CAMLlocal2(res, bmp);

  int width, height, xoff, yoff;

  unsigned char* bitmap = stbtt_GetCodepointBitmap((stbtt_fontinfo*)info, 
                                                       Double_val(scale), 
                                                       Double_val(scale), 
                                                           Int_val(code),
                                                                  &width,
                                                                 &height,
                                                                   &xoff,
                                                                   &yoff);

  if(!bitmap) {
    width = 0;
    height = 0;
  }

  res = caml_alloc(3,0);
  
  bmp = caml_alloc_string(width * height);
  memcpy(String_val(bmp), bitmap, width * height);


  Store_field(res, 0, bmp);
  Store_field(res, 1, Val_int(width));
  Store_field(res, 2, Val_int(height));

  stbtt_FreeBitmap(bitmap, NULL);

  CAMLreturn(res);
}



