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
echo "Extracting kit/range (with variable substitutions)"
$spitshell >range <<!GROK!THIS!
$startsh
!GROK!THIS!

$spitshell >>range <<'!NO!SUBS!'
# Peform range expansion (first parameter is maximum value for open ranges)
# Numbers may be space or comma separated. Ranges are a-b. If a is missing,
# 1 is assumed. If b is missing, the maximum value is used.

# $Id: range.SH,v 2.0.1.2 1992/05/08 11:17:30 ram Exp $
#
# $Log: range.SH,v $
# Revision 2.0.1.2  1992/05/08  11:17:30  ram
# patch17: some awk hang up with </dev/null within backquotes
#
# Revision 2.0.1.1  92/05/02  14:17:22  ram
# patch16: created
# 

# The first parameter gives the maximum number allowed
maxspec=$1
shift

# Make sure every range is space separated
set X `echo "$*" | sed -e 's/,/ /g'`
shift

range=''
for i in $*; do
	# Deal with incomplete ranges (e.g. -5 or 10-)
	case "X${i}X" in
	X-*) i="1$i";;
	*-X) i="$i$maxspec";;
	esac
	# Add the range (expanded when necessary) into $range
	case "$i" in
	*-*)
		end=`expr $i : '[0-9]*-\(.*\)'`
		start=`expr $i : '\(.*\)-[0-9]*'`
		vector=`cat /dev/null | awk "
			BEGIN {for (i = $start; i <= $end; i++) printf(\"%d \", i);}"`
		range="$range $vector"
		;;
	*)
		range="$range $i"
		;;
	esac
done

# Now remove duplicates, sort numbers and discard values above the maximum
echo "$range" | tr ' ' '\012' | awk '
BEGIN {
	max = '$maxspec';
}
/^[0-9]+/ {
	val = $1;
	if (val <= max)
		num[val] = val;
}
END {
	for (i = 1; i <= max; i++)
		if (num[i])
			printf("%d ", i);
	printf("\n");
}
'
!NO!SUBS!
chmod 755 range
$eunicefix range
