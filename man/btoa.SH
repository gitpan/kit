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
echo "Extracting man/btoa.$manext (with variable substitutions)"
$rm -f btoa.$manext
$spitshell >btoa.$manext <<!GROK!THIS!
.TH BTOA $manext local
''' @(#) Manual page for atob/btoa -- (c) ram August 1990
'''
''' $Id: btoa.SH,v 2.0.1.1 1991/05/27 14:31:27 ram Exp $
'''
''' $Log: btoa.SH,v $
''' Revision 2.0.1.1  1991/05/27  14:31:27  ram
''' patch5: search for config.sh is now silent
'''
''' Revision 2.0  91/02/19  15:50:22  ram
''' Baseline for first official release.
''' 
'''
.SH NAME
btoa, atob \- encode/decode binary to printable ASCII
.SH SYNOPSIS
.B btoa
.br
.B atob
.SH DESCRIPTION
.I Btoa
is a filter that reads anything from the standard input, and encodes it into
printable ASCII on the standard output.  It also attaches a header and checksum
information used by the reverse filter 
.I atob 
to find the start of the data and to check integrity.
.PP
.I Atob
reads an encoded file, strips off any leading and
trailing lines added by mailers, and recreates a copy of the original file
on the standard output.
.I Atob 
gives NO output (and exits with an error message) if its input is garbage or 
the checksums do not check.
.PP
.SH FEATURES
.I Btoa
uses a compact base-85 encoding so that
4 bytes are encoded into 5 characters (file is expanded by 25%).
As a special case, 32-bit zero is encoded as one character.  This encoding
produces less output than
.IR uuencode "(1)."
.SH AUTHOR
Paul Rutter
.SH "SEE ALSO"
kit($manext), mail(1), uuencode(1)
!GROK!THIS!
chmod 444 btoa.$manext
