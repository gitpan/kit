case $CONFIG in
'')
	if test ! -f config.sh; then
		ln ../config.sh . || \
		ln ../../config.sh . || \
		ln ../../../config.sh . || \
		(echo "Can't find config.sh."; exit 1)
	fi 2>/dev/null
	. config.sh
	;;
esac
case "$0" in
*/*) cd `expr X$0 : 'X\(.*\)/'` ;;
esac
echo "Extracting badtar/Makefile (with variable substitutions)"
$spitshell >Makefile <<!GROK!THIS!
#
# Makefile for kit (sub-directory badtar)
#

# $Id: Makefile.SH,v 2.0.1.2 1992/04/20 17:31:53 ram Exp $
#
# $Log: Makefile.SH,v $
# Revision 2.0.1.2  1992/04/20  17:31:53  ram
# patch15: now creates directories before installing
#
# Revision 2.0.1.1  92/01/11  19:11:57  ram
# patch11: created
# 

SHELL = /bin/sh

CC = $cc
CFLAGS = $ccflags $optimize
RM = $rm
bin = $bin
man = $mansrc
manpage = badtar.$manext
!GROK!THIS!
case "$wantbtar" in
true)
$spitshell >>Makefile <<'!NO!SUBS!'

all: badtar $(manpage)

badtar: badtar.o
	$(CC) $(CFLAGS) -o badtar badtar.o

$(manpage): badtar.SH
	/bin/sh badtar.SH

install: badtar $(manpage)
	../install -d $(bin)
	../install -s -m 755 badtar $(bin)
	-if test "$(man)"; then \
		../install -d $(man); \
		../install -m 444 $(manpage) $(man); \
	fi

clean:
	rm -f *.o badtar $(manpage)

!NO!SUBS!
	;;
*)
$spitshell >>Makefile <<'!NO!SUBS!'

all install clean:

!NO!SUBS!
	;;
esac
$spitshell >>Makefile <<'!NO!SUBS!'
realclean clobber: clean
	$(RM) -f core Makefile config.sh

!NO!SUBS!
chmod 755 Makefile
$eunicefix Makefile
