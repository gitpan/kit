case $CONFIG in
'')
	if test ! -f config.sh; then
		ln ../config.sh . || \
		ln ../../config.sh . || \
		ln ../../../config.sh . || \
		(echo "Can't find config.sh."; exit 1)
	fi
	. config.sh
	;;
esac
case "$0" in
*/*) cd `expr X$0 : 'X\(.*\)/'` ;;
esac
echo "Extracting shar/Makefile (with variable substitutions)"
$spitshell >Makefile <<!GROK!THIS!
#
# Makefile for kit (sub-directory shar)
#

# $Id: Makefile.SH,v 2.0.1.2 1992/04/20 17:42:50 ram Exp $
#
# $Log: Makefile.SH,v $
# Revision 2.0.1.2  1992/04/20  17:42:50  ram
# patch15: now creates directories before installing
#
# Revision 2.0.1.1  92/01/11  19:22:47  ram
# patch11: created
# 

SHELL = /bin/sh

RM = $rm
libdir = $privlib

!GROK!THIS!
$spitshell >>Makefile <<'!NO!SUBS!'
scripts = makeshar rshar
scriptsh = makeshar.SH rshar.SH
added = Makefile config.sh

all: $(scripts)

makeshar: makeshar.SH
	sh $@.SH

rshar: rshar.SH
	sh $@.SH

install: $(scripts)
	../install -d $(libdir)
	-for file in $(scripts); do \
		../install -m 555 $$file $(libdir); \
	done

clean:
	$(RM) -f $(scripts)

realclean clobber: clean
	$(RM) -f $(added)
!NO!SUBS!
chmod 755 Makefile
$eunicefix Makefile
