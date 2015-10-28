open OgamlMath

let () = 
  Vector3f.unit_z
  |> Vector3fs.from_cartesian
  |> Vector3fs.print
  |> Printf.printf "unit_z : %s\n%!";
  Vector3f.unit_z
  |> Vector3f.prop (-1.)
  |> Vector3fs.from_cartesian
  |> Vector3fs.prop (-1.)
  |> Vector3fs.to_cartesian
  |> Vector3f.print
  |> Printf.printf "unit_z : %s\n%!";
  Vector3f.unit_x
  |> Vector3fs.from_cartesian
  |> Vector3fs.print
  |> Printf.printf "unit_x : %s\n%!";
  Vector3f.unit_x
  |> Vector3f.prop (-1.)
  |> Vector3fs.from_cartesian
  |> Vector3fs.prop (-1.)
  |> Vector3fs.to_cartesian
  |> Vector3f.print
  |> Printf.printf "unit_x : %s\n%!";
  Vector3f.unit_y
  |> Vector3fs.from_cartesian
  |> Vector3fs.print
  |> Printf.printf "unit_y : %s\n%!";
  Vector3f.unit_y
  |> Vector3f.prop (-1.)
  |> Vector3fs.from_cartesian
  |> Vector3fs.prop (-1.)
  |> Vector3fs.to_cartesian
  |> Vector3f.print
  |> Printf.printf "unit_y : %s\n%!";
  Vector3f.({x = 8.731; y = 23.121; z = -12.232})
  |> Vector3fs.from_cartesian
  |> Vector3fs.to_cartesian
  |> Vector3f.print
  |> Printf.printf "Vector 8.731, 23.121, -12.232 : %s\n%!"
