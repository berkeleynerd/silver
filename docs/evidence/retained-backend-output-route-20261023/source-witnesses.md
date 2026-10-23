# Backend-route source witnesses

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/server/arraylist.c

### Lines 1–87

```text
/********************************************************************/
/*                                                                  */
/*  The Why3 Verification Platform   /   The Why3 Development Team  */
/*  Copyright 2010-2025 --  Inria - CNRS - Paris-Saclay University  */
/*                                                                  */
/*  This software is distributed under the terms of the GNU Lesser  */
/*  General Public License version 2.1, with the special exception  */
/*  on linking described in file LICENSE.                           */
/********************************************************************/

#include <assert.h>
#include <stdlib.h>
#include "arraylist.h"

#define INVALID_INDEX (-1)

int list_lookup_index(plist l, int key);
void list_resize(plist l);

plist init_list(int capacity) {
  plist result;
  result = (plist) malloc (sizeof(t_list));
  result->capacity = capacity;
  result->len = 0;
  result->key = (int*) malloc(sizeof(int) * capacity);
  result->data = (void**) malloc(sizeof(void*) * capacity);
  return result;
}

bool list_is_empty(plist l) {
  return (l->len == 0);
}

int list_lookup_index(plist l, int key) {
  for (int i = 0; i < l->len; i++) {
    if (l->key[i] == key) {
       return i;
    }
  }
  return INVALID_INDEX;
}

void* list_lookup(plist l, int key) {
  int i = list_lookup_index(l, key);
  if (i == INVALID_INDEX) {
    return NULL;
  } else {
    return l->data[i];
  }
}

void list_remove(plist l, int key) {
  int i = list_lookup_index(l, key);
  if (i != INVALID_INDEX) {
    assert (!list_is_empty(l));
    l->len--;
    l->key[i] = l->key[l->len];
    l->data[i] = l->data[l->len];
  }
}

void free_list(plist l) {
  assert (list_is_empty(l));
  free(l->data);
  free(l->key);
  free(l);
}

void list_resize(plist l) {
  int newcap = l->capacity * 2;
  l->capacity = newcap;
  l->key = (int*) realloc(l->key, sizeof(int) * newcap);
  l->data = (void**) realloc(l->data, sizeof(void*) * newcap);
}

void list_append(plist l, int key, void* elt) {
  if (l->len == l->capacity) {
     list_resize(l);
  }
  l->key[l->len] = key;
  l->data[l->len] = elt;
  l->len++;
}

int list_length(plist l) {
  return l->len;
}
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/server/logging.c

### Lines 1–42

```text
/********************************************************************/
/*                                                                  */
/*  The Why3 Verification Platform   /   The Why3 Development Team  */
/*  Copyright 2010-2025 --  Inria - CNRS - Paris-Saclay University  */
/*                                                                  */
/*  This software is distributed under the terms of the GNU Lesser  */
/*  General Public License version 2.1, with the special exception  */
/*  on linking described in file LICENSE.                           */
/********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "logging.h"
#include "options.h"

FILE* logfile;

void init_logging() {
  if (logging) {
   logfile = fopen("why3server.log", "w");
  }
}

void log_msg(char* fmt, ...) {
  if (logging) {
    va_list va;
    va_start(va, fmt);
    vfprintf(logfile, fmt, va);
    fprintf(logfile, "\n");
    fflush (logfile);
    va_end(va);
  }
}

void logging_shutdown(char* s) {
  if (logging) {
    log_msg("%s",s);
    fclose(logfile);
  }
  exit(1);
}
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/server/options.c

### Lines 1–87

```text
/********************************************************************/
/*                                                                  */
/*  The Why3 Verification Platform   /   The Why3 Development Team  */
/*  Copyright 2010-2025 --  Inria - CNRS - Paris-Saclay University  */
/*                                                                  */
/*  This software is distributed under the terms of the GNU Lesser  */
/*  General Public License version 2.1, with the special exception  */
/*  on linking described in file LICENSE.                           */
/********************************************************************/

#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include "options.h"

int parallel = 1;
/* global data doesn't need null initialization, so none provided here */
char* socketname;
bool logging = false;
bool single_client = false;

void parse_options(int argc, char **argv) {
  static struct option long_options[] = {
    /* These options set a flag. */
    {"socket", required_argument, 0, 's'},
    {"logging", no_argument, 0, 'l'},
    {"single-client", no_argument, 0, 'i'},
    {0, 0, 0, 0}
  };
  while (1) {
     int option_index = 0;
     int c = 0;
     c = getopt_long (argc, argv, "j:s:",
                      long_options, &option_index);
     /* Detect the end of the options. */
     if (c == -1) break;

     switch (c) {
       case 0:
         /* The case where a long option has been detected for --socket should
            be handled like the short option, as a NULL value was given for the
            corresponding flag in long_options. */
         exit (1);

       case 'i':
         single_client = true;
         break;

       case 'j':
         errno = 0;
         parallel = strtol(optarg, NULL, 10);
         if (errno == EINVAL) {
            printf("-j requires a number\n");
            exit(1);
         }
         if (parallel <= 0 ) {
            printf("-j requires a positive number\n");
            exit(1);
         }
         break;

       case 'l':
         logging = true;
         break;

       case 's':
         socketname = optarg;
         break;

       case '?':
         /* getopt_long already printed an error message. */
         exit (1);

       default:
         exit (1);
     }
  }
  if (optind < argc) {
    printf("extra arguments, stopping [opt_index=%d,argc=%d]\n",optind,argc);
    exit(1);
  }
  if (socketname == NULL) {
    printf("need to specify a socket name using --socket\n");
    exit(1);
  }
}
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/server/proc.c

### Lines 1–60

```text
/********************************************************************/
/*                                                                  */
/*  The Why3 Verification Platform   /   The Why3 Development Team  */
/*  Copyright 2010-2025 --  Inria - CNRS - Paris-Saclay University  */
/*                                                                  */
/*  This software is distributed under the terms of the GNU Lesser  */
/*  General Public License version 2.1, with the special exception  */
/*  on linking described in file LICENSE.                           */
/********************************************************************/

#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include "proc.h"
#include "options.h"

// global pointers are initialized with NULL by C semantics
plist processes;

// kill process using os specific routine
void os_kill(pproc p);

void os_kill(pproc p) {
#ifdef _WIN32
  // arbitrarily chosen exit code
  TerminateJobObject(p->job, ERROR_REQUEST_ABORTED);
#else
  kill(-p->id, SIGKILL);
#endif
}

void init_process_list () {
  processes = init_list(parallel);
}

void kill_processes(int key, char *id) {
  for (int i = 0; i < processes->len; i++) {
    pproc p = processes->data[i];
    if (p->client_key == key &&
	(id == NULL || !strcmp(p->task_id, id))) {
      os_kill(p);
    }
  }
}

void free_process(pproc proc) {
#ifdef _WIN32
   CloseHandle(proc->handle);
   CloseHandle(proc->job);
#endif
   free(proc->outfile);
   free(proc->task_id);
   free(proc);
}

void kill_all_processes() {
  for (int i = 0; i < processes->len; i++) {
    os_kill((pproc)processes->data[i]);
  }
}
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/server/queue.c

### Lines 1–76

```text
/********************************************************************/
/*                                                                  */
/*  The Why3 Verification Platform   /   The Why3 Development Team  */
/*  Copyright 2010-2025 --  Inria - CNRS - Paris-Saclay University  */
/*                                                                  */
/*  This software is distributed under the terms of the GNU Lesser  */
/*  General Public License version 2.1, with the special exception  */
/*  on linking described in file LICENSE.                           */
/********************************************************************/

#include <assert.h>
#include <stdlib.h>
#include "queue.h"
#include "string.h"

void simple_push(pqueue q, void* elt);
void resize_queue(pqueue q);

pqueue init_queue(unsigned int capacity) {
  assert (capacity > 0);
  pqueue res = (pqueue) malloc(sizeof(t_queue));
  res->capacity = capacity;
  res->len = 0;
  res->pointer = 0;
  res->data = (void**) malloc(sizeof(void*) * capacity);
  return res;
}

void* queue_pop(pqueue q) {
  void* tmp;
  assert (q->len > 0);
  tmp = q->data[q->pointer];
  q->len--;
  q->pointer = (q->pointer + 1) % q->capacity;
  return tmp;
}

void simple_push(pqueue q, void* elt) {
  q->data[(q->pointer + q->len) % q->capacity] = elt;
  q->len++;
}

void resize_queue(pqueue q) {
  unsigned int old_cap, new_cap, old_p, new_p;
  old_cap = q->capacity;
  old_p = q->pointer;
  new_cap = 2 * old_cap;
  new_p = new_cap - old_cap + old_p;
  q->data = (void**) realloc(q->data, sizeof(void*) * new_cap);
  memcpy(q->data + new_p,
         q->data + old_p,
         sizeof(void*) * (old_cap - old_p));
  q->capacity = new_cap;
  q->pointer = new_p;
}

void queue_push(pqueue q, void* elt) {
  if (q->len == q->capacity) {
    resize_queue(q);
  }
  simple_push(q, elt);
}

bool queue_is_empty(pqueue q) {
  return (q->len == 0);
}

unsigned int queue_length(pqueue q) {
  return (q->len);
}

void free_queue(pqueue q) {
  assert(queue_is_empty (q));
  free(q->data);
  free(q);
}
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/server/readbuf.c

### Lines 1–58

