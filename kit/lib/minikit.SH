case $CONFIG in
'')
	if test ! -f config.sh; then
		ln ../config.sh . || \
		ln ../../config.sh . || \
		ln ../../../config.sh . || \
		(echo "Can't find config.sh."; exit 1)
	fi 2>/dev/null
	. ./config.sh
	;;
esac
case "$0" in
*/*) cd `expr X$0 : 'X\(.*\)/'` ;;
esac

# $Id: minikit.SH,v 2.0.1.1 92/04/20 17:38:35 ram Exp $
#
# $Log:	minikit.SH,v $
# Revision 2.0.1.1  92/04/20  17:38:35  ram
# patch15: minikit now extracted via a .SH file
# patch15: added acknowledgment support
# patch15: replaced space indentation with tabs
# 

echo "Extracting kit/lib/minikit (with variable substitutions)"
$spitshell >minikit <<!GROK!THIS!
#! /bin/sh
(exit \$?0) || exec sh \$0
ver='$VERSION'
pl='$PATCHLEVEL'
!GROK!THIS!

$spitshell >>minikit <<'!NO!SUBS!'
files='mini_unkit mini_size mini_size.c mini_code.c core mini_code'
trap "rm -f $files; echo "Aborted"; exit 1" 1 2 3 15
echo "Minikit [version $ver PL$pl]"
echo "Extracting mini kit..."
cat >mini_code.c <<'EOP'
#include <stdio.h>
#define reg register
#define streq(s0, s1)  strcmp(s0, s1) == 0
#define times85(x)	((((((x<<2)+x)<<2)+x)<<2)+x)
#define DE(c) ((c) - '!')
long_t Ceor = 0;
long_t Csum = 0;
long_t Crot = 0;
long_t w = 0;
long_t b = 0;
fatal()
{
	fprintf(stderr, "bad format or Csum to atob\n");
	exit(1);
}
decode(c) reg c;
{
	if (c == 'z') {
		if (b != 0) {
			fatal();
		} else {
			bo(0); bo(0); bo(0); bo(0);
		}
	} else if ((c >= '!') && (c < ('!' + 85))) {
		if (b == 0) {
			w = DE(c);
			++b;
		} else if (b < 4) {
			w = times85(w);
			w += DE(c);
			++b;
		} else {
			w = times85(w) + DE(c);
			bo((int)((w >> 24) & 255));
			bo((int)((w >> 16) & 255));
			bo((int)((w >> 8) & 255));
			bo((int)(w & 255));
			w = 0;
			b = 0;
		}
	} else {
		fatal();
	}
}
FILE *t;
bo(c) reg c;
{
	Ceor ^= c;
	Csum += c;
	Csum += 1;
	if ((Crot & 0x80000000)) {
		Crot <<= 1;
		Crot += 1;
	} else
		Crot <<= 1;
	Crot += c;
	putc(c, t);
}
main(argc, argv) char **argv;
{
	reg c;
	reg long_t i;
	char n[100];
	char buf[100];
	long_t n1, n2, oeor, osum, orot;

	if (argc != 1) {
		fprintf(stderr,"bad args to %s\n", argv[0]);
		exit(2);
	}
	sprintf(n, "/usr/tmp/atob.%x", getpid());
	t = fopen(n, "w+");
	if (t == NULL)
		fatal();
	unlink(n);
	for (;;) {
		if (fgets(buf, sizeof buf, stdin) == NULL)
			fatal();
		if (streq(buf, "xbtoa Begin\n"))
			break;
	}

	while ((c = getchar()) != EOF) {
		if (c == '\n')
			continue;
		else if (c == 'x')
			break;
		else
			decode(c);
	}
	if(scanf("btoa End N %ld %lx E %lx S %lx R %lx\n",&n1,&n2,&oeor,&osum,&orot)!=5)
		fatal();
	if ((n1 != n2) || (oeor != Ceor) || (osum != Csum) || (orot != Crot))
		fatal();
	else {
		fseek(t, 0L, 0);
		for (i = n1; --i >= 0;)
			putchar(getc(t));
	}
	exit(0);
}
EOP
cat >mini_unkit<<EOP
ver='$ver'
pl='$pl'
EOP
cat >>mini_unkit <<'EOP'
if tar -cf - /dev/null 2>/dev/null | tar -xof - >/dev/null 2>&1; then
	tar_opt='xvof'
else
	tar_opt='xvf'
fi
if test -f zag.ba.aa; then
	cat `ls zag.ba.??` | ./mini_code | zcat | tar $tar_opt - || exit 1
else
	echo >&2 "Sorry, I can only deal with plain ascii-encoded kits"
	exit 1
fi
if test -f zzz.ack -a -f /usr/lib/sendmail; then
	s=`cat zzz.ack`
	sb=`cat zzz.subject`
	echo "Sending acknowledgment to $s..."
	u=`(logname) 2>/dev/null || whoami`
	h=`(uname -n) 2>/dev/null || hostname 2>/dev/null`
	d=`date`
	/usr/lib/sendmail $s <<EOM
Subject: Kit received [$sb]
To: $s
Precedence: junk
X-Mailer: minikit [version $ver PL$pl]

Your kit archive labeled '$sb' has been
unpacked by $u@$h on $d.
EOM
fi
test -f zzz.minikit && rm -f `cat zzz.minikit` zzz.minikit
rm -f z??.[hb][ea]*.??
EOP
echo "Compiling mini kit..."
cat >mini_size.c <<'EOP'
main() { printf("%d\n", sizeof(int)); }
EOP
is=4
lt=int
if cc -o mini_size mini_size.c >/dev/null 2>&1; then
	is=`./mini_size 2>/dev/null`
	case "$is" in
	2) lt=long;;
	4) ;;
	8) lt=short;;
	*) echo "WARNING: unknown int size ($is bytes) -- get kit $ver PL$pl";;
	esac
fi
if cc -Dlong_t=$lt -o mini_code mini_code.c >/dev/null 2>&1; then
	echo "Running mini kit..."
	sh mini_unkit
else
	echo "Error in C compilation--aborting."
fi
rm -f $files
echo "Done."
!NO!SUBS!
chmod 755 minikit
$eunicefix minikit
