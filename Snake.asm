IDEAL
MODEL small
STACK 100h
DATASEG
length1 db 3
last db 'a'
loc dw 2000, 2002, 2004
intro db 'Welcome to Snake!'
inst db 'Use W A S D to move the snake and q to quit the game'
diffculty db 'Choose your diffculty level by pressing 1-3'
end1 db 'Game Over'
playag db 'Press q to quit'

CODESEG

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

proc delay ;create a delay by using a double loop to wait
	mov cx, 0FFFFh	
	loop1:
		mov bx, 60
		loop2:
			dec bx
			cmp bx, 0
			jnz loop2
	loop loop1
	ret
endp delay

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

proc screen ;clear the screen and make new borders and background color
push bx
push di

	mov bh, 32 ;color of background
	mov bl, '' ;symbol of background
	mov di, 0
	lop1:
		mov [es:di], bx
		add di, 2
		cmp di, 25*80*2
		jnz lop1
	
	mov bh, 4   ;color of the border
	mov bl, 'X' ;what symbol is the border
	
	mov di, 0
	up1: ;creating the up border
		mov [es:di], bx
		add di, 2
		cmp di, 160
		jne up1
	
	mov di, 160*24
	down: ;creating the down border
		mov [es:di], bx
		add di, 2
		cmp di, 160*25
		jne down
	
	mov di, 0
	left: ;creating the left border
		mov [es:di], bx
		add di, 160
		cmp di, 160*25
		jne left
	
	mov di, 158
	right: ;creating the right border
		mov [es:di], bx
		add di, 160
		cmp di, 160*25 - 2
		jne right
		
	pop di
	pop bx
	ret
endp screen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

proc start1 ;create the starter message and wait for the player to select diffculty and by their selection change the length of the snake
push cx
push di
push ax
	mov cx, 43 ;size of the print
	mov di, 1628 ;loc of the print
	mov ah, 20h ;color of the print
	mov bx, offset diffculty
	;print the message by the setting that were enterd before
	difflop:
	mov al, [bx]
	mov [es:di], ax
	add di, 2 
	inc bx
	dec cx
	cmp cx, 0
	jnz difflop
	
	mov cx, 52 ;size of the print
	mov di, 1460 ;loc of the print

	mov bx, offset inst 
	;print the message by the setting that were enterd before
	instlop:
	mov al, [bx]
	mov [es:di], ax
	add di, 2 
	inc bx
	dec cx
	cmp cx, 0
	jnz instlop
	
	mov cx, 17 ;size of the print
	mov di, 1340 ;loc of the print
	mov bx, offset intro 
	;print the message by the setting that were enterd before
	introlop:
	mov al, [bx]
	mov [es:di], ax
	add di, 2 
	inc bx
	dec cx
	cmp cx, 0
	jnz introlop
	
	waiting: ;wait until a key is pressed
		call delay
		mov ax, 0100h
		int 16h
		jz waiting
		mov ax, 0
		int 16h
		cmp al, '1'
		je diff1
		cmp al, '2'
		je diff2
		cmp al, '3'
		je diff3
		jmp waiting
		
		diff2: ;change the length of the snake to 6
		mov bx, offset length1
		mov ax, 6
		mov [bx], al
		jmp diff1
		
		diff3: ;change the length of the snake to 12
		mov bx, offset length1
		mov ax, 12
		mov [bx], al
		jmp diff1
		
		diff1:
		call screen ;clear the screen so the message will disapper
		pop ax
		pop di
		pop cx
ret
endp start1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

proc sub_move ;


	mov bx, offset length1
	mov cx, 0
	mov cl, [bx] ;cl gets the length of the snake
	mem:
		cmp cx, 0
		je insert
		;delete the old snake trail so there will be no lines on the screen 
		mov bx, cx
		add bx, cx
		sub bx, 2
		add bx, offset loc
		mov ax, [bx]
		add bx, 2
		mov [bx], ax
		dec cx
		jmp mem
		
	insert:
	mov bx, offset loc
	mov [bx], di
	
	mov cl, ' ' ;symbol of the snake ;42
	mov ch, 101 ;color of the snake
	mov bx, offset loc 
	mov di, [bx] ;di get the loc of the snake
	mov ax, [es:di]
	mov [es:di], cx ;move the snake to the next loc
	
	mov ch, 32 ;color of trail of the snake
	mov cl, ' ' ;symbol of trail of the snake
	mov dx, 0
	mov bx, offset length1
	mov dl, [bx]
	mov bx, dx
	add bx, dx
	add bx, offset loc
	mov di, [bx]
	mov [es:di], cx
	
	;check if the food was eaten and if he did then gen a new one
	cmp al, '$'
	jnz nexteat
	call eat
	nexteat:
	

	ret
endp sub_move

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc eat ;inc the length of the snake and gen a new food 
;add 1 to the length of the snake
mov ax, 0
mov bx, offset length1
mov al, [bx]
inc al
mov [bx], al

;change the loc of the snake + one
    mov ax, 0
	mov bx, offset length1
	mov al, [bx]
	mov bx, ax
	add bx, ax
	sub bx, 2
	add bx, offset loc
	mov ax, [bx]
	add bx, 2
	mov [bx], ax
	
	call random ;give us a random value of di
	mov cl, '$' ;הכנסת ערך לקבלת הצורה
	mov ch, 73  ;הכנסת ערך לקבלת הצבע
	mov [es:di], cx ;יצירת אוכל נוסף
	
	ret
