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
echo "Extracting man/Makefile (with variable substitutions)"
$spitshell >Makefile <<!GROK!THIS!
#
# Makefile for kit (sub-directory man)
#

# $Id: Makefile.SH,v 2.0.1.3 1992/04/20 17:39:21 ram Exp $
#
# $Log: Makefile.SH,v $
# Revision 2.0.1.3  1992/04/20  17:39:21  ram
# patch15: now creates directories before installing
#
# Revision 2.0.1.2  91/05/27  14:30:53  ram
# patch5: search for config.sh is now silent
# 
# Revision 2.0.1.1  91/04/30  13:35:12  ram
# patch3: installation of manual pages made optional
# 
# Revision 2.0  91/02/19  15:50:12  ram
# Baseline for first official release.
# 

SHELL = /bin/sh

RM = $rm
man = $mansrc

.SUFFIXES: .$manext .SH

.SH.$manext:
	sh $<

L = $manext
!GROK!THIS!
$spitshell >>Makefile <<'!NO!SUBS!'
manpage = atob.$(L) btoa.$(L) kit.$(L) mailkit.$(L) unkit.$(L)
added = Makefile config.sh

.SH:
	sh $<

all: $(manpage)

install: all
	-if test "$(man)"; then \
		../install -d $(man); \
		for file in $(manpage); do \
			../install -m 444 $$file $(man); \
		done; \
	fi

clean:
	$(RM) -f $(manpage)

realclean clobber: clean
	$(RM) -f $(added)
!NO!SUBS!
chmod 755 Makefile
$eunicefix Makefile
