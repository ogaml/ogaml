
type code = int

type t = code array

let empty () = [||]

let make l c = 
  if c < 0 || c > 0b1111111111111111111111111111111 then
    raise (Invalid_argument "UTF8String.make: invalid code")
  else Array.make l c

let get s i = 
  if i >= Array.length s || i < 0 then
    raise (Invalid_argument "UTF8String.get: index out of bounds") 
  else
    s.(i)

let set s i c = 
  if i >= Array.length s || i < 0 then
    raise (Invalid_argument "UTF8String.set: index out of bounds")
  else if c < 0 || c > 0b1111111111111111111111111111111 then
    raise (Invalid_argument "UTF8String.set: invalid code")
  else
    s.(i) <- c

let length s = Array.length s

let byte_length s = 
  Array.fold_left (fun v c ->
    if c <= 0b01111111 then (v+1)
    else if c <= 0b11111111111 then (v+2)
    else if c <= 0b1111111111111111 then (v+3)
    else if c <= 0b111111111111111111111 then (v+4)
    else if c <= 0b11111111111111111111111111 then (v+5)
    else (v+6)
  ) 0 s 

let from_string s = 
  let rec get_6bit_values i j = 
    if i > j then 0
    else if i >= String.length s || ((Char.code s.[i]) land 0b11000000 <> 0b10000000) then
      raise (Invalid_argument "UTF8String.from_string: invalid byte sequence")
    else begin
      (((Char.code s.[i]) land 0b00111111) lsl ((j-i)*6)) + (get_6bit_values (i+1) j)
    end
  in
  let rec iter i = 
    if i >= String.length s then []
    else begin
      let c = Char.code s.[i] in
      if c <= 127 then c :: (iter (i+1))
      else if c land 0b11100000 = 0b11000000 then 
        (((c land 0b00011111) lsl 6)  + (get_6bit_values (i+1) (i+1))) :: (iter (i+2))
      else if c land 0b11110000 = 0b11100000 then
        (((c land 0b00001111) lsl 12) + (get_6bit_values (i+1) (i+2))) :: (iter (i+3))
      else if c land 0b11111000 = 0b11110000 then
        (((c land 0b00000111) lsl 18) + (get_6bit_values (i+1) (i+3))) :: (iter (i+4))
      else if c land 0b11111100 = 0b11111000 then
        (((c land 0b00000011) lsl 24) + (get_6bit_values (i+1) (i+4))) :: (iter (i+5))
      else if c land 0b11111110 = 0b11111100 then
        (((c land 0b00000001) lsl 30) + (get_6bit_values (i+1) (i+5))) :: (iter (i+6))
      else raise (Invalid_argument "UTF8String.from_string: invalid leading byte")
    end
  in
  Array.of_list (iter 0)

let to_string s = 
  let str = Bytes.create (byte_length s) in
  let rec iter i curr = 
    if i >= Array.length s then ()
    else begin
      if s.(i) <= 0b01111111 then begin
        Bytes.set str curr (Char.chr s.(i));
        iter (i+1) (curr+1)
      end
      else if s.(i) <= 0b11111111111 then begin
        Bytes.set str curr (Char.chr (0b11000000 lor (s.(i) lsr 6)));
        Bytes.set str (curr+1) (Char.chr (0b10000000 lor (s.(i) land 0b111111)));
        iter (i+1) (curr+2)
      end
      else if s.(i) <= 0b1111111111111111 then begin
        Bytes.set str curr (Char.chr (0b11100000 lor (s.(i) lsr 12)));
        Bytes.set str (curr+1) (Char.chr (0b10000000 lor ((s.(i) lsr 6) land 0b111111)));
        Bytes.set str (curr+2) (Char.chr (0b10000000 lor (s.(i) land 0b111111)));
        iter (i+1) (curr+3)
      end
      else if s.(i) <= 0b111111111111111111111 then begin
        Bytes.set str curr (Char.chr (0b11110000 lor (s.(i) lsr 18)));
        Bytes.set str (curr+1) (Char.chr (0b10000000 lor ((s.(i) lsr 12) land 0b111111)));
        Bytes.set str (curr+2) (Char.chr (0b10000000 lor ((s.(i) lsr 6) land 0b111111)));
        Bytes.set str (curr+3) (Char.chr (0b10000000 lor (s.(i) land 0b111111)));
        iter (i+1) (curr+4)
      end
      else if s.(i) <= 0b11111111111111111111111111 then begin
        Bytes.set str curr (Char.chr (0b11111000 lor (s.(i) lsr 24)));
        Bytes.set str (curr+1) (Char.chr (0b10000000 lor ((s.(i) lsr 18) land 0b111111)));
        Bytes.set str (curr+2) (Char.chr (0b10000000 lor ((s.(i) lsr 12) land 0b111111)));
        Bytes.set str (curr+3) (Char.chr (0b10000000 lor ((s.(i) lsr 6) land 0b111111)));
        Bytes.set str (curr+4) (Char.chr (0b10000000 lor (s.(i) land 0b111111)));
        iter (i+1) (curr+5)
      end
      else begin
        Bytes.set str curr (Char.chr (0b11111100 lor (s.(i) lsr 30)));
        Bytes.set str (curr+1) (Char.chr (0b10000000 lor ((s.(i) lsr 24) land 0b111111)));
        Bytes.set str (curr+2) (Char.chr (0b10000000 lor ((s.(i) lsr 18) land 0b111111)));
        Bytes.set str (curr+3) (Char.chr (0b10000000 lor ((s.(i) lsr 12) land 0b111111)));
        Bytes.set str (curr+4) (Char.chr (0b10000000 lor ((s.(i) lsr 6) land 0b111111)));
        Bytes.set str (curr+5) (Char.chr (0b10000000 lor (s.(i) land 0b111111)));
        iter (i+1) (curr+6)
      end
    end
  in 
  iter 0 0;
  str

let iter s f = Array.iter f s

let fold s f v = Array.fold_left (fun a c -> f c a) v s

let map s f = 
  Array.map (fun c -> 
    let c' = f c in
    if c' < 0 || c' > 0b1111111111111111111111111111111 then
      raise (Invalid_argument "UTF8String.map: invalid code")
    else c'
  ) s


