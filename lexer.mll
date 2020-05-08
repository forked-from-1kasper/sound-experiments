{
  open Parser
}

let ws = ['\t' '\r' '\n' ' ']
let nl = ['\r' '\n']
let comment = ";" [^ '\n' '\r']* (nl|eof)

let integer = ['0'-'9']+
let float   = integer "." integer

rule main = parse
| ws+|comment { main lexbuf }
| '-'?['0'-'9']+ as s { INT (int_of_string s) }
| float as s          { FLOAT (float_of_string s) }
| "\xE2\x99\xAF"      { SHARP        }
| "\xE2\x99\xAD"      { FLAT         }
| "\xE2\x99\xAE"      { NATURAL      }
| "\xF0\x9D\x84\x9E"  { G4           }
| "\xF0\x9D\x84\xA2"  { F3           }
| "\xC2\xB7"          { END          }
| "\xF0\x9D\x85\x9D"  { WHOLE        }
| "\xF0\x9D\x85\x9E"  { HALF         }
| "\xE2\x99\xA9"      { QUARTER      }
| "\xE2\x99\xAA"      { EIGHTH       }
| "\xF0\x9D\x85\xA1"  { SIXTEENTH    }
| "\xF0\x9D\x84\xBB"  { RWHOLE       }
| "\xF0\x9D\x84\xBC"  { RHALF        }
| "\xF0\x9D\x84\xBD"  { RQUARTER     }
| "\xF0\x9D\x84\xBE"  { REIGHTH      }
| "\xF0\x9D\x94\xBF"  { RSIXTEENTH   }
| "{"                 { LCURVBRACKET }
| "}"                 { RCURVBRACKET }
| "."                 { POINT        }
| "="                 { DEFEQ        }
| eof                 { EOF          }