```text
/********************************************************************/
/*                                                                  */
/*  The Why3 Verification Platform   /   The Why3 Development Team  */
/*  Copyright 2010-2025 --  Inria - CNRS - Paris-Saclay University  */
/*                                                                  */
/*  This software is distributed under the terms of the GNU Lesser  */
/*  General Public License version 2.1, with the special exception  */
/*  on linking described in file LICENSE.                           */
/********************************************************************/

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "readbuf.h"

void resize_readbuf(preadbuf b, size_t newcapacity);

preadbuf init_readbuf(size_t capacity) {
  assert (capacity > 0);
  preadbuf buf;
  buf = (preadbuf) malloc(sizeof(t_readbuf));
  buf->capacity = capacity;
  buf->len = 0;
  buf->data = (char*) malloc(sizeof(char) * capacity);
  return buf;
}

void resize_readbuf(preadbuf b, size_t newcapacity) {
  b->data = (char*) realloc(b->data, sizeof(char) * newcapacity);
  b->capacity = newcapacity;
}

char* prepare_read(preadbuf b, size_t size) {
  if (b->len + size > b->capacity) {
     resize_readbuf(b, (b->capacity + size) * 2);
  }
  return b->data + b->len;
}

void have_read(preadbuf b, size_t size) {
  assert(b->capacity >= b->len + size);
  b->len += size;
}

void have_taken(preadbuf b, size_t size) {
  assert (size <= b->len);
  memcpy(b->data, b->data+size, b->len - size);
  b->len -= size;
}

void clear_readbuf(preadbuf b) {
  b->len = 0;
}

void free_readbuf(preadbuf b) {
  free(b->data);
  free(b);
}
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/server/request.c

### Lines 1–191

```text
/********************************************************************/
/*                                                                  */
/*  The Why3 Verification Platform   /   The Why3 Development Team  */
/*  Copyright 2010-2025 --  Inria - CNRS - Paris-Saclay University  */
/*                                                                  */
/*  This software is distributed under the terms of the GNU Lesser  */
/*  General Public License version 2.1, with the special exception  */
/*  on linking described in file LICENSE.                           */
/********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "request.h"
#include "options.h"
#include "logging.h"

// Global pointers are initialized with NULL by C semantics
pqueue queue;

//count the semicolons in <buf>, up to <len>
int count_semicolons(char* buf, int len);

//in <buf>, starting from index <begin> and up to index <len-1>, search for a
//semicolon. If a semicolon is found at index i, copy the substring from
//<begin> to <i-1>, that is, excluding the semicolon, into <result>, which
//will be allocated to contain that much space + a null terminator.
//If no semicolon is found, the part of <buf> starting from <begin> up to <len-1>
//is copied instead, and a null terminator added.
int copy_up_to_semicolon(char* buf, int begin, int len, char** result);

int count_semicolons(char* buf, int len) {
  int cnt = 0;
  for (int i = 0; i < len; i++) {
    if (buf[i] == ';') {
      cnt++;
    }
  }
  return cnt;
}

int copy_up_to_semicolon(char* buf, int begin, int len, char** result) {
  int i;
  for (i = begin; i < len; i++) {
    if (buf[i] == ';') {
      break;
    }
  }
  (*result) = (char*) malloc(sizeof(char) * (i - begin + 1));
  memcpy((*result), buf + begin, i - begin);
  (*result)[i - begin] = '\0';
  if (i == len) {
    return 0;
  } else {
    return i + 1;
  }
}

prequest parse_request(char* str_req, int len, int key) {
  int numargs, semic, parallel_arg;
  int pos = 0;
  prequest req;
  char* tmp;
  bool runstdin = false;

  log_msg("client %d: received query %.*s", key, len, str_req);

  semic = count_semicolons(str_req, len);
  if (semic == 0) {
    return NULL;
  }
  if (semic == 1) {
    //  might be a 'parallel' or a 'interrupt' command
    pos = copy_up_to_semicolon (str_req, pos, len, &tmp);
    if (strncmp(tmp, "parallel", pos) == 0) {
      free(tmp);
      pos = copy_up_to_semicolon (str_req, pos, len, &tmp);
      parallel_arg = atoi(tmp);
      if (parallel_arg >= 1) {
        parallel = parallel_arg;
      }
    }
    else if (strncmp(tmp, "interrupt", pos) == 0) {
      free(tmp);
      req = (prequest) malloc(sizeof(request));
      req->key = key;
      req->req_type = REQ_INTERRUPT;
      pos = copy_up_to_semicolon(str_req, pos, len, &(req->id));
      return req;
    }
    free(tmp);
    return NULL;
  }

  numargs = semic - 4;
  if (numargs < 0) {
    return NULL;
  }
  pos = copy_up_to_semicolon(str_req, pos, len, &tmp);
  if (strncmp(tmp, "run", pos) != 0) {
    if (strncmp(tmp, "runstdin", pos) == 0) {
      runstdin = true;
    } else {
      free(tmp);
      return NULL;
    }
  }
  free(tmp);
  req = (prequest) malloc(sizeof(request));
  req->key = key;
  req->req_type = REQ_RUN;
  req->numargs = numargs;
  req->usestdin = runstdin;
  pos = copy_up_to_semicolon(str_req, pos, len, &(req->id));
  pos = copy_up_to_semicolon(str_req, pos, len, &tmp);
  req->timeout = atoi(tmp);
  free(tmp);
  pos = copy_up_to_semicolon(str_req, pos, len, &tmp);
  req->memlimit = atoi(tmp);
  free(tmp);
  pos = copy_up_to_semicolon(str_req, pos, len, &(req->cmd));
  req->args = (char**)malloc(sizeof(char*) * (numargs));
  for (int i = 0; i < numargs; i++) {
    pos = copy_up_to_semicolon(str_req, pos, len, &(req->args[i]));
  }
  return req;
}

void print_request(prequest r) {
  if (r) {
    switch (r->req_type) {
    case REQ_RUN:
      printf("req_type=REQ_RUN, timeout=%d, memlimit=%u, cmd=%s", r->timeout, r->memlimit, r->cmd);
      for (int i = 0; i < r->numargs; i++) {
        printf(" %s", r->args[i]);
      }
      break;
    case REQ_INTERRUPT:
      printf("req_type=REQ_INTERRUPT, id=%s", r->id);
      break;
    default:
      printf("request.print_request: ill-formed request");
    }
  }
  else {
    printf("<null request>");
  }
}

void free_request(prequest r) {
  if (r) {
    switch (r->req_type) {
    case REQ_RUN:
      free(r->cmd);
      for (int i = 0;i < r->numargs; i++) {
        free(r->args[i]);
      }
      free(r->args);
      break;
    case REQ_INTERRUPT:
      free(r->id);
      break;
    default:
        log_msg("bad argument for request.free_request()");
    }
    free(r);
  }
}

void init_request_queue () {
  queue = init_queue(100);
}

void remove_from_queue(int key, char *id, void callback(prequest)) {
  // inefficient, but what else?
  pqueue tmp = init_queue(queue->capacity);
  while (!queue_is_empty(queue)) {
    prequest r = queue_pop(queue);
    if (r->key != key ||
	(id != NULL && strcmp(r->id,id))) {
      queue_push(tmp, r);
    } else if (callback) {
      callback(r);
    }
  }
  while (!queue_is_empty(tmp)) {
    prequest r = queue_pop(tmp);
    queue_push(queue, r);
  }
  free_queue(tmp);
}
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/server/server-unix.c

### Lines 74–87

```text
void shutdown_with_msg(char* msg) {
  if (server_sock != -1) {
    close(server_sock);
  }
  if (clients != NULL) {
     for (int i = 0; i < list_length(clients); i++) {
       close(((pclient) clients->data[i])->fd);
     }
  }
  kill_all_processes();
  unlink(socketname);
  logging_shutdown(msg);
}

```

### Lines 132–143

```text
int open_temp_file(char* dir, char** outfile) {
  char* template;
  size_t len;
  len = strlen(dir);
  template = (char*) malloc(sizeof(char) * (len + 12));
  strcpy(template, dir);
  strcat(template, "/why3");
  strcat(template, "XXXXXX");
  (*outfile) = template;
  return mkstemp(template);
}

```

### Lines 164–226

```text
void sigterm_handler(int sig) {
  shutdown_with_msg("");
}

void set_sigterm_handler() {
  struct sigaction sa;
  sigemptyset (&sa.sa_mask);
  sa.sa_handler = &sigterm_handler;
  sa.sa_flags = 0;
  if (sigaction(SIGTERM, &sa, NULL) == -1) {
    shutdown_with_msg("error installing signal handler");
  }
  if (sigaction(SIGHUP, &sa, NULL) == -1) {
    shutdown_with_msg("error installing signal handler");
  }
  if (sigaction(SIGINT, &sa, NULL) == -1) {
    shutdown_with_msg("error installing signal handler");
  }
}

// The next two functions implement the "self pipe trick". A pipe is used as
// boolean information whether child processes have terminated. The code is
// "data to read on the pipe" = "child processes have terminated"
static void sigchld_handle(int sig) {
  int saved_errno;
  saved_errno = errno;
  if (write(cpipe[1], "x", 1) == -1 && errno != EAGAIN && errno != EINTR) {
    shutdown_with_msg("error writing to pipe");
  }
  errno = saved_errno;
}

void setup_child_pipe() {
  int flags;
  struct sigaction sa;
  if (pipe(cpipe) == - 1) {
    shutdown_with_msg("error creating pipe");
  }
  flags = fcntl(cpipe[0], F_GETFL);
  if (flags == -1) {
    shutdown_with_msg("error getting flags on pipe");
  }
  flags |= O_NONBLOCK;
  if (fcntl(cpipe[0], F_SETFL, flags) == -1) {
    shutdown_with_msg("error setting flags on pipe");
  }
  flags = fcntl(cpipe[1], F_GETFL);
  if (flags == -1) {
    shutdown_with_msg("error getting flags on pipe");
  }
  flags |= O_NONBLOCK;
  if (fcntl(cpipe[1], F_SETFL, flags) == -1) {
    shutdown_with_msg("error setting flags on pipe");
  }
  sigemptyset(&sa.sa_mask);
  sa.sa_flags = SA_RESTART;
  sa.sa_handler = &sigchld_handle;
  if (sigaction(SIGCHLD, &sa, NULL) == -1) {
    shutdown_with_msg("error installing signal handler");
  }
  add_to_poll_list(cpipe[0], POLLIN);
}

```

### Lines 234–302

```text
void server_init_listening(char* socketname, int parallel) {
  struct sockaddr_un addr;
  int res;
  int cur_dir;
  char *socketname_copy1, *socketname_copy2, *dirn, *filen;

  init_logging();
  // Initialize current_dir pointer. Do that here because we switch the
  // directory temporarily below.
  current_dir = get_cur_dir();

  // Before opening the socket, we switch to the dir of the socket. This
  // workaround is needed because Unix sockets only support relatively short
  // paths (~100 chars depending on the system). We also open a file
  // descriptor to the current dir so that we can switch back afterwards.

  socketname_copy1 = strdup(socketname);
  socketname_copy2 = strdup(socketname);
  dirn = dirname(socketname_copy1);
  filen = basename(socketname_copy2);
  cur_dir = open(".", O_RDONLY);
  if (cur_dir == -1) {
    shutdown_with_msg("error when opening current directory");
  }
  res = chdir(dirn);
  if (res == -1) {
    shutdown_with_msg("error when switching to socket directory");
  }

  init_request_queue();
  clients = init_list(parallel);
  addr.sun_family = AF_UNIX;
  poll_len = 2 + parallel;
  poll_list = (struct pollfd*) malloc(sizeof(struct pollfd) * poll_len);
  poll_num = 0;
  if (strlen(filen) + 1 > unix_path_max()) {
    shutdown_with_msg("basename of filename too long");
  }
  memcpy(addr.sun_path, filen, strlen(filen) + 1);
  server_sock = socket(AF_UNIX, SOCK_STREAM, 0);
  res = unlink(filen);
  // we delete the file if present
  if (res == -1 && errno != ENOENT) {
    shutdown_with_msg("error deleting socket");
  }
  res = bind(server_sock, (struct sockaddr*) &addr, sizeof(struct sockaddr_un));
  if (res == -1) {
    shutdown_with_msg("error binding socket");
  }
  res = listen(server_sock, parallel*2);
  if (res == -1) {
    shutdown_with_msg("error listening on socket");
  }
  res = fchdir(cur_dir);
  if (res == -1) {
    shutdown_with_msg("error when switching back to current directory");
  }
  res = close(cur_dir);
  if (res == -1) {
    shutdown_with_msg("error closing descriptor to current dir");
  }
  free(socketname_copy1);
  free(socketname_copy2);
  add_to_poll_list(server_sock, POLLIN);
  init_process_list();
  setup_child_pipe();
  set_sigterm_handler();
}

```

### Lines 313–400

```text
pid_t create_process(char* cmd,
                     int argc,
                     char** argv,
                     bool usestdin,
                     int outfile,
                     int timelimit,
                     unsigned int memlimit) {
  struct rlimit res;
  char** unix_argv;
  int count = argc;
  // in the case of usestdin, the last argument is in fact not passed to
  // execvp, it contains the filename instead
  if (usestdin) {
    count--;
  }
  unix_argv = (char**)malloc(sizeof(char*) * (count + 2));
  unix_argv[0] = cmd;
  unix_argv[count + 1] = NULL;
  for (int i = 0; i < count; i++) {
    unix_argv[i + 1] = argv[i];
  }

  pid_t pid = fork ();
  if (pid == -1) {
      shutdown_with_msg("failed to fork");
  }

  // the server process simply collects the created pid and returns
  if (pid > 0) {
    free(unix_argv);
    return pid;
  }

  // we are now in the child process

  // we create a new process group so that possible (grand)children of the
  // child process can be killed as well

  if (setpgid(0, 0) == -1) {
    fprintf(stdout, "%s: creation of process group failed (%s)\n",
            unix_argv[0], strerror(errno));

    exit(1);
  }

  // we set the resource limits
  if (timelimit > 0) {
    /* set the CPU time limit */
    getrlimit(RLIMIT_CPU,&res);
    res.rlim_cur = timelimit;
    res.rlim_max = timelimit;
    setrlimit(RLIMIT_CPU,&res);
  }

  if (memlimit > 0) {
    /* set the CPU memory limit */
    getrlimit(RLIMIT_AS,&res);
    res.rlim_cur = (rlim_t)memlimit * 1024 * 1024;
    res.rlim_max = (rlim_t)memlimit * 1024 * 1024;
    setrlimit(RLIMIT_AS,&res);
  }

  if (timelimit > 0 || memlimit > 0) {
    /* do not generate core dumps */
    getrlimit(RLIMIT_CORE,&res);
    res.rlim_cur = 0;
    res.rlim_max = 0;
    setrlimit(RLIMIT_CORE,&res);
  }

  if (usestdin) {
    int infile = open(argv[count], O_RDONLY);
    if (infile == -1) { perror("Cannot open the input file"); exit(1); }
    dup2(infile, 0);
  }

  //adapt stdout/stderr
  dup2(outfile, 1);
  dup2(outfile, 2);

  /* execute the command */
  execvp(cmd,unix_argv);
  fprintf(stderr, "%s: exec of '%s' failed (%s)\n",
          unix_argv[0],unix_argv[0],strerror(errno));

  exit(1);
}

