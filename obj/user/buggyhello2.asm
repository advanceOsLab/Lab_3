
obj/user/buggyhello2:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  800039:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800040:	00 
  800041:	a1 00 20 80 00       	mov    0x802000,%eax
  800046:	89 04 24             	mov    %eax,(%esp)
  800049:	e8 4b 00 00 00       	call   800099 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
  800056:	8b 45 08             	mov    0x8(%ebp),%eax
  800059:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005c:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800063:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800066:	85 c0                	test   %eax,%eax
  800068:	7e 08                	jle    800072 <libmain+0x22>
		binaryname = argv[0];
  80006a:	8b 0a                	mov    (%edx),%ecx
  80006c:	89 0d 04 20 80 00    	mov    %ecx,0x802004

	// call user main routine
	umain(argc, argv);
  800072:	89 54 24 04          	mov    %edx,0x4(%esp)
  800076:	89 04 24             	mov    %eax,(%esp)
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 02 00 00 00       	call   800085 <exit>
}
  800083:	c9                   	leave  
  800084:	c3                   	ret    

00800085 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800085:	55                   	push   %ebp
  800086:	89 e5                	mov    %esp,%ebp
  800088:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80008b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800092:	e8 3f 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 28                	jle    800120 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000fc:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800103:	00 
  800104:	c7 44 24 08 b8 0e 80 	movl   $0x800eb8,0x8(%esp)
  80010b:	00 
  80010c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800113:	00 
  800114:	c7 04 24 d5 0e 80 00 	movl   $0x800ed5,(%esp)
  80011b:	e8 27 00 00 00       	call   800147 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	83 c4 2c             	add    $0x2c,%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
  80014c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80014f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800152:	8b 35 04 20 80 00    	mov    0x802004,%esi
  800158:	e8 cb ff ff ff       	call   800128 <sys_getenvid>
  80015d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800160:	89 54 24 10          	mov    %edx,0x10(%esp)
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80016b:	89 74 24 08          	mov    %esi,0x8(%esp)
  80016f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800173:	c7 04 24 e4 0e 80 00 	movl   $0x800ee4,(%esp)
  80017a:	e8 c1 00 00 00       	call   800240 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800183:	8b 45 10             	mov    0x10(%ebp),%eax
  800186:	89 04 24             	mov    %eax,(%esp)
  800189:	e8 51 00 00 00       	call   8001df <vcprintf>
	cprintf("\n");
  80018e:	c7 04 24 ac 0e 80 00 	movl   $0x800eac,(%esp)
  800195:	e8 a6 00 00 00       	call   800240 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019a:	cc                   	int3   
  80019b:	eb fd                	jmp    80019a <_panic+0x53>

0080019d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	53                   	push   %ebx
  8001a1:	83 ec 14             	sub    $0x14,%esp
  8001a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a7:	8b 13                	mov    (%ebx),%edx
  8001a9:	8d 42 01             	lea    0x1(%edx),%eax
  8001ac:	89 03                	mov    %eax,(%ebx)
  8001ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ba:	75 19                	jne    8001d5 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001bc:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c3:	00 
  8001c4:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c7:	89 04 24             	mov    %eax,(%esp)
  8001ca:	e8 ca fe ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  8001cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001d5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d9:	83 c4 14             	add    $0x14,%esp
  8001dc:	5b                   	pop    %ebx
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001e8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ef:	00 00 00 
	b.cnt = 0;
  8001f2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800203:	8b 45 08             	mov    0x8(%ebp),%eax
  800206:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800210:	89 44 24 04          	mov    %eax,0x4(%esp)
  800214:	c7 04 24 9d 01 80 00 	movl   $0x80019d,(%esp)
  80021b:	e8 74 01 00 00       	call   800394 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800220:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800230:	89 04 24             	mov    %eax,(%esp)
  800233:	e8 61 fe ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  800238:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800246:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800249:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024d:	8b 45 08             	mov    0x8(%ebp),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	e8 87 ff ff ff       	call   8001df <vcprintf>
	va_end(ap);

	return cnt;
}
  800258:	c9                   	leave  
  800259:	c3                   	ret    
  80025a:	66 90                	xchg   %ax,%ax
  80025c:	66 90                	xchg   %ax,%ax
  80025e:	66 90                	xchg   %ax,%ax

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 3c             	sub    $0x3c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d7                	mov    %edx,%edi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
  800277:	89 c3                	mov    %eax,%ebx
  800279:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80027c:	8b 45 10             	mov    0x10(%ebp),%eax
  80027f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800282:	b9 00 00 00 00       	mov    $0x0,%ecx
  800287:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80028a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80028d:	39 d9                	cmp    %ebx,%ecx
  80028f:	72 05                	jb     800296 <printnum+0x36>
  800291:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800294:	77 69                	ja     8002ff <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800296:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800299:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80029d:	83 ee 01             	sub    $0x1,%esi
  8002a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002ac:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002b0:	89 c3                	mov    %eax,%ebx
  8002b2:	89 d6                	mov    %edx,%esi
  8002b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002ba:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c5:	89 04 24             	mov    %eax,(%esp)
  8002c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cf:	e8 3c 09 00 00       	call   800c10 <__udivdi3>
  8002d4:	89 d9                	mov    %ebx,%ecx
  8002d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002de:	89 04 24             	mov    %eax,(%esp)
  8002e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e5:	89 fa                	mov    %edi,%edx
  8002e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ea:	e8 71 ff ff ff       	call   800260 <printnum>
  8002ef:	eb 1b                	jmp    80030c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002f8:	89 04 24             	mov    %eax,(%esp)
  8002fb:	ff d3                	call   *%ebx
  8002fd:	eb 03                	jmp    800302 <printnum+0xa2>
  8002ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800302:	83 ee 01             	sub    $0x1,%esi
  800305:	85 f6                	test   %esi,%esi
  800307:	7f e8                	jg     8002f1 <printnum+0x91>
  800309:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800310:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800314:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800317:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80031a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800325:	89 04 24             	mov    %eax,(%esp)
  800328:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	e8 0c 0a 00 00       	call   800d40 <__umoddi3>
  800334:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800338:	0f be 80 08 0f 80 00 	movsbl 0x800f08(%eax),%eax
  80033f:	89 04 24             	mov    %eax,(%esp)
  800342:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800345:	ff d0                	call   *%eax
}
  800347:	83 c4 3c             	add    $0x3c,%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800355:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	3b 50 04             	cmp    0x4(%eax),%edx
  80035e:	73 0a                	jae    80036a <sprintputch+0x1b>
		*b->buf++ = ch;
  800360:	8d 4a 01             	lea    0x1(%edx),%ecx
  800363:	89 08                	mov    %ecx,(%eax)
  800365:	8b 45 08             	mov    0x8(%ebp),%eax
  800368:	88 02                	mov    %al,(%edx)
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800372:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800375:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800379:	8b 45 10             	mov    0x10(%ebp),%eax
  80037c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800380:	8b 45 0c             	mov    0xc(%ebp),%eax
  800383:	89 44 24 04          	mov    %eax,0x4(%esp)
  800387:	8b 45 08             	mov    0x8(%ebp),%eax
  80038a:	89 04 24             	mov    %eax,(%esp)
  80038d:	e8 02 00 00 00       	call   800394 <vprintfmt>
	va_end(ap);
}
  800392:	c9                   	leave  
  800393:	c3                   	ret    

