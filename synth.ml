(* https://github.com/akabe/ocaml-numerical-analysis
   Thanks to akabe *)
open Wav
open Conv
open Lexing
open Constants
open Datatypes

let help = "Synth notes-to-wav converter

   invoke =   synth | synth list
     list = command | command list
  command = <source> -o <output>
          | -o <output> <source>"

let rec parseArgs : string list -> cmdline list = function
  | [] -> []
  | infile :: "-o" :: outfile :: rest ->
    Wav (infile, outfile) :: parseArgs rest
  | "-o" :: outfile :: infile :: rest ->
    Wav (infile, outfile) :: parseArgs rest
  | _ -> raise Proto.InvalidArguments

let defaults : cmdline list -> cmdline list = function
  | [] -> [Help]
  | xs -> xs

let parseErr f lexbuf =
  try f Lexer.main lexbuf
  with Parser.Error -> raise (Proto.Parser (lexeme_start lexbuf, lexeme_end lexbuf))

let cmd : cmdline -> unit = function
  | Help -> print_endline help
  | Wav (infile, outfile) ->
    let chan = open_in infile in
    let file = parseErr Parser.file (Lexing.from_channel chan) in
    close_in chan;
    Printf.printf "Parsed “%s” successfully!\n" infile;
    let notes = extractSound file in
    let values = initArr notes in
    List.iter (updateArr values) notes;
    Printf.printf "Writing “%s”\n" outfile;
    Wav.save ~sampling_bits:16 ~sampling_rate:frate outfile (MONORAL values)

let () =
  Array.to_list Sys.argv
  |> List.tl
  |> parseArgs
  |> defaults
  |> List.iter cmd