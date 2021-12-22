#include <string.h>
#include <caml/bigarray.h>
#include "utils.h"

CAMLprim value
caml_matrix_multiply(value in_dest, value in_src1, value in_src2)
{
  CAMLparam3(in_dest, in_src1, in_src2);

  float* dest = (float*)Caml_ba_data_val(in_dest);
  float* src1 = (float*)Caml_ba_data_val(in_src1);
  float* src2 = (float*)Caml_ba_data_val(in_src2);

  dest[0]  = src1[0] * src2[0]  + src1[4] * src2[1]  + src1[8]  * src2[2]  + src1[12] * src2[3];
  dest[1]  = src1[1] * src2[0]  + src1[5] * src2[1]  + src1[9]  * src2[2]  + src1[13] * src2[3];
  dest[2]  = src1[2] * src2[0]  + src1[6] * src2[1]  + src1[10] * src2[2]  + src1[14] * src2[3];
  dest[3]  = src1[3] * src2[0]  + src1[7] * src2[1]  + src1[11] * src2[2]  + src1[15] * src2[3];
  dest[4]  = src1[0] * src2[4]  + src1[4] * src2[5]  + src1[8]  * src2[6]  + src1[12] * src2[7];
  dest[5]  = src1[1] * src2[4]  + src1[5] * src2[5]  + src1[9]  * src2[6]  + src1[13] * src2[7];
  dest[6]  = src1[2] * src2[4]  + src1[6] * src2[5]  + src1[10] * src2[6]  + src1[14] * src2[7];
  dest[7]  = src1[3] * src2[4]  + src1[7] * src2[5]  + src1[11] * src2[6]  + src1[15] * src2[7];
  dest[8]  = src1[0] * src2[8]  + src1[4] * src2[9]  + src1[8]  * src2[10] + src1[12] * src2[11];
  dest[9]  = src1[1] * src2[8]  + src1[5] * src2[9]  + src1[9]  * src2[10] + src1[13] * src2[11];
  dest[10] = src1[2] * src2[8]  + src1[6] * src2[9]  + src1[10] * src2[10] + src1[14] * src2[11];
  dest[11] = src1[3] * src2[8]  + src1[7] * src2[9]  + src1[11] * src2[10] + src1[15] * src2[11];
  dest[12] = src1[0] * src2[12] + src1[4] * src2[13] + src1[8]  * src2[14] + src1[12] * src2[15];
  dest[13] = src1[1] * src2[12] + src1[5] * src2[13] + src1[9]  * src2[14] + src1[13] * src2[15];
  dest[14] = src1[2] * src2[12] + src1[6] * src2[13] + src1[10] * src2[14] + src1[14] * src2[15];
  dest[15] = src1[3] * src2[12] + src1[7] * src2[13] + src1[11] * src2[14] + src1[15] * src2[15];

  CAMLreturn(Val_unit);
}
