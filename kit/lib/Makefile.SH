: Makefile.SH generated from Jmake.tmpl and Jmakefile [jmake 3.0 PL70]
: $X-Id: Jmake.tmpl,v 3.0.1.3 1997/02/28 14:56:16 ram Exp ram $

case $CONFIG in
'')
	if test -f config.sh; then TOP=.;
	elif test -f ../config.sh; then TOP=..;
	elif test -f ../../config.sh; then TOP=../..;
	elif test -f ../../../config.sh; then TOP=../../..;
	elif test -f ../../../../config.sh; then TOP=../../../..;
	else
		echo "Can't find config.sh."; exit 1
	fi
	. $TOP/config.sh
	;;
esac
case "$0" in
*/*) cd `expr X$0 : 'X\(.*\)/'` ;;
esac
CURRENT=kit/lib
DIR=`echo $CURRENT/ | sed -e 's/\.\///g'`
echo "Extracting ${DIR}Makefile (with variable substitutions)"

INSTALL=`echo $install | sed -e 's,\./i,\$(TOP)/i,'`
INSTALLDIR=`echo $installdir | sed -e 's,\./i,\$(TOP)/i,'`
DATE=`date`

$spitshell >Makefile <<!GROK!THIS!
########################################################################
# Makefile generated from Makefile.SH on $DATE

SHELL = /bin/sh
JMAKE = jmake
TOP = ../..
CURRENT = $CURRENT
DIR = $DIR
INSTALL = $INSTALL
INSTALLDIR = $INSTALLDIR

########################################################################
# Parameters set by Configure -- edit config.sh if changes are needed

CTAGS = ctags
MAKE = make
MV = $mv
PRIVLIB = $installprivlib
RM = $rm -f

!GROK!THIS!
$spitshell >>Makefile <<'!NO!SUBS!'
########################################################################
# Jmake rules for building libraries, programs, scripts, and data files
# $X-Id: Jmake.rules,v 3.0.1.6 1997/02/28 14:56:01 ram Exp ram $

########################################################################
# Start of Jmakefile

# $X-Id: Jmakefile,v 2.9 92/07/14 16:47:32 ram Exp $
#
#  @COPYRIGHT@
#
# $X-Log:	Jmakefile,v $
# Revision 2.9  92/07/14  16:47:32  ram
# 3.0 beta baseline.
#

FILES = secure compressors
SCRIPTS = getopt getproc minikit range

all::

all:: $(SCRIPTS)

local_realclean::
	$(RM) $(SCRIPTS)

getopt: getopt.SH
	/bin/sh getopt.SH

getproc: getproc.SH
	/bin/sh getproc.SH

minikit: minikit.SH
	/bin/sh minikit.SH

range: range.SH
	/bin/sh range.SH


install::
	@for dir in $(PRIVLIB); do \
	case '${MFLAGS}' in *[i]*) set +e;; esac; \
	(set -x; test -d $$dir || $(INSTALLDIR) $$dir); \
	done

deinstall::
	$(RM) -r $(PRIVLIB)

install:: $(FILES)
	@case '${MFLAGS}' in *[i]*) set +e;; esac; \
	for i in $(FILES); do \
	(set -x; $(INSTALL) -c -m 444 $$i $(PRIVLIB)); \
	done

deinstall::
	@case '${MFLAGS}' in *[i]*) set +e;; esac; \
	for i in $(FILES); do \
	(set -x; $(RM) $(PRIVLIB)/$$i); \
	done

install:: $(SCRIPTS)
	@case '${MFLAGS}' in *[i]*) set +e;; esac; \
	for i in $(SCRIPTS); do \
	(set -x; $(INSTALL) -c -m 555 $$i $(PRIVLIB)); \
	done

deinstall::
	@case '${MFLAGS}' in *[i]*) set +e;; esac; \
	for i in $(SCRIPTS); do \
	(set -x; $(RM) $(PRIVLIB)/$$i); \
	done

########################################################################
# Common rules for all Makefiles -- do not edit

emptyrule::

clean: local_clean
realclean: local_realclean
clobber: local_clobber

local_clean::
	$(RM) core *~ *.o

local_realclean:: local_clean

local_clobber:: local_realclean
	$(RM) Makefile config.sh

Makefile.SH: Jmakefile
	-@if test -f $(TOP)/.package; then \
	if test -f Makefile.SH; then \
	echo "	$(RM) Makefile.SH~; $(MV) Makefile.SH Makefile.SH~"; \
	$(RM) Makefile.SH~; $(MV) Makefile.SH Makefile.SH~; \
	fi; \
	echo "	$(JMAKE) -DTOPDIR=$(TOP) -DCURDIR=$(CURRENT)" ; \
	$(JMAKE) -DTOPDIR=$(TOP) -DCURDIR=$(CURRENT) ; \
	else touch $@; exit 0; fi

Makefile: Makefile.SH
	/bin/sh Makefile.SH

tags::
	$(CTAGS) -w *.[ch]
	$(CTAGS) -xw *.[ch] > tags

local_clobber::
	$(RM) tags

########################################################################
# Empty rules for directories with no sub-directories -- do not edit

install::
	@echo "install in $(CURRENT) done."

deinstall::
	@echo "deinstall in $(CURRENT) done."

install.man::
	@echo "install.man in $(CURRENT) done."

deinstall.man::
	@echo "deinstall.man in $(CURRENT) done."

Makefiles::

Makefiles.SH::

!NO!SUBS!
chmod 644 Makefile
$eunicefix Makefile

