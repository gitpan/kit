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
echo "Extracting btoa/Makefile (with variable substitutions)"
$spitshell >Makefile <<!GROK!THIS!
#
# Makefile for kit (sub-directory btoa)
#

# $Id: Makefile.SH,v 2.0.1.2 1992/04/20 17:32:09 ram Exp $
#
# $Log: Makefile.SH,v $
# Revision 2.0.1.2  1992/04/20  17:32:09  ram
# patch15: now creates directories before installing
#
# Revision 2.0.1.1  91/05/27  14:14:41  ram
# patch5: some dumb make failed on previous makefile
# 
# Revision 2.0  91/02/19  15:49:16  ram
# Baseline for first official release.
# 

SHELL = /bin/sh

CC = $cc
CFLAGS = $ccflags $optimize
RM = $rm
bin = $bin

!GROK!THIS!
$spitshell >>Makefile <<'!NO!SUBS!'
BIN = btoa atob hexencode hexdecode

all: $(BIN)

btoa: btoa.c
	$(CC) $(CFLAGS) -o $@ $@.c

atob: atob.c
	$(CC) $(CFLAGS) -o $@ $@.c

hexencode: hexencode.c
	$(CC) $(CFLAGS) -o $@ $@.c

hexdecode: hexdecode.c
	$(CC) $(CFLAGS) -o $@ $@.c

install: $(BIN)
	../install -d $(bin)
	-for file in $(BIN); do \
		../install -s -m 755 $$file $(bin); \
	done

clean:
	$(RM) -f *.o $(BIN)

realclean clobber: clean
	$(RM) -f core Makefile config.sh
!NO!SUBS!
chmod 644 Makefile
$eunicefix Makefile
