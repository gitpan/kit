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
echo "Extracting kit/lib/getproc (with variable substitutions)"
$spitshell >getproc <<!GROK!THIS!
$startsh

# $Id: getproc.SH,v 2.0.1.1 1998/03/30 14:23:03 ram Exp $
#
# $Log: getproc.SH,v $
# Revision 2.0.1.1  1998/03/30 14:23:03  ram
# patch35: created
#

# Extracts compressor or uncompressor via a tag. This script is not meant
# to be invoked directly by the user.
#
# Usage: getproc [tag [compress | uncompress]]
#
# Without any argument, it lists all the known compression scheme tags.
# Otherwise, it selects the proper compression/decompression program.
# If the second argument is missing, "uncompress" is assumed.
#
# The compressor description lies in the kit public library.

libdir='$privlibexp'
!GROK!THIS!

$spitshell >>getproc <<'!NO!SUBS!'
tag="$1"
case "$tag" in
'') list=1;;
*) list=0;;
esac
case "$2" in
compress) idx=0;;
*) idx=1;;
esac

sed -e 's/[	][	]*/,/g' $libdir/compressors | awk "
BEGIN {
	tag = \"$tag\";
	idx = $idx;
	list = $list;
"'
	FS = ",";
}
/^[A-Za-z]/ {
	compress[$1] = $2;
	uncompress[$1] = $3;
	if (list)
		printf("    %s\n", $1);
}
END {
	if (!list) {
		if (idx == 0)
			printf("%s\n", compress[tag]);
		else
			printf("%s\n", uncompress[tag]);
	}
}
'
!NO!SUBS!
chmod 755 getproc
$eunicefix getproc
