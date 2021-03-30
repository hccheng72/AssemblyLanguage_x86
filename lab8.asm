TITLE  Lab 8: String and 2D array(lab8.asm)
; Name: Huichan Cheng

COMMENT !
Write a program that works with Fibonacci numbers.
The program fills a 2D array with Fibonacci numbers up to the max count of numbers that the user specifies.
Then it allows the user to search for a number in the array.
!

INCLUDE Irvine32.inc

NUMROW = 4
NUMCOL = 6
MAX = NUMROW * NUMCOL

; accept an integer as input and prints the integer followed by a space
numSpace MACRO aNum
	push eax
	movzx eax, aNum                    ; size of aNum should be less than a DWORD
	call writeDec
	mov al, ' '
	call writeChar
	pop eax
ENDM

; accepts an address of a text string as input and prints the text string
textString MACRO address
	push edx
	mov edx, address
	call writeString
	pop edx
ENDM

; accept a number as input and prints the number inside []
numBracket MACRO aNum
	push eax
	mov al, '['
	call writeChar
	movzx eax, aNum
	call writeDec
	mov al, ']'
	call writeChar
	pop eax
ENDM

.data
arr2D WORD MAX DUP(? )
prompt BYTE "How many numbers? ", 0
errorMeg BYTE "Must be between 1 and ", 0
promptSearch BYTE "Target number? (-1 to end search): ", 0


.code
main PROC
; Call a getCount procedure to ask the user how many Fibonacci
; numbers they want to see
mov edx, OFFSET prompt
mov ebx, OFFSET errorMeg
call getCount; eax = count

; Call the procedure fillArray to fill the array with Fibonacci numbers,
; up to the max count from the user
push OFFSET arr2D
push eax
call fillArray

; Call the procedure search to let the user search for
; a particular number in the array
push OFFSET promptSearch
push OFFSET arr2D
push eax
call search

exit
main ENDP

; prompt the userand read in the count of number
; input: edx = address of prompt; ebx = address of errorMeg
; output: eax = valid count
getCount PROC
	promptStart :
	textString edx
	call readInt
	cmp eax, 1
	jl Err
	cmp eax, MAX
	jle returnVal

	Err :
	textString ebx
		mov eax, MAX
		call writeDec                    ; numSpace MAX->not work
		call crlf
		jmp promptStart

	returnVal :
		ret
getCount ENDP

; fill the 2D array with Fibonacci numbers, up to the count from the user
; input: address of arr2D and count
; output: none
fillArray PROC
	push ebp
	mov ebp, esp
	pushad

	mov edi, [ebp + 12]                    ; add of arr
	mov ecx, [ebp + 8]                     ; count
    
	; fulfill the first two elements with 0 and 1
	mov WORD PTR [edi], 0
	add edi, 2
	mov WORD PTR [edi], 1
	add edi, 2
	sub ecx, 2

	; fulfill remaining elements of the array
	cld
	FillArr:
	mov ax, [edi - 4]
	add ax, [edi - 2]
	stosw
	loop FillArr
    
	; call printArray procedure to display the 2D array
	push[ebp + 12]
	push[ebp + 8]
	call printArray

	popad
	pop ebp
	ret 8
fillArray ENDP

; print the data in the array, up to the max count
; input: address of arr2D and count
; output: none
printArray PROC
	push ebp
	mov ebp, esp
	pushad

	mov esi, [ebp + 12]                 ; add of arr
	mov ecx, [ebp + 8]                  ; count
	mov ebx, NUMCOL                     ; ebx = NUMCOL
	cld
	PrintArr :
		lodsw
		numSpace ax
		dec ebx
		jne KeepGo
		call crlf
		mov ebx, NUMCOL
		KeepGo :
		loop PrintArr
	call crlf

	popad
	pop ebp
	ret 8
printArray ENDP

; loopand prompt for a target number until the user enters -1
; find the target number
; input: address of promptSearch, address of arr2D, and count
; output: none
search PROC
	push ebp
	mov ebp, esp
	pushad
    
	;display the prompt for the target number
	AskTarget:
	textString[ebp + 16]
	call readInt                          ; eax = target number
	
	; if user enters -1, exist the program
	cmp eax, -1
	je Bye

	; if user enters a num over the range of an unsigned word, show not found
	test eax, 0FFFF0000h
	jne NotFound

	; search for the target number
	cld
	mov edi, [ebp + 12]
	mov ecx, [ebp + 8]
	repne scasw
	jne NotFound

	; if found, find out its index of position
	COMMENT !
	neg ecx
	add ecx, [ebp + 8]                      ; ecx:th of elets
	dec ecx
	!

	sub edi, [ebp + 12]
	shr edi, 1                              ; edi:th of elets
	dec edi
	mov eax, edi
	mov cl, NUMCOL
	div cl                                  ; index = [al][ah]
	mov cl, al                              ; need this step!!
	numBracket cl
	numBracket ah
	call crlf
	jmp AskTarget

	; show - 1 for the result of not found
	NotFound:
	mov eax, -1
	call writeInt
	call crlf
	jmp AskTarget

	Bye:
	popad
	pop ebp
	ret 12
search ENDP

END main