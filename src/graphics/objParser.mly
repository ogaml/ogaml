%token EOF
%token <string> STRING
%token <int> INT 
%token <float> FLOAT 
%token VERTEX UV NORMAL FACE PARAM
%token USEMTL MATLIB OBJECT GROUP
%token SMOOTH OFF
%token LEFTBRACKET RIGHTBRACKET SLASH

%start file
%type <ObjAST.t list> file
%%

file:
  |obj_list EOF {$1}
  ;

float_lit:
  |INT {float_of_int $1}
  |FLOAT {$1}
  ;

vertex:
  |VERTEX float_lit float_lit float_lit 
    {ObjAST.Vertex OgamlMath.Vector3f.({x = $2; y = $3; z = $4})}
  |VERTEX float_lit float_lit float_lit float_lit 
    {ObjAST.Vertex OgamlMath.Vector3f.({x = $2; y = $3; z = $4})}
  ;

uv:
  |UV float_lit float_lit
    {ObjAST.UV OgamlMath.Vector2f.({x = $2; y = $3})}
  |UV float_lit float_lit float_lit
    {ObjAST.UV OgamlMath.Vector2f.({x = $2; y = $3})}
  ;

normal:
  |NORMAL float_lit float_lit float_lit 
    {ObjAST.Normal OgamlMath.Vector3f.({x = $2; y = $3; z = $4} |> normalize)}
  ;

param:
  |PARAM float_lit 
    {ObjAST.Param}
  |PARAM float_lit float_lit
    {ObjAST.Param}
  |PARAM float_lit float_lit float_lit
    {ObjAST.Param}
  ;

triple:
  |INT
    {OgamlMath.Vector3i.({x = $1; y = 0; z = 0})}
  |INT SLASH INT 
    {OgamlMath.Vector3i.({x = $1; y = $3; z = 0})}
  |INT SLASH SLASH INT
    {OgamlMath.Vector3i.({x = $1; y = 0; z = $4})}
  |INT SLASH INT SLASH INT
    {OgamlMath.Vector3i.({x = $1; y = $3; z = $5})}
  ;

face:
  |FACE triple triple triple 
    {ObjAST.Tri ($2,$3,$4)}
  |FACE triple triple triple triple
    {ObjAST.Quad ($2,$3,$4,$5)}
  ;

mtllib:
  |MATLIB LEFTBRACKET STRING RIGHTBRACKET
    {ObjAST.Mtllib $3}
  |MATLIB STRING 
    {ObjAST.Mtllib $2}
  ;

usemtl:
  |USEMTL LEFTBRACKET STRING RIGHTBRACKET
    {ObjAST.Usemtl $3}
  |USEMTL STRING 
    {ObjAST.Usemtl $2}
  ;

objct:
  |OBJECT LEFTBRACKET STRING RIGHTBRACKET
    {ObjAST.Object $3}
  |OBJECT STRING 
    {ObjAST.Object $2}
  ;

group:
  |GROUP LEFTBRACKET STRING RIGHTBRACKET
    {ObjAST.Group $3}
  |GROUP STRING 
    {ObjAST.Group $2}
  ;

smooth:
  |SMOOTH INT 
    {ObjAST.Smooth (Some $2)}
  |SMOOTH OFF
    {ObjAST.Smooth None}
  ;

obj_field:
  | vertex {$1}
  | uv     {$1}
  | normal {$1}
  | param  {$1}
  | face   {$1}
  | mtllib {$1}
  | usemtl {$1}
  | objct  {$1}
  | group  {$1}
  | smooth {$1} 
  ;

obj_list:
  | {[]}
  | obj_field obj_list {$1 :: $2}
  ;
