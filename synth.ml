(* https://github.com/akabe/ocaml-numerical-analysis
   Thanks to akabe *)
open Wav
open Conv
open Lexing
open Constants
open Datatypes

let source : stream list =
  [ [ Clef Clef.g4;
      Chord [ { pos = -1; value = 1.0 } ];
      Chord [ { pos =  0; value = 0.5 } ];
      Chord [ { pos =  1; value = 1.0 } ];
      Chord [ { pos =  2; value = 0.5 } ];
      Chord [ { pos =  3; value = 1.0 } ];
      Chord [ { pos =  4; value = 0.5 } ];
      Chord [ { pos =  5; value = 1.0 } ];
      Chord [ { pos =  6; value = 0.5 } ];
      Pause 1.0 ];
    [ Clef Clef.f3;
      Chord [ { pos = -1; value = 1.0 } ];
      Chord [ { pos =  1; value = 1.0 } ] ] ]

let rec parseArgs : string list -> cmdline list = function
  | [] -> []
  | infile :: "-o" :: outfile :: rest ->
    Wav (infile, outfile) :: parseArgs rest
  | "-o" :: outfile :: infile :: rest ->
    Wav (infile, outfile) :: parseArgs rest
  | _ -> raise Proto.InvalidArguments

let parseErr f lexbuf =
  try f Lexer.main lexbuf
  with Parser.Error -> raise (Proto.Parser (lexeme_start lexbuf, lexeme_end lexbuf))

let cmd : cmdline -> unit = function
  | Wav (infile, outfile) ->
    let chan = open_in infile in
    let stream = parseErr Parser.file (Lexing.from_channel chan) in
    close_in chan;
    Printf.printf "Parsed “%s” successfully!\n" infile;
    let notes = List.map extractNotes stream in
    let values = initArr notes in
    List.iter (updateArr values) notes;
    Printf.printf "Writing “%s”\n" outfile;
    Wav.save ~sampling_bits:16 ~sampling_rate:frate outfile (MONORAL values)

let () =
  Array.to_list Sys.argv
  |> List.tl
  |> parseArgs
  |> List.iter cmd