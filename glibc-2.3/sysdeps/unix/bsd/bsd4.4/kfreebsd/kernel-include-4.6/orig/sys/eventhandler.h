/*-
 * Copyright (c) 1999 Michael Smith <msmith@freebsd.org>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * $FreeBSD: src/sys/sys/eventhandler.h,v 1.5 2000/01/16 06:11:33 bde Exp $
 */

#include <sys/queue.h>

#ifndef SYS_EVENTHANDLER_H
#define SYS_EVENTHANDLER_H

struct eventhandler_entry 
{
    TAILQ_ENTRY(eventhandler_entry)	ee_link;
    int					ee_priority;
    void				*ee_arg;
};

struct eventhandler_list 
{
    TAILQ_ENTRY(eventhandler_list)	el_link;
    char				*el_name;
    int					el_flags;
#define EHE_INITTED	(1<<0)
    TAILQ_HEAD(,eventhandler_entry)	el_entries;
};

typedef struct eventhandler_entry	*eventhandler_tag;

/* 
 * Fast handler lists require the eventhandler list be present
 * at link time.  They don't allow addition of entries to
 * unknown eventhandler lists, ie. each list must have an 
 * "owner".
 *
 * Fast handler lists must be defined once by the owner 
 * of the eventhandler list, and the declaration must be in 
 * scope at any point the list is manipulated.
 */
#define EVENTHANDLER_FAST_DECLARE(name, type)			\
extern struct eventhandler_list Xeventhandler_list_ ## name ;	\
struct eventhandler_entry_ ## name 				\
{								\
    struct eventhandler_entry	ee;				\
    type		eh_func;				\
};								\
struct __hack

#define EVENTHANDLER_FAST_DEFINE(name, type)				\
struct eventhandler_list Xeventhandler_list_ ## name = { #name };	\
struct __hack

#define EVENTHANDLER_FAST_INVOKE(name, args...)				\
do {									\
    struct eventhandler_list *_el = &Xeventhandler_list_ ## name ;	\
    struct eventhandler_entry *_ep = TAILQ_FIRST(&(_el->el_entries));	\
									\
    while (_ep != NULL) {						\
	((struct eventhandler_entry_ ## name *)_ep)->eh_func(_ep->ee_arg , ## args); \
	_ep = TAILQ_NEXT(_ep, ee_link);					\
    }									\
} while (0)

#define EVENTHANDLER_FAST_REGISTER(name, func, arg, priority) \
    eventhandler_register(Xeventhandler_list_ ## name, #name, func, arg, priority)

#define EVENTHANDLER_FAST_DEREGISTER(name, tag) \
    eventhandler_deregister(Xeventhandler_list ## name, tag)


/*
 * Slow handlerss are entirely dynamic; lists are created
 * when entries are added to them, and thus have no concept of "owner",
 *
 * Slow handlerss need to be declared, but do not need to be defined. The
 * declaration must be in scope wherever the handler is to be invoked.
 */
#define EVENTHANDLER_DECLARE(name, type)	\
struct eventhandler_entry_ ## name 		\
{						\
    struct eventhandler_entry	ee;		\
    type		eh_func;		\
};						\
struct __hack

#define EVENTHANDLER_INVOKE(name, args...)				\
do {									\
    struct eventhandler_list *_el;					\
    struct eventhandler_entry *_ep;					\
									\
    if ((_el = eventhandler_find_list(#name)) != NULL) {		\
	for (_ep = TAILQ_FIRST(&(_el->el_entries));			\
	     _ep != NULL;						\
	     _ep = TAILQ_NEXT(_ep, ee_link)) {				\
	    ((struct eventhandler_entry_ ## name *)_ep)->eh_func(_ep->ee_arg , ## args); \
	}								\
    }									\
} while (0)

#define EVENTHANDLER_REGISTER(name, func, arg, priority) \
    eventhandler_register(NULL, #name, func, arg, priority)

#define EVENTHANDLER_DEREGISTER(name, tag) 		\
do {							\
    struct eventhandler_list *_el;			\
							\
    if ((_el = eventhandler_find_list(#name)) != NULL)	\
	eventhandler_deregister(_el, tag);		\
} while(0)
	

extern eventhandler_tag	eventhandler_register(struct eventhandler_list *list, 
					      char *name,
					      void *func, 
					      void *arg, 
					      int priority);
extern void		eventhandler_deregister(struct eventhandler_list *list,
						eventhandler_tag tag);
extern struct eventhandler_list	*eventhandler_find_list(char *name);

/*
 * Standard system event queues.
 */

/* Shutdown events */
typedef void (*shutdown_fn) __P((void *, int));

#define	SHUTDOWN_PRI_FIRST	0
#define	SHUTDOWN_PRI_DEFAULT	10000
#define	SHUTDOWN_PRI_LAST	20000

EVENTHANDLER_DECLARE(shutdown_pre_sync, shutdown_fn);	/* before fs sync */
EVENTHANDLER_DECLARE(shutdown_post_sync, shutdown_fn);	/* after fs sync */
EVENTHANDLER_DECLARE(shutdown_final, shutdown_fn);

#endif /* SYS_EVENTHANDLER_H */
