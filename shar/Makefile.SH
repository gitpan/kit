: Makefile.SH generated from Jmake.tmpl and Jmakefile [jmake 3.0 PL13]
: $X-Id: Jmake.tmpl,v 3.0.1.1 1993/08/20 07:36:36 ram Exp ram $

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
CURRENT=shar
DIR=`echo $CURRENT/ | sed -e 's/\.\///g'`
echo "Extracting ${DIR}Makefile (with variable substitutions)"
DATE=`date`
$spitshell >Makefile <<!GROK!THIS!
########################################################################
# Makefile generated from Makefile.SH on $DATE

SHELL = /bin/sh
JMAKE = jmake
TOP = ..
CURRENT = $CURRENT
DIR = $DIR
INSTALL = ../install

########################################################################
# Parameters set by Configure -- edit config.sh if changes are needed

CTAGS = ctags
L = $manext
MANSRC = $installmansrc
MAKE = make
MV = $mv
PRIVLIB = $installprivlib
RM = $rm -f
SCRIPTDIR = $installscript

########################################################################
# Automatically generated parameters -- do not edit

SCRIPTS =  \$(BIN)

!GROK!THIS!
$spitshell >>Makefile <<'!NO!SUBS!'
########################################################################
# Jmake rules for building libraries, programs, scripts, and data files
# $X-Id: Jmake.rules,v 3.0 1993/08/18 12:04:14 ram Exp ram $

########################################################################
# Start of Jmakefile

# $X-Id: Jmakefile,v 2.9.1.2 92/08/26 12:33:22 ram Exp $
#
#  @COPYRIGHT@
#
# $X-Log:	Jmakefile,v $

BIN = rshar makeshar

all:: $(BIN)

local_realclean::
	$(RM) $(BIN)

rshar: rshar.SH
	/bin/sh rshar.SH

makeshar: makeshar.SH
	/bin/sh makeshar.SH


install:: $(SCRIPTS) $(LSCRIPTS)
	@for file in $(SCRIPTS) $(LSCRIPTS); do \
		case '${MFLAGS}' in *[i]*) set +e;; esac; \
		(set -x; $(INSTALL) -c -m 555 $$file $(SCRIPTDIR)); \
	done

deinstall::
	@for file in $(SCRIPTS) $(LSCRIPTS); do \
		case '${MFLAGS}' in *[i]*) set +e;; esac; \
		(set -x; $(RM) $(SCRIPTDIR)/$$file); \
	done


install:: $(BIN)
	@case '${MFLAGS}' in *[i]*) set +e;; esac; \
	for i in $(BIN); do \
		(set -x; $(INSTALL) -c -m 555 $$i $(PRIVLIB)); \
	done

deinstall::
	@case '${MFLAGS}' in *[i]*) set +e;; esac; \
	for i in $(BIN); do \
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