00800394 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
  80039a:	83 ec 3c             	sub    $0x3c,%esp
  80039d:	8b 75 08             	mov    0x8(%ebp),%esi
  8003a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003a3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003a6:	eb 11                	jmp    8003b9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003a8:	85 c0                	test   %eax,%eax
  8003aa:	0f 84 48 04 00 00    	je     8007f8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8003b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b9:	83 c7 01             	add    $0x1,%edi
  8003bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003c0:	83 f8 25             	cmp    $0x25,%eax
  8003c3:	75 e3                	jne    8003a8 <vprintfmt+0x14>
  8003c5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003c9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003d0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e3:	eb 1f                	jmp    800404 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003e8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003ec:	eb 16                	jmp    800404 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003f1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f5:	eb 0d                	jmp    800404 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8d 47 01             	lea    0x1(%edi),%eax
  800407:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040a:	0f b6 17             	movzbl (%edi),%edx
  80040d:	0f b6 c2             	movzbl %dl,%eax
  800410:	83 ea 23             	sub    $0x23,%edx
  800413:	80 fa 55             	cmp    $0x55,%dl
  800416:	0f 87 bf 03 00 00    	ja     8007db <vprintfmt+0x447>
  80041c:	0f b6 d2             	movzbl %dl,%edx
  80041f:	ff 24 95 a0 0f 80 00 	jmp    *0x800fa0(,%edx,4)
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800429:	ba 00 00 00 00       	mov    $0x0,%edx
  80042e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800431:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800434:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800438:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80043b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80043e:	83 f9 09             	cmp    $0x9,%ecx
  800441:	77 3c                	ja     80047f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800443:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800446:	eb e9                	jmp    800431 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8b 00                	mov    (%eax),%eax
  80044d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 40 04             	lea    0x4(%eax),%eax
  800456:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80045c:	eb 27                	jmp    800485 <vprintfmt+0xf1>
  80045e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800461:	85 d2                	test   %edx,%edx
  800463:	b8 00 00 00 00       	mov    $0x0,%eax
  800468:	0f 49 c2             	cmovns %edx,%eax
  80046b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800471:	eb 91                	jmp    800404 <vprintfmt+0x70>
  800473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800476:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047d:	eb 85                	jmp    800404 <vprintfmt+0x70>
  80047f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800482:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800485:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800489:	0f 89 75 ff ff ff    	jns    800404 <vprintfmt+0x70>
  80048f:	e9 63 ff ff ff       	jmp    8003f7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800494:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80049a:	e9 65 ff ff ff       	jmp    800404 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004aa:	8b 00                	mov    (%eax),%eax
  8004ac:	89 04 24             	mov    %eax,(%esp)
  8004af:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b4:	e9 00 ff ff ff       	jmp    8003b9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004bc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004c0:	8b 00                	mov    (%eax),%eax
  8004c2:	99                   	cltd   
  8004c3:	31 d0                	xor    %edx,%eax
  8004c5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c7:	83 f8 07             	cmp    $0x7,%eax
  8004ca:	7f 0b                	jg     8004d7 <vprintfmt+0x143>
  8004cc:	8b 14 85 00 11 80 00 	mov    0x801100(,%eax,4),%edx
  8004d3:	85 d2                	test   %edx,%edx
  8004d5:	75 20                	jne    8004f7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  8004d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004db:	c7 44 24 08 20 0f 80 	movl   $0x800f20,0x8(%esp)
  8004e2:	00 
  8004e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e7:	89 34 24             	mov    %esi,(%esp)
  8004ea:	e8 7d fe ff ff       	call   80036c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f2:	e9 c2 fe ff ff       	jmp    8003b9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004fb:	c7 44 24 08 29 0f 80 	movl   $0x800f29,0x8(%esp)
  800502:	00 
  800503:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800507:	89 34 24             	mov    %esi,(%esp)
  80050a:	e8 5d fe ff ff       	call   80036c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800512:	e9 a2 fe ff ff       	jmp    8003b9 <vprintfmt+0x25>
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80051d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800520:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800523:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800527:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800529:	85 ff                	test   %edi,%edi
  80052b:	b8 19 0f 80 00       	mov    $0x800f19,%eax
  800530:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800533:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800537:	0f 84 92 00 00 00    	je     8005cf <vprintfmt+0x23b>
  80053d:	85 c9                	test   %ecx,%ecx
  80053f:	0f 8e 98 00 00 00    	jle    8005dd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800545:	89 54 24 04          	mov    %edx,0x4(%esp)
  800549:	89 3c 24             	mov    %edi,(%esp)
  80054c:	e8 47 03 00 00       	call   800898 <strnlen>
  800551:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800554:	29 c1                	sub    %eax,%ecx
  800556:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800559:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800560:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800563:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800565:	eb 0f                	jmp    800576 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800567:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80056e:	89 04 24             	mov    %eax,(%esp)
  800571:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800573:	83 ef 01             	sub    $0x1,%edi
  800576:	85 ff                	test   %edi,%edi
  800578:	7f ed                	jg     800567 <vprintfmt+0x1d3>
  80057a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800580:	85 c9                	test   %ecx,%ecx
  800582:	b8 00 00 00 00       	mov    $0x0,%eax
  800587:	0f 49 c1             	cmovns %ecx,%eax
  80058a:	29 c1                	sub    %eax,%ecx
  80058c:	89 75 08             	mov    %esi,0x8(%ebp)
  80058f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800592:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800595:	89 cb                	mov    %ecx,%ebx
  800597:	eb 50                	jmp    8005e9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800599:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059d:	74 1e                	je     8005bd <vprintfmt+0x229>
  80059f:	0f be d2             	movsbl %dl,%edx
  8005a2:	83 ea 20             	sub    $0x20,%edx
  8005a5:	83 fa 5e             	cmp    $0x5e,%edx
  8005a8:	76 13                	jbe    8005bd <vprintfmt+0x229>
					putch('?', putdat);
  8005aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005b8:	ff 55 08             	call   *0x8(%ebp)
  8005bb:	eb 0d                	jmp    8005ca <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8005bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005c0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005c4:	89 04 24             	mov    %eax,(%esp)
  8005c7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ca:	83 eb 01             	sub    $0x1,%ebx
  8005cd:	eb 1a                	jmp    8005e9 <vprintfmt+0x255>
  8005cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005db:	eb 0c                	jmp    8005e9 <vprintfmt+0x255>
  8005dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e9:	83 c7 01             	add    $0x1,%edi
  8005ec:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005f0:	0f be c2             	movsbl %dl,%eax
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	74 25                	je     80061c <vprintfmt+0x288>
  8005f7:	85 f6                	test   %esi,%esi
  8005f9:	78 9e                	js     800599 <vprintfmt+0x205>
  8005fb:	83 ee 01             	sub    $0x1,%esi
  8005fe:	79 99                	jns    800599 <vprintfmt+0x205>
  800600:	89 df                	mov    %ebx,%edi
  800602:	8b 75 08             	mov    0x8(%ebp),%esi
  800605:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800608:	eb 1a                	jmp    800624 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80060a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800615:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800617:	83 ef 01             	sub    $0x1,%edi
  80061a:	eb 08                	jmp    800624 <vprintfmt+0x290>
  80061c:	89 df                	mov    %ebx,%edi
  80061e:	8b 75 08             	mov    0x8(%ebp),%esi
  800621:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800624:	85 ff                	test   %edi,%edi
  800626:	7f e2                	jg     80060a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800628:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80062b:	e9 89 fd ff ff       	jmp    8003b9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800630:	83 f9 01             	cmp    $0x1,%ecx
  800633:	7e 19                	jle    80064e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8b 50 04             	mov    0x4(%eax),%edx
  80063b:	8b 00                	mov    (%eax),%eax
  80063d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800640:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 40 08             	lea    0x8(%eax),%eax
  800649:	89 45 14             	mov    %eax,0x14(%ebp)
  80064c:	eb 38                	jmp    800686 <vprintfmt+0x2f2>
	else if (lflag)
  80064e:	85 c9                	test   %ecx,%ecx
  800650:	74 1b                	je     80066d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8b 00                	mov    (%eax),%eax
  800657:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065a:	89 c1                	mov    %eax,%ecx
  80065c:	c1 f9 1f             	sar    $0x1f,%ecx
  80065f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 40 04             	lea    0x4(%eax),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)
  80066b:	eb 19                	jmp    800686 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8b 00                	mov    (%eax),%eax
  800672:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800675:	89 c1                	mov    %eax,%ecx
  800677:	c1 f9 1f             	sar    $0x1f,%ecx
  80067a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8d 40 04             	lea    0x4(%eax),%eax
  800683:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800686:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800689:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80068c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800691:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800695:	0f 89 04 01 00 00    	jns    80079f <vprintfmt+0x40b>
				putch('-', putdat);
  80069b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006a6:	ff d6                	call   *%esi
				num = -(long long) num;
  8006a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006ae:	f7 da                	neg    %edx
  8006b0:	83 d1 00             	adc    $0x0,%ecx
  8006b3:	f7 d9                	neg    %ecx
  8006b5:	e9 e5 00 00 00       	jmp    80079f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ba:	83 f9 01             	cmp    $0x1,%ecx
  8006bd:	7e 10                	jle    8006cf <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8b 10                	mov    (%eax),%edx
  8006c4:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c7:	8d 40 08             	lea    0x8(%eax),%eax
  8006ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8006cd:	eb 26                	jmp    8006f5 <vprintfmt+0x361>
	else if (lflag)
  8006cf:	85 c9                	test   %ecx,%ecx
  8006d1:	74 12                	je     8006e5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8b 10                	mov    (%eax),%edx
  8006d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006dd:	8d 40 04             	lea    0x4(%eax),%eax
  8006e0:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e3:	eb 10                	jmp    8006f5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8b 10                	mov    (%eax),%edx
  8006ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ef:	8d 40 04             	lea    0x4(%eax),%eax
  8006f2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006f5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8006fa:	e9 a0 00 00 00       	jmp    80079f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800703:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80070a:	ff d6                	call   *%esi
			putch('X', putdat);
  80070c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800710:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800717:	ff d6                	call   *%esi
			putch('X', putdat);
  800719:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800724:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800729:	e9 8b fc ff ff       	jmp    8003b9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80072e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800732:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800739:	ff d6                	call   *%esi
			putch('x', putdat);
  80073b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800746:	ff d6                	call   *%esi
			num = (unsigned long long)
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8b 10                	mov    (%eax),%edx
  80074d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800752:	8d 40 04             	lea    0x4(%eax),%eax
  800755:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800758:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80075d:	eb 40                	jmp    80079f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80075f:	83 f9 01             	cmp    $0x1,%ecx
  800762:	7e 10                	jle    800774 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	8b 10                	mov    (%eax),%edx
  800769:	8b 48 04             	mov    0x4(%eax),%ecx
  80076c:	8d 40 08             	lea    0x8(%eax),%eax
  80076f:	89 45 14             	mov    %eax,0x14(%ebp)
  800772:	eb 26                	jmp    80079a <vprintfmt+0x406>
	else if (lflag)
  800774:	85 c9                	test   %ecx,%ecx
  800776:	74 12                	je     80078a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8b 10                	mov    (%eax),%edx
  80077d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800782:	8d 40 04             	lea    0x4(%eax),%eax
  800785:	89 45 14             	mov    %eax,0x14(%ebp)
  800788:	eb 10                	jmp    80079a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	8b 10                	mov    (%eax),%edx
  80078f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800794:	8d 40 04             	lea    0x4(%eax),%eax
  800797:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80079a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007a3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8007b2:	89 14 24             	mov    %edx,(%esp)
  8007b5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007b9:	89 da                	mov    %ebx,%edx
  8007bb:	89 f0                	mov    %esi,%eax
  8007bd:	e8 9e fa ff ff       	call   800260 <printnum>
			break;
  8007c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c5:	e9 ef fb ff ff       	jmp    8003b9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ce:	89 04 24             	mov    %eax,(%esp)
  8007d1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d6:	e9 de fb ff ff       	jmp    8003b9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007df:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007e6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e8:	eb 03                	jmp    8007ed <vprintfmt+0x459>
  8007ea:	83 ef 01             	sub    $0x1,%edi
  8007ed:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007f1:	75 f7                	jne    8007ea <vprintfmt+0x456>
  8007f3:	e9 c1 fb ff ff       	jmp    8003b9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007f8:	83 c4 3c             	add    $0x3c,%esp
  8007fb:	5b                   	pop    %ebx
  8007fc:	5e                   	pop    %esi
  8007fd:	5f                   	pop    %edi
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	83 ec 28             	sub    $0x28,%esp
  800806:	8b 45 08             	mov    0x8(%ebp),%eax
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800813:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800816:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081d:	85 c0                	test   %eax,%eax
  80081f:	74 30                	je     800851 <vsnprintf+0x51>
  800821:	85 d2                	test   %edx,%edx
  800823:	7e 2c                	jle    800851 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800825:	8b 45 14             	mov    0x14(%ebp),%eax
  800828:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082c:	8b 45 10             	mov    0x10(%ebp),%eax
  80082f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800833:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800836:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083a:	c7 04 24 4f 03 80 00 	movl   $0x80034f,(%esp)
  800841:	e8 4e fb ff ff       	call   800394 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800846:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800849:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084f:	eb 05                	jmp    800856 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800851:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800856:	c9                   	leave  
  800857:	c3                   	ret    

