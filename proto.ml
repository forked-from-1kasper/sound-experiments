exception InvalidNote of int
exception Parser of int * int
exception Lexer of int * int * string
exception InvalidArguments
exception NoClef

let pi    = 3.141592653589793
let tau   = 2.0 *. pi

let eps = 0.00000001

let listGetMax (f : 'a -> 'b) (xs : 'a list) (zero : 'b) : 'b =
  let maximum : 'b ref = ref zero in
  List.iter (fun x -> let v = f x in if v > !maximum then maximum := v else ()) xs;
  !maximum

let arrayGetMax (f : 'a -> 'b) (xs : 'a array) (zero : 'b) : 'b =
  let maximum : 'b ref = ref zero in
  Array.iter (fun x -> let v = f x in if v > !maximum then maximum := v else ()) xs;
  !maximum

let mapSum (f : 'a -> float) (xs : 'a list) : float =
  List.fold_left (fun x v -> x +. f v) 0.0 xs

(* Compatibility with OCaml 4.05
   From: https://github.com/ocaml/ocaml/blob/trunk/stdlib/list.ml *)
let filterMap f =
  let rec aux accu = function
    | [] -> List.rev accu
    | x :: l ->
      match f x with
      | None -> aux accu l
      | Some v -> aux (v :: accu) l
  in aux []

let concatMap f l =
  let rec aux f acc = function
    | [] -> List.rev acc
    | x :: l ->
       let xs = f x in
       aux f (List.rev_append xs acc) l
in aux f [] l