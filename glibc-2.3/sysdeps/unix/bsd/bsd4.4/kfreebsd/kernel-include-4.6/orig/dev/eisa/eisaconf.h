/*
 * EISA bus device definitions
 *
 * Copyright (c) 1995, 1996 Justin T. Gibbs.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice immediately at the beginning of the file, without modification,
 *    this list of conditions, and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * $FreeBSD: src/sys/dev/eisa/eisaconf.h,v 1.20 1999/08/28 00:43:39 peter Exp $
 */

#ifndef _I386_EISA_EISACONF_H_
#define _I386_EISA_EISACONF_H_ 1

#define EISA_SLOT_SIZE 0x1000

#define EISA_MFCTR_CHAR0(ID) (char)(((ID>>26) & 0x1F) | '@')  /* Bits 26-30 */
#define EISA_MFCTR_CHAR1(ID) (char)(((ID>>21) & 0x1F) | '@')  /* Bits 21-25 */
#define EISA_MFCTR_CHAR2(ID) (char)(((ID>>16) & 0x1F) | '@')  /* Bits 16-20 */
#define EISA_MFCTR_ID(ID)    (short)((ID>>16) & 0xFF)	      /* Bits 16-31 */
#define EISA_PRODUCT_ID(ID)  (short)((ID>>4)  & 0xFFF)        /* Bits  4-15 */
#define EISA_REVISION_ID(ID) (u_char)(ID & 0x0F)              /* Bits  0-3  */

extern int num_eisa_slots;

typedef u_int32_t eisa_id_t;

enum eisa_device_ivars {
    EISA_IVAR_SLOT,
    EISA_IVAR_ID,
    EISA_IVAR_IRQ
};

#define EISA_TRIGGER_EDGE       0x0
#define EISA_TRIGGER_LEVEL      0x1

/*
 * Simplified accessors for isa devices
 */
#define EISA_ACCESSOR(A, B, T)						 \
									 \
static __inline T eisa_get_ ## A(device_t dev)				 \
{									 \
	uintptr_t v;							 \
	BUS_READ_IVAR(device_get_parent(dev), dev, EISA_IVAR_ ## B, &v); \
	return (T) v;							 \
}									 \
									 \
static __inline void eisa_set_ ## A(device_t dev, T t)			 \
{									 \
	u_long v = (u_long) t;						 \
	BUS_WRITE_IVAR(device_get_parent(dev), dev, EISA_IVAR_ ## B, v); \
}

EISA_ACCESSOR(slot, SLOT, int)
EISA_ACCESSOR(id, ID, eisa_id_t)
EISA_ACCESSOR(irq, IRQ, eisa_id_t)

int eisa_add_intr __P((device_t, int, int));

#define		RESVADDR_NONE		0x00
#define		RESVADDR_BITMASK	0x01	/* size is a mask of reserved 
						 * bits at addr
						 */
#define		RESVADDR_RELOCATABLE	0x02
int eisa_add_iospace __P((device_t, u_long, u_long, int));
int eisa_add_mspace __P((device_t, u_long, u_long, int));

#endif /* _I386_EISA_EISACONF_H_ */
