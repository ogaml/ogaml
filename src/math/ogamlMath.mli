(** Mathematical helpers for data manipulation and rendering with OpenGL *)

(** Contains various useful constants *)
module Constants : sig

  (** This module contains some useful constants *)

  (*** Mathematical constants *)

  (** Approximation of pi = 3.14159265358979323846 *)
  val pi : float

  (** Approximation of e = 2.71828182845904523536 *)
  val e : float

  (** Approximation of pi/2 = 1.57079632679489661923 *)
  val pi2 : float

  (** Approximation of pi/3 = 1.047197551196597746153 *)
  val pi3 : float

  (** Approximation of pi/4 = 0.785398163397448309616 *)
  val pi4 : float

  (** Approximation of ln(2) = 0.693147180559945309417 *)
  val ln2 : float

  (** Approximation of ln(10) = 2.30258509299404568402 *)
  val ln10 : float

  (** Approximation of sqrt(2) = 1.41421356237309504880 *)
  val sqrt2 : float

  (** Approximation of sqrt(3) = 1.732050807568877293 *)
  val sqrt3 : float

end


(** Operations on immutable vectors of 2 integers *)
module Vector2i : sig

  (** This module defines the vector2i type and various operations on it. *)

  (*** Vector operations *)

  (** Type of immutable vectors of 2 integers *)
  type t = {x : int; y : int}

  (** Fast way to create a vector*)
  val make : int -> int -> t

  (** Zero vector *)
  val zero : t

  (** Unit x vector *)
  val unit_x : t

  (** Unit y vector *)
  val unit_y : t

  (** Adds two vectors together *)
  val add : t -> t -> t

  (** $sub u v$ computes the vector $u - v$ *)
  val sub : t -> t -> t

  (** Multiplies a vector by a scalar *)
  val prop : int -> t -> t

  (** Divides a vector by a scalar. Returns $Error$ if the scalar is zero. *)
  val div : int -> t -> (t, [> `Division_by_zero]) result

  (** Computes the pointwise product of two vectors. *)
  val pointwise_product : t -> t -> t

  (** Computes the pointwise division of two vectors. *)
  val pointwise_div : t -> t -> t

  (** Computes the dot product of two vectors *)
  val dot : t -> t -> int

  (** Computes the determinant of two vectors *)
  val det : t -> t -> int

  (** Computes the angle (in radians) between two vectors *)
  val angle : t -> t -> float

  (** Computes the squared norm of a vector *)
  val squared_norm : t -> int

  (** Computes the norm of a vector *)
  val norm : t -> float

  (** Computes the squared distance between two points *)
  val squared_dist : t -> t -> int

  (** Computes the distance between two points *)
  val dist : t -> t -> float

  (** $clamp v a b$ returns the vector whose coordinates are the coordinates of $v$
    * clamped between the coordinates of $a$ and $b$ *)
  val clamp : t -> t -> t -> t

  (** Maps each coordinate of a vector *)
  val map : t -> (int -> int) -> t

  (** Maps each pair of coordinates of two vectors *)
  val map2 : t -> t -> (int -> int -> int) -> t

  (** Returns the maximal coordinate of a vector *)
  val max : t -> int

  (** Returns the minimal coordinate of a vector *)
  val min : t -> int

  (** $raster p1 p2$ applies the Bresenham's line algorithm between the points
    * $p1$ and $p2$ and returns the list of points constituting the line
    *
    * Note : should not be used for precise raytracing as it may miss points *)
  val raster : t -> t -> t list

  (** Returns a pretty-printed string (not for serialization) *)
  val to_string : t -> string

end


(** Operations on immutable vectors of 2 floats *)
module Vector2f : sig

  (** This module defines the vector2f type and various operations on it. *)

  (*** Vector operations *)

  (** Type of immutable vectors of 2 floats *)
  type t = {x : float; y : float}

  (** Fast way to create a vector*)
  val make : float -> float -> t

  (** Zero vector *)
  val zero : t

  (** Unit x vector *)
  val unit_x : t

  (** Unit y vector *)
  val unit_y : t

  (** Adds two vectors together *)
  val add : t -> t -> t

  (** $sub u v$ computes the vector $u - v$ *)
  val sub : t -> t -> t

  (** Multiplies a vector by a scalar *)
  val prop : float -> t -> t

  (** Divides a vector by a scalar. Returns $Error$ if the scalar is zero. *)
  val div : float -> t -> (t, [> `Division_by_zero]) result

  (** Computes the pointwise product of two vectors. *)
  val pointwise_product : t -> t -> t

  (** Computes the pointwise division of two vectors. *)
  val pointwise_div : t -> t -> t

  (** Truncates the floating-point coordinates of a vector @see:OgamlMath.Vector2i *)
  val to_int : t -> Vector2i.t

  (** Returns a float vector from an int vector @see:OgamlMath.Vector2i *)
  val from_int : Vector2i.t -> t

  (** Computes the dot product of two vectors *)
  val dot : t -> t -> float

  (** Computes the determinant of two vectors *)
  val det : t -> t -> float

  (** Computes the angle (in radians) between two vectors *)
  val angle : t -> t -> float

  (** Computes the squared norm of a vector *)
  val squared_norm : t -> float

  (** Computes the norm of a vector *)
  val norm : t -> float

  (** Computes the squared distance between two points *)
  val squared_dist : t -> t -> float 

  (** Computes the distance between two points *)
  val dist : t -> t -> float

  (** Normalizes a vector. Returns $Error$ if the vector is zero. *)
  val normalize : t -> (t, [> `Division_by_zero]) result

  (** $clamp v a b$ returns the vector whose coordinates are the coordinates of $v$
    * clamped between the coordinates of $a$ and $b$ *)
  val clamp : t -> t -> t -> t

  (** Maps each coordinate of a vector *)
  val map : t -> (float -> float) -> t

  (** Maps each pair of coordinates of two vectors *)
  val map2 : t -> t -> (float -> float -> float) -> t

  (** Returns the maximal coordinate of a vector *)
  val max : t -> float

  (** Returns the minimal coordinate of a vector *)
  val min : t -> float 

  (** Returns a pretty-printed string (not for serialization) *)
  val to_string : t -> string

  (** $direction u v$ returns the normalized direction vector from $u$ to $v$.
    * Returns $Error$ if $u = v$. *)
  val direction : t -> t -> (t, [> `Division_by_zero]) result

  (** $endpoint a v t$ returns the point $a + tv$ *)
  val endpoint : t -> t -> float -> t

  (** $raytrace_points p1 p2$ returns the list of integer-valued points (squares) on 
    * the line from $p1$ to $p2$  
    *
    * Each point is a triplet of the form $(t, p, f)$ such that :
    *
    * $t$ is the time at the intersection between the line and the point
    *
    * $p$ stores the (integer) coordinates of the point
    *
    * $f$ is a unit vector indicating which face of the square has been intersected 
    *)
  val raytrace_points : t -> t -> (float * t * t) list

  (** $raytrace p v t$ applies $raytrace_points$ between the points 
    * $p$ and $p + tv$. The intersection times are comprised between 0 and t *)
  val raytrace : t -> t -> float -> (float * t * t) list