00800858 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80085e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800861:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800865:	8b 45 10             	mov    0x10(%ebp),%eax
  800868:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	89 04 24             	mov    %eax,(%esp)
  800879:	e8 82 ff ff ff       	call   800800 <vsnprintf>
	va_end(ap);

	return rc;
}
  80087e:	c9                   	leave  
  80087f:	c3                   	ret    

00800880 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
  80088b:	eb 03                	jmp    800890 <strlen+0x10>
		n++;
  80088d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800890:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800894:	75 f7                	jne    80088d <strlen+0xd>
		n++;
	return n;
}
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a6:	eb 03                	jmp    8008ab <strnlen+0x13>
		n++;
  8008a8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ab:	39 d0                	cmp    %edx,%eax
  8008ad:	74 06                	je     8008b5 <strnlen+0x1d>
  8008af:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008b3:	75 f3                	jne    8008a8 <strnlen+0x10>
		n++;
	return n;
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c1:	89 c2                	mov    %eax,%edx
  8008c3:	83 c2 01             	add    $0x1,%edx
  8008c6:	83 c1 01             	add    $0x1,%ecx
  8008c9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008cd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d0:	84 db                	test   %bl,%bl
  8008d2:	75 ef                	jne    8008c3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008d4:	5b                   	pop    %ebx
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	83 ec 08             	sub    $0x8,%esp
  8008de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e1:	89 1c 24             	mov    %ebx,(%esp)
  8008e4:	e8 97 ff ff ff       	call   800880 <strlen>
	strcpy(dst + len, src);
  8008e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f0:	01 d8                	add    %ebx,%eax
  8008f2:	89 04 24             	mov    %eax,(%esp)
  8008f5:	e8 bd ff ff ff       	call   8008b7 <strcpy>
	return dst;
}
  8008fa:	89 d8                	mov    %ebx,%eax
  8008fc:	83 c4 08             	add    $0x8,%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	56                   	push   %esi
  800906:	53                   	push   %ebx
  800907:	8b 75 08             	mov    0x8(%ebp),%esi
  80090a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090d:	89 f3                	mov    %esi,%ebx
  80090f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800912:	89 f2                	mov    %esi,%edx
  800914:	eb 0f                	jmp    800925 <strncpy+0x23>
		*dst++ = *src;
  800916:	83 c2 01             	add    $0x1,%edx
  800919:	0f b6 01             	movzbl (%ecx),%eax
  80091c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091f:	80 39 01             	cmpb   $0x1,(%ecx)
  800922:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800925:	39 da                	cmp    %ebx,%edx
  800927:	75 ed                	jne    800916 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800929:	89 f0                	mov    %esi,%eax
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	56                   	push   %esi
  800933:	53                   	push   %ebx
  800934:	8b 75 08             	mov    0x8(%ebp),%esi
  800937:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80093d:	89 f0                	mov    %esi,%eax
  80093f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800943:	85 c9                	test   %ecx,%ecx
  800945:	75 0b                	jne    800952 <strlcpy+0x23>
  800947:	eb 1d                	jmp    800966 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800949:	83 c0 01             	add    $0x1,%eax
  80094c:	83 c2 01             	add    $0x1,%edx
  80094f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800952:	39 d8                	cmp    %ebx,%eax
  800954:	74 0b                	je     800961 <strlcpy+0x32>
  800956:	0f b6 0a             	movzbl (%edx),%ecx
  800959:	84 c9                	test   %cl,%cl
  80095b:	75 ec                	jne    800949 <strlcpy+0x1a>
  80095d:	89 c2                	mov    %eax,%edx
  80095f:	eb 02                	jmp    800963 <strlcpy+0x34>
  800961:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800963:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800966:	29 f0                	sub    %esi,%eax
}
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800972:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800975:	eb 06                	jmp    80097d <strcmp+0x11>
		p++, q++;
  800977:	83 c1 01             	add    $0x1,%ecx
  80097a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80097d:	0f b6 01             	movzbl (%ecx),%eax
  800980:	84 c0                	test   %al,%al
  800982:	74 04                	je     800988 <strcmp+0x1c>
  800984:	3a 02                	cmp    (%edx),%al
  800986:	74 ef                	je     800977 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800988:	0f b6 c0             	movzbl %al,%eax
  80098b:	0f b6 12             	movzbl (%edx),%edx
  80098e:	29 d0                	sub    %edx,%eax
}
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	53                   	push   %ebx
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099c:	89 c3                	mov    %eax,%ebx
  80099e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009a1:	eb 06                	jmp    8009a9 <strncmp+0x17>
		n--, p++, q++;
  8009a3:	83 c0 01             	add    $0x1,%eax
  8009a6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a9:	39 d8                	cmp    %ebx,%eax
  8009ab:	74 15                	je     8009c2 <strncmp+0x30>
  8009ad:	0f b6 08             	movzbl (%eax),%ecx
  8009b0:	84 c9                	test   %cl,%cl
  8009b2:	74 04                	je     8009b8 <strncmp+0x26>
  8009b4:	3a 0a                	cmp    (%edx),%cl
  8009b6:	74 eb                	je     8009a3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b8:	0f b6 00             	movzbl (%eax),%eax
  8009bb:	0f b6 12             	movzbl (%edx),%edx
  8009be:	29 d0                	sub    %edx,%eax
  8009c0:	eb 05                	jmp    8009c7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d4:	eb 07                	jmp    8009dd <strchr+0x13>
		if (*s == c)
  8009d6:	38 ca                	cmp    %cl,%dl
  8009d8:	74 0f                	je     8009e9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009da:	83 c0 01             	add    $0x1,%eax
  8009dd:	0f b6 10             	movzbl (%eax),%edx
  8009e0:	84 d2                	test   %dl,%dl
  8009e2:	75 f2                	jne    8009d6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f5:	eb 07                	jmp    8009fe <strfind+0x13>
		if (*s == c)
  8009f7:	38 ca                	cmp    %cl,%dl
  8009f9:	74 0a                	je     800a05 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009fb:	83 c0 01             	add    $0x1,%eax
  8009fe:	0f b6 10             	movzbl (%eax),%edx
  800a01:	84 d2                	test   %dl,%dl
  800a03:	75 f2                	jne    8009f7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	57                   	push   %edi
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a10:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a13:	85 c9                	test   %ecx,%ecx
  800a15:	74 36                	je     800a4d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a17:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1d:	75 28                	jne    800a47 <memset+0x40>
  800a1f:	f6 c1 03             	test   $0x3,%cl
  800a22:	75 23                	jne    800a47 <memset+0x40>
		c &= 0xFF;
  800a24:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a28:	89 d3                	mov    %edx,%ebx
  800a2a:	c1 e3 08             	shl    $0x8,%ebx
  800a2d:	89 d6                	mov    %edx,%esi
  800a2f:	c1 e6 18             	shl    $0x18,%esi
  800a32:	89 d0                	mov    %edx,%eax
  800a34:	c1 e0 10             	shl    $0x10,%eax
  800a37:	09 f0                	or     %esi,%eax
  800a39:	09 c2                	or     %eax,%edx
  800a3b:	89 d0                	mov    %edx,%eax
  800a3d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a3f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a42:	fc                   	cld    
  800a43:	f3 ab                	rep stos %eax,%es:(%edi)
  800a45:	eb 06                	jmp    800a4d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4a:	fc                   	cld    
  800a4b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4d:	89 f8                	mov    %edi,%eax
  800a4f:	5b                   	pop    %ebx
  800a50:	5e                   	pop    %esi
  800a51:	5f                   	pop    %edi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a62:	39 c6                	cmp    %eax,%esi
  800a64:	73 35                	jae    800a9b <memmove+0x47>
  800a66:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a69:	39 d0                	cmp    %edx,%eax
  800a6b:	73 2e                	jae    800a9b <memmove+0x47>
		s += n;
		d += n;
  800a6d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a70:	89 d6                	mov    %edx,%esi
  800a72:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a74:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a7a:	75 13                	jne    800a8f <memmove+0x3b>
  800a7c:	f6 c1 03             	test   $0x3,%cl
  800a7f:	75 0e                	jne    800a8f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a81:	83 ef 04             	sub    $0x4,%edi
  800a84:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a87:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a8a:	fd                   	std    
  800a8b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8d:	eb 09                	jmp    800a98 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a8f:	83 ef 01             	sub    $0x1,%edi
  800a92:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a95:	fd                   	std    
  800a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a98:	fc                   	cld    
  800a99:	eb 1d                	jmp    800ab8 <memmove+0x64>
  800a9b:	89 f2                	mov    %esi,%edx
  800a9d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9f:	f6 c2 03             	test   $0x3,%dl
  800aa2:	75 0f                	jne    800ab3 <memmove+0x5f>
  800aa4:	f6 c1 03             	test   $0x3,%cl
  800aa7:	75 0a                	jne    800ab3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aa9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800aac:	89 c7                	mov    %eax,%edi
  800aae:	fc                   	cld    
  800aaf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab1:	eb 05                	jmp    800ab8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ab3:	89 c7                	mov    %eax,%edi
  800ab5:	fc                   	cld    
  800ab6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ac2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad3:	89 04 24             	mov    %eax,(%esp)
  800ad6:	e8 79 ff ff ff       	call   800a54 <memmove>
}
  800adb:	c9                   	leave  
  800adc:	c3                   	ret    

