nasm -f elf64 -o sdl_window.o main.asm
gcc -nostartfiles -no-pie -o sdl_window sdl_window.o -lSDL2