end


(** Operations on immutable vectors of 3 ints *)
module Vector3i : sig

  (** This module defines the vector3i type and various operations on it. *)

  (*** Vector operations *)

  (** Type of immutable vectors of 3 ints *)
  type t = {x : int; y : int; z : int}

  (** Fast way to create a vector*)
  val make : int -> int -> int -> t

  (** Zero vector *)
  val zero : t

  (** Unit x vector *)
  val unit_x : t

  (** Unit y vector *)
  val unit_y : t

  (** Unit z vector *)
  val unit_z : t

  (** Adds two vectors together *)
  val add : t -> t -> t

  (** $sub u v$ computes the vector $u - v$ *)
  val sub : t -> t -> t

  (** Multiplies a vector by a scalar *)
  val prop : int -> t -> t

  (** Divides a vector by a scalar. Returns $Error$ if the scalar is zero. *)
  val div : int -> t -> (t, [> `Division_by_zero]) result

  (** Computes the pointwise product of two vectors. *)
  val pointwise_product : t -> t -> t

  (** Computes the pointwise division of two vectors. *)
  val pointwise_div : t -> t -> t

  (** Projects a vector on the plane $z = 0$ @see:OgamlMath.Vector2i *)
  val project : t -> Vector2i.t

  (** Lifts a 2D vector in the 3D space by setting $z = 0$ @see:OgamlMath.Vector2i *)
  val lift : Vector2i.t -> t

  (** Computes the dot product of two vectors *)
  val dot : t -> t -> int 

  (** Computes the cross product of two vectors *)
  val cross : t -> t -> t

  (** Computes the angle (in radians) between two vectors *)
  val angle : t -> t -> float

  (** Computes the squared norm of a vector *)
  val squared_norm : t -> int

  (** Computes the norm of a vector *)
  val norm : t -> float

  (** Computes the squared distance between two points *)
  val squared_dist : t -> t -> int

  (** Computes the distance between two points *)
  val dist : t -> t -> float

  (** $clamp v a b$ returns the vector whose coordinates are the coordinates of $v$
    * clamped between the coordinates of $a$ and $b$ *)
  val clamp : t -> t -> t -> t

  (** Maps each coordinate of a vector *)
  val map : t -> (int -> int) -> t

  (** Maps each pair of coordinates of two vectors *)
  val map2 : t -> t -> (int -> int -> int) -> t

  (** Returns the maximal coordinate of a vector *)
  val max : t -> int

  (** Returns the minimal coordinate of a vector *)
  val min : t -> int

  (** $raster p1 p2$ applies the Bresenham's line algorithm between the points
    * $p1$ and $p2$ and returns the list of points constituting the line 
    *
    * Note : should not be used for precise raytracing as it may miss points *)
  val raster : t -> t -> t list

  (** Returns a pretty-printed string (not for serialization) *)
  val to_string : t -> string

end


(** Operations on immutable vectors of 3 floats *)
module Vector3f : sig

  (** This module defines the vector3f type and various operations on it. *)

  (*** Vector operations *)

  (** Type of immutable vectors of 3 floats *)
  type t = {x : float; y : float; z : float}

  (** Fast way to create a vector*)
  val make : float -> float -> float -> t

  (** Zero vector *)
  val zero : t

  (** Unit x vector *)
  val unit_x : t

  (** Unit y vector *)
  val unit_y : t

  (** Unit z vector *)
  val unit_z : t

  (** Adds two vectors together *)
  val add : t -> t -> t

  (** $sub u v$ computes the vector $u - v$ *)
  val sub : t -> t -> t

  (** Multiplies a vector by a scalar *)
  val prop : float -> t -> t

  (** Divides a vector by a scalar. Returns $Error$ if the scalar is zero. *)
  val div : float -> t -> (t, [> `Division_by_zero]) result

  (** Computes the pointwise product of two vectors. *)
  val pointwise_product : t -> t -> t

  (** Computes the pointwise division of two vectors. *)
  val pointwise_div : t -> t -> t

  (** Truncates the floating-point coordinates of a vector @see:OgamlMath.Vector3i *)
  val to_int : t -> Vector3i.t

  (** Returns a float vector from an int vector @see:OgamlMath.Vector3i *)
  val from_int : Vector3i.t -> t

  (** Projects a vector on the plane $z = 0.$ @see:OgamlMath.Vector2f *)
  val project : t -> Vector2f.t

  (** Lifts a 2D vector in the 3D space by setting $z = 0.$ @see:OgamlMath.Vector2f *)
  val lift : Vector2f.t -> t

  (** Computes the dot product of two vectors *)
  val dot : t -> t -> float

  (** Computes the cross product of two vectors *)
  val cross : t -> t -> t

  (** Computes the angle (in radians) between two vectors *)
  val angle : t -> t -> float

  (** Computes the squared norm of a vector *)
  val squared_norm : t -> float

  (** Computes the norm of a vector *)
  val norm : t -> float

  (** Computes the squared distance between two points *)
  val squared_dist : t -> t -> float

  (** Computes the distance between two points *)
  val dist : t -> t -> float

  (** Normalizes a vector. Returns $Error$ if the vector is zero. *)
  val normalize : t -> (t, [> `Division_by_zero]) result

  (** $clamp v a b$ returns the vector whose coordinates are the coordinates of $v$
    * clamped between the coordinates of $a$ and $b$ *)
  val clamp : t -> t -> t -> t

  (** Maps each coordinate of a vector *)
  val map : t -> (float -> float) -> t

  (** Maps each pair of coordinates of two vectors *)
  val map2 : t -> t -> (float -> float -> float) -> t

  (** Returns the maximal coordinate of a vector *)
  val max : t -> float

  (** Returns the minimal coordinate of a vector *)
  val min : t -> float 

  (** Returns a pretty-printed string (not for serialization) *)
  val to_string : t -> string

  (** $direction u v$ returns the normalized direction vector from $u$ to $v$.
    * Returns $Error$ if $u = v$. *)
  val direction : t -> t -> (t, [> `Division_by_zero]) result

  (** $endpoint a v t$ returns the point $a + tv$ *)
  val endpoint : t -> t -> float -> t

  (** $raytrace_points p1 p2$ returns the list of integer-valued points (cubes) on 
    * the line from $p1$ to $p2$  
    *
    * Each point is a triple of the form $(t, p, f)$ such that :
    *
    * $t$ is the time at the intersection between the line and the point
    *
    * $p$ stores the (integer) coordinates of the point
    *
    * $f$ is a unit vector indicating which face of the cube has been intersected 
    *)
  val raytrace_points : t -> t -> (float * t * t) list

  (** $raytrace p v t$ applies $raytrace_points$ between the points 
    * $p$ and $p + tv$. The intersection times are comprised between 0 and t *)
  val raytrace : t -> t -> float -> (float * t * t) list


