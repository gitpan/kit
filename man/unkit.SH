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
echo "Extracting man/unkit.$manext (with variable substitutions)"
$rm -f unkit.$manext
$spitshell >unkit.$manext <<!GROK!THIS!
.so man$manext/kit.$manext
!GROK!THIS!
chmod 444 unkit.$manext