00800add <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
  800ae2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae8:	89 d6                	mov    %edx,%esi
  800aea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aed:	eb 1a                	jmp    800b09 <memcmp+0x2c>
		if (*s1 != *s2)
  800aef:	0f b6 02             	movzbl (%edx),%eax
  800af2:	0f b6 19             	movzbl (%ecx),%ebx
  800af5:	38 d8                	cmp    %bl,%al
  800af7:	74 0a                	je     800b03 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800af9:	0f b6 c0             	movzbl %al,%eax
  800afc:	0f b6 db             	movzbl %bl,%ebx
  800aff:	29 d8                	sub    %ebx,%eax
  800b01:	eb 0f                	jmp    800b12 <memcmp+0x35>
		s1++, s2++;
  800b03:	83 c2 01             	add    $0x1,%edx
  800b06:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b09:	39 f2                	cmp    %esi,%edx
  800b0b:	75 e2                	jne    800aef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b1f:	89 c2                	mov    %eax,%edx
  800b21:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b24:	eb 07                	jmp    800b2d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b26:	38 08                	cmp    %cl,(%eax)
  800b28:	74 07                	je     800b31 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b2a:	83 c0 01             	add    $0x1,%eax
  800b2d:	39 d0                	cmp    %edx,%eax
  800b2f:	72 f5                	jb     800b26 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
  800b39:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3f:	eb 03                	jmp    800b44 <strtol+0x11>
		s++;
  800b41:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b44:	0f b6 0a             	movzbl (%edx),%ecx
  800b47:	80 f9 09             	cmp    $0x9,%cl
  800b4a:	74 f5                	je     800b41 <strtol+0xe>
  800b4c:	80 f9 20             	cmp    $0x20,%cl
  800b4f:	74 f0                	je     800b41 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b51:	80 f9 2b             	cmp    $0x2b,%cl
  800b54:	75 0a                	jne    800b60 <strtol+0x2d>
		s++;
  800b56:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b59:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5e:	eb 11                	jmp    800b71 <strtol+0x3e>
  800b60:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b65:	80 f9 2d             	cmp    $0x2d,%cl
  800b68:	75 07                	jne    800b71 <strtol+0x3e>
		s++, neg = 1;
  800b6a:	8d 52 01             	lea    0x1(%edx),%edx
  800b6d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b71:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b76:	75 15                	jne    800b8d <strtol+0x5a>
  800b78:	80 3a 30             	cmpb   $0x30,(%edx)
  800b7b:	75 10                	jne    800b8d <strtol+0x5a>
  800b7d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b81:	75 0a                	jne    800b8d <strtol+0x5a>
		s += 2, base = 16;
  800b83:	83 c2 02             	add    $0x2,%edx
  800b86:	b8 10 00 00 00       	mov    $0x10,%eax
  800b8b:	eb 10                	jmp    800b9d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b8d:	85 c0                	test   %eax,%eax
  800b8f:	75 0c                	jne    800b9d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b91:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b93:	80 3a 30             	cmpb   $0x30,(%edx)
  800b96:	75 05                	jne    800b9d <strtol+0x6a>
		s++, base = 8;
  800b98:	83 c2 01             	add    $0x1,%edx
  800b9b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ba5:	0f b6 0a             	movzbl (%edx),%ecx
  800ba8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bab:	89 f0                	mov    %esi,%eax
  800bad:	3c 09                	cmp    $0x9,%al
  800baf:	77 08                	ja     800bb9 <strtol+0x86>
			dig = *s - '0';
  800bb1:	0f be c9             	movsbl %cl,%ecx
  800bb4:	83 e9 30             	sub    $0x30,%ecx
  800bb7:	eb 20                	jmp    800bd9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800bb9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bbc:	89 f0                	mov    %esi,%eax
  800bbe:	3c 19                	cmp    $0x19,%al
  800bc0:	77 08                	ja     800bca <strtol+0x97>
			dig = *s - 'a' + 10;
  800bc2:	0f be c9             	movsbl %cl,%ecx
  800bc5:	83 e9 57             	sub    $0x57,%ecx
  800bc8:	eb 0f                	jmp    800bd9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800bca:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bcd:	89 f0                	mov    %esi,%eax
  800bcf:	3c 19                	cmp    $0x19,%al
  800bd1:	77 16                	ja     800be9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800bd3:	0f be c9             	movsbl %cl,%ecx
  800bd6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bd9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bdc:	7d 0f                	jge    800bed <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800bde:	83 c2 01             	add    $0x1,%edx
  800be1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800be5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800be7:	eb bc                	jmp    800ba5 <strtol+0x72>
  800be9:	89 d8                	mov    %ebx,%eax
  800beb:	eb 02                	jmp    800bef <strtol+0xbc>
  800bed:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800bef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf3:	74 05                	je     800bfa <strtol+0xc7>
		*endptr = (char *) s;
  800bf5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bfa:	f7 d8                	neg    %eax
  800bfc:	85 ff                	test   %edi,%edi
  800bfe:	0f 44 c3             	cmove  %ebx,%eax
}
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    
  800c06:	66 90                	xchg   %ax,%ax
  800c08:	66 90                	xchg   %ax,%ax
  800c0a:	66 90                	xchg   %ax,%ax
  800c0c:	66 90                	xchg   %ax,%ax
  800c0e:	66 90                	xchg   %ax,%ax

