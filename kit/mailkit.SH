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
echo "Extracting kit/mailkit (with variable substitutions)"
$spitshell >mailkit <<!GROK!THIS!
$startsh
# @(#) Mailer for kit files
# @(#) (c) R. Manfredi, 1990-1993

# $Id: mailkit.SH,v 2.0.1.13 1993/04/26 11:19:31 ram Exp $
#
# $Log: mailkit.SH,v $
# Revision 2.0.1.13  1993/04/26  11:19:31  ram
# patch27: copyright dates updated
#
# Revision 2.0.1.12  93/01/11  18:06:55  ram
# patch22: now uses external getopt script for option parsing
# 
# Revision 2.0.1.11  92/11/03  10:12:40  ram
# patch21: option parsing can now deal with embeded spaces in arguments
# 
# Revision 2.0.1.10  92/11/01  15:08:10  ram
# patch20: added getopt-style option parsing
# 
# Revision 2.0.1.9  92/08/17  17:55:16  ram
# patch18: recipient file was wrongly reported as missing
# patch18: instruction message now saved in case of error
# patch18: mailkit attempts to retrieve saved instructions if any
# 
# Revision 2.0.1.8  92/05/02  14:17:01  ram
# patch16: there can now be multiple occurences of -l
# patch16: -p is now the default option unless -c is used
# patch16: kit now invokes mailkit with -c to force clean up
# patch16: mailkit asks for unsent part disposal when needed
# patch16: now pays attention to EDITOR and MAILER env vars
# patch16: new -r option to specify range of parts to be sent
# patch16: added -c option to force cleanup of parts
# 
# Revision 2.0.1.7  92/04/20  17:37:36  ram
# patch15: added the bulk Precedence and X-Mailer headers
# patch15: fixed incorrect help message regarding -l
# patch15: changed verbose messages for consistency with other scripts
# 
# Revision 2.0.1.6  92/01/13  14:14:21  ram
# patch13: fixed the option parsing code
# 
# Revision 2.0.1.5  92/01/11  19:19:15  ram
# patch11: the leading 'startsh' configuration variable was missing
# patch11: reported by Michael Fischer <fischer-michael@cs.yale.edu>
# 
# Revision 2.0.1.4  91/12/08  14:55:22  ram
# patch10: forgot to protect evaluation of variable in a test
# 
# Revision 2.0.1.3  91/11/25  12:09:23  ram
# patch8: stamping of kit parts is now done directly in kit
# patch8: added option -l to allow taking recipients from a file
# 
# Revision 2.0.1.2  91/07/30  17:26:26  ram
# patch6: config.sh now carries the symbols defined in patchlevel.h
# patch6: the subject line in mails now appears first for USG /bin/mail
# 
# Revision 2.0.1.1  91/05/27  14:28:37  ram
# patch5: added option -n
# patch5: usage is no longer printed by a function
# patch5: version number is no longer hardwired
# patch5: set -- was not supported everywhere; use set X and shift
# 
# Revision 2.0  91/02/19  15:49:57  ram
# Baseline for first official release.
# 

# Define the mailer program
mailer="$mailer"

# Define the default editor
editor=$defeditor

# Which patch-level is it ?
pl='$PATCHLEVEL'
version='$VERSION'
libdir='$privlib'
!GROK!THIS!
$spitshell >>mailkit <<'!NO!SUBS!'

# Flag used for -e/f and -E/F options
edit=no
added=no
feed=no
preserve=dflt
recipients=''

partname='Kit'			# Default part's name
range='1-'				# Default range (all parts)
unsent=''				# Parts which could not be sent
error=''				# True when error occurred

# Ensure proper MAILER and EDITOR variables. I cannot use the ${MAILER:-def}
# construct since some shells do not recognize that (/bin/sh on the DEC 3100).
case "$MAILER" in
'') MAILER="$mailer";;
esac
case "$EDITOR" in
'') EDITOR="$editor";;
esac

