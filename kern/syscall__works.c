/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>
#include <kern/sched.h>

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	char *va = (char *)s;
	pte_t *ptep;
	for ( ; va < s + len; va+=PGSIZE){
		ptep = pgdir_walk(curenv->env_pgdir, (void *)va, 0);
		if (ptep && (*ptep & PTE_P) && (*ptep & PTE_U))
			continue;
		env_destroy(curenv);
		return;
	}
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
}

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if (e == curenv)
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
	env_destroy(e);
	return 0;
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
}

// Allocate a new environment.
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
//	-E_NO_MEM on memory exhaustion.

static envid_t
sys_exofork(void)
{
	// Create the new environment with env_alloc(), from kern/env.c.
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	int ret; 
	struct Env **newenv_store;
	struct Env *e;

	//envid_t parent_id = (envid_t) curenv;
	ret =  env_alloc(&e, curenv->env_id); 
	if(ret < 0)
		return ret; 
	e->env_status = ENV_NOT_RUNNABLE;
	//memcopy(&e->env_tf, curenv->env_tf, sizeof(e->env_tf));
	e->env_tf = curenv->env_tf;
	 //memmove(&newenv->env_tf, &curenv->env_tf, sizeof(struct Trapframe));

	e->env_tf.tf_regs.reg_eax = 0;

	return e->env_id;
	//panic("sys_exofork not implemented");
}

// Set envid's env_status to status, which must be ENV_RUNNABLE
// or ENV_NOT_RUNNABLE.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
	// Hint: Use the 'envid2env' function from kern/env.c to translate an
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	
	// LAB 4: Your code here.

	int ret; 
	struct Env *e;

	ret = envid2env(envid, &e, 1);
	if(ret < 0)
		return ret; 

	if ( (status != ENV_NOT_RUNNABLE) && (status != ENV_RUNNABLE))
		return -E_INVAL;

	e->env_status = status;
	return 0;
	//panic("sys_env_set_status not implemented");
}


// Set the page fault upcall for 'envid' by modifying the corresponding struct
// Env's 'env_pgfault_upcall' field.  When 'envid' causes a page fault, the
// kernel will push a fault record onto the exception stack, then branch to
// 'func'.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
// "have permission..." => checkperm需要为1
// 这也是合理的，因为应该是当前进程设置自己的pgfault handler
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e;
	if (envid2env(envid, &e, 1) < 0)
		return -E_BAD_ENV;
	e->env_pgfault_upcall = func;
	return 0;
}

// Allocate a page of memory and map it at 'va' with permission
// 'perm' in the address space of 'envid'.
// The page's contents are set to 0.
// If a page is already mapped at 'va', that page is unmapped as a
// side effect.
//
// perm -- PTE_U | PTE_P must be set, PTE_AVAIL | PTE_W may or may not be set,
//         but no other bits may be set.  See PTE_SYSCALL in inc/mmu.h.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.

static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	// Hint: This function is a wrapper around page_alloc() and
	//   page_insert() from kern/pmap.c.
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here
	int ret; 
	struct PageInfo * pp ;
	struct Env * e;

	ret = envid2env(envid,  &e, 1);
	if(ret < 0)
	
		return ret; 
		
	 if (((unsigned) va >= UTOP) || ( (unsigned)va % PGSIZE))
		return -E_INVAL; 

	perm = PTE_U | PTE_P | perm;
	if ((perm & ~(PTE_U |  PTE_P |  PTE_AVAIL | PTE_W)))
		return -E_INVAL;



	//if (!((perm & PTE_U) && (perm & PTE_P)))
	//	return -E_INVAL;
		
	pp = page_alloc(ALLOC_ZERO);
	if (!pp)
		return -E_NO_MEM;
	ret = page_insert(e->env_pgdir, pp, va, perm);
	

	if(ret < 0)
		{

		page_free(pp);
		return ret; 
		}
		return 0; 
	//memset(va, 0, 4096)

	//panic("sys_page_alloc not implemented");
}


