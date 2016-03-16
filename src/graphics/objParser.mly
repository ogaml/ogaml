%token EOF
%token <string> STRING
%token <int> INT 
%token <float> FLOAT 
%token VERTEX UV NORMAL FACE PARAM
%token USEMTL MATLIB OBJECT GROUP
%token SMOOTH OFF
%token LEFTBRACKET RIGHTBRACKET SLASH

%start <ObjAST.t list> file
%%

file:
  |l = obj_list; EOF {l}
  ;

float_lit:
  |i = INT {float_of_int i}
  |f = FLOAT {f}
  ;

vertex:
  |VERTEX; x = float_lit; y = float_lit; z = float_lit 
    {ObjAST.Vertex OgamlMath.Vector3f.({x; y; z})}
  |VERTEX; x = float_lit; y = float_lit; z = float_lit; w = float_lit 
    {ObjAST.Vertex OgamlMath.Vector3f.({x; y; z})}
  ;

uv:
  |UV; x = float_lit; y = float_lit
    {ObjAST.UV OgamlMath.Vector2f.({x; y})}
  |UV; x = float_lit; y = float_lit; z = float_lit
    {ObjAST.UV OgamlMath.Vector2f.({x; y})}
  ;

normal:
  |NORMAL; x = float_lit; y = float_lit; z = float_lit 
    {ObjAST.Normal OgamlMath.Vector3f.({x; y; z} |> normalize)}
  ;

param:
  |PARAM; x = float_lit 
    {ObjAST.Param}
  |PARAM; x = float_lit; y = float_lit
    {ObjAST.Param}
  |PARAM; x = float_lit; y = float_lit; z = float_lit
    {ObjAST.Param}
  ;

%inline triple:
  |x = INT
    {OgamlMath.Vector3i.({x; y = 0; z = 0})}
  |x = INT; SLASH; y = INT 
    {OgamlMath.Vector3i.({x; y; z = 0})}
  |x = INT; SLASH; SLASH; z = INT
    {OgamlMath.Vector3i.({x; y = 0; z})}
  |x = INT; SLASH; y = INT; SLASH; z = INT
    {OgamlMath.Vector3i.({x; y; z})}
  ;

face:
  |FACE; t1 = triple; t2 = triple; t3 = triple 
    {ObjAST.Tri (t1,t2,t3)}
  |FACE; t1 = triple; t2 = triple; t3 = triple; t4 = triple
    {ObjAST.Quad (t1,t2,t3,t4)}
  ;

mtllib:
  |MATLIB; LEFTBRACKET; s = STRING; RIGHTBRACKET
  |MATLIB; s = STRING 
    {ObjAST.Mtllib s}
  ;

usemtl:
  |USEMTL; LEFTBRACKET; s = STRING; RIGHTBRACKET
  |USEMTL; s = STRING 
    {ObjAST.Usemtl s}
  ;

objct:
  |OBJECT; LEFTBRACKET; s = STRING; RIGHTBRACKET
  |OBJECT; s = STRING 
    {ObjAST.Object s}
  ;

group:
  |GROUP; LEFTBRACKET; s = STRING; RIGHTBRACKET
  |GROUP; s = STRING 
    {ObjAST.Group s}
  ;

smooth:
  |SMOOTH; i = INT 
    {ObjAST.Smooth (Some i)}
  |SMOOTH; OFF
    {ObjAST.Smooth None}
  ;

obj_field:
  | f = vertex {f}
  | f = uv     {f}
  | f = normal {f}
  | f = param  {f}
  | f = face   {f}
  | f = mtllib {f}
  | f = usemtl {f}
  | f = objct  {f}
  | f = group  {f}
  | f = smooth {f} 
  ;

obj_list:
  | {[]}
  | f = obj_field; l = obj_list {f :: l}
  ;
