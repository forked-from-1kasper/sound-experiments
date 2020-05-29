let frate    : int ref   = ref 11025
let elemSecs : float ref = ref 1.81405
let eps      : float ref = ref 0.00000001

let noteDecayRate = ref 10.0

let elemTick () = !elemSecs *. float_of_int !frate