// Map the page of memory at 'srcva' in srcenvid's address space
// at 'dstva' in dstenvid's address space with permission 'perm'.
// Perm has the same restrictions as in sys_page_alloc, except
// that it also must not grant write access to a read-only
// page.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
//		or the caller doesn't have permission to change one of them.
//		言下之意，caller必须对两个都有更改的权限
//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
//		or dstva >= UTOP or dstva is not page-aligned.
//	-E_INVAL is srcva is not mapped in srcenvid's address space.
//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
	// Hint: This function is a wrapper around page_lookup() and
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
int ret; 
struct Env *srce, *dste;
struct PageInfo *pp;
pte_t *pte;

ret = envid2env(srcenvid, &srce, 1);
	if(ret < 0)
		return ret;

ret = envid2env(dstenvid, &dste, 1);
	if(ret < 0)
		return ret; 

 

if (((unsigned) srcva >= UTOP) || ( (unsigned)srcva % PGSIZE)  || ((unsigned)dstva >= UTOP) || ((unsigned)dstva % PGSIZE))
		return -E_INVAL; 

pp= page_lookup(srce->env_pgdir, srcva, &pte);
if (!pp)
		return -E_INVAL;
//perm = PTE_U | PTE_P | perm;
//	if (!(perm & !(PTE_U |  PTE_P |  PTE_AVAIL | PTE_W)))
//		return -E_INVAL;

//if ((perm & PTE_W) && !(*pte & PTE_W) )
//	return -E_INVAL;

ret = page_insert(dste->env_pgdir, pp, dstva,  perm);
if(ret < 0)
	return ret; 
	
return 0; 


	//panic("sys_page_map not implemented");
}

// Unmap the page of memory at 'va' in the address space of 'envid'.
// If no page is mapped, the function silently succeeds.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.


static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
int ret; 
struct Env *e;
struct PageInfo *pp;
pte_t *pte;

ret = envid2env(envid,  &e, 1); 
	if(ret < 0)
		return ret; 
if (((unsigned)va >= UTOP) || ( (unsigned)va % PGSIZE)  )
		return -E_INVAL; 

page_remove(e->env_pgdir, va);

return 0;
	//panic("sys_page_unmap not implemented");
}

// Try to send 'value' to the target env 'envid'.
// If srcva < UTOP, then also send page currently mapped at 'srcva',
// so that receiver gets a duplicate mapping of the same page.
//
// 如果srcva >= UTOP，就只传递value, 而不repmap page, 而不是错误。
//
// The send fails with a return value of -E_IPC_NOT_RECV if the
// target is not blocked, waiting for an IPC.
//
// The send also can fail for the other reasons listed below.
//
// Otherwise, the send succeeds, and the target's ipc fields are
// updated as follows:
//    env_ipc_recving is set to 0 to block future sends;
//    env_ipc_from is set to the sending envid;
//    env_ipc_value is set to the 'value' parameter;
//    env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
// The target environment is marked runnable again, returning 0
// from the paused sys_ipc_recv system call.  (Hint: does the
// sys_ipc_recv function ever actually return?)
//
// If the sender wants to send a page but the receiver isn't asking for one,
// then no page mapping is transferred, but no error occurs.
// The ipc only happens when no errors occur.
//
// reciever是否需要page，是通过env->env_ipc_dstva的值来判断的
//
// Returns 0 on success, < 0 on error.
// Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist.
//		(No need to check permissions.)
//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
//		or another environment managed to send first.
//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
//	-E_INVAL if srcva < UTOP and perm is inappropriate
//		(see sys_page_alloc).
//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
//		address space.
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env *de;
	pte_t *ptep;

	if (envid2env(envid, &de, 0) < 0)
		return -E_BAD_ENV;
	// 不应出现:env_status != ENV_NOT_RUNNABLE, && env_ipc_receving为true的情况
	// 开始由于env_run()中对进程状态修改的条件没写对，导致下面的test为true。从而有可能
	// receiver在sender把信息发送之前就处于RUNNABLE状态，若scheduler先调度receiver, 
	// receiver就没有收到信息。
	if (de->env_status != ENV_NOT_RUNNABLE && de->env_ipc_recving)
		panic("[%x]'s(ptr %p) env status: %x\n", de->env_id, de, de->env_status);
	if (!de->env_ipc_recving)
		return -E_IPC_NOT_RECV;
	// 如果srcva >= UTOP，就只传递value, 而不repmap page, 而不是错误。
	if ((uint32_t)srcva < UTOP){
		if ((uint32_t)srcva % PGSIZE)
			return -E_INVAL;
		if (!((perm & PTE_U) && (perm & PTE_P)))
			return -E_INVAL;
		int pcheck = ~(PTE_U | PTE_P | PTE_W | PTE_AVAIL);
		if (perm & pcheck)
			return -E_INVAL;
		if (!page_lookup(curenv->env_pgdir, srcva, &ptep))
			return -E_INVAL;
		if ((perm & PTE_W) && (*ptep & PTE_W) == 0)
			return -E_INVAL;
		// dstva < UTOP时，receiver才接受page mapping
		if ((uint32_t)de->env_ipc_dstva < UTOP){
			//很多check在ipc_try_send和sys_page_map之间是重复的.这也是为什么
			//sys_page_map()出错了基本上就是-E_NO_MEM. 相同的检查上面都通过了
			if (sys_page_map(0, srcva, envid, de->env_ipc_dstva, perm) < 0)
				return -E_NO_MEM;
		}
	}
	de->env_ipc_recving = false;
	de->env_ipc_value = value;
	de->env_ipc_from = curenv->env_id;
	de->env_ipc_perm =  ((uint32_t)srcva < UTOP && 
			(uint32_t) de->env_ipc_dstva < UTOP) ? perm : 0;
	de->env_status = ENV_RUNNABLE;
	return 0;
}

