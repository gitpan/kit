/*
 * I got that from net.sources and extended it -- RAM
 *
 * $Id: badtar.c,v 2.0.1.4 1993/02/19 14:52:24 ram Exp $
 *
 * $Log: badtar.c,v $
 * Revision 2.0.1.4  1993/02/19 14:52:24  ram
 * patch26: wrongly reported end-of-tape when last block was short
 * patch26: one short tar block will now correctly be accounted for
 *
 * Revision 2.0.1.3  92/08/17  17:53:34  ram
 * patch18: badtar now correctly reports links
 * 
 * Revision 2.0.1.2  92/03/24  13:37:13  ram
 * patch14: fixed some loose declarations
 * 
 * Revision 2.0.1.1  92/01/11  19:12:45  ram
 * patch11: created
 * 
 */

/* read tar tapes with bad blocks MWS */
#include "../config.h"
#include "../patchlevel.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/file.h>					/* Should be metaconfigured ? */
#ifdef I_FCNTL							/* Added by ram for O_RDONLY */
#include <fcntl.h>
#else
#include <sys/fcntl.h>
#endif
#define TBLOCK		512					/* Size of a tape block */
#define NAMSIZ		100					/* Maximum size for filename */
#define BLOCKF		20					/* Blocking factor */
#define TAPEBLOCK 	(BLOCKF * TBLOCK)	/* Blocksize */

/* Values used in linkflag field */
#define REGTYPE		'0'					/* Regular file */
#define AREGTYPE	'\0'				/* Regular file */
#define LNKTYPE		'1'					/* Regular link */
#define SYMTYPE		'2'					/* Linkflag for symbolic link */
#define CHRTYPE		'3'					/* Character special file */
#define BLKTYPE		'4'					/* Block special file */
#define DIRTYPE		'5'					/* Directory */
#define FIFOTYPE	'6'					/* Named pipe */
#define CONTTYPE	'7'					/* Reserved */

#define islink(c)	((c) == LNKTYPE || (c) == SYMTYPE)

int verbose = 0;					/* Verbose output control */
int silent = 0;						/* Silent output control */
char *default_tape = TAPEDEV;		/* Default device tape file */

/* Logging printf */
#define lprintf		if (!silent) fprintf

/* see tar (4 or 5) in the manual */
union hblock {
     char dummy[TBLOCK];
     struct header {
          char name[NAMSIZ];
          char mode[8];
          char uid[8];
          char gid[8];
          char size[12];
          char mtime[12];
          char chksum[8];
          char linkflag;
          char linkname[NAMSIZ];
     } dbuf;
};
char pad[TBLOCK];

/* Print usage */
void usage()
{
	fprintf(stderr,
"Usage: badtar [-hiorsvV] [-l logfile] [-f tape drive] [-u uid] [-g gid]\n");
	fprintf(stderr, "  -V : print version number.\n");
	fprintf(stderr, "  -f : tape drive device or file (default is %s).\n",
		default_tape);
	fprintf(stderr, "  -g : set GID on extracted files (0 for current user).\n");
	fprintf(stderr, "  -h : print this help message.\n");
	fprintf(stderr, "  -i : ignore end of tape blocks.\n");
	fprintf(stderr, "  -l : define log file (default is stderr).\n");
	fprintf(stderr, "  -o : set ownership of files to current user.\n");
	fprintf(stderr, "  -r : make relative paths by removing leading '/'.\n");
	fprintf(stderr, "  -s : silent mode, no logging is done.\n");
	fprintf(stderr, "  -u : set UID on extracted files (0 for current user).\n");
	fprintf(stderr, "  -v : verbose mode, print headers found.\n");
}

/* Print version number */
void version()
{
	fprintf(stderr, "badtar %.1f PL%d\n", VERSION, PATCHLEVEL);
	fprintf(stderr, "(version modified by Raphael Manfredi, as part of kit)\n");
}

/* check the check sum for the header block */
int check_sum(c)
union hblock *c;
{
	int i,j;
	char *cp;
	cp = c->dummy;
	i = 0;
	for (j = 0; j < TBLOCK; j++)
		i += *cp++;
	/* When calculating the checksum, the "chksum" field is
	 * treated as if it were all blanks.
	 */
	for (j = 0; j < 8; j++)
		i -= c->dbuf.chksum[j];	/* Remove chksum values */
	for (j = 0; j < 8; j++)
		i += ' ';				/* Treat as blank */
	return(i);
}

char buf[TAPEBLOCK];
char xbuf[TAPEBLOCK];
int bpos = TAPEBLOCK - TBLOCK, eot = 0, bad = 0, fd1;
FILE *logf;

extern int errno;

