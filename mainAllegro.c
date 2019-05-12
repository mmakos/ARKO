#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <allegro5/allegro.h>
#include "allegro5/allegro_image.h"
#include "allegro5/allegro_native_dialog.h"


void median( char *input, char *output, unsigned int width, unsigned int height );

typedef struct
{
	unsigned int biSize;
	char niBytes[ 12 ];		//bity nie istotne
	unsigned int biWidth;
	unsigned int biHeight;
	char rest[ 28 ];
}BMPHeader;

int error( int msg )
{
	printf( "Wystapil blad: " );
	switch( msg ) {
	case -1:
		printf( "Brak wystarczqjqcej ilosci argumentow.\n" );
		break;
	case -2:
		printf( "Nie udalo sie otworzyc pliku.\n" );
		break;
	case -3:
		printf( "Plik nie jest mapa bitowa.\n" );
		break;
	case -4:
		printf( "Nie udalo sie zapisac do pliku.\n" );
		break;
	default:
		printf( "Nieznany blad.\n" );
		break;
	}
	return msg;
}

int main( int argc, char *argv[] )
{
	FILE *file = 0;
	BMPHeader header;
	char *image;
	char *result;
	unsigned int size = 0;
	unsigned int width = 0;
	unsigned int height = 0;
	unsigned short bfType = 0;

	if( argc < 3 )		//za malo argumentow
		return error( -1 );

	printf( "File name: %s\n", argv[ 1 ] );
	file = fopen( argv[ 1 ], "rb" );		//otwieramy plik
	if( file == 0 )
		return error( -2 );

	fread( &bfType, sizeof( unsigned short ), 1, file );
	if( bfType != 0x4D42 )
		return error( -3 );

	fread( &header, sizeof( BMPHeader ), 1, file );

	size = header.biSize;
	width = header.biWidth;
	height = header.biHeight;
	printf( "Rozmiar: %d\n", size );
	printf( "Wymiary: %d x %d\n", width, height );

	image = malloc( size - sizeof( BMPHeader ) - sizeof( unsigned short ) );
	fread( image, size - sizeof( BMPHeader ) - sizeof( unsigned short ), 1, file );
	fclose( file );

	result = malloc( size );
	memcpy( result, &bfType, sizeof( unsigned short ) );
	memcpy( result + 2, &header, sizeof( BMPHeader ) );

	median( image, result + sizeof( BMPHeader ) + sizeof( unsigned short ), width, height );

	file = fopen( argv[ 2 ], "wb" );
	if( file == 0 )
		return error( -2 );
	if( fwrite( result, 1, size, file ) != size )
		return error( -4 );


	//----------GRAFA----------
	ALLEGRO_DISPLAY * display = NULL;
	ALLEGRO_BITMAP * bitmap = NULL;

	if( !al_init() )
		al_show_native_message_box( display, "Error", "Error", "Failed to initialize allegro!", NULL, ALLEGRO_MESSAGEBOX_ERROR );
	if( !al_init_image_addon() )
		al_show_native_message_box( display, "Error", "Error", "Failed to initialize al_init_image_addon!", NULL, ALLEGRO_MESSAGEBOX_ERROR );

	display = al_create_display( 800, 600 );
	if( !display )
		al_show_native_message_box( display, "Error", "Error", "Failed to initialize display!", NULL, ALLEGRO_MESSAGEBOX_ERROR );

	bitmap = al_load_bitmap( argv[ 2 ] );
	if( !bitmap ){
		al_show_native_message_box( display, "Error", "Error", "Failed to load bitmap!", NULL, ALLEGRO_MESSAGEBOX_ERROR );
		al_destroy_display( display );
	}
	al_draw_bitmap( bitmap, 200, 200, 0 );

	al_flip_display();
	al_rest( 2 );

	al_destroy_display( display );
	al_destroy_bitmap( bitmap );
	//---------------------

	fclose( file );

	printf( "Obraz przefiltrowany pomyślnie.\n" );
	return 0;
}