open Proto
open Datatypes
open Accidentals

let clean : int -> int = function
  | 0 -> 0  | 1 -> 2
  | 2 -> 4  | 3 -> 5
  | 4 -> 7  | 5 -> 9
  | 6 -> 11 | v -> raise (InvalidNote v)

let (%) a b  = let c = a mod b in if c >= 0 then c else b + c

(* Performs floor division by 7 *)
let octave x = if x >= 0 then x / 7 else (x + 1) / 7 - 1

let g4 accidentals (x : note) : sound =
  let pos        = x.pos + 1 in
  let note       = pos % 7 in
  let octave     = octave pos in
  let accidental = getAccidental accidentals x.pos in
  let semitone   = clean note + accidental + octave * 12 in
  let interval   = 2.0 ** (float_of_int semitone /. 12.0) in
  Wave { value = x.value; freq = 261.63 *. interval }

let f3 accidental (x : note) : sound =
  g4 accidental { pos   = x.pos - 12;
                  value = x.value }