case $CONFIG in
'')
	if test ! -f config.sh; then
		ln ../config.sh . || \
		ln ../../config.sh . || \
		ln ../../../config.sh . || \
		(echo "Can't find config.sh."; exit 1)
	fi 2>/dev/null
	. ./config.sh
	;;
esac
echo "Extracting config.h (with variable substitutions)"
sed <<!GROK!THIS! >config.h -e 's!^#undef!/\*#define!'
/*
 * This file was produced by running the config.h.SH script, which
 * gets its values from config.sh, which is generally produced by
 * running Configure.
 *
 * Feel free to modify any of this as the need arises.  Note, however,
 * that running config.h.SH again will wipe out any changes you've made.
 * For a more permanent change edit config.sh and rerun config.h.SH.
 *
 * \$Id: config.h.SH,v 2.0.1.6 1992/01/11 19:13:18 ram Exp $
 */

#ifndef _config_h_
#define _config_h_

/* BYTEORDER
 *	This symbol hold the hexadecimal constant defined in byteorder,
 *	i.e. 0x1234 or 0x4321, etc...
 */
#define BYTEORDER 0x$byteorder	/* large digits for MSB */

/* bcopy:
 *	This symbol is maped to memcpy if the  bcopy() routine is not
 *	available to copy strings.
 */
#$d_bcopy bcopy(s,d,l) memcpy((d),(s),(l))		/* mapped to memcpy */

/* GETOPT:
 *	This symbol, if defined, indicates that the getopt() routine exists.
 */
#$d_getopt	GETOPT		/**/

/* index:
 *	This preprocessor symbol is defined, along with rindex, if the system
 *	uses the strchr and strrchr routines instead.
 */
#$d_index	index strchr	/**/

/* MEMCPY:
 *	This symbol, if defined, indicates that the memcpy routine is available
 *	to copy blocks of memory. You should always use bcopy() instead of
 *	memcpy() because bcopy is remaped to memcpy if necessary. This means
 *	that a memcpy() routine must be provided in case MEMCPY is not defined
 *	and no bcopy() is found.
 */
#$d_memcpy	MEMCPY		/**/

/* MEMSET:
 *	This symbol, if defined, indicates that the memset routine is available
 *	to set blocks of memory. You should always use bzero() instead of
 *	memset() because bzero is remaped to memset if necessary. This means
 *	that a memset() routine must be provided in case MEMSET is not defined
 *	and no bzero() is found.
 */
#$d_memset	MEMSET		/**/

/* perror:
 *	This symbol is maped to null if the  perror() routine is not
 *	available to print system error messages.
 */
#$d_perror	perror(s)	;	/* mapped to a null statement */

/* SIGNAL_T:
 *	This symbol's value is either "void" or "int", corresponding to the
 *	appropriate return type of a signal handler.  Thus, you can declare
 *	a signal handler using "SIGNAL_T (*handler())()", and define the
 *	handler using "SIGNAL_T handler(sig)".
 */
#define SIGNAL_T $signal_t	/* Kept for backward compatibility */

/* I_FCNTL:
 *	This symbol, if defined, indicates to the C program that it should
 *	include <fcntl.h>.
 */
#$i_fcntl	I_FCNTL		/**/

/* I_SYSIOCTL:
 *	This symbol, if defined, indicates that <sys/ioctl.h> exists and should
 *	be included. Otherwise, include <sgtty.h> or <termio.h>.
 */
#$i_sysioctl	I_SYSIOCTL		/**/

/* I_TERMIO:
 *	This symbol, if defined, indicates that the program should include
 *	<termio.h> rather than <sgtty.h>.  There are also differences in
 *	the ioctl() calls that depend on the value of this symbol.
 */
/* I_TERMIOS:
 *	This symbol, if defined, indicates that the program should include
 *	the POSIX termios.h rather than sgtty.h or termio.h.
 *	There are also differences in the ioctl() calls that depend on the
 *	value of this symbol.
 */
/* I_SGTTY:
 *	This symbol, if defined, indicates that the program should include
 *	<sgtty.h> rather than <termio.h>.  There are also differences in
 *	the ioctl() calls that depend on the value of this symbol.
 */
#$i_termio	I_TERMIO		/**/
#$i_termios	I_TERMIOS		/**/
#$i_sgtty	I_SGTTY		/**/

/* VOIDFLAGS
 *	This symbol indicates how much support of the void type is given by this
 *	compiler.  What various bits mean:
 *
 *	    1 = supports declaration of void
 *	    2 = supports arrays of pointers to functions returning void
 *	    4 = supports comparisons between pointers to void functions and
 *		    addresses of void functions
 *	    8 = suports declaration of generic void pointers
 *
 *	The package designer should define VOIDUSED to indicate the requirements
 *	of the package.  This can be done either by #defining VOIDUSED before
 *	including config.h, or by defining defvoidused in Myinit.U.  If the
 *	latter approach is taken, only those flags will be tested.  If the
 *	level of void support necessary is not present, defines void to int.
 */
#ifndef VOIDUSED
#define VOIDUSED $defvoidused
#endif
#define VOIDFLAGS $voidflags
#if (VOIDFLAGS & VOIDUSED) != VOIDUSED
#$define void int		/* is void to be avoided? */
#$define M_VOID			/* Xenix strikes again */
#endif

/* TAPEDEV:
 *	This symbol hols the full path name of the default tape device. It
 *	is usually located in /dev under the name rmt or rst followed by a
 *	single digit.
 */
#define TAPEDEV "$tapedev"	/**/

#endif
!GROK!THIS!