00800c10 <__udivdi3>:
  800c10:	55                   	push   %ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	83 ec 0c             	sub    $0xc,%esp
  800c16:	8b 44 24 28          	mov    0x28(%esp),%eax
  800c1a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800c1e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800c22:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800c26:	85 c0                	test   %eax,%eax
  800c28:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c2c:	89 ea                	mov    %ebp,%edx
  800c2e:	89 0c 24             	mov    %ecx,(%esp)
  800c31:	75 2d                	jne    800c60 <__udivdi3+0x50>
  800c33:	39 e9                	cmp    %ebp,%ecx
  800c35:	77 61                	ja     800c98 <__udivdi3+0x88>
  800c37:	85 c9                	test   %ecx,%ecx
  800c39:	89 ce                	mov    %ecx,%esi
  800c3b:	75 0b                	jne    800c48 <__udivdi3+0x38>
  800c3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c42:	31 d2                	xor    %edx,%edx
  800c44:	f7 f1                	div    %ecx
  800c46:	89 c6                	mov    %eax,%esi
  800c48:	31 d2                	xor    %edx,%edx
  800c4a:	89 e8                	mov    %ebp,%eax
  800c4c:	f7 f6                	div    %esi
  800c4e:	89 c5                	mov    %eax,%ebp
  800c50:	89 f8                	mov    %edi,%eax
  800c52:	f7 f6                	div    %esi
  800c54:	89 ea                	mov    %ebp,%edx
  800c56:	83 c4 0c             	add    $0xc,%esp
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    
  800c5d:	8d 76 00             	lea    0x0(%esi),%esi
  800c60:	39 e8                	cmp    %ebp,%eax
  800c62:	77 24                	ja     800c88 <__udivdi3+0x78>
  800c64:	0f bd e8             	bsr    %eax,%ebp
  800c67:	83 f5 1f             	xor    $0x1f,%ebp
  800c6a:	75 3c                	jne    800ca8 <__udivdi3+0x98>
  800c6c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c70:	39 34 24             	cmp    %esi,(%esp)
  800c73:	0f 86 9f 00 00 00    	jbe    800d18 <__udivdi3+0x108>
  800c79:	39 d0                	cmp    %edx,%eax
  800c7b:	0f 82 97 00 00 00    	jb     800d18 <__udivdi3+0x108>
  800c81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c88:	31 d2                	xor    %edx,%edx
  800c8a:	31 c0                	xor    %eax,%eax
  800c8c:	83 c4 0c             	add    $0xc,%esp
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    
  800c93:	90                   	nop
  800c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c98:	89 f8                	mov    %edi,%eax
  800c9a:	f7 f1                	div    %ecx
  800c9c:	31 d2                	xor    %edx,%edx
  800c9e:	83 c4 0c             	add    $0xc,%esp
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    
  800ca5:	8d 76 00             	lea    0x0(%esi),%esi
  800ca8:	89 e9                	mov    %ebp,%ecx
  800caa:	8b 3c 24             	mov    (%esp),%edi
  800cad:	d3 e0                	shl    %cl,%eax
  800caf:	89 c6                	mov    %eax,%esi
  800cb1:	b8 20 00 00 00       	mov    $0x20,%eax
  800cb6:	29 e8                	sub    %ebp,%eax
  800cb8:	89 c1                	mov    %eax,%ecx
  800cba:	d3 ef                	shr    %cl,%edi
  800cbc:	89 e9                	mov    %ebp,%ecx
  800cbe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cc2:	8b 3c 24             	mov    (%esp),%edi
  800cc5:	09 74 24 08          	or     %esi,0x8(%esp)
  800cc9:	89 d6                	mov    %edx,%esi
  800ccb:	d3 e7                	shl    %cl,%edi
  800ccd:	89 c1                	mov    %eax,%ecx
  800ccf:	89 3c 24             	mov    %edi,(%esp)
  800cd2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cd6:	d3 ee                	shr    %cl,%esi
  800cd8:	89 e9                	mov    %ebp,%ecx
  800cda:	d3 e2                	shl    %cl,%edx
  800cdc:	89 c1                	mov    %eax,%ecx
  800cde:	d3 ef                	shr    %cl,%edi
  800ce0:	09 d7                	or     %edx,%edi
  800ce2:	89 f2                	mov    %esi,%edx
  800ce4:	89 f8                	mov    %edi,%eax
  800ce6:	f7 74 24 08          	divl   0x8(%esp)
  800cea:	89 d6                	mov    %edx,%esi
  800cec:	89 c7                	mov    %eax,%edi
  800cee:	f7 24 24             	mull   (%esp)
  800cf1:	39 d6                	cmp    %edx,%esi
  800cf3:	89 14 24             	mov    %edx,(%esp)
  800cf6:	72 30                	jb     800d28 <__udivdi3+0x118>
  800cf8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800cfc:	89 e9                	mov    %ebp,%ecx
  800cfe:	d3 e2                	shl    %cl,%edx
  800d00:	39 c2                	cmp    %eax,%edx
  800d02:	73 05                	jae    800d09 <__udivdi3+0xf9>
  800d04:	3b 34 24             	cmp    (%esp),%esi
  800d07:	74 1f                	je     800d28 <__udivdi3+0x118>
  800d09:	89 f8                	mov    %edi,%eax
  800d0b:	31 d2                	xor    %edx,%edx
  800d0d:	e9 7a ff ff ff       	jmp    800c8c <__udivdi3+0x7c>
  800d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d18:	31 d2                	xor    %edx,%edx
  800d1a:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1f:	e9 68 ff ff ff       	jmp    800c8c <__udivdi3+0x7c>
  800d24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d28:	8d 47 ff             	lea    -0x1(%edi),%eax
  800d2b:	31 d2                	xor    %edx,%edx
  800d2d:	83 c4 0c             	add    $0xc,%esp
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    
  800d34:	66 90                	xchg   %ax,%ax
  800d36:	66 90                	xchg   %ax,%ax
  800d38:	66 90                	xchg   %ax,%ax
  800d3a:	66 90                	xchg   %ax,%ax
  800d3c:	66 90                	xchg   %ax,%ax
  800d3e:	66 90                	xchg   %ax,%ax

