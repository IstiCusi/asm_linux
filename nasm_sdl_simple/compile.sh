set -xe
nasm -f elf64 -o main.o main.asm
gcc -nostartfiles -no-pie -o main main.o -lSDL2
