let frate = 11025
let elemSecs : float ref = ref 1.81405
let elemTick () = !elemSecs *. float_of_int frate