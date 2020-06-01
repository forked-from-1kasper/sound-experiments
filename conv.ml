open Proto
open Constants
open Datatypes
open Accidentals

let extractNotes (xs : stream) =
  let clef        : clef ref        = ref (fun _ -> raise NoClef) in
  let accidentals : accidentals ref = ref Lines.empty in
  let loudness    : float ref       = ref 1.0 in
  let convert : element -> (sound list) list = function
    | Chord xs   -> [ List.map (!clef !accidentals !loudness) xs ]
    | Pause x    -> [ [ Silence x ] ]
    | Loudness x -> loudness := x; []
    | Clef f     -> clef := f; []
    | Sharp   x  -> accidentals := sharp   !accidentals x; []
    | Flat    x  -> accidentals := flat    !accidentals x; []
    | Natural x  -> accidentals := natural !accidentals x; []
    | Barline    -> accidentals := Lines.empty; [] in
  concatMap convert xs

let extractSound (xs : file) =
  let proc x =
    match x with
    | Stream xs -> Some (extractNotes xs)
    | Speed (note, value) -> 
      elemSecs := (60.0 /. float_of_int value) *. note;
      None in
  filterMap proc xs

let getValue : sound -> float = function
  | Wave { value = x } -> x
  | Silence x          -> x

let totalTicks notes =
  let duration = mapSum (fun xs -> listGetMax getValue xs 0.0
                                *. elemTick ()) notes in
  int_of_float duration

let soundsToFuncs notes : (float -> float) array =
  let waves  : (float -> float) array =
    Array.make (List.length notes) (fun x -> x) in
  let passed : float ref = ref 0.0 in
  let getLoudness delta t : sound -> float = function
    | Silence _ -> 0.0
    | Wave { freq = freq; value = value; loudness = k } ->
      k *. Wave.genSound freq value (t -. delta) in
  let genWave i xs =
    let delta = !passed in
    waves.(i) <- (fun t -> mapSum (getLoudness delta t) xs);
    passed := delta +. !elemSecs *. listGetMax getValue xs 0.0 in
  List.iteri genWave notes; waves

let updateArr (xs : float array) ys : unit =
  let ticks = totalTicks ys in
  let waves = soundsToFuncs ys in
  for i = 0 to ticks - 1 do
    let t = float_of_int i /. float_of_int !frate in
    xs.(i) <- xs.(i) +. Array.fold_left (fun x f -> x +. f t) 0.0 waves;
  done

let initArr xs = Array.make (listGetMax totalTicks xs 0) 0.0

let normArr xs =
  let maximum = arrayGetMax abs_float xs 0.0 +. !eps in
  Array.iteri (fun i x -> xs.(i) <- x /. maximum) xs