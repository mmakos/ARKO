;----------------------------------------
;Project: Median Filter
;Author: Michal Makos
;----------------------------------------
;
;rcx - height
;rdx - width
;rsi - *input wskaznik mapy wejsciowej
;rdi - *output wskaznik mapy wyjsciowej
;
;rbp-4 - padding
;rbp-8 - szerokosc w bajtach z paddingiem
;rbp-12 - licznik pixeli do obliczenia
;rbp-16 - chwilowa wartosc potrzebna w mrdianie
;rbp-20 - licznik linijek pozostalych do wczytania

section .data
ninePx times 9 db 0		;tablica z pixelami do liczenia

section .text
global median

median:
	push rbx
	push rbp
	mov rbp, rsp
	
countFuckingPadding:
	mov rax, rdx	;szerokosc w rax w px
	add rax, rdx
	add rax, rdx	;szerokosc w bajtach
	mov [rbp - 16], rax	;szerokosc w bajtach w rbp-8
	and rax, 3			;reszta z dzielenia przez 4
	mov rbx, 4			
	sub rbx, rax		;padding (dla 0 -> 4)
	and rbx, 3			;wlasciwy padding
	mov [rbp - 8], rbx	;padding w rbp-4
	mov rax, [rbp - 16]
	add rax, [rbp - 8]	;do szerokosci w bajtach dodajemy padding
	mov [rbp - 16], rax	;w rbp-8 szerokosc w bajtach z paddingiem
	
	sub rcx, 2			;pierwsza i ostatnia wczytujemy oddzielnie
	mov [rbp - 40], rcx	;licznik linijek pozostalych do wczytania
	
	mov rcx, [rbp - 16]
	shr rcx, 2			;rcx - licznik czworek pikseli pozostalych do przepisania
firstLine:
	mov rdx, [rsi]		;w rdx obecnie przepisywana czworka
	mov [rdi], rdx		;zapisujemy do rdi
	add rdi, 4
	add rsi, 4			;przechodzimy wskaznikami na kolejna czworke
	dec rcx				;dekrementujemy licznik
	jnz firstLine		;jesli nie zero to przepisujemy kolejna czworke

	
processLine:
	mov rax, [rbp - 16]
	sub rax, [rbp - 8]
	sub rax, 6
	mov [rbp - 24], rax	;rbp-12 licznik pixeli pozostalych do wczytania
	
writeFirstPx:
	mov dx, word[rsi]
	mov [rdi], dx
	add rsi, 2
	add rdi, 2
	mov dl, byte[rsi]
	mov [rdi], dl
	inc rsi
	inc rdi
	
fillPxArray:
	mov rbx, ninePx		;w rbx wskaznik na element tablicy 9 pixeli
	
	mov dl, byte[rsi]	;(0,0)
	mov [rbx], dl
	inc rbx
	sub rsi, [rbp - 16]
	
	mov dl, byte[rsi]	;(0,1)
	mov [rbx], dl
	inc rbx
	sub rsi, 3
	
	mov dl, byte[rsi]	;(-1,1)
	mov [rbx], dl
	inc rbx
	add rsi, 6
	
	mov dl, byte[rsi]	;(1,1)
	mov [rbx], dl
	inc rbx
	add rsi, [rbp - 16]
	
	mov dl, byte[rsi]	;(1,0)
	mov [rbx], dl
	inc rbx
	sub rsi, 6
	
	mov dl, byte[rsi]	;(-1,0)
	mov [rbx], dl
	inc rbx
	add rsi, [rbp - 16]
	
	mov dl, byte[rsi]	;(-1,-1)
	mov [rbx], dl
	inc rbx
	add rsi, 3
	
	mov dl, byte[rsi]	;(0,-1)
	mov [rbx], dl
	inc rbx
	add rsi, 3
	
	mov dl, byte[rsi]	;(1,-1)
	mov [rbx], dl
	sub rbx, 8			;teraz w tablicy mamy 9 pixeli to przetworzenia,
	sub rsi, 3			;rsi wskazuje znow na przetwarzany pixel
	sub rsi, [rbp - 16]	;a rbx na poczatek tablicy 9 pixeli
	
	mov ch, 5			;licznik ile razy petla ma sie jeszcze wykonac
	mov ah, 0			;obecne min
findMed:
	mov al, 255			;min z 9 px
	mov cl, 9			;licznik sprawdzen pixeli
	
inLoop:
	mov dl, byte[rbx]
	cmp dl, al
	jnb nextByte
	cmp dl, ah
	jb nextByte
	mov al, dl
	mov [rbp - 32], rbx	;zapamietujemy adres wybranej wartosci w tabeli 9 px
	
nextByte:
	inc rbx
	dec cl
	jnz inLoop
	mov rdx, [rbp - 32]
	mov byte[rdx], 255
	mov ah, al
	sub rbx, 9
	dec ch
	jnz findMed			
	
	mov dl, ah			;w dl mamy mrdiane
	mov [rdi], dl
	inc rdi
	inc rsi
	dec dword[rbp - 24]
	jnz fillPxArray
	
writeLastPx:
	mov dx, word[rsi]
	mov [rdi], dx
	add rsi, 2
	add rdi, 2
	mov dl, byte[rsi]
	mov [rdi], dl
	inc rsi
	inc rdi
	
	mov rax, [rbp - 8]	;ile paddingu zostalo do dopisania
	cmp rax, 0
	je afterPadd
addPadding:
	mov byte[rdi], 0
	inc rdi
	dec rax
	jnz addPadding
	add rsi, [rbp - 8]	;przesuwamy rsi na nastepna linie
	
afterPadd:
	dec dword[rbp - 40]
	jnz processLine	;jesli nie zero to przetwarzamy nastepna linie
;-----------------------------

	mov rcx, [rbp - 16]
	shr rcx, 2			;rcx - licznik czworek pikseli pozostalych do przepisania
lastLine:
	mov rdx, [rsi]		;w rdx obecnie przepisywana czworka
	mov [rdi], rdx		;zapisujemy do rdi
	add rdi, 4
	add rsi, 4			;przechodzimy wskaznikami na kolejna czworke
	dec rcx				;dekrementujemy licznik
	jnz lastLine		;jesli nie zero to przepisujemy kolejna czworke
	
end:
	pop rbp
	pop rbx
	ret
	