```

### Lines 505–535

```text
void run_request (prequest r) {
  char* outfile;
  int out_descr;
  pproc proc;
  pclient client;
  pid_t id;
  assert (r != NULL);

  client = (pclient) list_lookup(clients, r->key);
  if (client == NULL) {
    return;
  }
  out_descr = open_temp_file(current_dir, &outfile);
  id = create_process(r->cmd,
                      r->numargs,
                      r->args,
                      r->usestdin,
                      out_descr,
                      r->timeout,
                      r->memlimit);
  close(out_descr);

  proc = (pproc) malloc(sizeof(t_proc));
  proc->task_id = r->id;
  proc->client_key = r->key;
  proc->id = id;
  proc->outfile = outfile;
  list_append(processes, id, (void*) proc);
  send_started_msg_to_client(client, r->id);
}

```

### Lines 638–690

```text
int main(int argc, char **argv) {
  char ch;
  int res;
  struct pollfd* cur;
  pclient client;
  parse_options(argc, argv);
  server_init_listening(socketname, parallel);
  while (1) {
    schedule_new_jobs();
    poll_list_clean();
    while ((res = poll(poll_list, poll_num, -1)) == -1 && errno == EINTR)
      continue;
    if (res == -1) {
      shutdown_with_msg("call to poll failed");
    }
    for (int i = 0; i < poll_num; i++) {
      cur = (struct pollfd*) poll_list + i;
      if (cur->revents == 0) {
        continue;
      }
      // a child has terminated
      if (cur->fd == cpipe[0]) {
        while ((res = read(cpipe[0], &ch, 1)) == -1 && errno == EINTR)
          continue;
        if (res == -1) {
          shutdown_with_msg("call to read shouldn't fail");
        }
        handle_child_events();
        continue;
      }
      // an incoming client
      if (cur->fd == server_sock) {
        assert (cur->revents == POLLIN);
        server_accept_client();
        continue;
      }

      // a client
      client = (pclient) list_lookup(clients, cur->fd);
      if (client == NULL)
        continue;
      if (cur->revents & POLLERR) {
        close_client(client);
      } else if (cur->revents & POLLOUT) {
        write_to_client(client, cur);
      } else if (cur->revents & POLLIN) {
        read_on_client(client);
      }
    }
  }
}

#endif /* _WIN32 */
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/server/writebuf.c

### Lines 1–80

```text
/********************************************************************/
/*                                                                  */
/*  The Why3 Verification Platform   /   The Why3 Development Team  */
/*  Copyright 2010-2025 --  Inria - CNRS - Paris-Saclay University  */
/*                                                                  */
/*  This software is distributed under the terms of the GNU Lesser  */
/*  General Public License version 2.1, with the special exception  */
/*  on linking described in file LICENSE.                           */
/********************************************************************/

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "writebuf.h"

pwritebuf init_writebuf(int capacity) {
   pwritebuf buf = (pwritebuf) malloc(sizeof(t_writebuf));
   buf->data = NULL;
   buf->len = 0;
   buf->pointer = 0;
   buf->is_writing = false;
   buf->writequeue = init_queue(capacity);
   return buf;
}

char* prepare_write(pwritebuf b, int* size) {
   assert (can_write(b));
   assert (has_write_data(b));
   b->is_writing = true;
   *size = b->len - b->pointer;
   return (b->data + b->pointer);
}

void have_written(pwritebuf b, int size) {
   assert (b->is_writing);
   assert (b->pointer + size <= b->len);
   b->is_writing = false;
   if (b->pointer + size < b->len) {
      b->pointer += size;
   } else {
      free(b->data);
      b->pointer = 0;
      if (!queue_is_empty(b->writequeue)) {
         b->data = queue_pop(b->writequeue);
         b->len = strlen(b->data);
      } else {
         b->data = NULL;
         b->len = 0;
      }
   }
}

bool can_write(pwritebuf b) {
   return (!b->is_writing);
}

bool has_write_data(pwritebuf b) {
   return (b->data != NULL);
}

void push_write_data(pwritebuf b, char* data) {
   if (has_write_data (b)) {
      queue_push(b->writequeue, (void*) data);
   } else {
      b->data = data;
      b->pointer = 0;
      b->len = strlen(data);
   }
}

//delete all data associated with the buffer
void free_writebuf(pwritebuf b) {
   free(b->data);
   while (!queue_is_empty(b->writequeue)) {
      free(queue_pop(b->writequeue));
   }
   free_queue(b->writequeue);
   free(b);
}
```

## docs/evidence/retained-backend-output-route-20261023/gnat-runtime-sources.tar.gz :: adainclude/a-elchha.adb

### Lines 34–161

