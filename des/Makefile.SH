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
echo "Extracting des/Makefile (with variable substitutions)"
$spitshell >Makefile <<!GROK!THIS!
#
# Makefile for kit (sub-directory des)
#

# $Id: Makefile.SH,v 2.0.1.5 1992/04/20 17:32:21 ram Exp $
#
# $Log: Makefile.SH,v $
# Revision 2.0.1.5  1992/04/20  17:32:21  ram
# patch15: now creates directories before installing
#
# Revision 2.0.1.4  92/01/11  19:13:59  ram
# patch11: now depends on the 'hasdes' configuration variable
# 
# Revision 2.0.1.3  91/11/25  12:03:16  ram
# patch8: this file was stamped with a wrong package name
# 
# Revision 2.0.1.2  91/05/27  14:15:38  ram
# patch5: some dumb make failed on previous makefile
# 
# Revision 2.0.1.1  91/04/01  15:38:51  ram
# patch1: created
# 

SHELL = /bin/sh

ALL = certify des
CC = $cc
CFLAGS = $ccflags $optimize
MAKE = make
RM = $rm
bin = $bin
!GROK!THIS!
case "$hasdes" in
false)
$spitshell >>Makefile <<'!NO!SUBS!'

all: $(ALL)

des: main.o des.o getpass.o misc.o getopt.o
	$(CC) $(CFLAGS) -o des main.o des.o getpass.o misc.o getopt.o

descert: descert.o des.o
	$(CC) $(CFLAGS) -o descert descert.o des.o

certify: testdata
	$(MAKE) $(MFLAGS) descert
	if ./descert < testdata; then touch certify; $(RM) descert descert.o; fi

install: des
	../install -d $(bin)
	../install -s -m 755 des $(bin)
	@echo "	Warning: manual pages for des not installed."

clean:
	rm -f *.o des descert

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
	$(RM) -f certify core Makefile config.sh

!NO!SUBS!
chmod 755 Makefile
$eunicefix Makefile