endp eat
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
proc random ;gen a random number and put it in di
	
	rnd:
	mov ax, 40h
	mov es, ax
	
	mov ax, [es:6Ch] ;get the clock time
	and ax, 1023
	mov cx, ax
	
	mov ax, [es:6Ch] ;get the clock time
	and ax, 511
	add cx, ax
	
	;get a random number between 0-127
	mov ax, [es:6Ch] ;get the clock time
	and ax, 255
	add cx, ax
	
	;get a random number between 0-3
	mov ax, [es:6Ch] ;get the clock time
	and ax, 3 ;change the amount of bits that are taken
	add cx, ax ;add the bit to the number
	
	;check if the number is lower than 2000 so it will be on the screen
	cmp ax, 2000
	jg rnd
	
	;mul by 2 cx
	mov ax, cx
	add ax, cx
	
	mov di, ax
	add di, 162
	
	mov ax, 0b800h
	mov es, ax
	
	;if the new loc is at the snake then pick a new loc
	mov ax, [es:di]
	cmp al, '.'
	je rnd


	ret
endp random

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

proc lost ;;clear the screen and display a gameover screen while waiting for the player to quit

push cx ;store cx in stack
push di ;store di in stack
push ax ;store ax in stack
push bx ;store bx in stack

call screen ;clear the snake and the food 

	mov cx, 45 ;size of the print
	mov di, 2148 ;loc of the print
	mov ah, 20h ;color of the print
	mov bx, offset playag
	;print the message
	end1lop:
	mov al, [bx] ;al get the cell of the message
	mov [es:di], ax ;print the cell to the screen
	add di, 2 ;move to the next memory 
	inc bx ;move to the next cell to print
	dec cx ;lower cx to know how much more is left to print
	cmp cx, 0 ;check if completed the print
	jne end1lop ;if print is not completed then jump to start of the loop
	
	;print the message
	mov cx, 9 ;size of the print
	mov di, 1994  ;loc of the print
	mov bx, offset end1 
	playlop:
	mov al, [bx]
	mov [es:di], ax
	add di, 2 
	inc bx
	dec cx
	cmp cx, 0
	jne playlop
	
		waiting_to_quit:
		call delay
		;check if any key was entered and if nothing was enter jump to waiting_to_quit
		mov ax, 0100h
		int 16h 
		jz waiting_to_quit ;if no key was enterd jump to the start of the loop
		mov ax, 0
		int 16h 
		cmp al, 'q' ;check if the key that was pressed is q
		jne waiting_to_quit ;if q wasn't pressed then jump to the start of the loop 
		
		pop bx ;release the data stored in the stack
		pop ax ;release the data stored in the stack
		pop di ;release the data stored in the stack
		pop cx ;release the data stored in the stack
ret
endp lost

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

start:
	mov ax, @data
	mov ds, ax
	
	mov ax, 0b800h
	mov es, ax		
	call screen
	
	call start1
	mov es, ax
	
	;create the first food
	call random
	mov cl, '$'
	mov ch, 73
	mov [es:di], cx
		
	Mainlop:
		mov bx, offset loc
		mov di, [bx] ;di get the snake location
		mov bx, offset last
		mov cl, [bx] ;cl get the last location that the snaked moved
		
		mov dx, 0
		mov ax, 0100h
		int 16h ;check if any key was pressed
		jnz nextinput ;if a key was pressed jump to next input
		mov bx, offset last ;if nothing was enterd countine moving to the last diraction that was given
		mov al, [bx]
		jmp endinput 
		nextinput:
		mov ah, 0
		int 16h
		;check what is the key that was entered and what was the last key that was pressed
		
			cmp al, 'w'
			jne notw
			cmp cl, 's' ;if the last movment wasn't s then jump to endinput
			jne endinput
			notw:
			
			cmp al, 's'
			jne s
			cmp cl, 'w'
			jne endinput
			s:
			
			cmp al, 'a'
			jne a
			cmp cl, 'd'
			jne endinput
			a:
			
			cmp al, 'd'
			jne d
			cmp cl, 'a'
			jne endinput
			d:
			
		cmp al, 'q' ;check if the player asked to quit
		je exit
		mov bx, offset last
		mov al, [bx] ;make al to the last movment in order to make correct turns
		endinput:
		
		;check if the snake touched the borders and if he did then its game over
		mov ah, 0
		mov si, ax
		call delay
		mov bx, 160
		
			cmp si, 'w'
			jnz nextw
			cmp di, 320
			jl death
			sub di, 160
			nextw:
			
			cmp si, 'a'
			jnz nexta
			mov ax, di
			div bx
			cmp dx, 2
			je death
			sub di, 2
			nexta:
			
			cmp si, 's'
			jnz nexts
			cmp di, 4000-160-159
			ja death
			add di, 160
			nexts:
			
			cmp si, 'd'
			jnz nextd
			mov ax, di
			div bx
			cmp dx, 156
			je death
			add di, 2
			nextd:
		
		;change the last var to the last button that been pressed
		mov bx, offset last
		mov ax, si
		mov [bx], al

;check if the head of the snake touched itself
		mov ax, [es:di] ;ax get the location of the head
		cmp ah, 101 ;check if the head is touching itself by checking the color
		je death ;if the snake touched itself then jump to death

		call sub_move
		jmp Mainlop ;return to the start of the loop
	
	death:
	call lost ;end the game
	
exit:
mov ax, 4c00h
int 21h
END start