```text
with System.Standard_Library; use System.Standard_Library;
with System.Soft_Links; use System;

procedure Ada.Exceptions.Last_Chance_Handler
  (Except : Exception_Occurrence)
is
   procedure Unhandled_Terminate;
   pragma No_Return (Unhandled_Terminate);
   pragma Import (C, Unhandled_Terminate, "__gnat_unhandled_terminate");
   --  Perform system dependent shutdown code

   function Exception_Message_Length
     (X : Exception_Occurrence) return Natural;
   pragma Import (Ada, Exception_Message_Length, "__gnat_exception_msg_len");

   procedure Append_Info_Exception_Message
     (X    : Exception_Occurrence;
      Info : in out String;
      Ptr  : in out Natural);
   pragma Import
     (Ada, Append_Info_Exception_Message, "__gnat_append_info_e_msg");

   procedure Append_Info_Untailored_Exception_Information
     (X    : Exception_Occurrence;
      Info : in out String;
      Ptr  : in out Natural);
   pragma Import
     (Ada, Append_Info_Untailored_Exception_Information,
      "__gnat_append_info_u_e_info");

   procedure To_Stderr (S : String);
   pragma Import (Ada, To_Stderr, "__gnat_to_stderr");
   --  Little routine to output string to stderr

   Gnat_Argv : System.Address;
   pragma Import (C, Gnat_Argv, "gnat_argv");

   procedure Fill_Arg (A : System.Address; Arg_Num : Integer);
   pragma Import (C, Fill_Arg, "__gnat_fill_arg");

   function Len_Arg (Arg_Num : Integer) return Integer;
   pragma Import (C, Len_Arg, "__gnat_len_arg");

   Ptr   : Natural := 0;
   Nobuf : String (1 .. 0);

   Nline : constant String := String'(1 => ASCII.LF);
   --  Convenient shortcut

begin
   --  Do not execute any task termination code when shutting down the system.
   --  The Adafinal procedure would execute the task termination routine for
   --  normal termination, but we have already executed the task termination
   --  procedure because of an unhandled exception.

   System.Soft_Links.Task_Termination_Handler :=
     System.Soft_Links.Task_Termination_NT'Access;

   --  We shutdown the runtime now. The rest of the procedure needs to be
   --  careful not to use anything that would require runtime support. In
   --  particular, functions returning strings are banned since the sec stack
   --  is no longer functional. This is particularly important to note for the
   --  Exception_Information output. We used to allow the tailored version to
   --  show up here, which turned out to be a bad idea as it might involve a
   --  traceback decorator the length of which we don't control. Potentially
   --  heavy primary/secondary stack use or dynamic allocations right before
   --  this point are not welcome, moving the output before the finalization
   --  raises order of outputs concerns, and decorators are intended to only
   --  be used with exception traces, which should have been issued already.

   System.Standard_Library.Adafinal;

   --  Print a message only when exception traces are not active

   if Exception_Trace /= RM_Convention then
      null;

   --  Check for special case of raising _ABORT_SIGNAL, which is not
   --  really an exception at all. We recognize this by the fact that
   --  it is the only exception whose name starts with underscore.

   elsif To_Ptr (Except.Id.Full_Name) (1) = '_' then
      To_Stderr (Nline);
      To_Stderr ("Execution terminated by abort of environment task");
      To_Stderr (Nline);

   --  If no tracebacks, we print the unhandled exception in the old style
   --  (i.e. the style used before ZCX was implemented). We do this to
   --  retain compatibility.

   elsif Except.Num_Tracebacks = 0 then
      To_Stderr (Nline);
      To_Stderr ("raised ");
      To_Stderr
        (To_Ptr (Except.Id.Full_Name) (1 .. Except.Id.Name_Length - 1));

      if Exception_Message_Length (Except) /= 0 then
         To_Stderr (" : ");
         Append_Info_Exception_Message (Except, Nobuf, Ptr);
      end if;

      To_Stderr (Nline);

   --  Traceback exists

   else
      To_Stderr (Nline);

      if Gnat_Argv = System.Null_Address then
         To_Stderr ("Execution terminated by unhandled exception");
      else
         declare
            Arg : aliased String (1 .. Len_Arg (0));
         begin
            Fill_Arg (Arg'Address, 0);
            To_Stderr ("Execution of ");
            To_Stderr (Arg);
            To_Stderr (" terminated by unhandled exception");
         end;
      end if;

      To_Stderr (Nline);

      Append_Info_Untailored_Exception_Information (Except, Nobuf, Ptr);
   end if;

   Unhandled_Terminate;
end Ada.Exceptions.Last_Chance_Handler;
```

## docs/evidence/retained-backend-output-route-20261023/gnat-runtime-sources.tar.gz :: adainclude/a-elchha.ads

### Lines 34–39

```text
procedure Ada.Exceptions.Last_Chance_Handler
  (Except :  Exception_Occurrence);
pragma Export (C,
               Last_Chance_Handler,
               "__gnat_last_chance_handler");
pragma No_Return (Last_Chance_Handler);
```

## docs/evidence/retained-backend-output-route-20261023/gnat-runtime-sources.tar.gz :: adainclude/a-except.ads

### Lines 143–145

```text
   Exception_Msg_Max_Length : constant := SP.Default_Exception_Msg_Max_Length;

   ------------------
```

### Lines 244–282

```text
   Max_Tracebacks : constant := 50;
   --  Maximum number of trace backs stored in exception occurrence

   subtype Tracebacks_Array is TBE.Tracebacks_Array (1 .. Max_Tracebacks);
   --  Traceback array stored in exception occurrence

   type Exception_Occurrence is record
      Id : Exception_Id := Null_Id;
      --  Exception_Identity for this exception occurrence

      Machine_Occurrence : System.Address;
      --  The underlying machine occurrence. For GCC, this corresponds to the
      --  _Unwind_Exception structure address.

      Msg_Length : Natural := 0;
      --  Length of message (zero = no message)

      Msg : String (1 .. Exception_Msg_Max_Length);
      --  Characters of message

      Exception_Raised : Boolean := False;
      --  Set to true to indicate that this exception occurrence has actually
      --  been raised. When an exception occurrence is first created, this is
      --  set to False, then when it is processed by Raise_Current_Exception,
      --  it is set to True. If Raise_Current_Exception is used to raise an
      --  exception for which this flag is already True, then it knows that
      --  it is dealing with the reraise case (which is useful to distinguish
      --  for exception tracing purposes).

      Pid : Natural := 0;
      --  Partition_Id for partition raising exception

      Num_Tracebacks : Natural range 0 .. Max_Tracebacks := 0;
      --  Number of traceback entries stored

      Tracebacks : Tracebacks_Array;
      --  Stored tracebacks (in Tracebacks (1 .. Num_Tracebacks))
   end record;

```

## docs/evidence/retained-backend-output-route-20261023/gnat-runtime-sources.tar.gz :: adainclude/a-except.adb

### Lines 1851–1960

```text
   procedure To_Stderr (C : Character) is
      procedure Put_Char_Stderr (C : Integer);
      pragma Import (C, Put_Char_Stderr, "put_char_stderr");
   begin
      Put_Char_Stderr (Character'Pos (C));
   end To_Stderr;

   procedure To_Stderr (S : String) is
   begin
      for J in S'Range loop
         if S (J) /= ASCII.CR then
            To_Stderr (S (J));
         end if;
      end loop;
   end To_Stderr;

   -------------------------
   -- Transfer_Occurrence --
   -------------------------

   procedure Transfer_Occurrence
     (Target : Exception_Occurrence_Access;
      Source : Exception_Occurrence)
   is
   begin
      Save_Occurrence (Target.all, Source);
   end Transfer_Occurrence;

   ------------------------
   -- Triggered_By_Abort --
   ------------------------

   function Triggered_By_Abort return Boolean is
      Ex : constant Exception_Occurrence_Access := Get_Current_Excep.all;
   begin
      return Ex /= null
        and then Exception_Identity (Ex.all) = Standard'Abort_Signal'Identity;
   end Triggered_By_Abort;

   -------------------------
   -- Wide_Exception_Name --
   -------------------------

   WC_Encoding : constant Character;
   pragma Import (C, WC_Encoding, "__gl_wc_encoding");
   --  Encoding method for source, as exported by binder

   function Wide_Exception_Name
     (Id : Exception_Id) return Wide_String
   is
      S : constant String := Exception_Name (Id);
      W : Wide_String (1 .. S'Length);
      L : Natural;
   begin
      String_To_Wide_String
        (S, W, L, Get_WC_Encoding_Method (WC_Encoding));
      return W (1 .. L);
   end Wide_Exception_Name;

   function Wide_Exception_Name
     (X : Exception_Occurrence) return Wide_String
   is
      S : constant String := Exception_Name (X);
      W : Wide_String (1 .. S'Length);
      L : Natural;
   begin
      String_To_Wide_String
        (S, W, L, Get_WC_Encoding_Method (WC_Encoding));
      return W (1 .. L);
   end Wide_Exception_Name;

   ----------------------------
   -- Wide_Wide_Exception_Name --
   -----------------------------

   function Wide_Wide_Exception_Name
     (Id : Exception_Id) return Wide_Wide_String
   is
      S : constant String := Exception_Name (Id);
      W : Wide_Wide_String (1 .. S'Length);
      L : Natural;
   begin
      String_To_Wide_Wide_String
        (S, W, L, Get_WC_Encoding_Method (WC_Encoding));
      return W (1 .. L);
   end Wide_Wide_Exception_Name;

   function Wide_Wide_Exception_Name
     (X : Exception_Occurrence) return Wide_Wide_String
   is
      S : constant String := Exception_Name (X);
      W : Wide_Wide_String (1 .. S'Length);
      L : Natural;
   begin
      String_To_Wide_Wide_String
        (S, W, L, Get_WC_Encoding_Method (WC_Encoding));
      return W (1 .. L);
   end Wide_Wide_Exception_Name;

   ---------
   -- ZZZ --
   ---------

   --  This function gives us the end of the PC range for addresses
   --  within the exception unit itself. We hope that gigi/gcc keeps all the
   --  procedures in their original order.

   procedure ZZZ is null;

end Ada.Exceptions;
```

## docs/evidence/retained-backend-output-route-20261023/gnat-runtime-sources.tar.gz :: adainclude/a-exexda.adb

### Lines 34–744

