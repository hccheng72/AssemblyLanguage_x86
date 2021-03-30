TITLE  Lab 7: Procedures and macros(lab7.asm)
; Name: Huichan Cheng

COMMENT !
This is a program that converts a signed decimal number to binary
and prints the binary result as a numeric text string.
!

INCLUDE Irvine32.inc

mWriteString MACRO address
	push edx
	mov edx, address
	call writeString
	pop edx
ENDM

.data
prompt BYTE "Enter a number within 8 bits: ", 0
errorMeg BYTE "Must be between -128 and 127", 0dh, 0ah, 0
ary BYTE 4 DUP('0'), ' ', 4 DUP('0'), 0dh, 0ah, 0;; initialize the array as 0000 0000
goodbye BYTE "Goodbye", 0dh, 0ah, 0

.code
main PROC

TOP:
sub esp, 4
push OFFSET prompt
push OFFSET errorMeg
call readInput
pop eax                          ; eax = input value

cmp eax, 0
je BYE

push eax
push OFFSET ary
call convert

mWriteString OFFSET ary
jmp TOP

BYE:
mWriteString OFFSET goodbye

exit
main ENDP

; reads in the user input numberand returns a valid input
; input: address of the prompt stringand address of the errorMeg string
; output: a valid value from reader on stack
readInput PROC
	push ebp
	mov ebp, esp
	push eax
	
	;; Prompt the user for a number
	PROMPTSTR:
	mWriteString [ebp+12]
	call readInt
	
	;; Check that the input number is within the range of a signed 8 - bit integer
	;; If not in the available range, show the error message
	cmp eax, -128
	jl ERR
	cmp eax, 127
	jl RETURNVALUE

	ERR :
	mWriteString [ebp+8]
	jmp PROMPTSTR

	RETURNVALUE:
	mov [ebp+16], eax

	pop eax
	pop ebp
	ret 8
readInput ENDP

; converts the input number into a binary text string
; input: user input numberand the address of the output array of characters
; output: none
convert PROC
	push ebp
	mov ebp, esp
	pushad

	mov ecx, 8           ;as the counter of loop
	mov esi, 0           ;as the index of ary
	mov edx, [ebp+8]     ;address of ary
	mov ebx, [ebp+12]    ;the input value

	;; to get each bit of the value,
	;; convert it to a char and store it as an element of ary.
	countLOOP:
		rol bl, 1
		jc ONE
		mov al, 0
		call toChar
		mov [edx + esi], al
		jmp checkSPACE
		ONE:
		mov al, 1
		call toChar
		mov [edx + esi], al              ;mov [ebp + 8][esi], al--> not work
		checkSPACE:
		inc esi
		cmp esi, 4
		jne notSPACE
		inc esi
		notSPACE:
		loop countLOOP
		
	popad
	pop ebp
	ret 8
convert ENDP

; converts the input bit into its ASCII character
; input: al
; output: al
toChar PROC
	cmp al, 0
	jne oneCHAR
	mov al, '0'
	jmp NEXT
	oneCHAR:
		mov al, '1'
	NEXT:
	ret
toChar ENDP


END main