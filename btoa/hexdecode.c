
/*

 #    #  ######  #    #  #####   ######   ####    ####   #####   ######
 #    #  #        #  #   #    #  #       #    #  #    #  #    #  #
 ######  #####     ##    #    #  #####   #       #    #  #    #  #####
 #    #  #         ##    #    #  #       #       #    #  #    #  #        ###
 #    #  #        #  #   #    #  #       #    #  #    #  #    #  #        ###
 #    #  ######  #    #  #####   ######   ####    ####   #####   ######   ###

	Converts hex from stdin to stdout.

	R. Manfredi and E. Mogenet, June 1990.
*/

/*
 * $Id: hexdecode.c,v 2.0 1991/02/19 15:49:29 ram Exp $
 *
 * $Log: hexdecode.c,v $
 * Revision 2.0  1991/02/19 15:49:29  ram
 * Baseline for first official release.
 *
 */

#include <stdio.h>

static char	rcs_id[] = "@(#)hexdecode, convert hex from stdin to stdout";

#define ishexa(x) (((x)>='0' && (x)<='9') || ((x)>='A' && (x)<='F'))
#define tohexa(x) ( (x)>='A' ? (x)-'A'+0xA : (x)-'0' )

main(argc, argv)
int	argc;
char	**argv;
{
	int	c1, c2;

	while (EOF != (c1 = getchar())) {
		if (ishexa(c1)) {
			c2 = getchar();
			if (ishexa(c2))
				putchar((tohexa(c1) << 4) | (tohexa(c2)));
			else
				goto corrupted;
		} else if ( c1 != '\n' ) {
corrupted:
			fprintf(stderr, "%s: file corrupted\n", argv[0]);
			exit(1);
		}
	}
	exit(0);
}