```text
separate (Ada.Exceptions)
package body Exception_Data is

   --  This unit implements the Exception_Information related services for
   --  both the Ada standard requirements and the GNAT.Exception_Traces
   --  facility. This is also used by the implementation of the stream
   --  attributes of types Exception_Id and Exception_Occurrence.

   --  There are common parts between the contents of Exception_Information
   --  (the regular Ada interface) and Untailored_Exception_Information (used
   --  for streaming, and when there is no symbolic traceback available) The
   --  overall structure is sketched below:

   --
   --                 Untailored_Exception_Information
   --                               |
   --                       +-------+--------+
   --                       |                |
   --                Basic_Exc_Info & Untailored_Exc_Tback
   --                    (B_E_I)         (U_E_TB)

   --           o--
   --  (B_E_I)  |  Exception_Name: <exception name> (as in Exception_Name)
   --           |  Message: <message> (or a null line if no message)
   --           |  PID=nnnn (if nonzero)
   --           o--
   --  (U_E_TB) |  Call stack traceback locations:
   --           |  <0xyyyyyyyy 0xyyyyyyyy ...>
   --           o--

   --                     Exception_Information
   --                               |
   --                    +----------+----------+
   --                    |                     |
   --             Basic_Exc_Info    &      traceback
   --                                          |
   --                              +-----------+------------+
   --                              |                        |
   --                     Untailored_Exc_Tback    Or    Tback_Decorator
   --                     if no decorator set           otherwise

   --  Functions returning String imply secondary stack use, which is a heavy
   --  mechanism requiring run-time support. Besides, some of the routines we
   --  provide here are to be used by the default Last_Chance_Handler, at the
   --  critical point where the runtime is about to be finalized. Since most
   --  of the items we have at hand are of bounded length, we also provide a
   --  procedural interface able to incrementally append the necessary bits to
   --  a preallocated buffer or output them straight to stderr.

   --  The procedural interface is composed of two major sections: a neutral
   --  section for basic types like Address, Character, Natural or String, and
   --  an exception oriented section for the exception names, messages, and
   --  information. This is the Append_Info family of procedures below.

   --  Output to stderr is commanded by passing an empty buffer to update, and
   --  care is taken not to overflow otherwise.

   --------------------------------------------
   -- Procedural Interface - Neutral section --
   --------------------------------------------

   procedure Append_Info_Address
     (A    : Address;
      Info : in out String;
      Ptr  : in out Natural);

   procedure Append_Info_Character
     (C    : Character;
      Info : in out String;
      Ptr  : in out Natural);

   procedure Append_Info_Nat
     (N    : Natural;
      Info : in out String;
      Ptr  : in out Natural);

   procedure Append_Info_NL
     (Info : in out String;
      Ptr  : in out Natural);
   pragma Inline (Append_Info_NL);

   procedure Append_Info_String
     (S    : String;
      Info : in out String;
      Ptr  : in out Natural);

   -------------------------------------------------------
   -- Procedural Interface - Exception oriented section --
   -------------------------------------------------------

   procedure Append_Info_Exception_Name
     (Id   : Exception_Id;
      Info : in out String;
      Ptr  : in out Natural);

   procedure Append_Info_Exception_Name
     (X    : Exception_Occurrence;
      Info : in out String;
      Ptr  : in out Natural);

   procedure Append_Info_Exception_Message
     (X    : Exception_Occurrence;
      Info : in out String;
      Ptr  : in out Natural);

   procedure Append_Info_Basic_Exception_Information
     (X    : Exception_Occurrence;
      Info : in out String;
      Ptr  : in out Natural);

   procedure Append_Info_Untailored_Exception_Traceback
     (X    : Exception_Occurrence;
      Info : in out String;
      Ptr  : in out Natural);

   procedure Append_Info_Untailored_Exception_Information
     (X    : Exception_Occurrence;
      Info : in out String;
      Ptr  : in out Natural);

   --  The "functional" interface to the exception information not involving
   --  a traceback decorator uses preallocated intermediate buffers to avoid
   --  the use of secondary stack. Preallocation requires preliminary length
   --  computation, for which a series of functions are introduced:

   ---------------------------------
   -- Length evaluation utilities --
   ---------------------------------

   function Basic_Exception_Info_Maxlength
     (X : Exception_Occurrence) return Natural;

   function Untailored_Exception_Traceback_Maxlength
     (X : Exception_Occurrence) return Natural;

   function Exception_Info_Maxlength
     (X : Exception_Occurrence) return Natural;

   function Exception_Name_Length
     (Id : Exception_Id) return Natural;

   function Exception_Name_Length
     (X : Exception_Occurrence) return Natural;

   function Exception_Message_Length
     (X : Exception_Occurrence) return Natural;

   --------------------------
   -- Functional Interface --
   --------------------------

   function Untailored_Exception_Traceback
     (X : Exception_Occurrence) return String;
   --  Returns an image of the complete call chain associated with an
   --  exception occurrence in its most basic form, that is as a raw sequence
   --  of hexadecimal addresses.

   function Tailored_Exception_Traceback
     (X : Exception_Occurrence) return String;
   --  Returns an image of the complete call chain associated with an
   --  exception occurrence, either in its basic form if no decorator is
   --  in place, or as formatted by the decorator otherwise.

   -----------------------------------------------------------------------
   -- Services for the default Last_Chance_Handler and the task wrapper --
   -----------------------------------------------------------------------

   pragma Export
     (Ada, Append_Info_Exception_Message, "__gnat_append_info_e_msg");

   pragma Export
     (Ada, Append_Info_Untailored_Exception_Information,
      "__gnat_append_info_u_e_info");

   pragma Export
     (Ada, Exception_Message_Length, "__gnat_exception_msg_len");

   function Get_Executable_Load_Address return System.Address;
   pragma Import (C, Get_Executable_Load_Address,
                  "__gnat_get_executable_load_address");
   --  Get the load address of the executable, or Null_Address if not known

   -------------------------
   -- Append_Info_Address --
   -------------------------

   procedure Append_Info_Address
     (A    : Address;
      Info : in out String;
      Ptr  : in out Natural)
   is
      S : String (1 .. 18);
      P : Natural;
      N : Integer_Address;

      H : constant array (Integer range 0 .. 15) of Character :=
        "0123456789abcdef";
   begin
      P := S'Last;
      N := To_Integer (A);
      loop
         S (P) := H (Integer (N mod 16));
         P := P - 1;
         N := N / 16;
         exit when N = 0;
      end loop;

      S (P - 1) := '0';
      S (P) := 'x';

      Append_Info_String (S (P - 1 .. S'Last), Info, Ptr);
   end Append_Info_Address;

   ---------------------------------------------
   -- Append_Info_Basic_Exception_Information --
   ---------------------------------------------

   --  To ease the maximum length computation, we define and pull out some
   --  string constants:

   BEI_Name_Header : constant String := "raised ";
   BEI_Msg_Header  : constant String := " : ";
   BEI_PID_Header  : constant String := "PID: ";

   procedure Append_Info_Basic_Exception_Information
     (X    : Exception_Occurrence;
      Info : in out String;
      Ptr  : in out Natural)
   is
      Name : String (1 .. Exception_Name_Length (X));
      --  Buffer in which to fetch the exception name, in order to check
      --  whether this is an internal _ABORT_SIGNAL or a regular occurrence.

      Name_Ptr : Natural := Name'First - 1;

   begin
      --  Output exception name and message except for _ABORT_SIGNAL, where
      --  these two lines are omitted.

      Append_Info_Exception_Name (X, Name, Name_Ptr);

      if Name (Name'First) /= '_' then
         Append_Info_String (BEI_Name_Header, Info, Ptr);
         Append_Info_String (Name, Info, Ptr);

         if Exception_Message_Length (X) /= 0 then
            Append_Info_String (BEI_Msg_Header, Info, Ptr);
            Append_Info_Exception_Message  (X, Info, Ptr);
         end if;

         Append_Info_NL (Info, Ptr);
      end if;

      --  Output PID line if nonzero

      if X.Pid /= 0 then
         Append_Info_String (BEI_PID_Header, Info, Ptr);
         Append_Info_Nat (X.Pid, Info, Ptr);
         Append_Info_NL (Info, Ptr);
      end if;
   end Append_Info_Basic_Exception_Information;

   ---------------------------
   -- Append_Info_Character --
   ---------------------------

   procedure Append_Info_Character
     (C    : Character;
      Info : in out String;
      Ptr  : in out Natural)
   is
   begin
      if Info'Length = 0 then
         To_Stderr (C);
      elsif Ptr < Info'Last then
         Ptr := Ptr + 1;
         Info (Ptr) := C;
      end if;
   end Append_Info_Character;

   -----------------------------------
   -- Append_Info_Exception_Message --
   -----------------------------------

   procedure Append_Info_Exception_Message
     (X    : Exception_Occurrence;
      Info : in out String;
      Ptr  : in out Natural)
   is
   begin
      if X.Id = Null_Id then
         raise Constraint_Error;
      end if;

      declare
         Len : constant Natural           := Exception_Message_Length (X);
         Msg : constant String (1 .. Len) := X.Msg (1 .. Len);
      begin
         Append_Info_String (Msg, Info, Ptr);
      end;
   end Append_Info_Exception_Message;

   --------------------------------
   -- Append_Info_Exception_Name --
   --------------------------------

   procedure Append_Info_Exception_Name
     (Id   : Exception_Id;
      Info : in out String;
      Ptr  : in out Natural)
   is
   begin
      if Id = Null_Id then
         raise Constraint_Error;
      end if;

      declare
         Len  : constant Natural           := Exception_Name_Length (Id);
         Name : constant String (1 .. Len) := To_Ptr (Id.Full_Name) (1 .. Len);
      begin
         Append_Info_String (Name, Info, Ptr);
      end;
   end Append_Info_Exception_Name;

   procedure Append_Info_Exception_Name
     (X    : Exception_Occurrence;
      Info : in out String;
      Ptr  : in out Natural)
   is
   begin
      Append_Info_Exception_Name (X.Id, Info, Ptr);
   end Append_Info_Exception_Name;

   ------------------------------
   -- Exception_Info_Maxlength --
   ------------------------------

   function Exception_Info_Maxlength
     (X : Exception_Occurrence) return Natural
   is
   begin
      return
        Basic_Exception_Info_Maxlength (X)
        + Untailored_Exception_Traceback_Maxlength (X);
   end Exception_Info_Maxlength;

   ---------------------
   -- Append_Info_Nat --
   ---------------------

   procedure Append_Info_Nat
     (N    : Natural;
      Info : in out String;
      Ptr  : in out Natural)
   is
   begin
      if N > 9 then
         Append_Info_Nat (N / 10, Info, Ptr);
      end if;

      Append_Info_Character
        (Character'Val (Character'Pos ('0') + N mod 10), Info, Ptr);
   end Append_Info_Nat;

   --------------------
   -- Append_Info_NL --
   --------------------

   procedure Append_Info_NL
     (Info : in out String;
      Ptr  : in out Natural)
   is
   begin
      Append_Info_Character (ASCII.LF, Info, Ptr);
   end Append_Info_NL;

   ------------------------
   -- Append_Info_String --
   ------------------------

   procedure Append_Info_String
     (S    : String;
      Info : in out String;
      Ptr  : in out Natural)
   is
   begin
      if Info'Length = 0 then
         To_Stderr (S);
      else
         declare
            Last : constant Natural :=
              Integer'Min (Ptr + S'Length, Info'Last);
         begin
            Info (Ptr + 1 .. Last) := S;
            Ptr := Last;
         end;
      end if;
   end Append_Info_String;

   --------------------------------------------------
   -- Append_Info_Untailored_Exception_Information --
   --------------------------------------------------

   procedure Append_Info_Untailored_Exception_Information
     (X    : Exception_Occurrence;
      Info : in out String;
      Ptr  : in out Natural)
   is
   begin
      Append_Info_Basic_Exception_Information (X, Info, Ptr);
      Append_Info_Untailored_Exception_Traceback (X, Info, Ptr);
   end Append_Info_Untailored_Exception_Information;

   ------------------------------------------------
   -- Append_Info_Untailored_Exception_Traceback --
   ------------------------------------------------

   --  As for Basic_Exception_Information:

   BETB_Header : constant String := "Call stack traceback locations:";
   LDAD_Header : constant String := "Load address: ";

   procedure Append_Info_Untailored_Exception_Traceback
     (X    : Exception_Occurrence;
      Info : in out String;
      Ptr  : in out Natural)
   is
      Load_Address : Address;

   begin
      if X.Num_Tracebacks = 0 then
         return;
      end if;

      --  The executable load address line

      Load_Address := Get_Executable_Load_Address;

      if Load_Address /= Null_Address then
         Append_Info_String (LDAD_Header, Info, Ptr);
         Append_Info_Address (Load_Address, Info, Ptr);
         Append_Info_NL (Info, Ptr);
      end if;

      --  The traceback lines

      Append_Info_String (BETB_Header, Info, Ptr);
      Append_Info_NL (Info, Ptr);

      for J in 1 .. X.Num_Tracebacks loop
         Append_Info_Address (TBE.PC_For (X.Tracebacks (J)), Info, Ptr);
         exit when J = X.Num_Tracebacks;
         Append_Info_Character (' ', Info, Ptr);
      end loop;

      Append_Info_NL (Info, Ptr);
   end Append_Info_Untailored_Exception_Traceback;

   ------------------------------------
   -- Basic_Exception_Info_Maxlength --
   ------------------------------------

   function Basic_Exception_Info_Maxlength
     (X : Exception_Occurrence) return Natural
   is
   begin
      return
        BEI_Name_Header'Length + Exception_Name_Length (X)
        + BEI_Msg_Header'Length + Exception_Message_Length (X) + 1
        + BEI_PID_Header'Length + 15;
   end Basic_Exception_Info_Maxlength;

   ---------------------------
   -- Exception_Information --
   ---------------------------

   function Exception_Information (X : Exception_Occurrence) return String is
      --  The tailored exception information is the basic information
      --  associated with the tailored call chain backtrace.

      Tback_Info : constant String  := Tailored_Exception_Traceback (X);
      Tback_Len  : constant Natural := Tback_Info'Length;

      Info : String (1 .. Basic_Exception_Info_Maxlength (X) + Tback_Len);
      Ptr  : Natural := Info'First - 1;

   begin
      Append_Info_Basic_Exception_Information (X, Info, Ptr);
      Append_Info_String (Tback_Info, Info, Ptr);
      return Info (Info'First .. Ptr);
   end Exception_Information;

   ------------------------------
   -- Exception_Message_Length --
   ------------------------------

   function Exception_Message_Length
     (X : Exception_Occurrence) return Natural
   is
   begin
      return X.Msg_Length;
   end Exception_Message_Length;

   ---------------------------
   -- Exception_Name_Length --
   ---------------------------

   function Exception_Name_Length (Id : Exception_Id) return Natural is
   begin
      --  What is stored in the internal Name buffer includes a terminating
      --  null character that we never care about.

      return Id.Name_Length - 1;
   end Exception_Name_Length;

   function Exception_Name_Length (X : Exception_Occurrence) return Natural is
   begin
      return Exception_Name_Length (X.Id);
   end Exception_Name_Length;

   -------------------------------
   -- Untailored_Exception_Traceback --
   -------------------------------

   function Untailored_Exception_Traceback
     (X : Exception_Occurrence) return String
   is
      Info : aliased String
                       (1 .. Untailored_Exception_Traceback_Maxlength (X));
      Ptr  : Natural := Info'First - 1;
   begin
      Append_Info_Untailored_Exception_Traceback (X, Info, Ptr);
      return Info (Info'First .. Ptr);
   end Untailored_Exception_Traceback;

   --------------------------------------
   -- Untailored_Exception_Information --
   --------------------------------------

   function Untailored_Exception_Information
     (X : Exception_Occurrence) return String
   is
      Info : String (1 .. Exception_Info_Maxlength (X));
      Ptr  : Natural := Info'First - 1;
   begin
      Append_Info_Untailored_Exception_Information (X, Info, Ptr);
      return Info (Info'First .. Ptr);
   end Untailored_Exception_Information;

   -------------------------
   -- Set_Exception_C_Msg --
   -------------------------

   procedure Set_Exception_C_Msg
     (Excep  : EOA;
      Id     : Exception_Id;
      Msg1   : System.Address;
      Line   : Integer        := 0;
      Column : Integer        := 0;
      Msg2   : System.Address := System.Null_Address)
   is
      Remind : Integer;
      Ptr    : Natural;

      procedure Append_Number (Number : Integer);
      --  Append given number to Excep.Msg

      -------------------
      -- Append_Number --
      -------------------

      procedure Append_Number (Number : Integer) is
         Val  : Integer;
         Size : Integer;

      begin
         if Number <= 0 then
            return;
         end if;

         --  Compute the number of needed characters

         Size := 1;
         Val := Number;
         while Val > 0 loop
            Val := Val / 10;
            Size := Size + 1;
         end loop;

         --  If enough characters are available, put the line number

         if Excep.Msg_Length <= Exception_Msg_Max_Length - Size then
            Excep.Msg (Excep.Msg_Length + 1) := ':';
            Excep.Msg_Length := Excep.Msg_Length + Size;

            Val := Number;
            Size := 0;
            while Val > 0 loop
               Remind := Val rem 10;
               Val := Val / 10;
               Excep.Msg (Excep.Msg_Length - Size) :=
                 Character'Val (Remind + Character'Pos ('0'));
               Size := Size + 1;
            end loop;
         end if;
      end Append_Number;

   --  Start of processing for Set_Exception_C_Msg

   begin
      Excep.Exception_Raised := False;
      Excep.Id               := Id;
      Excep.Num_Tracebacks   := 0;
      Excep.Pid              := Local_Partition_ID;
      Excep.Msg_Length       := 0;

      while To_Ptr (Msg1) (Excep.Msg_Length + 1) /= ASCII.NUL
        and then Excep.Msg_Length < Exception_Msg_Max_Length
      loop
         Excep.Msg_Length := Excep.Msg_Length + 1;
         Excep.Msg (Excep.Msg_Length) := To_Ptr (Msg1) (Excep.Msg_Length);
      end loop;

      Append_Number (Line);
      Append_Number (Column);

      --  Append second message if present

      if Msg2 /= System.Null_Address
        and then Excep.Msg_Length + 1 < Exception_Msg_Max_Length
      then
         Excep.Msg_Length := Excep.Msg_Length + 1;
         Excep.Msg (Excep.Msg_Length) := ' ';

         Ptr := 1;
         while To_Ptr (Msg2) (Ptr) /= ASCII.NUL
           and then Excep.Msg_Length < Exception_Msg_Max_Length
         loop
            Excep.Msg_Length := Excep.Msg_Length + 1;
            Excep.Msg (Excep.Msg_Length) := To_Ptr (Msg2) (Ptr);
            Ptr := Ptr + 1;
         end loop;
      end if;
   end Set_Exception_C_Msg;

   -----------------------
   -- Set_Exception_Msg --
   -----------------------

   procedure Set_Exception_Msg
     (Excep   : EOA;
      Id      : Exception_Id;
      Message : String)
   is
      Len : constant Natural :=
              Natural'Min (Message'Length, Exception_Msg_Max_Length);
      First : constant Integer := Message'First;
   begin
      Excep.Exception_Raised := False;
      Excep.Msg_Length       := Len;
      Excep.Msg (1 .. Len)   := Message (First .. First + Len - 1);
      Excep.Id               := Id;
      Excep.Num_Tracebacks   := 0;
      Excep.Pid              := Local_Partition_ID;
   end Set_Exception_Msg;

   ----------------------------------
   -- Tailored_Exception_Traceback --
   ----------------------------------

   function Tailored_Exception_Traceback
     (X : Exception_Occurrence) return String
   is
      --  We reference the decorator *wrapper* here and not the decorator
      --  itself. The purpose of the local variable Wrapper is to prevent a
      --  potential race condition in the code below. The atomicity of this
      --  assignment is enforced by pragma Atomic in System.Soft_Links.

      --  The potential race condition here, if no local variable was used,
      --  relates to the test upon the wrapper's value and the call, which
      --  are not performed atomically. With the local variable, potential
      --  changes of the wrapper's global value between the test and the
      --  call become inoffensive.

      Wrapper : constant Traceback_Decorator_Wrapper_Call :=
                  Traceback_Decorator_Wrapper;

   begin
      if Wrapper = null then
         return Untailored_Exception_Traceback (X);
      else
         return Wrapper.all (X.Tracebacks'Address, X.Num_Tracebacks);
      end if;
   end Tailored_Exception_Traceback;

   ----------------------------------------------
   -- Untailored_Exception_Traceback_Maxlength --
   ----------------------------------------------

   function Untailored_Exception_Traceback_Maxlength
     (X : Exception_Occurrence) return Natural
   is
      Space_Per_Address : constant := 2 + 16 + 1;
      --  Space for "0x" + HHHHHHHHHHHHHHHH + " "
   begin
      return
        LDAD_Header'Length + Space_Per_Address + BETB_Header'Length + 1 +
          X.Num_Tracebacks * Space_Per_Address + 1;
   end Untailored_Exception_Traceback_Maxlength;

end Exception_Data;
```