# Old Bourne shells do not have functions
usage='
echo "Usage: mailkit [-EFVcefhp] [-n base] [-l file] [-r range]";
echo " "" "" "" "" "" "" progname [address_list]";
echo " "" -E : edit a message that will be sent as part #0";
echo " "" -F : feed message from stdin and sent it as part #0";
echo " "" -V : print version and patch-level";
echo " "" -c : clean up after each part sent.";
echo " "" -e : edit a message that will be added to every part";
echo " "" -f : feed message from stdin to every part";
echo " "" -h : to print this help message.";
echo " "" -l : get recipients from a file (multiple occurences allowed).";
echo " "" -n : set the basename of parts to be sent (default is $partname).";
echo " "" -p : preserve files sent (default, unless -c specified).";
echo " "" -r : define parts to be sent (default is 1-).";
exit 1;
'

# Process the command line options
eval "set X "`$libdir/getopt EFVcefhpn:l:r: "$@"`; shift
while test $# -gt 0
do
	case "$1" in
	-V) echo "mailkit $version PL$pl"
		exit 0
		;;
	-E) edit=yes
		added=no
		shift
		;;
	-c) case "$preserve" in
		dflt) preserve=no;;
		esac
		shift
		;;
	-e) edit=yes
		added=yes
		shift
		;;
	-h) eval $usage
		;;
	-p) preserve=yes
		shift
		;;
	-l) recipients="$recipients $2"
		shift
		shift
		;;
	-n) partname="$2"
		shift
		shift
		;;
	-r) range="${2:-$range}"
		shift
		shift
		;;
	-f)	feed=yes
		added=yes
		shift
		;;
	-F)	feed=yes
		added=no
		shift
		;;
	--) shift
		break
		;;
	-*) echo "unknown option $1"
		eval $usage
		;;
	*) break
		;;
	esac
done

if test "x$1" = x; then
	echo >&2 "$0: missing program name"
	eval $usage
fi

# Save arguments before using set
prog_name=$1
shift
address=$@
saved_address=$@

# When a recipient file is provided, ignore the remaining of the command line
if test "$recipients"; then
	if test -r $recipients; then
		# The format of the file is simple: a list of addresses, one per
		# line. Shell-style comments are allowed and multiple addresses on a
		# single line may be separated with spaces or commas.
		set X `cat $recipients | sed -n -e '/^[^#]/ {'	\
			-e 's/#.*//'	\
			-e 's/,/ /g'	\
			-e 's/\n/ /'	\
			-e 'p'			\
			-e '}'` $saved_address
		shift
		address=$@
	else
		echo >&2 "mailkit: can't open $recipients"
		exit 1
	fi
fi

if test "x$address" = x; then
	echo >&2 "mailkit: missing recipient list"
	eval $usage
fi

# In case of editing, compute a temporary file name
message=/tmp/MKt$$
# Temporary files used for building top message
tmpmsg=/tmp/Nkt$$
topmsg=/tmp/Tkt$$

# Set a trap in case we die abruptly
trap 'rm -f $message $tmpmsg $topmsg;
test $preserve = no && rm -f $partname??;
echo "Mailing aborted."
exit 1' 1 2 3 15

# Count how many files there are
set X $partname??
shift

# Remove instructions or number of parts will be off by 1
case $1 in
"${partname}00") shift;;
esac

nfiles=$#

if test $edit = yes
then
	# If editing was asked for, prepare the help message
	cat >$message <<EOM
Please, enter your message here for the "$prog_name" kit.
Do not worry about this text, the 4 lines at the top will be removed.
EOM
	if test $added = yes
	then
		cat >>$message <<'EOM'
The message will be added at the top of each part.
EOM
	else
		cat >>$message <<'EOM'
The message will be sent as part #0 and other parts will mention that.
EOM
	fi
	cat >>$message <<'EOM'
