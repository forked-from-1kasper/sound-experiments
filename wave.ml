open Proto
open Datatypes

let overtones freq x =
  sin (1.0 *. tau *. freq *. x) *. exp (-0.0004 *. tau *. freq *. x) /. 1.0  +.
  sin (2.0 *. tau *. freq *. x) *. exp (-0.0004 *. tau *. freq *. x) /. 2.0  +.
  sin (3.0 *. tau *. freq *. x) *. exp (-0.0004 *. tau *. freq *. x) /. 4.0  +.
  sin (4.0 *. tau *. freq *. x) *. exp (-0.0004 *. tau *. freq *. x) /. 8.0  +.
  sin (5.0 *. tau *. freq *. x) *. exp (-0.0004 *. tau *. freq *. x) /. 16.0 +.
  sin (6.0 *. tau *. freq *. x) *. exp (-0.0004 *. tau *. freq *. x) /. 32.0

let fading freq value x =
  1.0 +. 16.0 *. x *. exp (-6.0 *. value *. x)

let piano freq value x =
  (fading freq value x) *. (overtones freq x ** 3.0)

let sinusoidal freq value x =
  (fading freq value x) *. (sin (tau *. freq *. x))

let getInstrument : string -> instrument = function
  | "piano"              -> piano
  | "sin" | "sinusoidal" -> sinusoidal
  | x                    -> raise (UnknownInstrument x)

let instr = ref piano
let genSound freq value x =
  if x < 0.0 then 0.0
  else let f = !instr freq value x in
  if x >= value then
    f /. exp (!Constants.noteDecayRate *. (x -. value))
  else f