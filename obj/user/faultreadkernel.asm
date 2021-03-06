
obj/user/faultreadkernel:     file format elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	a1 00 00 10 f0       	mov    0xf0100000,%eax
  80003e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800042:	c7 04 24 a0 0e 80 00 	movl   $0x800ea0,(%esp)
  800049:	e8 ee 00 00 00       	call   80013c <cprintf>
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
  80005c:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800063:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800066:	85 c0                	test   %eax,%eax
  800068:	7e 08                	jle    800072 <libmain+0x22>
		binaryname = argv[0];
  80006a:	8b 0a                	mov    (%edx),%ecx
  80006c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

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
  800092:	e8 ac 0a 00 00       	call   800b43 <sys_env_destroy>
}
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	53                   	push   %ebx
  80009d:	83 ec 14             	sub    $0x14,%esp
  8000a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000a3:	8b 13                	mov    (%ebx),%edx
  8000a5:	8d 42 01             	lea    0x1(%edx),%eax
  8000a8:	89 03                	mov    %eax,(%ebx)
  8000aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ad:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000b1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000b6:	75 19                	jne    8000d1 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000b8:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000bf:	00 
  8000c0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000c3:	89 04 24             	mov    %eax,(%esp)
  8000c6:	e8 3b 0a 00 00       	call   800b06 <sys_cputs>
		b->idx = 0;
  8000cb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000d1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000d5:	83 c4 14             	add    $0x14,%esp
  8000d8:	5b                   	pop    %ebx
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000e4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000eb:	00 00 00 
	b.cnt = 0;
  8000ee:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000f5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800102:	89 44 24 08          	mov    %eax,0x8(%esp)
  800106:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80010c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800110:	c7 04 24 99 00 80 00 	movl   $0x800099,(%esp)
  800117:	e8 78 01 00 00       	call   800294 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800122:	89 44 24 04          	mov    %eax,0x4(%esp)
  800126:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 d2 09 00 00       	call   800b06 <sys_cputs>

	return b.cnt;
}
  800134:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800142:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800145:	89 44 24 04          	mov    %eax,0x4(%esp)
  800149:	8b 45 08             	mov    0x8(%ebp),%eax
  80014c:	89 04 24             	mov    %eax,(%esp)
  80014f:	e8 87 ff ff ff       	call   8000db <vcprintf>
	va_end(ap);

	return cnt;
}
  800154:	c9                   	leave  
  800155:	c3                   	ret    
  800156:	66 90                	xchg   %ax,%ax
  800158:	66 90                	xchg   %ax,%ax
  80015a:	66 90                	xchg   %ax,%ax
  80015c:	66 90                	xchg   %ax,%ax
  80015e:	66 90                	xchg   %ax,%ax

