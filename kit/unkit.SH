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
echo "Extracting kit/unkit (with variable substitutions)"
$spitshell >unkit <<!GROK!THIS!
$startsh
# @(#) unkit, reversal of kit
# @(#) (c) E. Mogenet April 1990
# @(#) (c) R. Manfredi, 1990-1993

# $Id: unkit.SH,v 2.0.1.18 1995/10/12 11:14:55 ram Exp $
#
# $Log: unkit.SH,v $
# Revision 2.0.1.18  1995/10/12  11:14:55  ram
# patch32: new -R option to remove leading / in pathnames
#
# Revision 2.0.1.17  1993/04/26  11:21:29  ram
# patch27: updated copyright dates
#
# Revision 2.0.1.16  93/02/08  18:13:58  ram
# patch24: new option -d to specify directory where kits are
# patch24: added security checks (options -s and -S) on shell archives
# patch24: avoid sending an acknowledgment when -l option used
# patch24: (reported by Christian Bertin <bertin@acri.fr>)
# 
# Revision 2.0.1.15  93/01/11  18:07:29  ram
# patch22: now uses external getopt script for option parsing
# patch22: fixed some typos in the help message
# 
# Revision 2.0.1.14  92/11/03  10:12:44  ram
# patch21: option parsing can now deal with embeded spaces in arguments
# 
# Revision 2.0.1.13  92/11/01  15:08:15  ram
# patch20: added getopt-style option parsing
# 
# Revision 2.0.1.12  92/09/04  19:28:28  ram
# patch19: unkit will use perl instead of awk, if available
# patch19: now smart enough to deal with multiple parts from stdin
# patch19: now recognizes - as being stdin
# 
# Revision 2.0.1.11  92/08/17  17:59:42  ram
# patch18: new -k option, added by Steve Tynor <fugue!tynor@gatech.edu>
# patch18: do not start unkiting until all parts are here (Jaap Vermulen)
# patch18: unkit can now deal with files holding multiple kit parts
# patch18: now return a meaningful exit status
# 
# Revision 2.0.1.10  92/04/20  17:39:08  ram
# patch15: added support for acknowledgment
# 
# Revision 2.0.1.9  92/01/13  14:20:37  ram
# patch13: fixed the option parsing code
# patch13: unkit may be used to actually do an unshar
# patch13: from Jaap Vermeulen <jaap@sequent.com>
# 
# Revision 2.0.1.8  92/01/11  19:20:05  ram
# patch11: now knows about badtar
# patch11: added -b option to force use of badtar
# 
# Revision 2.0.1.7  91/12/08  14:56:49  ram
# patch10: added space in the credit for Emmanuel Mogenet
# 
# Revision 2.0.1.6  91/11/25  15:52:14  ram
# patch9: added a trap to clean-up things in case of interruption
# patch9: now knows about minikit and zzz.minikit file
# 
# Revision 2.0.1.5  91/11/25  12:09:54  ram
# patch8: random clean-up for consistency with other scripts
# 
# Revision 2.0.1.4  91/07/30  17:31:49  ram
# patch6: config.sh now carries the symbols defined in patchlevel.h
# patch6: not all the tar support -o option for ownership overwrite
# patch6: the -v option for zcat did not make much sense
# patch6: (last two reported by Richard Bielak <richieb@bony.com>)
# 
# Revision 2.0.1.3  91/05/27  14:29:22  ram
# patch5: usage is no longer printed by a function
# patch5: version number is no longer hardwired
# 
# Revision 2.0.1.2  91/04/30  13:34:11  ram
# patch3: unkit now carries a built-in unshar
# 
# Revision 2.0.1.1  91/04/01  15:51:53  ram
# patch1: unkit updated to deal with new naming conventions
# patch1: for some reason, log messages from 1.0 had been kept
# 
# Revision 2.0  91/02/19  15:50:03  ram
# Baseline for first official release.
# 

# Which patch-level is it ?
pl='$PATCHLEVEL'
version='$VERSION'
libdir='$privlib'

# Tar options to be used
badtar='$needbtar'

# Mailer to be used for acknowledgments
mailer="$mailer"
!GROK!THIS!

case "$d_portable" in
define) cat >> unkit <<EOP
if tar -cf - /dev/null 2>/dev/null | tar -xof - >/dev/null 2>&1; then
	tar_opt='xvof'
else
	tar_opt='xvf'
fi
EOP
	;;
*) case "$d_taropt_o" in
	"$define") opt='xvof';;
	*) opt='xvf';;
	esac
	echo "tar_opt='$opt'" >> unkit
	;;