end


(** Operations on immutable vectors of 2 floats represented in polar coordinates *)
module Vector2fs : sig

  (** This module defines the vector2fs type and various operations on it. *)

  (*** Vector operations *)

  (** Type of immutable vectors of 2 floats represented in polar coordinates *)
  type t = {r : float; (* Signed radius *)
            t : float; (* Theta angle. An angle of 0 corresponds to a vector pointing towards positive X. *)
           }

  (** Zero vector *)
  val zero : t

  (** Unit x vector *)
  val unit_x : t

  (** Unit y vector *)
  val unit_y : t

  (** Multiplies a vector by a scalar *)
  val prop : float -> t -> t

  (** Divides a vector by a scalar. Returns $Error$ if the scalar is zero. *)
  val div : float -> t -> (t, [> `Division_by_zero]) result

  (** Converts a vector represented in polar coordinates to a vector represented in cartesian coordinates 
    * @see:OgamlMath.Vector2f *)
  val to_cartesian : t -> Vector2f.t

  (** Converts a vector represented in cartesian coordinates to a vector represented in polar coordinates 
    * @see:OgamlMath.Vector2f *)
  val from_cartesian : Vector2f.t -> t

  (** Computes the norm of a vector *)
  val norm : t -> float

  (** Normalizes a vector. Returns $Error$ if the vector is zero. *)
  val normalize : t -> (t, [> `Division_by_zero]) result

  (** Returns a pretty-printed string (not for serialization) *)
  val to_string : t -> string

