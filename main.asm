section .data
    windowTitle db 'Hello, SDL2', 0  ; Titel des Fensters
    null        dq 0                 ; Nullzeiger für SDL_CreateWindow
    renderer    dq 0
    redColor    db 255, 0, 0, 255 ; RGBA für Rot
    

section .bss
    window      resq 1  ; Speicherplatz für den Fensterzeiger
    event       resb 32 ; SDL_Event ist 32 Bytes

section .text
    extern SDL_Init, SDL_CreateWindow, SDL_PollEvent, SDL_DestroyWindow, SDL_Quit
    global _start

_start:
    ; SDL initialisieren
    mov rdi, 0x20  ; SDL_INIT_VIDEO
    call SDL_Init

    ; Fenster erstellen
    mov rdi, windowTitle  ; Titel
    xor rsi, rsi          ; x = SDL_WINDOWPOS_UNDEFINED
    xor rdx, rdx          ; y = SDL_WINDOWPOS_UNDEFINED
    mov rcx, 640          ; Breite
    mov r8, 480           ; Höhe
    xor r9, r9            ; flags = 0
    call SDL_CreateWindow
    mov [window], rax     ; Fensterzeiger speichern

    ; Ereignisschleife
event_loop:
    lea rdi, [event]
    call SDL_PollEvent
    test rax, rax
    jz event_loop         ; Wenn kein Ereignis vorliegt, weitermachen

    cmp dword [event], 0x100 ; SDL_QUIT = 0x100
    jne event_loop           ; Wenn es nicht SDL_QUIT ist, weitermachen

    ; Aufräumen und beenden
    mov rdi, [window]
    call SDL_DestroyWindow
    call SDL_Quit

    ; Programm beenden
    mov rax, 60    ; syscall für exit
    xor rdi, rdi   ; Status = 0
    syscall

