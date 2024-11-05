#include <stdlib.h>
#include <stdio.h>
#include <elf.h>

void print_elf_header(const Elf64_Ehdr *header) {
    printf("ELF Header:\n");
    printf("  Magic: ");
    for (int i = 0; i < EI_NIDENT; i++) {
        printf("%02x ", header->e_ident[i]);
    }
    printf("\n");
    printf("  Class:                             %s\n", (header->e_ident[EI_CLASS] == ELFCLASS64) ? "ELF64" : "ELF32");
    printf("  Data:                              %s\n", (header->e_ident[EI_DATA] == ELFDATA2LSB) ? "2's complement, little endian" : "2's complement, big endian");
    printf("  Version:                           %d (current)\n", header->e_ident[EI_VERSION]);
    printf("  OS/ABI:                            %s\n", (header->e_ident[EI_OSABI] == ELFOSABI_SYSV) ? "UNIX - System V" : "Other");
    printf("  ABI Version:                       %d\n", header->e_ident[EI_ABIVERSION]);
    printf("  Type:                              %s\n", (header->e_type == ET_EXEC) ? "EXEC (Executable file)" : "Other");
    printf("  Machine:                           0x%x\n", header->e_machine);
    printf("  Version:                           0x%x\n", header->e_version);
    printf("  Entry point address:               0x%lx\n", (unsigned long)header->e_entry);
    printf("  Start of program headers:          %lu (bytes into file)\n", (unsigned long)header->e_phoff);
    printf("  Start of section headers:          %lu (bytes into file)\n", (unsigned long)header->e_shoff);
    printf("  Flags:                             0x%x\n", header->e_flags);
    printf("  Size of this header:               %u (bytes)\n", header->e_ehsize);
    printf("  Size of program headers:           %u (bytes)\n", header->e_phentsize);
    printf("  Number of program headers:         %u\n", header->e_phnum);
    printf("  Size of section headers:           %u (bytes)\n", header->e_shentsize);
    printf("  Number of section headers:         %u\n", header->e_shnum);
    printf("  Section header string table index: %u\n", header->e_shstrndx);
}

int main(int argc, char** argv) {

  Elf64_Ehdr elfbuffer = { 0 };

  FILE* fd   = fopen(argv[1], "r");
  if (fd == NULL) {
    printf(" %s : Error : File not found\n", argv[0]);
    return EXIT_FAILURE;
  }

  size_t size = fread(&elfbuffer, sizeof(elfbuffer), 1, fd);
  if (size != 1) {
    printf(" *** Error *** : No correct ELF header size found\n");
  }

  print_elf_header(&elfbuffer);

  fclose(fd);
  return EXIT_SUCCESS; 
}