end


(** Operations on immutable vectors of 3 floats represented in spherical coordinates *)
module Vector3fs : sig

  (** This module defines the vector3fs type and various operations on it. *)

  (*** Vector operations *)

  (** Type of immutable vectors of 3 floats represented in spherical coordinates *)
  type t = {r : float; (* Signed radius *)
            t : float; (* Longitude (theta). A longitude of 0 corresponds to a vector pointing towards positive Z. *)
            p : float  (* Latitude (phi). A latitude of 0 corresponds to a vector pointing towards the equator, and a latitude of pi/2 corresponds to a vector pointing towards the north pole (positive Y). *)
           }

  (** Zero vector *)
  val zero : t

  (** Unit x vector *)
  val unit_x : t

  (** Unit y vector *)
  val unit_y : t

  (** Unit z vector *)
  val unit_z : t

  (** Multiplies a vector by a scalar *)
  val prop : float -> t -> t

  (** Divides a vector by a scalar. Returns $Error$ if the scalar is zero. *)
  val div : float -> t -> (t, [> `Division_by_zero]) result

  (** Converts a vector represented in spherical coordinates to a vector represented in cartesian coordinates 
    * @see:OgamlMath.Vector3f *)
  val to_cartesian : t -> Vector3f.t

  (** Converts a vector represented in cartesian coordinates to a vector represented in spherical coordinates 
    * @see:OgamlMath.Vector3f *)
  val from_cartesian : Vector3f.t -> t

  (** Computes the norm of a vector *)
  val norm : t -> float

  (** Normalizes a vector. Returns $Error$ if the vector is zero. *)
  val normalize : t -> (t, [> `Division_by_zero]) result

  (** Returns a pretty-printed string (not for serialization) *)
  val to_string : t -> string

end


(** Operations on integer rectangles *)
module IntRect : sig

  (** This module defines the IntRect type and various operations on it. *)

  (** Type of immutable rectangles of integers *)
  type t = {x : int; y : int; width : int; height : int}

  (** $create position size$ creates a rectangle at position $position$ and
    * of size $size$ *)
  val create : Vector2i.t -> Vector2i.t -> t

  (** $create_from_points p1 p2$ creates a rectangle going from $p1$ to $p2$ *)
  val create_from_points : Vector2i.t -> Vector2i.t -> t

  (** Zero rectangle *)
  val zero : t

  (** Unit rectangle *)
  val one : t

  (** Returns the position of a rectangle *)
  val position : t -> Vector2i.t

  (** Returns the absolute position of a rectangle, that is the 
    * point of minimal coordinates *)
  val abs_position : t -> Vector2i.t

  (** Returns the top corner (aka position + size) of a rectangle *)
  val corner : t -> Vector2i.t

  (** Returns the absolute corner of a rectangle, that is the
    * point of maximal coordinates *)
  val abs_corner : t -> Vector2i.t

  (** Returns the size of a rectangle *)
  val size : t -> Vector2i.t

  (** Returns the absolute size of a rectangle *)
  val abs_size : t -> Vector2i.t

  (** Returns the center of a rectangle *)
  val center : t -> Vector2f.t

  (** $normalize rect$ returns a rectangle equivalent to $rect$ but with
      positive size *)
  val normalize : t -> t

  (** Returns the area of a rectangle *)
  val area : t -> int

  (** Scales a rectangle *)
  val scale : t -> Vector2i.t -> t

  (** Adds a vector to the height and width of a rectangle.
    * Be careful since if the rectangle is not normalized, adding a positive vector
    * may reduce the effective size of the rectangle. *)
  val extend : t -> Vector2i.t -> t

  (** Translates a rectangle *)
  val translate : t -> Vector2i.t -> t

  (** $intersects t1 t2$ returns $true$ iff $t1$ and $t2$ overlap *)
  val intersects : t -> t -> bool

  (** $includes t r$ returns $true$ iff the rectangle $r$ is included in the rectangle $t$ *)
  val includes : t -> t -> bool

  (** $contains t p$ returns $true$ iff the rectangle $t$ contains $p$ 
    *
    * if $strict$ is set to $true$ then upper bounds are not included ($false$ by default) *)
  val contains : ?strict:bool -> t -> Vector2i.t -> bool

  (** $iter t f$ iterates through all points of the rectangle $t$
    * 
    * if $strict$ is set to $false$ then upper bounds are included ($true$ by default) *)
  val iter : ?strict:bool -> t -> (Vector2i.t -> unit) -> unit

  (** $fold t f u$ folds through all points of the rectangle $t$ 
    * 
    * if $strict$ is set to $false$ then upper bounds are included ($true$ by default) *)
  val fold : ?strict:bool -> t -> (Vector2i.t -> 'a -> 'a) -> 'a -> 'a

  (** Returns a pretty-printed string (not for serialization) *)
  val to_string : t -> string

