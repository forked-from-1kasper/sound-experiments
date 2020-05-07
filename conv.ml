open Proto
open Constants
open Datatypes
open Accidentals

let extractNotes (xs : stream) =
  let clef        : clef ref        = ref (fun _ -> raise NoClef) in
  let accidentals : accidentals ref = ref Lines.empty in
  let loudness    : float ref       = ref 1.0 in
  let convert : element -> (sound list) option = (function
    | Chord xs   -> Some (List.map (!clef !accidentals !loudness) xs)
    | Pause x    -> Some [ Silence x ]
    | Loudness x -> loudness := x; None
    | Clef f     -> clef := f; None
    | Sharp   x  -> accidentals := sharp   !accidentals x; None
    | Flat    x  -> accidentals := flat    !accidentals x; None
    | Natural x  -> accidentals := natural !accidentals x; None) in
  filterMap convert xs

let getValue : sound -> float = function
  | Wave { value = x } -> x
  | Silence x          -> x

let totalTicks notes =
  let duration = mapSum (fun xs -> listGetMax getValue xs 0.0
                                *. noteDurationTicks) notes in
  int_of_float duration

let soundsToFuncs notes : (float -> float) array =
  let waves  : (float -> float) array = Array.make (List.length notes) (fun x -> x) in
  let passed : float ref = ref 0.0 in
  let getLoudness delta t : sound -> float = function
    | Silence _ -> 0.0
    | Wave { freq = freq; value = value; loudness = k } ->
      k *. Wave.piano freq value (t -. delta) in
  let genWave i xs =
    let delta = !passed in
    waves.(i) <- (fun t -> mapSum (getLoudness delta t) xs);
    passed := delta +. noteDurationSecs *. listGetMax getValue xs 0.0 in
  List.iteri genWave notes; waves

let updateArr (xs : float array) ys : unit =
  let ticks = totalTicks ys in
  let waves = soundsToFuncs ys in
  for i = 0 to ticks - 1 do
    let t = float_of_int i /. float_of_int frate in
    xs.(i) <- xs.(i) +. Array.fold_left (fun x f -> x +. f t) 0.0 waves;
  done;
  let maximum = arrayGetMax abs_float xs 0.0 +. eps in
  for i = 0 to ticks - 1 do xs.(i) <- xs.(i) /. maximum done

let initArr xs = Array.make (listGetMax totalTicks xs 0) 0.0