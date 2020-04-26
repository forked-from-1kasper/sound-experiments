%{
  open Datatypes
%}

%token G4 F3
%token WHOLE  HALF  QUARTER  EIGHTH  SIXTEENTH
%token RWHOLE RHALF RQUARTER REIGHTH RSIXTEENTH
%token POINT SHARP FLAT NATURAL
%token END EOF
%token LCURVBRACKET RCURVBRACKET
%token <int> LINE

%start <Datatypes.stream list> file

%%

points:
  | POINT* { List.length $1 }

note:
  | LINE WHOLE     points { mkNote $1  1.0 $3 }
  | LINE HALF      points { mkNote $1  2.0 $3 }
  | LINE QUARTER   points { mkNote $1  4.0 $3 }
  | LINE EIGHTH    points { mkNote $1  8.0 $3 }
  | LINE SIXTEENTH points { mkNote $1 16.0 $3 }

pause:
  | RWHOLE     { Pause 1.0           }
  | RHALF      { Pause (1.0 /.  2.0) }
  | RQUARTER   { Pause (1.0 /.  4.0) }
  | REIGHTH    { Pause (1.0 /.  8.0) }
  | RSIXTEENTH { Pause (1.0 /. 16.0) }

clef:
  | G4 { Clef.g4 }
  | F3 { Clef.f3 }

cochord:
  | note         { [$1]     }
  | note cochord { $1 :: $2 }

chord:
  | note                              { [$1] }
  | LCURVBRACKET cochord RCURVBRACKET { $2   }

element:
  | chord        { Chord $1   }
  | clef         { Clef $1    }
  | pause        { $1         }
  | LINE SHARP   { Sharp $1   }
  | LINE FLAT    { Flat $1    }
  | LINE NATURAL { Natural $1 }

stream:
  | element        { [$1]     }
  | element stream { $1 :: $2 }

file:
  | stream END EOF  { [$1]     }
  | stream END file { $1 :: $3 }