esac

$spitshell >>unkit <<'!NO!SUBS!'

decoding=hexdecode			# Default decoding program
preserve=yes				# Preserve input files by default
secure=yes					# Security checks by default
extra_secure=no				# Don't be too strict
ack=yes						# Acknowledgment sent if present
directory=''				# Cd there before starting extraction
usebtar=''					# Do not use badtar
pstrip=''					# Option for badtar to strip leading / in paths
key=''						# Key for DES decoding

# In case we are interrupted, remove all the temporary files
trap 'test -f zzz.minikit && rm -f `cat zzz.minikit` zzz.minikit; \
	rm -f z??.[hbtx][eamt]*;  echo >&2 "Aborted."; exit 1' 1 2 3 15

# Old Bourne shells do not have functions
usage='
echo "Usage: unkit [-bhlprRsSV] [-d dir] [-k key] [file1 ... filen]";
echo " "" -b : force use of badtar ($badtar by default).";
echo " "" -d : cd to specified directory before starting extraction.";
echo " "" -h : give this help message.";
echo " "" -k : set the key used for data decryption.";
echo " "" -l : list files held in the kit parts.";
echo " "" -p : preserve input files (default).";
echo " "" -r : remove input files if unshar succeeds.";
echo " "" -R : remove leading / if absolute pathnames were used.";
echo " "" -s : skip security checks on shell-archives.";
echo " "" -S : extra secure; abort if security checks cannot be made.";
echo " "" -V : print current version and patch-level.";
exit 1
'

# Process the command line options
eval "set X "`$libdir/getopt bhlprRsSVd:k: "$@"`; shift
while test $# -gt 0
do
	case "$1" in
	-p) preserve=yes
		shift;;
	-r) if test $tar_opt = xvof
		then
			preserve=no
		fi
		shift;;
	-R) pstrip='-r'
		usebadtar='true'
		shift;;
	-V) echo "unkit $version PL$pl"
		exit 0;;
	-h) eval $usage;;
	-l) tar_opt=tvf
		preserve=yes
		ack=no
		shift;;
	-b) usebtar='true'
		shift;;
	-k) key="-k $2"
		shift
		shift;;
	-s) secure=no
		shift;;
	-S) extra_secure=yes
		shift;;
	-d) directory="$2"
		shift
		shift;;
	--) shift
		break
		;;
	-*) echo "unknown option $1"
		eval $usage;;
	*) break;;
	esac
done

# Test for unshar -- we have our own built-in unshar, but the
# unshar that comes with cshar is smarter in case of errors and
# much more reliable.

# Use a sub-shell to avoid messages like "sh: unshar not found".
# The "$a" variable is the parameter set by 'eval' (or empty if none).
if (unshar -n /dev/null) >/dev/null 2>&1
then
	unshar_cmd='unshar -n $a'
else
	# Our built-in unshar may not give a meaningful exit status
	unshar_cmd='sed -n -e "/^#![ 	]*\/bin\/sh/,\$p" $a | /bin/sh'
fi

# If no file name is given, process the standard input
if test $# -eq 0
then
	set X -
	shift
fi

# More than one kit part can be held in the files given as argument.
# Loop over each of the supplied arguments and extract parts based on
# the leading #!/bin/sh put by the shell archiver.

list=''
count=0

# Go to specified directory before starting, if necessary
case "$directory" in
'') ;;
*)
	if cd $directory; then
		: ok
	else
		echo "unkit: cannot cd to $directory." >&2
		exit 1
	fi
	;;
esac

for file in $*; do
	# Use perl if possible, as it does not have this stupid awk limitation
	# about the maximum number of opened files. However, I want this to
	# run (barely) even if perl is not available.
	if (perl -v) >/dev/null 2>&1; then
		num=`perl -e '
		$a = 0;
		open(FILE, ">>zag.tmp");
		while (<>) {
			if (m|^#!\s*/bin/sh|) {
				$a++;
				open(FILE, ">zag.tmp.$a");
			}
			print FILE;
		}
		print "$a\n";
		' $file`
	else
		num=`awk '
		BEGIN { a = 0; file = "zag.tmp" }
		/^#![ 	]*\/bin\/sh/ {
			a++;
			file = sprintf("zag.tmp.%d", a);
			print > file;
			next;
		}
		{ print >> file }
		END { printf("%d\n", a) }
		' $file`
	fi
	name=''
	case "$num" in
	0)
		case "$file" in
		-) file='stdin';;
		esac
		echo "unkit: warning: no kit part in $file (skipped)." >&2
		rm -f zag.tmp
		;;
	1)
		case "$file" in
		-)
			echo "unkit: one kit part found in stdin."
			name=zag.tmp.1
			;;
		*)
			rm -f zag.tmp.1
			echo "unkit: one kit part found in $file."
			name=$file
			;;
		esac
		;;
	*)
		case "$file" in
		-) file='stdin';;
		esac
		echo "unkit: $num kit parts found in $file." >&2

		# Each part is renamed into a zag.xtr.* file to free the name
		# space for the next file (each awk extracts into zag.tmp.*).
		for part in zag.tmp.*; do
			count=`expr $count + 1`
			new="zag.xtr.$count"
			mv $part $new
			name="$name $new"
		done
		;;
	esac
	list="$list $name"