// Block until a value is ready.  Record that you want to receive
// using the env_ipc_recving and env_ipc_dstva fields of struct Env,
// mark yourself not runnable, and then give up the CPU.
//
// If 'dstva' is < UTOP, then you are willing to receive a page of data.
// 'dstva' is the virtual address at which the sent page should be mapped.
//
// This function only returns on error, but the system call will eventually
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	//cprintf("entering sys_ipc_recv()\n");
	// LAB 4: Your code here.
	if ((uint32_t)dstva < UTOP && (uint32_t)dstva % PGSIZE){
		panic("wrong dstva in sys_ipc_recv()\n");
		return -E_INVAL;
	}
	//不管是否receiver intend接受page，都赋值dstva,让sender根据dstva判断
	//receiver是否要接受page mapping.
	curenv->env_ipc_dstva = dstva;
	curenv->env_ipc_recving = true;
	curenv->env_status = ENV_NOT_RUNNABLE;
	curenv->env_tf.tf_regs.reg_eax = 0;
	sched_yield();
	return 0;
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int retval = 0;
	switch(syscallno){
		case SYS_cputs:
			user_mem_assert(curenv, (void *)a1, a2, PTE_U | PTE_P);
			sys_cputs((char *)a1, a2);
			retval = a2;
			break;
		case SYS_cgetc:
			retval = sys_cgetc();
			break;
		case SYS_getenvid:
			retval = sys_getenvid();
			break;
		case SYS_env_destroy:
			retval = sys_env_destroy(a1);
			break;
		case SYS_yield:
			sys_yield();
			break;
		case SYS_exofork:
			retval = sys_exofork();
			break;
		case SYS_env_set_status:
			retval = sys_env_set_status(a1, a2);
			break;
		case SYS_page_map:
			retval = sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
			break;
		case SYS_page_unmap:
			retval = sys_page_unmap(a1, (void *)a2);
			break;
		case SYS_page_alloc:
			retval = sys_page_alloc(a1, (void *)a2, a3);
			break;
		case SYS_env_set_pgfault_upcall:
			retval = sys_env_set_pgfault_upcall(a1, (void *)a2);
			break;
		case SYS_ipc_recv:
			retval = sys_ipc_recv((void *)a1);
			break;
		case SYS_ipc_try_send:
			retval = sys_ipc_try_send(a1, a2, (void *)a3, a4);
			break;
		default:
			return -E_INVAL; 
	}
	//cprintf("syscall, number %d, retval %d\n", syscallno, retval);
	return retval;
}

