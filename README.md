# Requirements

OCaml, ocamlbuild, ocamllex and Menhir.

# Build

```shell
$ make
```

# Run

Now we can generate some .wav-file.

For example, the following code:

```
𝄞 -1𝅗𝅥 0𝅗𝅥 1𝅗𝅥 2𝅗𝅥 3𝅗𝅥 4𝅗𝅥 5𝅗𝅥 6𝅗𝅥 𝄽 5♩ 4♩ 3♩ 2♩ 1♩ 0♩ -1♩ ·
```

Corresponds to the following notes:

![ABC](pictures/abc.png)

In `-1𝅗𝅥`:

* Number denotes position on the stave: `1` is first line, `2` is space between first line and second line, `3` is second line etc.

* Symbol denotes note value.

To compile it, we first need to save it:

```shell
$ echo "-1𝅗𝅥 0𝅗𝅥 1𝅗𝅥 2𝅗𝅥 3𝅗𝅥 4𝅗𝅥 5𝅗𝅥 6𝅗𝅥 𝄽 5♩ 4♩ 3♩ 2♩ 1♩ 0♩ -1♩ ·" > abc.synth
```

Then run `synth`:

```shell
$ ./synth.native abc.synth -o abc.wav
```

You can find more examples in the `examples/` directory.