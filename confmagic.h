/*
 * This file was produced by running metaconfig and is intended to be included
 * after config.h and after all the other needed includes have been dealt with.
 *
 * This file may be empty, and should not be edited. Rerun metaconfig instead.
 * If you wish to get rid of this magic, remove this file and rerun metaconfig
 * without the -M option.
 *
 *  $Id: confmagic.h,v 2.0.1.1 1998/03/30 14:20:18 ram Exp $
 */

#ifndef _confmagic_h_
#define _confmagic_h_

#ifndef HAS_BCOPY
#ifndef bcopy
#define bcopy(s,d,l) memcpy((d),(s),(l))
#endif
#endif

#ifndef HAS_INDEX
#ifndef index
#define index strchr
#endif
#endif

#endif
