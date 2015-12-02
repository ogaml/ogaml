
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

  (** Raised when an error occurs (usually a division by zero) *)
  exception Vector2i_exception of string

  (*** Vector operations *)

  (** Type of immutable vectors of 2 integers *)
  type t = {x : int; y : int}

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

  (** Divides a vector by a scalar. Raises Vector2i_exception if the scalar is zero. *)
  val div : int -> t -> t

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

  (** $clamp v a b$ returns the vector whose coordinates are the coordinates of $v$
    * clamped between the coordinates of $a$ and $b$ *)
  val clamp : t -> t -> t -> t

  (** Returns the maximal coordinate of a vector *)
  val max : t -> int

  (** Returns the minimal coordinate of a vector *)
  val min : t -> int

  (** Returns a pretty-printed string (not for serialization) *)
  val print : t -> string

end


(** Operations on immutable vectors of 2 floats *)
module Vector2f : sig

  (** This module defines the vector2f type and various operations on it. *)

  (** Raised when an error occurs (usually a division by zero) *)
  exception Vector2f_exception of string

  (*** Vector operations *)

  (** Type of immutable vectors of 2 floats *)
  type t = {x : float; y : float}

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

  (** Divides a vector by a scalar. Raises Vector2f_exception if the scalar is zero. *)
  val div : float -> t -> t

  (** Rounds-down a vector @see:OgamlMath.Vector2i *)
  val floor : t -> Vector2i.t

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

  (** Normalizes a vector. Raises Vector2f_exception if the vector is zero. *)
  val normalize : t -> t

  (** $clamp v a b$ returns the vector whose coordinates are the coordinates of $v$
    * clamped between the coordinates of $a$ and $b$ *)
  val clamp : t -> t -> t -> t

  (** Returns the maximal coordinate of a vector *)
  val max : t -> float

  (** Returns the minimal coordinate of a vector *)
  val min : t -> float 

  (** Returns a pretty-printed string (not for serialization) *)
  val print : t -> string

  (** $direction u v$ returns the normalized direction vector from $u$ to $v$.
    * Raises Vector2f_exception if $u = v$. *)
  val direction : t -> t -> t

  (** $endpoint a v t$ returns the point $a + tv$ *)
  val endpoint : t -> t -> float -> t

end


(** Operations on immutable vectors of 3 ints *)
module Vector3i : sig

  (** This module defines the vector3i type and various operations on it. *)

  (** Raised when an error occurs (usually a division by zero) *)
  exception Vector3i_exception of string

  (*** Vector operations *)

  (** Type of immutable vectors of 3 ints *)
  type t = {x : int; y : int; z : int}

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

  (** Divides a vector by a scalar. Raises Vector3i_exception if the scalar is zero. *)
  val div : int -> t -> t

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

  (** $clamp v a b$ returns the vector whose coordinates are the coordinates of $v$
    * clamped between the coordinates of $a$ and $b$ *)
  val clamp : t -> t -> t -> t

  (** Returns the maximal coordinate of a vector *)
  val max : t -> int

  (** Returns the minimal coordinate of a vector *)
  val min : t -> int

  (** Returns a pretty-printed string (not for serialization) *)
  val print : t -> string

end


(** Operations on immutable vectors of 3 floats *)
module Vector3f : sig

  (** This module defines the vector3f type and various operations on it. *)

  (** Raised when an error occurs (usually a division by zero) *)
  exception Vector3f_exception of string

  (*** Vector operations *)

  (** Type of immutable vectors of 3 floats *)
  type t = {x : float; y : float; z : float}

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

  (** Divides a vector by a scalar. Raises Vector3f_exception if the scalar is zero. *)
  val div : float -> t -> t

  (** Rounds-down a vector @see:OgamlMath.Vector3i *)
  val floor : t -> Vector3i.t

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

  (** Normalizes a vector. Raises Vector3f_exception if the vector is zero. *)
  val normalize : t -> t

  (** $clamp v a b$ returns the vector whose coordinates are the coordinates of $v$
    * clamped between the coordinates of $a$ and $b$ *)
  val clamp : t -> t -> t -> t

  (** Returns the maximal coordinate of a vector *)
  val max : t -> float

  (** Returns the minimal coordinate of a vector *)
  val min : t -> float 

  (** Returns a pretty-printed string (not for serialization) *)
  val print : t -> string

  (** $direction u v$ returns the normalized direction vector from $u$ to $v$.
    * Raises Vector3f_exception if $u = v$. *)
  val direction : t -> t -> t

  (** $endpoint a v t$ returns the point $a + tv$ *)
  val endpoint : t -> t -> float -> t

