;----------------------------------------
;Project: Median Filter
;Author: Michal Makos
;----------------------------------------
;
;ebp+20 - height
;ebp+16 - width
;ebp+12 - *output wskaznik mapy wyjsciowej
;ebp+8 - *input wskaznik mapy wejsciowej
;
;ebp-4 - padding
;ebp-8 - szerokosc w bajtach z paddingiem
;ebp-12 - licznik pixeli do obliczenia
;ebp-16 - chwilowa wartosc potrzebna w medianie
;ebp-20 - licznik linijek pozostalych do wczytania

section .data
ninePx times 9 db 0		;tablica z pixelami do liczenia

section .text
global median

median:
	push ebp
	mov ebp, esp
	
	mov esi, [ebp + 8]	;wskaznik mapy wejsciowej w esi
	mov edi, [ebp + 12]	;wskaznik mapy wyjsciowej w edi
	
countFuckingPadding:
	mov eax, [ebp + 16]	;szerokosc w eax w px
	add eax, [ebp + 16]
	add eax, [ebp + 16]	;szerokosc w bajtach
	mov [ebp - 8], eax	;szerokosc w bajtach w ebp-8
	and eax, 3			;reszta z dzielenia przez 4
	mov ebx, 4			
	sub ebx, eax		;padding (dla 0 -> 4)
	and ebx, 3			;wlasciwy padding
	mov [ebp - 4], ebx	;padding w ebp-4
	mov eax, [ebp - 8]
	add eax, [ebp - 4]	;do szerokosci w bajtach dodajemy padding
	mov [ebp - 8], eax	;w ebp-8 szerokosc w bajtach z paddingiem
	
	
	mov ecx, [ebp - 8]
	shr ecx, 2			;ecx - licznik czworek pikseli pozostalych do przepisania
firstLine:
	mov edx, [esi]		;w edx obecnie przepisywana czworka
	mov [edi], edx		;zapisujemy do edi
	add edi, 4
	add esi, 4			;przechodzimy wskaznikami na kolejna czworke
	dec ecx				;dekrementujemy licznik
	jnz firstLine		;jesli nie zero to przepisujemy kolejna czworke

	
	mov ecx, [ebp + 20]
	sub ecx, 2			;pierwsza i ostatnia wczytujemy oddzielnie
	mov [ebp - 20], ecx	;licznik linijek pozostalych do wczytania
processLine:
	mov eax, [ebp - 8]
	sub eax, [ebp - 4]
	sub eax, 6
	mov [ebp - 12], eax	;ebp-12 licznik pixeli pozostalych do wczytania
	
writeFirstPx:
	mov dx, word[esi]
	mov [edi], dx
	add esi, 2
	add edi, 2
	mov dl, byte[esi]
	mov [edi], dl
	inc esi
	inc edi
	
fillPxArray:
	mov ebx, ninePx		;w ebx wskaznik na element tablicy 9 pixeli
	
	mov dl, byte[esi]	;(0,0)
	mov [ebx], dl
	inc ebx
	sub esi, [ebp - 8]
	
	mov dl, byte[esi]	;(0,1)
	mov [ebx], dl
	inc ebx
	sub esi, 3
	
	mov dl, byte[esi]	;(-1,1)
	mov [ebx], dl
	inc ebx
	add esi, 6
	
	mov dl, byte[esi]	;(1,1)
	mov [ebx], dl
	inc ebx
	add esi, [ebp - 8]
	
	mov dl, byte[esi]	;(1,0)
	mov [ebx], dl
	inc ebx
	sub esi, 6
	
	mov dl, byte[esi]	;(-1,0)
	mov [ebx], dl
	inc ebx
	add esi, [ebp - 8]
	
	mov dl, byte[esi]	;(-1,-1)
	mov [ebx], dl
	inc ebx
	add esi, 3
	
	mov dl, byte[esi]	;(0,-1)
	mov [ebx], dl
	inc ebx
	add esi, 3
	
	mov dl, byte[esi]	;(1,-1)
	mov [ebx], dl
	sub ebx, 8			;teraz w tablicy mamy 9 pixeli to przetworzenia,
	sub esi, 3			;esi wskazuje znow na przetwarzany pixel
	sub esi, [ebp - 8]	;a ebx na poczatek tablicy 9 pixeli
	
	mov ch, 5			;licznik ile razy petla ma sie jeszcze wykonac
	mov ah, 0			;obecne min
findMed:
	mov al, 255			;min z 9 px
	mov cl, 9			;licznik sprawdzen pixeli
	
inLoop:
	mov dl, byte[ebx]
	cmp dl, al
	jnb nextByte
	cmp dl, ah
	jb nextByte
	mov al, dl
	mov [ebp - 16], ebx	;zapamietujemy adres wybranej wartosci w tabeli 9 px
	
nextByte:
	inc ebx
	dec cl
	jnz inLoop
	mov edx, [ebp - 16]
	mov byte[edx], 255
	mov ah, al
	sub ebx, 9
	dec ch
	jnz findMed			
	
	mov dl, ah			;w dl mamy mediane
	mov [edi], dl
	inc edi
	inc esi
	dec dword[ebp - 12]
	jnz fillPxArray
	
writeLastPx:
	mov dx, word[esi]
	mov [edi], dx
	add esi, 2
	add edi, 2
	mov dl, byte[esi]
	mov [edi], dl
	inc esi
	inc edi
	
	mov eax, [ebp - 4]	;ile paddingu zostalo do dopisania
	cmp eax, 0
	je afterPadd
addPadding:
	mov byte[edi], 0
	inc edi
	dec eax
	jnz addPadding
	add esi, [ebp - 4]	;przesuwamy esi na nastepna linie
	
afterPadd:
	dec dword[ebp - 20]
	jnz processLine	;jesli nie zero to przetwarzamy nastepna linie
;-----------------------------
	
	mov ecx, [ebp - 8]
	shr ecx, 2			;ecx - licznik czworek pikseli pozostalych do przepisania
lastLine:
	mov edx, [esi]		;w edx obecnie przepisywana czworka
	mov [edi], edx		;zapisujemy do edi
	add edi, 4
	add esi, 4			;przechodzimy wskaznikami na kolejna czworke
	dec ecx				;dekrementujemy licznik
	jnz lastLine		;jesli nie zero to przepisujemy kolejna czworke
	
end:
	pop ebp
	ret
	