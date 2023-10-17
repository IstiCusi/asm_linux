; vim: ft=nasm

; ---------------------------------------------------------------------------
;Copyright (C) 2023 Stephan Strauss
;
;Permission is hereby granted, free of charge, to any person obtaining a copy
;of this software and associated documentation files (the "Software"), to deal
;in the Software without restriction, including without limitation the rights
;to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;copies of the Software, and to permit persons to whom the Software is
;furnished to do so, subject to the following conditions:
;
;The above copyright notice and this permission notice shall be included in all
;copies or substantial portions of the Software.
;
;THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;SOFTWARE.
; -----------------------------------------------------------------------------

; This code serves as a practical illustration of creating real-world 
; applications in assembly. Here, the focus is on demonstrating the process and 
; ease of using NASM, rather than building a tool for a specific purpose. 
; The file is thoroughly documented to provide newcomers with a smooth 
; introduction to Linux assembly. For questions, feel free to reach out 
; through my GitHub page: https://github.com/IstiCusi.

; -----------------------------------------------------------------------------
; Data section: 

; The ".data" section is primarily used for storing initialized data that the 
; program will utilize. Notably, the in-file structure mirrors the layout of 
; the loaded section in RAM, differing from the .bss section, which doesn't 
; pre-allocate memory in the loaded file. Opt for .bss when feasible to 
; minimize file sizes.

; To locate the actual .data address in the executable, navigate the header 
; sequence: ELF header -> section header ->...

; The prefix '.' signifies a section, so '.data' refers to the data section.

; 'db' and 'dq' stand for 'define byte' and 'define quad word' (4 * 2 bytes), 
; respectively.

; It's crucial to understand that 'windowTitle' is shorthand for 'WindowTitle:', 
; indicating it's merely a label representing an address. For instance, 'window' 
; is an address, '[window]' references indirect addressing (dereferencing the 
; 'window' pointer), akin to '*window' in C.

section .data

    windowTitle db 'SDL2 Window', 0
    window      dq 0                ; Pointer to the window
    renderer    dq 0              ; Pointer to the renderer

; ----------------------------------------------------------------------------
; Text Section
;
; The ".text" section holds the machine code that the CPU will execute. Unlike
; sections meant for data storage (.data and .bss), the .text segment is
; read-only and comprises the actual instructions that dictate the program's
; behavior. 
;
; When a program is executed, the operating system loads the .text section 
; into memory, making it accessible for the CPU. It's crucial to understand
; that this section is strictly for executable code, not for variables or data
; that may change. Any attempt to write data here can result in a segmentation
; fault, as it violates memory protection set by the OS.
;
; The .text section typically begins with a 'global _start' directive, which
; exposes the _start label to the linker, indicating the starting point of the
; program. This is followed by the '_start:' label itself, marking the actual
; location in code where execution begins. 
;
; For maintainability and readability, it's advisable to separate the .text
; section from others clearly, ensuring a structured and comprehensible
; assembly file.
; ----------------------------------------------------------------------------

section .text

; ----------------------------------------------------------------------------
; KEYWORD: extern
;
; The "extern" keyword in assembly language is used to declare symbols that are
; not defined in the current assembly file but are expected to exist either in
; other object files or in libraries. These symbols are typically functions or
; variables that are defined in external libraries (e.g., libc).
;
; When you declare a symbol with "extern", you're instructing the assembler to
; create an entry for that symbol in the ".symtab" (symbol table) section of the
; ELF (Executable and Linkable Format) file. You can verify the presence of these
; symbols using the "readelf -s" command on the object file or the final executable,
; particularly if you included debug symbols during the linking process (-g flag).
;
; In scenarios where non-PIE (Position Independent Executable) is used, "readelf"
; can also display the addresses within the GOT (Global Offset Table), which are
; resolved at run time to their final values. However, with PIE (the default for
; many modern systems), these addresses are not fixed; the system determines them
; dynamically at execution to enhance security. Specifically, PIE was introduced to
; mitigate certain types of vulnerabilities, such as buffer overflow exploits, by
; randomizing the memory locations used at runtime, a technique known as ASLR 
; (Address Space Layout Randomization).
;
; Therefore, when writing assembly code that relies on external functions, it's 
; crucial to use the "extern" keyword for correct linking and execution, keeping 
; in mind the security and structural implications of the executable formats.
; ----------------------------------------------------------------------------

    extern SDL_Init, SDL_CreateWindow, SDL_CreateRenderer
    extern SDL_SetRenderDrawColor, SDL_RenderFillRect, SDL_RenderPresent
    extern SDL_Delay, SDL_DestroyRenderer, SDL_DestroyWindow, SDL_Quit

    global _start

_start:

    ; x86 ABI defines a certain sequence of registers used for the first 6 parameters
    ; of a function: rdi, rsi, rdx, rcx, r8, r9. So we load rdi as the fist parameter
    
    ; -------------------------------------------------------------------
    ; SDL Initialization:

    ; SDL.h:83 #define SDL_INIT_VIDEO 0x00000020u  
    ; SDL.h:143 extern DECLSPEC int SDLCALL SDL_Init(Uint32 flags);
     
    mov rdi, 0x20  ; SDL_INIT_VIDEO
    call SDL_Init

    ; -------------------------------------------------------------------
    ; Construct window:

    ; SDL_video.h:738 SDL_Window* SDL_CreateWindow( const char *title,
    ;                                               int x,
    ;                                               int y,
    ;                                               int w, 
    ;                                               int h,
    ;                                               Uint32 flags);

    mov rdi, windowTitle  ; Title string - pointer address
    xor rsi, rsi          ; x -- Typical way to set to zero
    xor rdx, rdx          ; y -- Typical way to set to zero
    mov rcx, 640          ; width
    mov r8, 480           ; height
    xor r9, r9            ; flags = 0
    call SDL_CreateWindow
    mov [window], rax     ; Save window pointer

