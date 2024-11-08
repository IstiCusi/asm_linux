# Assembler Examples on Linux (Intel/AMD 64-bit)

This repository contains various examples demonstrating assembler programming on a 64-bit Linux system (Intel/AMD architecture). The examples are meant to be educational and will be continuously updated as part of an evolving assembly programming course.

## Current Examples

### Minimalist C Example as Preparation for Assembly Programming

This example demonstrates a simple, dependency-free C program designed for low-level programming, focusing on core C features and direct system calls without standard library dependencies. It introduces basic functions for handling strings, integers, and direct output, which are helpful for transitioning to assembly language.

#### Code Overview

1. **String Length Calculation (`slength`)**:

   - This function calculates the length of a C-string by counting characters until it reaches the null terminator.

2. **Direct System Call for Writing (`swrite`)**:

   - This function directly invokes the Linux `write` system call using inline assembly. It writes data to a specified file descriptor (`fd`), making it suitable for low-level output handling. The use of `syscall` avoids any standard library dependency.

   swrite is a minimal C function that performs the Linux write system call directly
   using inline assembly, without standard library dependencies. The function takes
   three arguments: fd (file descriptor), buf (pointer to data), and
   count (number of bytes to write). It sets up these parameters in registers using
   the System V calling convention required for Linux syscalls on x86-64. Specifically,
   rax is set to 1 (syscall number for write), rdi to fd, rsi to buf, and rdx to count.
   The syscall instruction then invokes the kernel with these values. The asm volatile
   directive prevents the compiler from optimizing out the assembly block. The lack of
   output operands means this block has only side effects, with no returned values.
   The clobber list (%rax, %rdi, %rsi, %rdx, and memory) warns the compiler that these
   registers and memory may be altered (or “clobbered”) during execution, so it won’t
   store critical data there before this operation.

3. **Integer to ASCII Conversion (`itoa`)**:

   - Converts an integer to a string representation in the specified base (e.g., decimal or hexadecimal). This function supports negative numbers when using base 10.

4. **Simple Mathematical Function (`f`)**:

   - A placeholder function (`f(x) = x * x`) to perform basic integer computation.

5. **Program Execution (`main`)**:
   - Calls `f(20)` to calculate the square of 20.
   - Converts the result to a string using `itoa` and outputs it using `swrite`.
   - Outputs a newline to the console.

This minimalistic approach lays a foundation for understanding direct system calls and C fundamentals that will be useful when transitioning to assembly programming.

### Simple SDL Rectangle Drawing (nasm_sdl_simple)

Located in the `nasm_sdl_simple` subfolder, this example includes a NASM source code file (`main.asm`) that demonstrates a simple application using the SDL library to draw a red rectangle on the screen. The `main.asm` file is thoroughly documented to provide newcomers with a smooth introduction to Linux assembly.

#### Compilation

To compile the `main.asm` to an executable, run the `compile.sh` script located in the same folder. This script performs the following tasks:

1. Compiles `main.asm` to an object file (`main.o`) using NASM.
2. Links `main.o` to create an executable file (`main`) using GCC, while ensuring that the startup files and Position Independent Execution (PIE) are disabled, and linking against the SDL2 library.
3. Analyzes the global symbol table at different stages:
   - After compilation, focusing on SDL symbols.
   - After linking, focusing on SDL symbols and offsets.
   - After startup, focusing on shared libraries binding, using GDB to extract function information.

The analysis results are logged into `sym_obj.log`, `sym_lin.log`, and `sym_exe.log` respectively.

#### Execution

Upon execution, the program follows these steps:

1. Initializes SDL with video support.
2. Creates an SDL window with specified dimensions.
3. Creates a renderer for the window.
4. Sets the render color to red.
5. Calls a subroutine `calc_rect` to calculate the dimensions of the rectangle to be drawn.
6. Draws a red rectangle on the window.
7. Renders the scene.
8. Delays for 7 seconds to allow viewing the result.
9. Destroys the renderer and window to free up resources.
10. Quits SDL and exits the program.

Each step corresponds to a specific block of assembly code in `main.asm`, well-documented to explain the operations and the utilization of the SDL2 library in assembly language.

## Tools

Adjacent to the example subfolders at the root level, there is a `tools` folder containing C programs to further investigate the outcomes of the examples.

### Symbol Table Reader (symtab)

The `symtab` folder within `tools` contains `read_symtab` and `read_symtab.c` which provide functionality to read and analyze the symbol table generated from the assembly and linking process. The `read_symtab.c` program reads an ELF (Executable and Linkable Format) file, extracts, and prints the symbol table of the file. It demonstrates how to use the ELF header and section header table to locate the symbol table and the string table sections, and then how to read and print the symbols.

#### Usage

1. Compile the `read_symtab.c` source file.
2. Run `read_symtab` with the ELF file as argument: `./read_symtab <elf_file>`.

This program is useful for understanding the structure of ELF files and how symbols are stored and accessed in an ELF file.

### Tag Copy

Simple neovim function to add to your config.lua file for copying
function declarations from headers to the asm files for easy reference,
so that at the beginning of the copied string you find the file name,
where the declaration was extracted and the linenumber in the following
format &lt;file&gt;:&lt;linenumber&gt; Yanked Text

## Future Work

More examples and tools will be added to this repository to form a comprehensive course on assembly programming on Linux. Stay tuned for updates!

## Contributing

Feel free to explore the repository, and contributions to expand the educational content are welcomed.

## License

This project is open-source and available under the [MIT License](LICENSE).

## Author

- [Stephan Strauss](https://github.com/IstiCusi)