end


(** Operations on float rectangles *)
module FloatRect : sig

  (** This module defines the FloatRect type and various operations on it. *)

  (** Type of immutable rectangles of floats *)
  type t = {x : float; y : float; width : float; height : float}

  (** $create position size$ creates a rectangle at position $position$ and
    * of size $size$ *)
  val create : Vector2f.t -> Vector2f.t -> t

  (** $create_from_points p1 p2$ creates a rectangle going from $p1$ to $p2$ *)
  val create_from_points : Vector2f.t -> Vector2f.t -> t

  (** Zero rectangle *)
  val zero : t

  (** Unit rectangle *)
  val one : t

  (** Returns the position of a rectangle *)
  val position : t -> Vector2f.t

  (** Returns the absolute position of a rectangle, that is the point of
    * minimal coordinates *)
  val abs_position : t -> Vector2f.t

  (** Returns the top corner (aka position + size) of a rectangle *)
  val corner : t -> Vector2f.t

  (** Returns the absolute corner of a rectangle, that is the
    * point of maximal coordinates *)
  val abs_corner : t -> Vector2f.t

  (** Returns the size of a rectangle *)
  val size : t -> Vector2f.t

  (** Returns the absolute size of a rectangle *)
  val abs_size : t -> Vector2f.t

  (** Returns the center of a rectangle *)
  val center : t -> Vector2f.t

  (** $normalize rect$ returns a rectangle equivalent to $rect$ but with
      positive size *)
  val normalize : t -> t

  (** Returns the area of a rectangle *)
  val area : t -> float

  (** Scales a rectangle *)
  val scale : t -> Vector2f.t -> t

  (** Adds a vector to the height and width of a rectangle.
    * Be careful since if the rectangle is not normalized, adding a positive vector
    * may reduce the effective size of the rectangle. *)
  val extend : t -> Vector2f.t -> t

  (** Translates a rectangle *)
  val translate : t -> Vector2f.t -> t

  (** Converts an integer rectangle to a float rectangle *)
  val from_int : IntRect.t -> t

  (** Truncates the floating-point coordinates of a rectangle @see:OgamlMath.IntRect *)
  val to_int : t -> IntRect.t

  (** $intersects t1 t2$ returns $true$ iff $t1$ and $t2$ overlap *)
  val intersects : t -> t -> bool

  (** $contains t p$ returns $true$ iff the rectangle $t$ contains $p$ *)
  val contains : t -> Vector2f.t -> bool

  (** $includes t r$ returns $true$ iff the rectangle $r$ is included in the rectangle $t$ *)
  val includes : t -> t -> bool

  (** Returns a pretty-printed string (not for serialization) *)
  val to_string : t -> string

end


