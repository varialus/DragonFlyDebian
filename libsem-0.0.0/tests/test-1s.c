#define _GNU_SOURCE

#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>
#include <error.h>
#include <errno.h>

#define THREADS 500

typedef struct
{
  volatile int chk, no;
  sem_t sem;
} thr_arg;

void *
foo (void *arg)
{
  thr_arg *parg = arg;
  sem_t *sem = &parg->sem;
  volatile int *chk = &parg->chk;
  int err;
  (*chk)++;
  if (parg->chk - 1)
    error (0, ERANGE, "Thread %i: value %i should be 1",
	parg->no, parg->chk);
  err = sem_post (sem);
  if (err)
    error (0, errno, "sem_post");
  return (void *)err;
}

int
main (int argc, char **argv)
{
  int i;
  error_t err;
  pthread_t tid[THREADS];
  thr_arg arg[THREADS];

  for (i = 0; i < THREADS; i ++)
    {
      sem_t *sem = &arg[i].sem;
      arg[i].chk = 0;
      arg[i].no = i + 1;
      err = sem_init (sem, 0, 0);
      if (err)
	error (0, errno, "sem_init");
      err = pthread_create (&tid[i], 0, foo, &arg[i]);
      if (err)
	error (0, errno, "pthread_create");
      err = sem_wait (sem);
      if (err)
	error (0, errno, "sem_wait");
      arg[i].chk--;
      if (arg[i].chk)
        error (0, EGREGIOUS, "Main: Thread %i: value %i should be 0.",
	  arg[i].no, arg[i].chk);

    }

  for (i = THREADS - 1; i >= 0; i --)
    {
      void * ret;
      err = pthread_join (tid[i], &ret);
      if (err)
	error (0, errno, "pthread_join");
      if ((int)ret)
	error (0, EGREGIOUS, "Main: Thread %i: return value %i should be 0", 
          arg[i].no, (int)ret);
    }

  return 0;
}
