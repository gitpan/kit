/*
 * $Id: getpass.c,v 2.0.1.3 1998/03/30 14:22:05 ram Exp $
 *
 * $Log: getpass.c,v $
 * Revision 2.0.1.3  1998/03/30 14:22:05  ram
 * patch35: switched to new metaconfig symbols
 *
 * Revision 2.0.1.2  91/04/30  13:33:30  ram
 * patch3: now relies on the new metaconfig symbol Signal_t
 * 
 * Revision 2.0.1.1  91/04/01  15:40:01  ram
 * patch1: created
 * 
 */

#include <stdio.h>
#include <signal.h>
#include "../config.h"

/* These defines should be correctly set up by Configure */
#ifdef I_TERMIOS
#include <termios.h>
#endif
#ifdef I_TERMIO
#include <termio.h>
#endif
#ifdef I_SGTTY
#include <sgtty.h>
#endif
#ifdef I_SYS_IOCTL
#include <sys/ioctl.h>
#endif

#define	TTY	"/dev/tty"	/* Change to "con" for MS-DOS */

/* Issue prompt and read reply with echo turned off */
char *
getpass(prompt)
char *prompt;
{
	register char *cp;
	int c;
	FILE *tty;
	static char pbuf[128];

#ifdef I_SGTTY
	struct sgttyb ttyb,ttysav;
#else
#ifdef I_TERMIOS
	struct termios ttyb, ttysav;
#else
	struct termio ttyb, ttysav;
#endif
#endif

	extern Signal_t (*signal())();
	Signal_t (*sig)();

	if ((tty = fdopen(open(TTY, 2), "r")) == NULL)
		tty = stdin;
	else
		setbuf(tty, (char *)NULL);
	sig = signal(SIGINT, SIG_IGN);

#ifdef I_SGTTY
	ioctl(fileno(tty), TIOCGETP, &ttyb);
	ioctl(fileno(tty), TIOCGETP, &ttysav);
	ttyb.sg_flags |= RAW;
	ttyb.sg_flags &= ~ECHO;
	ioctl(fileno(tty), TIOCSETP, &ttyb);
#else
#ifdef I_TERMIOS
	tcgetattr(fileno(tty), &ttyb);
	tcgetattr(fileno(tty), &ttysav);
#else
	ioctl(fileno(tty), TCGETA, &ttyb);
	ioctl(fileno(tty), TCGETA, &ttysav);
#endif
#ifdef CBREAK
	ttyb.c_lflag |= CBREAK;
#endif
#ifdef RAW
	ttyb.c_lflag |= RAW;
#endif
	ttyb.c_lflag &= ~ECHO;
#ifdef I_TERMIOS
	tcsetattr(fileno(tty), TCSANOW, &ttyb);
#else
	ioctl(fileno(tty), TCSETA, &ttyb);
#endif
#endif

	fprintf(stderr, "%s", prompt);
	fflush(stderr);
	cp = pbuf;
	for (;;) {
		c = getc(tty);
		if(c == '\r' || c == '\n' || c == EOF)
			break;
		if (cp < &pbuf[127])
			*cp++ = c;
	}
	*cp = '\0';
	fprintf(stderr,"\r\n");
	fflush(stderr);

#ifdef I_SGTTY
	ioctl(fileno(tty), TIOCSETP, &ttysav);
#else
#ifdef I_TERMIOS
	tcsetattr(fileno(tty), TCSANOW, &ttysav);
#else
	ioctl(fileno(tty), TCSETA, &ttysav);
#endif
#endif

	signal(SIGINT, sig);
	if (tty != stdin)
		fclose(tty);
	return(pbuf);
}
