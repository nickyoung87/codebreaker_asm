section .data
	newline db 0x0A
	cls db 0x1b, '[', 'H', 0x1b, '[', '2', 'J', 0

	enterPatternStr db "Create an 8 character code using 1s and 0s", 0x0A, 0
	enterPatternStrLen equ $-enterPatternStr

	guessStr db "Enter your guess", 0x0A, 0
	guessStrLen equ $-guessStr

	guessResultStr db "Here is the result of your guess", 0x0A, 0
	guessResultStrLen equ $-guessResultStr

	winnerStr db "Congratulations! You got it right!", 0x0A, 0
	winnerStrLen equ $-winnerStr

	tryAgainStr db "Sorry, that's incorrect. Please try again.", 0x0A, 0
	tryAgainStrLen equ $-tryAgainStr

section .bss
	code resb 9 ; Needs to be 1 bigger to account for newline
	guess resb 9
	checkGuess resb 8

section .text
	global _start

_start:
	; Output code insert message
	MOV eax, 4
	MOV ebx, 1
	MOV ecx, enterPatternStr
	MOV edx, enterPatternStrLen
	INT 0x80

	; User inputs the code
	MOV eax, 3
	MOV ebx, 1
	MOV ecx, code
	MOV edx, 9
	INT 0x80

	; Remove the newline
	MOV esi, eax
	DEC esi
	MOV BYTE [code + esi], 0

	; Clear the screen so 2nd player can't see the answer
	MOV eax, 4
	MOV ebx, 1
	MOV ecx, cls
	MOV edx, 7
	INT 0x80

	; Now we loop through the user guessing until they get the code
game_loop:
	; Output a newline
	MOV eax, 4
	MOV ebx, 1
	MOV ecx, newline
	MOV edx, 1
	INT 0x80

	MOV eax, 4
	MOV ebx, 1
	MOV ecx, guessStr
	MOV edx, guessStrLen
	INT 0x80

	; Wait for guess
	MOV eax, 3
	MOV ebx, 1
	MOV ecx, guess
	MOV edx, 9
	INT 0x80

	; Remove the newline
	MOV esi, eax
	DEC esi
	MOV BYTE [guess + esi], 0

	; Need to loop through the string and compare and set which are correct
	MOV esi, 0
check_loop:
	CMP esi, 8
	JGE guess_result

	MOV al, [code + esi]
	AND al, 1

	MOV bl, [guess + esi]
	AND bl, 1

	XOR al, bl
	XOR al, 1

	ADD al, '0'
	MOV [checkGuess + esi], al

	INC esi
	JMP check_loop

guess_result:
	; Print the guess result
	MOV eax, 4
	MOV ebx, 1
	MOV ecx, guessResultStr
	MOV edx, guessResultStrLen
	INT 0x80

	; Print the actual result
	MOV eax, 4
	MOV ebx, 1
	MOV ecx, checkGuess
	MOV edx, 8
	INT 0x80

	; Print a newline
	MOV eax, 4
	MOV ebx, 1
	MOV ecx, newline
	MOV edx, 1
	INT 0x80

	; Now we need to see if they actually won
	MOV esi, 0
check_win_loop:
	CMP esi, 8
	JGE winner

	MOV al, [checkGuess + esi]
	CMP al, '1'
	JNE try_again

	INC esi
	JMP check_win_loop
winner:
	; Print the winning message
	MOV eax, 4
	MOV ebx, 1
	MOV ecx, winnerStr
	MOV edx, winnerStrLen
	INT 0x80

	JMP end_game

try_again:
	; print the try again message
	MOV eax, 4
	MOV ebx, 1
	MOV ecx, tryAgainStr
	MOV edx, tryAgainStrLen
	INT 0x80

	JMP game_loop

end_game:
	; Exit
	MOV eax, 1
	XOR ebx, ebx
	INT 0x80
