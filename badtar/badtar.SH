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
echo "Extracting badtar/badtar.$manext (with variable substitutions)"
$rm -f badtar.$manext
$spitshell >badtar.$manext <<!GROK!THIS!
.TH BADTAR $manext ram
''' @(#) Manual page for badtar -- (c) ram January 1992
'''
''' $Id: badtar.SH,v 2.0.1.3 1993/04/26 11:15:53 ram Exp $
'''
''' $Log: badtar.SH,v $
''' Revision 2.0.1.3  1993/04/26  11:15:53  ram
''' patch27: manual page name was mis-spelled BABTAR
'''
''' Revision 2.0.1.2  92/05/02  14:10:56  ram
''' patch16: fixed incorrect extraction message
''' 
''' Revision 2.0.1.1  92/01/11  19:12:35  ram
''' patch11: created
''' 
'''
.SH NAME
badtar \- a filter for damaged tar files
.SH SYNOPSIS
\fBbadtar\fR [ \-\fBhiorsvV\fR ] [ \-\fBl\fI logfile\fR ]
[ \-\fBf\fI tape_drive\fR ] [ \-\fBu\fI uid\fR ] [ \-\fBg\fI gid\fR ]
.SH DESCRIPTION
\fIBadtar\fR can be used to extract files from a tar tape which
contains read errors. It is used as a filter whose output should be piped
into tar thus:
.sp
.in +5
badtar -f /dev/rmt0 -l logfile | tar xvf -
.in -5
.sp
This program is not perfect. It cannot read what cannot be read, but it
will continue over read errors, pad files to suitable lengths when blocks
are missing, ignore files whose header tar blocks are mangled, etc...
.PP
It is possible to read from a pipe by giving \- as argument to \-\fBf\fR.
However in that case, you need another program to read the tape device
(for instance \fIdd\fR) and read erros may be fatal. Besides, \fIbadtar\fR has
some neat options which let you overwrite the owner of the files in the
archive or strip the leading '/' in the path name to make them relative.
Here is a way of reading from a remote tape drive located on \fImoon\fR:
.sp
.in +5
remsh moon dd if=/dev/rmt0 conv=noerror,sync | \\\\
.br
badtar -f - | tar xvf -
.in -5
.sp
.PP
The log file (\-\fBl\fR flag) gives a list of all files found, indicates which
of them were padded, shows where blocks were deleted (i.e. files were lost)
and where bad blocks occured on the tape. You can get a good idea from this
list where files will have been mangled or lost. All error messages begin with
*** which makes life easier to find errors in a long list.
If the \-\fBl\fR flag is not given stderr is defaulted. If the \-\fBf\fR flag
is not given \fI$tapedev\fR is defaulted.
.SH OPTIONS
.TP 10
\-\fBf\fI file\fR
tells \fIbadtar\fR the output is to be taken from file \fIfile\fR. Use \- to
read standard input. By default, \fIbadtar\fR attempts to read \fI$tapedev\fR.
.TP
\-\fBg\fI gid\fR
directs \fIbadtar\fR to overwrite group membership to \fIgid\fR on file
extraction.
The \fIgid\fR has to be given in numeric form. Use \fI0\fR to force the
\fIgid\fR of the user running badtar.
.TP
\-\fBh\fR
prints the usage message and exits.
.TP
\-\fBi\fR
makes \fIbadtar\fR ignore the end of tape blocks. There is a risk \fIbadtar\fR
enters in an infinite loop when this option is used.
.TP
\-\fBl\fI logfile\fR
sets a logfile for \fIbadtar\fR to redirect his error messages. By default,
the standard error is used.
.TP
\-\fBo\fR
directs \fIbadtar\fR to overwrite the ownership of the file (both \fIuid\fR and
\fIgid\fR). It is a shortcut for \-\fBu\fI 0 \fR\-\fBg\fI 0\fR.
.TP
\-\fBr\fR
builds relative paths out of absolute ones by removing the leading slash in the
file name.
.TP
\-\fBs\fR
asks for silent mode. No logging is done.
.TP
\-\fBu\fI uid\fR
directs \fIbadtar\fR to overwrite ownership to \fIuid\fR on file
extraction.
The \fIuid\fR has to be given in numeric form. Use \fI0\fR to force the
\fIuid\fR of the user running badtar. This means there is no way to force
the owner to \fIroot\fR unless \fIbadtar\fR is run by the super-user. It
is considered to be a feature.
.TP
\-\fBv\fR
asks for verbose mode. The tar headers are written when found on the tape.
.TP
\-\fBV\fR
prints version number and exits.
.SH "SEE ALSO"
tar(1)
.SH AUTHORS
Mike Williams <mike@erix.UUCP>.
.br
Extended by Raphael Manfredi <ram@eiffel.com>.
.br
.sp
\fIBadtar\fR was enhanced at Interactive Software Engineering Inc, Santa
Barbara, USA.
!GROK!THIS!
chmod 444 badtar.$manext
