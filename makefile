CC = cl.exe
LINK = link.exe
CFLAGS = -Wall -m32

all: main.o median.o
	$(LINK) $(CFLAGS) /OUT:median.exe main.o median.o

median.o: median.asm
	nasm -f elf32 -o median.o median.asm

main.o: main.c
	$(CC) $(CFLAGS) /c /Fo main.o main.c

clean:
	rm -f *.o