/*
 * $Id: misc.c,v 2.0.1.1 1991/04/01 15:40:18 ram Exp $
 *
 * $Log: misc.c,v $
 * Revision 2.0.1.1  1991/04/01 15:40:18  ram
 * patch1: created
 *
 */

#include "../config.h"
#ifndef MEMSET
/* Set block of memory to constant */
memset(blk,val,size)
register char *blk;
register char val;
register unsigned size;
{
	while(size-- != 0)
		*blk++ = val;
}
#endif

#ifndef MEMCPY
/* Copy block of memory */
memcpy(dest,src,size)
register char *dest,*src;
register unsigned size;
{
	while(size-- != 0)
		*dest++ = *src++;
}
#endif

