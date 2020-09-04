#define GL_GLEXT_PROTOTYPES
#if defined(_WIN32)
  #include <windows.h>
  #include <gl/glew.h>
#endif
#if defined(__APPLE__)
  #include <OpenGL/gl3.h>
  #ifndef GL_TESS_CONTROL_SHADER
      #define GL_TESS_CONTROL_SHADER 0x00008e88
  #endif
  #ifndef GL_TESS_EVALUATION_SHADER
      #define GL_TESS_EVALUATION_SHADER 0x00008e87
  #endif
  #ifndef GL_PATCHES
      #define GL_PATCHES 0x0000000e
  #endif
#else
  #include <GL/gl.h>
#endif
#include <caml/bigarray.h>
#include <string.h>
#include "utils.h"
#include "types_stubs.h"


#define QUERY(_a) (*(GLuint*) Data_custom_val(_a))

void finalise_query(value v)
{
  glDeleteQueries(1,&QUERY(v));
}


int compare_queries(value v1, value v2)
{
  GLuint i1 = QUERY(v1);
  GLuint i2 = QUERY(v2);
  if(i1 < i2) return -1;
  else if(i1 == i2) return 0;
  else return 1;
}

intnat hash_query(value v)
{
  GLuint i = QUERY(v);
  return i;
}

static struct custom_operations query_custom_ops = {
  "query GC handling",
  finalise_query,
  compare_queries,
  hash_query,
  custom_serialize_default,
  custom_deserialize_default
};

// INPUT   nothing
// OUTPUT  a fresh query id
CAMLprim value
caml_create_query(value unit)
{
  CAMLparam0();
  CAMLlocal1(v);

  GLuint buf[1];
  glGenQueries(1, buf);
  v = caml_alloc_custom( &query_custom_ops, sizeof(GLuint), 0, 1);
  memcpy( Data_custom_val(v), buf, sizeof(GLuint) );

  CAMLreturn(v);
}


// INPUT   a target and a query id
// OUTPUT  nothing, begins the query
CAMLprim value
caml_begin_query(value target, value query)
{
  CAMLparam2(target, query);

  glBeginQuery(Query_val(target), QUERY(query));

  CAMLreturn(Val_unit);
}


// INPUT   a target
// OUTPUT  nothing, ends the query bound to the target
CAMLprim value
caml_end_query(value target)
{
  CAMLparam1(target);

  glEndQuery(Query_val(target));

  CAMLreturn(Val_unit);
}


// INPUT   a query id
// OUTPUT  an int containing the query value
CAMLprim value
caml_get_query_result(value query)
{
  CAMLparam1(query);

  GLint res = 0;
  glGetQueryObjectiv(QUERY(query), GL_QUERY_RESULT, &res);

  CAMLreturn(Val_int(res));
}


// INPUT   a query id
// OUTPUT  an int containing the query value
CAMLprim value
caml_get_query_result_no_wait(value query)
{
  CAMLparam1(query);

  GLint res = 0;
  glGetQueryObjectiv(QUERY(query), GL_QUERY_RESULT_NO_WAIT, &res);

  CAMLreturn(Val_int(res));
}
