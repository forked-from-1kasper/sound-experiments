open Proto

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
type instrument = float -> float -> float -> float

type element =
  | Chord    of chord
  | Pause    of float
  | Clef     of clef
  | Sharp    of int
  | Flat     of int
  | Natural  of int
  | Loudness of float

type stream = element list

type instr =
  | Stream of stream
  | Speed  of float * int

type file = instr list

type cmdline =
  | Instrument of string
  | Wav        of string * string
  | Frate      of int
  | Eps        of float
  | Help

let lenghten n : float = 2.0 -. (1.0 /. (2.0 ** float_of_int n))
let value frac n = lenghten n *. (1.0 /. frac)

let mkNote pos frac n = { pos = pos; value = value frac n }
let pause frac = Pause (1.0 /. frac)

let ratio : int -> float = function
  | 0 -> raise EmptyTuplet
  | 1 -> 1.0
  | 2 -> 3.0
  | n -> float_of_int (n - 1)

let chord value xs = Chord (List.map (fun x -> { pos = x; value = value }) xs)

let beam xs frac n =
  let value = value frac n in
  List.map (chord value) xs

let tuplet xs frac n =
  let count = List.length xs in
  let src   = value frac n in
  let total = src *. ratio count in
  let value = total /. float_of_int count in
  List.map (chord value) xs