## docs/evidence/retained-backend-output-route-20261023/gnat-runtime-sources.tar.gz :: adainclude/a-exextr.adb

### Lines 32–221

```text
with Ada.Unchecked_Conversion;

pragma Warnings (Off);
with Ada.Exceptions.Last_Chance_Handler;
pragma Warnings (On);
--  Bring last chance handler into closure

separate (Ada.Exceptions)
package body Exception_Traces is

   Nline : constant String := String'(1 => ASCII.LF);
   --  Convenient shortcut

   type Exception_Action is access procedure (E : Exception_Occurrence);
   pragma Favor_Top_Level (Exception_Action);

   Global_Action : Exception_Action := null;
   pragma Atomic (Global_Action);
   pragma Export
     (Ada, Global_Action, "__gnat_exception_actions_global_action");
   --  Global action, executed whenever an exception is raised.  Changing the
   --  export name must be coordinated with code in g-excact.adb.

   Global_Unhandled_Action : Exception_Action := null;
   pragma Atomic (Global_Unhandled_Action);
   pragma Export
     (Ada, Global_Unhandled_Action,
      "__gnat_exception_actions_global_unhandled_action");
   --  Global action, executed whenever an unhandled exception is raised.
   --  Changing the export name must be coordinated with code in g-excact.adb.

   Raise_Hook_Initialized : Boolean := False;
   pragma Export
     (Ada, Raise_Hook_Initialized, "__gnat_exception_actions_initialized");

   procedure Last_Chance_Handler (Except : Exception_Occurrence);
   pragma Import (C, Last_Chance_Handler, "__gnat_last_chance_handler");
   pragma No_Return (Last_Chance_Handler);
   --  Users can replace the default version of this routine,
   --  Ada.Exceptions.Last_Chance_Handler.

   function To_Action is new Ada.Unchecked_Conversion
     (Raise_Action, Exception_Action);

   -----------------------
   -- Local Subprograms --
   -----------------------

   procedure Notify_Exception (Excep : EOA; Is_Unhandled : Boolean);
   --  Factorizes the common processing for Notify_Handled_Exception and
   --  Notify_Unhandled_Exception. Is_Unhandled is set to True only in the
   --  latter case because Notify_Handled_Exception may be called for an
   --  actually unhandled occurrence in the Front-End-SJLJ case.

   ----------------------
   -- Notify_Exception --
   ----------------------

   procedure Notify_Exception (Excep : EOA; Is_Unhandled : Boolean) is
      --  Save actions locally to avoid any race condition that would
      --  reset them to null.
      Action           : constant Exception_Action := Global_Action;
      Unhandled_Action : constant Exception_Action := Global_Unhandled_Action;

   begin
      --  Output the exception information required by the Exception_Trace
      --  configuration. Take care not to output information about internal
      --  exceptions.

      if not Excep.Id.Not_Handled_By_Others
        and then
          (Exception_Trace = Every_Raise
            or else
              (Is_Unhandled
                and then
                  (Exception_Trace = Unhandled_Raise
                    or else Exception_Trace = Unhandled_Raise_In_Main)))
      then
         --  Exception trace messages need to be protected when several tasks
         --  can issue them at the same time.

         Lock_Task.all;
         To_Stderr (Nline);

         if Exception_Trace /= Unhandled_Raise_In_Main then
            if Is_Unhandled then
               To_Stderr ("Unhandled ");
            end if;

            To_Stderr ("Exception raised");
            To_Stderr (Nline);
         end if;

         To_Stderr (Exception_Information (Excep.all));
         Unlock_Task.all;
      end if;

      --  Call the user-specific actions
      --  ??? We should presumably look at the reraise status here.

      if Raise_Hook_Initialized
        and then Exception_Data_Ptr (Excep.Id).Raise_Hook /= null
      then
         To_Action (Exception_Data_Ptr (Excep.Id).Raise_Hook) (Excep.all);
      end if;

      if Is_Unhandled and Unhandled_Action /= null then
         Unhandled_Action (Excep.all);
      end if;

      if Action /= null then
         Action (Excep.all);
      end if;
   end Notify_Exception;

   ------------------------------
   -- Notify_Handled_Exception --
   ------------------------------

   procedure Notify_Handled_Exception (Excep : EOA) is
   begin
      Notify_Exception (Excep, Is_Unhandled => False);
   end Notify_Handled_Exception;

   --------------------------------
   -- Notify_Unhandled_Exception --
   --------------------------------

   procedure Notify_Unhandled_Exception (Excep : EOA) is
   begin
      --  Check whether there is any termination handler to be executed for
      --  the environment task, and execute it if needed. Here we handle both
      --  the Abnormal and Unhandled_Exception task termination. Normal
      --  task termination routine is executed elsewhere (either in the
      --  Task_Wrapper or in the Adafinal routine for the environment task).

      Task_Termination_Handler.all (Excep.all);

      Notify_Exception (Excep, Is_Unhandled => True);
      Debug_Unhandled_Exception (SSL.Exception_Data_Ptr (Excep.Id));
   end Notify_Unhandled_Exception;

   -----------------------------------
   -- Unhandled_Exception_Terminate --
   -----------------------------------

   procedure Unhandled_Exception_Terminate (Excep : EOA) is
      Occ : Exception_Occurrence;
      --  This occurrence will be used to display a message after finalization.
      --  It is necessary to save a copy here, or else the designated value
      --  could be overwritten if an exception is raised during finalization
      --  (even if that exception is caught). The occurrence is saved on the
      --  stack to avoid dynamic allocation (if this exception is due to lack
      --  of space in the heap, we therefore avoid a second failure). We assume
      --  that there is enough room on the stack however.

   begin
      Save_Occurrence (Occ, Excep.all);
      Last_Chance_Handler (Occ);
   end Unhandled_Exception_Terminate;

   ------------------------------------
   -- Handling GNAT.Exception_Traces --
   ------------------------------------

   --  The bulk of exception traces output is centralized in Notify_Exception,
   --  for both the Handled and Unhandled cases. Extra task specific output is
   --  triggered in the task wrapper for unhandled occurrences in tasks. It is
   --  not performed in this unit to avoid dependencies on the tasking units
   --  here.

   --  We used to rely on the output performed by Unhanded_Exception_Terminate
   --  for the case of an unhandled occurrence in the environment thread, and
   --  the task wrapper was responsible for the whole output in the tasking
   --  case.

   --  This initial scheme had a drawback: the output from Terminate only
   --  occurs after finalization is done, which means possibly never if some
   --  tasks keep hanging around.

   --  The first "presumably obvious" fix consists in moving the Terminate
   --  output before the finalization. It has not been retained because it
   --  introduces annoying changes in output orders when the finalization
   --  itself issues outputs, this also in "regular" cases not resorting to
   --  Exception_Traces.

   --  Today's solution has the advantage of simplicity and better isolates
   --  the Exception_Traces machinery.

end Exception_Traces;
```

