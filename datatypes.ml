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
type clef  = int -> note -> sound

type element =
  | Chord of chord
  | Pause of float
  | Clef  of clef
  | Sharp | Flat | Natural

type stream = element list

type cmdline =
  | Wav of string * string