(** Operations on integer boxes *)
module IntBox : sig

  (** This module defines the IntBox type and various operations on it. *)

  (** Type of immutable boxes of integers *)
  type t = {x : int; y : int; z : int; width : int; height : int; depth : int}

  (** $create position size$ creates a box at position $position$ and
    * of size $size$ *)
  val create : Vector3i.t -> Vector3i.t -> t

  (** $create_from_points p1 p2$ creates a box going from $p1$ to $p2$ *)
  val create_from_points : Vector3i.t -> Vector3i.t -> t

  (** Zero box *)
  val zero : t

  (** Unit box *)
  val one : t

  (** Returns the position of a box *)
  val position : t -> Vector3i.t

  (** Returns the absolute position of a box, that is the point of minimal
    * coordinates *)
  val abs_position : t -> Vector3i.t

  (** Returns the top corner (aka position + size) of a box *)
  val corner : t -> Vector3i.t

  (** Returns the absolute corner of a box, that is the
    * point of maximal coordinates *)
  val abs_corner : t -> Vector3i.t

  (** $normalize box$ returns a box equivalent to $box$ but with
      positive size *)
  val normalize : t -> t

  (** Returns the size of a box *)
  val size : t -> Vector3i.t

  (** Returns the absolute size of a box *)
  val abs_size : t -> Vector3i.t

  (** Returns the center of a box *)
  val center : t -> Vector3f.t

  (** Returns the volume of a box *)
  val volume : t -> int

  (** Scales a box *)
  val scale : t -> Vector3i.t -> t

  (** Adds a vector to the dimensions of a box.
    * Be careful since if the box is not normalized, adding a positive vector
    * may reduce the effective size of the box. *)
  val extend : t -> Vector3i.t -> t

  (** Translates a box *)
  val translate : t -> Vector3i.t -> t

  (** $intersects t1 t2$ returns $true$ iff the boxes $t1$ and $t2$ overlap *)
  val intersects : t -> t -> bool

  (** $includes t b$ returns $true$ iff the box $b$ is included in the box $t$ *)
  val includes : t -> t -> bool

  (** $contains t p$ returns $true$ iff the box $t$ contains $p$ 
    *
    * if $strict$ is set to $true$ then upper bounds are not included ($false$ by default) *)
  val contains : ?strict:bool -> t -> Vector3i.t -> bool

  (** $iter t f$ iterates through all points of the box $t$
    * 
    * if $strict$ is set to $false$ then upper bounds are included ($true$ by default) *)
  val iter : ?strict:bool -> t -> (Vector3i.t -> unit) -> unit

  (** $fold t f u$ folds through all points of the box $t$ 
    * 
    * if $strict$ is set to $false$ then upper bounds are included ($true$ by default) *)
  val fold : ?strict:bool -> t -> (Vector3i.t -> 'a -> 'a) -> 'a -> 'a

  (** Returns a pretty-printed string (not for serialization) *)
  val to_string : t -> string

end


(** Operations on float boxes *)
module FloatBox : sig

  (** This module defines the FloatBox type and various operations on it. *)

  (** Type of immutable boxes of floats *)
  type t = {x : float; y : float; z : float; width : float; height : float; depth : float}

  (** $create position size$ creates a box at position $position$ and
    * of size $size$ *)
  val create : Vector3f.t -> Vector3f.t -> t

  (** $create_from_points p1 p2$ creates a box going from $p1$ to $p2$ *)
  val create_from_points : Vector3f.t -> Vector3f.t -> t

  (** Zero box *)
  val zero : t

  (** Unit box *)
  val one : t

  (** Returns the position of a box *)
  val position : t -> Vector3f.t

  (** Returns the absolute position of a box, that is the point of minimal
    * coordinates *)
  val abs_position : t -> Vector3f.t

  (** Returns the top corner (aka position + size) of a box *)
  val corner : t -> Vector3f.t

  (** Returns the absolute corner of a box, that is the
    * point of maximal coordinates *)
  val abs_corner : t -> Vector3f.t

  (** Returns the size of a box *)
  val size : t -> Vector3f.t

  (** Returnrs the absolute size of a box *)
  val abs_size : t -> Vector3f.t

  (** Returns the center of a box *)
  val center : t -> Vector3f.t

  (** $normalize box$ returns a box equivalent to $box$ but with
      positive size *)
  val normalize : t -> t

  (** Adds a vector to the dimensions of a box.
    * Be careful since if the box is not normalized, adding a positive vector
    * may reduce the effective size of the box. *)
  val extend : t -> Vector3f.t -> t

  (** Returns the volume of a box *)
  val volume : t -> float

  (** Scales a box *)
  val scale : t -> Vector3f.t -> t

  (** Translates a box *)
  val translate : t -> Vector3f.t -> t

  (** Converts an integer box to a float box *)
  val from_int : IntBox.t -> t

  (** Truncates the floating-point coordinates of a box @see:OgamlMath.IntBox *)
  val to_int : t -> IntBox.t

  (** $intersects t1 t2$ returns $true$ iff the boxes $t1$ and $t2$ overlap *)
  val intersects : t -> t -> bool

  (** $includes t b$ returns $true$ iff the box $b$ is included in the box $t$ *)
  val includes : t -> t -> bool

  (** $contains t p$ returns $true$ iff the box $t$ contains $p$ *)
  val contains : t -> Vector3f.t -> bool

  (** Returns a pretty-printed string (not for serialization) *)
  val to_string : t -> string

