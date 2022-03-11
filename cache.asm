CACHE_LINES  EQU 100
CACHE_LINE_SIZE EQU 8
OFFSET_BITS  EQU 3
TAG_BITS EQU 29 ; 32 - OFSSET_BITS


section .text
    global load
    extern printf

section .data
    var dd 0
;; void load(char* reg, char** tags, char cache[CACHE_LINES][CACHE_LINE_SIZE], char* address, int to_replace);
load:
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]  ; address of reg
    mov ebx, [ebp + 12] ; tags
    mov ecx, [ebp + 16] ; cache
    mov edx, [ebp + 20] ; address
    mov edi, [ebp + 24] ; to_replace (index of the cache line that needs to be replaced in case of a cache MISS)

    mov esi, edx
    ;rotesc la dreapta esi, apoi shiftez la dreapta esi, pentru a ramane in esi doar ultimii 3 biti
    ror esi, OFFSET_BITS
    shr esi, TAG_BITS
    ;shiftez la dreapta edx pentru a sterge ultimii 3 biti
    shr edx, OFFSET_BITS
    mov eax, 0

find_tag:
    ;daca s-a gasit tag-ul edx in vectorul de tag-uri ebx
    cmp edx, [ebx+eax]
    jz found_it
    inc eax
    jmp check_find_loop

found_it:
    ;se salveaza in ebx adresa lui reg
    mov ebx, [ebp+8]
    ;eax devine 8*eax (dimensiunea unei linii din cache)
    add eax, eax
    add eax, eax
    add eax, eax
    ;ne pozitionam pe octetul dorit
    add eax, esi
    ;aducem in esi ceea ce se gaseste in cache la adresa dorita
    mov esi, [ecx+eax]
    ;apoi mutam la valoarea de la adresa lui reg ceea ce am obtinut din cache
    mov [ebx], esi
    jmp exit

check_find_loop:
    ;comparam daca s-au parcurs toate liniile din tags
    ;am pus 100 deoarece sunt 100 de linii in cache, iar fiecare linie are asociat un tag
    cmp eax, 100
    jnz find_tag

not_found_it:
    ;se aduge tags pe tags[to_replace]
    add ebx, edi
    ;se scrie valoarea de la acea adresa cu tag-ul edx
    mov [ebx], edx
    ;se initializeaza cu 0 ultimii 3 biti din adresa pentru a adauga ulterior pe rand cei 8 octeti in cache
    shl edx, OFFSET_BITS
    ;se pune offset-ul pe stiva pentru a elibera un registru
    push esi
    ;esi va contoriza cei 8 octeti care se vor adauga in cache 
    xor esi, esi
    ;edi devine 8*edi (pentru a ne pozitiona in cache)
    add edi, edi
    add edi, edi
    add edi, edi
    jmp add_bytes_in_cache

add_bytes_in_cache:
    ;retin intr-o variabila globala valoarea lui esi
    mov dword [var], esi
    ;mut in esi fiecare octet in parte (vom avea edx+1 apoi edx+2...)
    mov esi, [edx+esi]
    ;mut in cache la cache[to_replace][0], apoi la cache[to_replace][1]...
    mov [ecx+edi], esi
    ;restaurez valoarea lui esi din variabila globala
    mov esi, dword [var]
    ;incrementez edi pentru a sti unde pun urmatorul octet
    add edi, 1
    ;incrementez esi pentru a trece la urmatorul octet
    inc esi
    cmp esi, 8
    ;daca am terminat de pus toti cei 8 octeti, se iese
    jnz add_bytes_in_cache

add_reg:
    ;se adauga in eax adresa lui reg
    mov eax, [ebp+8]
    ;se readuce edi la valoarea 8*edi, deoarece in add_bytes_in_cache l-am incrementat cu 1 de 8 ori
    sub edi, 8
    ;se readuce valoarea lui esi din not_found_it (offset-ul), atunci cand am dat push
    pop esi
    ;adaug la edi offset-ul esi
    add edi, esi
    ;adaug in esi octetul de la cache[to_replace][offset]
    mov esi, [ecx+edi]
    ;pun la valoarea de la adresa lui reg octetul dorit
    mov [eax], esi
    
exit:
    popa
    leave
    ret