done
set X $list
shift
case $# in
1) ;;
*)
	case "$count" in
	0)
		echo "unkit: found a total of $# kit parts." >&2;;
	*)
		echo "unkit: found $# kit parts ($count parts extracted)." >&2;;
	esac
	;;
esac

# Security checks need perl, unfortunately.
if (perl -v) >/dev/null 2>&1; then
	: nothing
else
	secure=no
	case "$extra_secure" in
	yes)
		echo "unkit: cannot perform security checks (perl not found)." >&2
		rm -f zag.[tx][mt]*
		exit 1
		;;
	esac
fi

# Loop over each identified kit part and unshar it
unsecure=''
for i
do
	# Ensure archive does not contain any alien code.
	run_unshar=yes
	case "$secure" in
	yes)
		if perl $libdir/secure $i; then
			: ok
		else
			echo "unkit: skipping unsecure shell archive $i (for now)." >&2
			unsecure="$unsecure $i"
			run_unshar=no
		fi
		;;
	esac

	# The command expects "$a" to be the parameter.
	case "$run_unshar" in
	yes)
		eval "a=$i; $unshar_cmd"	&&
		(test $preserve = no && rm $i)
		;;
	esac
done

# Clean up extracted parts (save disk space before tar extraction)
rm -f zag.[tx][mt]*

# Should unsecure parts have been found, signal it again and abort
case "$unsecure" in
'') ;;
*)
	echo "unkit: the following parts are unsecure:" >&2
	set X $unsecure
	shift
	echo $* | tr ' ' '\012' | sed -e 's/^/    /' >&2
	echo "unkit: aborting." >&2
	exit 1
	;;
esac

# Now check for file names to find how to decode
if test -f z[ace][gbc].ba.aa -a ! -f ark*isdone
then
	decoding=atob
else
	# Unkit was used whilst unshar was intended
	exit 0
fi
if test -f zcb.*.aa
then
	decoding=$decoding" | des -d $key"
elif test -f zec.*.aa
then
	decoding=$decoding" | des -d -b $key"
fi

# Maybe we need badtar...
case "$badtar" in
true) tarcmd="badtar -s -o $pstrip -f - | tar $tar_opt -";;
*) if test "$usebtar"; then
		tarcmd="badtar -s -o $pstrip -f - | tar $tar_opt -"
	else
		tarcmd="tar $tar_opt -"
	fi
	;;
esac

echo "Decoding with $decoding | zcat | $tarcmd"

status=1
cat `ls z??.[hb][ea]*.??` |
eval $decoding		|
zcat				|
eval "$tarcmd" && status=0

# Send acknowledgment only when unpacking was successful.
if test $ack = 'yes' -a -f zzz.ack -a $status -eq 0; then
	sender=`cat zzz.ack`
	subject=`cat zzz.subject`
	echo "Sending acknowledgment to $sender..."
	user=`(logname) 2>/dev/null || whoami`
	host=`(uname -n) 2>/dev/null || hostname 2>/dev/null`
	date=`date`
	$mailer $sender <<EOM
Subject: Kit received [$subject]
To: $sender
Precedence: junk
X-Mailer: unkit [version $version PL$pl]

Your kit archive labeled '$subject' has been
unpacked by $user@$host on $date.
EOM
	echo "Done."
fi

test -f zzz.minikit && rm -f `cat zzz.minikit` zzz.minikit
rm -f z??.[hb][ea]*.??

# Emit error message if extraction was not successful
case "$status" in
0) ;;
*)
	echo "unkit: restoring failed." >&2
	;;
esac

# Give a meaningful exit status
exit $status
!NO!SUBS!
chmod 755 unkit
$eunicefix unkit
