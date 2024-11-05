typedef unsigned long size_t;

unsigned int slength(const char *str) {
  unsigned int i = 0;
  while (str[i] != '\0') {
    i++;
  }
  return i;
}

void swrite(int fd, const char *buf, size_t count) {
  asm volatile("movq $1, %%rax\n"
               "movq %0, %%rdi\n"
               "movq %1, %%rsi\n"
               "movq %2, %%rdx\n"
               "syscall"
               :
               : "r"((long)fd), "r"(buf), "r"((long)count)
               : "%rax", "%rdi", "%rsi", "%rdx", "memory");
}

void itoa(int value, char *str, int base) {
  char *ptr = str, *ptr1 = str, tmp_char;
  int tmp_value;

  if (value < 0 && base == 10) {
    *ptr++ = '-';
    value = -value;
  }

  do {
    tmp_value = value;
    value /= base;
    *ptr++ = "0123456789abcdef"[tmp_value - value * base];
  } while (value);

  *ptr-- = '\0';

  while (ptr1 < ptr) {
    tmp_char = *ptr;
    *ptr-- = *ptr1;
    *ptr1++ = tmp_char;
  }
}

int f(int x) { return x * x; }

int main() {
  char buffer[20] = {0};
  itoa(f(20), buffer, 10);
  swrite(1, buffer, slength(buffer));
  swrite(1, "\n", 1);
  return 0;
}
