/*

 #####    #####   ####     ##             ####
 #    #     #    #    #   #  #           #    #
 #####      #    #    #  #    #          #
 #    #     #    #    #  ######   ###    #
 #    #     #    #    #  #    #   ###    #    #
 #####      #     ####   #    #   ###     ####

	btoa: version 4.0
	stream filter to change 8 bit bytes into printable ascii
	computes the number of bytes, and three kinds of simple checksums
	incoming bytes are collected into 32-bit words, then printed in
	base 85 exp(85,5) > exp(2,32)
	the ASCII characters used are between '!' and 'u'
	'z' encodes 32-bit zero; 'x' is used to mark the end of encoded data.

	Paul Rutter Joe Orost

	Raphael Manfredi added support for 64 bits platforms.
*/

/*
 * $Id: btoa.c,v 2.0.1.1 1993/04/26 11:18:21 ram Exp $
 *
 * $Log: btoa.c,v $
 * Revision 2.0.1.1  1993/04/26 11:18:21  ram
 * patch27: added support for 64 bits architecture (tested on Alpha)
 *
 * Revision 2.0  91/02/19  15:49:25  ram
 * Baseline for first official release.
 * 
 */

#include <stdio.h>
#include "../config.h"

/* Provision for 64 bits machines -> remaps long to int. If the machine is
 * ILP 64 (Integer, Long and Pointer types on 64 bits), then everything is fine,
 * since both longs and ints can be used. If the machine is LP 64, then it has
 * a 32 bits arithmetic and long must be used as an int.
 */
#if (BYTEORDER | 0xffff) == 0xffff
typedef long long_t;			/* 32 bits machines */
#else
typedef int long_t;				/* 64 bits, hopefully */
#endif


#define reg register

#define MAXPERLINE 78

long_t Ceor = 0;
long_t Csum = 0;
long_t Crot = 0;

long_t ccount = 0;
long_t bcount = 0;
long_t word;

#define EN(c)	(int) ((c) + '!')

encode(c) reg c;
{
  Ceor ^= c;
  Csum += c;
  Csum += 1;
  if (Crot & 0x80000000) {
    Crot <<= 1;
    Crot += 1;
  } 
  else {
    Crot <<= 1;
  }
  Crot += c;

  word <<= 8;
  word |= c;
  if (bcount == 3) {
    wordout(word);
    bcount = 0;
  } 
  else {
    bcount += 1;
  }
}

wordout(word) reg long_t word;
{
  if (word == 0) {
    charout('z');
  } 
  else {
    reg long_t tmp = 0;

    if (word < 0)
    { /* Because some don't support unsigned long */
      tmp = 32;
      word = word - (long_t)(85 * 85 * 85 * 85 * 32);
    }
    if (word < 0) {
      tmp = 64;
      word = word - (long_t)(85 * 85 * 85 * 85 * 32);
    }
    charout(EN((word / (long_t)(85 * 85 * 85 * 85)) + tmp));
    word %= (long_t)(85 * 85 * 85 * 85);
    charout(EN(word / (85 * 85 * 85)));
    word %= (85 * 85 * 85);
    charout(EN(word / (85 * 85)));
    word %= (85 * 85);
    charout(EN(word / 85));
    word %= 85;
    charout(EN(word));
  }
}

charout(c) {
  putchar(c);
  ccount += 1;
  if (ccount == MAXPERLINE) {
    putchar('\n');
    ccount = 0;
  }
}

main(argc,argv)
char **argv;
{
  reg int c;
  reg long_t n;

  if (argc != 1) {
    fprintf(stderr,"bad args to %s\n", argv[0]);
    exit(2);
  }
  printf("xbtoa Begin\n");
  n = 0;
  while ((c = getchar()) != EOF) {
    encode(c);
    n += 1;
  }
  while (bcount != 0) {
    encode(0);
  }
  /* n is written twice as crude cross check*/
  if (ccount == 0) /* ccount == 0 means '\n' just written in charout() */
    ; /* this avoids bug in BITNET, which changes blank line to spaces */
  else
    putchar('\n');
  printf("xbtoa End N %d %x E %x S %x R %x\n",
	(int) n, (int) n, (int) Ceor, (int) Csum, (int) Crot);
  exit(0);
}

