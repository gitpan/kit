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
echo "Extracting man/kit.$manext (with variable substitutions)"
$rm -f kit.$manext
$spitshell >kit.$manext <<!GROK!THIS!
.TH KIT $manext "Version $VERSION PL$PATCHLEVEL"
''' @(#) Manual page for mailing kit -- (c) ram July 1990
'''
''' $Id: kit.SH,v 2.0.1.14 1995/10/12 11:04:03 ram Exp $
'''
''' $Log: kit.SH,v $
''' Revision 2.0.1.14  1995/10/12  11:04:03  ram
''' patch31: updated my e-mail address
''' patch31: fixed a few typo
'''
''' Revision 2.0.1.13  1993/04/26  11:22:28  ram
''' patch27: cshar(1) man page not referenced any more.
''' patch27: now contains a pointer to some unshar(1) man page
'''
''' Revision 2.0.1.12  93/02/08  18:14:56  ram
''' patch24: documents new options -d, -s and -S for unkit
''' patch24: new file 'secure' installed in private library
''' 
''' Revision 2.0.1.11  93/01/11  18:08:33  ram
''' patch22: manual page now carries version number and patchlevel
''' patch22: added OPTIONS section for quick reference
''' 
''' Revision 2.0.1.10  92/08/17  18:01:16  ram
''' patch18: documents new -k option for unkit
''' patch18: unkit can now deal with multiple kit parts in a single file
''' patch18: (the previous feature was suggested by Bertrand Meyer)
''' 
''' Revision 2.0.1.9  92/05/02  14:19:05  ram
''' patch16: documents new -r option for mailkit and -S for kit
''' patch16: mailkit now supports multiple -l options
''' patch16: two environment variables are used: EDITOR and MAILER
''' patch16: added example using mailkit -r
''' 
''' Revision 2.0.1.8  92/04/20  17:42:36  ram
''' patch15: documents the new -a option
''' patch15: older kits will not honor -a or -M (new paragraph in BUGS)
''' 
''' Revision 2.0.1.7  92/01/13  14:21:42  ram
''' patch13: the built-in unshar in unkit may now be used alone
''' 
''' Revision 2.0.1.6  92/01/11  19:22:08  ram
''' patch11: the .so directive was made relative to make man happy
''' patch11: documents badtar and cshar-emulating scripts
''' 
''' Revision 2.0.1.5  91/11/25  15:53:01  ram
''' patch9: added kit's -M option to include minikit
''' patch9: documents the tar -o possible problem
''' 
''' Revision 2.0.1.4  91/11/25  12:10:23  ram
''' patch8: documents new -l option for kit and mailkit
''' 
''' Revision 2.0.1.3  91/05/27  14:32:48  ram
''' patch5: search for config.sh is now silent
''' patch5: documented new options -d and -n for kit
''' patch5: new option -n for mailkit
''' patch5: the 'kit .' bug has now a workaround thanks to -d
''' patch5: new example to show usage of -d and -n
''' 
''' Revision 2.0.1.2  91/04/30  13:38:47  ram
''' patch3: fixed some English mistakes/misspellings
''' patch3: unshar is no longer needed to unkit (built-in)
''' patch3: the NOTE section has been revised
''' 
''' Revision 2.0.1.1  91/04/01  15:52:58  ram
''' patch1: documented the new kit options -x, -k and -X
''' patch1: new naming conventions for split files are described
''' 
''' Revision 2.0  91/02/19  15:50:28  ram
''' Baseline for first official release.
''' 
'''
.SH NAME
kit, mailkit, unkit \- the ultimate mailing tools
.SH SYNOPSIS
\fBkit\fR [ \fB\-EFHMBVXefhpx\fR ] [ \fB\-S\fI size\fR ]
[ \fB\-a\fI address\fR ] [ \fB\-k\fI key\fR ]
[ \fB\-d\fI dir\fR ] [ \fB\-m\fI address\fR ] [ \fB\-n\fI basename\fR ]
[ \fB\-l\fI file\fR ] [ \fB\-s\fI name\fR ] \fIdirectories\fR | \fIfiles\fR
.sp
\fBmailkit\fR [ \fB\-EFVcefhp\fR ] [ \fB\-l\fI file\fR ]
[ \fB\-n\fI partname\fR ] \fItitle\fR [ \fIaddress(es)\fR ]
.sp
\fBunkit\fR [ \fB\-bhlprRsSV\fR ] [\fB\-d\fI dir\fR ]
[ \fB\-k\fI key\fR ] [ \fIfiles\fR ]
.SH DESCRIPTION
'''
''' Kit
'''
\fIKit\fR is the ultimate mailing tool. It enables you to mail
data without any consideration of possible escape sequences or
control characters.
Given a file name or a directory, it builds a single file using
\fItar\fR(1) and \fIcompress\fR(1). Then this file is hex-encoded
(option \fB\-H\fR) or ASCII-encoded with \fIbtoa\fR(1)
(option \fB\-B\fR, which is used by default) before being shell-archived.
\fIKit\fR produces files that match "Kit*" regular expression.
This default base name can be changed thanks to the \fB\-n\fR option.
With the \fB\-m\fR option, it is possible to give one mail address, and
\fIkit\fR will invoke \fImailkit\fR to send the archive. There may be
as many \fB\-m\fR options as needed (to send the same archive to more
than a single person).
If there are a lot of recipients, you may want to store them in a file
and use the \fB\-l\fR option to tell \fIkit\fR where the recipient file
is located.
.PP
The \fB\-E\fR, \fB\-F\fR, \fB\-e\fR, \fB\-f\fR and \fB\-p\fR options are
passed on to \fImailkit\fR, so
if no \fB\-m\fR option is used, they will be ignored. When sending
files with \fB\-m\fR, the subject of the message holds the name of
the first file given in the command line (supposed to be the name
of the kit). It is possible to overwrite this default by using the
\fB\-s\fR option.
.PP
If you want to send sensitive data, it is possible to encrypt them using
a public-domain implementation of Data Encryption Standard (DES).
The \fB\-x\fR option will use the Cipher Block Chaining mode (default),
while \fB\-X\fR requests the Electronic Code Book mode. If you do not
specify the encryption key with \fB\-k\fR, \fIdes\fR(1) will prompt you
for one. If you use the \fB\-k\fR option, \fB\-x\fR is assumed.
.PP
It may happen that there are no write permissions in the directory
where the root directory to be kitted lies. The \fB\-d\fR option enables
you to specify another directory, where all the temporary files will be
stored. If you use something like \fI/tmp\fR, you must be careful to use
\fB\-n\fR to change the base name used (in case someone else is doing
the same thing, otherwise files may get mangled). To prevent common mistakes,
\fIkit\fR will stop and give an error message if the argument of \fB\-d\fR is
not a directory, if the directory is not writable by the user, or if
a kit file is present in the temporary directory (same base name).
.PP
When you send a kit to someone who may not have \fIkit\fR, the \fB\-M\fR
option may be used to include a \fIminikit\fR script, which is a minimal
set of commands to unkit an unencrypted ASCII-encoded kit. The overhead is
small (around 4K) and some instructions are provided in the header of every
kit part. The minikit is usually called \fIminikit\fR, but should you
already have a file with that name in your distribution, it will be renamed
\fIMINIKIT\fR. If by chance (!) you named one of your files MINIKIT, then
a unique name of the form \fImkitXXXXX\fR will be generated (XXXXX stands
for the PID of the \fIkit\fR process).
.PP
By using the \fB\-a\fR option, you ask the remote \fIunkit\fR program to send
an automatic acknowledgment to the specified e-mail address upon successful
archive extraction. However, this feature is only supported if the remote
end has at least the 2.0 PL15 release. You will receive a short message with
a \fIjunk\fR precedence, telling you who extracted the archive and when.
.PP
The default part size generated by kit is currently 50000 bytes. However, this
can be changed throughout the \fB\-S\fR option, which expects a part size as
argument. It can be given in bytes (e.g. \fI\-S 40000\fR to set the maximum
part size to 40000 bytes) or in kbytes by appending a \fIk\fR at the end
(i.e. \fI-S 60k\fR would produce parts with size ranging up to 61440 bytes).
'''
''' Mailkit
'''
.PP
\fIMailkit\fR takes "Kit*" files and sends them to a list of addresses.
The \fB\-n\fR option can be used to change that base name, if necessary.
Each message sent corresponds to one part and has its \`Subject:'
field set to the number of this part with the \fItitle\fR given, and you
also have the total number of parts, so that missing parts can easily
be located.
.PP
The options \fB\-E\fR and \fB\-e\fR from \fImailkit\fR enable you to give
the recipient some instructions. They both call an editor. At the
top of the file edited, there is a little message, which
will (of course) be stripped from the text you enter, so do not
remove it or your own message will be cut instead. With \fB\-E\fR,
the message will be sent in an extra part (#0), while with \fB\-e\fR
it will be included in each part. Empty messages will be ignored.
.PP
Options \fB\-F\fR and \fB\-f\fR are very similar, but take their
input from stdin (standard input) instead of calling an editor.
Option \fB\-p\fR asks \fImailkit\fR for preserving mailed files. They
are removed by default.
.PP
When \fImailkit\fR is given a \fB\-l\fR option, it takes the file name
as a file whith recipients addresses in it and adds the optional addresses that
may be given on the command line. Addresses in the recipient file are
separated with spaces, commas or new lines. Shell-style comments starting with
a pound sign (#) are allowed. More than one \fB\-l\fR can be used to get
addresses from multiple files (duplicates will not be removed by \fImailkit\fR
but should be taken care of by the underlying transport mechanism).
.PP
If \fImailkit\fR is invoked by \fIkit\fR via \fB\-m\fR options, it will be
given the \fB\-c\fR flag to clean up parts when they are successfully sent,
unless \fB\-p\fR was also provided. However, when invoking \fImailkit\fR
directly from a shell, the default action is to not remove the parts when they
have been sent (that is to say, \fB\-p\fR is the default action unless you
add the \fB-c\fR option yourself). If for some reason one part could not be
sent and \fImailkit\fR was directed to remove parts when sent, then the
file is not removed immediately. If the input and output are connected to a
terminal, \fImailkit\fR will ask you at the end whether you wish to keep the
unsent parts, on an individual basis. Otherwise, (e.g. standard output
redirected to a file), the unsent parts will be removed without asking.
.PP
Another useful feature when invoking \fImailkit\fR manually is the ability
to send only a subset of all the kit parts by using the \fB\-r\fR option
and supplying a range list of parts to be sent. A \fIrange list\fR
is a set of ranges comma separated. A \fIrange\fR is a part number by itself or
a set of two numbers
separated with a minus sign, indicating the lowest and the largest bound, hence
specifying an interval. If the lowest bound is missing, 1 is assumed. If the
largest bound is missing, the total number of parts is substituted. Thus,
a range of \fI1-\fR means all the parts, while \fI1,4-7,10\fR would send parts
1, 4 trough 7 and 10. Finally, \fI-5,8-\fR would send parts 1 through 5 and
8 up to the end. If you introduce spaces in your range list specification,
do not forget to quote the whole list for the shell...
'''
''' Unkit
'''
.PP
\fIUnkit\fR is used to restore the original files. The argument is
a list of archive files (or mail files, as \fIunshar\fR(1), which
is called by \fIunkit\fR, can deal with mail headers).
Input files are not removed unless option \fB\-r\fR is given. By default,
option \fB\-p\fR is used to preserve the input file(s).
If no file name is given to \fIunkit\fR, the standard input is processed.
This is useful to process messages directly from a mail user agent.
.PP
You may save more than one kit part into a file and give that file as an
argument to \fIunkit\fR, which will then identify and extract the embeded
parts to process them. The program lists on the standard error the files
as they are processed and tells you how many kit parts it found within each
file.
.PP
Sometimes, \fItar\fR does not work well accross NFS and will fail restoring
ownership on files, even with the \-\fBo\fR option. If you chose to install
\fIbadtar\fR at configuration time, you may use \-\fBb\fR to instruct
\fIunkit\fR using \fIbadtar\fR as a filter before running \fItar\fR. This is
the default action on some systems (the \-\fBh\fR option will tell you
what was determined at configuration time).
.PP
If you want to know what \fIunkit\fR will create without actually
doing it, use the \fB\-l\fR option. With this option, \fB\-r\fR is
ignored. You may also use \fIunkit\fR in place of \fIunshar\fR: it will
stop after having unpacked the shell archives if it does not detect any
kit file.
.PP
When unpacking crypted archives, the \fB\-k\fR option may be used to
specify the key to be used by DES. If you do not supply it, DES will
prompt you on the terminal.
.PP
By default, \fIunkit\fR will perform security checks on the shell archives
(if \fIperl\fR is available) to detect alien code. It will skip those parts
containing suspicious code which should not be part of the archive. You may
explicitely skip those checks by using the \fB\-s\fR option, which should be
used only when \fIunkit\fR input can be reliably trusted. Unfortunately, the
script used to make those checks is written in \fIperl\fR, so nothing will
happen if \fIperl\fR is not in your PATH. The \fB\-S\fR option will make kit
abort with an error if it is unable to perform security checks due to the
absence of \fIperl\fR.
.PP
For all of these commands, option \fB\-V\fR prints the version
number with the current patch level and exits, while \fB\-h\fR gives
a little help message with the syntax and the meaning of the options.
.SH OPTIONS
This section summarizes the different options. All the options may be specified
separately (e.g. \fB\-a \-b \fIfoo\fR \-c) or grouped together, along with
optional arguments (e.g. \fB\-ac\fR \fB\-b\fIfoo\fR). Option parsing stops
when \-\- is encountered.
'''
''' Kit
'''
.PP
\fIKit\fR has the following options:
.TP 15
.B \-B
Use \fIbtoa\fR encoding (default), as opposed to hexadecimal encoding.
.TP
.B \-E
Edit instructions which will be sent as part #0.
.TP
.B \-F
Get instructions to be sent as part #0 from standard input.
.TP
.B \-H
Use hexadecimal encoding, as opposed to the default \fIbtoa\fR. This is an
obsolete feature, kept for compatibility with \fIkit\fR 1.0.
.TP
.B \-M
Include \fIminikit\fR in the distribution, in order to allow unkiting
by the recipient, should \fIkit\fR be missing at the remote site. Note that
\fIminikit\fR will only be able to unkit plain \fIbtoa\fR-encoded packages
(i.e. encryption is not supported, although automatic acknowledgment is).
.TP
.B \-V
Print version number and patchlevel.
.TP
.B \-S\fI size
Set each part size in bytes or kbytes (by appending a single \fIk\fR after
the size figure). The actual size of each part may be slightly bigger than
the maximum stated (a few hundred bytes at most).
.TP
.B \-X
Encryption with DES Electronic Code Block algorithm.
You will be prompted for a key, unless you specify one on the command line via
the \fB\-k\fR option.
.TP
.B \-a\fI address
Ask the unkiting process to send an acknowldgment to the specified e-mail
address upon successful extraction.
.TP
.B \-d\fI dir
Put temporary files in the specified directory. This is useful if you do not
have writing permission in the current directory. If you specify a common
directory like \fI/tmp\fR, be sure to use the \fB\-n\fR option or your kit
might be clobbered if somebody else is doing the same thing.
.TP
.B \-e
Edit instructions to be sent at the top of each part.
.TP
.B \-f
Get instructions to be sent at the top of each part from standard input.
.TP
.B \-h
Print usage and option summary.
.TP
.B \-k\fI key
Set the key to be used for encryption. The \fB\-x\fR option will be assumed,
unless \fB\-X\fR is explicitely given to override the default.
.TP
.B \-m\fI address
Invoke \fImailkit\fR to send all the parts at the given address. Several
\fB\-m\fR may be specifed to send the package to more than one recipient. The
kit parts will be removed at the end, unless \fB\-p\fR is given. When sending
large files to multiple recipients, it is wise to use this option in case one
part gets lost.
.TP
.B \-l\fI file
Send the kit parts to the recipients held in the file (one recipient per line).
.TP
.B \-n\fI basename
Set the basename of the generated parts. The default is \fIKit\fR. You should
use this option when a kit is already present in the current directory, or when
you use something like \fB\-d /tmp\fR.
.TP
.B \-p
Preserve file sent. This option is meaningful only when \fB\-m\fR or \fB-l\fR
is given.
.TP
.B \-s\fI name
Set the kit name, which will be copied as-is into the Subject of messages
sent by \fImailkit\fR (provided \fB\-m\fR or \fB\-l\fR is specified), and also
in the automatic acknowledgment. By default, the name of the first directory
or file specified on the command line will be used.
.TP
.B \-x
Use DES Cipher Block Chaining encryption algorithm.
You will be prompted for a key, unless you specify one on the command line via
the \fB\-k\fR option.
'''
''' Mailkit
'''
.PP
\fIMailkit\fR recognizes the following options:
.TP 15
.B \-E
Edit instructions which will be sent as part #0.
.TP
.B \-F
Get instructions to be sent as part #0 from standard input.
.TP
.B \-V
Print version number and patchlevel.
.TP
.B \-c
Clean up after each part sent: all the parts successfully sent will be
removed from the disk.
.TP
.B \-e
Edit instructions to be sent at the top of each part.
.TP
.B \-f
Get instructions to be sent at the top of each part from standard input.
.TP
.B \-h
Print usage and option summary.
.TP
.B \-l\fI file
Get the recipient list from a file (one recipient per line).
.TP
.B \-n\fI basename
Set the basename of the generated parts. The default is \fIKit\fR. You should
use this option when more than one kit is present in the current directory,
or when you used the \fIkit\fR's \fB\-n\fR option to change the default
basename.
.TP
.B \-p
Preserve files sent. This is the default, unless \fB\-c\fR is specified.
.TP
.B \-r\fI range
Specify which parts are to be sent. For instance, \fB\-r\fI 1,4-7\fR would
send part #1 and then parts #4 through #7.
'''
''' Unkit
'''
.PP
\fIUnkit\fR uses the following options:
.TP 15
.B \-R
Tell \fIunkit\fR that it should use \fIbadtar\fR in order to strip leading '/'
in pathnames. Use this option when the remote party has sent you a kit with
absolute pathnames. It silently turns on \fB\-b\fR as well.
.B \-S
Complain loudly and abort if \fIperl\fR is not found, since that would make
it impossible to check each kit part for possible alien code before running
them through the shell.
.TP
.B \-V
Print version number and patchlevel.
.TP
.B \-b
Force usage of \fIbadtar\fR.
.TP
.B \-d\fI dir
Go to \fIdir\fR before starting extraction.
.TP
.B \-h
Print usage and option summary.
.TP
.B \-k\fI key
Set the key to be used for data decryption. \fIUnkit\fR is able to determine
automatically whether decryption is needed or not and will prompt you for the
key unless this option is used.
.TP
.B \-l
Lists the files contained in the kit package without extracting them.
.TP
.B \-r
Remove input files if unshar succeeds.
.TP
.B \-s
Force skipping of security checks, which are conducted only if \fIperl\fR is
available in your PATH.
.SH FILES
.PD 0
.TP 15
{zag,zcb,zec}.hex.*
temporary files used by \fIkit\fR and \fIunkit\fR for datas which
are hex-encoded.
.TP
{zag,zcb,zec}.ba.*
temporary files used by \fIkit\fR and \fIunkit\fR for datas which
are ASCII-encoded.
.TP
Kit*
files generated by \fIkit\fR
.TP
zag*
non encrypted temporary files.
.TP
zcb*
data encrypted using CBC mode.
.TP
zec*
data encrypted using ECB mode.
.TP
zzz.minikit
file holding the name of the extras files added by kit.
.TP
zzz.ack
contains the address where acknowledgment should be sent.
.TP
zzz.subject
contains the name of kit archive for acknowledgment purposes.
.TP
$privlib/minikit
the script which may be used to unkit a distribution when the kit
package is not available.
.TP
$privlib/makeshar
the script which emulates \fIcshar\fR's \fImakekit\fR program.
.TP
$privlib/rshar
a simple shell archive maker.
.TP
$privlib/secure
security checks (detection of alien code) in kit archives.
.PD
.SH ENVIRONMENT
The following environment variables are paid attention to by \fImailkit\fR. If
they are not set, a default determined at configuration time will be used:
.TP 15
EDITOR
the name of the editor to call when -E option and friends are used.
.TP
MAILER
the name of the program to invoke to send mail. This program must be
ready to take a list of addresses as argument and the whole message
(with some headers already computed) from standard input.
.SH NOTES
Kit may now be used as a standalone package, i.e. without the help of
the \fIcshar\fR distribution.
This was not true before version 2.0 PL10. Two simple shell scripts
now emulate \fIcshar\fR's behaviour. Those scripts are held in the
private library directory because they are not intended to be used
directly by any user.
.PP
In order to use kit, \fIhexdecode\fR, \fIhexencode\fR,
\fIatob\fR and \fIbtoa\fR
must be installed and \fIcompress\fR must be available.
If any of these is missing, this mailing kit is useless.
.PP
.I Unkit
has its own \fIunshar\fR built-in, but it will not be used if
\fIunshar\fR is installed, because it is really simple-minded and
not smart at all in case of errors. However, this is useful if
you do not have \fBcshar\fR, but still want to use \fIunkit\fR.
.SH EXAMPLES
To mail \fIram@educ.emse.fr\fR a directory called XLOCK and all what it may
hold, do:
.sp
.in +5
.B kit XLOCK
.br
.B mailkit XLOCK ram@educ.emse.fr
.in -5
.sp
\fIKit\fR will produce files Kit*, and mailkit will send them.
Or, to do it all in one:
.sp
.in +5
.B kit \-m ram@educ.emse.fr XLOCK
.in -5
.sp
Assuming the XLOCK package has 5 kit parts, you could send only parts 3 and 5
by using:
.sp
.in +5
.br
.B mailkit -r 3,5 XLOCK ram@eiffel.com
.in -5
.sp
If you have no write permissions in the current directory, you can
specify an alternate directory for temporary files:
.sp
.in +5
\fBkit \-m ram@eiffel.com \-d /tmp \-n mykit XLOCK\fR
.in -5
.sp
To unkit, save the mail messages in files called, e.g. xlock.01 (for
part 01), xlock.02 (for part 02) and so on.
Then do:
.sp
.in +5
.B unkit xlock*
.in -5
.sp
Even if it succeeds, files xlock* will not be removed.
.SH BUGS
Try "kit .": it is harmless (well, I hope !), and you will quickly
understand the problem. The solution is to use the \fB\-d\fR option.
.PP
If you use the
.B \-r
option in
.I unkit
and one or more kit parts are missing, all the files will be lost.
So use it with care...
.PP
Some systems cannot extract tar archives with overwriting of ownership
informations (usually this is done with tar option -o).
.PP
The
.B \-M
option is unknown to versions of
.I kit
prior to 2.0 PL9, which means the remote
.I unkit
program will not be able to clean-up the extras files. Similarly,
the automatic acknowledgment feature was added at 2.0 PL15. Fortunately,
.I kit
programs newer than 2.0 PL9 will know how to deal with the extras files,
although the acknowledgment feature itself will only be handled by 2.0 PL15 and
later versions.
.SH "SEE ALSO"
atob($manext), btoa($manext), unshar(1), makekit(1).
.SH AUTHOR
Raphael Manfredi <ram@hptnos02.grenoble.hp.com>.

\fIKit\fR was first developed at the Ecole des Mines, Saint-Etienne,
France. Many improvements were added at Interactive Software
Engineering Inc., Santa-Barbara CA, USA.
!GROK!THIS!
chmod 444 kit.$manext
