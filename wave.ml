open Proto

let overtones freq x =
  sin (1.0 *. tau *. freq *. x) *. exp (-0.0004 *. tau *. freq *. x) /. 1.0  +.
  sin (2.0 *. tau *. freq *. x) *. exp (-0.0004 *. tau *. freq *. x) /. 2.0  +.
  sin (3.0 *. tau *. freq *. x) *. exp (-0.0004 *. tau *. freq *. x) /. 4.0  +.
  sin (4.0 *. tau *. freq *. x) *. exp (-0.0004 *. tau *. freq *. x) /. 8.0  +.
  sin (5.0 *. tau *. freq *. x) *. exp (-0.0004 *. tau *. freq *. x) /. 16.0 +.
  sin (6.0 *. tau *. freq *. x) *. exp (-0.0004 *. tau *. freq *. x) /. 32.0

let piano' freq value x =
  (overtones freq x ** 3.0) *.
    (1.0 +. 16.0 *. x *. exp (-6.0 *. value *. x))
let piano freq value x = if x >= 0.0 then piano' freq value x else 0.0