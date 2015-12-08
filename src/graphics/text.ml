
type t = (Font.code * Font.Glyph.t) list

let create ~text ~position ~font ~size ~bold =
  let length = String.length text in
  let rec iter i =
    if i >= length then []
    else begin
      let code = (`Char text.[i]) in
      let glyph = Font.glyph font code size bold in
      (code,glyph) :: (iter (i+1))
    end
  in
  iter 0
