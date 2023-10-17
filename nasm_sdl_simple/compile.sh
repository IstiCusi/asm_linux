clear
#set -xe

YE='\033[1;33m'
NC='\033[0m' 

# ------------------- Clean Up ------------------

if [ "$1" = "clean" ]; then
    rm -f *.log *.o
    [ -f ./main ] && rm -f ./main
    exit 0
fi

## ----------------- Compile ---------------------

nasm -f elf64 -o main.o main.asm
gcc -g -nostartfiles -no-pie -o main main.o -lSDL2

## ----------------- Analyse ---------------------

../tools/symtab/read_symtab ./main.o > sym_obj.log
../tools/symtab/read_symtab ./main   > sym_lin.log
echo "${YE}Global Symbol table after compilation${NC}"
cat ./sym_obj.log | awk '/SDL_/ {print $2, $8}'
echo "${YE}Global Symbol table after linking (PIE)${NC}"
cat ./sym_lin.log | awk '/SDL_|OFFSET/ {print $2, $8}'
echo "${YE}Global Symbol table after startup (Shared libraries binding)${NC}"
gdb -batch -ex "file ./main" -ex "info functions" > sym_exe.log
tail -n +4 ./sym_exe.log


