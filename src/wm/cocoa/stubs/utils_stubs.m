#import "cocoa_stubs.h"

// AutoReleasePool binding
//////////////////////////
static NSAutoreleasePool* arp = nil;

CAMLprim value
caml_init_arp(value unit)
{
  CAMLparam0();

  if(arp == nil) {
    arp = [[NSAutoreleasePool alloc] init];
  }

  CAMLreturn(Val_unit);
}

// Display information
//////////////////////
CAMLprim value
caml_cocoa_display_size(value unit)
{
  CAMLparam0();
  CAMLlocal1(tuple);

  CGDirectDisplayID displayID = CGMainDisplayID();
  size_t screenWidth = CGDisplayPixelsWide(displayID);
  size_t screenHeight = CGDisplayPixelsHigh(displayID);

  tuple = caml_alloc(2,0);
  Store_field(tuple,0,caml_copy_double(screenWidth));
  Store_field(tuple,1,caml_copy_double(screenHeight));

  CAMLreturn(tuple);
}

// NSString binding
///////////////////

CAMLprim value
caml_cocoa_gen_string(value str)
{
  CAMLparam1(str);

  char* tmp = String_val(str);

  NSString* data = [NSString stringWithFormat:@"%s" , tmp];

  CAMLreturn((value) data);
}


CAMLprim value
caml_cocoa_get_string(value mlstr)
{
  CAMLparam1(mlstr);
  CAMLlocal1(mlc);

  NSString* str = (NSString*) mlstr;
  char* c = (char*)[str UTF8String];

  mlc = caml_copy_string(c);

  CAMLreturn(mlc);
}

// NSRect binding
/////////////////

CAMLprim value
caml_cocoa_create_nsrect(value x, value y, value w, value h)
{
  CAMLparam4(x,y,w,h);

  CAMLlocal1(mlrect);
  mlrect = caml_alloc_custom(&empty_custom_opts, sizeof(NSRect), 0, 1);

  NSRect rect = NSMakeRect(Double_val(x), Double_val(y), Double_val(w), Double_val(h));

  memcpy(Data_custom_val(mlrect), &rect, sizeof(NSRect));

  CAMLreturn(mlrect);
}

CAMLprim value
caml_cocoa_get_nsrect(value mlrect)
{
  CAMLparam1(mlrect);
  CAMLlocal1(tuple);

  NSRect* rect = (NSRect*) Data_custom_val(mlrect);

  tuple = caml_alloc(4,0);
  Store_field(tuple,0,caml_copy_double(rect->origin.x));
  Store_field(tuple,1,caml_copy_double(rect->origin.y));
  Store_field(tuple,2,caml_copy_double(rect->size.width));
  Store_field(tuple,3,caml_copy_double(rect->size.height));

  CAMLreturn(tuple);
}

// NSColor binding
//////////////////

CAMLprim value
caml_cocoa_color_rgba(value r, value g, value b, value a)
{
  CAMLparam4(r,g,b,a);

  float fr = Double_val(r);
  float fg = Double_val(g);
  float fb = Double_val(b);
  float fa = Double_val(a);

  NSColor* color = [NSColor colorWithRed:fr green:fg blue:fb alpha:fa];

  CAMLreturn( (value) color );
}

#define def_caml_cocoa_color(c,nsc) CAMLprim value \
                            caml_cocoa_color_ ## c (value unit) \
                            { \
                              CAMLparam0(); \
                              NSColor* color = [NSColor nsc ## Color]; \
                              CAMLreturn( (value) color ); \
                            }

def_caml_cocoa_color(black,black)
def_caml_cocoa_color(blue,blue)
def_caml_cocoa_color(brown,brown)
def_caml_cocoa_color(clear,clear)
def_caml_cocoa_color(cyan,cyan)
def_caml_cocoa_color(dark_gray,darkGray)
def_caml_cocoa_color(gray,gray)
def_caml_cocoa_color(green,green)
def_caml_cocoa_color(light_gray,lightGray)
def_caml_cocoa_color(magenta,magenta)
def_caml_cocoa_color(orange,orange)
def_caml_cocoa_color(purple,purple)
def_caml_cocoa_color(red,red)
def_caml_cocoa_color(white,white)
def_caml_cocoa_color(yellow,yellow)
