/*

 #    #  ######  #    #  ######  #    #   ####    ####   #####   ######
 #    #  #        #  #   #       ##   #  #    #  #    #  #    #  #
 ######  #####     ##    #####   # #  #  #       #    #  #    #  #####
 #    #  #         ##    #       #  # #  #       #    #  #    #  #        ###
 #    #  #        #  #   #       #   ##  #    #  #    #  #    #  #        ###
 #    #  ######  #    #  ######  #    #   ####    ####   #####   ######   ###

	stdout = hexa(stdin)

	R. Manfredi and E. Mogenet
*/

/*
 * $Id: hexencode.c,v 2.0 1991/02/19 15:49:33 ram Exp $
 *
 * $Log: hexencode.c,v $
 * Revision 2.0  1991/02/19 15:49:33  ram
 * Baseline for first official release.
 *
 */

#include <stdio.h>

static char	rcs_id[] = "@(#)hexencode, stdout = hexa(stdin)";

#define QUARTET 0xF
static char	hexa[] = "0123456789ABCDEF";

main()
{
	int	c;
	int	jump;


	jump = 0;
	while (EOF != (c = getchar())) {
		putchar(hexa[(c>>4) & QUARTET]);
		putchar(hexa[c & QUARTET]);
		jump += 2;
		if ( jump > 75 ) {
			putchar('\n');
			jump = 0;
		}
	}
	putchar('\n');
	exit(0);
}


