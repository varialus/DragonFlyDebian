/*-
 * Copyright (c) 2000 The NetBSD Foundation, Inc.
 * All rights reserved.
 *
 * This code is derived from software contributed to The NetBSD Foundation
 * by Tyler C. Sarna.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *      This product includes software developed by the NetBSD
 *      Foundation, Inc. and its contributors.
 * 4. Neither the name of The NetBSD Foundation nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE NETBSD FOUNDATION, INC. AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * $FreeBSD: src/sys/dev/sound/pci/via82c686.h,v 1.1.2.5 2002/04/22 15:49:33 cg Exp $
 */

#ifndef _VIA_H
#define _VIA_H

/*
 * VIA Technologies VT82C686A Southbridge Audio Driver
 *
 * Documentation links:
 *
 * ftp://ftp.alsa-project.org/pub/manuals/via/686a.pdf
 * ftp://ftp.alsa-project.org/pub/manuals/general/ac97r21.pdf
 * ftp://ftp.alsa-project.org/pub/manuals/ad/AD1881_0.pdf (example AC'97 codec)
 */

#define VIA_PCICONF_MISC      0x41
#define         VIA_PCICONF_ACLINKENAB 0x80     /* ac link enab */
#define         VIA_PCICONF_ACNOTRST   0x40     /* ~(ac reset) */
#define         VIA_PCICONF_ACSYNC     0x20     /* ac sync */
#define         VIA_PCICONF_ACVSR      0x08     /* var. samp. rate */
#define         VIA_PCICONF_ACSGD      0x04     /* SGD enab */
#define         VIA_PCICONF_ACFM       0x02     /* FM enab */
#define         VIA_PCICONF_ACSB       0x01     /* SB enab */
#define VIA_PCICONF_FUNC_EN	0x42

#define VIA_PLAY_BASE		    0x00
#define VIA_REC_BASE		    0x10

#define VIA_RP_STAT                 0x00
#define         VIA_RPSTAT_INTR               0x03

#define VIA_RP_CONTROL              0x01
#define         VIA_RPCTRL_START              0x80
#define         VIA_RPCTRL_TERMINATE          0x40
#define		VIA_RPCTRL_AUTOSTART	      0x20
/* The following are 8233 specific */
#define		VIA_RPCTRL_I_STOP	      0x04
#define		VIA_RPCTRL_I_EOL	      0x02
#define		VIA_RPCTRL_I_FLAG	      0x01

#define VIA_RP_MODE                 0x02
#define         VIA_RPMODE_INTR_FLAG          0x01
#define         VIA_RPMODE_INTR_EOL           0x02
#define         VIA_RPMODE_STEREO             0x10
#define         VIA_RPMODE_16BIT              0x20
#define         VIA_RPMODE_AUTOSTART          0x80

#define VIA_RP_DMAOPS_BASE          0x04

#define VIA8233_RP_DXS_LVOL	      0x02
#define VIA8233_RP_DXS_RVOL	      0x03
#define VIA8233_RP_RATEFMT	      0x08
#define 	VIA8233_RATEFMT_48K	      0xfffff
#define		VIA8233_RATEFMT_STEREO	      0x00100000
#define		VIA8233_RATEFMT_16BIT	      0x00200000

#define VIA_RP_DMAOPS_COUNT         0x0C

#define VIA_CODEC_CTL               0x80
#define         VIA_CODEC_READ                0x00800000
#define         VIA_CODEC_BUSY                0x01000000
#define         VIA_CODEC_PRIVALID            0x02000000
#define         VIA_CODEC_INDEX(x)            ((x)<<16)

#define AC97_REG_EXT_AUDIO_ID           0x28
#define         AC97_CODEC_DOES_VRA             0x0001
#define         AC97_CODEC_DOES_MICVRA          0x0008
#define AC97_REG_EXT_AUDIO_STAT         0x2A
#define         AC97_ENAB_VRA                   0x0001
#define         AC97_ENAB_MICVRA                0x0008
#define AC97_REG_EXT_DAC_RATE           0x2C
#define AC97_REG_EXT_ADC_RATE           0x32

#endif /* _VIA_H */
