# StenCToMips

The goal of this project is to implement a compiler for StenC language, write in C using Lex and Yacc tools.
This project produces a MIPS executable code corresponding to the input programs.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- [lex](https://en.wikipedia.org/wiki/Lex_(software)) : A computer program that generates lexical analyzers. 
- [yacc](https://en.wikipedia.org/wiki/Yacc) : A Look Ahead Left-to-Right (LALR) parser generator.

### compilation

Compile using the makefile : `make`.

```
- debug : Compiles in debug mode.
- clean : Clean previous compilation.
```

### use

Start the program : `./stenctomips`.

```
This executable will take standard input.
So, if you do not want to write your program in the prompt, you can redirect the standard input to a file.
Example: `$./StenCToMips.prog < file.c`.
```

## Authors

* **MANCIAUX Romain** - *Initial work* - [PamplemousseMR](https://github.com/PamplemousseMR).
* **HANSER Florian** - *Initial work* - [ResnaHF](https://github.com/ResnaHF).

## License

This project is licensed under the GNU Lesser General Public License v3.0 - see the [LICENSE.md](LICENSE.md) file for details.