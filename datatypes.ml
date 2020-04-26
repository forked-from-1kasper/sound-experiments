type note =
  { pos   : int;
    value : float }

type wave =
  { value : float;
    freq  : float }

type sound =
  | Wave    of wave
  | Silence of float

type chord = note list

module Lines = Map.Make(struct type t = int let compare = compare end)
type accidentals = int Lines.t

type clef = accidentals -> note -> sound

type element =
  | Chord of chord
  | Pause of float
  | Clef of clef
  | Sharp of int
  | Flat of int
  | Natural of int

type stream = element list

type cmdline =
  | Wav of string * string