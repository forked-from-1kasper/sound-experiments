open Datatypes

let getAccidental (xs : accidentals) x =
  match Lines.find_opt x xs with
  | Some x -> x
  | None   -> 0

let sharp   (xs : accidentals) x = Lines.add x (getAccidental xs x + 1) xs
let flat    (xs : accidentals) x = Lines.add x (getAccidental xs x - 1) xs
let natural (xs : accidentals) x = Lines.add x 0 xs