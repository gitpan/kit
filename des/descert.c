/*
 * $Id: descert.c,v 2.0.1.1 1991/04/01 15:39:44 ram Exp $
 *
 * $Log: descert.c,v $
 * Revision 2.0.1.1  1991/04/01 15:39:44  ram
 * patch1: created
 *
 */

#include <stdio.h>
int nfail = 0;
main()
{
	char key[8],plain[8],cipher[8],answer[8];
	int i;
	int test;
	int fail;

	desinit(0);

	for(test=0;!feof(stdin);test++){

		get8(key);
		printf(" K: "); put8(key);
		setkey(key);

		get8(plain);
		printf(" P: "); put8(plain);

		get8(answer);
		printf(" C: "); put8(answer);

		for(i=0;i<8;i++)
			cipher[i] = plain[i];
		endes(cipher);

		for(i=0;i<8;i++)
			if(cipher[i] != answer[i])
				break;
		fail = 0;
		if(i != 8){
			printf(" Encrypt FAIL");
			fail++;
		}
		dedes(cipher);
		for(i=0;i<8;i++)
			if(cipher[i] != plain[i])
				break;
		if(i != 8){
			printf(" Decrypt FAIL");
			fail++;
		}
		if(fail == 0)
			printf(" OK");
		else
			nfail++;
		printf("\n");
	}

	stats();
	/* NOTREACHED */
}

stats()
{
	printf("\n    -- ");
	if (nfail == 0)
		printf("All tests succesful");
	else if (nfail == 1)
		printf("FAILED 1 test");
	else
		printf("FAILED %d tests", nfail);
	printf(".\n\n");
	(void) exit((nfail == 0)? 0 : 1);
	/* NOTREACHED */
}

get8(cp)
char *cp;
{
	int i,t;

	for(i=0;i<8;i++){
		scanf("%2x",&t);
		if(feof(stdin))
			stats();
		*cp++ = t;
	}
}
put8(cp)
char *cp;
{
	int i;

	for(i=0;i<8;i++){
		printf("%02x",*cp++ & 0xff);
	}
}