/* get the next TBLOCK chars from the tape */
char *get_next()
{
	int res;
	int nbytes;
	if (bpos >= TAPEBLOCK - TBLOCK) {	/* Reached end of buf array */
		bcopy(xbuf, buf, TAPEBLOCK);	/* Reset buf to xbuf ('x' chars) */
		res = read(fd1, buf, TAPEBLOCK);	/* Read a new chunck */
		if (res == 0) {
			eot = 1;					/* End of tape */
			lprintf(logf, "*** End of tape?\n");
		} else if (res < TAPEBLOCK) {
			if (res == -1) {
				lprintf(logf, "*** Bad block on tape!!\n");
				bad = 1; 
			} else {
				/* We read only a partial block (maybe we are
				 * reading data through a pipe ?). Anyway, loop
				 * until TAPEBLOCK bytes have been read or an
				 * error occurred.
				 */
				for (
					nbytes = res;
					nbytes < TAPEBLOCK && res != -1;
					nbytes += res
				) {
					res = read(fd1, buf + nbytes, TAPEBLOCK - nbytes);
					if (res == -1) {
						lprintf(logf, "*** Bad block on tape!!\n");
						bad = 1;
						break;
					} else if (res == 0) {
						lprintf(logf, "*** Last block was short (%d bytes).\n",
							nbytes);
						break;
					}
				}
			}
		} else if (bad) {
			lprintf(logf, "*** End of bad block(s) on tape\n");
			bad = 0;
		}
		bpos = 0;
	} else
		bpos += TBLOCK;

	fflush(logf);			/* Let they know what we're doing */
	return &buf[bpos];
}