## docs/evidence/retained-backend-output-route-20261023/gnat-runtime-sources.tar.gz :: adainclude/s-stalib.ads

### Lines 97–261

```text
   type Exception_Data is record
      Not_Handled_By_Others : aliased Boolean;
      --  Normally set False, indicating that the exception is handled in the
      --  usual way by others (i.e. an others handler handles the exception).
      --  Set True to indicate that this exception is not caught by others
      --  handlers, but must be explicitly named in a handler. This latter
      --  setting is currently used by the Abort_Signal.

      Lang : aliased Character;
      --  A character indicating the language raising the exception.
      --  Set to "A" for exceptions defined by an Ada program.
      --  Set to "B" for imported C++ exceptions with base type matching.
      --  Set to "C" for imported C++ exceptions with exact type matching.

      Name_Length : aliased Natural;
      --  Length of fully expanded name of exception

      Full_Name : aliased System.Address;
      --  Fully expanded name of exception, null terminated
      --  You can use To_Ptr to convert this to a string.

      HTable_Ptr : aliased Exception_Data_Ptr;
      --  Hash table pointer used to link entries together in the hash table
      --  built (by Register_Exception in s-exctab.adb) for converting between
      --  identities and names.

      Foreign_Data : aliased System.Address;
      --  Data for imported exceptions. Not used in the Ada case. This
      --  represents the address of the RTTI for the C++ case.

      Raise_Hook : aliased Raise_Action;
      --  This field can be used to place a "hook" on an exception. If the
      --  value is non-null, then it points to a procedure which is called
      --  whenever the exception is raised. This call occurs immediately,
      --  before any other actions taken by the raise (and in particular
      --  before any unwinding of the stack occurs).
   end record;

   --  Definitions for standard predefined exceptions defined in Standard,

   --  Why are the NULs necessary here, seems like they should not be
   --  required, since Gigi is supposed to add a Nul to each name ???

   Constraint_Error_Name : constant String := "CONSTRAINT_ERROR" & ASCII.NUL;
   Program_Error_Name    : constant String := "PROGRAM_ERROR"    & ASCII.NUL;
   Storage_Error_Name    : constant String := "STORAGE_ERROR"    & ASCII.NUL;
   Tasking_Error_Name    : constant String := "TASKING_ERROR"    & ASCII.NUL;
   Abort_Signal_Name     : constant String := "_ABORT_SIGNAL"    & ASCII.NUL;

   Numeric_Error_Name    : constant String := "NUMERIC_ERROR"    & ASCII.NUL;
   --  This is used only in the Ada 83 case, but it is not worth having a
   --  separate version of s-stalib.ads for use in Ada 83 mode.

   Constraint_Error_Def : aliased Exception_Data :=
     (Not_Handled_By_Others => False,
      Lang                  => 'A',
      Name_Length           => Constraint_Error_Name'Length,
      Full_Name             => Constraint_Error_Name'Address,
      HTable_Ptr            => null,
      Foreign_Data          => Null_Address,
      Raise_Hook            => null);

   Numeric_Error_Def : aliased Exception_Data :=
     (Not_Handled_By_Others => False,
      Lang                  => 'A',
      Name_Length           => Numeric_Error_Name'Length,
      Full_Name             => Numeric_Error_Name'Address,
      HTable_Ptr            => null,
      Foreign_Data          => Null_Address,
      Raise_Hook            => null);

   Program_Error_Def : aliased Exception_Data :=
     (Not_Handled_By_Others => False,
      Lang                  => 'A',
      Name_Length           => Program_Error_Name'Length,
      Full_Name             => Program_Error_Name'Address,
      HTable_Ptr            => null,
      Foreign_Data          => Null_Address,
      Raise_Hook            => null);

   Storage_Error_Def : aliased Exception_Data :=
     (Not_Handled_By_Others => False,
      Lang                  => 'A',
      Name_Length           => Storage_Error_Name'Length,
      Full_Name             => Storage_Error_Name'Address,
      HTable_Ptr            => null,
      Foreign_Data          => Null_Address,
      Raise_Hook            => null);

   Tasking_Error_Def : aliased Exception_Data :=
     (Not_Handled_By_Others => False,
      Lang                  => 'A',
      Name_Length           => Tasking_Error_Name'Length,
      Full_Name             => Tasking_Error_Name'Address,
      HTable_Ptr            => null,
      Foreign_Data          => Null_Address,
      Raise_Hook            => null);

   Abort_Signal_Def : aliased Exception_Data :=
     (Not_Handled_By_Others => True,
      Lang                  => 'A',
      Name_Length           => Abort_Signal_Name'Length,
      Full_Name             => Abort_Signal_Name'Address,
      HTable_Ptr            => null,
      Foreign_Data          => Null_Address,
      Raise_Hook            => null);

   pragma Export (C, Constraint_Error_Def, "constraint_error");
   pragma Export (C, Numeric_Error_Def,    "numeric_error");
   pragma Export (C, Program_Error_Def,    "program_error");
   pragma Export (C, Storage_Error_Def,    "storage_error");
   pragma Export (C, Tasking_Error_Def,    "tasking_error");
   pragma Export (C, Abort_Signal_Def,     "_abort_signal");

   Local_Partition_ID : Natural := 0;
   --  This variable contains the local Partition_ID that will be used when
   --  building exception occurrences. In distributed mode, it will be
   --  set by each partition to the correct value during the elaboration.

   type Exception_Trace_Kind is
     (RM_Convention,
      --  No particular trace is requested, only unhandled exceptions
      --  in the environment task (following the RM) will be printed.
      --  This is the default behavior.

      Every_Raise,
      --  Denotes the initial raise event for any exception occurrence, either
      --  explicit or due to a specific language rule, within the context of a
      --  task or not.

      Unhandled_Raise,
      --  Denotes the raise events corresponding to exceptions for which there
      --  is no user defined handler. This includes unhandled exceptions in
      --  task bodies.

      Unhandled_Raise_In_Main
      --  Same as Unhandled_Raise, except exceptions in task bodies are not
      --  included. Same as RM_Convention, except (1) the message is printed as
      --  soon as the environment task completes due to an unhandled exception
      --  (before awaiting the termination of dependent tasks, and before
      --  library-level finalization), and (2) a symbolic traceback is given
      --  if possible. This is the default behavior if the binder switch -E is
      --  used.
     );
   --  Provide a way to denote different kinds of automatic traces related
   --  to exceptions that can be requested.

   Exception_Trace : Exception_Trace_Kind := RM_Convention;
   pragma Atomic (Exception_Trace);
   --  By default, follow the RM convention

   -----------------
   -- Subprograms --
   -----------------

   procedure Abort_Undefer_Direct;
   pragma Inline (Abort_Undefer_Direct);
   --  A little procedure that just calls Abort_Undefer.all, for use in
   --  clean up procedures, which only permit a simple subprogram name.

   procedure Adafinal;
   --  Performs the Ada Runtime finalization the first time it is invoked.
   --  All subsequent calls are ignored.

end System.Standard_Library;
```

