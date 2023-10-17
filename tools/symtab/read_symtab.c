#include <stdio.h>
#include <stdlib.h>
#include <elf.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/mman.h>

void print_symbols(char* elf_data) {
  Elf64_Ehdr* elf_header           = (Elf64_Ehdr*) elf_data;
  Elf64_Shdr* section_header_table = (Elf64_Shdr*)(elf_data + elf_header->e_shoff);

    // Find the symbol table section
    Elf64_Shdr* symtab_section = NULL;
    for (int i = 0; i < elf_header->e_shnum; i++) {
        if (section_header_table[i].sh_type == SHT_SYMTAB) {
            symtab_section = &section_header_table[i];
            break;
        }
    }
    if (!symtab_section) {
        fprintf(stderr, "Symbol table not found in the ELF file.\n");
        return;
    }

    // Calculate the number of symbols
    size_t num_symbols = symtab_section->sh_size / sizeof(Elf64_Sym);

    // Find the string table section for symbol names
    Elf64_Shdr* strtab_section = &section_header_table[symtab_section->sh_link];
    char* strtab = elf_data + strtab_section->sh_offset;

    // Get the symbol table
    Elf64_Sym* symbol_table = (Elf64_Sym*)(elf_data + symtab_section->sh_offset);

    printf("Symbol table:\n");
    printf("   Num:    Value          Size Type    Bind   Vis      Ndx Name\n");

    // Print the symbol table
    for (size_t i = 0; i < num_symbols; i++) {
        printf("%6zu: %016lx %8lx %-6s %-6s %-7s %3u %s\n",
            i,
            (unsigned long)symbol_table[i].st_value,
            (unsigned long)symbol_table[i].st_size,
            (symbol_table[i].st_info & 0xf) == STT_FUNC ? "FUNC" : "OBJECT",
            (symbol_table[i].st_info >> 4) == STB_GLOBAL ? "GLOBAL" : "LOCAL",
            symbol_table[i].st_other == STV_DEFAULT ? "DEFAULT" :
            (symbol_table[i].st_other == STV_HIDDEN ? "HIDDEN" : "INTERNAL"),
            symbol_table[i].st_shndx,
            strtab + symbol_table[i].st_name);
    }
}

int main(int argc, char** argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <elf_file>\n", argv[0]);
        return 1;
    }

    int fd = open(argv[1], O_RDONLY);
    if (fd == -1) {
        perror("open");
        return 1;
    }

    struct stat file_stat;
    if (fstat(fd, &file_stat) == -1) {
        perror("fstat");
        close(fd);
        return 1;
    }

    char* elf_data = mmap(NULL, file_stat.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    if (elf_data == MAP_FAILED) {
        perror("mmap");
        close(fd);
        return 1;
    }

    print_symbols(elf_data);

    munmap(elf_data, file_stat.st_size);
    close(fd);

    return 0;
}

