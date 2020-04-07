// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	pte_t pte = uvpt[PGNUM(addr)];
	if (!((utf->utf_err & FEC_WR) && (pte & PTE_COW))) {
		cprintf("KUD BIH S TOBOM is write: %d\n", (utf->utf_err & FEC_WR));
		cprintf("KUD BIH S TOBOM is COW: %d\n", (pte & PTE_COW));		
		panic("User space cannot resolve this page fault: %e", utf->utf_err);
	}
	
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(sys_getenvid(), (void *) PFTEMP, PTE_W | PTE_U | PTE_P)) < 0)
		panic("Error in sys_page_alloc: %e", r);
	memcpy((void *) PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
	if ((r = sys_page_map(sys_getenvid(), (void *) PFTEMP, sys_getenvid(),
			      ROUNDDOWN(addr, PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
		panic("Error in sys_page_map: %e", r);
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.

	if ((uvpt[PGNUM(pn*PGSIZE)] & PTE_W) || (uvpt[PGNUM(pn*PGSIZE)] & PTE_COW)) {
		if ((r = sys_page_map(sys_getenvid(), (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE),
				      PTE_COW | (uvpt[PGNUM(pn*PGSIZE)] & (0xfff & ~PTE_W)))) < 0)
			return r;
		if ((r = sys_page_map(sys_getenvid(), (void *) (pn*PGSIZE), sys_getenvid(), (void *) (pn*PGSIZE),
				      PTE_COW | (uvpt[PGNUM(pn*PGSIZE)] & (0xfff & ~PTE_W)))) < 0)
			return r;
	} else {
		// Read-only pages
		if ((r = sys_page_map(sys_getenvid(), (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE),
				      (uvpt[PGNUM(pn*PGSIZE)] & 0xfff))) < 0)
		    return r;
	}
	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
	envid_t newenvid_id = sys_exofork();
	if (newenvid_id < 0)
		panic("Issue creating fork: %e", newenvid_id);
	if (!newenvid_id) {
		// in child environment
		thisenv = &envs[ENVX(sys_getenvid())];
		// set_pgfault_handler(pgfault);				
		return 0;
	}
	for (size_t i = 0; i <= UTOP/1024/1024; i++) {
		if (uvpd[i] & PTE_P) {
			for (size_t j = 0; j < 1024; j++) {
				if (1024*i+j >= UTOP/PGSIZE)
					continue;
				if ((uvpt[1024*i+j] & PTE_P) && 1024*i+j != UXSTACKTOP/PGSIZE-1) {
					int r;
					if ((r = duppage(newenvid_id, 1024*i+j)) < 0)
						panic("Error in duppage: %e", r);
				} else if (1024*i+j == UXSTACKTOP/PGSIZE-1) {
					int r;
					if ((r = sys_page_alloc(newenvid_id, (char *) UXSTACKTOP-PGSIZE, PTE_W | PTE_U | PTE_P)) < 0)
						panic("Error in sys_page_alloc: %e", r);
				}
			}
		}
	}
	int r;
	extern void _pgfault_upcall();
	if ((r = sys_env_set_pgfault_upcall(newenvid_id, _pgfault_upcall)) < 0)
		panic("Error in sys_env_set_pgfault_upcall: %e", r);
	sys_env_set_status(newenvid_id, ENV_RUNNABLE);
	return newenvid_id;
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
