let frate    = ref 11025
let elemSecs = ref 1.81405
let eps      = ref 0.00000001

let noteDecayRate = ref 10.0

let elemTick () = !elemSecs *. float_of_int !frate