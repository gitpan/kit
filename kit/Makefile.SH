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
echo "Extracting kit/Makefile (with variable substitutions)"
$spitshell >Makefile <<!GROK!THIS!
#
# Makefile for kit (sub-directory kit)
#

# $Id: Makefile.SH,v 2.0.1.8 1993/02/08 18:12:09 ram Exp $
#
# $Log: Makefile.SH,v $
# Revision 2.0.1.8  1993/02/08  18:12:09  ram
# patch24: new target 'secure' for alien code detection in archive
#
# Revision 2.0.1.7  93/01/11  18:04:13  ram
# patch22: new getopt target
# 
# Revision 2.0.1.6  92/09/04  19:22:28  ram
# patch19: forgot the 'range' target
# 
# Revision 2.0.1.5  92/05/02  14:13:13  ram
# patch16: added rules for new range script
# 
# Revision 2.0.1.4  92/04/20  17:32:57  ram
# patch15: now creates directories before installing
# patch15: minikit is now created via a .SH file
# 
# Revision 2.0.1.3  91/11/25  15:49:18  ram
# patch9: now installs minikit in the private kit library
# 
# Revision 2.0.1.2  91/11/25  12:03:28  ram
# patch8: this file was stamped with a wrong package name
# 
# Revision 2.0.1.1  91/05/27  14:21:28  ram
# patch5: some dumb make failed on previous makefile
# 
# Revision 2.0  91/02/19  15:49:49  ram
# Baseline for first official release.
# 

SHELL = /bin/sh

RM = $rm
binsh = $scriptdir
libdir = $privlib

!GROK!THIS!
$spitshell >>Makefile <<'!NO!SUBS!'
bin = kit mailkit unkit
libsh = minikit range getopt
lib = secure
scripts = $(bin) $(libsh) $(lib)
scriptmade = $(bin) $(libsh)
scriptsh = kit.SH mailkit.SH unkit.SH minikit.SH
added = Makefile config.sh

all: $(scripts)

kit: kit.SH
	sh $@.SH

mailkit: mailkit.SH
	sh $@.SH

unkit: unkit.SH
	sh $@.SH

minikit: minikit.SH
	sh $@.SH

range: range.SH
	sh $@.SH

getopt: getopt.SH
	sh $@.SH

install: $(scripts)
	../install -d $(binsh)
	-for file in $(bin); do \
		../install -m 755 $$file $(binsh); \
	done
	../install -d $(libdir)
	-for file in $(libsh) $(lib); do \
		../install -m 755 $$file $(libdir); \
	done

clean:
	$(RM) -f $(scriptmade)

realclean clobber: clean
	$(RM) -f $(added)
!NO!SUBS!
chmod 755 Makefile
$eunicefix Makefile
