open Proto
open Constants
open Datatypes

let extractNotes (xs : stream) =
  let clef       : clef ref = ref (fun _ -> raise NoClef) in
  let accidental : int ref  = ref 0 in
  let convert : element -> (sound list) option = (function
    | Chord xs -> Some (List.map (!clef !accidental) xs)
    | Pause x  -> Some [ Silence x ]
    | Clef f   -> clef := f; None
    | Sharp    -> accidental := !accidental + 1; None
    | Flat     -> accidental := !accidental - 1; None
    | Natural  -> accidental := 0; None) in
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
    | Wave { freq = freq; value = value } ->
      Wave.piano freq value (t -. delta) in
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