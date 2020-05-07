type note =
  { pos   : int;
    value : float }

type wave =
  { value    : float;
    freq     : float;
    loudness : float }

type sound =
  | Wave    of wave
  | Silence of float

type chord = note list

module Lines = Map.Make(struct type t = int let compare = compare end)
type accidentals = int Lines.t

type clef = accidentals -> float -> note -> sound

type element =
  | Chord of chord
  | Pause of float
  | Clef of clef
  | Sharp of int
  | Flat of int
  | Natural of int
  | Loudness of float

type stream = element list

type cmdline =
  | Wav of string * string

let lenghten n : float = 2.0 -. (1.0 /. (2.0 ** float_of_int n))
let mkNote pos frac n = { pos = pos; value = lenghten n *. (1.0 /. frac) }