------------------------------------------------------------------------
EOM
	# If there is a part #0, append it before calling the editor
	if test -f ${partname}00; then
		echo "mailkit: using previously kept instructions..." >&2
		sleep 2
		cat ${partname}00 >>$message
	fi

	# Call the editor
	$EDITOR $message

	# Now remove the 4 lines at the top
	# Do not use tail +5, as this may not exist on every system
	cp $message $tmpmsg
	awk '{ nl += 1 }; nl > 4 { print }' <$tmpmsg >$message
	rm -f $tmpmsg

	# If message is empty, discard it.
	if test ! -s $message
	then
		rm -f $message
		edit=no
		echo "mailkit: discarding empty message." >&2
	fi
elif test $feed = yes; then
	edit=yes			# No differences from now on
	cat > $message		# Feed from stdin
fi

# Print recipient list
echo "Mailing \"$prog_name\" ($range) to:"
echo $address | tr ' ' '\012' | sed -e 's/^/	/'

# Expand given range
range=`$libdir/range $nfiles $range`

for i in $range
do
	# Add leading zero if number < 10
	if test $i -lt 10; then
		pn="0$i"
	else
		pn=$i
	fi

	# Compute file name
	part=$partname$pn

	# Protect against unexisting/unreadable files
	if  test -f $part -a -r $part
	then
		echo "Mailing $part..."
		# System V /bin/mail does not recognize header correctly, unless the
		# first line is a subject. Oh well...
		cat > $topmsg <<EOH
Subject: $prog_name - kit #$i / $nfiles
To: $address
Precedence: bulk
X-Mailer: mailkit [version $version PL$pl]

EOH
		# Has edit been requested ?
		if test $edit = yes
		then
			if test $added = yes
			then
				# Add message to each part
				cat $message >> $topmsg
				# add a blank line
				echo " " >> $topmsg
			else
				# Signals that there is a part #0
				cat >> $topmsg <<EOM
[ There is an instruction mail which is labeled: $prog_name - kit #0 / $nfiles ]

EOM
			fi
		fi
		cat $part >> $topmsg
		# Remove part sucessfully sent unless '-p' was used
		if $MAILER $address < $topmsg; then
			test "$preserve" = no && rm -f $part
		else
			echo "mailkit: could not send $part." >&2
			error='true'
			if test "$preserve" = no; then
				unsent="$unsent $part"
			fi
		fi
		rm -f $topmsg
	else
		echo "mailkit: could not open $part" >&2
		error='true'
	fi
done

# Is there a part #0 to send ?
if test $edit = yes -a $added = no
then
	cat > $topmsg <<EOM
Subject: $prog_name - kit #0 / $nfiles
To: $address
Precedence: bulk
X-Mailer: mailkit [version $version PL$pl]

[ This is an instruction message for the $prog_name kit ]

EOM
	cat >>$topmsg <$message
	echo "Mailing instructions..."
	if $MAILER $address < $topmsg; then
		rm -f $topmsg
	else
		echo "mailkit: could not send instructions." >&2
		error='true'
		rm -f $topmsg
	fi
fi

# Save instructions as part #0 in case of error
if test "$error" -a -f $message; then
	cp $message ${partname}00 &&
	echo "mailkit: instruction message saved as ${partname}00." >&2
	if test $preserve = no; then
		unsent="$unsent ${partname}00"
	fi
fi

# When there are some parts which could not be sent and the command is run from
# a terminal, ask the user what should be done with those unsent files.
# Otherwise simply remove them.
if test "$unsent"; then
	if test -t 0 -a -t 1; then
		echo "mailkit: would you like to remove the following unsent parts?"
		echo "mailkit: (keeping them would allow you to try again later.)"
		rm -i $unsent
	else
		echo "mailkit: removing unsent parts." >&2
		rm -f $unsent
	fi
else
	if test -f ${partname}00 -a ! "$error"; then
		echo "mailkit: removing instructions held in ${partname}00." >&2
		rm -f ${partname}00
	fi
fi

rm -f $message
!NO!SUBS!
chmod 755 mailkit
$eunicefix mailkit