00800d40 <__umoddi3>:
  800d40:	55                   	push   %ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	83 ec 14             	sub    $0x14,%esp
  800d46:	8b 44 24 28          	mov    0x28(%esp),%eax
  800d4a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800d4e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800d52:	89 c7                	mov    %eax,%edi
  800d54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d58:	8b 44 24 30          	mov    0x30(%esp),%eax
  800d5c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800d60:	89 34 24             	mov    %esi,(%esp)
  800d63:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d67:	85 c0                	test   %eax,%eax
  800d69:	89 c2                	mov    %eax,%edx
  800d6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d6f:	75 17                	jne    800d88 <__umoddi3+0x48>
  800d71:	39 fe                	cmp    %edi,%esi
  800d73:	76 4b                	jbe    800dc0 <__umoddi3+0x80>
  800d75:	89 c8                	mov    %ecx,%eax
  800d77:	89 fa                	mov    %edi,%edx
  800d79:	f7 f6                	div    %esi
  800d7b:	89 d0                	mov    %edx,%eax
  800d7d:	31 d2                	xor    %edx,%edx
  800d7f:	83 c4 14             	add    $0x14,%esp
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    
  800d86:	66 90                	xchg   %ax,%ax
  800d88:	39 f8                	cmp    %edi,%eax
  800d8a:	77 54                	ja     800de0 <__umoddi3+0xa0>
  800d8c:	0f bd e8             	bsr    %eax,%ebp
  800d8f:	83 f5 1f             	xor    $0x1f,%ebp
  800d92:	75 5c                	jne    800df0 <__umoddi3+0xb0>
  800d94:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d98:	39 3c 24             	cmp    %edi,(%esp)
  800d9b:	0f 87 e7 00 00 00    	ja     800e88 <__umoddi3+0x148>
  800da1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800da5:	29 f1                	sub    %esi,%ecx
  800da7:	19 c7                	sbb    %eax,%edi
  800da9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800db1:	8b 44 24 08          	mov    0x8(%esp),%eax
  800db5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800db9:	83 c4 14             	add    $0x14,%esp
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    
  800dc0:	85 f6                	test   %esi,%esi
  800dc2:	89 f5                	mov    %esi,%ebp
  800dc4:	75 0b                	jne    800dd1 <__umoddi3+0x91>
  800dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dcb:	31 d2                	xor    %edx,%edx
  800dcd:	f7 f6                	div    %esi
  800dcf:	89 c5                	mov    %eax,%ebp
  800dd1:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dd5:	31 d2                	xor    %edx,%edx
  800dd7:	f7 f5                	div    %ebp
  800dd9:	89 c8                	mov    %ecx,%eax
  800ddb:	f7 f5                	div    %ebp
  800ddd:	eb 9c                	jmp    800d7b <__umoddi3+0x3b>
  800ddf:	90                   	nop
  800de0:	89 c8                	mov    %ecx,%eax
  800de2:	89 fa                	mov    %edi,%edx
  800de4:	83 c4 14             	add    $0x14,%esp
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    
  800deb:	90                   	nop
  800dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800df0:	8b 04 24             	mov    (%esp),%eax
  800df3:	be 20 00 00 00       	mov    $0x20,%esi
  800df8:	89 e9                	mov    %ebp,%ecx
  800dfa:	29 ee                	sub    %ebp,%esi
  800dfc:	d3 e2                	shl    %cl,%edx
  800dfe:	89 f1                	mov    %esi,%ecx
  800e00:	d3 e8                	shr    %cl,%eax
  800e02:	89 e9                	mov    %ebp,%ecx
  800e04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e08:	8b 04 24             	mov    (%esp),%eax
  800e0b:	09 54 24 04          	or     %edx,0x4(%esp)
  800e0f:	89 fa                	mov    %edi,%edx
  800e11:	d3 e0                	shl    %cl,%eax
  800e13:	89 f1                	mov    %esi,%ecx
  800e15:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e19:	8b 44 24 10          	mov    0x10(%esp),%eax
  800e1d:	d3 ea                	shr    %cl,%edx
  800e1f:	89 e9                	mov    %ebp,%ecx
  800e21:	d3 e7                	shl    %cl,%edi
  800e23:	89 f1                	mov    %esi,%ecx
  800e25:	d3 e8                	shr    %cl,%eax
  800e27:	89 e9                	mov    %ebp,%ecx
  800e29:	09 f8                	or     %edi,%eax
  800e2b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800e2f:	f7 74 24 04          	divl   0x4(%esp)
  800e33:	d3 e7                	shl    %cl,%edi
  800e35:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e39:	89 d7                	mov    %edx,%edi
  800e3b:	f7 64 24 08          	mull   0x8(%esp)
  800e3f:	39 d7                	cmp    %edx,%edi
  800e41:	89 c1                	mov    %eax,%ecx
  800e43:	89 14 24             	mov    %edx,(%esp)
  800e46:	72 2c                	jb     800e74 <__umoddi3+0x134>
  800e48:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  800e4c:	72 22                	jb     800e70 <__umoddi3+0x130>
  800e4e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e52:	29 c8                	sub    %ecx,%eax
  800e54:	19 d7                	sbb    %edx,%edi
  800e56:	89 e9                	mov    %ebp,%ecx
  800e58:	89 fa                	mov    %edi,%edx
  800e5a:	d3 e8                	shr    %cl,%eax
  800e5c:	89 f1                	mov    %esi,%ecx
  800e5e:	d3 e2                	shl    %cl,%edx
  800e60:	89 e9                	mov    %ebp,%ecx
  800e62:	d3 ef                	shr    %cl,%edi
  800e64:	09 d0                	or     %edx,%eax
  800e66:	89 fa                	mov    %edi,%edx
  800e68:	83 c4 14             	add    $0x14,%esp
  800e6b:	5e                   	pop    %esi
  800e6c:	5f                   	pop    %edi
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    
  800e6f:	90                   	nop
  800e70:	39 d7                	cmp    %edx,%edi
  800e72:	75 da                	jne    800e4e <__umoddi3+0x10e>
  800e74:	8b 14 24             	mov    (%esp),%edx
  800e77:	89 c1                	mov    %eax,%ecx
  800e79:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  800e7d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  800e81:	eb cb                	jmp    800e4e <__umoddi3+0x10e>
  800e83:	90                   	nop
  800e84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e88:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800e8c:	0f 82 0f ff ff ff    	jb     800da1 <__umoddi3+0x61>
  800e92:	e9 1a ff ff ff       	jmp    800db1 <__umoddi3+0x71>