main(argc, argv)
char **argv;
{
	int i, size, chksum;
	int fblocks = 0;			/* Tape blocks used by file */
	int eot_block = 0;			/* Number of EOT blocks found */
	int user = -1;				/* UID to be forced */
	int group = -1;				/* GID to be forced */
	union hblock *hp;			/* To decipher headers */
	char tape[NAMSIZ];			/* Name of tape device */
	char ignore = 0;			/* Do not ignore EOT */
	char relative = 0;			/* Do not remove leading '/' */
	int nblock = 0;				/* Number of blocks written */
	strcpy(tape, default_tape);	/* Default device file */
	logf = stderr;				/* Default logging on stderr */
	i = 1;
	
	/* get arguments */
	while (argc > i && argv[i][0] == '-') {
		switch (argv[i][1]) {
			case 'f' : 
				if (argc > i + 1) {
					strcpy(tape,argv[++i]);
					}
				else {
					fprintf(stderr, "No tape drive name given\n");
					exit(10);
				}
				break;
			case 'l':
				if (argc > i + 1) {
					if ((logf = fopen(argv[++i], "w")) == NULL) {
						perror("Can't open log file\n");
						exit(11);
					}
				}
				else {
					fprintf(stderr, "No log file name given\n");
					exit(12);
				}
				break;
			case 'i':		/* Ignore end of tape condition */
				ignore = 1;
				break;
			case 'r':		/* Force relative paths */
				relative = 1;
				break;
			case 'o':		/* Forces ownership */
				user = (int) getuid();
				group = (int) getgid();
				break;
			case 'u':		/* Force UID on extraction */
				if (argc > i + 1) {
					sscanf(argv[++i], "%d", &user);
					if (user == 0)
						user = (int) getuid();	/* Can't give to root */
				} else {
					fprintf(stderr, "No user ID given\n");
					exit(1);
				}
				break;
			case 'g':		/* Force GID on extraction */
				if (argc > i + 1) {
					sscanf(argv[++i], "%d", &group);
					if (group == 0)
						group = (int) getgid();	/* Can't give to root */
				} else {
					fprintf(stderr, "No group ID given\n");
					exit(1);
				}
				break;
			case 'v':		/* Verbose logging */
				verbose = 1;
				silent = 0;
				break;
			case 's':		/* No logging */
				silent = 1;
				verbose = 0;
				break;
			case 'h':		/* Print help message */
				usage();
				exit(0);
			case 'V':		/* Print version number */
				version();
				exit(0);
			default: 
				usage();
				exit(13);
		}
		i++;
	}
	
	/* first char cannot be a 0 */
	pad[0]  = 'x';
	
	/* don't quite know what the tape driver will return, so fill buffer
	   with non zero rubbish
	 */
	for (i = 0; i < TAPEBLOCK; i++) xbuf[i] = 'x';
	
	/* open the tape drive ('-' stands for stdin) */
	if (0 == strcmp(tape, "-"))
		fd1 = 0;		/* Standard input */
	else if ((fd1 = open(tape, O_RDONLY,0)) < 0) {
		perror("can't open tape");
		exit(1);
	}
	while (1) {
		fflush(logf);			/* So that they know where we are */
		hp = (union hblock *) get_next();
		/* tar tests the first char to see if it is an end of tape (eot) block
		 * or not. Can't see why it doesn't use tape marks. Maybe they weren't
		 * invented when it was written?
	 	 */
	 	/* get a tar block */
		
		if (hp->dbuf.name[0] == '\0' && !bad && !fblocks) {
			/* skip possible eot block (there are two of them) */
			lprintf(logf, "*** End of tape block\n");
			eot_block++;
			if (eot_block < 2)
				continue;
			eot = 1;
		}
		/* note if the last block read is bad there may be rubish
		 * (old info from the last write at the end of it) this may cause
		 * some of the last files which are extracted to be partially
		 * overwritten. There is very little one can do about this
		 * (except pray)
		 */
		
		/* end of tape ?? */
		if (eot) {
			if (fblocks) {
				lprintf(logf,"*** Last file Truncated. File padded!!\n");
				while (fblocks-- > 0)
					nblock++, write(1, pad, TBLOCK);
			}
			if (!ignore) {
				/* write two blank (eot) blocks */
				pad[0] = '\0';
				nblock++, write(1, pad, TBLOCK);
				nblock++, write(1, pad, TBLOCK);
				i = BLOCKF - nblock % BLOCKF;	/* Pad if necessary */
				if (i < BLOCKF) {
					lprintf(logf, "*** Padding %d block%s\n", i, i>1 ? "s":"");
					for (; i > 0; i--)
						write(1, pad, TBLOCK);
				}
				lprintf(logf,"*** End of tar\n");
				exit(0);		/* OK */
			} else {
				lprintf(logf,"*** Ignoring end of tar\n");
				fblocks = 0;		/* You never know */
				eot = 0;			/* I said: ignore EOT !! */
				eot_block = 0;
				continue;
			}
		}
		
		/* We need two consecutive EOT blocks for eot
		 * condition to occur
		 */
		eot_block = 0;
		
		/* decode header informations */
		sscanf(hp->dbuf.size, "%lo", &size);
		sscanf(hp->dbuf.chksum, "%o", &chksum);

		if (fblocks > 0 && !bad) { /* all ok in the middle of a file */
			nblock++, write(1, hp, TBLOCK);
			fblocks--;
			/* header inside file ? */
			if (check_sum(hp) == chksum && hp->dbuf.name[0] != '\0')
				lprintf(logf, "*** Warning: Header found inside file!!\n");
			continue;
		}
		
		/* have we got a header ?? */
		if (check_sum(hp) == chksum && hp->dbuf.name[0] != '\0') {

			if (verbose) {
				char *type_flag;
				/* Write some informations about the header we've got */
				fprintf(logf, "*** Header found.\n");
				fprintf(logf, "***   Name: %s\n", hp->dbuf.name);
				fprintf(logf, "***   Size: %d\n", size);
				fprintf(logf, "***   Mode: %s\n", hp->dbuf.mode);
				switch (hp->dbuf.linkflag) {
				case AREGTYPE:
				case REGTYPE:
					type_flag = "regular file"; break;
				case LNKTYPE:
					type_flag = "hard link"; break;
				case SYMTYPE:
					type_flag = "symbolic link"; break;
				case CHRTYPE:
					type_flag = "character special file"; break;
				case BLKTYPE:
					type_flag = "block special file"; break;
				case DIRTYPE:
					type_flag = "directory"; break;
				case FIFOTYPE:
					type_flag = "named pipe (FIFO)"; break;
				case CONTTYPE:
					type_flag = "RESERVED"; break;
				default:
					type_flag = "UNKNOWN"; break;
				}
				fprintf(logf, "***   Link flag: %s\n", type_flag);
				if (islink(hp->dbuf.linkflag))
					fprintf(logf, "***   Link name: %s\n", hp->dbuf.linkname);
			}

			/* we have a header */
			if (fblocks > 0) {
				lprintf(logf, "*** Truncated!! File padded!!\n");
				while (fblocks-- > 0)
					nblock++, write(1, pad, TBLOCK);
			}

			/* If membership has to be overwritten, do it now */
			if (user != -1 || group != -1) {
				if (user != -1)
					sprintf(hp->dbuf.uid, "%o", user);
				if (group != -1)
					sprintf(hp->dbuf.gid, "%o", group);
				sprintf(hp->dbuf.chksum, "%o", check_sum(hp));
			}

			/* Remove the leading '/' to get non absolute path */
			if (relative) {
				if (hp->dbuf.name[0] == '/') {
					sprintf(hp->dbuf.name, "%s", hp->dbuf.name + 1);
					sprintf(hp->dbuf.chksum, "%o", check_sum(hp));
				}
				if (islink(hp->dbuf.linkflag) && hp->dbuf.linkname[0] == '/') {
					sprintf(hp->dbuf.linkname, "%s", hp->dbuf.linkname + 1);
					sprintf(hp->dbuf.chksum, "%o", check_sum(hp));
				}
			}

			/* Compute number of blocks used by the file */
			fblocks = (size%TBLOCK) ? size/TBLOCK + 1 : size/TBLOCK;
			fblocks = islink(hp->dbuf.linkflag) ? 0 : fblocks;
			lprintf(logf,"%s (%d bytes)\n", hp->dbuf.name, size);
			nblock++, write(1, hp, TBLOCK);		/* Write the header */
			continue;
		}
		
		/* not a header */
		if (fblocks <= 0) {
			/* throw it away! */
			lprintf(logf, "*** Deleted block!!\n");
			fblocks = 0;	/* It can't be < 0, but you know... */
			continue;
		}

		lprintf(logf, "***  Writing possibly bad block!!\n");
		fblocks--;
		nblock++, write(1, hp, TBLOCK);
	}
}