end


(** Operations on immutable quaternions *)
module Quaternion : sig

  (** This module defines the quaternion type and various operations on it *)

  (** Type of quaternions *)
  type t = {r : float; i : float; j : float; k : float}

  (** Zero quaternion *)
  val zero : t

  (** Unit (real) quaternion *)
  val one : t

  (** Returns a real number as a quaternion *)
  val real : float -> t

  (** Adds two quaternions *)
  val add : t -> t -> t

  (** Multiplies two quaternions *)
  val times : t -> t -> t 

  (** Multiplies a quaternion by a scalar *)
  val prop : float -> t -> t 

  (** $sub q1 q2$ returns the quaternion $q1 - q2$ *)
  val sub : t -> t -> t 

  (** Returns the quaternion representing a rotation given by an axis and an angle.
    * @see:OgamlMath.Vector3f *)
  val rotation : Vector3f.t -> float -> t 

  (** Returns the conjugate of a quaternion *)
  val conj : t -> t

  (** Returns the inverse of a quaternion. Returns $Error$ if the quaternion is zero *)
  val inverse : t -> (t, [> `Division_by_zero]) result

  (** Returns the squared norm of a quaternion *)
  val squared_norm : t -> float

  (** Returns the norm of a quaternion *)
  val norm : t -> float

  (** Normalizes a quaternion. Returns $Error$ if the quaternion is zero *)
  val normalize : t -> (t, [> `Division_by_zero]) result

end


