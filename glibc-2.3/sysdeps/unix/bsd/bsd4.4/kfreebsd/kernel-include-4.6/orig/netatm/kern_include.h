/*
 *
 * ===================================
 * HARP  |  Host ATM Research Platform
 * ===================================
 *
 *
 * This Host ATM Research Platform ("HARP") file (the "Software") is
 * made available by Network Computing Services, Inc. ("NetworkCS")
 * "AS IS".  NetworkCS does not provide maintenance, improvements or
 * support of any kind.
 *
 * NETWORKCS MAKES NO WARRANTIES OR REPRESENTATIONS, EXPRESS OR IMPLIED,
 * INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE, AS TO ANY ELEMENT OF THE
 * SOFTWARE OR ANY SUPPORT PROVIDED IN CONNECTION WITH THIS SOFTWARE.
 * In no event shall NetworkCS be responsible for any damages, including
 * but not limited to consequential damages, arising from or relating to
 * any use of the Software or related support.
 *
 * Copyright 1994-1998 Network Computing Services, Inc.
 *
 * Copies of this Software may be made, however, the above copyright
 * notice must be reproduced on all copies.
 *
 *	@(#) $FreeBSD: src/sys/netatm/kern_include.h,v 1.3 1999/08/28 00:48:40 peter Exp $
 *
 */

/*
 * Core ATM Services
 * -----------------
 *
 * Common kernel module includes
 *
 */

#ifndef _NETATM_KERN_INCLUDE_H
#define	_NETATM_KERN_INCLUDE_H

/*
 * Note that we're compiling kernel code
 */
#define	ATM_KERNEL

#include <sys/param.h>
#include <sys/systm.h>
#include <sys/types.h>
#include <sys/errno.h>
#include <sys/malloc.h>
#include <sys/proc.h>
#include <sys/sockio.h>
#include <sys/time.h>
#include <sys/kernel.h>
#include <sys/conf.h>
#include <sys/domain.h>
#include <sys/protosw.h>
#include <sys/socket.h>
#include <sys/socketvar.h>
#include <sys/syslog.h>

#ifdef sun
#include <machine/cpu.h>
#include <machine/mmu.h>
#include <machine/psl.h>
#include <sun/openprom.h>
#include <sun/vddrv.h>
#include <sundev/mbvar.h>
#endif

#ifdef __FreeBSD__
#include <sys/eventhandler.h>
#include <machine/clock.h>
#include <vm/vm.h>
#include <vm/pmap.h>
#endif

/*
 * Networking support
 */
#include <net/if.h>
#if (defined(BSD) && (BSD >= 199103))
#include <net/if_types.h>
#include <net/if_dl.h>
#endif
#include <net/netisr.h>
#include <net/route.h>
#include <netinet/in.h>
#include <netinet/in_var.h>
#include <netinet/if_ether.h>

/*
 * Porting fluff
 */
#include <netatm/port.h>

/*
 * ATM core services
 */
#include <netatm/queue.h>
#include <netatm/atm.h>
#include <netatm/atm_sys.h>
#include <netatm/atm_sap.h>
#include <netatm/atm_cm.h>
#include <netatm/atm_if.h>
#include <netatm/atm_vc.h>
#include <netatm/atm_ioctl.h>
#include <netatm/atm_sigmgr.h>
#include <netatm/atm_stack.h>
#include <netatm/atm_pcb.h>
#include <netatm/atm_var.h>

#endif	/* _NETATM_KERN_INCLUDE_H */
