/* Structures and definitions for magnetic tape I/O control commands.
   Copyright (C) 1996, 1997, 2002 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

#ifndef _SYS_MTIO_H
#define _SYS_MTIO_H	1

/* Get necessary definitions from system and kernel headers.  */
#include <sys/types.h>
#include <sys/ioctl.h>


/* Structure for MTIOCTOP - magnetic tape operation command.  */
struct mtop
  {
    short int mt_op;		/* Operations defined below.  */
    int mt_count;		/* How many of them.  */
  };

/* Magnetic Tape operations [Not all operations supported by all drivers].  */
#define MTFSF	1	/* Forward space over FileMark,
			 * position at first record of next file.  */
#define MTBSF	2	/* Backward space FileMark (position before FM).  */
#define MTFSR	3	/* Forward space record.  */
#define MTBSR	4	/* Backward space record.  */
#define MTWEOF	0	/* Write an end-of-file record (mark).  */
#define MTREW	5	/* Rewind.  */
#define MTOFFL	6	/* Rewind and put the drive offline (eject?).  */
#define MTNOP	7	/* No op, set status only (read with MTIOCGET).  */
#define MTCACHE	8	/* Enable controller cache.  */
#define MTNOCACHE 9	/* Disable controller cache.  */
#define MTSETBSIZ 10	/* Set block size.  */
#define MTSETDNSTY 11	/* Set density.  */
#define MTERASE 12	/* Erase tape -- be careful!  */
#define MTEOD	13	/* Overwrite with spaces -- be careful!  */
#define MTCOMP	14	/* Select compression mode.  */
#define MTRETENS 15	/* Re-tension tape.  */
#define MTWSS	16	/* Write setmarks.  */
#define MTFSS	17	/* Space forward over setmarks.  */
#define MTBSS	18	/* Space backward over setmarks.  */

#define MT_COMP_ENABLE		0xffffffff
#define MT_COMP_DISABLED	0xfffffffe
#define MT_COMP_UNSUPP		0xfffffffd

/* structure for MTIOCGET - mag tape get status command */

struct mtget
  {
    short mt_type;		/* Type of magtape device.  */
    /* The following registers are device dependent.  */
    short mt_dsreg;		/* Status register.  */
    short mt_erreg;		/* Error register.  */
    /* End of device dependent registers.  */
    short mt_resid;		/* Residual count: (not sure)
				   number of bytes ignored, or
				   number of files not skipped, or
				   number of records not skipped.  */
    __daddr_t mt_blksiz;	/* Current block size.  */
    __daddr_t mt_density;	/* Current density.  */
    __uint32_t mt_comp;		/* Current compression.  */
    __daddr_t mt_blksiz0;	/* Block size for mode 0.  */
    __daddr_t mt_blksiz1;	/* Block size for mode 1.  */
    __daddr_t mt_blksiz2;	/* Block size for mode 2.  */
    __daddr_t mt_blksiz3;	/* Block size for mode 3.  */
    __daddr_t mt_density0;	/* Density for mode 0.  */
    __daddr_t mt_density1;	/* Density for mode 1.  */
    __daddr_t mt_density2;	/* Density for mode 2.  */
    __daddr_t mt_density3;	/* Density for mode 3.  */
    __uint32_t mt_comp0;	/* Compression for mode 0.  */
    __uint32_t mt_comp1;	/* Compression for mode 1.  */
    __uint32_t mt_comp2;	/* Compression for mode 2.  */
    __uint32_t mt_comp3;	/* Compression for mode 3.  */
    /* The next two fields are not always used.  */
    __daddr_t mt_fileno;	/* Number of current file on tape.  */
    __daddr_t mt_blkno;		/* Current block number.  */
  };


/* Constants for mt_type.  */
#define	MT_ISTS		0x01		/* TS-11 */
#define	MT_ISHT		0x02		/* TM03 Massbus: TE16, TU45, TU77 */
#define	MT_ISTM		0x03		/* TM11/TE10 Unibus */
#define	MT_ISMT		0x04		/* TM78/TU78 Massbus */
#define	MT_ISUT		0x05		/* SI TU-45 emulation on Unibus */
#define	MT_ISCPC	0x06		/* SUN */
#define	MT_ISAR		0x07		/* SUN */
#define	MT_ISTMSCP	0x08		/* DEC TMSCP protocol (TU81, TK50) */
#define MT_ISCY		0x09		/* CCI Cipher */
#define MT_ISCT		0x0a		/* HP 1/4 tape */
#define MT_ISFHP	0x0b		/* HP 7980 1/2 tape */
#define MT_ISEXABYTE	0x0c		/* Exabyte */
#define MT_ISEXA8200	0x0c		/* Exabyte EXB-8200 */
#define MT_ISEXA8500	0x0d		/* Exabyte EXB-8500 */
#define MT_ISVIPER1	0x0e		/* Archive Viper-150 */
#define MT_ISPYTHON	0x0f		/* Archive Python (DAT) */
#define MT_ISHPDAT	0x10		/* HP 35450A DAT drive */
#define MT_ISMFOUR	0x11		/* M4 Data 1/2 9track drive */
#define MT_ISTK50	0x12		/* DEC SCSI TK50 */
#define MT_ISMT02	0x13		/* Emulex MT02 SCSI tape controller */

/* Constants for mt_dsreg.  */
#define	MTIO_DSREG_NIL	0	/* Unknown */
#define	MTIO_DSREG_REST	1	/* Doing Nothing */
#define	MTIO_DSREG_RBSY	2	/* Communicating with tape (but no motion) */
#define	MTIO_DSREG_WR	20	/* Writing */
#define	MTIO_DSREG_FMK	21	/* Writing Filemarks */
#define	MTIO_DSREG_ZER	22	/* Erasing */
#define	MTIO_DSREG_RD	30	/* Reading */
#define	MTIO_DSREG_FWD	40	/* Spacing Forward */
#define	MTIO_DSREG_REV	41	/* Spacing Reverse */
#define	MTIO_DSREG_POS	42	/* Hardware Positioning (direction unknown) */
#define	MTIO_DSREG_REW	43	/* Rewinding */
#define	MTIO_DSREG_TEN	44	/* Retensioning */
#define	MTIO_DSREG_UNL	45	/* Unloading */
#define	MTIO_DSREG_LD	46	/* Loading */


/* Magnetic tape I/O control commands.  */
#define	MTIOCTOP	_IOW('m', 1, struct mtop)	/* Do a mag tape op. */
#define	MTIOCGET	_IOR('m', 2, struct mtget)	/* Get tape status.  */

#define MTIOCIEOT	_IO('m', 3)			/* ignore EOT error */
#define MTIOCEEOT	_IO('m', 4)			/* enable EOT error */

#define	MTIOCRDSPOS	_IOR('m', 5, u_int32_t)	/* get logical blk addr */
#define	MTIOCRDHPOS	_IOR('m', 6, u_int32_t)	/* get hardware blk addr */
#define	MTIOCSLOCATE	_IOW('m', 5, u_int32_t)	/* seek to logical blk addr */
#define	MTIOCHLOCATE	_IOW('m', 6, u_int32_t)	/* seek to hardware blk addr */
#define	MTIOCERRSTAT	_IOR('m', 7, union mterrstat)	/* get tape errors */

#define	MTIOCSETEOTMODEL	_IOW('m', 8, u_int32_t)
#define	MTIOCGETEOTMODEL	_IOR('m', 8, u_int32_t)


/* Specify default tape device.  */
#ifndef DEFTAPE
# define DEFTAPE	"/dev/tape"
#endif

#endif /* mtio.h */
