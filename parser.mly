%{
  open Datatypes
%}

%token G4 F3
%token WHOLE  HALF  QUARTER  EIGHTH  SIXTEENTH
%token RWHOLE RHALF RQUARTER REIGHTH RSIXTEENTH
%token POINT SHARP FLAT NATURAL
%token DEFEQ END EOF
%token LBRACKET RBRACKET
%token LSQBRACKET RSQBRACKET
%token LCURVBRACKET RCURVBRACKET
%token <int> INT
%token <float> FLOAT

%start <Datatypes.file> file

%%

points:
  | POINT* { List.length $1 }

note:
  | WHOLE     {  1.0 }
  | HALF      {  2.0 }
  | QUARTER   {  4.0 }
  | EIGHTH    {  8.0 }
  | SIXTEENTH { 16.0 }

elem:
  | INT note points { mkNote $1 $2 $3 }

pause:
  | RWHOLE     { pause  1.0 }
  | RHALF      { pause  2.0 }
  | RQUARTER   { pause  4.0 }
  | REIGHTH    { pause  8.0 }
  | RSIXTEENTH { pause 16.0 }

clef:
  | G4 { Clef.g4 }
  | F3 { Clef.f3 }

cochord:
  | elem         { [$1]     }
  | elem cochord { $1 :: $2 }

ints:
  | INT      { [$1]     }
  | INT ints { $1 :: $2 }

chord:
  | elem                                   { [$1]            }
  | LCURVBRACKET cochord RCURVBRACKET      { $2              }

couple:
  | INT                            { [$1] }
  | LCURVBRACKET ints RCURVBRACKET { $2   }

couples:
  | couple         { [$1]     }
  | couple couples { $1 :: $2 }

element:
  | LSQBRACKET couples RSQBRACKET note points
    { tuplet $2 $4 $5 }
  | LBRACKET   couples RBRACKET   note points
    { beam   $2 $4 $5 }
  | chord       { [Chord $1]      }
  | clef        { [Clef $1]       }
  | pause       { [$1]            }
  | FLOAT       { [Loudness $1]   }
  | INT SHARP   { [Sharp $1]      }
  | INT FLAT    { [Flat $1]       }
  | INT NATURAL { [Natural $1]    }

stream:
  | element        { $1      }
  | element stream { $1 @ $2 }

file:
  | EOF                 { []                   }
  | note DEFEQ INT file { Speed ($1, $3) :: $4 }
  | stream END file     { Stream $1 :: $3      }