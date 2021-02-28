#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// #define ALLEGRO // TODO - uncomment if you are using allegro library

#ifdef ALLEGRO
#include <allegro5/allegro.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro_native_dialog.h>
#endif


int median( char *output, char *input, unsigned int width, unsigned int height );

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
	printf( "Error: " );
	switch( msg ) {
	case -1:
		printf( "Not enough arguments. You have to give input and output image name.\n" );
		break;
	case -2:
		printf( "Cannot open file..\n" );
		break;
	case -3:
		printf( "Input file is no BMP file.\n" );
		break;
	case -4:
		printf( "Cannot write to the file.\n" );
		break;
	default:
		printf( "Something went wrong.\n" );
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

	if( argc < 3 )		//not enough arguments
		return error( -1 );

	printf( "File name: %s\n", argv[ 1 ] );
	file = fopen( argv[ 1 ], "rb" );		//open the file
	if( file == 0 )
		return error( -2 );

	fread( &bfType, sizeof( unsigned short ), 1, file );
	if( bfType != 0x4D42 )
		return error( -3 );

	fread( &header, sizeof( BMPHeader ), 1, file );

	size = header.biSize;
	width = header.biWidth;
	height = header.biHeight;
	printf( "Size: %d\n", size );
	printf( "Dimensions: %d x %d\n", width, height );

	image = malloc( size - sizeof( BMPHeader ) - sizeof( unsigned short ) );
	fread( image, size - sizeof( BMPHeader ) - sizeof( unsigned short ), 1, file );
	fclose( file );

	result = malloc( size );
	memcpy( result, &bfType, sizeof( unsigned short ) );
	memcpy( result + 2, &header, sizeof( BMPHeader ) );
	//memcpy( result + sizeof( BMPHeader ) + sizeof( unsigned short ), image, size - sizeof( BMPHeader ) - sizeof( unsigned short ) );
	printf( "%d\n", median( result + sizeof( BMPHeader ) + sizeof( unsigned short ), image, width, height ) );
	file = fopen( argv[ 2 ], "wb" );
	if( file == 0 )
		return error( -2 );
	if( fwrite( result, 1, size, file ) != size )
		return error( -4 );


	#ifdef ALLEGRO
	//----------GRAFA----------
	ALLEGRO_DISPLAY* display = NULL;
	ALLEGRO_BITMAP* bitmap = NULL;

	if (!al_init())
		al_show_native_message_box(display, "Error", "Error", "Failed to initialize allegro!", NULL, ALLEGRO_MESSAGEBOX_ERROR);
	if (!al_init_image_addon())
		al_show_native_message_box(display, "Error", "Error", "Failed to initialize al_init_image_addon!", NULL, ALLEGRO_MESSAGEBOX_ERROR);

	display = al_create_display(width, height);
	if (!display)
		al_show_native_message_box(display, "Error", "Error", "Failed to initialize display!", NULL, ALLEGRO_MESSAGEBOX_ERROR);

	bitmap = al_load_bitmap(argv[2]);
	if (!bitmap) {
		al_show_native_message_box(display, "Error", "Error", "Failed to load bitmap!", NULL, ALLEGRO_MESSAGEBOX_ERROR);
		al_destroy_display(display);
	}
	al_draw_bitmap(bitmap, 0, 0, 0);

	al_flip_display();
	al_rest(10);

	al_destroy_display(display);
	al_destroy_bitmap(bitmap);
	//---------------------
	#endif // ALLEGRO

	fclose( file );

	printf( "Image succesfully filtered.\n" );
	return 0;
}
