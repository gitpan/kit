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
echo "Extracting kit/kit (with variable substitutions)"
$spitshell >kit <<!GROK!THIS!
$startsh
# @(#) converts to ascii && packages a whole directory
# @(#) (c) E. Mogenet April, 1990
# @(#) (c) R. Manfredi, 1990-1993

# Which patch-level is it ?
pl='$PATCHLEVEL'
version='$VERSION'
libdir='$privlibexp'
!GROK!THIS!
$spitshell >>kit <<'!NO!SUBS!'

# $Id: kit.SH,v 2.0.1.16 1998/03/30 14:22:46 ram Exp $
#
# $Log: kit.SH,v $
# Revision 2.0.1.16  1998/03/30 14:22:46  ram
# patch35: added support for alternate compression schemes through -C
#
# Revision 2.0.1.15  1995/10/12  11:13:50  ram
# patch32: force removal of read-only (copied from lib) temporary files
#
# Revision 2.0.1.14  1993/04/26  11:19:14  ram
# patch27: do not use cshar's makekit any more but use our own archiver
#
# Revision 2.0.1.13  93/01/11  18:06:46  ram
# patch22: now uses external getopt script for option parsing
# 
# Revision 2.0.1.12  92/11/03  10:12:34  ram
# patch21: option parsing can now deal with embeded spaces in arguments
# 
# Revision 2.0.1.11  92/11/01  15:08:04  ram
# patch20: added getopt-style option parsing
# 
# Revision 2.0.1.10  92/05/02  14:13:45  ram
# patch16: new option -S to set maximum part size
# 
# Revision 2.0.1.9  92/04/20  17:35:03  ram
# patch15: added support for -a option
# patch15: stamping now includes user and host infos
# patch15: error checking improved
# patch15: kit will no longer remove existing kit parts
# 
# Revision 2.0.1.8  92/01/13  14:13:59  ram
# patch13: fixed the option parsing code
# 
# Revision 2.0.1.7  92/01/11  19:17:20  ram
# patch11: now uses makeshar when cshar is not installed
# 
# Revision 2.0.1.6  91/12/08  14:55:06  ram
# patch10: forgot to protect evaluation of variable in a test
# 
# Revision 2.0.1.5  91/11/25  15:50:59  ram
# patch9: added option -M which asks for minikit inclusion
# patch9: the subject given to mailkit was wrong unless -s was used
# 
# Revision 2.0.1.4  91/11/25  12:08:20  ram
# patch8: stamping of kit parts is now done by kit instead of mailkit
# patch8: new option -l to give recipient file list
# patch8: removed comments describing usage and done some clean-up
# 
# Revision 2.0.1.3  91/07/30  17:24:20  ram
# patch6: config.sh now carries the symbols defined in patchlevel.h
# 
# Revision 2.0.1.2  91/05/27  14:25:21  ram
# patch5: added options -d and -n
# patch5: usage is no longer printed by a function
# patch5: redirection with piping in eval may yield i/o error
# patch5: version number is no longer hardwired
# 
# Revision 2.0.1.1  91/04/01  15:48:26  ram
# patch1: new options -x, -k and -X for encryption facilities
# patch1: naming convention for files has been revised
# patch1: kit now traps interrupts for a graceful exit
# 
# Revision 2.0  91/02/19  15:49:53  ram
# Baseline for first official release.
# 

coding=btoa					# Program used for coding
mode="zag"					# Mode is the 'A' part of the name
code="ba"					# Code is the 'B' part of the name
mailkit=mailkit				# Mailing program to use with kit
maxsize=50000				# Default maximum part size in bytes
maxvalue=$maxsize			# Actual requested size
invoke=no					# Do we have to invoke mailkit ?
tmpfile=/tmp/Kds$$			# Temporary file
tmpdir="."					# Temporary directory used
partname="Kit"				# Default part name used
minikit=''					# Do not include minikit
others=''					# Other files to be included
instruct=''					# Added instrucutions (minikit / acknowledgment)
ack=''						# Acknowledgment file
ackto=''					# Acknowledgment address
ctag='default'				# Compression tag
address=''					# Address list for mailkit

# Mailkit options
mailopt=""
subject=""

# DES options
key=""
desopt=""