; ----------------------------------------------------------------------------
; INDIRECT ADDRESSING: [window]
; 
; In assembly language, the notation [window] signifies indirect addressing. This
; means that we're not directly referring to the memory address where the "window"
; label/symbol is located, but rather, we're referencing the content found at the
; address that "window" points to.
; Think of "window" as a variable that holds a memory address. When you use 
; [window], the system reads it as a command to "go to the address contained in 
; 'window' and access the data there." This is analogous to dereferencing a 
; pointer in languages like C, where if 'window' is a pointer, *window would 
; give you the value stored at the location to which 'window' points.

; ---------------------------------------------------------------------------
    ; Create renderer for the window:

    ; SDL_render.h:227 SDL_Renderer* SDL_CreateRenderer(SDL_Window * window,
    ;                                                   int index, 
;                                                   Uint32 flags);

    mov rdi, [window]     ; Store window pointer in 1st parameter
    mov rsi, -1           ; index = -1, choose possible found solution
    mov rdx, 0            ; flags = 0
    call SDL_CreateRenderer
    mov [renderer], rax   ; Saved to renderer pointer

; ---------------------------------------------------------------------------
    ; Set Color to Red 

    ; SDL_render.h:1056 int SDL_SetRenderDrawColor(SDL_Renderer * renderer,
    ;                                              Uint8 r,
    ;                                              Uint8 g,
    ;                                              Uint8 b,
    ;                                              Uint8 a);

    mov rdi , [renderer]
    mov rsi , 255
    xor rdx , rdx
    xor rcx , rcx
    xor r8  , r8
    call SDL_SetRenderDrawColor

; ---------------------------------------------------------------------------
; STACK ALLOCATION: sub rsp, 16
; 
; The instruction 'sub rsp, 16' is used for stack space allocation, specifically,
; it allocates 16 bytes on the stack. This allocation is performed by decrementing 
; the stack pointer (rsp) by 16, essentially moving it to a lower memory address. 
; This movement is due to the stack's growth direction, which is from higher memory 
; addresses towards lower ones.
; 
; Following this allocation, several 'mov' instructions are utilized to populate 
; this space with integer values, each consuming 4 bytes. These values are intended 
; to form an SDL_Rect structure directly on the stack. The structure is populated by 
; using offsets with rsp: rsp (for 'x'), rsp+4 (for 'y'), rsp+8 (for 'w'), and 
; rsp+12 (for 'h'). These offsets allow writing to specific parts of the allocated 
; space, correlating to the SDL_Rect structure's members.
; 
; It's crucial to understand that this stack-based allocation is ephemeral and 
; pertains only to the current stack frame, that is, the scope of the active 
; function. The allocated space and its contents become prone to overwriting or 
; invalidation once the function concludes its execution or if the stack pointer 
; undergoes further modifications, emphasizing the temporary nature of stack 
; allocations.
; 
; Represented in C, the SDL_Rect structure looks like this:
;   typedef struct SDL_Rect
;   {
;     int x, y;
;     int w, h;
;   } SDL_Rect;
; ----------------------------------------------------------------------------
    
    ; Draw rectangular

    ; int SDL_RenderFillRect(SDL_Renderer * renderer,
    ;                        const SDL_Rect * rect);


    sub rsp, 16      ; 4 x 4 ints (32 bit) 
    mov dword [rsp]    , 50  
    mov dword [rsp+4]  , 50 
    mov dword [rsp+8]  , 400
    mov dword [rsp+12] , 400

    mov rdi, [renderer]
    mov rsi, rsp     ; Set rsi to address of the struct on the stack

    ; SDL_render.h:1329 int SDL_RenderFillRect(SDL_Renderer * renderer,
    ;                                          const SDL_Rect * rect);

    call SDL_RenderFillRect

    ;add rsp, 16 ; Give up the entry on the stack for the rect

    ; -------------------------------------------------------------------
    ; Render everything

    ; SDL_render.h:1722 void SDL_RenderPresent(SDL_Renderer * renderer);

    mov rdi, [renderer]   
    call SDL_RenderPresent

    ; -------------------------------------------------------------------
    ; Have a short delay for showing the window (in ms)

    ; SDL_timer.h:147 extern DECLSPEC void SDLCALL SDL_Delay(Uint32 ms);

    mov rdi, 7000         ; 7 sec 
    call SDL_Delay

    ; -------------------------------------------------------------------
    ; Destroy render context

    ; SDL_render.h:1748 void SDL_DestroyRenderer(SDL_Renderer * renderer);

    mov rdi, [renderer]
    call SDL_DestroyRenderer

    ; -------------------------------------------------------------------
    ; Destroy window

    ; SDL_video.h:1713 void SDL_DestroyWindow(SDL_Window * window);

    mov rdi, [window]
    call SDL_DestroyWindow

    ; -------------------------------------------------------------------
    ; Quit SDL 

    ; SDL.h:222 void SDL_Quit(void);

    call SDL_Quit

    ; -------------------------------------------------------------------
    ; Exit the process 

    ; man syscalls: https://filippo.io/linux-syscall-table/
    
    mov rax, 60           ; syscall number for exit
    xor rdi, rdi          ; status = 0
    syscall               ; call kernel

