CC = cl.exe
CFLAGS = -Wall -m32

all: compile clean

compile: main.o median.o
	$(CC) $(CFLAGS) -o median.exe main.o median.o

median.o: median.asm
	nasm -f elf32 -o median.o median.asm

main.o: main.c
	$(CC) $(CFLAGS) -c -o main.o main.c

clean:
	rm -f *.o
