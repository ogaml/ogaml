type t = {r : float; i : float; j : float; k : float}

val zero : t

val one : t

val real : float -> t

val add : t -> t -> t

val times : t -> t -> t 

val prop : float -> t -> t 

val sub : t -> t -> t 

val rotation : Vector3f.t -> float -> t 

val conj : t -> t

val inverse : t -> t

val squared_norm : t -> float

val norm : t -> float

val normalize : t -> t 

