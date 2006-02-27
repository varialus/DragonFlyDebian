/* Machine-dependent ELF dynamic relocation inline functions.  FreeBSD/amd64 version.
   Copyright (C) 2006 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Petr Salinger, 2006.

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

#ifndef dl_machine_h
#include_next <dl_machine_h>

#undef RTLD_START

/* Initial entry point code for the dynamic linker.
   The C function `_dl_start' is the real entry point;
   its return value is the user program's entry point.  */
#define RTLD_START asm ("\n\
.text\n\
	.align 16\n\
.globl _start\n\
# we dont use it: .globl _dl_start_user\n\
_start:\n\
	# align stack.\n\
	andq $-16, %rsp\n\
	# save argument pointer.\n\
	movq %rdi, %r13\n\
	call _dl_start\n\
# we dont use it: _dl_start_user:\n\
	# Save the user entry point address in %r12.\n\
	movq %rax, %r12\n\
	# See if we were run as a command with the executable file\n\
	# name as an extra leading argument.\n\
	movl _dl_skip_args(%rip), %eax\n\
	# get the original argument count.\n\
	movq 0(%r13), %rdx\n\
	# Adjust the pointer to skip _dl_skip_args words.\n\
	leaq (%r13,%rax,8), %r13\n\
	# Subtract _dl_skip_args from argc.\n\
	subl %eax, %edx\n\
	# Put argc on adjusted place\n\
	movq %rdx, 0(%r13)\n\
	# Call _dl_init (struct link_map *main_map, int argc, char **argv, char **env)\n\
	# argc -> rsi\n\
	movq %rdx, %rsi\n\
	# _dl_loaded -> rdi\n\
	movq _rtld_local(%rip), %rdi\n\
	# env -> rcx\n\
	leaq 16(%r13,%rdx,8), %rcx\n\
	# argv -> rdx\n\
	leaq 8(%r13), %rdx\n\
	# Clear %rbp to mark outermost frame obviously even for constructors.\n\
	xorl %ebp, %ebp\n\
	# Call the function to run the initializers.\n\
	call _dl_init_internal@PLT\n\
	# Pass our finalizer function to the user in %rdx, as per ELF ABI.\n\
	leaq _dl_fini(%rip), %rdx\n\
	# And make sure %rdi points to argc stored on the stack.\n\
	movq %r13, %rdi\n\
	# Jump to the user's entry point.\n\
	jmp *%r12\n\
.previous\n\
");

#endif
