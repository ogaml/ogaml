#import "cocoa_stubs.h"

////////////////////////////////////////////////////////////////////////////////
// NSOpenGLPixelFormat binding
////////////////////////////////////////////////////////////////////////////////

CAMLprim value
caml_cocoa_init_pixelformat_with_attributes(value mlattributes)
{
  CAMLparam1(mlattributes);
  int i, len;
  len = Wosize_val(mlattributes);
  NSOpenGLPixelFormatAttribute attributes[len];

  for (i=0; i < len; i++)
  {
    attributes[i] = Int_val(Field(mlattributes, i));
  }

  id format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];

  CAMLreturn((value)format);
}

////////////////////////////////////////////////////////////////////////////////
// NSOpenGLContext binding
////////////////////////////////////////////////////////////////////////////////

CAMLprim value
caml_cocoa_init_context_with_format(value mlformat)
{
  CAMLparam1(mlformat);

  NSOpenGLPixelFormat* format = (NSOpenGLPixelFormat*) mlformat;

  NSOpenGLContext* context = [[NSOpenGLContext alloc] initWithFormat:format
                                                        shareContext:nil];

  CAMLreturn( (value) context );
}