## docs/evidence/retained-backend-output-route-20261023/gnat-runtime-sources.tar.gz :: adainclude/s-stalib.adb

### Lines 56–99

```text
package body System.Standard_Library is

   Runtime_Finalized : Boolean := False;
   --  Set to True when adafinal is called. Used to ensure that subsequent
   --  calls to adafinal after the first have no effect.

   --------------------------
   -- Abort_Undefer_Direct --
   --------------------------

   procedure Abort_Undefer_Direct is
   begin
      System.Soft_Links.Abort_Undefer.all;
   end Abort_Undefer_Direct;

   --------------
   -- Adafinal --
   --------------

   procedure Adafinal is
   begin
      if not Runtime_Finalized then
         Runtime_Finalized := True;
         System.Soft_Links.Adafinal.all;
      end if;
   end Adafinal;

   -----------------
   -- Break_Start --
   -----------------

   procedure Break_Start;
   pragma Export (C, Break_Start, "__gnat_break_start");
   --  This is a dummy procedure that is called at the start of execution.
   --  Its sole purpose is to provide a well defined point for the placement
   --  of a main program breakpoint. This is not used anymore but kept for
   --  bootstrapping issues (still referenced by old gnatbind generated files).

   procedure Break_Start is
   begin
      null;
   end Break_Start;

end System.Standard_Library;
```

## docs/evidence/retained-backend-output-route-20261023/gnat-runtime-sources.tar.gz :: adainclude/s-soflin.ads

### Lines 223–233

```text
   Task_Termination_Handler : EO_Param_Proc := Task_Termination_NT'Access;
   --  Handle task termination routines (task/non-task case as appropriate)

   Finalize_Library_Objects : No_Param_Proc;
   pragma Export (C, Finalize_Library_Objects,
                  "__gnat_finalize_library_objects");
   --  Will be initialized by the binder

   Adafinal : No_Param_Proc := Adafinal_NT'Access;
   --  Performs the finalization of the Ada Runtime

```

## docs/evidence/retained-backend-output-route-20261023/gnat-runtime-sources.tar.gz :: adainclude/s-soflin.adb

### Lines 77–94

```text
   procedure Adafinal_NT is
   begin
      --  Handle normal task termination by the environment task, but only
      --  for the normal task termination. In the case of Abnormal and
      --  Unhandled_Exception they must have been handled before, and the
      --  task termination soft link must have been changed so the task
      --  termination routine is not executed twice.

      Task_Termination_Handler.all (Ada.Exceptions.Null_Occurrence);

      --  Finalize all library-level controlled objects if needed

      if Finalize_Library_Objects /= null then
         Finalize_Library_Objects.all;
      end if;
   end Adafinal_NT;

   ---------------------------
```

### Lines 287–293

```text
   procedure Task_Termination_NT (Excep : EO) is
      pragma Unreferenced (Excep);
   begin
      null;
   end Task_Termination_NT;

   --------------------
```

## docs/evidence/retained-backend-output-route-20261023/gnat-runtime-sources.tar.gz :: adainclude/s-parame.ads

### Lines 178–182

```text
   Default_Exception_Msg_Max_Length : constant := 200;
   --  This constant specifies the default number of characters to allow
   --  in an exception message (200 is minimum required by RM 11.4.1(18)).

end System.Parameters;
```

## docs/evidence/retained-backend-output-route-20261023/gnat-runtime-sources.tar.gz :: adainclude/s-exctra.adb

### Lines 89–124

```text
   procedure Set_Trace_Decorator (Decorator : Traceback_Decorator) is
   begin
      Current_Decorator := Decorator;
      Traceback_Decorator_Wrapper :=
        (if Current_Decorator /= null
         then Decorator_Wrapper'Access else null);
   end Set_Trace_Decorator;

   ---------------
   -- Trace_Off --
   ---------------

   procedure Trace_Off is
   begin
      Exception_Trace := RM_Convention;
   end Trace_Off;

   --------------
   -- Trace_On --
   --------------

   procedure Trace_On (Kind : Trace_Kind) is
   begin
      case Kind is
         when Every_Raise =>
            Exception_Trace := Every_Raise;

         when Unhandled_Raise =>
            Exception_Trace := Unhandled_Raise;

         when Unhandled_Raise_In_Main =>
            Exception_Trace := Unhandled_Raise_In_Main;
      end case;
   end Trace_On;

end System.Exception_Traces;
```

## docs/evidence/retained-backend-output-route-20261023/gnat-runtime-sources.tar.gz :: adainclude/a-excach.adb

### Lines 41–74

```text
separate (Ada.Exceptions)
procedure Call_Chain (Excep : EOA) is

   Exception_Tracebacks : constant Integer;
   pragma Import (C, Exception_Tracebacks, "__gl_exception_tracebacks");
   --  Boolean indicating whether tracebacks should be stored in exception
   --  occurrences.

begin
   if Exception_Tracebacks /= 0 and Excep.Num_Tracebacks = 0 then

      --  If Exception_Tracebacks = 0 then the program was not
      --  compiled for storing tracebacks in exception occurrences
      --  (-bargs -E switch) so that we do not generate them.
      --
      --  If Excep.Num_Tracebacks /= 0 then this is a reraise, no need
      --  to store a new (wrong) chain.

      --  We ask System.Traceback.Call_Chain to skip 3 frames to ensure that
      --  itself, ourselves and our caller are not part of the result. Our
      --  caller is always an exception propagation actor that we don't want
      --  to see, and it may be part of a separate subunit which pulls it
      --  outside the AAA/ZZZ range.

      System.Traceback.Call_Chain
        (Traceback   => Excep.Tracebacks,
         Max_Len     => Max_Tracebacks,
         Len         => Excep.Num_Tracebacks,
         Exclude_Min => AAA'Code_Address,
         Exclude_Max => ZZZ'Code_Address,
         Skip_Frames => 3);
   end if;

end Call_Chain;
```

## docs/evidence/retained-backend-output-route-20261023/gnat-runtime-sources.tar.gz :: adainclude/s-trasym.adb

### Lines 767–787

```text
   Exception_Tracebacks_Symbolic : constant Integer;
   pragma Import
     (C,
      Exception_Tracebacks_Symbolic,
      "__gl_exception_tracebacks_symbolic");
   --  Boolean indicating whether symbolic tracebacks should be generated.

   use Standard_Library;
begin
   --  If this version of this package is available, and the binder switch -Es
   --  was given, then we want to use this as the decorator by default, and we
   --  want to turn on tracing for Unhandled_Raise_In_Main. Note that the user
   --  cannot have already set Exception_Trace, because the runtime library is
   --  elaborated before user-defined code.

   if Exception_Tracebacks_Symbolic /= 0 then
      Exception_Traces.Set_Trace_Decorator (Symbolic_Traceback'Access);
      pragma Assert (Exception_Trace = RM_Convention);
      Exception_Trace := Unhandled_Raise_In_Main;
   end if;
end System.Traceback.Symbolic;
```
