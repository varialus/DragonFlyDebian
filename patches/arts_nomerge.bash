#!/bin/bash -e

cp flow/bufferqueue.h{,.in}
cp mcop/thread.h{,.in}
cat $0 | patch -p1
exit 0

diff -ur arts-1.2.3.old/configure.in.in arts-1.2.3/configure.in.in
--- arts-1.2.3.old/configure.in.in	2004-05-30 14:41:10.000000000 +0200
+++ arts-1.2.3/configure.in.in	2004-08-05 19:19:53.000000000 +0200
@@ -740,4 +740,6 @@
 dnl AC_OUTPUT(artsc/artsdsp)
 dnl AC_OUTPUT(soundserver/artsversion-new.h)
 dnl AC_OUTPUT(flow/gsl/gslconfig.h)
+dnl AC_OUTPUT(flow/bufferqueue.h)
+dnl AC_OUTPUT(mcop/thread.h)
 
diff -ur arts-1.2.3.old/flow/bufferqueue.h.in arts-1.2.3/flow/bufferqueue.h.in
--- arts-1.2.3.old/flow/bufferqueue.h.in	2004-08-05 19:18:09.000000000 +0200
+++ arts-1.2.3/flow/bufferqueue.h.in	2004-08-05 19:19:53.000000000 +0200
@@ -10,6 +10,8 @@
 #ifndef _BUFFERQUEUE_H
 #define _BUFFERQUEUE_H
 
+/* #undef HAVE_SEMAPHORE_H */
+
 #include "thread.h"
 
 #define _DEFAULT_CHUNK_SIZE 4096
@@ -67,27 +69,35 @@
 	ByteBuffer bufs[_MAX_CHUNKS];
 	int rp;
 	int wp;
+#ifdef HAVE_SEMAPHORE_H
 	Arts::Semaphore* sema_produced;
 	Arts::Semaphore* sema_consumed;
+#endif
 
 	void semaReinit() {
+#ifdef HAVE_SEMAPHORE_H
 		delete sema_consumed;
 		delete sema_produced;
 		sema_consumed = new Arts::Semaphore(0, _MAX_CHUNKS);
 		sema_produced = new Arts::Semaphore(0, 0);
+#endif
 	}
 
 
 public:
 	BufferQueue() {
+#ifdef HAVE_SEMAPHORE_H
 		rp = wp = 0;
 		sema_consumed = new Arts::Semaphore(0, _MAX_CHUNKS);
 		sema_produced = new Arts::Semaphore(0, 0);
+#endif
 	}
 
 	~BufferQueue() {
+#ifdef HAVE_SEMAPHORE_H
 		delete sema_consumed;
 		delete sema_produced;
+#endif
 	}
 
 	void write(void* data, int len);
@@ -97,9 +107,30 @@
 	ByteBuffer* waitProduced();
 	void consumed();
 
-	bool isEmpty() const       { return sema_produced->getValue() == 0; }
-	int bufferedChunks() const { return sema_produced->getValue(); }
-	int freeChunks() const     { return sema_consumed->getValue(); }
+	bool isEmpty() const
+	  {
+#ifdef HAVE_SEMAPHORE_H
+	    return sema_produced->getValue() == 0;
+#else
+	    return 0;
+#endif
+	  }
+	int bufferedChunks() const
+	  {
+#ifdef HAVE_SEMAPHORE_H
+	    return sema_produced->getValue();
+#else
+	    return 0;
+#endif
+	  }
+	int freeChunks() const
+	  {
+#ifdef HAVE_SEMAPHORE_H
+	    return sema_consumed->getValue();
+#else
+	    return 0;
+#endif
+	  }
 	int maxChunks() const      { return _MAX_CHUNKS; }
 	int chunkSize() const      { return bufs[0].maxSize(); }
 	void clear()               { rp = wp = 0; semaReinit(); }
@@ -113,34 +144,48 @@
 
 inline void BufferQueue::write(void* data, int len)
 {
+#ifdef HAVE_SEMAPHORE_H
 	sema_consumed->wait();
 	bufs[wp].put(data, len);
 	++wp %= _MAX_CHUNKS;
 	sema_produced->post();
+#endif
 }
 
 inline ByteBuffer* BufferQueue::waitConsumed()
 {
+#ifdef HAVE_SEMAPHORE_H
 	sema_consumed->wait();
 	return &bufs[wp];
+#else
+	return 0;
+#endif
 }
 
 inline void BufferQueue::produced()
 {
+#ifdef HAVE_SEMAPHORE_H
 	++wp %= _MAX_CHUNKS;
 	sema_produced->post();
+#endif
 }
 
 inline ByteBuffer* BufferQueue::waitProduced()
 {
+#ifdef HAVE_SEMAPHORE_H
 	sema_produced->wait();
 	return &bufs[rp];
+#else
+	return 0;
+#endif
 }
 
 inline void BufferQueue::consumed()
 {
+#ifdef HAVE_SEMAPHORE_H
 	++rp %=_MAX_CHUNKS;
 	sema_consumed->post();
+#endif
 }
 
 }
diff -ur arts-1.2.3.old/mcop/thread.h.in arts-1.2.3/mcop/thread.h.in
--- arts-1.2.3.old/mcop/thread.h.in	2004-08-05 19:17:59.000000000 +0200
+++ arts-1.2.3/mcop/thread.h.in	2004-08-05 19:19:53.000000000 +0200
@@ -23,6 +23,8 @@
 #ifndef ARTS_MCOP_THREAD_H
 #define ARTS_MCOP_THREAD_H
 
+/* #undef HAVE_SEMAPHORE_H */
+
 /*
  * BC - Status (2002-03-08): SystemThreads, Thread, Mutex, ThreadCondition,
  * Semaphore
@@ -78,7 +80,9 @@
 	virtual Mutex_impl *createRecMutex_impl() = 0;
 	virtual Thread_impl *createThread_impl(Thread *thread) = 0;
 	virtual ThreadCondition_impl *createThreadCondition_impl() = 0;
+#ifdef HAVE_SEMAPHORE_H
 	virtual Semaphore_impl *createSemaphore_impl(int, int) = 0;
+#endif
 	virtual ~SystemThreads();
 
 	/**
@@ -335,6 +339,7 @@
 	}
 };
 
+#ifdef HAVE_SEMAPHORE_H
 class Semaphore {
 private:
 	Semaphore_impl *impl;
@@ -367,6 +372,7 @@
 		return impl->getValue();
 	}
 };
+#endif /* HAVE_SEMAPHORE_H */
 
 }
 
