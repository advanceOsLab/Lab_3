
#include <inc/lib.h>

void
exit(void)
{
	cprintf(" we are exiting by destroying the env:: lib/exit.c\n");
	sys_env_destroy(0);
}

