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
echo "Extracting Makefile (with variable substitutions)"
$spitshell >Makefile <<!GROK!THIS!
#
#	Makefile for kit
#

# $Id: Makefile.SH,v 2.0.1.5 1992/01/11 19:08:43 ram Exp $
#
# $Log: Makefile.SH,v $
# Revision 2.0.1.5  1992/01/11  19:08:43  ram
# patch11: added subdirectories badtar and shar
#
# Revision 2.0.1.4  91/12/08  14:53:40  ram
# patch10: make clobber was not removing cppstdin
# 
# Revision 2.0.1.3  91/11/25  12:03:02  ram
# patch8: this file was stamped with a wrong package name
# 
# Revision 2.0.1.2  91/05/27  14:14:19  ram
# patch5: some dumb make failed on previous makefile
# 
# Revision 2.0.1.1  91/04/01  15:34:43  ram
# patch1: added des target
# 
# Revision 2.0  91/02/19  15:48:41  ram
# Baseline for first official release.
# 

SHELL = /bin/sh

SUBDIRS = badtar btoa kit shar man des
RM = $rm
!GROK!THIS!
$spitshell >>Makefile <<'!NO!SUBS!'

#
#	Building rules
#

all install clean realclean: makefiles
	-@for dir in $(SUBDIRS); do \
		(cd $$dir && make $@) \
	done

makefiles:
	-@for dir in $(SUBDIRS); do \
		(cd $$dir && if test ! -f Makefile; then \
			sh Makefile.SH; fi) \
	done

clobber: makefiles
	-@for dir in $(SUBDIRS); do \
		(cd $$dir && make $@) \
	done
	$(RM) -f config.h config.sh Makefile install cppstdin
!NO!SUBS!
chmod 755 Makefile
$eunicefix Makefile
