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
echo "Extracting shar/makeshar (with variable substitutions)"
$spitshell >makeshar <<!GROK!THIS!
$startsh
# (c) Raphael Manfredi, December 25th 1991

# $Id: makeshar.SH,v 2.0.1.6 2000/10/19 18:17:14 ram Exp $
#
# $Log: makeshar.SH,v $
# Revision 2.0.1.6  2000/10/19 18:17:14  ram
# patch38: added fix for broken bash
# patch38: added trap statement to cleanup
#
# Revision 2.0.1.5  93/01/11  18:08:54  ram
# patch22: sorting done numerically with -n option
# 
# Revision 2.0.1.4  92/05/02  14:19:45  ram
# patch16: maximum part size can now be specified via -s
# 
# Revision 2.0.1.3  92/03/24  13:37:34  ram
# patch14: fixed a typo
# 
# Revision 2.0.1.2  92/01/13  14:22:25  ram
# patch13: fixed option parsing code
# patch13: protected arguments given to rshar
# 
# Revision 2.0.1.1  92/01/11  19:23:16  ram
# patch11: created
# 

# Where rshar is located
libdir='$privlibexp'

!GROK!THIS!
$spitshell >>makeshar <<'!NO!SUBS!'
# This is a stripped down implementation of Rich Salz's makekit. The name is
# a little pun on words: In his cshar packagem Rich called its wrapper makekit
# so it seemed logical to call the kit's wrapper makeshar.
# It is not intended to be used directly. Rather, it is called by kit when
# cshar is missing.

# Default settings
partname=Part
maxsize=50000
value=$maxsize

# Option parsing
while test $# -gt 0
do
	case "$1" in
	-n) shift
		partname="$1"
		shift
		;;
	-s) shift
		maxsize="$1"
		shift
		;;
	-*) echo "unknown option $1"
		exit 1
		;;
	--) shift
		break
		;;
	*) break
		;;
	esac
done

trap 'rm -f zzz.list; exit 1' 1 2 3 15

(
	for i
	do
		# Ignore directories and other symbolic links
		if test -f $i; then
			echo "`wc -c < $i` $i"
		fi
	done
) | sort -n -r | awk '
# Awk is fed with a list of sizes and filenames, sorted in reverse order,
# i.e. the biggest files come first. Its output is a list of files to be
# put in the archives, each line counting for one part. The first line is
# the number of archives to be used.
BEGIN {
	maxsize = '$maxsize';	# Maximum shar size
	kitover = 1700;			# Kit overhead
	file = 130;				# File overhead
	max = 1;				# Maximum part number

	# We mimic makekit as much as possible to avoid any surprise for user
	print "   File Name            Archive #       Description";
	print "----------------------------------------------------------";
}
{
	# Fill in parts, starting with bigger files and finishing with smaller
	# ones. Note that we use an heuristic to compute the overhead of each
	# files in the archive. The kit overhead is an estimate. The file overhead
	# accounts for the listing in the archive contents as well as tests used
	# to check for overwriting.
	i = 1;
	while ( \
		(newtot = tot[i] + $1 + ($1 / 40) + file) > (maxsize - kitover) \
		&& tot[i] > 0 \
	)
		i++;
	# Uncomment the following line to add debug
	# printf("Adding %s to part %d giving %d bytes\n", $2, i, newtot);
	tot[i] = newtot;
	list[i] = sprintf("%s %s", list[i], $2);
	# Update maximum part number
	if (i > max)
		max = i;
	# Verbose to mimic makekit so that the user has no surprise
	printf("%-26.26s %d\n", $2, i);
}
END {
	# Print the number of parts used
	print max > "zzz.list";
	# Print the list of files to be put in each archive
	for (i = 1; i <= max; i++)
		print list[i] >> "zzz.list";
}
'
# The following is not an UUC (Useless Use of Cat). On my Linux 2.0.30 system,
# bash does not understand "<zzz.list (" which had been perfectly OK on all
# the other systems I used for the past 9 years, without bash as /bin/sh.
cat zzz.list | (
	# Now back to the shell, parse the output from awk and invoke rshar
	read max;
	i=1
	while read first last
	do
		if test $i -lt 10; then
			name=${partname}0$i
		else
			name=${partname}$i
		fi
		echo "Packing kit $i..."
		$libdir/rshar -k $max -n $i -- $first $last > $name
		i=`expr $i + 1`
	done
)
rm -f zzz.list
exit 0

!NO!SUBS!
chmod 755 makeshar
$eunicefix makeshar
