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
          | -o <output> <source>
          | -frate <int>
          | -eps <float>
          | -instrument instr
          | -note-decay-rate <float>
    instr = piano | sinusoidal"

let rec parseArgs : string list -> cmdline list = function
  | [] -> []
  | infile :: "-o" :: outfile :: rest ->
    Wav (infile, outfile) :: parseArgs rest
  | "-o" :: outfile :: infile :: rest ->
    Wav (infile, outfile) :: parseArgs rest
  | "-frate" :: value :: rest ->
    Frate (int_of_string value) :: parseArgs rest
  | "-eps" :: value :: rest ->
    Eps (float_of_string value) :: parseArgs rest
  | "-instrument" :: value :: rest ->
    Instrument value :: parseArgs rest
  | "-note-decay-rate" :: value :: rest ->
    NoteDecayRate (float_of_string value) :: parseArgs rest
  | _ -> raise Proto.InvalidArguments

let defaults : cmdline list -> cmdline list = function
  | [] -> [Help]
  | xs -> xs

let parseErr f lexbuf =
  try f Lexer.main lexbuf
  with
    | Parser.Error -> raise (Proto.Parser (lexeme_start lexbuf, lexeme_end lexbuf))
    | Failure msg -> raise (Proto.Lexer (lexeme_start lexbuf, lexeme_end lexbuf, msg))

let cmd : cmdline -> unit = function
  | Help -> print_endline help
  | Frate value -> frate := value
  | Eps value -> eps := value
  | Instrument name ->
    Wave.instr := Wave.getInstrument name
  | NoteDecayRate value ->
    Constants.noteDecayRate := value
  | Wav (infile, outfile) ->
    let chan = open_in infile in
    let file = parseErr Parser.file (Lexing.from_channel chan) in
    close_in chan;
    Printf.printf "Parsed “%s” successfully!\n" infile; flush_all ();
    let notes = extractSound file in
    let values = initArr notes in
    print_endline "Compiling..."; flush_all ();
    List.iter (updateArr values) notes;
    print_endline "Normalizing..."; flush_all ();
    normArr values;
    Printf.printf "Writing “%s”...\n" outfile; flush_all ();
    Wav.save ~sampling_bits:16 ~sampling_rate:!frate outfile (MONORAL values);
    print_endline "Done!"

let () =
  Array.to_list Sys.argv
  |> List.tl
  |> parseArgs
  |> defaults
  |> List.iter cmd