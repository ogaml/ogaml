#import "cocoa_stubs.h"

////////////////////////////////////////////////////////////////////////////////
// NSOpenGLPixelFormat binding
////////////////////////////////////////////////////////////////////////////////

CAMLprim value
caml_cocoa_init_pixelformat_with_attributes(value mlattributes)
{
  CAMLparam1(mlattributes); // Ignored for now

  NSOpenGLPixelFormatAttribute attributes[] =
  {
    #ifdef __OSX__
      NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
    #endif
    NSOpenGLPFAColorSize    , 24                           ,
    NSOpenGLPFAAlphaSize    , 8                            ,
    NSOpenGLPFADoubleBuffer ,
    NSOpenGLPFAAccelerated  ,
    0
  };

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
