open Utils

type code = int

type t = code array

let empty () = [||]

let make l c = 
  if c < 0 || c > 0b1111111111111111111111111111111 then
    Error `Invalid_UTF8_code
  else Ok (Array.make l c)

let get s i = 
  if i >= Array.length s || i < 0 then
    Error `Out_of_bounds
  else
    Ok s.(i)

let set s i c = 
  if i >= Array.length s || i < 0 then
    Error `Out_of_bounds
  else if c < 0 || c > 0b1111111111111111111111111111111 then
    Error `Invalid_UTF8_code
  else begin
    s.(i) <- c; Ok ()
  end

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
    if i > j then Ok 0
    else if i >= String.length s || ((Char.code s.[i]) land 0b11000000 <> 0b10000000) then
      Error `Invalid_UTF8_bytes
    else begin
      get_6bit_values (i+1) j >>>= fun vl ->
      (((Char.code s.[i]) land 0b00111111) lsl ((j-i)*6)) + vl 
    end
  in
  let get_char_at i = 
    let c = Char.code s.[i] in
    if c <= 127 then Ok (c, i+1)
    else if c land 0b11100000 = 0b11000000 then 
      ((get_6bit_values (i+1) (i+1)) >>>= fun v -> (c land 0b00011111) lsl 6 + v, i+2)
    else if c land 0b11110000 = 0b11100000 then
      ((get_6bit_values (i+1) (i+2)) >>>= fun v -> (c land 0b00001111) lsl 12 + v, i+3)
    else if c land 0b11111000 = 0b11110000 then
      ((get_6bit_values (i+1) (i+3)) >>>= fun v -> (c land 0b00000111) lsl 18 + v, i+4)
    else if c land 0b11111100 = 0b11111000 then
      ((get_6bit_values (i+1) (i+4)) >>>= fun v -> (c land 0b00000011) lsl 24 + v, i+5)
    else if c land 0b11111110 = 0b11111100 then
      ((get_6bit_values (i+1) (i+5)) >>>= fun v -> (c land 0b00000001) lsl 30 + v, i+6)
    else Error `Invalid_UTF8_leader
  in
  let rec iter i = 
    if i >= String.length s then Ok []
    else begin
      get_char_at i >>= fun (c,nxt) ->
      iter nxt >>>= fun tail ->
      c :: tail
    end
  in
  iter 0 >>>= Array.of_list

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
  let arr = Array.make (Array.length s) 0 in
  let rec aux i = 
    if i >= Array.length s then Ok ()
    else begin
      let c' = f s.(i) in
      if c' < 0 || c' > 0b1111111111111111111111111111111 then
        Error `Invalid_UTF8_code
      else begin
        arr.(i) <- c';
        aux (i+1)
      end
    end
  in
  aux 0 >>>= fun () -> arr


