%{
  open Datatypes
%}

%token G4 F3 C4
%token WHOLE  HALF  QUARTER  EIGHTH  SIXTEENTH
%token THIRTYSECOND SIXTYFOURTH TWENTYEIGHTH
%token RWHOLE RHALF RQUARTER REIGHTH RSIXTEENTH
%token RTHIRTYSECOND RSIXTYFOURTH RTWENTYEIGHTH
%token POINT SHARP FLAT NATURAL BARLINE
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

value:
  | WHOLE        {   1.0 }
  | HALF         {   2.0 }
  | QUARTER      {   4.0 }
  | EIGHTH       {   8.0 }
  | SIXTEENTH    {  16.0 }
  | THIRTYSECOND {  32.0 }
  | SIXTYFOURTH  {  64.0 }
  | TWENTYEIGHTH { 128.0 }

elem:
  | INT value points { mkNote $1 $2 $3 }

pause:
  | RWHOLE        { pause   1.0 }
  | RHALF         { pause   2.0 }
  | RQUARTER      { pause   4.0 }
  | REIGHTH       { pause   8.0 }
  | RSIXTEENTH    { pause  16.0 }
  | RTHIRTYSECOND { pause  32.0 }
  | RSIXTYFOURTH  { pause  64.0 }
  | RTWENTYEIGHTH { pause 128.0 }

clef:
  | G4 { Clef.g4 }
  | F3 { Clef.f3 }
  | C4 { Clef.c4 }

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
  | LSQBRACKET couples RSQBRACKET value points
    { tuplet $2 $4 $5 }
  | LBRACKET   couples RBRACKET   value points
    { beam   $2 $4 $5 }
  | chord       { [Chord $1]      }
  | clef        { [Clef $1]       }
  | pause       { [$1]            }
  | FLOAT       { [Loudness $1]   }
  | INT SHARP   { [Sharp $1]      }
  | INT FLAT    { [Flat $1]       }
  | INT NATURAL { [Natural $1]    }
  | BARLINE     { [Barline] }

stream:
  | element        { $1      }
  | element stream { $1 @ $2 }

file:
  | EOF                  { []                   }
  | value DEFEQ INT file { Speed ($1, $3) :: $4 }
  | stream END file      { Stream $1 :: $3      }