00800160 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 3c             	sub    $0x3c,%esp
  800169:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80016c:	89 d7                	mov    %edx,%edi
  80016e:	8b 45 08             	mov    0x8(%ebp),%eax
  800171:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800174:	8b 45 0c             	mov    0xc(%ebp),%eax
  800177:	89 c3                	mov    %eax,%ebx
  800179:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80017c:	8b 45 10             	mov    0x10(%ebp),%eax
  80017f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800182:	b9 00 00 00 00       	mov    $0x0,%ecx
  800187:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80018a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80018d:	39 d9                	cmp    %ebx,%ecx
  80018f:	72 05                	jb     800196 <printnum+0x36>
  800191:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800194:	77 69                	ja     8001ff <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800196:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800199:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80019d:	83 ee 01             	sub    $0x1,%esi
  8001a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001a8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001ac:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001b0:	89 c3                	mov    %eax,%ebx
  8001b2:	89 d6                	mov    %edx,%esi
  8001b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001ba:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8001c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001c5:	89 04 24             	mov    %eax,(%esp)
  8001c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cf:	e8 3c 0a 00 00       	call   800c10 <__udivdi3>
  8001d4:	89 d9                	mov    %ebx,%ecx
  8001d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001de:	89 04 24             	mov    %eax,(%esp)
  8001e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001e5:	89 fa                	mov    %edi,%edx
  8001e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ea:	e8 71 ff ff ff       	call   800160 <printnum>
  8001ef:	eb 1b                	jmp    80020c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001f5:	8b 45 18             	mov    0x18(%ebp),%eax
  8001f8:	89 04 24             	mov    %eax,(%esp)
  8001fb:	ff d3                	call   *%ebx
  8001fd:	eb 03                	jmp    800202 <printnum+0xa2>
  8001ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800202:	83 ee 01             	sub    $0x1,%esi
  800205:	85 f6                	test   %esi,%esi
  800207:	7f e8                	jg     8001f1 <printnum+0x91>
  800209:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80020c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800210:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800214:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800217:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80021a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800222:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800225:	89 04 24             	mov    %eax,(%esp)
  800228:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80022b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022f:	e8 0c 0b 00 00       	call   800d40 <__umoddi3>
  800234:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800238:	0f be 80 d1 0e 80 00 	movsbl 0x800ed1(%eax),%eax
  80023f:	89 04 24             	mov    %eax,(%esp)
  800242:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800245:	ff d0                	call   *%eax
}
  800247:	83 c4 3c             	add    $0x3c,%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5f                   	pop    %edi
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800255:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800259:	8b 10                	mov    (%eax),%edx
  80025b:	3b 50 04             	cmp    0x4(%eax),%edx
  80025e:	73 0a                	jae    80026a <sprintputch+0x1b>
		*b->buf++ = ch;
  800260:	8d 4a 01             	lea    0x1(%edx),%ecx
  800263:	89 08                	mov    %ecx,(%eax)
  800265:	8b 45 08             	mov    0x8(%ebp),%eax
  800268:	88 02                	mov    %al,(%edx)
}
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800272:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800275:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800279:	8b 45 10             	mov    0x10(%ebp),%eax
  80027c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800280:	8b 45 0c             	mov    0xc(%ebp),%eax
  800283:	89 44 24 04          	mov    %eax,0x4(%esp)
  800287:	8b 45 08             	mov    0x8(%ebp),%eax
  80028a:	89 04 24             	mov    %eax,(%esp)
  80028d:	e8 02 00 00 00       	call   800294 <vprintfmt>
	va_end(ap);
}
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	57                   	push   %edi
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
  80029a:	83 ec 3c             	sub    $0x3c,%esp
  80029d:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a6:	eb 11                	jmp    8002b9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002a8:	85 c0                	test   %eax,%eax
  8002aa:	0f 84 48 04 00 00    	je     8006f8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8002b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002b4:	89 04 24             	mov    %eax,(%esp)
  8002b7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b9:	83 c7 01             	add    $0x1,%edi
  8002bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002c0:	83 f8 25             	cmp    $0x25,%eax
  8002c3:	75 e3                	jne    8002a8 <vprintfmt+0x14>
  8002c5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002d0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002d7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e3:	eb 1f                	jmp    800304 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002ec:	eb 16                	jmp    800304 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002f1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f5:	eb 0d                	jmp    800304 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8002f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800304:	8d 47 01             	lea    0x1(%edi),%eax
  800307:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030a:	0f b6 17             	movzbl (%edi),%edx
  80030d:	0f b6 c2             	movzbl %dl,%eax
  800310:	83 ea 23             	sub    $0x23,%edx
  800313:	80 fa 55             	cmp    $0x55,%dl
  800316:	0f 87 bf 03 00 00    	ja     8006db <vprintfmt+0x447>
  80031c:	0f b6 d2             	movzbl %dl,%edx
  80031f:	ff 24 95 60 0f 80 00 	jmp    *0x800f60(,%edx,4)
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800329:	ba 00 00 00 00       	mov    $0x0,%edx
  80032e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800331:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800334:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800338:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80033b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80033e:	83 f9 09             	cmp    $0x9,%ecx
  800341:	77 3c                	ja     80037f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800343:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800346:	eb e9                	jmp    800331 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800348:	8b 45 14             	mov    0x14(%ebp),%eax
  80034b:	8b 00                	mov    (%eax),%eax
  80034d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800350:	8b 45 14             	mov    0x14(%ebp),%eax
  800353:	8d 40 04             	lea    0x4(%eax),%eax
  800356:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80035c:	eb 27                	jmp    800385 <vprintfmt+0xf1>
  80035e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800361:	85 d2                	test   %edx,%edx
  800363:	b8 00 00 00 00       	mov    $0x0,%eax
  800368:	0f 49 c2             	cmovns %edx,%eax
  80036b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800371:	eb 91                	jmp    800304 <vprintfmt+0x70>
  800373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800376:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80037d:	eb 85                	jmp    800304 <vprintfmt+0x70>
  80037f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800382:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800385:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800389:	0f 89 75 ff ff ff    	jns    800304 <vprintfmt+0x70>
  80038f:	e9 63 ff ff ff       	jmp    8002f7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800394:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80039a:	e9 65 ff ff ff       	jmp    800304 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003aa:	8b 00                	mov    (%eax),%eax
  8003ac:	89 04 24             	mov    %eax,(%esp)
  8003af:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b4:	e9 00 ff ff ff       	jmp    8002b9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003bc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003c0:	8b 00                	mov    (%eax),%eax
  8003c2:	99                   	cltd   
  8003c3:	31 d0                	xor    %edx,%eax
  8003c5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c7:	83 f8 07             	cmp    $0x7,%eax
  8003ca:	7f 0b                	jg     8003d7 <vprintfmt+0x143>
  8003cc:	8b 14 85 c0 10 80 00 	mov    0x8010c0(,%eax,4),%edx
  8003d3:	85 d2                	test   %edx,%edx
  8003d5:	75 20                	jne    8003f7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  8003d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003db:	c7 44 24 08 e9 0e 80 	movl   $0x800ee9,0x8(%esp)
  8003e2:	00 
  8003e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e7:	89 34 24             	mov    %esi,(%esp)
  8003ea:	e8 7d fe ff ff       	call   80026c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003f2:	e9 c2 fe ff ff       	jmp    8002b9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8003f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003fb:	c7 44 24 08 f2 0e 80 	movl   $0x800ef2,0x8(%esp)
  800402:	00 
  800403:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800407:	89 34 24             	mov    %esi,(%esp)
  80040a:	e8 5d fe ff ff       	call   80026c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800412:	e9 a2 fe ff ff       	jmp    8002b9 <vprintfmt+0x25>
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80041d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800420:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800423:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800427:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800429:	85 ff                	test   %edi,%edi
  80042b:	b8 e2 0e 80 00       	mov    $0x800ee2,%eax
  800430:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800433:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800437:	0f 84 92 00 00 00    	je     8004cf <vprintfmt+0x23b>
  80043d:	85 c9                	test   %ecx,%ecx
  80043f:	0f 8e 98 00 00 00    	jle    8004dd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800445:	89 54 24 04          	mov    %edx,0x4(%esp)
  800449:	89 3c 24             	mov    %edi,(%esp)
  80044c:	e8 47 03 00 00       	call   800798 <strnlen>
  800451:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800454:	29 c1                	sub    %eax,%ecx
  800456:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800459:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80045d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800460:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800463:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800465:	eb 0f                	jmp    800476 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800467:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80046b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046e:	89 04 24             	mov    %eax,(%esp)
  800471:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800473:	83 ef 01             	sub    $0x1,%edi
  800476:	85 ff                	test   %edi,%edi
  800478:	7f ed                	jg     800467 <vprintfmt+0x1d3>
  80047a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80047d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800480:	85 c9                	test   %ecx,%ecx
  800482:	b8 00 00 00 00       	mov    $0x0,%eax
  800487:	0f 49 c1             	cmovns %ecx,%eax
  80048a:	29 c1                	sub    %eax,%ecx
  80048c:	89 75 08             	mov    %esi,0x8(%ebp)
  80048f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800492:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800495:	89 cb                	mov    %ecx,%ebx
  800497:	eb 50                	jmp    8004e9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800499:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049d:	74 1e                	je     8004bd <vprintfmt+0x229>
  80049f:	0f be d2             	movsbl %dl,%edx
  8004a2:	83 ea 20             	sub    $0x20,%edx
  8004a5:	83 fa 5e             	cmp    $0x5e,%edx
  8004a8:	76 13                	jbe    8004bd <vprintfmt+0x229>
					putch('?', putdat);
  8004aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004b8:	ff 55 08             	call   *0x8(%ebp)
  8004bb:	eb 0d                	jmp    8004ca <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8004bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004c0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004c4:	89 04 24             	mov    %eax,(%esp)
  8004c7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ca:	83 eb 01             	sub    $0x1,%ebx
  8004cd:	eb 1a                	jmp    8004e9 <vprintfmt+0x255>
  8004cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004db:	eb 0c                	jmp    8004e9 <vprintfmt+0x255>
  8004dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e9:	83 c7 01             	add    $0x1,%edi
  8004ec:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004f0:	0f be c2             	movsbl %dl,%eax
  8004f3:	85 c0                	test   %eax,%eax
  8004f5:	74 25                	je     80051c <vprintfmt+0x288>
  8004f7:	85 f6                	test   %esi,%esi
  8004f9:	78 9e                	js     800499 <vprintfmt+0x205>
  8004fb:	83 ee 01             	sub    $0x1,%esi
  8004fe:	79 99                	jns    800499 <vprintfmt+0x205>
  800500:	89 df                	mov    %ebx,%edi
  800502:	8b 75 08             	mov    0x8(%ebp),%esi
  800505:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800508:	eb 1a                	jmp    800524 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800515:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800517:	83 ef 01             	sub    $0x1,%edi
  80051a:	eb 08                	jmp    800524 <vprintfmt+0x290>
  80051c:	89 df                	mov    %ebx,%edi
  80051e:	8b 75 08             	mov    0x8(%ebp),%esi
  800521:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800524:	85 ff                	test   %edi,%edi
  800526:	7f e2                	jg     80050a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052b:	e9 89 fd ff ff       	jmp    8002b9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800530:	83 f9 01             	cmp    $0x1,%ecx
  800533:	7e 19                	jle    80054e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8b 50 04             	mov    0x4(%eax),%edx
  80053b:	8b 00                	mov    (%eax),%eax
  80053d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800540:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 40 08             	lea    0x8(%eax),%eax
  800549:	89 45 14             	mov    %eax,0x14(%ebp)
  80054c:	eb 38                	jmp    800586 <vprintfmt+0x2f2>
	else if (lflag)
  80054e:	85 c9                	test   %ecx,%ecx
  800550:	74 1b                	je     80056d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8b 00                	mov    (%eax),%eax
  800557:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055a:	89 c1                	mov    %eax,%ecx
  80055c:	c1 f9 1f             	sar    $0x1f,%ecx
  80055f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8d 40 04             	lea    0x4(%eax),%eax
  800568:	89 45 14             	mov    %eax,0x14(%ebp)
  80056b:	eb 19                	jmp    800586 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800575:	89 c1                	mov    %eax,%ecx
  800577:	c1 f9 1f             	sar    $0x1f,%ecx
  80057a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8d 40 04             	lea    0x4(%eax),%eax
  800583:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800586:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800589:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80058c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800591:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800595:	0f 89 04 01 00 00    	jns    80069f <vprintfmt+0x40b>
				putch('-', putdat);
  80059b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005a6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ae:	f7 da                	neg    %edx
  8005b0:	83 d1 00             	adc    $0x0,%ecx
  8005b3:	f7 d9                	neg    %ecx
  8005b5:	e9 e5 00 00 00       	jmp    80069f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ba:	83 f9 01             	cmp    $0x1,%ecx
  8005bd:	7e 10                	jle    8005cf <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8b 10                	mov    (%eax),%edx
  8005c4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c7:	8d 40 08             	lea    0x8(%eax),%eax
  8005ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8005cd:	eb 26                	jmp    8005f5 <vprintfmt+0x361>
	else if (lflag)
  8005cf:	85 c9                	test   %ecx,%ecx
  8005d1:	74 12                	je     8005e5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8b 10                	mov    (%eax),%edx
  8005d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005dd:	8d 40 04             	lea    0x4(%eax),%eax
  8005e0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e3:	eb 10                	jmp    8005f5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8b 10                	mov    (%eax),%edx
  8005ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ef:	8d 40 04             	lea    0x4(%eax),%eax
  8005f2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005f5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8005fa:	e9 a0 00 00 00       	jmp    80069f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800603:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80060a:	ff d6                	call   *%esi
			putch('X', putdat);
  80060c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800610:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800617:	ff d6                	call   *%esi
			putch('X', putdat);
  800619:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800624:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800626:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800629:	e9 8b fc ff ff       	jmp    8002b9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80062e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800632:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800639:	ff d6                	call   *%esi
			putch('x', putdat);
  80063b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800646:	ff d6                	call   *%esi
			num = (unsigned long long)
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8b 10                	mov    (%eax),%edx
  80064d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800652:	8d 40 04             	lea    0x4(%eax),%eax
  800655:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800658:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80065d:	eb 40                	jmp    80069f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80065f:	83 f9 01             	cmp    $0x1,%ecx
  800662:	7e 10                	jle    800674 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8b 10                	mov    (%eax),%edx
  800669:	8b 48 04             	mov    0x4(%eax),%ecx
  80066c:	8d 40 08             	lea    0x8(%eax),%eax
  80066f:	89 45 14             	mov    %eax,0x14(%ebp)
  800672:	eb 26                	jmp    80069a <vprintfmt+0x406>
	else if (lflag)
  800674:	85 c9                	test   %ecx,%ecx
  800676:	74 12                	je     80068a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8b 10                	mov    (%eax),%edx
  80067d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800682:	8d 40 04             	lea    0x4(%eax),%eax
  800685:	89 45 14             	mov    %eax,0x14(%ebp)
  800688:	eb 10                	jmp    80069a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8b 10                	mov    (%eax),%edx
  80068f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800694:	8d 40 04             	lea    0x4(%eax),%eax
  800697:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80069a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006a3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8006b2:	89 14 24             	mov    %edx,(%esp)
  8006b5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006b9:	89 da                	mov    %ebx,%edx
  8006bb:	89 f0                	mov    %esi,%eax
  8006bd:	e8 9e fa ff ff       	call   800160 <printnum>
			break;
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c5:	e9 ef fb ff ff       	jmp    8002b9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ce:	89 04 24             	mov    %eax,(%esp)
  8006d1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d6:	e9 de fb ff ff       	jmp    8002b9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006df:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006e6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e8:	eb 03                	jmp    8006ed <vprintfmt+0x459>
  8006ea:	83 ef 01             	sub    $0x1,%edi
  8006ed:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f1:	75 f7                	jne    8006ea <vprintfmt+0x456>
  8006f3:	e9 c1 fb ff ff       	jmp    8002b9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8006f8:	83 c4 3c             	add    $0x3c,%esp
  8006fb:	5b                   	pop    %ebx
  8006fc:	5e                   	pop    %esi
  8006fd:	5f                   	pop    %edi
  8006fe:	5d                   	pop    %ebp
  8006ff:	c3                   	ret    

