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
echo "Extracting shar/rshar (with variable substitutions)"
$spitshell >rshar <<!GROK!THIS!
$startsh
# (c) Raphael Manfredi, December 25th 1991

# $Id: rshar.SH,v 2.0.1.4 1992/04/20 17:43:22 ram Exp $
#
# $Log: rshar.SH,v $
# Revision 2.0.1.4  1992/04/20  17:43:22  ram
# patch15: determination of user and host no longer uses a sub-shell
#
# Revision 2.0.1.3  92/03/24  13:46:04  ram
# patch14: determination of user name made more portable
# patch14: a missing quote led to a syntactically incorrect archive
# 
# Revision 2.0.1.2  92/01/13  14:26:20  ram
# patch13: fixed option parsing code
# patch13: the archive extraction now returns meaningful exit code
# patch13: from Jaap Vermeulen <jaap@sequent.com>
# patch13: there is now a space between file size and "characters"
# 
# Revision 2.0.1.1  92/01/11  19:23:24  ram
# patch11: created
# 

!GROK!THIS!
$spitshell >>rshar <<'!NO!SUBS!'
# This is a stripped down implementation of Rich Salz's cshar. Among the
# list of features missing, no directories are ever created: rshar assumes
# the list of files to be shar'ed are listed in a single directory, which
# is the case with kit.
# It is not intended to be used directly. Rather, it is called by makeshar
# via kit when cshar is missing.

# Default values
max=1
number=1

# Option parsing
while test $# -gt 0
do
	case "$1" in
	-k) shift
		max=$1
		shift
		;;
	-n) shift
		number=$1
		shift
		;;
	--) shift
		break
		;;
	-*) echo "unkown option $1"
		exit 1
		;;
	*) break
		;;
	esac
done

# Who and where am I?
user=`(logname) 2>/dev/null || whoami`
host=`(uname -n) 2>/dev/null || hostname`

echo '#! /bin/sh
# This is a shell archive.  Remove anything before this line, then feed it
# into a shell via "sh file" or similar.  To overwrite existing files,
# type "sh file -c"
#
# Wrapped by <'$user@$host'> on '`date`
echo '#
# This archive contains:'
echo $@ | tr ' ' '\012' | sed -e 's/^/#    /'

# Tell the user what it is all about
echo "echo \"If this archive is complete, you will see the following message:\""
if test $max -eq 1; then
	echo "echo '          \"shar: End of archive.\"'"
else
	echo "echo '          \"shar: End of archive $number (of $max).\"'"
fi
echo "exitcode=0"

for i in $*
do
	# Do not extract file if one with the same name already exists
	echo "if test -f '$i' -a \"\${1}\" != \"-c\"; then"
	echo "	echo \"shar: Will not clobber existing file '$i'\""
	echo "	exitcode=1"
	echo "else"
	set x `wc -c < $i`
	size=$2
	echo "	echo \"shar: Extracting '$i' ($size characters)\""
	# Insert X at the front, in case END_OF_FILE appears in the file
	echo "	sed 's/^X//' > $i << 'END_OF_FILE'"
	sed 's/^/X/' $i
	echo "END_OF_FILE"
	# restore executables
	if test -x $i; then
		echo "	chmod +x $i"
	fi
	# verify length
	echo "	if test $size -ne \`wc -c < '$i'\`; then"
	echo "		echo \"shar: '$i' unpacked with wrong size!\""
	echo "		exitcode=1"
	echo "	fi"
	echo "	# end of '$i'"
	echo "fi"
done

# End of shell archive
if test $max -eq 1; then
	echo "echo \"End of archive.\""
else
	echo "echo \"End of archive $number (of $max).\""
	echo "cp /dev/null ark${number}isdone"
	echo "missing=''"
	vector=`awk "BEGIN {for (i=1;i<=$max;i++) printf(\"%d \",i);}" /dev/null`
	echo "for i in $vector; do"
	echo "	if test ! -f ark\${i}isdone; then"
	echo "		missing=\"\$missing \$i\""
	echo "	fi"
	echo "done"
	echo "if test \"\$missing\" = \"\"; then"
	if test $max -eq 2; then
		echo "	echo \"You have unpacked both archives\""
	else
		echo "	echo \"You have unpacked all $max archives\""
	fi
	echo "	rm -f ark*isdone"
	echo "else"
	echo "	echo \"You still must unpack the following archives:\""
	echo "	echo \"        \" \$missing"
	echo "fi"
fi

# Someone might mail this :-) so skip signature
echo "exit \$exitcode"
!NO!SUBS!
chmod 755 rshar
$eunicefix rshar