# Old Bourne shells do not have functions
usage='
echo "Usage: kit [-BEFHMVXefhpx] [-S size] [-a address] [-d dir] [-k key] [-l file]";
echo " "" "" "" "" "" "" [-m address] [-n basename] [-C compress-tag] [-s name] dirs | files";
echo " "" -B : use btoa encoding (default).";
echo " "" -C : select alternative compression scheme.";
echo " "" -E : edit instructions for part #0 (passed to mailkit).";
echo " "" -F : feed instructions from stdin to part #0 (passed to mailkit).";
echo " "" -H : use hex-encoding.";
echo " "" -M : include minikit in the distribution.";
echo " "" -V : print version and patch-level.";
echo " "" -S : set each part size in bytes or kbytes (default $maxsize bytes).";
echo " "" -X : use Electronic Code Block DES encryption.";
echo " "" -a : acknowledgment requested upon archive extraction.";
echo " "" -d : put temporary files in the specified directory.";
echo " "" -e : edit instructions to add in each part (passed to mailkit).";
echo " "" -f : feed instructions from stdin in each part (passed to mailkit).";
echo " "" -h : to print this help message.";
echo " "" -k : sets the key used for data encryption.";
echo " "" -m : invoke mailkit to mail the parts (multiple occurrences combine).";
echo " "" -l : file holding the recipient list (passed to mailkit).";
echo " "" -n : set the basename of the generated parts (default is $partname).";
echo " "" -p : preserve files sent (given to mailkit).";
echo " "" -s : set kit name (given to mailkit).";
echo " "" -x : use Cipher Block Chaining DES encryption (default).";
exit 1
'

# Process the command line options
eval "set X "`$libdir/getopt BC:EFHMVXefhpxS:a:d:k:l:m:n:s: "$@"`; shift
while test $# -gt 0
do
	case "$1" in 
	-M) shift
		if test -f minikit; then
			if test -f MINIKIT; then
				minikit="mkit$$"
			else
				minikit='MINIKIT'
			fi
		else
			minikit='minikit'
		fi
		;;
	-H) shift
		coding=hexencode
		code="hex"
		;;
	-B) shift
		coding=btoa
		code="ba"
		;;
	-C) ctag="$2"
		shift
		shift
		;;
	-E|-e|-F|-f|-p) mailopt="$mailopt $1"
		shift
		;;
	-S) maxvalue="$2"
		shift
		shift
		;;
	-X) desopt="-b"
		mode="zec"
		shift
		;;
	-a) ackto="$2"
		ack='zzz.ack'
		shift
		shift
		;;
	-d) tmpdir="$2"
		shift
		shift
		;;
	-x) desopt=""
		mode="zcb"
		shift
		;;
	-k) key=" -k $2"
		case "$mode" in
		zag) mode="zcb";;
		esac
		shift
		shift
		;;
	-m) address="$address $2"
		invoke=yes
		shift
		shift
		;;
	-l) mailopt="$mailopt -l $2"
		invoke=yes
		shift
		shift
		;;
	-n) partname="$2"
		shift
		shift
		;;
	-s) subject="$2"
		shift
		shift
		;;
	-V) echo "kit $version PL$pl"
		exit 0
		;;
	-h) eval $usage
		;;
	--) shift
		break
		;;
	-*) echo "unkown option $1"
		eval $usage
		;;
	*) break
		;;
	esac
done

# At this stage, $1 should hold the name of a file or a directory
if test "x$1" = x
then
	eval $usage
fi

# When using minikit, the default compression scheme must be used.
if test "x$minikit" != x; then
	if test "x$ctag" != xdefault; then
		echo >&2 "kit: cannot select \"$ctag\" compression with minikit."
		exit 1
	fi
fi

# Check the writing permissions in the tmp directory. Also ifsome Kit parts are
# detected, complain and abort.
if test -w "$tmpdir" -a -d "$tmpdir"; then
	if test -f $tmpdir/${partname}01; then
echo >&2 "kit: directory '$tmpdir' already holds a file named '${partname}01'."
		exit 1
	fi
else
	if test -d "$tmpdir"; then
		echo >&2 "kit: you lack write permissions in the '$tmpdir' directory."
	else
		echo >&2 "kit: '$tmpdir' is not a directory."
	fi
	exit 1
fi

# Make sure no parts already exist. Due to the above check, existing parts will
# be removed only if they are named with extensions from 02 to 99.
rm -f $tmpdir/$partname??

# If DES is to be performed, do it before ASCII coding
case "$mode" in
zag);;
*) desopt="$desopt -e"$key
	coding="des $desopt | "$coding;;
esac

# Compute proper compressing command
compress=`$libdir/getproc "$ctag" compress`
case "$compress" in
'')
	echo "kit: unknown \"$ctag\" compressing tag, please use one of:" >&2
	$libdir/getproc | sed -e 's/^/kit: /' >&2
	exit 1
	;;
esac
uncompress=`$libdir/getproc "$ctag" uncompress`

# Subject is user-provided or the first file name is used
case "$subject" in
'') subject=$1
esac

# Compute maximum kit size (can be given in bytes or in kbytes)
maxvalue=`echo "$maxvalue" | sed -e 's/^\(.*\)[kK]/\1 \\\\* 1024/'`
maxvalue=`eval expr $maxvalue 2>/dev/null`
maxsize=${maxvalue:-$maxsize}

# The number of lines to be kept in each splited file is computed based on the
# average of 80 characters per line, and 2500 bytes are removed from the actual
# size for header overhead.
split=`expr $maxsize - 2500`
split=`expr $split / 80`
split=${split:-600}

