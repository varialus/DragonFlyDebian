/* Copyright (C) 2002 Free Software Foundation, Inc.
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

#ifndef _SYSCALL_H
#define _SYSCALL_H	1

#define SYS_exit			1
#define SYS_fork			2
#define SYS_read			3
#define SYS_write			4
#define SYS_open			5
#define SYS_close			6
#define SYS_wait4			7
/*#define SYS_creat			8	obsoleted */
#define SYS_link			9
#define SYS_unlink			10
/*#define SYS_execv			11 	removed syscall */
#define SYS_chdir			12
#define SYS_fchdir			13
#define SYS_mknod			14
#define SYS_chmod			15
#define SYS_chown			16
#define SYS_obreak			17
#define SYS_getfsstat			18
/*#define SYS_lseek			19	new 64-bit variant at 199 */
#define SYS_getpid			20
#define SYS_mount			21
#define SYS_unmount			22
#define SYS_setuid			23
#define SYS_getuid			24
#define SYS_geteuid			25
#define SYS_ptrace			26
#define SYS_recvmsg			27
#define SYS_sendmsg			28
#define SYS_recvfrom			29
#define SYS_accept			30
#define SYS_getpeername			31
#define SYS_getsockname			32
#define SYS_access			33
#define SYS_chflags			34
#define SYS_fchflags			35
#define SYS_sync			36
#define SYS_kill			37
/*#define SYS_stat			38	new 32-bit variant at 188 */
#define SYS_getppid			39
/*#define SYS_lstat			40	new 32-bit variant at 190 */
#define SYS_dup				41
#define SYS_pipe			42
#define SYS_getegid			43
#define SYS_profil			44
#define SYS_ktrace			45
/*#define SYS_sigaction			46	new 128-sigs variant at 342 */
#define SYS_getgid			47
/*#define SYS_sigprocmask		48	new 128-sigs variant at 340 */
#define SYS_getlogin			49
#define SYS_setlogin			50
#define SYS_acct			51
/*#define SYS_sigpending		52	new 128-sigs variant at 343 */
#define SYS_sigaltstack			53
#define SYS_ioctl			54
#define SYS_reboot			55
#define SYS_revoke			56
#define SYS_symlink			57
#define SYS_readlink			58
#define SYS_execve			59
#define SYS_umask			60
#define SYS_chroot			61
/*#define SYS_fstat			62	new 32-bit variant at 189 */
/*#define SYS_getkerninfo		63	obsoleted by uname, sysctl */
/*#define SYS_getpagesize		64	obsoleted by sysctl CTL_HW HW_PAGESIZE */
#define SYS_msync			65	/* also at 277 */
#define SYS_vfork			66
/*#define SYS_vread			67 	removed syscall */
/*#define SYS_vwrite			68 	removed syscall */
/*#define SYS_sbrk			69	stub returning EOPNOTSUPP */
/*#define SYS_sstk			70	stub returning EOPNOTSUPP */
/*#define SYS_mmap			71	new 64-bit variant at 197 */
/*#define SYS_ovadvise			72	stub returning EINVAL */
#define SYS_munmap			73
#define SYS_mprotect			74
#define SYS_madvise			75
/*#define SYS_vhangup			76 	removed syscall */
/*#define SYS_vlimit			77 	removed syscall */
#define SYS_mincore			78
#define SYS_getgroups			79
#define SYS_setgroups			80
#define SYS_getpgrp			81
#define SYS_setpgid			82
#define SYS_setitimer			83
/*#define SYS_wait			84	obsoleted by wait4 */
#define SYS_swapon			85
#define SYS_getitimer			86
/*#define SYS_gethostname		87	obsoleted by sysctl CTL_KERN KERN_HOSTNAME */
/*#define SYS_sethostname		88	obsoleted by sysctl CTL_KERN KERN_HOSTNAME */
#define SYS_getdtablesize		89
#define SYS_dup2			90
#define SYS_fcntl			92
#define SYS_select			93
#define SYS_fsync			95
#define SYS_setpriority			96
#define SYS_socket			97
#define SYS_connect			98
/*#define SYS_accept			99	new socket variant at 30 */
#define SYS_getpriority			100
/*#define SYS_send			101	old socket ABI, obsoleted */
/*#define SYS_recv			102	old socket ABI, obsoleted */
/*#define SYS_sigreturn			103	new 128-sigs variant at 344 */
#define SYS_bind			104
#define SYS_setsockopt			105
#define SYS_listen			106
/*#define SYS_vtimes			107 	removed syscall */
/*#define SYS_sigvec			108	old 32-sigs ABI, obsoleted */
/*#define SYS_sigblock			109	old 32-sigs ABI, obsoleted */
/*#define SYS_sigsetmask		110	old 32-sigs ABI, obsoleted */
/*#define SYS_sigsuspend		111	new 128-sigs variant at 341 */
/*#define SYS_sigstack			112     obsoleted by sigaltstack */
/*#define SYS_recvmsg			113	new socket variant at 27 */
/*#define SYS_sendmsg			114	new socket variant at 28 */
/*#define SYS_vtrace			115 	removed syscall */
#define SYS_gettimeofday		116
#define SYS_getrusage			117
#define SYS_getsockopt			118
#define SYS_readv			120
#define SYS_writev			121
#define SYS_settimeofday		122
#define SYS_fchown			123
#define SYS_fchmod			124
/*#define SYS_recvfrom			125	new socket variant at 29 */
#define SYS_setreuid			126
#define SYS_setregid			127
#define SYS_rename			128
/*#define SYS_truncate			129	new 64-bit variant at 200 */
/*#define SYS_ftruncate			130	new 64-bit variant at 201 */
#define SYS_flock			131
#define SYS_mkfifo			132
#define SYS_sendto			133
#define SYS_shutdown			134
#define SYS_socketpair			135
#define SYS_mkdir			136
#define SYS_rmdir			137
#define SYS_utimes			138
/*#define SYS_sigreturn			139 	removed syscall */
#define SYS_adjtime			140
/*#define SYS_getpeername		141	new socket variant at 31 */
/*#define SYS_gethostid			142	obsoleted by sysctl CTL_KERN KERN_HOSTID */
/*#define SYS_sethostid			143	obsoleted by sysctl CTL_KERN KERN_HOSTID */
/*#define SYS_getrlimit			144	new 64-bit variant at 194 */
/*#define SYS_setrlimit			145	new 64-bit variant at 195 */
/*#define SYS_killpg			146	obsoleted by kill(sig,-pid) */
#define SYS_setsid			147
#define SYS_quotactl			148
/*#define SYS_quota			149	obsolete */
/*#define SYS_getsockname		150	new socket variant at 32 */
/*#define SYS_getdirentries		156	new variant w. d_type at 196 */
#define SYS_statfs			157
#define SYS_fstatfs			158
#define SYS_getfh			161
#define SYS_getdomainname		162
#define SYS_setdomainname		163
#define SYS_uname			164
#define SYS_sysarch			165
#define SYS_rtprio			166
#define SYS_semsys			169	/* redundant, see at 220-223 */
#define SYS_msgsys			170	/* redundant, see at 224-227 */
#define SYS_shmsys			171	/* redundant, see at 228-231 */
#define SYS_pread			173
#define SYS_pwrite			174
#define SYS_ntp_adjtime			176
#define SYS_setgid			181
#define SYS_setegid			182
#define SYS_seteuid			183
/*#define SYS_lfs_bmapv			184	obsolete */
/*#define SYS_lfs_markv			185	obsolete */
/*#define SYS_lfs_segclean		186	obsolete */
/*#define SYS_lfs_segwait		187	obsolete */
#define SYS_stat			188	/* takes a 'struct stat' */
#define SYS_fstat			189	/* takes a 'struct stat' */
#define SYS_lstat			190	/* takes a 'struct stat' */
#define SYS_pathconf			191
#define SYS_fpathconf			192
#define SYS_getrlimit			194	/* takes a 'struct rlimit' */
#define SYS_setrlimit			195	/* takes a 'struct rlimit' */
#define SYS_getdirentries		196
#define SYS_mmap			197	/* takes a 64-bit off_t ! */
#define SYS_lseek			199	/* takes a 64-bit off_t ! */
#define SYS_truncate			200	/* takes a 64-bit off_t ! */
#define SYS_ftruncate			201	/* takes a 64-bit off_t ! */
#define SYS_sysctl			202
#define SYS_mlock			203
#define SYS_munlock			204
#define SYS_undelete			205
#define SYS_futimes			206
#define SYS_getpgid			207
#define SYS_poll			209
#define SYS_semctl			220
#define SYS_semget			221
#define SYS_semop			222
/*#define SYS_semconfig			223	removed in FreeBSD 4.6 */
#define SYS_msgctl			224
#define SYS_msgget			225
#define SYS_msgsnd			226
#define SYS_msgrcv			227
#define SYS_shmat			228
#define SYS_shmctl			229
#define SYS_shmdt			230
#define SYS_shmget			231
#define SYS_clock_gettime		232
#define SYS_clock_settime		233
#define SYS_clock_getres		234
#define SYS_nanosleep			240
#define SYS_minherit			250
#define SYS_rfork			251
/*#define SYS_openbsd_poll		252	OpenBSD duplicate of 209 */
#define SYS_issetugid			253
#define SYS_lchown			254	/* also at 275 */
#define SYS_getdents			272
#define SYS_lchmod			274
/*#define SYS_lchown			275	NetBSD duplicate of 254 */
#define SYS_lutimes			276
/*#define SYS_msync			277	NetBSD duplicate of 65 */
#define SYS_nstat			278	/* takes a 'struct nstat' */
#define SYS_nfstat			279	/* takes a 'struct nstat' */
#define SYS_nlstat			280	/* takes a 'struct nstat' */
#define SYS_fhstatfs			297
#define SYS_fhopen			298
#define SYS_fhstat			299	/* takes a 'struct stat' */
#define SYS_modnext			300
#define SYS_modstat			301
#define SYS_modfnext			302
#define SYS_modfind			303
#define SYS_kldload			304
#define SYS_kldunload			305
#define SYS_kldfind			306
#define SYS_kldnext			307
#define SYS_kldstat			308
#define SYS_kldfirstmod			309
#define SYS_getsid			310
#define SYS_setresuid			311
#define SYS_setresgid			312
/*#define SYS_signanosleep		313 	removed syscall */
#define SYS_aio_return			314
#define SYS_aio_suspend			315
#define SYS_aio_cancel			316
#define SYS_aio_error			317
#define SYS_aio_read			318
#define SYS_aio_write			319
#define SYS_lio_listio			320
#define SYS_yield			321
#define SYS_thr_sleep			322
#define SYS_thr_wakeup			323
#define SYS_mlockall			324
#define SYS_munlockall			325
#define SYS_getcwd			326
#define SYS_sched_setparam		327
#define SYS_sched_getparam		328
#define SYS_sched_setscheduler		329
#define SYS_sched_getscheduler		330
#define SYS_sched_yield			331
#define SYS_sched_get_priority_max	332
#define SYS_sched_get_priority_min	333
#define SYS_sched_rr_get_interval	334
#define SYS_utrace			335
#define SYS_sendfile			336
#define SYS_kldsym			337
#define SYS_jail			338
#define SYS_sigprocmask			340
#define SYS_sigsuspend			341
#define SYS_sigaction			342
#define SYS_sigpending			343
#define SYS_sigreturn			344
#define SYS_acl_get_file		347
#define SYS_acl_set_file		348
#define SYS_acl_get_fd			349
#define SYS_acl_set_fd			350
#define SYS_acl_delete_file		351
#define SYS_acl_delete_fd		352
#define SYS_acl_aclcheck_file		353
#define SYS_acl_aclcheck_fd		354
#define SYS_extattrctl			355
#define SYS_extattr_set_file		356
#define SYS_extattr_get_file		357
#define SYS_extattr_delete_file		358
#define SYS_aio_waitcomplete		359
#define SYS_getresuid			360
#define SYS_getresgid			361
#define SYS_kqueue			362	/* new in FreeBSD 4.6 */
#define SYS_kevent			363	/* new in FreeBSD 4.6 */

#endif
