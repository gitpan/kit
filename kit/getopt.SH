case $CONFIG in
'')
	if test ! -f config.sh; then
		ln ../config.sh . || \
		ln ../../config.sh . || \
		ln ../../../config.sh . || \
		ln ../../../../config.sh . || \
		(echo "Can't find config.sh."; exit 1)
	fi 2>/dev/null
	. ./config.sh
	;;
esac
case "$0" in
*/*) cd `expr X$0 : 'X\(.*\)/'` ;;
esac
echo "Extracting kit/getopt (with variable substitutions)"
$spitshell >getopt <<!GROK!THIS!
$startsh
!GROK!THIS!
$spitshell >>getopt <<'!NO!SUBS!'

# Usage: getopt optstr [options]
#
# Here is a typical use inside a script:
#	eval "set X "`getopt optstr "$@"`
#	shift
#
# Then the $* array can then be parsed as usual, with all the options up to
# any optional '--' split up, for instance '-lfoo' becomes '-l foo' if l: is
# given in optstr, and '-lf' becomes '-l -f' if only lf is given as optstr.

# $Id: getopt.SH,v 2.0.1.2 1993/01/22 12:10:59 ram Exp $
#
# $Log: getopt.SH,v $
# Revision 2.0.1.2  1993/01/22  12:10:59  ram
# patch23: take care of '-n' on BSD systems (meaningful to echo)
#
# Revision 2.0.1.1  93/01/11  18:04:27  ram
# patch22: created
# 

# Options specification (getopt style)
optstr=$1; shift

# Process the command line options. Add a leading 'x' to each argument, in case
# one of them is a '-n' and we are on a BSD system...
set X `for arg in "$@"; do echo x$arg; done | awk '
BEGIN {
	optstr = "'$optstr'";	# getopt-style specification

	len = length(optstr);
	for (i = 1; i <= len; i++) {
		c = substr(optstr, i, 1);
		if (i < len) a = substr(optstr, i + 1, 1); else a = "";
		if (a == ":") {
			arg[c] = 1;
			i++;
		}
		opt[c] = 1;
	}
}
{
	expect = 0;
	xstr = $0;
	str = substr(xstr, 2);
	if (str == "--")
		ended = 1;
	if (ended || substr(str, 1, 1) != "-") {
		printf("'"'%s'"'\n", str);
		next;
	}
	len = length(str);
	for (i = 2; i <= len; i++) {
		c = substr(str, i, 1);
		if (!opt[c]) {
			printf("-%s\n", substr(str, i));
			next;
		}
		printf("-%s\n", c);
		if (arg[c]) {
			if (i < len)
				printf("'"'%s'"'\n", substr(str, i + 1));
			else
				expect = 1;
			next;
		}
	}
}
END {
	if (expect)
		print "?";
}
'`
# Avoid 'echo $@' in case first option is -n on a BSD system...
shift
echo " "$@
!NO!SUBS!
chmod 755 getopt
$eunicefix getopt