# We have two encoding methods for binary datas:
# - hexencode: brute force (mogenix)
# - btoa: binary to ascii (ram)
#
# As we want to make kit-unkit encoding-independant, the following
# naming convention occurs for files split: names are A.B.* where:
#
#   - A is zag for uncrypted files
#   - A is zcb for DES encrypted files with CBC mode
#   - A is zec for DES encrypted files with ECB mode
# 
#   - B is hex for hex-encoded file
#   - B is ba for ASCII-encoded files

split_file=$mode.$code.		# Name used for spliting

# In case we are interrupted
trap "rm -f $tmpfile; cd $tmpdir; rm -f $partname?? ${split_file}* \
	$others $minikit $partname??.$$; echo >&2 'Aborted.'; exit 1" 1 2 3 15

rm -f zzz.minikit

# Create the zzz.zcat file if they selected an alternate compression
case "$ctag" in
default) ;;
*)
	others="$others zzz.zcat zzz.minikit"
	echo "$uncompress" >zzz.zcat
	echo "zzz.zcat" >>zzz.minikit
	;;
esac

# We have to use a tmp file to avoid des prompting while tar is running
tar cvf - $@ | $compress > $tmpfile
case $? in
0) break;;
*) echo >&2 "kit: archiving failed."
	rm -f $tmpfile $others
	exit 1
	;;
esac

cd $tmpdir

# If minikit is to be used, copy the script from the library directory
if test "$minikit"; then
	if test -r "$libdir/minikit"; then
		cp $libdir/minikit $minikit
		chmod +x $minikit
		# Name of the minikit program is passed along to unkit, so that the
		# script may be removed when unkit is ran...
		echo "$minikit" >> zzz.minikit
		others="$others $minikit"
		# Add zzz.minikit unless already there
		case "$others" in
		*zzz.minikit*);;
		*) others="$others zzz.minikit";;
		esac
		# Prepare instructions for later
		instruct=">>
>> In case you do not have unkit, you may proceeed as follows:
>> - First run all the parts through unshar or sh. This will extract
>>   some temporary files, and among them a script called '$minikit'.
>> - Run the '$minikit' program, and the kit will be extracted for you.
>>   If the extraction is successful, all the temporary files previously
>>   extracted will be removed, including $minikit.
"
	else
		echo >&2 "$0: cannot find minikit in $libdir"
		kill -15 $$
	fi
fi

# If acknowledgment is wanted, write address in zzz.ack and add this file to
# zzz.minikit to ensure its final removal by unkit.
if test "$ack"; then
	echo "$ackto" >> zzz.ack
	echo "$subject" >> zzz.subject
	echo "zzz.ack" >> zzz.minikit
	echo "zzz.subject" >> zzz.minikit
	others="$others zzz.subject zzz.ack"
	# Add zzz.minikit unless already there
	case "$others" in
	*zzz.minikit*);;
	*) others="$others zzz.minikit";;
	esac
	instruct="$instruct>>
>> An acknowledgment will be automatically sent by unkit upon successful
>> extraction to the following address: $ackto.
"
fi

# Kit used to use cshar's makekit program when available but due to a
# really strange bug when packing some files (leading to a blank archive #1),
# kit's own archiving program is now always used.
makekit="$libdir/makeshar -s $maxsize -n $partname ${split_file}* $others"

echo "Coding with $coding"
# Beware: 'eval $coding < $tmpfile' is not portable
status=1
cat $tmpfile | eval $coding |
split -$split - $split_file &&
eval $makekit && status=0
rm -f ${split_file}* $others $tmpfile
case "$status" in
0);;
*) echo >&2 "kit: sharing failed."
	rm -f $tmpdir/$partname??
	exit 1
	;;
esac

# Stamp the files, stating they are kit files and not shell archives
set X $partname??
shift
nfiles=$#
user=`(logname) 2>/dev/null || whoami`
host=`(uname -n) 2>/dev/null || hostname`
for file in $partname??
do
	# Extract part number
	part=`expr $file : '[^0-9]*\(.*\)'`
	# Remove leading zero(s)
	part_num=`expr $part + 0`
	# Write kit header stamp message
	echo "Stamping kit $part_num..."
	genstamp=">> Wrapped by $user@$host on `date` [kit $version PL$pl]"
	if test $nfiles -gt 1; then
		cat >$file.$$ <<EOH
>> This is a kit file (part #$part_num out of $nfiles). To unkit, save this message
>> into a file, e.g. foo$part, and wait until you have the $nfiles files.
>> Then, do "unkit foo*". To see what will be extracted, you may wish to
>> do "unkit -l foo*" before.
>>
$genstamp
$instruct
EOH
	else
		cat >$file.$$ <<EOH
>> This is a kit file. To unkit, save this message into a file, e.g. foo.
>> Then, do "unkit foo". To see what will be extracted, you may wish to
>> do "unkit -l foo" before.
>>
$genstamp
$instruct
EOH
	fi
	cat $file >>$file.$$
	mv $file.$$ $file
done

# If -m option used, invoke mailkit
if test $invoke = yes; then
	$mailkit -n $partname -c $mailopt "$subject" $address
fi
!NO!SUBS!
chmod 755 kit
$eunicefix kit