00800700 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	83 ec 28             	sub    $0x28,%esp
  800706:	8b 45 08             	mov    0x8(%ebp),%eax
  800709:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800713:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800716:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071d:	85 c0                	test   %eax,%eax
  80071f:	74 30                	je     800751 <vsnprintf+0x51>
  800721:	85 d2                	test   %edx,%edx
  800723:	7e 2c                	jle    800751 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800725:	8b 45 14             	mov    0x14(%ebp),%eax
  800728:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072c:	8b 45 10             	mov    0x10(%ebp),%eax
  80072f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800733:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800736:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073a:	c7 04 24 4f 02 80 00 	movl   $0x80024f,(%esp)
  800741:	e8 4e fb ff ff       	call   800294 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800746:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800749:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074f:	eb 05                	jmp    800756 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800751:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800761:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800765:	8b 45 10             	mov    0x10(%ebp),%eax
  800768:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800773:	8b 45 08             	mov    0x8(%ebp),%eax
  800776:	89 04 24             	mov    %eax,(%esp)
  800779:	e8 82 ff ff ff       	call   800700 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	eb 03                	jmp    800790 <strlen+0x10>
		n++;
  80078d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800790:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800794:	75 f7                	jne    80078d <strlen+0xd>
		n++;
	return n;
}
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a6:	eb 03                	jmp    8007ab <strnlen+0x13>
		n++;
  8007a8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ab:	39 d0                	cmp    %edx,%eax
  8007ad:	74 06                	je     8007b5 <strnlen+0x1d>
  8007af:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b3:	75 f3                	jne    8007a8 <strnlen+0x10>
		n++;
	return n;
}
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c1:	89 c2                	mov    %eax,%edx
  8007c3:	83 c2 01             	add    $0x1,%edx
  8007c6:	83 c1 01             	add    $0x1,%ecx
  8007c9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d0:	84 db                	test   %bl,%bl
  8007d2:	75 ef                	jne    8007c3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d4:	5b                   	pop    %ebx
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	83 ec 08             	sub    $0x8,%esp
  8007de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e1:	89 1c 24             	mov    %ebx,(%esp)
  8007e4:	e8 97 ff ff ff       	call   800780 <strlen>
	strcpy(dst + len, src);
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007f0:	01 d8                	add    %ebx,%eax
  8007f2:	89 04 24             	mov    %eax,(%esp)
  8007f5:	e8 bd ff ff ff       	call   8007b7 <strcpy>
	return dst;
}
  8007fa:	89 d8                	mov    %ebx,%eax
  8007fc:	83 c4 08             	add    $0x8,%esp
  8007ff:	5b                   	pop    %ebx
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	8b 75 08             	mov    0x8(%ebp),%esi
  80080a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080d:	89 f3                	mov    %esi,%ebx
  80080f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800812:	89 f2                	mov    %esi,%edx
  800814:	eb 0f                	jmp    800825 <strncpy+0x23>
		*dst++ = *src;
  800816:	83 c2 01             	add    $0x1,%edx
  800819:	0f b6 01             	movzbl (%ecx),%eax
  80081c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081f:	80 39 01             	cmpb   $0x1,(%ecx)
  800822:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800825:	39 da                	cmp    %ebx,%edx
  800827:	75 ed                	jne    800816 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800829:	89 f0                	mov    %esi,%eax
  80082b:	5b                   	pop    %ebx
  80082c:	5e                   	pop    %esi
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	8b 75 08             	mov    0x8(%ebp),%esi
  800837:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80083d:	89 f0                	mov    %esi,%eax
  80083f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800843:	85 c9                	test   %ecx,%ecx
  800845:	75 0b                	jne    800852 <strlcpy+0x23>
  800847:	eb 1d                	jmp    800866 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800849:	83 c0 01             	add    $0x1,%eax
  80084c:	83 c2 01             	add    $0x1,%edx
  80084f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800852:	39 d8                	cmp    %ebx,%eax
  800854:	74 0b                	je     800861 <strlcpy+0x32>
  800856:	0f b6 0a             	movzbl (%edx),%ecx
  800859:	84 c9                	test   %cl,%cl
  80085b:	75 ec                	jne    800849 <strlcpy+0x1a>
  80085d:	89 c2                	mov    %eax,%edx
  80085f:	eb 02                	jmp    800863 <strlcpy+0x34>
  800861:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800863:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800866:	29 f0                	sub    %esi,%eax
}
  800868:	5b                   	pop    %ebx
  800869:	5e                   	pop    %esi
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800872:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800875:	eb 06                	jmp    80087d <strcmp+0x11>
		p++, q++;
  800877:	83 c1 01             	add    $0x1,%ecx
  80087a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80087d:	0f b6 01             	movzbl (%ecx),%eax
  800880:	84 c0                	test   %al,%al
  800882:	74 04                	je     800888 <strcmp+0x1c>
  800884:	3a 02                	cmp    (%edx),%al
  800886:	74 ef                	je     800877 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800888:	0f b6 c0             	movzbl %al,%eax
  80088b:	0f b6 12             	movzbl (%edx),%edx
  80088e:	29 d0                	sub    %edx,%eax
}
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	53                   	push   %ebx
  800896:	8b 45 08             	mov    0x8(%ebp),%eax
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089c:	89 c3                	mov    %eax,%ebx
  80089e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a1:	eb 06                	jmp    8008a9 <strncmp+0x17>
		n--, p++, q++;
  8008a3:	83 c0 01             	add    $0x1,%eax
  8008a6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a9:	39 d8                	cmp    %ebx,%eax
  8008ab:	74 15                	je     8008c2 <strncmp+0x30>
  8008ad:	0f b6 08             	movzbl (%eax),%ecx
  8008b0:	84 c9                	test   %cl,%cl
  8008b2:	74 04                	je     8008b8 <strncmp+0x26>
  8008b4:	3a 0a                	cmp    (%edx),%cl
  8008b6:	74 eb                	je     8008a3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b8:	0f b6 00             	movzbl (%eax),%eax
  8008bb:	0f b6 12             	movzbl (%edx),%edx
  8008be:	29 d0                	sub    %edx,%eax
  8008c0:	eb 05                	jmp    8008c7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c7:	5b                   	pop    %ebx
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d4:	eb 07                	jmp    8008dd <strchr+0x13>
		if (*s == c)
  8008d6:	38 ca                	cmp    %cl,%dl
  8008d8:	74 0f                	je     8008e9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008da:	83 c0 01             	add    $0x1,%eax
  8008dd:	0f b6 10             	movzbl (%eax),%edx
  8008e0:	84 d2                	test   %dl,%dl
  8008e2:	75 f2                	jne    8008d6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f5:	eb 07                	jmp    8008fe <strfind+0x13>
		if (*s == c)
  8008f7:	38 ca                	cmp    %cl,%dl
  8008f9:	74 0a                	je     800905 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008fb:	83 c0 01             	add    $0x1,%eax
  8008fe:	0f b6 10             	movzbl (%eax),%edx
  800901:	84 d2                	test   %dl,%dl
  800903:	75 f2                	jne    8008f7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	57                   	push   %edi
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800910:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800913:	85 c9                	test   %ecx,%ecx
  800915:	74 36                	je     80094d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800917:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091d:	75 28                	jne    800947 <memset+0x40>
  80091f:	f6 c1 03             	test   $0x3,%cl
  800922:	75 23                	jne    800947 <memset+0x40>
		c &= 0xFF;
  800924:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800928:	89 d3                	mov    %edx,%ebx
  80092a:	c1 e3 08             	shl    $0x8,%ebx
  80092d:	89 d6                	mov    %edx,%esi
  80092f:	c1 e6 18             	shl    $0x18,%esi
  800932:	89 d0                	mov    %edx,%eax
  800934:	c1 e0 10             	shl    $0x10,%eax
  800937:	09 f0                	or     %esi,%eax
  800939:	09 c2                	or     %eax,%edx
  80093b:	89 d0                	mov    %edx,%eax
  80093d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80093f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800942:	fc                   	cld    
  800943:	f3 ab                	rep stos %eax,%es:(%edi)
  800945:	eb 06                	jmp    80094d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094a:	fc                   	cld    
  80094b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094d:	89 f8                	mov    %edi,%eax
  80094f:	5b                   	pop    %ebx
  800950:	5e                   	pop    %esi
  800951:	5f                   	pop    %edi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	57                   	push   %edi
  800958:	56                   	push   %esi
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
  80095c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800962:	39 c6                	cmp    %eax,%esi
  800964:	73 35                	jae    80099b <memmove+0x47>
  800966:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800969:	39 d0                	cmp    %edx,%eax
  80096b:	73 2e                	jae    80099b <memmove+0x47>
		s += n;
		d += n;
  80096d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800970:	89 d6                	mov    %edx,%esi
  800972:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800974:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097a:	75 13                	jne    80098f <memmove+0x3b>
  80097c:	f6 c1 03             	test   $0x3,%cl
  80097f:	75 0e                	jne    80098f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800981:	83 ef 04             	sub    $0x4,%edi
  800984:	8d 72 fc             	lea    -0x4(%edx),%esi
  800987:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80098a:	fd                   	std    
  80098b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098d:	eb 09                	jmp    800998 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80098f:	83 ef 01             	sub    $0x1,%edi
  800992:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800995:	fd                   	std    
  800996:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800998:	fc                   	cld    
  800999:	eb 1d                	jmp    8009b8 <memmove+0x64>
  80099b:	89 f2                	mov    %esi,%edx
  80099d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099f:	f6 c2 03             	test   $0x3,%dl
  8009a2:	75 0f                	jne    8009b3 <memmove+0x5f>
  8009a4:	f6 c1 03             	test   $0x3,%cl
  8009a7:	75 0a                	jne    8009b3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ac:	89 c7                	mov    %eax,%edi
  8009ae:	fc                   	cld    
  8009af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b1:	eb 05                	jmp    8009b8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b3:	89 c7                	mov    %eax,%edi
  8009b5:	fc                   	cld    
  8009b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b8:	5e                   	pop    %esi
  8009b9:	5f                   	pop    %edi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	89 04 24             	mov    %eax,(%esp)
  8009d6:	e8 79 ff ff ff       	call   800954 <memmove>
}
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e8:	89 d6                	mov    %edx,%esi
  8009ea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ed:	eb 1a                	jmp    800a09 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ef:	0f b6 02             	movzbl (%edx),%eax
  8009f2:	0f b6 19             	movzbl (%ecx),%ebx
  8009f5:	38 d8                	cmp    %bl,%al
  8009f7:	74 0a                	je     800a03 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009f9:	0f b6 c0             	movzbl %al,%eax
  8009fc:	0f b6 db             	movzbl %bl,%ebx
  8009ff:	29 d8                	sub    %ebx,%eax
  800a01:	eb 0f                	jmp    800a12 <memcmp+0x35>
		s1++, s2++;
  800a03:	83 c2 01             	add    $0x1,%edx
  800a06:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a09:	39 f2                	cmp    %esi,%edx
  800a0b:	75 e2                	jne    8009ef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a1f:	89 c2                	mov    %eax,%edx
  800a21:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a24:	eb 07                	jmp    800a2d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a26:	38 08                	cmp    %cl,(%eax)
  800a28:	74 07                	je     800a31 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	39 d0                	cmp    %edx,%eax
  800a2f:	72 f5                	jb     800a26 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	57                   	push   %edi
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3f:	eb 03                	jmp    800a44 <strtol+0x11>
		s++;
  800a41:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a44:	0f b6 0a             	movzbl (%edx),%ecx
  800a47:	80 f9 09             	cmp    $0x9,%cl
  800a4a:	74 f5                	je     800a41 <strtol+0xe>
  800a4c:	80 f9 20             	cmp    $0x20,%cl
  800a4f:	74 f0                	je     800a41 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a51:	80 f9 2b             	cmp    $0x2b,%cl
  800a54:	75 0a                	jne    800a60 <strtol+0x2d>
		s++;
  800a56:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a59:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5e:	eb 11                	jmp    800a71 <strtol+0x3e>
  800a60:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a65:	80 f9 2d             	cmp    $0x2d,%cl
  800a68:	75 07                	jne    800a71 <strtol+0x3e>
		s++, neg = 1;
  800a6a:	8d 52 01             	lea    0x1(%edx),%edx
  800a6d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a71:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800a76:	75 15                	jne    800a8d <strtol+0x5a>
  800a78:	80 3a 30             	cmpb   $0x30,(%edx)
  800a7b:	75 10                	jne    800a8d <strtol+0x5a>
  800a7d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a81:	75 0a                	jne    800a8d <strtol+0x5a>
		s += 2, base = 16;
  800a83:	83 c2 02             	add    $0x2,%edx
  800a86:	b8 10 00 00 00       	mov    $0x10,%eax
  800a8b:	eb 10                	jmp    800a9d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800a8d:	85 c0                	test   %eax,%eax
  800a8f:	75 0c                	jne    800a9d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a91:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a93:	80 3a 30             	cmpb   $0x30,(%edx)
  800a96:	75 05                	jne    800a9d <strtol+0x6a>
		s++, base = 8;
  800a98:	83 c2 01             	add    $0x1,%edx
  800a9b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800a9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800aa2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa5:	0f b6 0a             	movzbl (%edx),%ecx
  800aa8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800aab:	89 f0                	mov    %esi,%eax
  800aad:	3c 09                	cmp    $0x9,%al
  800aaf:	77 08                	ja     800ab9 <strtol+0x86>
			dig = *s - '0';
  800ab1:	0f be c9             	movsbl %cl,%ecx
  800ab4:	83 e9 30             	sub    $0x30,%ecx
  800ab7:	eb 20                	jmp    800ad9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ab9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800abc:	89 f0                	mov    %esi,%eax
  800abe:	3c 19                	cmp    $0x19,%al
  800ac0:	77 08                	ja     800aca <strtol+0x97>
			dig = *s - 'a' + 10;
  800ac2:	0f be c9             	movsbl %cl,%ecx
  800ac5:	83 e9 57             	sub    $0x57,%ecx
  800ac8:	eb 0f                	jmp    800ad9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800aca:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800acd:	89 f0                	mov    %esi,%eax
  800acf:	3c 19                	cmp    $0x19,%al
  800ad1:	77 16                	ja     800ae9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ad3:	0f be c9             	movsbl %cl,%ecx
  800ad6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ad9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800adc:	7d 0f                	jge    800aed <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800ade:	83 c2 01             	add    $0x1,%edx
  800ae1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ae5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ae7:	eb bc                	jmp    800aa5 <strtol+0x72>
  800ae9:	89 d8                	mov    %ebx,%eax
  800aeb:	eb 02                	jmp    800aef <strtol+0xbc>
  800aed:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800aef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af3:	74 05                	je     800afa <strtol+0xc7>
		*endptr = (char *) s;
  800af5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800afa:	f7 d8                	neg    %eax
  800afc:	85 ff                	test   %edi,%edi
  800afe:	0f 44 c3             	cmove  %ebx,%eax
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	89 c3                	mov    %eax,%ebx
  800b19:	89 c7                	mov    %eax,%edi
  800b1b:	89 c6                	mov    %eax,%esi
  800b1d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b34:	89 d1                	mov    %edx,%ecx
  800b36:	89 d3                	mov    %edx,%ebx
  800b38:	89 d7                	mov    %edx,%edi
  800b3a:	89 d6                	mov    %edx,%esi
  800b3c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b51:	b8 03 00 00 00       	mov    $0x3,%eax
  800b56:	8b 55 08             	mov    0x8(%ebp),%edx
  800b59:	89 cb                	mov    %ecx,%ebx
  800b5b:	89 cf                	mov    %ecx,%edi
  800b5d:	89 ce                	mov    %ecx,%esi
  800b5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b61:	85 c0                	test   %eax,%eax
  800b63:	7e 28                	jle    800b8d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b69:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b70:	00 
  800b71:	c7 44 24 08 e0 10 80 	movl   $0x8010e0,0x8(%esp)
  800b78:	00 
  800b79:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b80:	00 
  800b81:	c7 04 24 fd 10 80 00 	movl   $0x8010fd,(%esp)
  800b88:	e8 27 00 00 00       	call   800bb4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b8d:	83 c4 2c             	add    $0x2c,%esp
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba5:	89 d1                	mov    %edx,%ecx
  800ba7:	89 d3                	mov    %edx,%ebx
  800ba9:	89 d7                	mov    %edx,%edi
  800bab:	89 d6                	mov    %edx,%esi
  800bad:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800bbc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bbf:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800bc5:	e8 cb ff ff ff       	call   800b95 <sys_getenvid>
  800bca:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcd:	89 54 24 10          	mov    %edx,0x10(%esp)
  800bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800bd8:	89 74 24 08          	mov    %esi,0x8(%esp)
  800bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be0:	c7 04 24 0c 11 80 00 	movl   $0x80110c,(%esp)
  800be7:	e8 50 f5 ff ff       	call   80013c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bf0:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf3:	89 04 24             	mov    %eax,(%esp)
  800bf6:	e8 e0 f4 ff ff       	call   8000db <vcprintf>
	cprintf("\n");
  800bfb:	c7 04 24 30 11 80 00 	movl   $0x801130,(%esp)
  800c02:	e8 35 f5 ff ff       	call   80013c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c07:	cc                   	int3   
  800c08:	eb fd                	jmp    800c07 <_panic+0x53>
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