(** Provides easy creation and manipulation of rendering matrices *)
module Matrix3D : sig

  (** Optimized operations on 3D (4x4) float matrices *)

  (*** Simple Matrices *)

  (** Type of 4x4 matrices stored in a flat, column-major array *)
  type t

  (** Zero matrix *)
  val zero : unit -> t

  (** Identity matrix *)
  val identity : unit -> t

  (** Builds a translation matrix from a vector @see:OgamlMath.Vector3f *)
  val translation : Vector3f.t -> t

  (** Builds a scaling matrix from a vector @see:OgamlMath.Vector3f *)
  val scaling : Vector3f.t -> t

  (** Builds a rotation matrix from an axis and an angle.
    * Returns $Error$ if the axis is zero.
    * @see:OgamlMath.Vector3f *)
  val rotation : Vector3f.t -> float -> (t, [> `Invalid_axis]) result

  (** Builds a rotation matrix from a quaternion @see:OgamlMath.Quaternion *)
  val from_quaternion : Quaternion.t -> t


  (*** Matrix Operations *)

  (** Computes the product of two matrices *)
  val product : t -> t -> t

  (** Transposes a matrix. The original is not modified. *)
  val transpose : t -> t

  (** Translates a matrix by a vector. The original matrix is not modified. 
    * @see:OgamlMath.Vector3f *)
  val translate : Vector3f.t -> t -> t

  (** Scales a matrix by a vector. The original matrix is not modified. 
    * @see:OgamlMath.Vector3f *)
  val scale : Vector3f.t -> t -> t

  (** Rotates a matrix by an angle around a given axis. The original matrix is not modified. 
    * Returns $Error$ if the axis is zero.
    * @see:OgamlMath.Vector3f *)
  val rotate : Vector3f.t -> float -> t -> (t, [> `Invalid_axis]) result

  (** Computes the (right-)product of a matrix with a column vector.
    * 
    * If $perspective$ is true, then the 4th column of the matrix is
    * added to the resulting vector. $perspective$ defaults to $true$. 
    *
    * @see:OgamlMath.Vector3f *)
  val times : t -> ?perspective:bool -> Vector3f.t -> Vector3f.t

  (** Returns a pretty-printed string (not for serialization) *)
  val to_string : t -> string


  (*** Rendering Matrices Creation *)

  (** Builds a "look-at" view matrix.
    * Returns $Error$ if $up = zero$ or if $at - from$ and $up$ are colinear.
    * @see:OgamlMath.Vector3f *)
  val look_at : from:Vector3f.t -> at:Vector3f.t -> up:Vector3f.t -> 
    (t, [> `From_equals_at | `Invalid_up_direction | `Invalid_at_direction]) result

  (** Builds the inverse of a "look-at" view matrix.
    * Returns $Error$ if $up = zero$ or if $at - from$ and $up$ are colinear.
    * @see:OgamlMath.Vector3f *)
  val ilook_at : from:Vector3f.t -> at:Vector3f.t -> up:Vector3f.t ->
    (t, [> `From_equals_at | `Invalid_up_direction | `Invalid_at_direction]) result


  (** Builds a "look-at" view matrix from eulerian angles. 
    * Theta should be in [0;2pi] and phi in [-pi/2;pi/2]. 
    * If phi = pi/2, the camera is looking up (towards positive Y). 
    * If theta = 0, the camera is looking towards negative Z. 
    * @see:OgamlMath.Vector3f *)
  val look_at_eulerian : from:Vector3f.t -> theta:float -> phi:float -> t

  (** Builds the inverse of a "look-at" view matrix from eulerian angles. 
    * Theta should be in [0;2pi] and phi in [-pi/2;pi/2]. 
    * @see:OgamlMath.Vector3f *)
  val ilook_at_eulerian : from:Vector3f.t -> theta:float -> phi:float -> t

  (** Builds an orthographic projection matrix englobing a volume defined by six planes. 
    * Returns $Error$ if $right = left$ or $near = far$ or $top = bottom$. *)
  val orthographic : right:float -> left:float -> near:float -> far:float ->
      top:float -> bottom:float -> (t, [> `Invalid_planes of string]) result

  (** Builds the inverse of an orthographic projection matrix
    * Returns $Error$ if $right = left$ or $near = far$ or $top = bottom$. *)
  val iorthographic : right:float -> left:float -> near:float -> far:float ->
      top:float -> bottom:float -> (t, [> `Invalid_planes of string]) result

  (** Builds a perspective projection matrix. Near and far are the positions
    * of the clipping planes relatively to the camera position (nothing will
    * be rendered outside those planes). Width and height should usually be 
    * the dimensions of the screen in pixels. Fov corresponds to the view 
    * angle, and is given in radians.
    *
    * Returns $Error$ if $near = far$. *)
  val perspective : near:float -> far:float -> width:float -> height:float ->
      fov:float -> (t, [> `Invalid_planes of string]) result

  (** Builds the inverse of a perspective projection matrix
    * Returns $Error$ if $near = far$. *)
  val iperspective : near:float -> far:float -> width:float -> height:float ->
      fov:float -> (t, [> `Invalid_planes of string]) result

  (*** Other functions *)

  (** Returns a matrix as a flat bigarray. Used internally by OGAML, it should not be necessary for your programs. *)
  val to_bigarray : t -> (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t


end



(** Provides easy creation and manipulation of 2D rendering matrices *)
module Matrix2D : sig

  (** Optimized operations on 2D (3x3) float matrices *)

  (*** Simple Matrices *)

  (** Type of 3x3 matrices stored in a flat, column-major array *)
  type t

  (** Zero matrix *)
  val zero : unit -> t

  (** Identity matrix *)
  val identity : unit -> t

  (** Builds a translation matrix from a vector @see:OgamlMath.Vector2f *)
  val translation : Vector2f.t -> t

  (** Builds a scaling matrix from a vector @see:OgamlMath.Vector2f *)
  val scaling : Vector2f.t -> t

  (** Builds a rotation matrix from an angle *)
  val rotation : float -> t

  (** Efficiently builds a transformation matrix *)
  val transformation : 
    translation:Vector2f.t ->
    rotation:float ->
    scale:Vector2f.t ->
    origin:Vector2f.t -> t

  (*** Matrix Operations *)

  (** Computes the product of two matrices *)
  val product : t -> t -> t

  (** Transposes a matrix. The original is not modified. *)
  val transpose : t -> t

  (** Translates a matrix by a vector. The original matrix is not modified. 
    * @see:OgamlMath.Vector2f *)
  val translate : Vector2f.t -> t -> t

  (** Scales a matrix by a vector. The original matrix is not modified. 
    * @see:OgamlMath.Vector2f *)
  val scale : Vector2f.t -> t -> t

  (** Rotates a matrix by an angle. The original matrix is not modified. *)
  val rotate : float -> t -> t

  (** Computes the (right-)product of a matrix with a column vector *)
  val times : t -> Vector2f.t -> Vector2f.t

  (** Returns a pretty-printed string (not for serialization) *)
  val to_string : t -> string


  (*** Rendering Matrices Creation *)

  (** Builds an orthographic projection matrix englobing a screen.
    * Returns $Error$ if one of the coordinates of $size$ is zero. *)
  val projection : size:Vector2f.t -> (t, [> `Invalid_projection]) result

  (** Builds the inverse of an orthographic projection matrix.
    * Returns $Error$ if one of the coordinates of $size$ is zero. *)
  val iprojection : size:Vector2f.t -> (t, [> `Invalid_projection]) result

  (*** Other functions *)

  (** Returns a matrix as a flat bigarray. Used internally by OGAML, it should not be necessary for your programs. *)
  val to_bigarray : t -> (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t


end