end


(** Operations on immutable vectors of 3 floats represented in spherical coordinates *)
module Vector3fs : sig

  (** This module defines the vector3fs type and various operations on it. *)

  (** Raised when an error occurs (usually a division by zero) *)
  exception Vector3fs_exception of string

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

  (** Divides a vector by a scalar. Raises Vector3fs_exception if the scalar is zero. *)
  val div : float -> t -> t

  (** Converts a vector represented in spherical coordinates to a vector represented in cartesian coordinates 
    * @see:OgamlMath.Vector3f *)
  val to_cartesian : t -> Vector3f.t

  (** Converts a vector represented in cartesian coordinates to a vector represented in spherical coordinates 
    * @see:OgamlMath.Vector3f *)
  val from_cartesian : Vector3f.t -> t

  (** Computes the norm of a vector *)
  val norm : t -> float

  (** Normalizes a vector. Raises Vector3fs_exception if the vector is zero. *)
  val normalize : t -> t

  (** Returns a pretty-printed string (not for serialization) *)
  val print : t -> string

end


(** Operations on immutable quaternions *)
module Quaternion : sig

  (** This module defines the quaternion type and various operations on it *)

  (** Raised when an error occurs (usually a division by zero) *)
  exception Quaternion_exception of string

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

  (** Returns the inverse of a quaternion. Raises Quaternion_exception if the quaternion is zero *)
  val inverse : t -> t

  (** Returns the squared norm of a quaternion *)
  val squared_norm : t -> float

  (** Returns the norm of a quaternion *)
  val norm : t -> float

  (** Normalizes a quaternion. Raises Quaternion_exception if the quaternion is zero *)
  val normalize : t -> t 

end


(** Provides easy creation and manipulation of rendering matrices *)
module Matrix3D : sig

  (** Optimized operations on 3D (4x4) float matrices *)

  (** Raised when an error occurs (usually a division by zero) *)
  exception Matrix3D_exception of string


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

  (** Builds a rotation matrix from an axis and an angle @see:OgamlMath.Vector3f *)
  val rotation : Vector3f.t -> float -> t

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
    * @see:OgamlMath.Vector3f *)
  val rotate : Vector3f.t -> float -> t -> t

  (** Computes the (right-)product of a matrix with a column vector
    * @see:OgamlMath.Vector3f *)
  val times : t -> Vector3f.t -> Vector3f.t

  (** Returns a pretty-printed string (not for serialization) *)
  val print : t -> string


  (*** Rendering Matrices Creation *)

  (** Builds a "look-at" view matrix.
    * Raises Matrix3D_exception if $up = zero$.
    * @see:OgamlMath.Vector3f *)
  val look_at : from:Vector3f.t -> at:Vector3f.t -> up:Vector3f.t -> t

  (** Builds a "look-at" view matrix from eulerian angles. 
    * Theta should be in [0;2pi] and phi in [-pi/2;pi/2]. 
    * If phi = pi/2, the camera is looking up (towards positive Y). 
    * If theta = 0, the camera is looking towards negative Z. 
    * @see:OgamlMath.Vector3f *)
  val look_at_eulerian : from:Vector3f.t -> theta:float -> phi:float -> t

  (** Builds an orthographic projection matrix englobing a volume defined by six planes. 
    * Raises Matrix3D_exception if $right = left$ or $near = far$ or $top = bottom$ *)
  val orthographic : right:float -> left:float -> near:float -> far:float ->
      top:float -> bottom:float -> t

  (** Builds the inverse of an orthographic projection matrix *)
  val iorthographic : right:float -> left:float -> near:float -> far:float ->
      top:float -> bottom:float -> t

  (** Builds a perspective projection matrix. Near and far are the positions
    * of the clipping planes relatively to the camera position (nothing will
    * be rendered outside those planes). Width and height should usually be 
    * the dimensions of the screen in pixels. Fov corresponds to the view 
    * angle, and is given in radians.
    *
    * Raises Matrix3D_exception if $near = far$. *)
  val perspective : near:float -> far:float -> width:float -> height:float ->
      fov:float -> t

  (** Builds the inverse of a perspective projection matrix *)
  val iperspective : near:float -> far:float -> width:float -> height:float ->
      fov:float -> t

  (*** Other functions *)

  (** Returns a matrix as a flat bigarray. Used internally by OGAML, it should not be necessary for your programs. *)
  val to_bigarray : t -> (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t


end

