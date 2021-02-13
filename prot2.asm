.section .data
file_stat:	.space 144	#Size of the fstat struct
.section .text
.globl _start
_start:

    openfile:
        mov $2, %rax  
        mov 16(%rsp), %rdi
        mov $2, %rsi
        mov $0, %rdx
        syscall

    #file descripter
        mov %rax, %rdi     #går til statfile
        mov %rax, %r8      #går til read

    statfile:
    #Get File Size
	    mov	$5,%rax			#Syscall fstat
	    mov	$file_stat,%rsi	#Reserved space for the stat struct
	    syscall
	    mov	$file_stat, %rbx
	    mov	48(%rbx),%rax	#Position of size in the struct
        mov %rax, %r9       #saving the filesize in r9
        mov %rax, %r10      #saving the filesize in r10

        push %r9           #pushes r9 on to the stack for alloc_mem

    call alloc_mem
    
        mov %rax, %r11     #pointer til den første buffer
        mov %rax, %r13

    read:
        mov %r11, %rsi     #modtager pointer
        mov $0, %rax       #mod/flag i dont know
        mov %r8, %rdi      #modtager file descripter
        mov %r9, %rdx      #modtager filesize
        syscall

    push %r10   #lægger filesize på stakken til get_number
    push %r13   #lægger en pointer på stakken til get_number

    call get_number_count

    mov %rax, %r12      #gemmer antallet af integers i filen i r12
    mov %rax, %r15
    imul $8, %r15
    imul $8, %r12       #tilpasser antallet til bytes
    push %r15           #giver alloc antallet af bytes der skal reserveres

    call alloc_mem

    mov %rax ,%r14      #lægger pointer til den nye buffer over i r13
    push %rax           #lægger den nye buffer adresse på stacken
    push %r10           #lægger størrelsen af den gamle buffern på stacken
    push %r13           #lægger den gamle buffer adresse på stacken

    call parse_number_buffer

    s_sorting:
    mov $0, %r13 #creates a cmp counter
    mov $0, %rcx
    mov $0, %r11
    pop %r12 #array lenght i bytes
    mov (%r14), %r8 #index pointer nu på 0 (i)
    mov (%r14), %r9 #same deal (j)
    
    outer_loop:
    mov %rcx, %r11 #updatere index i
    mov (%r14, %r11), %r8 #updatere index i
    mov %rcx, %r10 #r10 er nu imin
    

    inner_loop:
    inc %r13
    cmp %r8, (%r14,%r10) #sammenligner nuværende index med det mindste element
    jle inner_loop_end

    mov %r11, %r10 #index bliver nu til det mindste element (hvis det er mindre en det nuværende)

    inner_loop_end:
    add $8, %r11 #incrementer index i
    inc %r13
    cmp %r11, %r15 #sammenligner index i med arraylenght
    jle mid_loop_end

    mov (%r14, %r11), %r8 #updatere index i

    jmp inner_loop

    mid_loop_end:
    inc %r13
    cmp %rcx, %r10
    je outer_loop_end


    switch: #some switching be going on i say
    #mov $16, %r11
    #mov $0, %rcx
    mov (%r14, %rcx), %rdx
    mov (%r14, %r10), %rbx
    mov %rbx, (%r14, %rcx)
    mov %rdx, (%r14, %r10) #opdatere arrayet

    mov (%r14, %r11), %r8 #updatere index i
    mov (%r14, %rcx), %r9 #updatere index j

    outer_loop_end:
    add $8, %rcx #incrementer index j
    inc %r13
    cmp %rcx, %r15 #sammenligner index j med arraylenght
    jle main_end

    mov (%r14, %rcx), %r9 #updatere index j
    jmp outer_loop

    main_end: 

    mov $0, %rbx
    printloop:   
    mov (%r14, %rbx), %r12
    push %r12
    
    call print_number
    pop %r12

    add $8, %rbx
    #cmp %rbx, %r15
    jg printloop

    #%r13 contains the number of compares done troughout the sorting
    #push %r13 

    #call print_number


    exit:
	    mov	$60, %rax		#exit, syscall style	
        mov $0, %rdi		#error code 0
        syscall				#make syscall
