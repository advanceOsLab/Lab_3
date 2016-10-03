
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 80 11 f0       	mov    $0xf0118000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
>>>>>>> lab1
*/
//>>>>>>> lab2
void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 90 cd 17 f0       	mov    $0xf017cd90,%eax
f010004b:	2d 65 be 17 f0       	sub    $0xf017be65,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 65 be 17 f0 	movl   $0xf017be65,(%esp)
f0100063:	e8 8f 44 00 00       	call   f01044f7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 b2 04 00 00       	call   f010051f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 a0 49 10 f0 	movl   $0xf01049a0,(%esp)
f010007c:	e8 6d 34 00 00       	call   f01034ee <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 99 11 00 00       	call   f010121f <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100086:	e8 90 2f 00 00       	call   f010301b <env_init>
	trap_init();
f010008b:	90                   	nop
f010008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100090:	e8 d0 34 00 00       	call   f0103565 <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f0100095:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010009c:	00 
f010009d:	c7 04 24 56 a3 11 f0 	movl   $0xf011a356,(%esp)
f01000a4:	e8 6f 31 00 00       	call   f0103218 <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a9:	a1 cc c0 17 f0       	mov    0xf017c0cc,%eax
f01000ae:	89 04 24             	mov    %eax,(%esp)
f01000b1:	e8 a6 33 00 00       	call   f010345c <env_run>

f01000b6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000b6:	55                   	push   %ebp
f01000b7:	89 e5                	mov    %esp,%ebp
f01000b9:	56                   	push   %esi
f01000ba:	53                   	push   %ebx
f01000bb:	83 ec 10             	sub    $0x10,%esp
f01000be:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000c1:	83 3d 80 cd 17 f0 00 	cmpl   $0x0,0xf017cd80
f01000c8:	75 3d                	jne    f0100107 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000ca:	89 35 80 cd 17 f0    	mov    %esi,0xf017cd80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000d0:	fa                   	cli    
f01000d1:	fc                   	cld    

	va_start(ap, fmt);
f01000d2:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000d5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000d8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01000df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000e3:	c7 04 24 bb 49 10 f0 	movl   $0xf01049bb,(%esp)
f01000ea:	e8 ff 33 00 00       	call   f01034ee <cprintf>
	vcprintf(fmt, ap);
f01000ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000f3:	89 34 24             	mov    %esi,(%esp)
f01000f6:	e8 c0 33 00 00       	call   f01034bb <vcprintf>
	cprintf("\n");
f01000fb:	c7 04 24 9e 4c 10 f0 	movl   $0xf0104c9e,(%esp)
f0100102:	e8 e7 33 00 00       	call   f01034ee <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100107:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010010e:	e8 b3 06 00 00       	call   f01007c6 <monitor>
f0100113:	eb f2                	jmp    f0100107 <_panic+0x51>

f0100115 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100115:	55                   	push   %ebp
f0100116:	89 e5                	mov    %esp,%ebp
f0100118:	53                   	push   %ebx
f0100119:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010011c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010011f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100122:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100126:	8b 45 08             	mov    0x8(%ebp),%eax
f0100129:	89 44 24 04          	mov    %eax,0x4(%esp)
f010012d:	c7 04 24 d3 49 10 f0 	movl   $0xf01049d3,(%esp)
f0100134:	e8 b5 33 00 00       	call   f01034ee <cprintf>
	vcprintf(fmt, ap);
f0100139:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010013d:	8b 45 10             	mov    0x10(%ebp),%eax
f0100140:	89 04 24             	mov    %eax,(%esp)
f0100143:	e8 73 33 00 00       	call   f01034bb <vcprintf>
	cprintf("\n");
f0100148:	c7 04 24 9e 4c 10 f0 	movl   $0xf0104c9e,(%esp)
f010014f:	e8 9a 33 00 00       	call   f01034ee <cprintf>
	va_end(ap);
}
f0100154:	83 c4 14             	add    $0x14,%esp
f0100157:	5b                   	pop    %ebx
f0100158:	5d                   	pop    %ebp
f0100159:	c3                   	ret    
f010015a:	66 90                	xchg   %ax,%ax
f010015c:	66 90                	xchg   %ax,%ax
f010015e:	66 90                	xchg   %ax,%ax

f0100160 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100160:	55                   	push   %ebp
f0100161:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100163:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100168:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100169:	a8 01                	test   $0x1,%al
f010016b:	74 08                	je     f0100175 <serial_proc_data+0x15>
f010016d:	b2 f8                	mov    $0xf8,%dl
f010016f:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100170:	0f b6 c0             	movzbl %al,%eax
f0100173:	eb 05                	jmp    f010017a <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100175:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010017a:	5d                   	pop    %ebp
f010017b:	c3                   	ret    

f010017c <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010017c:	55                   	push   %ebp
f010017d:	89 e5                	mov    %esp,%ebp
f010017f:	53                   	push   %ebx
f0100180:	83 ec 04             	sub    $0x4,%esp
f0100183:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100185:	eb 2a                	jmp    f01001b1 <cons_intr+0x35>
		if (c == 0)
f0100187:	85 d2                	test   %edx,%edx
f0100189:	74 26                	je     f01001b1 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f010018b:	a1 a4 c0 17 f0       	mov    0xf017c0a4,%eax
f0100190:	8d 48 01             	lea    0x1(%eax),%ecx
f0100193:	89 0d a4 c0 17 f0    	mov    %ecx,0xf017c0a4
f0100199:	88 90 a0 be 17 f0    	mov    %dl,-0xfe84160(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010019f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01001a5:	75 0a                	jne    f01001b1 <cons_intr+0x35>
			cons.wpos = 0;
f01001a7:	c7 05 a4 c0 17 f0 00 	movl   $0x0,0xf017c0a4
f01001ae:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001b1:	ff d3                	call   *%ebx
f01001b3:	89 c2                	mov    %eax,%edx
f01001b5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001b8:	75 cd                	jne    f0100187 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001ba:	83 c4 04             	add    $0x4,%esp
f01001bd:	5b                   	pop    %ebx
f01001be:	5d                   	pop    %ebp
f01001bf:	c3                   	ret    

f01001c0 <kbd_proc_data>:
f01001c0:	ba 64 00 00 00       	mov    $0x64,%edx
f01001c5:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001c6:	a8 01                	test   $0x1,%al
f01001c8:	0f 84 ef 00 00 00    	je     f01002bd <kbd_proc_data+0xfd>
f01001ce:	b2 60                	mov    $0x60,%dl
f01001d0:	ec                   	in     (%dx),%al
f01001d1:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001d3:	3c e0                	cmp    $0xe0,%al
f01001d5:	75 0d                	jne    f01001e4 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f01001d7:	83 0d 80 be 17 f0 40 	orl    $0x40,0xf017be80
		return 0;
f01001de:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001e3:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001e4:	55                   	push   %ebp
f01001e5:	89 e5                	mov    %esp,%ebp
f01001e7:	53                   	push   %ebx
f01001e8:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001eb:	84 c0                	test   %al,%al
f01001ed:	79 37                	jns    f0100226 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001ef:	8b 0d 80 be 17 f0    	mov    0xf017be80,%ecx
f01001f5:	89 cb                	mov    %ecx,%ebx
f01001f7:	83 e3 40             	and    $0x40,%ebx
f01001fa:	83 e0 7f             	and    $0x7f,%eax
f01001fd:	85 db                	test   %ebx,%ebx
f01001ff:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100202:	0f b6 d2             	movzbl %dl,%edx
f0100205:	0f b6 82 40 4b 10 f0 	movzbl -0xfefb4c0(%edx),%eax
f010020c:	83 c8 40             	or     $0x40,%eax
f010020f:	0f b6 c0             	movzbl %al,%eax
f0100212:	f7 d0                	not    %eax
f0100214:	21 c1                	and    %eax,%ecx
f0100216:	89 0d 80 be 17 f0    	mov    %ecx,0xf017be80
		return 0;
f010021c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100221:	e9 9d 00 00 00       	jmp    f01002c3 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100226:	8b 0d 80 be 17 f0    	mov    0xf017be80,%ecx
f010022c:	f6 c1 40             	test   $0x40,%cl
f010022f:	74 0e                	je     f010023f <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100231:	83 c8 80             	or     $0xffffff80,%eax
f0100234:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100236:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100239:	89 0d 80 be 17 f0    	mov    %ecx,0xf017be80
	}

	shift |= shiftcode[data];
f010023f:	0f b6 d2             	movzbl %dl,%edx
f0100242:	0f b6 82 40 4b 10 f0 	movzbl -0xfefb4c0(%edx),%eax
f0100249:	0b 05 80 be 17 f0    	or     0xf017be80,%eax
	shift ^= togglecode[data];
f010024f:	0f b6 8a 40 4a 10 f0 	movzbl -0xfefb5c0(%edx),%ecx
f0100256:	31 c8                	xor    %ecx,%eax
f0100258:	a3 80 be 17 f0       	mov    %eax,0xf017be80

	c = charcode[shift & (CTL | SHIFT)][data];
f010025d:	89 c1                	mov    %eax,%ecx
f010025f:	83 e1 03             	and    $0x3,%ecx
f0100262:	8b 0c 8d 20 4a 10 f0 	mov    -0xfefb5e0(,%ecx,4),%ecx
f0100269:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010026d:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100270:	a8 08                	test   $0x8,%al
f0100272:	74 1b                	je     f010028f <kbd_proc_data+0xcf>
		if ('a' <= c && c <= 'z')
f0100274:	89 da                	mov    %ebx,%edx
f0100276:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100279:	83 f9 19             	cmp    $0x19,%ecx
f010027c:	77 05                	ja     f0100283 <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f010027e:	83 eb 20             	sub    $0x20,%ebx
f0100281:	eb 0c                	jmp    f010028f <kbd_proc_data+0xcf>
		else if ('A' <= c && c <= 'Z')
f0100283:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100286:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100289:	83 fa 19             	cmp    $0x19,%edx
f010028c:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010028f:	f7 d0                	not    %eax
f0100291:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100293:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100295:	f6 c2 06             	test   $0x6,%dl
f0100298:	75 29                	jne    f01002c3 <kbd_proc_data+0x103>
f010029a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002a0:	75 21                	jne    f01002c3 <kbd_proc_data+0x103>
		cprintf("Rebooting!\n");
f01002a2:	c7 04 24 ed 49 10 f0 	movl   $0xf01049ed,(%esp)
f01002a9:	e8 40 32 00 00       	call   f01034ee <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ae:	ba 92 00 00 00       	mov    $0x92,%edx
f01002b3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002b8:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002b9:	89 d8                	mov    %ebx,%eax
f01002bb:	eb 06                	jmp    f01002c3 <kbd_proc_data+0x103>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002c2:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002c3:	83 c4 14             	add    $0x14,%esp
f01002c6:	5b                   	pop    %ebx
f01002c7:	5d                   	pop    %ebp
f01002c8:	c3                   	ret    

f01002c9 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002c9:	55                   	push   %ebp
f01002ca:	89 e5                	mov    %esp,%ebp
f01002cc:	57                   	push   %edi
f01002cd:	56                   	push   %esi
f01002ce:	53                   	push   %ebx
f01002cf:	83 ec 1c             	sub    $0x1c,%esp
f01002d2:	89 c7                	mov    %eax,%edi
f01002d4:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d9:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002de:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002e3:	eb 06                	jmp    f01002eb <cons_putc+0x22>
f01002e5:	89 ca                	mov    %ecx,%edx
f01002e7:	ec                   	in     (%dx),%al
f01002e8:	ec                   	in     (%dx),%al
f01002e9:	ec                   	in     (%dx),%al
f01002ea:	ec                   	in     (%dx),%al
f01002eb:	89 f2                	mov    %esi,%edx
f01002ed:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002ee:	a8 20                	test   $0x20,%al
f01002f0:	75 05                	jne    f01002f7 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002f2:	83 eb 01             	sub    $0x1,%ebx
f01002f5:	75 ee                	jne    f01002e5 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01002f7:	89 f8                	mov    %edi,%eax
f01002f9:	0f b6 c0             	movzbl %al,%eax
f01002fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ff:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100304:	ee                   	out    %al,(%dx)
f0100305:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010030a:	be 79 03 00 00       	mov    $0x379,%esi
f010030f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100314:	eb 06                	jmp    f010031c <cons_putc+0x53>
f0100316:	89 ca                	mov    %ecx,%edx
f0100318:	ec                   	in     (%dx),%al
f0100319:	ec                   	in     (%dx),%al
f010031a:	ec                   	in     (%dx),%al
f010031b:	ec                   	in     (%dx),%al
f010031c:	89 f2                	mov    %esi,%edx
f010031e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010031f:	84 c0                	test   %al,%al
f0100321:	78 05                	js     f0100328 <cons_putc+0x5f>
f0100323:	83 eb 01             	sub    $0x1,%ebx
f0100326:	75 ee                	jne    f0100316 <cons_putc+0x4d>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100328:	ba 78 03 00 00       	mov    $0x378,%edx
f010032d:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100331:	ee                   	out    %al,(%dx)
f0100332:	b2 7a                	mov    $0x7a,%dl
f0100334:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100339:	ee                   	out    %al,(%dx)
f010033a:	b8 08 00 00 00       	mov    $0x8,%eax
f010033f:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100340:	89 fa                	mov    %edi,%edx
f0100342:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100348:	89 f8                	mov    %edi,%eax
f010034a:	80 cc 07             	or     $0x7,%ah
f010034d:	85 d2                	test   %edx,%edx
f010034f:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100352:	89 f8                	mov    %edi,%eax
f0100354:	0f b6 c0             	movzbl %al,%eax
f0100357:	83 f8 09             	cmp    $0x9,%eax
f010035a:	74 76                	je     f01003d2 <cons_putc+0x109>
f010035c:	83 f8 09             	cmp    $0x9,%eax
f010035f:	7f 0a                	jg     f010036b <cons_putc+0xa2>
f0100361:	83 f8 08             	cmp    $0x8,%eax
f0100364:	74 16                	je     f010037c <cons_putc+0xb3>
f0100366:	e9 9b 00 00 00       	jmp    f0100406 <cons_putc+0x13d>
f010036b:	83 f8 0a             	cmp    $0xa,%eax
f010036e:	66 90                	xchg   %ax,%ax
f0100370:	74 3a                	je     f01003ac <cons_putc+0xe3>
f0100372:	83 f8 0d             	cmp    $0xd,%eax
f0100375:	74 3d                	je     f01003b4 <cons_putc+0xeb>
f0100377:	e9 8a 00 00 00       	jmp    f0100406 <cons_putc+0x13d>
	case '\b':
		if (crt_pos > 0) {
f010037c:	0f b7 05 a8 c0 17 f0 	movzwl 0xf017c0a8,%eax
f0100383:	66 85 c0             	test   %ax,%ax
f0100386:	0f 84 e5 00 00 00    	je     f0100471 <cons_putc+0x1a8>
			crt_pos--;
f010038c:	83 e8 01             	sub    $0x1,%eax
f010038f:	66 a3 a8 c0 17 f0    	mov    %ax,0xf017c0a8
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100395:	0f b7 c0             	movzwl %ax,%eax
f0100398:	66 81 e7 00 ff       	and    $0xff00,%di
f010039d:	83 cf 20             	or     $0x20,%edi
f01003a0:	8b 15 ac c0 17 f0    	mov    0xf017c0ac,%edx
f01003a6:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003aa:	eb 78                	jmp    f0100424 <cons_putc+0x15b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003ac:	66 83 05 a8 c0 17 f0 	addw   $0x50,0xf017c0a8
f01003b3:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003b4:	0f b7 05 a8 c0 17 f0 	movzwl 0xf017c0a8,%eax
f01003bb:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003c1:	c1 e8 16             	shr    $0x16,%eax
f01003c4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003c7:	c1 e0 04             	shl    $0x4,%eax
f01003ca:	66 a3 a8 c0 17 f0    	mov    %ax,0xf017c0a8
f01003d0:	eb 52                	jmp    f0100424 <cons_putc+0x15b>
		break;
	case '\t':
		cons_putc(' ');
f01003d2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d7:	e8 ed fe ff ff       	call   f01002c9 <cons_putc>
		cons_putc(' ');
f01003dc:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e1:	e8 e3 fe ff ff       	call   f01002c9 <cons_putc>
		cons_putc(' ');
f01003e6:	b8 20 00 00 00       	mov    $0x20,%eax
f01003eb:	e8 d9 fe ff ff       	call   f01002c9 <cons_putc>
		cons_putc(' ');
f01003f0:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f5:	e8 cf fe ff ff       	call   f01002c9 <cons_putc>
		cons_putc(' ');
f01003fa:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ff:	e8 c5 fe ff ff       	call   f01002c9 <cons_putc>
f0100404:	eb 1e                	jmp    f0100424 <cons_putc+0x15b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100406:	0f b7 05 a8 c0 17 f0 	movzwl 0xf017c0a8,%eax
f010040d:	8d 50 01             	lea    0x1(%eax),%edx
f0100410:	66 89 15 a8 c0 17 f0 	mov    %dx,0xf017c0a8
f0100417:	0f b7 c0             	movzwl %ax,%eax
f010041a:	8b 15 ac c0 17 f0    	mov    0xf017c0ac,%edx
f0100420:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100424:	66 81 3d a8 c0 17 f0 	cmpw   $0x7cf,0xf017c0a8
f010042b:	cf 07 
f010042d:	76 42                	jbe    f0100471 <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010042f:	a1 ac c0 17 f0       	mov    0xf017c0ac,%eax
f0100434:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010043b:	00 
f010043c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100442:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100446:	89 04 24             	mov    %eax,(%esp)
f0100449:	e8 f6 40 00 00       	call   f0104544 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010044e:	8b 15 ac c0 17 f0    	mov    0xf017c0ac,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100454:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100459:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010045f:	83 c0 01             	add    $0x1,%eax
f0100462:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100467:	75 f0                	jne    f0100459 <cons_putc+0x190>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100469:	66 83 2d a8 c0 17 f0 	subw   $0x50,0xf017c0a8
f0100470:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100471:	8b 0d b0 c0 17 f0    	mov    0xf017c0b0,%ecx
f0100477:	b8 0e 00 00 00       	mov    $0xe,%eax
f010047c:	89 ca                	mov    %ecx,%edx
f010047e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010047f:	0f b7 1d a8 c0 17 f0 	movzwl 0xf017c0a8,%ebx
f0100486:	8d 71 01             	lea    0x1(%ecx),%esi
f0100489:	89 d8                	mov    %ebx,%eax
f010048b:	66 c1 e8 08          	shr    $0x8,%ax
f010048f:	89 f2                	mov    %esi,%edx
f0100491:	ee                   	out    %al,(%dx)
f0100492:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100497:	89 ca                	mov    %ecx,%edx
f0100499:	ee                   	out    %al,(%dx)
f010049a:	89 d8                	mov    %ebx,%eax
f010049c:	89 f2                	mov    %esi,%edx
f010049e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010049f:	83 c4 1c             	add    $0x1c,%esp
f01004a2:	5b                   	pop    %ebx
f01004a3:	5e                   	pop    %esi
f01004a4:	5f                   	pop    %edi
f01004a5:	5d                   	pop    %ebp
f01004a6:	c3                   	ret    

f01004a7 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004a7:	80 3d b4 c0 17 f0 00 	cmpb   $0x0,0xf017c0b4
f01004ae:	74 11                	je     f01004c1 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004b0:	55                   	push   %ebp
f01004b1:	89 e5                	mov    %esp,%ebp
f01004b3:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004b6:	b8 60 01 10 f0       	mov    $0xf0100160,%eax
f01004bb:	e8 bc fc ff ff       	call   f010017c <cons_intr>
}
f01004c0:	c9                   	leave  
f01004c1:	f3 c3                	repz ret 

f01004c3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004c3:	55                   	push   %ebp
f01004c4:	89 e5                	mov    %esp,%ebp
f01004c6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004c9:	b8 c0 01 10 f0       	mov    $0xf01001c0,%eax
f01004ce:	e8 a9 fc ff ff       	call   f010017c <cons_intr>
}
f01004d3:	c9                   	leave  
f01004d4:	c3                   	ret    

f01004d5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004d5:	55                   	push   %ebp
f01004d6:	89 e5                	mov    %esp,%ebp
f01004d8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004db:	e8 c7 ff ff ff       	call   f01004a7 <serial_intr>
	kbd_intr();
f01004e0:	e8 de ff ff ff       	call   f01004c3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004e5:	a1 a0 c0 17 f0       	mov    0xf017c0a0,%eax
f01004ea:	3b 05 a4 c0 17 f0    	cmp    0xf017c0a4,%eax
f01004f0:	74 26                	je     f0100518 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004f2:	8d 50 01             	lea    0x1(%eax),%edx
f01004f5:	89 15 a0 c0 17 f0    	mov    %edx,0xf017c0a0
f01004fb:	0f b6 88 a0 be 17 f0 	movzbl -0xfe84160(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100502:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100504:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010050a:	75 11                	jne    f010051d <cons_getc+0x48>
			cons.rpos = 0;
f010050c:	c7 05 a0 c0 17 f0 00 	movl   $0x0,0xf017c0a0
f0100513:	00 00 00 
f0100516:	eb 05                	jmp    f010051d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100518:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010051d:	c9                   	leave  
f010051e:	c3                   	ret    

f010051f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010051f:	55                   	push   %ebp
f0100520:	89 e5                	mov    %esp,%ebp
f0100522:	57                   	push   %edi
f0100523:	56                   	push   %esi
f0100524:	53                   	push   %ebx
f0100525:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100528:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010052f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100536:	5a a5 
	if (*cp != 0xA55A) {
f0100538:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010053f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100543:	74 11                	je     f0100556 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100545:	c7 05 b0 c0 17 f0 b4 	movl   $0x3b4,0xf017c0b0
f010054c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010054f:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f0100554:	eb 16                	jmp    f010056c <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100556:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010055d:	c7 05 b0 c0 17 f0 d4 	movl   $0x3d4,0xf017c0b0
f0100564:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100567:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010056c:	8b 0d b0 c0 17 f0    	mov    0xf017c0b0,%ecx
f0100572:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100577:	89 ca                	mov    %ecx,%edx
f0100579:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010057a:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010057d:	89 da                	mov    %ebx,%edx
f010057f:	ec                   	in     (%dx),%al
f0100580:	0f b6 f0             	movzbl %al,%esi
f0100583:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100586:	b8 0f 00 00 00       	mov    $0xf,%eax
f010058b:	89 ca                	mov    %ecx,%edx
f010058d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010058e:	89 da                	mov    %ebx,%edx
f0100590:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100591:	89 3d ac c0 17 f0    	mov    %edi,0xf017c0ac

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100597:	0f b6 d8             	movzbl %al,%ebx
f010059a:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010059c:	66 89 35 a8 c0 17 f0 	mov    %si,0xf017c0a8
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005a3:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ad:	89 f2                	mov    %esi,%edx
f01005af:	ee                   	out    %al,(%dx)
f01005b0:	b2 fb                	mov    $0xfb,%dl
f01005b2:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005b7:	ee                   	out    %al,(%dx)
f01005b8:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005bd:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005c2:	89 da                	mov    %ebx,%edx
f01005c4:	ee                   	out    %al,(%dx)
f01005c5:	b2 f9                	mov    $0xf9,%dl
f01005c7:	b8 00 00 00 00       	mov    $0x0,%eax
f01005cc:	ee                   	out    %al,(%dx)
f01005cd:	b2 fb                	mov    $0xfb,%dl
f01005cf:	b8 03 00 00 00       	mov    $0x3,%eax
f01005d4:	ee                   	out    %al,(%dx)
f01005d5:	b2 fc                	mov    $0xfc,%dl
f01005d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01005dc:	ee                   	out    %al,(%dx)
f01005dd:	b2 f9                	mov    $0xf9,%dl
f01005df:	b8 01 00 00 00       	mov    $0x1,%eax
f01005e4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005e5:	b2 fd                	mov    $0xfd,%dl
f01005e7:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005e8:	3c ff                	cmp    $0xff,%al
f01005ea:	0f 95 c1             	setne  %cl
f01005ed:	88 0d b4 c0 17 f0    	mov    %cl,0xf017c0b4
f01005f3:	89 f2                	mov    %esi,%edx
f01005f5:	ec                   	in     (%dx),%al
f01005f6:	89 da                	mov    %ebx,%edx
f01005f8:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005f9:	84 c9                	test   %cl,%cl
f01005fb:	75 0c                	jne    f0100609 <cons_init+0xea>
		cprintf("Serial port does not exist!\n");
f01005fd:	c7 04 24 f9 49 10 f0 	movl   $0xf01049f9,(%esp)
f0100604:	e8 e5 2e 00 00       	call   f01034ee <cprintf>
}
f0100609:	83 c4 1c             	add    $0x1c,%esp
f010060c:	5b                   	pop    %ebx
f010060d:	5e                   	pop    %esi
f010060e:	5f                   	pop    %edi
f010060f:	5d                   	pop    %ebp
f0100610:	c3                   	ret    

f0100611 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100611:	55                   	push   %ebp
f0100612:	89 e5                	mov    %esp,%ebp
f0100614:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100617:	8b 45 08             	mov    0x8(%ebp),%eax
f010061a:	e8 aa fc ff ff       	call   f01002c9 <cons_putc>
}
f010061f:	c9                   	leave  
f0100620:	c3                   	ret    

f0100621 <getchar>:

int
getchar(void)
{
f0100621:	55                   	push   %ebp
f0100622:	89 e5                	mov    %esp,%ebp
f0100624:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100627:	e8 a9 fe ff ff       	call   f01004d5 <cons_getc>
f010062c:	85 c0                	test   %eax,%eax
f010062e:	74 f7                	je     f0100627 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100630:	c9                   	leave  
f0100631:	c3                   	ret    

f0100632 <iscons>:

int
iscons(int fdnum)
{
f0100632:	55                   	push   %ebp
f0100633:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100635:	b8 01 00 00 00       	mov    $0x1,%eax
f010063a:	5d                   	pop    %ebp
f010063b:	c3                   	ret    
f010063c:	66 90                	xchg   %ax,%ax
f010063e:	66 90                	xchg   %ax,%ax

f0100640 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100640:	55                   	push   %ebp
f0100641:	89 e5                	mov    %esp,%ebp
f0100643:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100646:	c7 44 24 08 40 4c 10 	movl   $0xf0104c40,0x8(%esp)
f010064d:	f0 
f010064e:	c7 44 24 04 5e 4c 10 	movl   $0xf0104c5e,0x4(%esp)
f0100655:	f0 
f0100656:	c7 04 24 63 4c 10 f0 	movl   $0xf0104c63,(%esp)
f010065d:	e8 8c 2e 00 00       	call   f01034ee <cprintf>
f0100662:	c7 44 24 08 dc 4c 10 	movl   $0xf0104cdc,0x8(%esp)
f0100669:	f0 
f010066a:	c7 44 24 04 6c 4c 10 	movl   $0xf0104c6c,0x4(%esp)
f0100671:	f0 
f0100672:	c7 04 24 63 4c 10 f0 	movl   $0xf0104c63,(%esp)
f0100679:	e8 70 2e 00 00       	call   f01034ee <cprintf>
	return 0;
}
f010067e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100683:	c9                   	leave  
f0100684:	c3                   	ret    

f0100685 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100685:	55                   	push   %ebp
f0100686:	89 e5                	mov    %esp,%ebp
f0100688:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010068b:	c7 04 24 75 4c 10 f0 	movl   $0xf0104c75,(%esp)
f0100692:	e8 57 2e 00 00       	call   f01034ee <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100697:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010069e:	00 
f010069f:	c7 04 24 04 4d 10 f0 	movl   $0xf0104d04,(%esp)
f01006a6:	e8 43 2e 00 00       	call   f01034ee <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006ab:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006b2:	00 
f01006b3:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006ba:	f0 
f01006bb:	c7 04 24 2c 4d 10 f0 	movl   $0xf0104d2c,(%esp)
f01006c2:	e8 27 2e 00 00       	call   f01034ee <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006c7:	c7 44 24 08 87 49 10 	movl   $0x104987,0x8(%esp)
f01006ce:	00 
f01006cf:	c7 44 24 04 87 49 10 	movl   $0xf0104987,0x4(%esp)
f01006d6:	f0 
f01006d7:	c7 04 24 50 4d 10 f0 	movl   $0xf0104d50,(%esp)
f01006de:	e8 0b 2e 00 00       	call   f01034ee <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006e3:	c7 44 24 08 65 be 17 	movl   $0x17be65,0x8(%esp)
f01006ea:	00 
f01006eb:	c7 44 24 04 65 be 17 	movl   $0xf017be65,0x4(%esp)
f01006f2:	f0 
f01006f3:	c7 04 24 74 4d 10 f0 	movl   $0xf0104d74,(%esp)
f01006fa:	e8 ef 2d 00 00       	call   f01034ee <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006ff:	c7 44 24 08 90 cd 17 	movl   $0x17cd90,0x8(%esp)
f0100706:	00 
f0100707:	c7 44 24 04 90 cd 17 	movl   $0xf017cd90,0x4(%esp)
f010070e:	f0 
f010070f:	c7 04 24 98 4d 10 f0 	movl   $0xf0104d98,(%esp)
f0100716:	e8 d3 2d 00 00       	call   f01034ee <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010071b:	b8 8f d1 17 f0       	mov    $0xf017d18f,%eax
f0100720:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100725:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010072a:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100730:	85 c0                	test   %eax,%eax
f0100732:	0f 48 c2             	cmovs  %edx,%eax
f0100735:	c1 f8 0a             	sar    $0xa,%eax
f0100738:	89 44 24 04          	mov    %eax,0x4(%esp)
f010073c:	c7 04 24 bc 4d 10 f0 	movl   $0xf0104dbc,(%esp)
f0100743:	e8 a6 2d 00 00       	call   f01034ee <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100748:	b8 00 00 00 00       	mov    $0x0,%eax
f010074d:	c9                   	leave  
f010074e:	c3                   	ret    

f010074f <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010074f:	55                   	push   %ebp
f0100750:	89 e5                	mov    %esp,%ebp
f0100752:	56                   	push   %esi
f0100753:	53                   	push   %ebx
f0100754:	83 ec 40             	sub    $0x40,%esp
	uint32_t ebpr = 1;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebpr));
	uint32_t *ptr = (uint32_t*)ebpr ;
f0100757:	89 eb                	mov    %ebp,%ebx
	
	//__asm __volatile("movl %%ebp,%0" : "=r" (ebpr));
	//ptr= (uint32_t*)ebpr;	
	cprintf("EBPR :%08x  ,EIP %08x  ,args:  %08x , %08x \n",ptr,*(ptr+1),*(ptr+2),*(ptr+3));
	address	= *(ptr+1);
	debuginfo_eip(address, &eipinfo);
f0100759:	8d 75 e0             	lea    -0x20(%ebp),%esi
	__asm __volatile("movl %%ebp,%0" : "=r" (ebpr));
	uint32_t *ptr = (uint32_t*)ebpr ;
	uint32_t *temp;
	uint32_t address;
	struct Eipdebuginfo eipinfo;
	while(*ptr!=0)
f010075c:	eb 57                	jmp    f01007b5 <mon_backtrace+0x66>
	{
	
	//__asm __volatile("movl %%ebp,%0" : "=r" (ebpr));
	//ptr= (uint32_t*)ebpr;	
	cprintf("EBPR :%08x  ,EIP %08x  ,args:  %08x , %08x \n",ptr,*(ptr+1),*(ptr+2),*(ptr+3));
f010075e:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100761:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100765:	8b 43 08             	mov    0x8(%ebx),%eax
f0100768:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010076c:	8b 43 04             	mov    0x4(%ebx),%eax
f010076f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100773:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100777:	c7 04 24 e8 4d 10 f0 	movl   $0xf0104de8,(%esp)
f010077e:	e8 6b 2d 00 00       	call   f01034ee <cprintf>
	address	= *(ptr+1);
	debuginfo_eip(address, &eipinfo);
f0100783:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100787:	8b 43 04             	mov    0x4(%ebx),%eax
f010078a:	89 04 24             	mov    %eax,(%esp)
f010078d:	e8 81 32 00 00       	call   f0103a13 <debuginfo_eip>
	cprintf("%s  , %d  ,  %s \n",eipinfo.eip_file,eipinfo.eip_line,eipinfo.eip_fn_name);
f0100792:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100795:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100799:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010079c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01007a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007a7:	c7 04 24 8e 4c 10 f0 	movl   $0xf0104c8e,(%esp)
f01007ae:	e8 3b 2d 00 00       	call   f01034ee <cprintf>
	temp = ptr;
	ptr = (uint32_t*) *temp;	
f01007b3:	8b 1b                	mov    (%ebx),%ebx
	__asm __volatile("movl %%ebp,%0" : "=r" (ebpr));
	uint32_t *ptr = (uint32_t*)ebpr ;
	uint32_t *temp;
	uint32_t address;
	struct Eipdebuginfo eipinfo;
	while(*ptr!=0)
f01007b5:	83 3b 00             	cmpl   $0x0,(%ebx)
f01007b8:	75 a4                	jne    f010075e <mon_backtrace+0xf>
	cprintf("%s  , %d  ,  %s \n",eipinfo.eip_file,eipinfo.eip_line,eipinfo.eip_fn_name);
	temp = ptr;
	ptr = (uint32_t*) *temp;	
	}	
	return 0;
}
f01007ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01007bf:	83 c4 40             	add    $0x40,%esp
f01007c2:	5b                   	pop    %ebx
f01007c3:	5e                   	pop    %esi
f01007c4:	5d                   	pop    %ebp
f01007c5:	c3                   	ret    

f01007c6 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007c6:	55                   	push   %ebp
f01007c7:	89 e5                	mov    %esp,%ebp
f01007c9:	57                   	push   %edi
f01007ca:	56                   	push   %esi
f01007cb:	53                   	push   %ebx
f01007cc:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007cf:	c7 04 24 18 4e 10 f0 	movl   $0xf0104e18,(%esp)
f01007d6:	e8 13 2d 00 00       	call   f01034ee <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007db:	c7 04 24 3c 4e 10 f0 	movl   $0xf0104e3c,(%esp)
f01007e2:	e8 07 2d 00 00       	call   f01034ee <cprintf>

	if (tf != NULL)
f01007e7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01007eb:	74 0b                	je     f01007f8 <monitor+0x32>
		print_trapframe(tf);
f01007ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01007f0:	89 04 24             	mov    %eax,(%esp)
f01007f3:	e8 1e 2e 00 00       	call   f0103616 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f01007f8:	c7 04 24 a0 4c 10 f0 	movl   $0xf0104ca0,(%esp)
f01007ff:	e8 9c 3a 00 00       	call   f01042a0 <readline>
f0100804:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100806:	85 c0                	test   %eax,%eax
f0100808:	74 ee                	je     f01007f8 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010080a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100811:	be 00 00 00 00       	mov    $0x0,%esi
f0100816:	eb 0a                	jmp    f0100822 <monitor+0x5c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100818:	c6 03 00             	movb   $0x0,(%ebx)
f010081b:	89 f7                	mov    %esi,%edi
f010081d:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100820:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100822:	0f b6 03             	movzbl (%ebx),%eax
f0100825:	84 c0                	test   %al,%al
f0100827:	74 63                	je     f010088c <monitor+0xc6>
f0100829:	0f be c0             	movsbl %al,%eax
f010082c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100830:	c7 04 24 a4 4c 10 f0 	movl   $0xf0104ca4,(%esp)
f0100837:	e8 7e 3c 00 00       	call   f01044ba <strchr>
f010083c:	85 c0                	test   %eax,%eax
f010083e:	75 d8                	jne    f0100818 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100840:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100843:	74 47                	je     f010088c <monitor+0xc6>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100845:	83 fe 0f             	cmp    $0xf,%esi
f0100848:	75 16                	jne    f0100860 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010084a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100851:	00 
f0100852:	c7 04 24 a9 4c 10 f0 	movl   $0xf0104ca9,(%esp)
f0100859:	e8 90 2c 00 00       	call   f01034ee <cprintf>
f010085e:	eb 98                	jmp    f01007f8 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100860:	8d 7e 01             	lea    0x1(%esi),%edi
f0100863:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100867:	eb 03                	jmp    f010086c <monitor+0xa6>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100869:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010086c:	0f b6 03             	movzbl (%ebx),%eax
f010086f:	84 c0                	test   %al,%al
f0100871:	74 ad                	je     f0100820 <monitor+0x5a>
f0100873:	0f be c0             	movsbl %al,%eax
f0100876:	89 44 24 04          	mov    %eax,0x4(%esp)
f010087a:	c7 04 24 a4 4c 10 f0 	movl   $0xf0104ca4,(%esp)
f0100881:	e8 34 3c 00 00       	call   f01044ba <strchr>
f0100886:	85 c0                	test   %eax,%eax
f0100888:	74 df                	je     f0100869 <monitor+0xa3>
f010088a:	eb 94                	jmp    f0100820 <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f010088c:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100893:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100894:	85 f6                	test   %esi,%esi
f0100896:	0f 84 5c ff ff ff    	je     f01007f8 <monitor+0x32>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010089c:	c7 44 24 04 5e 4c 10 	movl   $0xf0104c5e,0x4(%esp)
f01008a3:	f0 
f01008a4:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008a7:	89 04 24             	mov    %eax,(%esp)
f01008aa:	e8 ad 3b 00 00       	call   f010445c <strcmp>
f01008af:	85 c0                	test   %eax,%eax
f01008b1:	74 1b                	je     f01008ce <monitor+0x108>
f01008b3:	c7 44 24 04 6c 4c 10 	movl   $0xf0104c6c,0x4(%esp)
f01008ba:	f0 
f01008bb:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008be:	89 04 24             	mov    %eax,(%esp)
f01008c1:	e8 96 3b 00 00       	call   f010445c <strcmp>
f01008c6:	85 c0                	test   %eax,%eax
f01008c8:	75 2f                	jne    f01008f9 <monitor+0x133>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008ca:	b0 01                	mov    $0x1,%al
f01008cc:	eb 05                	jmp    f01008d3 <monitor+0x10d>
		if (strcmp(argv[0], commands[i].name) == 0)
f01008ce:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f01008d3:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01008d6:	01 d0                	add    %edx,%eax
f01008d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01008db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01008df:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008e2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01008e6:	89 34 24             	mov    %esi,(%esp)
f01008e9:	ff 14 85 6c 4e 10 f0 	call   *-0xfefb194(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008f0:	85 c0                	test   %eax,%eax
f01008f2:	78 1d                	js     f0100911 <monitor+0x14b>
f01008f4:	e9 ff fe ff ff       	jmp    f01007f8 <monitor+0x32>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008f9:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100900:	c7 04 24 c6 4c 10 f0 	movl   $0xf0104cc6,(%esp)
f0100907:	e8 e2 2b 00 00       	call   f01034ee <cprintf>
f010090c:	e9 e7 fe ff ff       	jmp    f01007f8 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100911:	83 c4 5c             	add    $0x5c,%esp
f0100914:	5b                   	pop    %ebx
f0100915:	5e                   	pop    %esi
f0100916:	5f                   	pop    %edi
f0100917:	5d                   	pop    %ebp
f0100918:	c3                   	ret    
f0100919:	66 90                	xchg   %ax,%ax
f010091b:	66 90                	xchg   %ax,%ax
f010091d:	66 90                	xchg   %ax,%ax
f010091f:	90                   	nop

f0100920 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100920:	55                   	push   %ebp
f0100921:	89 e5                	mov    %esp,%ebp
f0100923:	53                   	push   %ebx
f0100924:	83 ec 14             	sub    $0x14,%esp
f0100927:	89 c3                	mov    %eax,%ebx
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
		
	if (!nextfree) {
f0100929:	83 3d bc c0 17 f0 00 	cmpl   $0x0,0xf017c0bc
f0100930:	75 23                	jne    f0100955 <boot_alloc+0x35>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100932:	b8 8f dd 17 f0       	mov    $0xf017dd8f,%eax
f0100937:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010093c:	a3 bc c0 17 f0       	mov    %eax,0xf017c0bc
		cprintf("End:%x\n",end);
f0100941:	c7 44 24 04 90 cd 17 	movl   $0xf017cd90,0x4(%esp)
f0100948:	f0 
f0100949:	c7 04 24 7c 4e 10 f0 	movl   $0xf0104e7c,(%esp)
f0100950:	e8 99 2b 00 00       	call   f01034ee <cprintf>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//return NULL;
	next = nextfree;
f0100955:	a1 bc c0 17 f0       	mov    0xf017c0bc,%eax
	nextfree = ROUNDUP((char*)(nextfree + n) , PGSIZE);	
f010095a:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100961:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100967:	89 15 bc c0 17 f0    	mov    %edx,0xf017c0bc
		if (nextfree > (char *)(KERNBASE + PTSIZE))
			panic("boot_alloc: out of memory\n");
	}

	return result;*/
}
f010096d:	83 c4 14             	add    $0x14,%esp
f0100970:	5b                   	pop    %ebx
f0100971:	5d                   	pop    %ebp
f0100972:	c3                   	ret    

f0100973 <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100973:	2b 05 b8 c0 17 f0    	sub    0xf017c0b8,%eax
f0100979:	c1 f8 03             	sar    $0x3,%eax
f010097c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010097f:	89 c2                	mov    %eax,%edx
f0100981:	c1 ea 0c             	shr    $0xc,%edx
f0100984:	3b 15 88 cd 17 f0    	cmp    0xf017cd88,%edx
f010098a:	72 26                	jb     f01009b2 <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f010098c:	55                   	push   %ebp
f010098d:	89 e5                	mov    %esp,%ebp
f010098f:	83 ec 18             	sub    $0x18,%esp

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100992:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100996:	c7 44 24 08 04 52 10 	movl   $0xf0105204,0x8(%esp)
f010099d:	f0 
f010099e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01009a5:	00 
f01009a6:	c7 04 24 84 4e 10 f0 	movl   $0xf0104e84,(%esp)
f01009ad:	e8 04 f7 ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f01009b2:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
f01009b7:	c3                   	ret    

f01009b8 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01009b8:	89 d1                	mov    %edx,%ecx
f01009ba:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01009bd:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009c0:	a8 01                	test   $0x1,%al
f01009c2:	74 5d                	je     f0100a21 <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009c9:	89 c1                	mov    %eax,%ecx
f01009cb:	c1 e9 0c             	shr    $0xc,%ecx
f01009ce:	3b 0d 88 cd 17 f0    	cmp    0xf017cd88,%ecx
f01009d4:	72 26                	jb     f01009fc <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009d6:	55                   	push   %ebp
f01009d7:	89 e5                	mov    %esp,%ebp
f01009d9:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009e0:	c7 44 24 08 04 52 10 	movl   $0xf0105204,0x8(%esp)
f01009e7:	f0 
f01009e8:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f01009ef:	00 
f01009f0:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01009f7:	e8 ba f6 ff ff       	call   f01000b6 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f01009fc:	c1 ea 0c             	shr    $0xc,%edx
f01009ff:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a05:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a0c:	89 c2                	mov    %eax,%edx
f0100a0e:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a16:	85 d2                	test   %edx,%edx
f0100a18:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a1d:	0f 44 c2             	cmove  %edx,%eax
f0100a20:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100a26:	c3                   	ret    

f0100a27 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a27:	55                   	push   %ebp
f0100a28:	89 e5                	mov    %esp,%ebp
f0100a2a:	57                   	push   %edi
f0100a2b:	56                   	push   %esi
f0100a2c:	53                   	push   %ebx
f0100a2d:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a30:	84 c0                	test   %al,%al
f0100a32:	0f 85 07 03 00 00    	jne    f0100d3f <check_page_free_list+0x318>
f0100a38:	e9 14 03 00 00       	jmp    f0100d51 <check_page_free_list+0x32a>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;
	//cprintf("000000000000011\n");
	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a3d:	c7 44 24 08 28 52 10 	movl   $0xf0105228,0x8(%esp)
f0100a44:	f0 
f0100a45:	c7 44 24 04 8d 02 00 	movl   $0x28d,0x4(%esp)
f0100a4c:	00 
f0100a4d:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0100a54:	e8 5d f6 ff ff       	call   f01000b6 <_panic>
	//cprintf("000000000000022\n");
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a59:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a5c:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a5f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a62:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a65:	89 c2                	mov    %eax,%edx
f0100a67:	2b 15 b8 c0 17 f0    	sub    0xf017c0b8,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a6d:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a73:	0f 95 c2             	setne  %dl
f0100a76:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a79:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a7d:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a7f:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a83:	8b 00                	mov    (%eax),%eax
f0100a85:	85 c0                	test   %eax,%eax
f0100a87:	75 dc                	jne    f0100a65 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a8c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a92:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a95:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a98:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a9a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a9d:	a3 c0 c0 17 f0       	mov    %eax,0xf017c0c0
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100aa2:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100aa7:	8b 1d c0 c0 17 f0    	mov    0xf017c0c0,%ebx
f0100aad:	eb 63                	jmp    f0100b12 <check_page_free_list+0xeb>
f0100aaf:	89 d8                	mov    %ebx,%eax
f0100ab1:	2b 05 b8 c0 17 f0    	sub    0xf017c0b8,%eax
f0100ab7:	c1 f8 03             	sar    $0x3,%eax
f0100aba:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100abd:	89 c2                	mov    %eax,%edx
f0100abf:	c1 ea 16             	shr    $0x16,%edx
f0100ac2:	39 f2                	cmp    %esi,%edx
f0100ac4:	73 4a                	jae    f0100b10 <check_page_free_list+0xe9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ac6:	89 c2                	mov    %eax,%edx
f0100ac8:	c1 ea 0c             	shr    $0xc,%edx
f0100acb:	3b 15 88 cd 17 f0    	cmp    0xf017cd88,%edx
f0100ad1:	72 20                	jb     f0100af3 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ad3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ad7:	c7 44 24 08 04 52 10 	movl   $0xf0105204,0x8(%esp)
f0100ade:	f0 
f0100adf:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100ae6:	00 
f0100ae7:	c7 04 24 84 4e 10 f0 	movl   $0xf0104e84,(%esp)
f0100aee:	e8 c3 f5 ff ff       	call   f01000b6 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100af3:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100afa:	00 
f0100afb:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100b02:	00 
	return (void *)(pa + KERNBASE);
f0100b03:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b08:	89 04 24             	mov    %eax,(%esp)
f0100b0b:	e8 e7 39 00 00       	call   f01044f7 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b10:	8b 1b                	mov    (%ebx),%ebx
f0100b12:	85 db                	test   %ebx,%ebx
f0100b14:	75 99                	jne    f0100aaf <check_page_free_list+0x88>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b16:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b1b:	e8 00 fe ff ff       	call   f0100920 <boot_alloc>
f0100b20:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b23:	8b 15 c0 c0 17 f0    	mov    0xf017c0c0,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b29:	8b 0d b8 c0 17 f0    	mov    0xf017c0b8,%ecx
		assert(pp < pages + npages);
f0100b2f:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0100b34:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100b37:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100b3a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b3d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b40:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b45:	89 5d cc             	mov    %ebx,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b48:	e9 97 01 00 00       	jmp    f0100ce4 <check_page_free_list+0x2bd>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b4d:	39 ca                	cmp    %ecx,%edx
f0100b4f:	73 24                	jae    f0100b75 <check_page_free_list+0x14e>
f0100b51:	c7 44 24 0c 9e 4e 10 	movl   $0xf0104e9e,0xc(%esp)
f0100b58:	f0 
f0100b59:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0100b60:	f0 
f0100b61:	c7 44 24 04 a7 02 00 	movl   $0x2a7,0x4(%esp)
f0100b68:	00 
f0100b69:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0100b70:	e8 41 f5 ff ff       	call   f01000b6 <_panic>
		assert(pp < pages + npages);
f0100b75:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100b78:	72 24                	jb     f0100b9e <check_page_free_list+0x177>
f0100b7a:	c7 44 24 0c bf 4e 10 	movl   $0xf0104ebf,0xc(%esp)
f0100b81:	f0 
f0100b82:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0100b89:	f0 
f0100b8a:	c7 44 24 04 a8 02 00 	movl   $0x2a8,0x4(%esp)
f0100b91:	00 
f0100b92:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0100b99:	e8 18 f5 ff ff       	call   f01000b6 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b9e:	89 d0                	mov    %edx,%eax
f0100ba0:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100ba3:	a8 07                	test   $0x7,%al
f0100ba5:	74 24                	je     f0100bcb <check_page_free_list+0x1a4>
f0100ba7:	c7 44 24 0c 4c 52 10 	movl   $0xf010524c,0xc(%esp)
f0100bae:	f0 
f0100baf:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0100bb6:	f0 
f0100bb7:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
f0100bbe:	00 
f0100bbf:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0100bc6:	e8 eb f4 ff ff       	call   f01000b6 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bcb:	c1 f8 03             	sar    $0x3,%eax
f0100bce:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100bd1:	85 c0                	test   %eax,%eax
f0100bd3:	75 24                	jne    f0100bf9 <check_page_free_list+0x1d2>
f0100bd5:	c7 44 24 0c d3 4e 10 	movl   $0xf0104ed3,0xc(%esp)
f0100bdc:	f0 
f0100bdd:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0100be4:	f0 
f0100be5:	c7 44 24 04 ac 02 00 	movl   $0x2ac,0x4(%esp)
f0100bec:	00 
f0100bed:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0100bf4:	e8 bd f4 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bf9:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bfe:	75 24                	jne    f0100c24 <check_page_free_list+0x1fd>
f0100c00:	c7 44 24 0c e4 4e 10 	movl   $0xf0104ee4,0xc(%esp)
f0100c07:	f0 
f0100c08:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0100c0f:	f0 
f0100c10:	c7 44 24 04 ad 02 00 	movl   $0x2ad,0x4(%esp)
f0100c17:	00 
f0100c18:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0100c1f:	e8 92 f4 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c24:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c29:	75 24                	jne    f0100c4f <check_page_free_list+0x228>
f0100c2b:	c7 44 24 0c 80 52 10 	movl   $0xf0105280,0xc(%esp)
f0100c32:	f0 
f0100c33:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0100c3a:	f0 
f0100c3b:	c7 44 24 04 ae 02 00 	movl   $0x2ae,0x4(%esp)
f0100c42:	00 
f0100c43:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0100c4a:	e8 67 f4 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c4f:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c54:	75 24                	jne    f0100c7a <check_page_free_list+0x253>
f0100c56:	c7 44 24 0c fd 4e 10 	movl   $0xf0104efd,0xc(%esp)
f0100c5d:	f0 
f0100c5e:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0100c65:	f0 
f0100c66:	c7 44 24 04 af 02 00 	movl   $0x2af,0x4(%esp)
f0100c6d:	00 
f0100c6e:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0100c75:	e8 3c f4 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c7a:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c7f:	76 58                	jbe    f0100cd9 <check_page_free_list+0x2b2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c81:	89 c3                	mov    %eax,%ebx
f0100c83:	c1 eb 0c             	shr    $0xc,%ebx
f0100c86:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0100c89:	77 20                	ja     f0100cab <check_page_free_list+0x284>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c8f:	c7 44 24 08 04 52 10 	movl   $0xf0105204,0x8(%esp)
f0100c96:	f0 
f0100c97:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100c9e:	00 
f0100c9f:	c7 04 24 84 4e 10 f0 	movl   $0xf0104e84,(%esp)
f0100ca6:	e8 0b f4 ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f0100cab:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cb0:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100cb3:	76 2a                	jbe    f0100cdf <check_page_free_list+0x2b8>
f0100cb5:	c7 44 24 0c a4 52 10 	movl   $0xf01052a4,0xc(%esp)
f0100cbc:	f0 
f0100cbd:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0100cc4:	f0 
f0100cc5:	c7 44 24 04 b0 02 00 	movl   $0x2b0,0x4(%esp)
f0100ccc:	00 
f0100ccd:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0100cd4:	e8 dd f3 ff ff       	call   f01000b6 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100cd9:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
f0100cdd:	eb 03                	jmp    f0100ce2 <check_page_free_list+0x2bb>
		else
			++nfree_extmem;
f0100cdf:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ce2:	8b 12                	mov    (%edx),%edx
f0100ce4:	85 d2                	test   %edx,%edx
f0100ce6:	0f 85 61 fe ff ff    	jne    f0100b4d <check_page_free_list+0x126>
f0100cec:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100cef:	85 db                	test   %ebx,%ebx
f0100cf1:	7f 24                	jg     f0100d17 <check_page_free_list+0x2f0>
f0100cf3:	c7 44 24 0c 17 4f 10 	movl   $0xf0104f17,0xc(%esp)
f0100cfa:	f0 
f0100cfb:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0100d02:	f0 
f0100d03:	c7 44 24 04 b8 02 00 	movl   $0x2b8,0x4(%esp)
f0100d0a:	00 
f0100d0b:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0100d12:	e8 9f f3 ff ff       	call   f01000b6 <_panic>
	assert(nfree_extmem > 0);
f0100d17:	85 ff                	test   %edi,%edi
f0100d19:	7f 4d                	jg     f0100d68 <check_page_free_list+0x341>
f0100d1b:	c7 44 24 0c 29 4f 10 	movl   $0xf0104f29,0xc(%esp)
f0100d22:	f0 
f0100d23:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0100d2a:	f0 
f0100d2b:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
f0100d32:	00 
f0100d33:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0100d3a:	e8 77 f3 ff ff       	call   f01000b6 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;
	//cprintf("000000000000011\n");
	if (!page_free_list)
f0100d3f:	a1 c0 c0 17 f0       	mov    0xf017c0c0,%eax
f0100d44:	85 c0                	test   %eax,%eax
f0100d46:	0f 85 0d fd ff ff    	jne    f0100a59 <check_page_free_list+0x32>
f0100d4c:	e9 ec fc ff ff       	jmp    f0100a3d <check_page_free_list+0x16>
f0100d51:	83 3d c0 c0 17 f0 00 	cmpl   $0x0,0xf017c0c0
f0100d58:	0f 84 df fc ff ff    	je     f0100a3d <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d5e:	be 00 04 00 00       	mov    $0x400,%esi
f0100d63:	e9 3f fd ff ff       	jmp    f0100aa7 <check_page_free_list+0x80>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100d68:	83 c4 4c             	add    $0x4c,%esp
f0100d6b:	5b                   	pop    %ebx
f0100d6c:	5e                   	pop    %esi
f0100d6d:	5f                   	pop    %edi
f0100d6e:	5d                   	pop    %ebp
f0100d6f:	c3                   	ret    

f0100d70 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d70:	55                   	push   %ebp
f0100d71:	89 e5                	mov    %esp,%ebp
f0100d73:	53                   	push   %ebx
f0100d74:	83 ec 14             	sub    $0x14,%esp
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	//cprintf("EXTPHYSMEM: %x,boot_alloc (0): %x\n",EXTPHYSMEM,boot_alloc (0));
	cprintf("pages :%x\n",pages);
f0100d77:	a1 b8 c0 17 f0       	mov    0xf017c0b8,%eax
f0100d7c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d80:	c7 04 24 3a 4f 10 f0 	movl   $0xf0104f3a,(%esp)
f0100d87:	e8 62 27 00 00       	call   f01034ee <cprintf>
	cprintf("pagefreelist :%x\n",page_free_list);
f0100d8c:	a1 c0 c0 17 f0       	mov    0xf017c0c0,%eax
f0100d91:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d95:	c7 04 24 45 4f 10 f0 	movl   $0xf0104f45,(%esp)
f0100d9c:	e8 4d 27 00 00       	call   f01034ee <cprintf>
	for (i = 1; i < npages ; i++) 
f0100da1:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100da6:	e9 f1 00 00 00       	jmp    f0100e9c <page_init+0x12c>
	{
		
		if(i< npages_basemem)	
f0100dab:	3b 1d c4 c0 17 f0    	cmp    0xf017c0c4,%ebx
f0100db1:	73 2d                	jae    f0100de0 <page_init+0x70>
f0100db3:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
		{
			pages[i].pp_ref = 0;
f0100dba:	89 c2                	mov    %eax,%edx
f0100dbc:	03 15 b8 c0 17 f0    	add    0xf017c0b8,%edx
f0100dc2:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100dc8:	8b 0d c0 c0 17 f0    	mov    0xf017c0c0,%ecx
f0100dce:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100dd0:	03 05 b8 c0 17 f0    	add    0xf017c0b8,%eax
f0100dd6:	a3 c0 c0 17 f0       	mov    %eax,0xf017c0c0
f0100ddb:	e9 b9 00 00 00       	jmp    f0100e99 <page_init+0x129>
f0100de0:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
		}		 
		else if ((i >=IOPHYSMEM/PGSIZE)&&i<(EXTPHYSMEM/PGSIZE))
f0100de6:	83 f8 5f             	cmp    $0x5f,%eax
f0100de9:	0f 86 aa 00 00 00    	jbe    f0100e99 <page_init+0x129>
		{
			;//I0 Hole
		}		
		else if ((i >= EXTPHYSMEM / PGSIZE) && (i <PADDR(boot_alloc (0))/PGSIZE))
f0100def:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100df5:	76 3d                	jbe    f0100e34 <page_init+0xc4>
f0100df7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dfc:	e8 1f fb ff ff       	call   f0100920 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e01:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e06:	77 20                	ja     f0100e28 <page_init+0xb8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e08:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e0c:	c7 44 24 08 ec 52 10 	movl   $0xf01052ec,0x8(%esp)
f0100e13:	f0 
f0100e14:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
f0100e1b:	00 
f0100e1c:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0100e23:	e8 8e f2 ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100e28:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e2d:	c1 e8 0c             	shr    $0xc,%eax
f0100e30:	39 c3                	cmp    %eax,%ebx
f0100e32:	72 65                	jb     f0100e99 <page_init+0x129>
			;		
		else if (i >=PADDR(boot_alloc(0))/PGSIZE)
f0100e34:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e39:	e8 e2 fa ff ff       	call   f0100920 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e3e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e43:	77 20                	ja     f0100e65 <page_init+0xf5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e45:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e49:	c7 44 24 08 ec 52 10 	movl   $0xf01052ec,0x8(%esp)
f0100e50:	f0 
f0100e51:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
f0100e58:	00 
f0100e59:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0100e60:	e8 51 f2 ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100e65:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e6a:	c1 e8 0c             	shr    $0xc,%eax
f0100e6d:	39 c3                	cmp    %eax,%ebx
f0100e6f:	72 28                	jb     f0100e99 <page_init+0x129>
f0100e71:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
		{
			pages[i].pp_ref = 0;
f0100e78:	89 c2                	mov    %eax,%edx
f0100e7a:	03 15 b8 c0 17 f0    	add    0xf017c0b8,%edx
f0100e80:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100e86:	8b 0d c0 c0 17 f0    	mov    0xf017c0c0,%ecx
f0100e8c:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100e8e:	03 05 b8 c0 17 f0    	add    0xf017c0b8,%eax
f0100e94:	a3 c0 c0 17 f0       	mov    %eax,0xf017c0c0
	// free pages!
	size_t i;
	//cprintf("EXTPHYSMEM: %x,boot_alloc (0): %x\n",EXTPHYSMEM,boot_alloc (0));
	cprintf("pages :%x\n",pages);
	cprintf("pagefreelist :%x\n",page_free_list);
	for (i = 1; i < npages ; i++) 
f0100e99:	83 c3 01             	add    $0x1,%ebx
f0100e9c:	3b 1d 88 cd 17 f0    	cmp    0xf017cd88,%ebx
f0100ea2:	0f 82 03 ff ff ff    	jb     f0100dab <page_init+0x3b>
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
	
}
f0100ea8:	83 c4 14             	add    $0x14,%esp
f0100eab:	5b                   	pop    %ebx
f0100eac:	5d                   	pop    %ebp
f0100ead:	c3                   	ret    

f0100eae <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100eae:	55                   	push   %ebp
f0100eaf:	89 e5                	mov    %esp,%ebp
f0100eb1:	53                   	push   %ebx
f0100eb2:	83 ec 14             	sub    $0x14,%esp
	if ((page_free_list)) 
f0100eb5:	8b 1d c0 c0 17 f0    	mov    0xf017c0c0,%ebx
f0100ebb:	85 db                	test   %ebx,%ebx
f0100ebd:	74 6f                	je     f0100f2e <page_alloc+0x80>
	{
        	struct PageInfo *ret = page_free_list;//Returns the first free page		
        	page_free_list = page_free_list->pp_link;//keeping the next page as the start of the pages in free list		
f0100ebf:	8b 03                	mov    (%ebx),%eax
f0100ec1:	a3 c0 c0 17 f0       	mov    %eax,0xf017c0c0
		ret->pp_link = NULL;
f0100ec6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        	if (alloc_flags & ALLOC_ZERO) 
		{
            		memset(page2kva(ret), 0, PGSIZE);
			//cprintf("ret,pagekva:%x,%x\n",ret,page2kva(ret));
        	}
		return ret;
f0100ecc:	89 d8                	mov    %ebx,%eax
	if ((page_free_list)) 
	{
        	struct PageInfo *ret = page_free_list;//Returns the first free page		
        	page_free_list = page_free_list->pp_link;//keeping the next page as the start of the pages in free list		
		ret->pp_link = NULL;
        	if (alloc_flags & ALLOC_ZERO) 
f0100ece:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100ed2:	74 5f                	je     f0100f33 <page_alloc+0x85>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ed4:	2b 05 b8 c0 17 f0    	sub    0xf017c0b8,%eax
f0100eda:	c1 f8 03             	sar    $0x3,%eax
f0100edd:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ee0:	89 c2                	mov    %eax,%edx
f0100ee2:	c1 ea 0c             	shr    $0xc,%edx
f0100ee5:	3b 15 88 cd 17 f0    	cmp    0xf017cd88,%edx
f0100eeb:	72 20                	jb     f0100f0d <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100eed:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ef1:	c7 44 24 08 04 52 10 	movl   $0xf0105204,0x8(%esp)
f0100ef8:	f0 
f0100ef9:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100f00:	00 
f0100f01:	c7 04 24 84 4e 10 f0 	movl   $0xf0104e84,(%esp)
f0100f08:	e8 a9 f1 ff ff       	call   f01000b6 <_panic>
		{
            		memset(page2kva(ret), 0, PGSIZE);
f0100f0d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100f14:	00 
f0100f15:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100f1c:	00 
	return (void *)(pa + KERNBASE);
f0100f1d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f22:	89 04 24             	mov    %eax,(%esp)
f0100f25:	e8 cd 35 00 00       	call   f01044f7 <memset>
			//cprintf("ret,pagekva:%x,%x\n",ret,page2kva(ret));
        	}
		return ret;
f0100f2a:	89 d8                	mov    %ebx,%eax
f0100f2c:	eb 05                	jmp    f0100f33 <page_alloc+0x85>
   	}
    	else 
	{	
		return NULL;
f0100f2e:	b8 00 00 00 00       	mov    $0x0,%eax
	}
}
f0100f33:	83 c4 14             	add    $0x14,%esp
f0100f36:	5b                   	pop    %ebx
f0100f37:	5d                   	pop    %ebp
f0100f38:	c3                   	ret    

f0100f39 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f39:	55                   	push   %ebp
f0100f3a:	89 e5                	mov    %esp,%ebp
f0100f3c:	83 ec 18             	sub    $0x18,%esp
f0100f3f:	8b 45 08             	mov    0x8(%ebp),%eax
	if((pp->pp_ref == 0) && (pp->pp_link==NULL))
f0100f42:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f47:	75 14                	jne    f0100f5d <page_free+0x24>
f0100f49:	83 38 00             	cmpl   $0x0,(%eax)
f0100f4c:	75 0f                	jne    f0100f5d <page_free+0x24>
	{
		pp->pp_link = page_free_list;							//page_free_list->pp_link = pp;
f0100f4e:	8b 15 c0 c0 17 f0    	mov    0xf017c0c0,%edx
f0100f54:	89 10                	mov    %edx,(%eax)
		page_free_list = pp;			//Inserting the free page in the beginning	
f0100f56:	a3 c0 c0 17 f0       	mov    %eax,0xf017c0c0
f0100f5b:	eb 1c                	jmp    f0100f79 <page_free+0x40>
	}
	else
	{
		panic("The page is not free!");
f0100f5d:	c7 44 24 08 57 4f 10 	movl   $0xf0104f57,0x8(%esp)
f0100f64:	f0 
f0100f65:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
f0100f6c:	00 
f0100f6d:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0100f74:	e8 3d f1 ff ff       	call   f01000b6 <_panic>
	}

}
f0100f79:	c9                   	leave  
f0100f7a:	c3                   	ret    

f0100f7b <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f7b:	55                   	push   %ebp
f0100f7c:	89 e5                	mov    %esp,%ebp
f0100f7e:	83 ec 18             	sub    $0x18,%esp
f0100f81:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100f84:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f0100f88:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0100f8b:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100f8f:	66 85 d2             	test   %dx,%dx
f0100f92:	75 08                	jne    f0100f9c <page_decref+0x21>
		page_free(pp);
f0100f94:	89 04 24             	mov    %eax,(%esp)
f0100f97:	e8 9d ff ff ff       	call   f0100f39 <page_free>
}
f0100f9c:	c9                   	leave  
f0100f9d:	c3                   	ret    

f0100f9e <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{	
f0100f9e:	55                   	push   %ebp
f0100f9f:	89 e5                	mov    %esp,%ebp
f0100fa1:	57                   	push   %edi
f0100fa2:	56                   	push   %esi
f0100fa3:	53                   	push   %ebx
f0100fa4:	83 ec 2c             	sub    $0x2c,%esp
	int dindex = PDX(va), tindex = PTX(va);
f0100fa7:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100faa:	c1 ee 16             	shr    $0x16,%esi
f0100fad:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100fb0:	c1 ef 0c             	shr    $0xc,%edi
f0100fb3:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
	//cprintf("va:%x,dindex:%x,tindex:%x,pgdir[dindex]%x\n",va,dindex,tindex,&pgdir[dindex]);
	//cprintf("pgdir[dindex]: %x" ,pgdir[dindex]);
	if(!(pgdir[dindex] & PTE_P))//if the entry is not present
f0100fb9:	8d 1c b5 00 00 00 00 	lea    0x0(,%esi,4),%ebx
f0100fc0:	03 5d 08             	add    0x8(%ebp),%ebx
f0100fc3:	f6 03 01             	testb  $0x1,(%ebx)
f0100fc6:	75 34                	jne    f0100ffc <pgdir_walk+0x5e>
	{
	   if(create)
f0100fc8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100fcc:	0f 84 9d 00 00 00    	je     f010106f <pgdir_walk+0xd1>
	   {
		struct PageInfo *pg = page_alloc(ALLOC_ZERO);
f0100fd2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100fd9:	e8 d0 fe ff ff       	call   f0100eae <page_alloc>
		//cprintf("pg:%x\n",pg);
		//cprintf("xxxxxxxxx\n");
		if(!pg)
f0100fde:	85 c0                	test   %eax,%eax
f0100fe0:	0f 84 90 00 00 00    	je     f0101076 <pgdir_walk+0xd8>
		{
		    return NULL; //Allocation failure				
		}
		//cprintf("pageinfo pg%x\n",pg);
		pg->pp_ref++;
f0100fe6:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100feb:	2b 05 b8 c0 17 f0    	sub    0xf017c0b8,%eax
f0100ff1:	c1 f8 03             	sar    $0x3,%eax
f0100ff4:	c1 e0 0c             	shl    $0xc,%eax
		//cprintf("page2pa%x\n",page2pa(pg));
            	pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
f0100ff7:	83 c8 07             	or     $0x7,%eax
f0100ffa:	89 03                	mov    %eax,(%ebx)
		//cprintf("yyyyyyyy\n");
		return NULL;
		}
	}
			
	pte_t *p = KADDR(PTE_ADDR(pgdir[dindex]));
f0100ffc:	8b 03                	mov    (%ebx),%eax
f0100ffe:	89 c3                	mov    %eax,%ebx
f0101000:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101006:	89 da                	mov    %ebx,%edx
f0101008:	c1 ea 0c             	shr    $0xc,%edx
f010100b:	3b 15 88 cd 17 f0    	cmp    0xf017cd88,%edx
f0101011:	72 20                	jb     f0101033 <pgdir_walk+0x95>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101013:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101017:	c7 44 24 08 04 52 10 	movl   $0xf0105204,0x8(%esp)
f010101e:	f0 
f010101f:	c7 44 24 04 b6 01 00 	movl   $0x1b6,0x4(%esp)
f0101026:	00 
f0101027:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f010102e:	e8 83 f0 ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f0101033:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
	if(test == 0)
f0101039:	83 3d 84 cd 17 f0 00 	cmpl   $0x0,0xf017cd84
f0101040:	75 28                	jne    f010106a <pgdir_walk+0xcc>
	{
//cprintf("dindex :%x ,va :%x,(PTE_ADDR(pgdir[dindex]):%x,p(KADDR(PTE_ADDR(pgdir[dindex]):%x,tindex : %x, p+tindex: %x\n",dindex,va,PTE_ADDR(pgdir[dindex]),p,tindex,p+tindex);
	cprintf("va: %x , dindex: %x , pgdir[dindex]: %x , p+tindex: %x , *(p+tindex):%x \n",va,dindex,pgdir[dindex],p+tindex,*(p+tindex));
f0101042:	8d 14 bb             	lea    (%ebx,%edi,4),%edx
f0101045:	8b 0a                	mov    (%edx),%ecx
f0101047:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f010104b:	89 54 24 10          	mov    %edx,0x10(%esp)
f010104f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101053:	89 74 24 08          	mov    %esi,0x8(%esp)
f0101057:	8b 45 0c             	mov    0xc(%ebp),%eax
f010105a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010105e:	c7 04 24 10 53 10 f0 	movl   $0xf0105310,(%esp)
f0101065:	e8 84 24 00 00       	call   f01034ee <cprintf>

	}	
	
	
	return p+tindex;
f010106a:	8d 04 bb             	lea    (%ebx,%edi,4),%eax
f010106d:	eb 0c                	jmp    f010107b <pgdir_walk+0xdd>
		//cprintf("pgdir[dindex]:%x,page2pa(pg):%x,pages: %x\n",pgdir[dindex],page2pa(pg),pages);	
	   }
	   else 
		{
		//cprintf("yyyyyyyy\n");
		return NULL;
f010106f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101074:	eb 05                	jmp    f010107b <pgdir_walk+0xdd>
		struct PageInfo *pg = page_alloc(ALLOC_ZERO);
		//cprintf("pg:%x\n",pg);
		//cprintf("xxxxxxxxx\n");
		if(!pg)
		{
		    return NULL; //Allocation failure				
f0101076:	b8 00 00 00 00       	mov    $0x0,%eax

	}	
	
	
	return p+tindex;
}	
f010107b:	83 c4 2c             	add    $0x2c,%esp
f010107e:	5b                   	pop    %ebx
f010107f:	5e                   	pop    %esi
f0101080:	5f                   	pop    %edi
f0101081:	5d                   	pop    %ebp
f0101082:	c3                   	ret    

f0101083 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
//boot_map_region(kern_pgdir, UPAGES, sizeof(struct PageInfo) * npages,PADDR(pages),PTE_U);
static void boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101083:	55                   	push   %ebp
f0101084:	89 e5                	mov    %esp,%ebp
f0101086:	57                   	push   %edi
f0101087:	56                   	push   %esi
f0101088:	53                   	push   %ebx
f0101089:	83 ec 2c             	sub    $0x2c,%esp
f010108c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Fill this function in
	int i;
	for(i=0;i<(size/PGSIZE);i++)
f010108f:	c1 e9 0c             	shr    $0xc,%ecx
f0101092:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101095:	89 d3                	mov    %edx,%ebx
f0101097:	be 00 00 00 00       	mov    $0x0,%esi
f010109c:	8b 45 08             	mov    0x8(%ebp),%eax
f010109f:	29 d0                	sub    %edx,%eax
f01010a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
		pte_t *ptr = pgdir_walk(pgdir, (void*) va, 1);
		if(test == 0)
			{
				//cprintf("i: %d , ptr :%x *ptr : %x  PTE_ADDR(pa):%x,  va : %x, pa: %x \n",i,ptr,*ptr,PTE_ADDR(pa),va,pa);
			}		
		*ptr = PTE_ADDR(pa) | perm | PTE_P;
f01010a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010a7:	83 c8 01             	or     $0x1,%eax
f01010aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
//boot_map_region(kern_pgdir, UPAGES, sizeof(struct PageInfo) * npages,PADDR(pages),PTE_U);
static void boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	int i;
	for(i=0;i<(size/PGSIZE);i++)
f01010ad:	eb 2b                	jmp    f01010da <boot_map_region+0x57>
	{				
		//cprintf("*va : %x,pa; %x\n",va,pa);
		pte_t *ptr = pgdir_walk(pgdir, (void*) va, 1);
f01010af:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01010b6:	00 
f01010b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01010be:	89 04 24             	mov    %eax,(%esp)
f01010c1:	e8 d8 fe ff ff       	call   f0100f9e <pgdir_walk>
		if(test == 0)
			{
				//cprintf("i: %d , ptr :%x *ptr : %x  PTE_ADDR(pa):%x,  va : %x, pa: %x \n",i,ptr,*ptr,PTE_ADDR(pa),va,pa);
			}		
		*ptr = PTE_ADDR(pa) | perm | PTE_P;
f01010c6:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01010cc:	0b 7d d8             	or     -0x28(%ebp),%edi
f01010cf:	89 38                	mov    %edi,(%eax)
				//cprintf("PTE_ADDR(pa) : %x\n",PTE_ADDR(pa));
		if(test == 0)
			{
				//cprintf("*ptr_2 : %x\n",*ptr);
			}	
		va = va+PGSIZE;
f01010d1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
//boot_map_region(kern_pgdir, UPAGES, sizeof(struct PageInfo) * npages,PADDR(pages),PTE_U);
static void boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	int i;
	for(i=0;i<(size/PGSIZE);i++)
f01010d7:	83 c6 01             	add    $0x1,%esi
f01010da:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010dd:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
f01010e0:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01010e3:	75 ca                	jne    f01010af <boot_map_region+0x2c>
			}	
		va = va+PGSIZE;
		pa = pa+PGSIZE;	
	}

}
f01010e5:	83 c4 2c             	add    $0x2c,%esp
f01010e8:	5b                   	pop    %ebx
f01010e9:	5e                   	pop    %esi
f01010ea:	5f                   	pop    %edi
f01010eb:	5d                   	pop    %ebp
f01010ec:	c3                   	ret    

f01010ed <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
// 
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01010ed:	55                   	push   %ebp
f01010ee:	89 e5                	mov    %esp,%ebp
f01010f0:	53                   	push   %ebx
f01010f1:	83 ec 14             	sub    $0x14,%esp
f01010f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir,va,0);
f01010f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01010fe:	00 
f01010ff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101102:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101106:	8b 45 08             	mov    0x8(%ebp),%eax
f0101109:	89 04 24             	mov    %eax,(%esp)
f010110c:	e8 8d fe ff ff       	call   f0100f9e <pgdir_walk>
	if (!pte || !(*pte & PTE_P)) return NULL;   //if pte == NULL,then..page not found,
f0101111:	85 c0                	test   %eax,%eax
f0101113:	74 43                	je     f0101158 <page_lookup+0x6b>
f0101115:	f6 00 01             	testb  $0x1,(%eax)
f0101118:	74 45                	je     f010115f <page_lookup+0x72>
	if(pte_store)
f010111a:	85 db                	test   %ebx,%ebx
f010111c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101120:	74 02                	je     f0101124 <page_lookup+0x37>
	{
	   *pte_store = pte;		
f0101122:	89 03                	mov    %eax,(%ebx)
	}
	// Fill this function in
	return pa2page(PTE_ADDR(*pte));
f0101124:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101126:	c1 e8 0c             	shr    $0xc,%eax
f0101129:	3b 05 88 cd 17 f0    	cmp    0xf017cd88,%eax
f010112f:	72 1c                	jb     f010114d <page_lookup+0x60>
		panic("pa2page called with invalid pa");
f0101131:	c7 44 24 08 5c 53 10 	movl   $0xf010535c,0x8(%esp)
f0101138:	f0 
f0101139:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0101140:	00 
f0101141:	c7 04 24 84 4e 10 f0 	movl   $0xf0104e84,(%esp)
f0101148:	e8 69 ef ff ff       	call   f01000b6 <_panic>
	return &pages[PGNUM(pa)];
f010114d:	8b 15 b8 c0 17 f0    	mov    0xf017c0b8,%edx
f0101153:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0101156:	eb 0c                	jmp    f0101164 <page_lookup+0x77>
// 
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t *pte = pgdir_walk(pgdir,va,0);
	if (!pte || !(*pte & PTE_P)) return NULL;   //if pte == NULL,then..page not found,
f0101158:	b8 00 00 00 00       	mov    $0x0,%eax
f010115d:	eb 05                	jmp    f0101164 <page_lookup+0x77>
f010115f:	b8 00 00 00 00       	mov    $0x0,%eax
	{
	   *pte_store = pte;		
	}
	// Fill this function in
	return pa2page(PTE_ADDR(*pte));
}
f0101164:	83 c4 14             	add    $0x14,%esp
f0101167:	5b                   	pop    %ebx
f0101168:	5d                   	pop    %ebp
f0101169:	c3                   	ret    

f010116a <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{	
f010116a:	55                   	push   %ebp
f010116b:	89 e5                	mov    %esp,%ebp
f010116d:	53                   	push   %ebx
f010116e:	83 ec 24             	sub    $0x24,%esp
f0101171:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pt;
	struct PageInfo *pter = page_lookup(pgdir,va,&pt);
f0101174:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101177:	89 44 24 08          	mov    %eax,0x8(%esp)
f010117b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010117f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101182:	89 04 24             	mov    %eax,(%esp)
f0101185:	e8 63 ff ff ff       	call   f01010ed <page_lookup>
	if (!pter || !(*pt & PTE_P))
f010118a:	85 c0                	test   %eax,%eax
f010118c:	74 1c                	je     f01011aa <page_remove+0x40>
f010118e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101191:	f6 02 01             	testb  $0x1,(%edx)
f0101194:	74 14                	je     f01011aa <page_remove+0x40>
	     return;
	page_decref(pter);
f0101196:	89 04 24             	mov    %eax,(%esp)
f0101199:	e8 dd fd ff ff       	call   f0100f7b <page_decref>
	*pt = 0;
f010119e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011a1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011a7:	0f 01 3b             	invlpg (%ebx)
	tlb_invalidate(pgdir, va);	
	// Fill this function in
}
f01011aa:	83 c4 24             	add    $0x24,%esp
f01011ad:	5b                   	pop    %ebx
f01011ae:	5d                   	pop    %ebp
f01011af:	c3                   	ret    

f01011b0 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01011b0:	55                   	push   %ebp
f01011b1:	89 e5                	mov    %esp,%ebp
f01011b3:	57                   	push   %edi
f01011b4:	56                   	push   %esi
f01011b5:	53                   	push   %ebx
f01011b6:	83 ec 1c             	sub    $0x1c,%esp
f01011b9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01011bc:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pge = pgdir_walk(pgdir, va, true);
f01011bf:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01011c6:	00 
f01011c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01011cb:	8b 45 08             	mov    0x8(%ebp),%eax
f01011ce:	89 04 24             	mov    %eax,(%esp)
f01011d1:	e8 c8 fd ff ff       	call   f0100f9e <pgdir_walk>
f01011d6:	89 c3                	mov    %eax,%ebx
	if(!pge)				//Doubt
f01011d8:	85 c0                	test   %eax,%eax
f01011da:	74 36                	je     f0101212 <page_insert+0x62>
		return -E_NO_MEM;	//if page table couldn't be allocated
	pp->pp_ref++;			//Corner case?
f01011dc:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if(*pge & PTE_P)		//If there is already a page mapped at 'va', it should be page_remove()d.
f01011e1:	f6 00 01             	testb  $0x1,(%eax)
f01011e4:	74 0f                	je     f01011f5 <page_insert+0x45>
		page_remove(pgdir,va);	
f01011e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01011ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01011ed:	89 04 24             	mov    %eax,(%esp)
f01011f0:	e8 75 ff ff ff       	call   f010116a <page_remove>
	*pge = page2pa(pp) | perm | PTE_P;
f01011f5:	8b 45 14             	mov    0x14(%ebp),%eax
f01011f8:	83 c8 01             	or     $0x1,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011fb:	2b 35 b8 c0 17 f0    	sub    0xf017c0b8,%esi
f0101201:	c1 fe 03             	sar    $0x3,%esi
f0101204:	c1 e6 0c             	shl    $0xc,%esi
f0101207:	09 c6                	or     %eax,%esi
f0101209:	89 33                	mov    %esi,(%ebx)
	// Fill this function in
	return 0;
f010120b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101210:	eb 05                	jmp    f0101217 <page_insert+0x67>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *pge = pgdir_walk(pgdir, va, true);
	if(!pge)				//Doubt
		return -E_NO_MEM;	//if page table couldn't be allocated
f0101212:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	if(*pge & PTE_P)		//If there is already a page mapped at 'va', it should be page_remove()d.
		page_remove(pgdir,va);	
	*pge = page2pa(pp) | perm | PTE_P;
	// Fill this function in
	return 0;
}
f0101217:	83 c4 1c             	add    $0x1c,%esp
f010121a:	5b                   	pop    %ebx
f010121b:	5e                   	pop    %esi
f010121c:	5f                   	pop    %edi
f010121d:	5d                   	pop    %ebp
f010121e:	c3                   	ret    

f010121f <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010121f:	55                   	push   %ebp
f0101220:	89 e5                	mov    %esp,%ebp
f0101222:	57                   	push   %edi
f0101223:	56                   	push   %esi
f0101224:	53                   	push   %ebx
f0101225:	83 ec 4c             	sub    $0x4c,%esp
	test = 1;	
f0101228:	c7 05 84 cd 17 f0 01 	movl   $0x1,0xf017cd84
f010122f:	00 00 00 
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101232:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f0101239:	e8 40 22 00 00       	call   f010347e <mc146818_read>
f010123e:	89 c3                	mov    %eax,%ebx
f0101240:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101247:	e8 32 22 00 00       	call   f010347e <mc146818_read>
f010124c:	c1 e0 08             	shl    $0x8,%eax
f010124f:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101251:	89 d8                	mov    %ebx,%eax
f0101253:	c1 e0 0a             	shl    $0xa,%eax
f0101256:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010125c:	85 c0                	test   %eax,%eax
f010125e:	0f 48 c2             	cmovs  %edx,%eax
f0101261:	c1 f8 0c             	sar    $0xc,%eax
f0101264:	a3 c4 c0 17 f0       	mov    %eax,0xf017c0c4
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101269:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101270:	e8 09 22 00 00       	call   f010347e <mc146818_read>
f0101275:	89 c3                	mov    %eax,%ebx
f0101277:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f010127e:	e8 fb 21 00 00       	call   f010347e <mc146818_read>
f0101283:	c1 e0 08             	shl    $0x8,%eax
f0101286:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101288:	89 d8                	mov    %ebx,%eax
f010128a:	c1 e0 0a             	shl    $0xa,%eax
f010128d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101293:	85 c0                	test   %eax,%eax
f0101295:	0f 48 c2             	cmovs  %edx,%eax
f0101298:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010129b:	85 c0                	test   %eax,%eax
f010129d:	74 0e                	je     f01012ad <mem_init+0x8e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010129f:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01012a5:	89 15 88 cd 17 f0    	mov    %edx,0xf017cd88
f01012ab:	eb 0c                	jmp    f01012b9 <mem_init+0x9a>
	else
		npages = npages_basemem;//npages = 16639
f01012ad:	8b 15 c4 c0 17 f0    	mov    0xf017c0c4,%edx
f01012b3:	89 15 88 cd 17 f0    	mov    %edx,0xf017cd88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01012b9:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;//npages = 16639

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01012bc:	c1 e8 0a             	shr    $0xa,%eax
f01012bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01012c3:	a1 c4 c0 17 f0       	mov    0xf017c0c4,%eax
f01012c8:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;//npages = 16639

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01012cb:	c1 e8 0a             	shr    $0xa,%eax
f01012ce:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01012d2:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f01012d7:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;//npages = 16639

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01012da:	c1 e8 0a             	shr    $0xa,%eax
f01012dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012e1:	c7 04 24 7c 53 10 f0 	movl   $0xf010537c,(%esp)
f01012e8:	e8 01 22 00 00       	call   f01034ee <cprintf>
	uint32_t *pagearray;
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");
	cprintf("npages:%d",npages);
f01012ed:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f01012f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012f6:	c7 04 24 6d 4f 10 f0 	movl   $0xf0104f6d,(%esp)
f01012fd:	e8 ec 21 00 00       	call   f01034ee <cprintf>
	cprintf("npages:%d",npages_basemem);
f0101302:	a1 c4 c0 17 f0       	mov    0xf017c0c4,%eax
f0101307:	89 44 24 04          	mov    %eax,0x4(%esp)
f010130b:	c7 04 24 6d 4f 10 f0 	movl   $0xf0104f6d,(%esp)
f0101312:	e8 d7 21 00 00       	call   f01034ee <cprintf>
	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	cprintf("boot_alloc_1: %x\n",boot_alloc(0));	
f0101317:	b8 00 00 00 00       	mov    $0x0,%eax
f010131c:	e8 ff f5 ff ff       	call   f0100920 <boot_alloc>
f0101321:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101325:	c7 04 24 77 4f 10 f0 	movl   $0xf0104f77,(%esp)
f010132c:	e8 bd 21 00 00       	call   f01034ee <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101331:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101336:	e8 e5 f5 ff ff       	call   f0100920 <boot_alloc>
f010133b:	a3 8c cd 17 f0       	mov    %eax,0xf017cd8c
	memset(kern_pgdir, 0, PGSIZE);
f0101340:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101347:	00 
f0101348:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010134f:	00 
f0101350:	89 04 24             	mov    %eax,(%esp)
f0101353:	e8 9f 31 00 00       	call   f01044f7 <memset>
	cprintf("kern_pgdir_0000:%x",kern_pgdir);
f0101358:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f010135d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101361:	c7 04 24 89 4f 10 f0 	movl   $0xf0104f89,(%esp)
f0101368:	e8 81 21 00 00       	call   f01034ee <cprintf>
	//cprintf("pages_1 :%x\n",pages);
	cprintf("boot_alloc_2: %x\n",boot_alloc(0));
f010136d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101372:	e8 a9 f5 ff ff       	call   f0100920 <boot_alloc>
f0101377:	89 44 24 04          	mov    %eax,0x4(%esp)
f010137b:	c7 04 24 9c 4f 10 f0 	movl   $0xf0104f9c,(%esp)
f0101382:	e8 67 21 00 00       	call   f01034ee <cprintf>
	// Recursively insert PD in itself as a page table, to form
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)
	// Permissions: kernel R, user R
	cprintf("kern_pgdir[PDX(UVPT)]: %x",kern_pgdir[PDX(UVPT)]);	
f0101387:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f010138c:	8b 80 f4 0e 00 00    	mov    0xef4(%eax),%eax
f0101392:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101396:	c7 04 24 ae 4f 10 f0 	movl   $0xf0104fae,(%esp)
f010139d:	e8 4c 21 00 00       	call   f01034ee <cprintf>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;//How its recursion?
f01013a2:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01013a7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013ac:	77 20                	ja     f01013ce <mem_init+0x1af>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013b2:	c7 44 24 08 ec 52 10 	movl   $0xf01052ec,0x8(%esp)
f01013b9:	f0 
f01013ba:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
f01013c1:	00 
f01013c2:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01013c9:	e8 e8 ec ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01013ce:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013d4:	83 ca 05             	or     $0x5,%edx
f01013d7:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	
	//pages = (struct PageInfo*) boot_alloc(npages * sizeof(struct PageInfo));   // PGSIZE is defined as 4096
	//memset(pages, 0, npages * sizeof(struct PageInfo) );
	pages = (struct PageInfo*)boot_alloc(npages*sizeof(struct PageInfo));
f01013dd:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f01013e2:	c1 e0 03             	shl    $0x3,%eax
f01013e5:	e8 36 f5 ff ff       	call   f0100920 <boot_alloc>
f01013ea:	a3 b8 c0 17 f0       	mov    %eax,0xf017c0b8
	memset(pages, 0, (npages*sizeof(struct PageInfo)));	
f01013ef:	8b 3d 88 cd 17 f0    	mov    0xf017cd88,%edi
f01013f5:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f01013fc:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101400:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101407:	00 
f0101408:	89 04 24             	mov    %eax,(%esp)
f010140b:	e8 e7 30 00 00       	call   f01044f7 <memset>
	cprintf("pages111111:%x",pages);
f0101410:	a1 b8 c0 17 f0       	mov    0xf017c0b8,%eax
f0101415:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101419:	c7 04 24 c8 4f 10 f0 	movl   $0xf0104fc8,(%esp)
f0101420:	e8 c9 20 00 00       	call   f01034ee <cprintf>
	//npages correspond to Amount of physical memory.
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));
f0101425:	b8 00 80 01 00       	mov    $0x18000,%eax
f010142a:	e8 f1 f4 ff ff       	call   f0100920 <boot_alloc>
f010142f:	a3 cc c0 17 f0       	mov    %eax,0xf017c0cc
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101434:	e8 37 f9 ff ff       	call   f0100d70 <page_init>
	check_page_free_list(1);
f0101439:	b8 01 00 00 00       	mov    $0x1,%eax
f010143e:	e8 e4 f5 ff ff       	call   f0100a27 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;
	//cprintf("000000000000000\n");
	if (!pages)
f0101443:	83 3d b8 c0 17 f0 00 	cmpl   $0x0,0xf017c0b8
f010144a:	75 1c                	jne    f0101468 <mem_init+0x249>
		panic("'pages' is a null pointer!");
f010144c:	c7 44 24 08 d7 4f 10 	movl   $0xf0104fd7,0x8(%esp)
f0101453:	f0 
f0101454:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f010145b:	00 
f010145c:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101463:	e8 4e ec ff ff       	call   f01000b6 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101468:	a1 c0 c0 17 f0       	mov    0xf017c0c0,%eax
f010146d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101472:	eb 05                	jmp    f0101479 <mem_init+0x25a>
		++nfree;
f0101474:	83 c3 01             	add    $0x1,%ebx
	//cprintf("000000000000000\n");
	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101477:	8b 00                	mov    (%eax),%eax
f0101479:	85 c0                	test   %eax,%eax
f010147b:	75 f7                	jne    f0101474 <mem_init+0x255>
		++nfree;
	//cprintf("100000000000000\n");
	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010147d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101484:	e8 25 fa ff ff       	call   f0100eae <page_alloc>
f0101489:	89 c7                	mov    %eax,%edi
f010148b:	85 c0                	test   %eax,%eax
f010148d:	75 24                	jne    f01014b3 <mem_init+0x294>
f010148f:	c7 44 24 0c f2 4f 10 	movl   $0xf0104ff2,0xc(%esp)
f0101496:	f0 
f0101497:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f010149e:	f0 
f010149f:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f01014a6:	00 
f01014a7:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01014ae:	e8 03 ec ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f01014b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014ba:	e8 ef f9 ff ff       	call   f0100eae <page_alloc>
f01014bf:	89 c6                	mov    %eax,%esi
f01014c1:	85 c0                	test   %eax,%eax
f01014c3:	75 24                	jne    f01014e9 <mem_init+0x2ca>
f01014c5:	c7 44 24 0c 08 50 10 	movl   $0xf0105008,0xc(%esp)
f01014cc:	f0 
f01014cd:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01014d4:	f0 
f01014d5:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f01014dc:	00 
f01014dd:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01014e4:	e8 cd eb ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f01014e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014f0:	e8 b9 f9 ff ff       	call   f0100eae <page_alloc>
f01014f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014f8:	85 c0                	test   %eax,%eax
f01014fa:	75 24                	jne    f0101520 <mem_init+0x301>
f01014fc:	c7 44 24 0c 1e 50 10 	movl   $0xf010501e,0xc(%esp)
f0101503:	f0 
f0101504:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f010150b:	f0 
f010150c:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f0101513:	00 
f0101514:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f010151b:	e8 96 eb ff ff       	call   f01000b6 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101520:	39 f7                	cmp    %esi,%edi
f0101522:	75 24                	jne    f0101548 <mem_init+0x329>
f0101524:	c7 44 24 0c 34 50 10 	movl   $0xf0105034,0xc(%esp)
f010152b:	f0 
f010152c:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101533:	f0 
f0101534:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f010153b:	00 
f010153c:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101543:	e8 6e eb ff ff       	call   f01000b6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101548:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010154b:	39 c6                	cmp    %eax,%esi
f010154d:	74 04                	je     f0101553 <mem_init+0x334>
f010154f:	39 c7                	cmp    %eax,%edi
f0101551:	75 24                	jne    f0101577 <mem_init+0x358>
f0101553:	c7 44 24 0c b8 53 10 	movl   $0xf01053b8,0xc(%esp)
f010155a:	f0 
f010155b:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101562:	f0 
f0101563:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f010156a:	00 
f010156b:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101572:	e8 3f eb ff ff       	call   f01000b6 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101577:	8b 15 b8 c0 17 f0    	mov    0xf017c0b8,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f010157d:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0101582:	c1 e0 0c             	shl    $0xc,%eax
f0101585:	89 f9                	mov    %edi,%ecx
f0101587:	29 d1                	sub    %edx,%ecx
f0101589:	c1 f9 03             	sar    $0x3,%ecx
f010158c:	c1 e1 0c             	shl    $0xc,%ecx
f010158f:	39 c1                	cmp    %eax,%ecx
f0101591:	72 24                	jb     f01015b7 <mem_init+0x398>
f0101593:	c7 44 24 0c 46 50 10 	movl   $0xf0105046,0xc(%esp)
f010159a:	f0 
f010159b:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01015a2:	f0 
f01015a3:	c7 44 24 04 d9 02 00 	movl   $0x2d9,0x4(%esp)
f01015aa:	00 
f01015ab:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01015b2:	e8 ff ea ff ff       	call   f01000b6 <_panic>
f01015b7:	89 f1                	mov    %esi,%ecx
f01015b9:	29 d1                	sub    %edx,%ecx
f01015bb:	c1 f9 03             	sar    $0x3,%ecx
f01015be:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01015c1:	39 c8                	cmp    %ecx,%eax
f01015c3:	77 24                	ja     f01015e9 <mem_init+0x3ca>
f01015c5:	c7 44 24 0c 63 50 10 	movl   $0xf0105063,0xc(%esp)
f01015cc:	f0 
f01015cd:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01015d4:	f0 
f01015d5:	c7 44 24 04 da 02 00 	movl   $0x2da,0x4(%esp)
f01015dc:	00 
f01015dd:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01015e4:	e8 cd ea ff ff       	call   f01000b6 <_panic>
f01015e9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01015ec:	29 d1                	sub    %edx,%ecx
f01015ee:	89 ca                	mov    %ecx,%edx
f01015f0:	c1 fa 03             	sar    $0x3,%edx
f01015f3:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01015f6:	39 d0                	cmp    %edx,%eax
f01015f8:	77 24                	ja     f010161e <mem_init+0x3ff>
f01015fa:	c7 44 24 0c 80 50 10 	movl   $0xf0105080,0xc(%esp)
f0101601:	f0 
f0101602:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101609:	f0 
f010160a:	c7 44 24 04 db 02 00 	movl   $0x2db,0x4(%esp)
f0101611:	00 
f0101612:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101619:	e8 98 ea ff ff       	call   f01000b6 <_panic>
	//cprintf("200000000000000\n");
	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010161e:	a1 c0 c0 17 f0       	mov    0xf017c0c0,%eax
f0101623:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101626:	c7 05 c0 c0 17 f0 00 	movl   $0x0,0xf017c0c0
f010162d:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101630:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101637:	e8 72 f8 ff ff       	call   f0100eae <page_alloc>
f010163c:	85 c0                	test   %eax,%eax
f010163e:	74 24                	je     f0101664 <mem_init+0x445>
f0101640:	c7 44 24 0c 9d 50 10 	movl   $0xf010509d,0xc(%esp)
f0101647:	f0 
f0101648:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f010164f:	f0 
f0101650:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f0101657:	00 
f0101658:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f010165f:	e8 52 ea ff ff       	call   f01000b6 <_panic>
	//cprintf("300000000000000\n");
	// free and re-allocate?
	page_free(pp0);
f0101664:	89 3c 24             	mov    %edi,(%esp)
f0101667:	e8 cd f8 ff ff       	call   f0100f39 <page_free>
	page_free(pp1);
f010166c:	89 34 24             	mov    %esi,(%esp)
f010166f:	e8 c5 f8 ff ff       	call   f0100f39 <page_free>
	page_free(pp2);
f0101674:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101677:	89 04 24             	mov    %eax,(%esp)
f010167a:	e8 ba f8 ff ff       	call   f0100f39 <page_free>
	//cprintf("400000000000000\n");
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010167f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101686:	e8 23 f8 ff ff       	call   f0100eae <page_alloc>
f010168b:	89 c6                	mov    %eax,%esi
f010168d:	85 c0                	test   %eax,%eax
f010168f:	75 24                	jne    f01016b5 <mem_init+0x496>
f0101691:	c7 44 24 0c f2 4f 10 	movl   $0xf0104ff2,0xc(%esp)
f0101698:	f0 
f0101699:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01016a0:	f0 
f01016a1:	c7 44 24 04 ea 02 00 	movl   $0x2ea,0x4(%esp)
f01016a8:	00 
f01016a9:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01016b0:	e8 01 ea ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f01016b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016bc:	e8 ed f7 ff ff       	call   f0100eae <page_alloc>
f01016c1:	89 c7                	mov    %eax,%edi
f01016c3:	85 c0                	test   %eax,%eax
f01016c5:	75 24                	jne    f01016eb <mem_init+0x4cc>
f01016c7:	c7 44 24 0c 08 50 10 	movl   $0xf0105008,0xc(%esp)
f01016ce:	f0 
f01016cf:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01016d6:	f0 
f01016d7:	c7 44 24 04 eb 02 00 	movl   $0x2eb,0x4(%esp)
f01016de:	00 
f01016df:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01016e6:	e8 cb e9 ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f01016eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016f2:	e8 b7 f7 ff ff       	call   f0100eae <page_alloc>
f01016f7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016fa:	85 c0                	test   %eax,%eax
f01016fc:	75 24                	jne    f0101722 <mem_init+0x503>
f01016fe:	c7 44 24 0c 1e 50 10 	movl   $0xf010501e,0xc(%esp)
f0101705:	f0 
f0101706:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f010170d:	f0 
f010170e:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f0101715:	00 
f0101716:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f010171d:	e8 94 e9 ff ff       	call   f01000b6 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101722:	39 fe                	cmp    %edi,%esi
f0101724:	75 24                	jne    f010174a <mem_init+0x52b>
f0101726:	c7 44 24 0c 34 50 10 	movl   $0xf0105034,0xc(%esp)
f010172d:	f0 
f010172e:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101735:	f0 
f0101736:	c7 44 24 04 ee 02 00 	movl   $0x2ee,0x4(%esp)
f010173d:	00 
f010173e:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101745:	e8 6c e9 ff ff       	call   f01000b6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010174a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010174d:	39 c7                	cmp    %eax,%edi
f010174f:	74 04                	je     f0101755 <mem_init+0x536>
f0101751:	39 c6                	cmp    %eax,%esi
f0101753:	75 24                	jne    f0101779 <mem_init+0x55a>
f0101755:	c7 44 24 0c b8 53 10 	movl   $0xf01053b8,0xc(%esp)
f010175c:	f0 
f010175d:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101764:	f0 
f0101765:	c7 44 24 04 ef 02 00 	movl   $0x2ef,0x4(%esp)
f010176c:	00 
f010176d:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101774:	e8 3d e9 ff ff       	call   f01000b6 <_panic>
	assert(!page_alloc(0));
f0101779:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101780:	e8 29 f7 ff ff       	call   f0100eae <page_alloc>
f0101785:	85 c0                	test   %eax,%eax
f0101787:	74 24                	je     f01017ad <mem_init+0x58e>
f0101789:	c7 44 24 0c 9d 50 10 	movl   $0xf010509d,0xc(%esp)
f0101790:	f0 
f0101791:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101798:	f0 
f0101799:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f01017a0:	00 
f01017a1:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01017a8:	e8 09 e9 ff ff       	call   f01000b6 <_panic>
f01017ad:	89 f0                	mov    %esi,%eax
f01017af:	2b 05 b8 c0 17 f0    	sub    0xf017c0b8,%eax
f01017b5:	c1 f8 03             	sar    $0x3,%eax
f01017b8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017bb:	89 c2                	mov    %eax,%edx
f01017bd:	c1 ea 0c             	shr    $0xc,%edx
f01017c0:	3b 15 88 cd 17 f0    	cmp    0xf017cd88,%edx
f01017c6:	72 20                	jb     f01017e8 <mem_init+0x5c9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01017cc:	c7 44 24 08 04 52 10 	movl   $0xf0105204,0x8(%esp)
f01017d3:	f0 
f01017d4:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01017db:	00 
f01017dc:	c7 04 24 84 4e 10 f0 	movl   $0xf0104e84,(%esp)
f01017e3:	e8 ce e8 ff ff       	call   f01000b6 <_panic>
	//cprintf("500000000000000\n");
	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01017e8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01017ef:	00 
f01017f0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01017f7:	00 
	return (void *)(pa + KERNBASE);
f01017f8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01017fd:	89 04 24             	mov    %eax,(%esp)
f0101800:	e8 f2 2c 00 00       	call   f01044f7 <memset>
	page_free(pp0);
f0101805:	89 34 24             	mov    %esi,(%esp)
f0101808:	e8 2c f7 ff ff       	call   f0100f39 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010180d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101814:	e8 95 f6 ff ff       	call   f0100eae <page_alloc>
f0101819:	85 c0                	test   %eax,%eax
f010181b:	75 24                	jne    f0101841 <mem_init+0x622>
f010181d:	c7 44 24 0c ac 50 10 	movl   $0xf01050ac,0xc(%esp)
f0101824:	f0 
f0101825:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f010182c:	f0 
f010182d:	c7 44 24 04 f5 02 00 	movl   $0x2f5,0x4(%esp)
f0101834:	00 
f0101835:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f010183c:	e8 75 e8 ff ff       	call   f01000b6 <_panic>
	assert(pp && pp0 == pp);
f0101841:	39 c6                	cmp    %eax,%esi
f0101843:	74 24                	je     f0101869 <mem_init+0x64a>
f0101845:	c7 44 24 0c ca 50 10 	movl   $0xf01050ca,0xc(%esp)
f010184c:	f0 
f010184d:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101854:	f0 
f0101855:	c7 44 24 04 f6 02 00 	movl   $0x2f6,0x4(%esp)
f010185c:	00 
f010185d:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101864:	e8 4d e8 ff ff       	call   f01000b6 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101869:	89 f0                	mov    %esi,%eax
f010186b:	2b 05 b8 c0 17 f0    	sub    0xf017c0b8,%eax
f0101871:	c1 f8 03             	sar    $0x3,%eax
f0101874:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101877:	89 c2                	mov    %eax,%edx
f0101879:	c1 ea 0c             	shr    $0xc,%edx
f010187c:	3b 15 88 cd 17 f0    	cmp    0xf017cd88,%edx
f0101882:	72 20                	jb     f01018a4 <mem_init+0x685>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101884:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101888:	c7 44 24 08 04 52 10 	movl   $0xf0105204,0x8(%esp)
f010188f:	f0 
f0101890:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101897:	00 
f0101898:	c7 04 24 84 4e 10 f0 	movl   $0xf0104e84,(%esp)
f010189f:	e8 12 e8 ff ff       	call   f01000b6 <_panic>
f01018a4:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01018aa:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01018b0:	80 38 00             	cmpb   $0x0,(%eax)
f01018b3:	74 24                	je     f01018d9 <mem_init+0x6ba>
f01018b5:	c7 44 24 0c da 50 10 	movl   $0xf01050da,0xc(%esp)
f01018bc:	f0 
f01018bd:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01018c4:	f0 
f01018c5:	c7 44 24 04 f9 02 00 	movl   $0x2f9,0x4(%esp)
f01018cc:	00 
f01018cd:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01018d4:	e8 dd e7 ff ff       	call   f01000b6 <_panic>
f01018d9:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01018dc:	39 d0                	cmp    %edx,%eax
f01018de:	75 d0                	jne    f01018b0 <mem_init+0x691>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01018e0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01018e3:	a3 c0 c0 17 f0       	mov    %eax,0xf017c0c0

	// free the pages we took
	page_free(pp0);
f01018e8:	89 34 24             	mov    %esi,(%esp)
f01018eb:	e8 49 f6 ff ff       	call   f0100f39 <page_free>
	page_free(pp1);
f01018f0:	89 3c 24             	mov    %edi,(%esp)
f01018f3:	e8 41 f6 ff ff       	call   f0100f39 <page_free>
	page_free(pp2);
f01018f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018fb:	89 04 24             	mov    %eax,(%esp)
f01018fe:	e8 36 f6 ff ff       	call   f0100f39 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101903:	a1 c0 c0 17 f0       	mov    0xf017c0c0,%eax
f0101908:	eb 05                	jmp    f010190f <mem_init+0x6f0>
		--nfree;
f010190a:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010190d:	8b 00                	mov    (%eax),%eax
f010190f:	85 c0                	test   %eax,%eax
f0101911:	75 f7                	jne    f010190a <mem_init+0x6eb>
		--nfree;
	assert(nfree == 0);
f0101913:	85 db                	test   %ebx,%ebx
f0101915:	74 24                	je     f010193b <mem_init+0x71c>
f0101917:	c7 44 24 0c e4 50 10 	movl   $0xf01050e4,0xc(%esp)
f010191e:	f0 
f010191f:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101926:	f0 
f0101927:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f010192e:	00 
f010192f:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101936:	e8 7b e7 ff ff       	call   f01000b6 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010193b:	c7 04 24 d8 53 10 f0 	movl   $0xf01053d8,(%esp)
f0101942:	e8 a7 1b 00 00       	call   f01034ee <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101947:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010194e:	e8 5b f5 ff ff       	call   f0100eae <page_alloc>
f0101953:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101956:	85 c0                	test   %eax,%eax
f0101958:	75 24                	jne    f010197e <mem_init+0x75f>
f010195a:	c7 44 24 0c f2 4f 10 	movl   $0xf0104ff2,0xc(%esp)
f0101961:	f0 
f0101962:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101969:	f0 
f010196a:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0101971:	00 
f0101972:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101979:	e8 38 e7 ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f010197e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101985:	e8 24 f5 ff ff       	call   f0100eae <page_alloc>
f010198a:	89 c3                	mov    %eax,%ebx
f010198c:	85 c0                	test   %eax,%eax
f010198e:	75 24                	jne    f01019b4 <mem_init+0x795>
f0101990:	c7 44 24 0c 08 50 10 	movl   $0xf0105008,0xc(%esp)
f0101997:	f0 
f0101998:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f010199f:	f0 
f01019a0:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f01019a7:	00 
f01019a8:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01019af:	e8 02 e7 ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f01019b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019bb:	e8 ee f4 ff ff       	call   f0100eae <page_alloc>
f01019c0:	89 c6                	mov    %eax,%esi
f01019c2:	85 c0                	test   %eax,%eax
f01019c4:	75 24                	jne    f01019ea <mem_init+0x7cb>
f01019c6:	c7 44 24 0c 1e 50 10 	movl   $0xf010501e,0xc(%esp)
f01019cd:	f0 
f01019ce:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01019d5:	f0 
f01019d6:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f01019dd:	00 
f01019de:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01019e5:	e8 cc e6 ff ff       	call   f01000b6 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019ea:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01019ed:	75 24                	jne    f0101a13 <mem_init+0x7f4>
f01019ef:	c7 44 24 0c 34 50 10 	movl   $0xf0105034,0xc(%esp)
f01019f6:	f0 
f01019f7:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01019fe:	f0 
f01019ff:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0101a06:	00 
f0101a07:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101a0e:	e8 a3 e6 ff ff       	call   f01000b6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a13:	39 c3                	cmp    %eax,%ebx
f0101a15:	74 05                	je     f0101a1c <mem_init+0x7fd>
f0101a17:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101a1a:	75 24                	jne    f0101a40 <mem_init+0x821>
f0101a1c:	c7 44 24 0c b8 53 10 	movl   $0xf01053b8,0xc(%esp)
f0101a23:	f0 
f0101a24:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101a2b:	f0 
f0101a2c:	c7 44 24 04 6b 03 00 	movl   $0x36b,0x4(%esp)
f0101a33:	00 
f0101a34:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101a3b:	e8 76 e6 ff ff       	call   f01000b6 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a40:	a1 c0 c0 17 f0       	mov    0xf017c0c0,%eax
f0101a45:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101a48:	c7 05 c0 c0 17 f0 00 	movl   $0x0,0xf017c0c0
f0101a4f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a59:	e8 50 f4 ff ff       	call   f0100eae <page_alloc>
f0101a5e:	85 c0                	test   %eax,%eax
f0101a60:	74 24                	je     f0101a86 <mem_init+0x867>
f0101a62:	c7 44 24 0c 9d 50 10 	movl   $0xf010509d,0xc(%esp)
f0101a69:	f0 
f0101a6a:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101a71:	f0 
f0101a72:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f0101a79:	00 
f0101a7a:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101a81:	e8 30 e6 ff ff       	call   f01000b6 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a86:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101a89:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101a8d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101a94:	00 
f0101a95:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0101a9a:	89 04 24             	mov    %eax,(%esp)
f0101a9d:	e8 4b f6 ff ff       	call   f01010ed <page_lookup>
f0101aa2:	85 c0                	test   %eax,%eax
f0101aa4:	74 24                	je     f0101aca <mem_init+0x8ab>
f0101aa6:	c7 44 24 0c f8 53 10 	movl   $0xf01053f8,0xc(%esp)
f0101aad:	f0 
f0101aae:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101ab5:	f0 
f0101ab6:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0101abd:	00 
f0101abe:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101ac5:	e8 ec e5 ff ff       	call   f01000b6 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101aca:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ad1:	00 
f0101ad2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ad9:	00 
f0101ada:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ade:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0101ae3:	89 04 24             	mov    %eax,(%esp)
f0101ae6:	e8 c5 f6 ff ff       	call   f01011b0 <page_insert>
f0101aeb:	85 c0                	test   %eax,%eax
f0101aed:	78 24                	js     f0101b13 <mem_init+0x8f4>
f0101aef:	c7 44 24 0c 30 54 10 	movl   $0xf0105430,0xc(%esp)
f0101af6:	f0 
f0101af7:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101afe:	f0 
f0101aff:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0101b06:	00 
f0101b07:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101b0e:	e8 a3 e5 ff ff       	call   f01000b6 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b13:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b16:	89 04 24             	mov    %eax,(%esp)
f0101b19:	e8 1b f4 ff ff       	call   f0100f39 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b1e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b25:	00 
f0101b26:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b2d:	00 
f0101b2e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101b32:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0101b37:	89 04 24             	mov    %eax,(%esp)
f0101b3a:	e8 71 f6 ff ff       	call   f01011b0 <page_insert>
f0101b3f:	85 c0                	test   %eax,%eax
f0101b41:	74 24                	je     f0101b67 <mem_init+0x948>
f0101b43:	c7 44 24 0c 60 54 10 	movl   $0xf0105460,0xc(%esp)
f0101b4a:	f0 
f0101b4b:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101b52:	f0 
f0101b53:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0101b5a:	00 
f0101b5b:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101b62:	e8 4f e5 ff ff       	call   f01000b6 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b67:	8b 3d 8c cd 17 f0    	mov    0xf017cd8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b6d:	a1 b8 c0 17 f0       	mov    0xf017c0b8,%eax
f0101b72:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b75:	8b 17                	mov    (%edi),%edx
f0101b77:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b7d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b80:	29 c1                	sub    %eax,%ecx
f0101b82:	89 c8                	mov    %ecx,%eax
f0101b84:	c1 f8 03             	sar    $0x3,%eax
f0101b87:	c1 e0 0c             	shl    $0xc,%eax
f0101b8a:	39 c2                	cmp    %eax,%edx
f0101b8c:	74 24                	je     f0101bb2 <mem_init+0x993>
f0101b8e:	c7 44 24 0c 90 54 10 	movl   $0xf0105490,0xc(%esp)
f0101b95:	f0 
f0101b96:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101b9d:	f0 
f0101b9e:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0101ba5:	00 
f0101ba6:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101bad:	e8 04 e5 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101bb2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bb7:	89 f8                	mov    %edi,%eax
f0101bb9:	e8 fa ed ff ff       	call   f01009b8 <check_va2pa>
f0101bbe:	89 da                	mov    %ebx,%edx
f0101bc0:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101bc3:	c1 fa 03             	sar    $0x3,%edx
f0101bc6:	c1 e2 0c             	shl    $0xc,%edx
f0101bc9:	39 d0                	cmp    %edx,%eax
f0101bcb:	74 24                	je     f0101bf1 <mem_init+0x9d2>
f0101bcd:	c7 44 24 0c b8 54 10 	movl   $0xf01054b8,0xc(%esp)
f0101bd4:	f0 
f0101bd5:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101bdc:	f0 
f0101bdd:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101be4:	00 
f0101be5:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101bec:	e8 c5 e4 ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 1);
f0101bf1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101bf6:	74 24                	je     f0101c1c <mem_init+0x9fd>
f0101bf8:	c7 44 24 0c ef 50 10 	movl   $0xf01050ef,0xc(%esp)
f0101bff:	f0 
f0101c00:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101c07:	f0 
f0101c08:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0101c0f:	00 
f0101c10:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101c17:	e8 9a e4 ff ff       	call   f01000b6 <_panic>
	assert(pp0->pp_ref == 1);
f0101c1c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c1f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c24:	74 24                	je     f0101c4a <mem_init+0xa2b>
f0101c26:	c7 44 24 0c 00 51 10 	movl   $0xf0105100,0xc(%esp)
f0101c2d:	f0 
f0101c2e:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101c35:	f0 
f0101c36:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0101c3d:	00 
f0101c3e:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101c45:	e8 6c e4 ff ff       	call   f01000b6 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c4a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c51:	00 
f0101c52:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c59:	00 
f0101c5a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c5e:	89 3c 24             	mov    %edi,(%esp)
f0101c61:	e8 4a f5 ff ff       	call   f01011b0 <page_insert>
f0101c66:	85 c0                	test   %eax,%eax
f0101c68:	74 24                	je     f0101c8e <mem_init+0xa6f>
f0101c6a:	c7 44 24 0c e8 54 10 	movl   $0xf01054e8,0xc(%esp)
f0101c71:	f0 
f0101c72:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101c79:	f0 
f0101c7a:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f0101c81:	00 
f0101c82:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101c89:	e8 28 e4 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c8e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c93:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0101c98:	e8 1b ed ff ff       	call   f01009b8 <check_va2pa>
f0101c9d:	89 f2                	mov    %esi,%edx
f0101c9f:	2b 15 b8 c0 17 f0    	sub    0xf017c0b8,%edx
f0101ca5:	c1 fa 03             	sar    $0x3,%edx
f0101ca8:	c1 e2 0c             	shl    $0xc,%edx
f0101cab:	39 d0                	cmp    %edx,%eax
f0101cad:	74 24                	je     f0101cd3 <mem_init+0xab4>
f0101caf:	c7 44 24 0c 24 55 10 	movl   $0xf0105524,0xc(%esp)
f0101cb6:	f0 
f0101cb7:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101cbe:	f0 
f0101cbf:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f0101cc6:	00 
f0101cc7:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101cce:	e8 e3 e3 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0101cd3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101cd8:	74 24                	je     f0101cfe <mem_init+0xadf>
f0101cda:	c7 44 24 0c 11 51 10 	movl   $0xf0105111,0xc(%esp)
f0101ce1:	f0 
f0101ce2:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101ce9:	f0 
f0101cea:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0101cf1:	00 
f0101cf2:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101cf9:	e8 b8 e3 ff ff       	call   f01000b6 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101cfe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d05:	e8 a4 f1 ff ff       	call   f0100eae <page_alloc>
f0101d0a:	85 c0                	test   %eax,%eax
f0101d0c:	74 24                	je     f0101d32 <mem_init+0xb13>
f0101d0e:	c7 44 24 0c 9d 50 10 	movl   $0xf010509d,0xc(%esp)
f0101d15:	f0 
f0101d16:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101d1d:	f0 
f0101d1e:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0101d25:	00 
f0101d26:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101d2d:	e8 84 e3 ff ff       	call   f01000b6 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d32:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d39:	00 
f0101d3a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d41:	00 
f0101d42:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101d46:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0101d4b:	89 04 24             	mov    %eax,(%esp)
f0101d4e:	e8 5d f4 ff ff       	call   f01011b0 <page_insert>
f0101d53:	85 c0                	test   %eax,%eax
f0101d55:	74 24                	je     f0101d7b <mem_init+0xb5c>
f0101d57:	c7 44 24 0c e8 54 10 	movl   $0xf01054e8,0xc(%esp)
f0101d5e:	f0 
f0101d5f:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101d66:	f0 
f0101d67:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f0101d6e:	00 
f0101d6f:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101d76:	e8 3b e3 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d7b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d80:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0101d85:	e8 2e ec ff ff       	call   f01009b8 <check_va2pa>
f0101d8a:	89 f2                	mov    %esi,%edx
f0101d8c:	2b 15 b8 c0 17 f0    	sub    0xf017c0b8,%edx
f0101d92:	c1 fa 03             	sar    $0x3,%edx
f0101d95:	c1 e2 0c             	shl    $0xc,%edx
f0101d98:	39 d0                	cmp    %edx,%eax
f0101d9a:	74 24                	je     f0101dc0 <mem_init+0xba1>
f0101d9c:	c7 44 24 0c 24 55 10 	movl   $0xf0105524,0xc(%esp)
f0101da3:	f0 
f0101da4:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101dab:	f0 
f0101dac:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0101db3:	00 
f0101db4:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101dbb:	e8 f6 e2 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0101dc0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101dc5:	74 24                	je     f0101deb <mem_init+0xbcc>
f0101dc7:	c7 44 24 0c 11 51 10 	movl   $0xf0105111,0xc(%esp)
f0101dce:	f0 
f0101dcf:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101dd6:	f0 
f0101dd7:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0101dde:	00 
f0101ddf:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101de6:	e8 cb e2 ff ff       	call   f01000b6 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101deb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101df2:	e8 b7 f0 ff ff       	call   f0100eae <page_alloc>
f0101df7:	85 c0                	test   %eax,%eax
f0101df9:	74 24                	je     f0101e1f <mem_init+0xc00>
f0101dfb:	c7 44 24 0c 9d 50 10 	movl   $0xf010509d,0xc(%esp)
f0101e02:	f0 
f0101e03:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101e0a:	f0 
f0101e0b:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0101e12:	00 
f0101e13:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101e1a:	e8 97 e2 ff ff       	call   f01000b6 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e1f:	8b 15 8c cd 17 f0    	mov    0xf017cd8c,%edx
f0101e25:	8b 02                	mov    (%edx),%eax
f0101e27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e2c:	89 c1                	mov    %eax,%ecx
f0101e2e:	c1 e9 0c             	shr    $0xc,%ecx
f0101e31:	3b 0d 88 cd 17 f0    	cmp    0xf017cd88,%ecx
f0101e37:	72 20                	jb     f0101e59 <mem_init+0xc3a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e39:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e3d:	c7 44 24 08 04 52 10 	movl   $0xf0105204,0x8(%esp)
f0101e44:	f0 
f0101e45:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0101e4c:	00 
f0101e4d:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101e54:	e8 5d e2 ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f0101e59:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101e61:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e68:	00 
f0101e69:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e70:	00 
f0101e71:	89 14 24             	mov    %edx,(%esp)
f0101e74:	e8 25 f1 ff ff       	call   f0100f9e <pgdir_walk>
f0101e79:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101e7c:	8d 51 04             	lea    0x4(%ecx),%edx
f0101e7f:	39 d0                	cmp    %edx,%eax
f0101e81:	74 24                	je     f0101ea7 <mem_init+0xc88>
f0101e83:	c7 44 24 0c 54 55 10 	movl   $0xf0105554,0xc(%esp)
f0101e8a:	f0 
f0101e8b:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101e92:	f0 
f0101e93:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0101e9a:	00 
f0101e9b:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101ea2:	e8 0f e2 ff ff       	call   f01000b6 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ea7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101eae:	00 
f0101eaf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101eb6:	00 
f0101eb7:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101ebb:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0101ec0:	89 04 24             	mov    %eax,(%esp)
f0101ec3:	e8 e8 f2 ff ff       	call   f01011b0 <page_insert>
f0101ec8:	85 c0                	test   %eax,%eax
f0101eca:	74 24                	je     f0101ef0 <mem_init+0xcd1>
f0101ecc:	c7 44 24 0c 94 55 10 	movl   $0xf0105594,0xc(%esp)
f0101ed3:	f0 
f0101ed4:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101edb:	f0 
f0101edc:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0101ee3:	00 
f0101ee4:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101eeb:	e8 c6 e1 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ef0:	8b 3d 8c cd 17 f0    	mov    0xf017cd8c,%edi
f0101ef6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101efb:	89 f8                	mov    %edi,%eax
f0101efd:	e8 b6 ea ff ff       	call   f01009b8 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f02:	89 f2                	mov    %esi,%edx
f0101f04:	2b 15 b8 c0 17 f0    	sub    0xf017c0b8,%edx
f0101f0a:	c1 fa 03             	sar    $0x3,%edx
f0101f0d:	c1 e2 0c             	shl    $0xc,%edx
f0101f10:	39 d0                	cmp    %edx,%eax
f0101f12:	74 24                	je     f0101f38 <mem_init+0xd19>
f0101f14:	c7 44 24 0c 24 55 10 	movl   $0xf0105524,0xc(%esp)
f0101f1b:	f0 
f0101f1c:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101f23:	f0 
f0101f24:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0101f2b:	00 
f0101f2c:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101f33:	e8 7e e1 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0101f38:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f3d:	74 24                	je     f0101f63 <mem_init+0xd44>
f0101f3f:	c7 44 24 0c 11 51 10 	movl   $0xf0105111,0xc(%esp)
f0101f46:	f0 
f0101f47:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101f4e:	f0 
f0101f4f:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f0101f56:	00 
f0101f57:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101f5e:	e8 53 e1 ff ff       	call   f01000b6 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101f63:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f6a:	00 
f0101f6b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f72:	00 
f0101f73:	89 3c 24             	mov    %edi,(%esp)
f0101f76:	e8 23 f0 ff ff       	call   f0100f9e <pgdir_walk>
f0101f7b:	f6 00 04             	testb  $0x4,(%eax)
f0101f7e:	75 24                	jne    f0101fa4 <mem_init+0xd85>
f0101f80:	c7 44 24 0c d4 55 10 	movl   $0xf01055d4,0xc(%esp)
f0101f87:	f0 
f0101f88:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101f8f:	f0 
f0101f90:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f0101f97:	00 
f0101f98:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101f9f:	e8 12 e1 ff ff       	call   f01000b6 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101fa4:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0101fa9:	f6 00 04             	testb  $0x4,(%eax)
f0101fac:	75 24                	jne    f0101fd2 <mem_init+0xdb3>
f0101fae:	c7 44 24 0c 22 51 10 	movl   $0xf0105122,0xc(%esp)
f0101fb5:	f0 
f0101fb6:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0101fbd:	f0 
f0101fbe:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f0101fc5:	00 
f0101fc6:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0101fcd:	e8 e4 e0 ff ff       	call   f01000b6 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101fd2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101fd9:	00 
f0101fda:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101fe1:	00 
f0101fe2:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101fe6:	89 04 24             	mov    %eax,(%esp)
f0101fe9:	e8 c2 f1 ff ff       	call   f01011b0 <page_insert>
f0101fee:	85 c0                	test   %eax,%eax
f0101ff0:	74 24                	je     f0102016 <mem_init+0xdf7>
f0101ff2:	c7 44 24 0c e8 54 10 	movl   $0xf01054e8,0xc(%esp)
f0101ff9:	f0 
f0101ffa:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102001:	f0 
f0102002:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0102009:	00 
f010200a:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102011:	e8 a0 e0 ff ff       	call   f01000b6 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102016:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010201d:	00 
f010201e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102025:	00 
f0102026:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f010202b:	89 04 24             	mov    %eax,(%esp)
f010202e:	e8 6b ef ff ff       	call   f0100f9e <pgdir_walk>
f0102033:	f6 00 02             	testb  $0x2,(%eax)
f0102036:	75 24                	jne    f010205c <mem_init+0xe3d>
f0102038:	c7 44 24 0c 08 56 10 	movl   $0xf0105608,0xc(%esp)
f010203f:	f0 
f0102040:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102047:	f0 
f0102048:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f010204f:	00 
f0102050:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102057:	e8 5a e0 ff ff       	call   f01000b6 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010205c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102063:	00 
f0102064:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010206b:	00 
f010206c:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0102071:	89 04 24             	mov    %eax,(%esp)
f0102074:	e8 25 ef ff ff       	call   f0100f9e <pgdir_walk>
f0102079:	f6 00 04             	testb  $0x4,(%eax)
f010207c:	74 24                	je     f01020a2 <mem_init+0xe83>
f010207e:	c7 44 24 0c 3c 56 10 	movl   $0xf010563c,0xc(%esp)
f0102085:	f0 
f0102086:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f010208d:	f0 
f010208e:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0102095:	00 
f0102096:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f010209d:	e8 14 e0 ff ff       	call   f01000b6 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01020a2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020a9:	00 
f01020aa:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01020b1:	00 
f01020b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01020b9:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f01020be:	89 04 24             	mov    %eax,(%esp)
f01020c1:	e8 ea f0 ff ff       	call   f01011b0 <page_insert>
f01020c6:	85 c0                	test   %eax,%eax
f01020c8:	78 24                	js     f01020ee <mem_init+0xecf>
f01020ca:	c7 44 24 0c 74 56 10 	movl   $0xf0105674,0xc(%esp)
f01020d1:	f0 
f01020d2:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01020d9:	f0 
f01020da:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f01020e1:	00 
f01020e2:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01020e9:	e8 c8 df ff ff       	call   f01000b6 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01020ee:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020f5:	00 
f01020f6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01020fd:	00 
f01020fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102102:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0102107:	89 04 24             	mov    %eax,(%esp)
f010210a:	e8 a1 f0 ff ff       	call   f01011b0 <page_insert>
f010210f:	85 c0                	test   %eax,%eax
f0102111:	74 24                	je     f0102137 <mem_init+0xf18>
f0102113:	c7 44 24 0c ac 56 10 	movl   $0xf01056ac,0xc(%esp)
f010211a:	f0 
f010211b:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102122:	f0 
f0102123:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f010212a:	00 
f010212b:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102132:	e8 7f df ff ff       	call   f01000b6 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102137:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010213e:	00 
f010213f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102146:	00 
f0102147:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f010214c:	89 04 24             	mov    %eax,(%esp)
f010214f:	e8 4a ee ff ff       	call   f0100f9e <pgdir_walk>
f0102154:	f6 00 04             	testb  $0x4,(%eax)
f0102157:	74 24                	je     f010217d <mem_init+0xf5e>
f0102159:	c7 44 24 0c 3c 56 10 	movl   $0xf010563c,0xc(%esp)
f0102160:	f0 
f0102161:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102168:	f0 
f0102169:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0102170:	00 
f0102171:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102178:	e8 39 df ff ff       	call   f01000b6 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010217d:	8b 3d 8c cd 17 f0    	mov    0xf017cd8c,%edi
f0102183:	ba 00 00 00 00       	mov    $0x0,%edx
f0102188:	89 f8                	mov    %edi,%eax
f010218a:	e8 29 e8 ff ff       	call   f01009b8 <check_va2pa>
f010218f:	89 c1                	mov    %eax,%ecx
f0102191:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102194:	89 d8                	mov    %ebx,%eax
f0102196:	2b 05 b8 c0 17 f0    	sub    0xf017c0b8,%eax
f010219c:	c1 f8 03             	sar    $0x3,%eax
f010219f:	c1 e0 0c             	shl    $0xc,%eax
f01021a2:	39 c1                	cmp    %eax,%ecx
f01021a4:	74 24                	je     f01021ca <mem_init+0xfab>
f01021a6:	c7 44 24 0c e8 56 10 	movl   $0xf01056e8,0xc(%esp)
f01021ad:	f0 
f01021ae:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01021b5:	f0 
f01021b6:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f01021bd:	00 
f01021be:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01021c5:	e8 ec de ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01021ca:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021cf:	89 f8                	mov    %edi,%eax
f01021d1:	e8 e2 e7 ff ff       	call   f01009b8 <check_va2pa>
f01021d6:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01021d9:	74 24                	je     f01021ff <mem_init+0xfe0>
f01021db:	c7 44 24 0c 14 57 10 	movl   $0xf0105714,0xc(%esp)
f01021e2:	f0 
f01021e3:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01021ea:	f0 
f01021eb:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f01021f2:	00 
f01021f3:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01021fa:	e8 b7 de ff ff       	call   f01000b6 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01021ff:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102204:	74 24                	je     f010222a <mem_init+0x100b>
f0102206:	c7 44 24 0c 38 51 10 	movl   $0xf0105138,0xc(%esp)
f010220d:	f0 
f010220e:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102215:	f0 
f0102216:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f010221d:	00 
f010221e:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102225:	e8 8c de ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 0);
f010222a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010222f:	74 24                	je     f0102255 <mem_init+0x1036>
f0102231:	c7 44 24 0c 49 51 10 	movl   $0xf0105149,0xc(%esp)
f0102238:	f0 
f0102239:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102240:	f0 
f0102241:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0102248:	00 
f0102249:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102250:	e8 61 de ff ff       	call   f01000b6 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102255:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010225c:	e8 4d ec ff ff       	call   f0100eae <page_alloc>
f0102261:	85 c0                	test   %eax,%eax
f0102263:	74 04                	je     f0102269 <mem_init+0x104a>
f0102265:	39 c6                	cmp    %eax,%esi
f0102267:	74 24                	je     f010228d <mem_init+0x106e>
f0102269:	c7 44 24 0c 44 57 10 	movl   $0xf0105744,0xc(%esp)
f0102270:	f0 
f0102271:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102278:	f0 
f0102279:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f0102280:	00 
f0102281:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102288:	e8 29 de ff ff       	call   f01000b6 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010228d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102294:	00 
f0102295:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f010229a:	89 04 24             	mov    %eax,(%esp)
f010229d:	e8 c8 ee ff ff       	call   f010116a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01022a2:	8b 3d 8c cd 17 f0    	mov    0xf017cd8c,%edi
f01022a8:	ba 00 00 00 00       	mov    $0x0,%edx
f01022ad:	89 f8                	mov    %edi,%eax
f01022af:	e8 04 e7 ff ff       	call   f01009b8 <check_va2pa>
f01022b4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022b7:	74 24                	je     f01022dd <mem_init+0x10be>
f01022b9:	c7 44 24 0c 68 57 10 	movl   $0xf0105768,0xc(%esp)
f01022c0:	f0 
f01022c1:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01022c8:	f0 
f01022c9:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f01022d0:	00 
f01022d1:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01022d8:	e8 d9 dd ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022dd:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022e2:	89 f8                	mov    %edi,%eax
f01022e4:	e8 cf e6 ff ff       	call   f01009b8 <check_va2pa>
f01022e9:	89 da                	mov    %ebx,%edx
f01022eb:	2b 15 b8 c0 17 f0    	sub    0xf017c0b8,%edx
f01022f1:	c1 fa 03             	sar    $0x3,%edx
f01022f4:	c1 e2 0c             	shl    $0xc,%edx
f01022f7:	39 d0                	cmp    %edx,%eax
f01022f9:	74 24                	je     f010231f <mem_init+0x1100>
f01022fb:	c7 44 24 0c 14 57 10 	movl   $0xf0105714,0xc(%esp)
f0102302:	f0 
f0102303:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f010230a:	f0 
f010230b:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0102312:	00 
f0102313:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f010231a:	e8 97 dd ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 1);
f010231f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102324:	74 24                	je     f010234a <mem_init+0x112b>
f0102326:	c7 44 24 0c ef 50 10 	movl   $0xf01050ef,0xc(%esp)
f010232d:	f0 
f010232e:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102335:	f0 
f0102336:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f010233d:	00 
f010233e:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102345:	e8 6c dd ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 0);
f010234a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010234f:	74 24                	je     f0102375 <mem_init+0x1156>
f0102351:	c7 44 24 0c 49 51 10 	movl   $0xf0105149,0xc(%esp)
f0102358:	f0 
f0102359:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102360:	f0 
f0102361:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0102368:	00 
f0102369:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102370:	e8 41 dd ff ff       	call   f01000b6 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102375:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010237c:	00 
f010237d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102384:	00 
f0102385:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102389:	89 3c 24             	mov    %edi,(%esp)
f010238c:	e8 1f ee ff ff       	call   f01011b0 <page_insert>
f0102391:	85 c0                	test   %eax,%eax
f0102393:	74 24                	je     f01023b9 <mem_init+0x119a>
f0102395:	c7 44 24 0c 8c 57 10 	movl   $0xf010578c,0xc(%esp)
f010239c:	f0 
f010239d:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01023a4:	f0 
f01023a5:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f01023ac:	00 
f01023ad:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01023b4:	e8 fd dc ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref);
f01023b9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023be:	75 24                	jne    f01023e4 <mem_init+0x11c5>
f01023c0:	c7 44 24 0c 5a 51 10 	movl   $0xf010515a,0xc(%esp)
f01023c7:	f0 
f01023c8:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01023cf:	f0 
f01023d0:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f01023d7:	00 
f01023d8:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01023df:	e8 d2 dc ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_link == NULL);
f01023e4:	83 3b 00             	cmpl   $0x0,(%ebx)
f01023e7:	74 24                	je     f010240d <mem_init+0x11ee>
f01023e9:	c7 44 24 0c 66 51 10 	movl   $0xf0105166,0xc(%esp)
f01023f0:	f0 
f01023f1:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01023f8:	f0 
f01023f9:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0102400:	00 
f0102401:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102408:	e8 a9 dc ff ff       	call   f01000b6 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010240d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102414:	00 
f0102415:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f010241a:	89 04 24             	mov    %eax,(%esp)
f010241d:	e8 48 ed ff ff       	call   f010116a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102422:	8b 3d 8c cd 17 f0    	mov    0xf017cd8c,%edi
f0102428:	ba 00 00 00 00       	mov    $0x0,%edx
f010242d:	89 f8                	mov    %edi,%eax
f010242f:	e8 84 e5 ff ff       	call   f01009b8 <check_va2pa>
f0102434:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102437:	74 24                	je     f010245d <mem_init+0x123e>
f0102439:	c7 44 24 0c 68 57 10 	movl   $0xf0105768,0xc(%esp)
f0102440:	f0 
f0102441:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102448:	f0 
f0102449:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0102450:	00 
f0102451:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102458:	e8 59 dc ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010245d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102462:	89 f8                	mov    %edi,%eax
f0102464:	e8 4f e5 ff ff       	call   f01009b8 <check_va2pa>
f0102469:	83 f8 ff             	cmp    $0xffffffff,%eax
f010246c:	74 24                	je     f0102492 <mem_init+0x1273>
f010246e:	c7 44 24 0c c4 57 10 	movl   $0xf01057c4,0xc(%esp)
f0102475:	f0 
f0102476:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f010247d:	f0 
f010247e:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0102485:	00 
f0102486:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f010248d:	e8 24 dc ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 0);
f0102492:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102497:	74 24                	je     f01024bd <mem_init+0x129e>
f0102499:	c7 44 24 0c 7b 51 10 	movl   $0xf010517b,0xc(%esp)
f01024a0:	f0 
f01024a1:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01024a8:	f0 
f01024a9:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f01024b0:	00 
f01024b1:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01024b8:	e8 f9 db ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 0);
f01024bd:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01024c2:	74 24                	je     f01024e8 <mem_init+0x12c9>
f01024c4:	c7 44 24 0c 49 51 10 	movl   $0xf0105149,0xc(%esp)
f01024cb:	f0 
f01024cc:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01024d3:	f0 
f01024d4:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f01024db:	00 
f01024dc:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01024e3:	e8 ce db ff ff       	call   f01000b6 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01024e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024ef:	e8 ba e9 ff ff       	call   f0100eae <page_alloc>
f01024f4:	85 c0                	test   %eax,%eax
f01024f6:	74 04                	je     f01024fc <mem_init+0x12dd>
f01024f8:	39 c3                	cmp    %eax,%ebx
f01024fa:	74 24                	je     f0102520 <mem_init+0x1301>
f01024fc:	c7 44 24 0c ec 57 10 	movl   $0xf01057ec,0xc(%esp)
f0102503:	f0 
f0102504:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f010250b:	f0 
f010250c:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0102513:	00 
f0102514:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f010251b:	e8 96 db ff ff       	call   f01000b6 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102520:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102527:	e8 82 e9 ff ff       	call   f0100eae <page_alloc>
f010252c:	85 c0                	test   %eax,%eax
f010252e:	74 24                	je     f0102554 <mem_init+0x1335>
f0102530:	c7 44 24 0c 9d 50 10 	movl   $0xf010509d,0xc(%esp)
f0102537:	f0 
f0102538:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f010253f:	f0 
f0102540:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0102547:	00 
f0102548:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f010254f:	e8 62 db ff ff       	call   f01000b6 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102554:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0102559:	8b 08                	mov    (%eax),%ecx
f010255b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102561:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102564:	2b 15 b8 c0 17 f0    	sub    0xf017c0b8,%edx
f010256a:	c1 fa 03             	sar    $0x3,%edx
f010256d:	c1 e2 0c             	shl    $0xc,%edx
f0102570:	39 d1                	cmp    %edx,%ecx
f0102572:	74 24                	je     f0102598 <mem_init+0x1379>
f0102574:	c7 44 24 0c 90 54 10 	movl   $0xf0105490,0xc(%esp)
f010257b:	f0 
f010257c:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102583:	f0 
f0102584:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f010258b:	00 
f010258c:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102593:	e8 1e db ff ff       	call   f01000b6 <_panic>
	kern_pgdir[0] = 0;
f0102598:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010259e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025a1:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01025a6:	74 24                	je     f01025cc <mem_init+0x13ad>
f01025a8:	c7 44 24 0c 00 51 10 	movl   $0xf0105100,0xc(%esp)
f01025af:	f0 
f01025b0:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01025b7:	f0 
f01025b8:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f01025bf:	00 
f01025c0:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01025c7:	e8 ea da ff ff       	call   f01000b6 <_panic>
	pp0->pp_ref = 0;
f01025cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025cf:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01025d5:	89 04 24             	mov    %eax,(%esp)
f01025d8:	e8 5c e9 ff ff       	call   f0100f39 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01025dd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01025e4:	00 
f01025e5:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01025ec:	00 
f01025ed:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f01025f2:	89 04 24             	mov    %eax,(%esp)
f01025f5:	e8 a4 e9 ff ff       	call   f0100f9e <pgdir_walk>
f01025fa:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01025fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102600:	8b 15 8c cd 17 f0    	mov    0xf017cd8c,%edx
f0102606:	8b 7a 04             	mov    0x4(%edx),%edi
f0102609:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010260f:	8b 0d 88 cd 17 f0    	mov    0xf017cd88,%ecx
f0102615:	89 f8                	mov    %edi,%eax
f0102617:	c1 e8 0c             	shr    $0xc,%eax
f010261a:	39 c8                	cmp    %ecx,%eax
f010261c:	72 20                	jb     f010263e <mem_init+0x141f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010261e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102622:	c7 44 24 08 04 52 10 	movl   $0xf0105204,0x8(%esp)
f0102629:	f0 
f010262a:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f0102631:	00 
f0102632:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102639:	e8 78 da ff ff       	call   f01000b6 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010263e:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0102644:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0102647:	74 24                	je     f010266d <mem_init+0x144e>
f0102649:	c7 44 24 0c 8c 51 10 	movl   $0xf010518c,0xc(%esp)
f0102650:	f0 
f0102651:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102658:	f0 
f0102659:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0102660:	00 
f0102661:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102668:	e8 49 da ff ff       	call   f01000b6 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010266d:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f0102674:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102677:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010267d:	2b 05 b8 c0 17 f0    	sub    0xf017c0b8,%eax
f0102683:	c1 f8 03             	sar    $0x3,%eax
f0102686:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102689:	89 c2                	mov    %eax,%edx
f010268b:	c1 ea 0c             	shr    $0xc,%edx
f010268e:	39 d1                	cmp    %edx,%ecx
f0102690:	77 20                	ja     f01026b2 <mem_init+0x1493>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102692:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102696:	c7 44 24 08 04 52 10 	movl   $0xf0105204,0x8(%esp)
f010269d:	f0 
f010269e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01026a5:	00 
f01026a6:	c7 04 24 84 4e 10 f0 	movl   $0xf0104e84,(%esp)
f01026ad:	e8 04 da ff ff       	call   f01000b6 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01026b2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01026b9:	00 
f01026ba:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01026c1:	00 
	return (void *)(pa + KERNBASE);
f01026c2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026c7:	89 04 24             	mov    %eax,(%esp)
f01026ca:	e8 28 1e 00 00       	call   f01044f7 <memset>
	page_free(pp0);
f01026cf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01026d2:	89 3c 24             	mov    %edi,(%esp)
f01026d5:	e8 5f e8 ff ff       	call   f0100f39 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01026da:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01026e1:	00 
f01026e2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01026e9:	00 
f01026ea:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f01026ef:	89 04 24             	mov    %eax,(%esp)
f01026f2:	e8 a7 e8 ff ff       	call   f0100f9e <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026f7:	89 fa                	mov    %edi,%edx
f01026f9:	2b 15 b8 c0 17 f0    	sub    0xf017c0b8,%edx
f01026ff:	c1 fa 03             	sar    $0x3,%edx
f0102702:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102705:	89 d0                	mov    %edx,%eax
f0102707:	c1 e8 0c             	shr    $0xc,%eax
f010270a:	3b 05 88 cd 17 f0    	cmp    0xf017cd88,%eax
f0102710:	72 20                	jb     f0102732 <mem_init+0x1513>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102712:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102716:	c7 44 24 08 04 52 10 	movl   $0xf0105204,0x8(%esp)
f010271d:	f0 
f010271e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102725:	00 
f0102726:	c7 04 24 84 4e 10 f0 	movl   $0xf0104e84,(%esp)
f010272d:	e8 84 d9 ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f0102732:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102738:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010273b:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102741:	f6 00 01             	testb  $0x1,(%eax)
f0102744:	74 24                	je     f010276a <mem_init+0x154b>
f0102746:	c7 44 24 0c a4 51 10 	movl   $0xf01051a4,0xc(%esp)
f010274d:	f0 
f010274e:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102755:	f0 
f0102756:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f010275d:	00 
f010275e:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102765:	e8 4c d9 ff ff       	call   f01000b6 <_panic>
f010276a:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010276d:	39 d0                	cmp    %edx,%eax
f010276f:	75 d0                	jne    f0102741 <mem_init+0x1522>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102771:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0102776:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010277c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010277f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102785:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102788:	89 3d c0 c0 17 f0    	mov    %edi,0xf017c0c0

	// free the pages we took
	page_free(pp0);
f010278e:	89 04 24             	mov    %eax,(%esp)
f0102791:	e8 a3 e7 ff ff       	call   f0100f39 <page_free>
	page_free(pp1);
f0102796:	89 1c 24             	mov    %ebx,(%esp)
f0102799:	e8 9b e7 ff ff       	call   f0100f39 <page_free>
	page_free(pp2);
f010279e:	89 34 24             	mov    %esi,(%esp)
f01027a1:	e8 93 e7 ff ff       	call   f0100f39 <page_free>

	cprintf("check_page() succeeded!\n");
f01027a6:	c7 04 24 bb 51 10 f0 	movl   $0xf01051bb,(%esp)
f01027ad:	e8 3c 0d 00 00       	call   f01034ee <cprintf>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	//test =1;
	//test=0;
	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(sizeof(struct PageInfo) * npages,PGSIZE),PADDR(pages),PTE_U);
f01027b2:	a1 b8 c0 17 f0       	mov    0xf017c0b8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027b7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027bc:	77 20                	ja     f01027de <mem_init+0x15bf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027be:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01027c2:	c7 44 24 08 ec 52 10 	movl   $0xf01052ec,0x8(%esp)
f01027c9:	f0 
f01027ca:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f01027d1:	00 
f01027d2:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01027d9:	e8 d8 d8 ff ff       	call   f01000b6 <_panic>
f01027de:	8b 15 88 cd 17 f0    	mov    0xf017cd88,%edx
f01027e4:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f01027eb:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01027f1:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f01027f8:	00 
	return (physaddr_t)kva - KERNBASE;
f01027f9:	05 00 00 00 10       	add    $0x10000000,%eax
f01027fe:	89 04 24             	mov    %eax,(%esp)
f0102801:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102806:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f010280b:	e8 73 e8 ff ff       	call   f0101083 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV*sizeof(struct Env),PGSIZE),PADDR(envs),PTE_U | PTE_P);
f0102810:	a1 cc c0 17 f0       	mov    0xf017c0cc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102815:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010281a:	77 20                	ja     f010283c <mem_init+0x161d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010281c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102820:	c7 44 24 08 ec 52 10 	movl   $0xf01052ec,0x8(%esp)
f0102827:	f0 
f0102828:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
f010282f:	00 
f0102830:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102837:	e8 7a d8 ff ff       	call   f01000b6 <_panic>
f010283c:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102843:	00 
	return (physaddr_t)kva - KERNBASE;
f0102844:	05 00 00 00 10       	add    $0x10000000,%eax
f0102849:	89 04 24             	mov    %eax,(%esp)
f010284c:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0102851:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102856:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f010285b:	e8 23 e8 ff ff       	call   f0101083 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102860:	bb 00 00 11 f0       	mov    $0xf0110000,%ebx
f0102865:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010286b:	77 20                	ja     f010288d <mem_init+0x166e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010286d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102871:	c7 44 24 08 ec 52 10 	movl   $0xf01052ec,0x8(%esp)
f0102878:	f0 
f0102879:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
f0102880:	00 
f0102881:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102888:	e8 29 d8 ff ff       	call   f01000b6 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	//test = 0;	
	cprintf("Bootstack:%x,PADDR(Bootstack):%x",bootstack,PADDR(bootstack));	
f010288d:	c7 44 24 08 00 00 11 	movl   $0x110000,0x8(%esp)
f0102894:	00 
f0102895:	c7 44 24 04 00 00 11 	movl   $0xf0110000,0x4(%esp)
f010289c:	f0 
f010289d:	c7 04 24 10 58 10 f0 	movl   $0xf0105810,(%esp)
f01028a4:	e8 45 0c 00 00       	call   f01034ee <cprintf>
	boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W);//why not second 
f01028a9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01028b0:	00 
f01028b1:	c7 04 24 00 00 11 00 	movl   $0x110000,(%esp)
f01028b8:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01028bd:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01028c2:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f01028c7:	e8 b7 e7 ff ff       	call   f0101083 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	//test = 0;
	boot_map_region(kern_pgdir,KERNBASE,ROUNDUP((0xFFFFFFFF - KERNBASE),PGSIZE),0x0,PTE_W);//0xFFFFFFFF - KERNBASE=256MB
f01028cc:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01028d3:	00 
f01028d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028db:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01028e0:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01028e5:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f01028ea:	e8 94 e7 ff ff       	call   f0101083 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01028ef:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f01028f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01028f7:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f01028fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01028ff:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102906:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010290b:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010290e:	8b 3d b8 c0 17 f0    	mov    0xf017c0b8,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102914:	89 7d c8             	mov    %edi,-0x38(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102917:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f010291d:	89 45 c4             	mov    %eax,-0x3c(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102920:	be 00 00 00 00       	mov    $0x0,%esi
f0102925:	eb 6b                	jmp    f0102992 <mem_init+0x1773>
f0102927:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010292d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102930:	e8 83 e0 ff ff       	call   f01009b8 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102935:	81 7d c8 ff ff ff ef 	cmpl   $0xefffffff,-0x38(%ebp)
f010293c:	77 20                	ja     f010295e <mem_init+0x173f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010293e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102942:	c7 44 24 08 ec 52 10 	movl   $0xf01052ec,0x8(%esp)
f0102949:	f0 
f010294a:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f0102951:	00 
f0102952:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102959:	e8 58 d7 ff ff       	call   f01000b6 <_panic>
f010295e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102961:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0102964:	39 d0                	cmp    %edx,%eax
f0102966:	74 24                	je     f010298c <mem_init+0x176d>
f0102968:	c7 44 24 0c 34 58 10 	movl   $0xf0105834,0xc(%esp)
f010296f:	f0 
f0102970:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102977:	f0 
f0102978:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f010297f:	00 
f0102980:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102987:	e8 2a d7 ff ff       	call   f01000b6 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010298c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102992:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f0102995:	77 90                	ja     f0102927 <mem_init+0x1708>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102997:	8b 35 cc c0 17 f0    	mov    0xf017c0cc,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010299d:	89 f7                	mov    %esi,%edi
f010299f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01029a4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029a7:	e8 0c e0 ff ff       	call   f01009b8 <check_va2pa>
f01029ac:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01029b2:	77 20                	ja     f01029d4 <mem_init+0x17b5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029b4:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01029b8:	c7 44 24 08 ec 52 10 	movl   $0xf01052ec,0x8(%esp)
f01029bf:	f0 
f01029c0:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f01029c7:	00 
f01029c8:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f01029cf:	e8 e2 d6 ff ff       	call   f01000b6 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029d4:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f01029d9:	81 c7 00 00 40 21    	add    $0x21400000,%edi
f01029df:	8d 14 37             	lea    (%edi,%esi,1),%edx
f01029e2:	39 c2                	cmp    %eax,%edx
f01029e4:	74 24                	je     f0102a0a <mem_init+0x17eb>
f01029e6:	c7 44 24 0c 68 58 10 	movl   $0xf0105868,0xc(%esp)
f01029ed:	f0 
f01029ee:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01029f5:	f0 
f01029f6:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f01029fd:	00 
f01029fe:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102a05:	e8 ac d6 ff ff       	call   f01000b6 <_panic>
f0102a0a:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102a10:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f0102a16:	0f 85 26 05 00 00    	jne    f0102f42 <mem_init+0x1d23>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a1c:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102a1f:	c1 e7 0c             	shl    $0xc,%edi
f0102a22:	be 00 00 00 00       	mov    $0x0,%esi
f0102a27:	eb 3c                	jmp    f0102a65 <mem_init+0x1846>
f0102a29:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a2f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a32:	e8 81 df ff ff       	call   f01009b8 <check_va2pa>
f0102a37:	39 c6                	cmp    %eax,%esi
f0102a39:	74 24                	je     f0102a5f <mem_init+0x1840>
f0102a3b:	c7 44 24 0c 9c 58 10 	movl   $0xf010589c,0xc(%esp)
f0102a42:	f0 
f0102a43:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102a4a:	f0 
f0102a4b:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f0102a52:	00 
f0102a53:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102a5a:	e8 57 d6 ff ff       	call   f01000b6 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a5f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102a65:	39 fe                	cmp    %edi,%esi
f0102a67:	72 c0                	jb     f0102a29 <mem_init+0x180a>
f0102a69:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102a6e:	81 c3 00 80 00 20    	add    $0x20008000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102a74:	89 f2                	mov    %esi,%edx
f0102a76:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a79:	e8 3a df ff ff       	call   f01009b8 <check_va2pa>
f0102a7e:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102a81:	39 d0                	cmp    %edx,%eax
f0102a83:	74 24                	je     f0102aa9 <mem_init+0x188a>
f0102a85:	c7 44 24 0c c4 58 10 	movl   $0xf01058c4,0xc(%esp)
f0102a8c:	f0 
f0102a8d:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102a94:	f0 
f0102a95:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f0102a9c:	00 
f0102a9d:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102aa4:	e8 0d d6 ff ff       	call   f01000b6 <_panic>
f0102aa9:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102aaf:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102ab5:	75 bd                	jne    f0102a74 <mem_init+0x1855>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102ab7:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102abc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102abf:	89 f8                	mov    %edi,%eax
f0102ac1:	e8 f2 de ff ff       	call   f01009b8 <check_va2pa>
f0102ac6:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102ac9:	75 0c                	jne    f0102ad7 <mem_init+0x18b8>
f0102acb:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ad0:	89 fa                	mov    %edi,%edx
f0102ad2:	e9 f0 00 00 00       	jmp    f0102bc7 <mem_init+0x19a8>
f0102ad7:	c7 44 24 0c 0c 59 10 	movl   $0xf010590c,0xc(%esp)
f0102ade:	f0 
f0102adf:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102ae6:	f0 
f0102ae7:	c7 44 24 04 2c 03 00 	movl   $0x32c,0x4(%esp)
f0102aee:	00 
f0102aef:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102af6:	e8 bb d5 ff ff       	call   f01000b6 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102afb:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102b00:	72 3c                	jb     f0102b3e <mem_init+0x191f>
f0102b02:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102b07:	76 07                	jbe    f0102b10 <mem_init+0x18f1>
f0102b09:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102b0e:	75 2e                	jne    f0102b3e <mem_init+0x191f>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102b10:	f6 04 82 01          	testb  $0x1,(%edx,%eax,4)
f0102b14:	0f 85 aa 00 00 00    	jne    f0102bc4 <mem_init+0x19a5>
f0102b1a:	c7 44 24 0c d4 51 10 	movl   $0xf01051d4,0xc(%esp)
f0102b21:	f0 
f0102b22:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102b29:	f0 
f0102b2a:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0102b31:	00 
f0102b32:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102b39:	e8 78 d5 ff ff       	call   f01000b6 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102b3e:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102b43:	76 55                	jbe    f0102b9a <mem_init+0x197b>
				assert(pgdir[i] & PTE_P);
f0102b45:	8b 0c 82             	mov    (%edx,%eax,4),%ecx
f0102b48:	f6 c1 01             	test   $0x1,%cl
f0102b4b:	75 24                	jne    f0102b71 <mem_init+0x1952>
f0102b4d:	c7 44 24 0c d4 51 10 	movl   $0xf01051d4,0xc(%esp)
f0102b54:	f0 
f0102b55:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102b5c:	f0 
f0102b5d:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f0102b64:	00 
f0102b65:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102b6c:	e8 45 d5 ff ff       	call   f01000b6 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b71:	f6 c1 02             	test   $0x2,%cl
f0102b74:	75 4e                	jne    f0102bc4 <mem_init+0x19a5>
f0102b76:	c7 44 24 0c e5 51 10 	movl   $0xf01051e5,0xc(%esp)
f0102b7d:	f0 
f0102b7e:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102b85:	f0 
f0102b86:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f0102b8d:	00 
f0102b8e:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102b95:	e8 1c d5 ff ff       	call   f01000b6 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102b9a:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
f0102b9e:	74 24                	je     f0102bc4 <mem_init+0x19a5>
f0102ba0:	c7 44 24 0c f6 51 10 	movl   $0xf01051f6,0xc(%esp)
f0102ba7:	f0 
f0102ba8:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102baf:	f0 
f0102bb0:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f0102bb7:	00 
f0102bb8:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102bbf:	e8 f2 d4 ff ff       	call   f01000b6 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102bc4:	83 c0 01             	add    $0x1,%eax
f0102bc7:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102bcc:	0f 85 29 ff ff ff    	jne    f0102afb <mem_init+0x18dc>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102bd2:	c7 04 24 3c 59 10 f0 	movl   $0xf010593c,(%esp)
f0102bd9:	e8 10 09 00 00       	call   f01034ee <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102bde:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0102be3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102be8:	77 20                	ja     f0102c0a <mem_init+0x19eb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bea:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bee:	c7 44 24 08 ec 52 10 	movl   $0xf01052ec,0x8(%esp)
f0102bf5:	f0 
f0102bf6:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
f0102bfd:	00 
f0102bfe:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102c05:	e8 ac d4 ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102c0a:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102c0f:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102c12:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c17:	e8 0b de ff ff       	call   f0100a27 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102c1c:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0102c1f:	83 e0 f3             	and    $0xfffffff3,%eax
f0102c22:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102c27:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102c2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c31:	e8 78 e2 ff ff       	call   f0100eae <page_alloc>
f0102c36:	89 c3                	mov    %eax,%ebx
f0102c38:	85 c0                	test   %eax,%eax
f0102c3a:	75 24                	jne    f0102c60 <mem_init+0x1a41>
f0102c3c:	c7 44 24 0c f2 4f 10 	movl   $0xf0104ff2,0xc(%esp)
f0102c43:	f0 
f0102c44:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102c4b:	f0 
f0102c4c:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f0102c53:	00 
f0102c54:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102c5b:	e8 56 d4 ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f0102c60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c67:	e8 42 e2 ff ff       	call   f0100eae <page_alloc>
f0102c6c:	89 c7                	mov    %eax,%edi
f0102c6e:	85 c0                	test   %eax,%eax
f0102c70:	75 24                	jne    f0102c96 <mem_init+0x1a77>
f0102c72:	c7 44 24 0c 08 50 10 	movl   $0xf0105008,0xc(%esp)
f0102c79:	f0 
f0102c7a:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102c81:	f0 
f0102c82:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f0102c89:	00 
f0102c8a:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102c91:	e8 20 d4 ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f0102c96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c9d:	e8 0c e2 ff ff       	call   f0100eae <page_alloc>
f0102ca2:	89 c6                	mov    %eax,%esi
f0102ca4:	85 c0                	test   %eax,%eax
f0102ca6:	75 24                	jne    f0102ccc <mem_init+0x1aad>
f0102ca8:	c7 44 24 0c 1e 50 10 	movl   $0xf010501e,0xc(%esp)
f0102caf:	f0 
f0102cb0:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102cb7:	f0 
f0102cb8:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0102cbf:	00 
f0102cc0:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102cc7:	e8 ea d3 ff ff       	call   f01000b6 <_panic>
	page_free(pp0);
f0102ccc:	89 1c 24             	mov    %ebx,(%esp)
f0102ccf:	e8 65 e2 ff ff       	call   f0100f39 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0102cd4:	89 f8                	mov    %edi,%eax
f0102cd6:	e8 98 dc ff ff       	call   f0100973 <page2kva>
f0102cdb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102ce2:	00 
f0102ce3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102cea:	00 
f0102ceb:	89 04 24             	mov    %eax,(%esp)
f0102cee:	e8 04 18 00 00       	call   f01044f7 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0102cf3:	89 f0                	mov    %esi,%eax
f0102cf5:	e8 79 dc ff ff       	call   f0100973 <page2kva>
f0102cfa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102d01:	00 
f0102d02:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102d09:	00 
f0102d0a:	89 04 24             	mov    %eax,(%esp)
f0102d0d:	e8 e5 17 00 00       	call   f01044f7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d12:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102d19:	00 
f0102d1a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102d21:	00 
f0102d22:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102d26:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0102d2b:	89 04 24             	mov    %eax,(%esp)
f0102d2e:	e8 7d e4 ff ff       	call   f01011b0 <page_insert>
	assert(pp1->pp_ref == 1);
f0102d33:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d38:	74 24                	je     f0102d5e <mem_init+0x1b3f>
f0102d3a:	c7 44 24 0c ef 50 10 	movl   $0xf01050ef,0xc(%esp)
f0102d41:	f0 
f0102d42:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102d49:	f0 
f0102d4a:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f0102d51:	00 
f0102d52:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102d59:	e8 58 d3 ff ff       	call   f01000b6 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d5e:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102d65:	01 01 01 
f0102d68:	74 24                	je     f0102d8e <mem_init+0x1b6f>
f0102d6a:	c7 44 24 0c 5c 59 10 	movl   $0xf010595c,0xc(%esp)
f0102d71:	f0 
f0102d72:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102d79:	f0 
f0102d7a:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f0102d81:	00 
f0102d82:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102d89:	e8 28 d3 ff ff       	call   f01000b6 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102d8e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102d95:	00 
f0102d96:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102d9d:	00 
f0102d9e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102da2:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0102da7:	89 04 24             	mov    %eax,(%esp)
f0102daa:	e8 01 e4 ff ff       	call   f01011b0 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102daf:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102db6:	02 02 02 
f0102db9:	74 24                	je     f0102ddf <mem_init+0x1bc0>
f0102dbb:	c7 44 24 0c 80 59 10 	movl   $0xf0105980,0xc(%esp)
f0102dc2:	f0 
f0102dc3:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102dca:	f0 
f0102dcb:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f0102dd2:	00 
f0102dd3:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102dda:	e8 d7 d2 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0102ddf:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102de4:	74 24                	je     f0102e0a <mem_init+0x1beb>
f0102de6:	c7 44 24 0c 11 51 10 	movl   $0xf0105111,0xc(%esp)
f0102ded:	f0 
f0102dee:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102df5:	f0 
f0102df6:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f0102dfd:	00 
f0102dfe:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102e05:	e8 ac d2 ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 0);
f0102e0a:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102e0f:	74 24                	je     f0102e35 <mem_init+0x1c16>
f0102e11:	c7 44 24 0c 7b 51 10 	movl   $0xf010517b,0xc(%esp)
f0102e18:	f0 
f0102e19:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102e20:	f0 
f0102e21:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f0102e28:	00 
f0102e29:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102e30:	e8 81 d2 ff ff       	call   f01000b6 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102e35:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102e3c:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e3f:	89 f0                	mov    %esi,%eax
f0102e41:	e8 2d db ff ff       	call   f0100973 <page2kva>
f0102e46:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0102e4c:	74 24                	je     f0102e72 <mem_init+0x1c53>
f0102e4e:	c7 44 24 0c a4 59 10 	movl   $0xf01059a4,0xc(%esp)
f0102e55:	f0 
f0102e56:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102e5d:	f0 
f0102e5e:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102e65:	00 
f0102e66:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102e6d:	e8 44 d2 ff ff       	call   f01000b6 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e72:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102e79:	00 
f0102e7a:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0102e7f:	89 04 24             	mov    %eax,(%esp)
f0102e82:	e8 e3 e2 ff ff       	call   f010116a <page_remove>
	assert(pp2->pp_ref == 0);
f0102e87:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102e8c:	74 24                	je     f0102eb2 <mem_init+0x1c93>
f0102e8e:	c7 44 24 0c 49 51 10 	movl   $0xf0105149,0xc(%esp)
f0102e95:	f0 
f0102e96:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102e9d:	f0 
f0102e9e:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f0102ea5:	00 
f0102ea6:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102ead:	e8 04 d2 ff ff       	call   f01000b6 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102eb2:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0102eb7:	8b 08                	mov    (%eax),%ecx
f0102eb9:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ebf:	89 da                	mov    %ebx,%edx
f0102ec1:	2b 15 b8 c0 17 f0    	sub    0xf017c0b8,%edx
f0102ec7:	c1 fa 03             	sar    $0x3,%edx
f0102eca:	c1 e2 0c             	shl    $0xc,%edx
f0102ecd:	39 d1                	cmp    %edx,%ecx
f0102ecf:	74 24                	je     f0102ef5 <mem_init+0x1cd6>
f0102ed1:	c7 44 24 0c 90 54 10 	movl   $0xf0105490,0xc(%esp)
f0102ed8:	f0 
f0102ed9:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102ee0:	f0 
f0102ee1:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f0102ee8:	00 
f0102ee9:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102ef0:	e8 c1 d1 ff ff       	call   f01000b6 <_panic>
	kern_pgdir[0] = 0;
f0102ef5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102efb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102f00:	74 24                	je     f0102f26 <mem_init+0x1d07>
f0102f02:	c7 44 24 0c 00 51 10 	movl   $0xf0105100,0xc(%esp)
f0102f09:	f0 
f0102f0a:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0102f11:	f0 
f0102f12:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f0102f19:	00 
f0102f1a:	c7 04 24 92 4e 10 f0 	movl   $0xf0104e92,(%esp)
f0102f21:	e8 90 d1 ff ff       	call   f01000b6 <_panic>
	pp0->pp_ref = 0;
f0102f26:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102f2c:	89 1c 24             	mov    %ebx,(%esp)
f0102f2f:	e8 05 e0 ff ff       	call   f0100f39 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102f34:	c7 04 24 d0 59 10 f0 	movl   $0xf01059d0,(%esp)
f0102f3b:	e8 ae 05 00 00       	call   f01034ee <cprintf>
f0102f40:	eb 0f                	jmp    f0102f51 <mem_init+0x1d32>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102f42:	89 f2                	mov    %esi,%edx
f0102f44:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f47:	e8 6c da ff ff       	call   f01009b8 <check_va2pa>
f0102f4c:	e9 8e fa ff ff       	jmp    f01029df <mem_init+0x17c0>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102f51:	83 c4 4c             	add    $0x4c,%esp
f0102f54:	5b                   	pop    %ebx
f0102f55:	5e                   	pop    %esi
f0102f56:	5f                   	pop    %edi
f0102f57:	5d                   	pop    %ebp
f0102f58:	c3                   	ret    

f0102f59 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102f59:	55                   	push   %ebp
f0102f5a:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f5f:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102f62:	5d                   	pop    %ebp
f0102f63:	c3                   	ret    

f0102f64 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102f64:	55                   	push   %ebp
f0102f65:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	return 0;
}
f0102f67:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f6c:	5d                   	pop    %ebp
f0102f6d:	c3                   	ret    

f0102f6e <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102f6e:	55                   	push   %ebp
f0102f6f:	89 e5                	mov    %esp,%ebp
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
		cprintf("[%08x] user_mem_check assertion failure for "
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
	}
}
f0102f71:	5d                   	pop    %ebp
f0102f72:	c3                   	ret    

f0102f73 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102f73:	55                   	push   %ebp
f0102f74:	89 e5                	mov    %esp,%ebp
f0102f76:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f79:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102f7c:	85 c0                	test   %eax,%eax
f0102f7e:	75 11                	jne    f0102f91 <envid2env+0x1e>
		*env_store = curenv;
f0102f80:	a1 c8 c0 17 f0       	mov    0xf017c0c8,%eax
f0102f85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102f88:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102f8a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f8f:	eb 5e                	jmp    f0102fef <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102f91:	89 c2                	mov    %eax,%edx
f0102f93:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102f99:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102f9c:	c1 e2 05             	shl    $0x5,%edx
f0102f9f:	03 15 cc c0 17 f0    	add    0xf017c0cc,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102fa5:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102fa9:	74 05                	je     f0102fb0 <envid2env+0x3d>
f0102fab:	39 42 48             	cmp    %eax,0x48(%edx)
f0102fae:	74 10                	je     f0102fc0 <envid2env+0x4d>
		*env_store = 0;
f0102fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fb3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102fb9:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102fbe:	eb 2f                	jmp    f0102fef <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102fc0:	84 c9                	test   %cl,%cl
f0102fc2:	74 21                	je     f0102fe5 <envid2env+0x72>
f0102fc4:	a1 c8 c0 17 f0       	mov    0xf017c0c8,%eax
f0102fc9:	39 c2                	cmp    %eax,%edx
f0102fcb:	74 18                	je     f0102fe5 <envid2env+0x72>
f0102fcd:	8b 40 48             	mov    0x48(%eax),%eax
f0102fd0:	39 42 4c             	cmp    %eax,0x4c(%edx)
f0102fd3:	74 10                	je     f0102fe5 <envid2env+0x72>
		*env_store = 0;
f0102fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fd8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102fde:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102fe3:	eb 0a                	jmp    f0102fef <envid2env+0x7c>
	}

	*env_store = e;
f0102fe5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fe8:	89 10                	mov    %edx,(%eax)
	return 0;
f0102fea:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102fef:	5d                   	pop    %ebp
f0102ff0:	c3                   	ret    

f0102ff1 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102ff1:	55                   	push   %ebp
f0102ff2:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102ff4:	b8 00 a3 11 f0       	mov    $0xf011a300,%eax
f0102ff9:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102ffc:	b8 23 00 00 00       	mov    $0x23,%eax
f0103001:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103003:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103005:	b0 10                	mov    $0x10,%al
f0103007:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103009:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010300b:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f010300d:	ea 14 30 10 f0 08 00 	ljmp   $0x8,$0xf0103014
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103014:	b0 00                	mov    $0x0,%al
f0103016:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103019:	5d                   	pop    %ebp
f010301a:	c3                   	ret    

f010301b <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010301b:	55                   	push   %ebp
f010301c:	89 e5                	mov    %esp,%ebp
f010301e:	56                   	push   %esi
f010301f:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i=0;i<NENV;i++)
	{
		envs[i].env_id = 0;
f0103020:	8b 35 cc c0 17 f0    	mov    0xf017c0cc,%esi
f0103026:	8b 0d d0 c0 17 f0    	mov    0xf017c0d0,%ecx
f010302c:	89 f0                	mov    %esi,%eax
f010302e:	ba 00 04 00 00       	mov    $0x400,%edx
f0103033:	89 c3                	mov    %eax,%ebx
f0103035:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f010303c:	89 48 44             	mov    %ecx,0x44(%eax)
f010303f:	83 c0 60             	add    $0x60,%eax
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i=0;i<NENV;i++)
f0103042:	83 ea 01             	sub    $0x1,%edx
f0103045:	74 04                	je     f010304b <env_init+0x30>
	{
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f0103047:	89 d9                	mov    %ebx,%ecx
f0103049:	eb e8                	jmp    f0103033 <env_init+0x18>
f010304b:	81 c6 a0 7f 01 00    	add    $0x17fa0,%esi
f0103051:	89 35 d0 c0 17 f0    	mov    %esi,0xf017c0d0
	}	

	// Per-CPU part of the initialization
	env_init_percpu();
f0103057:	e8 95 ff ff ff       	call   f0102ff1 <env_init_percpu>
}
f010305c:	5b                   	pop    %ebx
f010305d:	5e                   	pop    %esi
f010305e:	5d                   	pop    %ebp
f010305f:	c3                   	ret    

f0103060 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103060:	55                   	push   %ebp
f0103061:	89 e5                	mov    %esp,%ebp
f0103063:	53                   	push   %ebx
f0103064:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103067:	8b 1d d0 c0 17 f0    	mov    0xf017c0d0,%ebx
f010306d:	85 db                	test   %ebx,%ebx
f010306f:	0f 84 91 01 00 00    	je     f0103206 <env_alloc+0x1a6>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103075:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010307c:	e8 2d de ff ff       	call   f0100eae <page_alloc>
f0103081:	85 c0                	test   %eax,%eax
f0103083:	0f 84 84 01 00 00    	je     f010320d <env_alloc+0x1ad>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0103089:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f010308e:	2b 05 b8 c0 17 f0    	sub    0xf017c0b8,%eax
f0103094:	c1 f8 03             	sar    $0x3,%eax
f0103097:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010309a:	89 c2                	mov    %eax,%edx
f010309c:	c1 ea 0c             	shr    $0xc,%edx
f010309f:	3b 15 88 cd 17 f0    	cmp    0xf017cd88,%edx
f01030a5:	72 20                	jb     f01030c7 <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01030a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030ab:	c7 44 24 08 04 52 10 	movl   $0xf0105204,0x8(%esp)
f01030b2:	f0 
f01030b3:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01030ba:	00 
f01030bb:	c7 04 24 84 4e 10 f0 	movl   $0xf0104e84,(%esp)
f01030c2:	e8 ef cf ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f01030c7:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx

	e->env_pgdir = (pte_t *)page2kva(p);
f01030cd:	89 53 5c             	mov    %edx,0x5c(%ebx)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030d0:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01030d6:	77 20                	ja     f01030f8 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01030dc:	c7 44 24 08 ec 52 10 	movl   $0xf01052ec,0x8(%esp)
f01030e3:	f0 
f01030e4:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
f01030eb:	00 
f01030ec:	c7 04 24 6a 5a 10 f0 	movl   $0xf0105a6a,(%esp)
f01030f3:	e8 be cf ff ff       	call   f01000b6 <_panic>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01030f8:	83 c8 05             	or     $0x5,%eax
f01030fb:	89 82 f4 0e 00 00    	mov    %eax,0xef4(%edx)
	cprintf("e->env_pgdir[PDX(UVPT)]: %x,PADDR(e->env_pgdir): %x\n",e->env_pgdir[PDX(UVPT)],PADDR(e->env_pgdir));
f0103101:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103104:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103109:	77 20                	ja     f010312b <env_alloc+0xcb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010310b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010310f:	c7 44 24 08 ec 52 10 	movl   $0xf01052ec,0x8(%esp)
f0103116:	f0 
f0103117:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
f010311e:	00 
f010311f:	c7 04 24 6a 5a 10 f0 	movl   $0xf0105a6a,(%esp)
f0103126:	e8 8b cf ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010312b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103131:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103135:	8b 80 f4 0e 00 00    	mov    0xef4(%eax),%eax
f010313b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010313f:	c7 04 24 fc 59 10 f0 	movl   $0xf01059fc,(%esp)
f0103146:	e8 a3 03 00 00       	call   f01034ee <cprintf>
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010314b:	8b 43 48             	mov    0x48(%ebx),%eax
f010314e:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103153:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103158:	ba 00 10 00 00       	mov    $0x1000,%edx
f010315d:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103160:	89 da                	mov    %ebx,%edx
f0103162:	2b 15 cc c0 17 f0    	sub    0xf017c0cc,%edx
f0103168:	c1 fa 05             	sar    $0x5,%edx
f010316b:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103171:	09 d0                	or     %edx,%eax
f0103173:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103176:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103179:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010317c:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103183:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010318a:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103191:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103198:	00 
f0103199:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01031a0:	00 
f01031a1:	89 1c 24             	mov    %ebx,(%esp)
f01031a4:	e8 4e 13 00 00       	call   f01044f7 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01031a9:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01031af:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01031b5:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01031bb:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01031c2:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f01031c8:	8b 43 44             	mov    0x44(%ebx),%eax
f01031cb:	a3 d0 c0 17 f0       	mov    %eax,0xf017c0d0
	*newenv_store = e;
f01031d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01031d3:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01031d5:	8b 53 48             	mov    0x48(%ebx),%edx
f01031d8:	a1 c8 c0 17 f0       	mov    0xf017c0c8,%eax
f01031dd:	85 c0                	test   %eax,%eax
f01031df:	74 05                	je     f01031e6 <env_alloc+0x186>
f01031e1:	8b 40 48             	mov    0x48(%eax),%eax
f01031e4:	eb 05                	jmp    f01031eb <env_alloc+0x18b>
f01031e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01031eb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01031ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031f3:	c7 04 24 75 5a 10 f0 	movl   $0xf0105a75,(%esp)
f01031fa:	e8 ef 02 00 00       	call   f01034ee <cprintf>
	return 0;
f01031ff:	b8 00 00 00 00       	mov    $0x0,%eax
f0103204:	eb 0c                	jmp    f0103212 <env_alloc+0x1b2>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103206:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010320b:	eb 05                	jmp    f0103212 <env_alloc+0x1b2>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010320d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103212:	83 c4 14             	add    $0x14,%esp
f0103215:	5b                   	pop    %ebx
f0103216:	5d                   	pop    %ebp
f0103217:	c3                   	ret    

f0103218 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103218:	55                   	push   %ebp
f0103219:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f010321b:	5d                   	pop    %ebp
f010321c:	c3                   	ret    

f010321d <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010321d:	55                   	push   %ebp
f010321e:	89 e5                	mov    %esp,%ebp
f0103220:	57                   	push   %edi
f0103221:	56                   	push   %esi
f0103222:	53                   	push   %ebx
f0103223:	83 ec 2c             	sub    $0x2c,%esp
f0103226:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103229:	a1 c8 c0 17 f0       	mov    0xf017c0c8,%eax
f010322e:	39 c7                	cmp    %eax,%edi
f0103230:	75 37                	jne    f0103269 <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f0103232:	8b 15 8c cd 17 f0    	mov    0xf017cd8c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103238:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010323e:	77 20                	ja     f0103260 <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103240:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103244:	c7 44 24 08 ec 52 10 	movl   $0xf01052ec,0x8(%esp)
f010324b:	f0 
f010324c:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f0103253:	00 
f0103254:	c7 04 24 6a 5a 10 f0 	movl   $0xf0105a6a,(%esp)
f010325b:	e8 56 ce ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103260:	81 c2 00 00 00 10    	add    $0x10000000,%edx
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103266:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103269:	8b 57 48             	mov    0x48(%edi),%edx
f010326c:	85 c0                	test   %eax,%eax
f010326e:	74 05                	je     f0103275 <env_free+0x58>
f0103270:	8b 40 48             	mov    0x48(%eax),%eax
f0103273:	eb 05                	jmp    f010327a <env_free+0x5d>
f0103275:	b8 00 00 00 00       	mov    $0x0,%eax
f010327a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010327e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103282:	c7 04 24 8a 5a 10 f0 	movl   $0xf0105a8a,(%esp)
f0103289:	e8 60 02 00 00       	call   f01034ee <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010328e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103295:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103298:	89 c8                	mov    %ecx,%eax
f010329a:	c1 e0 02             	shl    $0x2,%eax
f010329d:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01032a0:	8b 47 5c             	mov    0x5c(%edi),%eax
f01032a3:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f01032a6:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01032ac:	0f 84 b7 00 00 00    	je     f0103369 <env_free+0x14c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01032b2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032b8:	89 f0                	mov    %esi,%eax
f01032ba:	c1 e8 0c             	shr    $0xc,%eax
f01032bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01032c0:	3b 05 88 cd 17 f0    	cmp    0xf017cd88,%eax
f01032c6:	72 20                	jb     f01032e8 <env_free+0xcb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032c8:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01032cc:	c7 44 24 08 04 52 10 	movl   $0xf0105204,0x8(%esp)
f01032d3:	f0 
f01032d4:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
f01032db:	00 
f01032dc:	c7 04 24 6a 5a 10 f0 	movl   $0xf0105a6a,(%esp)
f01032e3:	e8 ce cd ff ff       	call   f01000b6 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01032e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032eb:	c1 e0 16             	shl    $0x16,%eax
f01032ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01032f1:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01032f6:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01032fd:	01 
f01032fe:	74 17                	je     f0103317 <env_free+0xfa>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103300:	89 d8                	mov    %ebx,%eax
f0103302:	c1 e0 0c             	shl    $0xc,%eax
f0103305:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103308:	89 44 24 04          	mov    %eax,0x4(%esp)
f010330c:	8b 47 5c             	mov    0x5c(%edi),%eax
f010330f:	89 04 24             	mov    %eax,(%esp)
f0103312:	e8 53 de ff ff       	call   f010116a <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103317:	83 c3 01             	add    $0x1,%ebx
f010331a:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103320:	75 d4                	jne    f01032f6 <env_free+0xd9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103322:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103325:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103328:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010332f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103332:	3b 05 88 cd 17 f0    	cmp    0xf017cd88,%eax
f0103338:	72 1c                	jb     f0103356 <env_free+0x139>
		panic("pa2page called with invalid pa");
f010333a:	c7 44 24 08 5c 53 10 	movl   $0xf010535c,0x8(%esp)
f0103341:	f0 
f0103342:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103349:	00 
f010334a:	c7 04 24 84 4e 10 f0 	movl   $0xf0104e84,(%esp)
f0103351:	e8 60 cd ff ff       	call   f01000b6 <_panic>
	return &pages[PGNUM(pa)];
f0103356:	a1 b8 c0 17 f0       	mov    0xf017c0b8,%eax
f010335b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010335e:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103361:	89 04 24             	mov    %eax,(%esp)
f0103364:	e8 12 dc ff ff       	call   f0100f7b <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103369:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010336d:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103374:	0f 85 1b ff ff ff    	jne    f0103295 <env_free+0x78>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010337a:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010337d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103382:	77 20                	ja     f01033a4 <env_free+0x187>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103384:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103388:	c7 44 24 08 ec 52 10 	movl   $0xf01052ec,0x8(%esp)
f010338f:	f0 
f0103390:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
f0103397:	00 
f0103398:	c7 04 24 6a 5a 10 f0 	movl   $0xf0105a6a,(%esp)
f010339f:	e8 12 cd ff ff       	call   f01000b6 <_panic>
	e->env_pgdir = 0;
f01033a4:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f01033ab:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033b0:	c1 e8 0c             	shr    $0xc,%eax
f01033b3:	3b 05 88 cd 17 f0    	cmp    0xf017cd88,%eax
f01033b9:	72 1c                	jb     f01033d7 <env_free+0x1ba>
		panic("pa2page called with invalid pa");
f01033bb:	c7 44 24 08 5c 53 10 	movl   $0xf010535c,0x8(%esp)
f01033c2:	f0 
f01033c3:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01033ca:	00 
f01033cb:	c7 04 24 84 4e 10 f0 	movl   $0xf0104e84,(%esp)
f01033d2:	e8 df cc ff ff       	call   f01000b6 <_panic>
	return &pages[PGNUM(pa)];
f01033d7:	8b 15 b8 c0 17 f0    	mov    0xf017c0b8,%edx
f01033dd:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f01033e0:	89 04 24             	mov    %eax,(%esp)
f01033e3:	e8 93 db ff ff       	call   f0100f7b <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01033e8:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01033ef:	a1 d0 c0 17 f0       	mov    0xf017c0d0,%eax
f01033f4:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01033f7:	89 3d d0 c0 17 f0    	mov    %edi,0xf017c0d0
}
f01033fd:	83 c4 2c             	add    $0x2c,%esp
f0103400:	5b                   	pop    %ebx
f0103401:	5e                   	pop    %esi
f0103402:	5f                   	pop    %edi
f0103403:	5d                   	pop    %ebp
f0103404:	c3                   	ret    

f0103405 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103405:	55                   	push   %ebp
f0103406:	89 e5                	mov    %esp,%ebp
f0103408:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f010340b:	8b 45 08             	mov    0x8(%ebp),%eax
f010340e:	89 04 24             	mov    %eax,(%esp)
f0103411:	e8 07 fe ff ff       	call   f010321d <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103416:	c7 04 24 34 5a 10 f0 	movl   $0xf0105a34,(%esp)
f010341d:	e8 cc 00 00 00       	call   f01034ee <cprintf>
	while (1)
		monitor(NULL);
f0103422:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103429:	e8 98 d3 ff ff       	call   f01007c6 <monitor>
f010342e:	eb f2                	jmp    f0103422 <env_destroy+0x1d>

f0103430 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103430:	55                   	push   %ebp
f0103431:	89 e5                	mov    %esp,%ebp
f0103433:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0103436:	8b 65 08             	mov    0x8(%ebp),%esp
f0103439:	61                   	popa   
f010343a:	07                   	pop    %es
f010343b:	1f                   	pop    %ds
f010343c:	83 c4 08             	add    $0x8,%esp
f010343f:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103440:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f0103447:	f0 
f0103448:	c7 44 24 04 b6 01 00 	movl   $0x1b6,0x4(%esp)
f010344f:	00 
f0103450:	c7 04 24 6a 5a 10 f0 	movl   $0xf0105a6a,(%esp)
f0103457:	e8 5a cc ff ff       	call   f01000b6 <_panic>

f010345c <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010345c:	55                   	push   %ebp
f010345d:	89 e5                	mov    %esp,%ebp
f010345f:	83 ec 18             	sub    $0x18,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	panic("env_run not yet implemented");
f0103462:	c7 44 24 08 ac 5a 10 	movl   $0xf0105aac,0x8(%esp)
f0103469:	f0 
f010346a:	c7 44 24 04 d5 01 00 	movl   $0x1d5,0x4(%esp)
f0103471:	00 
f0103472:	c7 04 24 6a 5a 10 f0 	movl   $0xf0105a6a,(%esp)
f0103479:	e8 38 cc ff ff       	call   f01000b6 <_panic>

f010347e <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010347e:	55                   	push   %ebp
f010347f:	89 e5                	mov    %esp,%ebp
f0103481:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103485:	ba 70 00 00 00       	mov    $0x70,%edx
f010348a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010348b:	b2 71                	mov    $0x71,%dl
f010348d:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010348e:	0f b6 c0             	movzbl %al,%eax
}
f0103491:	5d                   	pop    %ebp
f0103492:	c3                   	ret    

f0103493 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103493:	55                   	push   %ebp
f0103494:	89 e5                	mov    %esp,%ebp
f0103496:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010349a:	ba 70 00 00 00       	mov    $0x70,%edx
f010349f:	ee                   	out    %al,(%dx)
f01034a0:	b2 71                	mov    $0x71,%dl
f01034a2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034a5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01034a6:	5d                   	pop    %ebp
f01034a7:	c3                   	ret    

f01034a8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01034a8:	55                   	push   %ebp
f01034a9:	89 e5                	mov    %esp,%ebp
f01034ab:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01034ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01034b1:	89 04 24             	mov    %eax,(%esp)
f01034b4:	e8 58 d1 ff ff       	call   f0100611 <cputchar>
	*cnt++;
}
f01034b9:	c9                   	leave  
f01034ba:	c3                   	ret    

f01034bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01034bb:	55                   	push   %ebp
f01034bc:	89 e5                	mov    %esp,%ebp
f01034be:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01034c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01034c8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01034cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01034d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01034d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01034d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034dd:	c7 04 24 a8 34 10 f0 	movl   $0xf01034a8,(%esp)
f01034e4:	e8 cb 08 00 00       	call   f0103db4 <vprintfmt>
	return cnt;
}
f01034e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01034ec:	c9                   	leave  
f01034ed:	c3                   	ret    

f01034ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01034ee:	55                   	push   %ebp
f01034ef:	89 e5                	mov    %esp,%ebp
f01034f1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01034f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01034f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01034fe:	89 04 24             	mov    %eax,(%esp)
f0103501:	e8 b5 ff ff ff       	call   f01034bb <vcprintf>
	va_end(ap);

	return cnt;
}
f0103506:	c9                   	leave  
f0103507:	c3                   	ret    

f0103508 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103508:	55                   	push   %ebp
f0103509:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f010350b:	c7 05 04 c9 17 f0 00 	movl   $0xf0000000,0xf017c904
f0103512:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103515:	66 c7 05 08 c9 17 f0 	movw   $0x10,0xf017c908
f010351c:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f010351e:	66 c7 05 48 a3 11 f0 	movw   $0x67,0xf011a348
f0103525:	67 00 
f0103527:	b8 00 c9 17 f0       	mov    $0xf017c900,%eax
f010352c:	66 a3 4a a3 11 f0    	mov    %ax,0xf011a34a
f0103532:	89 c2                	mov    %eax,%edx
f0103534:	c1 ea 10             	shr    $0x10,%edx
f0103537:	88 15 4c a3 11 f0    	mov    %dl,0xf011a34c
f010353d:	c6 05 4e a3 11 f0 40 	movb   $0x40,0xf011a34e
f0103544:	c1 e8 18             	shr    $0x18,%eax
f0103547:	a2 4f a3 11 f0       	mov    %al,0xf011a34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f010354c:	c6 05 4d a3 11 f0 89 	movb   $0x89,0xf011a34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103553:	b8 28 00 00 00       	mov    $0x28,%eax
f0103558:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f010355b:	b8 50 a3 11 f0       	mov    $0xf011a350,%eax
f0103560:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103563:	5d                   	pop    %ebp
f0103564:	c3                   	ret    

f0103565 <trap_init>:
}


void
trap_init(void)
{
f0103565:	55                   	push   %ebp
f0103566:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	// Per-CPU setup 
	trap_init_percpu();
f0103568:	e8 9b ff ff ff       	call   f0103508 <trap_init_percpu>
}
f010356d:	5d                   	pop    %ebp
f010356e:	c3                   	ret    

f010356f <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010356f:	55                   	push   %ebp
f0103570:	89 e5                	mov    %esp,%ebp
f0103572:	53                   	push   %ebx
f0103573:	83 ec 14             	sub    $0x14,%esp
f0103576:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103579:	8b 03                	mov    (%ebx),%eax
f010357b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010357f:	c7 04 24 c8 5a 10 f0 	movl   $0xf0105ac8,(%esp)
f0103586:	e8 63 ff ff ff       	call   f01034ee <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010358b:	8b 43 04             	mov    0x4(%ebx),%eax
f010358e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103592:	c7 04 24 d7 5a 10 f0 	movl   $0xf0105ad7,(%esp)
f0103599:	e8 50 ff ff ff       	call   f01034ee <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010359e:	8b 43 08             	mov    0x8(%ebx),%eax
f01035a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035a5:	c7 04 24 e6 5a 10 f0 	movl   $0xf0105ae6,(%esp)
f01035ac:	e8 3d ff ff ff       	call   f01034ee <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01035b1:	8b 43 0c             	mov    0xc(%ebx),%eax
f01035b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035b8:	c7 04 24 f5 5a 10 f0 	movl   $0xf0105af5,(%esp)
f01035bf:	e8 2a ff ff ff       	call   f01034ee <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01035c4:	8b 43 10             	mov    0x10(%ebx),%eax
f01035c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035cb:	c7 04 24 04 5b 10 f0 	movl   $0xf0105b04,(%esp)
f01035d2:	e8 17 ff ff ff       	call   f01034ee <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01035d7:	8b 43 14             	mov    0x14(%ebx),%eax
f01035da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035de:	c7 04 24 13 5b 10 f0 	movl   $0xf0105b13,(%esp)
f01035e5:	e8 04 ff ff ff       	call   f01034ee <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01035ea:	8b 43 18             	mov    0x18(%ebx),%eax
f01035ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035f1:	c7 04 24 22 5b 10 f0 	movl   $0xf0105b22,(%esp)
f01035f8:	e8 f1 fe ff ff       	call   f01034ee <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01035fd:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103600:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103604:	c7 04 24 31 5b 10 f0 	movl   $0xf0105b31,(%esp)
f010360b:	e8 de fe ff ff       	call   f01034ee <cprintf>
}
f0103610:	83 c4 14             	add    $0x14,%esp
f0103613:	5b                   	pop    %ebx
f0103614:	5d                   	pop    %ebp
f0103615:	c3                   	ret    

f0103616 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103616:	55                   	push   %ebp
f0103617:	89 e5                	mov    %esp,%ebp
f0103619:	56                   	push   %esi
f010361a:	53                   	push   %ebx
f010361b:	83 ec 10             	sub    $0x10,%esp
f010361e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103621:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103625:	c7 04 24 67 5c 10 f0 	movl   $0xf0105c67,(%esp)
f010362c:	e8 bd fe ff ff       	call   f01034ee <cprintf>
	print_regs(&tf->tf_regs);
f0103631:	89 1c 24             	mov    %ebx,(%esp)
f0103634:	e8 36 ff ff ff       	call   f010356f <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103639:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010363d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103641:	c7 04 24 82 5b 10 f0 	movl   $0xf0105b82,(%esp)
f0103648:	e8 a1 fe ff ff       	call   f01034ee <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010364d:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103651:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103655:	c7 04 24 95 5b 10 f0 	movl   $0xf0105b95,(%esp)
f010365c:	e8 8d fe ff ff       	call   f01034ee <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103661:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103664:	83 f8 13             	cmp    $0x13,%eax
f0103667:	77 09                	ja     f0103672 <print_trapframe+0x5c>
		return excnames[trapno];
f0103669:	8b 14 85 40 5e 10 f0 	mov    -0xfefa1c0(,%eax,4),%edx
f0103670:	eb 10                	jmp    f0103682 <print_trapframe+0x6c>
	if (trapno == T_SYSCALL)
		return "System call";
f0103672:	83 f8 30             	cmp    $0x30,%eax
f0103675:	ba 40 5b 10 f0       	mov    $0xf0105b40,%edx
f010367a:	b9 4c 5b 10 f0       	mov    $0xf0105b4c,%ecx
f010367f:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103682:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103686:	89 44 24 04          	mov    %eax,0x4(%esp)
f010368a:	c7 04 24 a8 5b 10 f0 	movl   $0xf0105ba8,(%esp)
f0103691:	e8 58 fe ff ff       	call   f01034ee <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103696:	3b 1d e0 c8 17 f0    	cmp    0xf017c8e0,%ebx
f010369c:	75 19                	jne    f01036b7 <print_trapframe+0xa1>
f010369e:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01036a2:	75 13                	jne    f01036b7 <print_trapframe+0xa1>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01036a4:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01036a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036ab:	c7 04 24 ba 5b 10 f0 	movl   $0xf0105bba,(%esp)
f01036b2:	e8 37 fe ff ff       	call   f01034ee <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f01036b7:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01036ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036be:	c7 04 24 c9 5b 10 f0 	movl   $0xf0105bc9,(%esp)
f01036c5:	e8 24 fe ff ff       	call   f01034ee <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01036ca:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01036ce:	75 51                	jne    f0103721 <print_trapframe+0x10b>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01036d0:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01036d3:	89 c2                	mov    %eax,%edx
f01036d5:	83 e2 01             	and    $0x1,%edx
f01036d8:	ba 5b 5b 10 f0       	mov    $0xf0105b5b,%edx
f01036dd:	b9 66 5b 10 f0       	mov    $0xf0105b66,%ecx
f01036e2:	0f 45 ca             	cmovne %edx,%ecx
f01036e5:	89 c2                	mov    %eax,%edx
f01036e7:	83 e2 02             	and    $0x2,%edx
f01036ea:	ba 72 5b 10 f0       	mov    $0xf0105b72,%edx
f01036ef:	be 78 5b 10 f0       	mov    $0xf0105b78,%esi
f01036f4:	0f 44 d6             	cmove  %esi,%edx
f01036f7:	83 e0 04             	and    $0x4,%eax
f01036fa:	b8 7d 5b 10 f0       	mov    $0xf0105b7d,%eax
f01036ff:	be 92 5c 10 f0       	mov    $0xf0105c92,%esi
f0103704:	0f 44 c6             	cmove  %esi,%eax
f0103707:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010370b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010370f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103713:	c7 04 24 d7 5b 10 f0 	movl   $0xf0105bd7,(%esp)
f010371a:	e8 cf fd ff ff       	call   f01034ee <cprintf>
f010371f:	eb 0c                	jmp    f010372d <print_trapframe+0x117>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103721:	c7 04 24 9e 4c 10 f0 	movl   $0xf0104c9e,(%esp)
f0103728:	e8 c1 fd ff ff       	call   f01034ee <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010372d:	8b 43 30             	mov    0x30(%ebx),%eax
f0103730:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103734:	c7 04 24 e6 5b 10 f0 	movl   $0xf0105be6,(%esp)
f010373b:	e8 ae fd ff ff       	call   f01034ee <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103740:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103744:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103748:	c7 04 24 f5 5b 10 f0 	movl   $0xf0105bf5,(%esp)
f010374f:	e8 9a fd ff ff       	call   f01034ee <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103754:	8b 43 38             	mov    0x38(%ebx),%eax
f0103757:	89 44 24 04          	mov    %eax,0x4(%esp)
f010375b:	c7 04 24 08 5c 10 f0 	movl   $0xf0105c08,(%esp)
f0103762:	e8 87 fd ff ff       	call   f01034ee <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103767:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010376b:	74 27                	je     f0103794 <print_trapframe+0x17e>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010376d:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103770:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103774:	c7 04 24 17 5c 10 f0 	movl   $0xf0105c17,(%esp)
f010377b:	e8 6e fd ff ff       	call   f01034ee <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103780:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103784:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103788:	c7 04 24 26 5c 10 f0 	movl   $0xf0105c26,(%esp)
f010378f:	e8 5a fd ff ff       	call   f01034ee <cprintf>
	}
}
f0103794:	83 c4 10             	add    $0x10,%esp
f0103797:	5b                   	pop    %ebx
f0103798:	5e                   	pop    %esi
f0103799:	5d                   	pop    %ebp
f010379a:	c3                   	ret    

f010379b <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010379b:	55                   	push   %ebp
f010379c:	89 e5                	mov    %esp,%ebp
f010379e:	57                   	push   %edi
f010379f:	56                   	push   %esi
f01037a0:	83 ec 10             	sub    $0x10,%esp
f01037a3:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01037a6:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01037a7:	9c                   	pushf  
f01037a8:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01037a9:	f6 c4 02             	test   $0x2,%ah
f01037ac:	74 24                	je     f01037d2 <trap+0x37>
f01037ae:	c7 44 24 0c 39 5c 10 	movl   $0xf0105c39,0xc(%esp)
f01037b5:	f0 
f01037b6:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f01037bd:	f0 
f01037be:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
f01037c5:	00 
f01037c6:	c7 04 24 52 5c 10 f0 	movl   $0xf0105c52,(%esp)
f01037cd:	e8 e4 c8 ff ff       	call   f01000b6 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01037d2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01037d6:	c7 04 24 5e 5c 10 f0 	movl   $0xf0105c5e,(%esp)
f01037dd:	e8 0c fd ff ff       	call   f01034ee <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01037e2:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01037e6:	83 e0 03             	and    $0x3,%eax
f01037e9:	66 83 f8 03          	cmp    $0x3,%ax
f01037ed:	75 3c                	jne    f010382b <trap+0x90>
		// Trapped from user mode.
		assert(curenv);
f01037ef:	a1 c8 c0 17 f0       	mov    0xf017c0c8,%eax
f01037f4:	85 c0                	test   %eax,%eax
f01037f6:	75 24                	jne    f010381c <trap+0x81>
f01037f8:	c7 44 24 0c 79 5c 10 	movl   $0xf0105c79,0xc(%esp)
f01037ff:	f0 
f0103800:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0103807:	f0 
f0103808:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
f010380f:	00 
f0103810:	c7 04 24 52 5c 10 f0 	movl   $0xf0105c52,(%esp)
f0103817:	e8 9a c8 ff ff       	call   f01000b6 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010381c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103821:	89 c7                	mov    %eax,%edi
f0103823:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103825:	8b 35 c8 c0 17 f0    	mov    0xf017c0c8,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010382b:	89 35 e0 c8 17 f0    	mov    %esi,0xf017c8e0
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103831:	89 34 24             	mov    %esi,(%esp)
f0103834:	e8 dd fd ff ff       	call   f0103616 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103839:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010383e:	75 1c                	jne    f010385c <trap+0xc1>
		panic("unhandled trap in kernel");
f0103840:	c7 44 24 08 80 5c 10 	movl   $0xf0105c80,0x8(%esp)
f0103847:	f0 
f0103848:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
f010384f:	00 
f0103850:	c7 04 24 52 5c 10 f0 	movl   $0xf0105c52,(%esp)
f0103857:	e8 5a c8 ff ff       	call   f01000b6 <_panic>
	else {
		env_destroy(curenv);
f010385c:	a1 c8 c0 17 f0       	mov    0xf017c0c8,%eax
f0103861:	89 04 24             	mov    %eax,(%esp)
f0103864:	e8 9c fb ff ff       	call   f0103405 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103869:	a1 c8 c0 17 f0       	mov    0xf017c0c8,%eax
f010386e:	85 c0                	test   %eax,%eax
f0103870:	74 06                	je     f0103878 <trap+0xdd>
f0103872:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103876:	74 24                	je     f010389c <trap+0x101>
f0103878:	c7 44 24 0c dc 5d 10 	movl   $0xf0105ddc,0xc(%esp)
f010387f:	f0 
f0103880:	c7 44 24 08 aa 4e 10 	movl   $0xf0104eaa,0x8(%esp)
f0103887:	f0 
f0103888:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
f010388f:	00 
f0103890:	c7 04 24 52 5c 10 f0 	movl   $0xf0105c52,(%esp)
f0103897:	e8 1a c8 ff ff       	call   f01000b6 <_panic>
	env_run(curenv);
f010389c:	89 04 24             	mov    %eax,(%esp)
f010389f:	e8 b8 fb ff ff       	call   f010345c <env_run>

f01038a4 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01038a4:	55                   	push   %ebp
f01038a5:	89 e5                	mov    %esp,%ebp
f01038a7:	53                   	push   %ebx
f01038a8:	83 ec 14             	sub    $0x14,%esp
f01038ab:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01038ae:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01038b1:	8b 53 30             	mov    0x30(%ebx),%edx
f01038b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01038b8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01038bc:	a1 c8 c0 17 f0       	mov    0xf017c0c8,%eax
f01038c1:	8b 40 48             	mov    0x48(%eax),%eax
f01038c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038c8:	c7 04 24 08 5e 10 f0 	movl   $0xf0105e08,(%esp)
f01038cf:	e8 1a fc ff ff       	call   f01034ee <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01038d4:	89 1c 24             	mov    %ebx,(%esp)
f01038d7:	e8 3a fd ff ff       	call   f0103616 <print_trapframe>
	env_destroy(curenv);
f01038dc:	a1 c8 c0 17 f0       	mov    0xf017c0c8,%eax
f01038e1:	89 04 24             	mov    %eax,(%esp)
f01038e4:	e8 1c fb ff ff       	call   f0103405 <env_destroy>
}
f01038e9:	83 c4 14             	add    $0x14,%esp
f01038ec:	5b                   	pop    %ebx
f01038ed:	5d                   	pop    %ebp
f01038ee:	c3                   	ret    

f01038ef <syscall>:
f01038ef:	55                   	push   %ebp
f01038f0:	89 e5                	mov    %esp,%ebp
f01038f2:	83 ec 18             	sub    $0x18,%esp
f01038f5:	c7 44 24 08 90 5e 10 	movl   $0xf0105e90,0x8(%esp)
f01038fc:	f0 
f01038fd:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
f0103904:	00 
f0103905:	c7 04 24 a8 5e 10 f0 	movl   $0xf0105ea8,(%esp)
f010390c:	e8 a5 c7 ff ff       	call   f01000b6 <_panic>

f0103911 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void 
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103911:	55                   	push   %ebp
f0103912:	89 e5                	mov    %esp,%ebp
f0103914:	57                   	push   %edi
f0103915:	56                   	push   %esi
f0103916:	53                   	push   %ebx
f0103917:	83 ec 14             	sub    $0x14,%esp
f010391a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010391d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103920:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103923:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103926:	8b 1a                	mov    (%edx),%ebx
f0103928:	8b 01                	mov    (%ecx),%eax
f010392a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010392d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103934:	e9 88 00 00 00       	jmp    f01039c1 <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0103939:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010393c:	01 d8                	add    %ebx,%eax
f010393e:	89 c7                	mov    %eax,%edi
f0103940:	c1 ef 1f             	shr    $0x1f,%edi
f0103943:	01 c7                	add    %eax,%edi
f0103945:	d1 ff                	sar    %edi
f0103947:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010394a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010394d:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0103950:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103952:	eb 03                	jmp    f0103957 <stab_binsearch+0x46>
			m--;
f0103954:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103957:	39 c3                	cmp    %eax,%ebx
f0103959:	7f 1f                	jg     f010397a <stab_binsearch+0x69>
f010395b:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010395f:	83 ea 0c             	sub    $0xc,%edx
f0103962:	39 f1                	cmp    %esi,%ecx
f0103964:	75 ee                	jne    f0103954 <stab_binsearch+0x43>
f0103966:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103969:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010396c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010396f:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103973:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103976:	76 18                	jbe    f0103990 <stab_binsearch+0x7f>
f0103978:	eb 05                	jmp    f010397f <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010397a:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010397d:	eb 42                	jmp    f01039c1 <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010397f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103982:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103984:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103987:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010398e:	eb 31                	jmp    f01039c1 <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103990:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103993:	73 17                	jae    f01039ac <stab_binsearch+0x9b>
			*region_right = m - 1;
f0103995:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103998:	83 e8 01             	sub    $0x1,%eax
f010399b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010399e:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01039a1:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01039a3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01039aa:	eb 15                	jmp    f01039c1 <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01039ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01039af:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01039b2:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f01039b4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01039b8:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01039ba:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01039c1:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01039c4:	0f 8e 6f ff ff ff    	jle    f0103939 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01039ca:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01039ce:	75 0f                	jne    f01039df <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f01039d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01039d3:	8b 00                	mov    (%eax),%eax
f01039d5:	83 e8 01             	sub    $0x1,%eax
f01039d8:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01039db:	89 07                	mov    %eax,(%edi)
f01039dd:	eb 2c                	jmp    f0103a0b <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01039df:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01039e2:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01039e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01039e7:	8b 0f                	mov    (%edi),%ecx
f01039e9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01039ec:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01039ef:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01039f2:	eb 03                	jmp    f01039f7 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01039f4:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01039f7:	39 c8                	cmp    %ecx,%eax
f01039f9:	7e 0b                	jle    f0103a06 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f01039fb:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01039ff:	83 ea 0c             	sub    $0xc,%edx
f0103a02:	39 f3                	cmp    %esi,%ebx
f0103a04:	75 ee                	jne    f01039f4 <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103a06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103a09:	89 07                	mov    %eax,(%edi)
	}
}
f0103a0b:	83 c4 14             	add    $0x14,%esp
f0103a0e:	5b                   	pop    %ebx
f0103a0f:	5e                   	pop    %esi
f0103a10:	5f                   	pop    %edi
f0103a11:	5d                   	pop    %ebp
f0103a12:	c3                   	ret    

f0103a13 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103a13:	55                   	push   %ebp
f0103a14:	89 e5                	mov    %esp,%ebp
f0103a16:	57                   	push   %edi
f0103a17:	56                   	push   %esi
f0103a18:	53                   	push   %ebx
f0103a19:	83 ec 4c             	sub    $0x4c,%esp
f0103a1c:	8b 75 08             	mov    0x8(%ebp),%esi
f0103a1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103a22:	c7 03 b7 5e 10 f0    	movl   $0xf0105eb7,(%ebx)
	info->eip_line = 0;
f0103a28:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103a2f:	c7 43 08 b7 5e 10 f0 	movl   $0xf0105eb7,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103a36:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103a3d:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103a40:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103a47:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103a4d:	77 21                	ja     f0103a70 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103a4f:	a1 00 00 20 00       	mov    0x200000,%eax
f0103a54:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0103a57:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103a5c:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0103a62:	89 7d c0             	mov    %edi,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0103a65:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0103a6b:	89 7d bc             	mov    %edi,-0x44(%ebp)
f0103a6e:	eb 1a                	jmp    f0103a8a <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103a70:	c7 45 bc 9f fe 10 f0 	movl   $0xf010fe9f,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103a77:	c7 45 c0 69 d5 10 f0 	movl   $0xf010d569,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103a7e:	b8 68 d5 10 f0       	mov    $0xf010d568,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103a83:	c7 45 c4 10 61 10 f0 	movl   $0xf0106110,-0x3c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103a8a:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103a8d:	39 7d c0             	cmp    %edi,-0x40(%ebp)
f0103a90:	0f 83 c2 01 00 00    	jae    f0103c58 <debuginfo_eip+0x245>
f0103a96:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0103a9a:	0f 85 bf 01 00 00    	jne    f0103c5f <debuginfo_eip+0x24c>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103aa0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103aa7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103aaa:	29 f8                	sub    %edi,%eax
f0103aac:	c1 f8 02             	sar    $0x2,%eax
f0103aaf:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103ab5:	83 e8 01             	sub    $0x1,%eax
f0103ab8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103abb:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103abf:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0103ac6:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103ac9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103acc:	89 f8                	mov    %edi,%eax
f0103ace:	e8 3e fe ff ff       	call   f0103911 <stab_binsearch>
	if (lfile == 0)
f0103ad3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103ad6:	85 c0                	test   %eax,%eax
f0103ad8:	0f 84 88 01 00 00    	je     f0103c66 <debuginfo_eip+0x253>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103ade:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103ae1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ae4:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103ae7:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103aeb:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0103af2:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103af5:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103af8:	89 f8                	mov    %edi,%eax
f0103afa:	e8 12 fe ff ff       	call   f0103911 <stab_binsearch>

	if (lfun <= rfun) {
f0103aff:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103b02:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0103b05:	7f 62                	jg     f0103b69 <debuginfo_eip+0x156>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		// .stab contains an array of fixed length structures, one struct per stab
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103b07:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103b0a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103b0d:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0103b10:	8b 10                	mov    (%eax),%edx
f0103b12:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0103b15:	2b 4d c0             	sub    -0x40(%ebp),%ecx
f0103b18:	39 ca                	cmp    %ecx,%edx
f0103b1a:	73 06                	jae    f0103b22 <debuginfo_eip+0x10f>
		{
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103b1c:	03 55 c0             	add    -0x40(%ebp),%edx
f0103b1f:	89 53 08             	mov    %edx,0x8(%ebx)
			//cprintf("info->eip_fn_name%s,stabstr%s,stabs[lfun].n_strx%d\n",info->eip_fn_name,*stabstr,stabs[lfun].n_strx);
		}		
		info->eip_fn_addr = stabs[lfun].n_value;//info->eip_fn_addr have the addres of the function. 
f0103b22:	8b 40 08             	mov    0x8(%eax),%eax
f0103b25:	89 43 10             	mov    %eax,0x10(%ebx)
		cprintf("info->eip_fn_addr%x\n",info->eip_fn_addr);
f0103b28:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b2c:	c7 04 24 c1 5e 10 f0 	movl   $0xf0105ec1,(%esp)
f0103b33:	e8 b6 f9 ff ff       	call   f01034ee <cprintf>
		cprintf("addr_1%x\n",addr);//addr have the eip value.
f0103b38:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103b3c:	c7 04 24 d6 5e 10 f0 	movl   $0xf0105ed6,(%esp)
f0103b43:	e8 a6 f9 ff ff       	call   f01034ee <cprintf>
		addr -= info->eip_fn_addr;
f0103b48:	2b 73 10             	sub    0x10(%ebx),%esi
		cprintf("addr_2%x\n",addr);
f0103b4b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103b4f:	c7 04 24 e0 5e 10 f0 	movl   $0xf0105ee0,(%esp)
f0103b56:	e8 93 f9 ff ff       	call   f01034ee <cprintf>
		// Search within the function definition for the line number.
		lline = lfun;
f0103b5b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103b5e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103b61:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b64:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103b67:	eb 0f                	jmp    f0103b78 <debuginfo_eip+0x165>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103b69:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103b6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b6f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103b72:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b75:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103b78:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0103b7f:	00 
f0103b80:	8b 43 08             	mov    0x8(%ebx),%eax
f0103b83:	89 04 24             	mov    %eax,(%esp)
f0103b86:	e8 50 09 00 00       	call   f01044db <strfind>
f0103b8b:	2b 43 08             	sub    0x8(%ebx),%eax
f0103b8e:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103b91:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103b95:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0103b9c:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103b9f:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103ba2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103ba5:	89 f8                	mov    %edi,%eax
f0103ba7:	e8 65 fd ff ff       	call   f0103911 <stab_binsearch>
	info->eip_line = stabs[lline].n_value;
f0103bac:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103baf:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f0103bb2:	8d 04 11             	lea    (%ecx,%edx,1),%eax
f0103bb5:	8b 44 87 08          	mov    0x8(%edi,%eax,4),%eax
f0103bb9:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103bbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103bbf:	89 c6                	mov    %eax,%esi
f0103bc1:	89 d0                	mov    %edx,%eax
f0103bc3:	01 ca                	add    %ecx,%edx
f0103bc5:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103bc8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103bcb:	eb 06                	jmp    f0103bd3 <debuginfo_eip+0x1c0>
f0103bcd:	83 e8 01             	sub    $0x1,%eax
f0103bd0:	83 ea 0c             	sub    $0xc,%edx
f0103bd3:	89 c7                	mov    %eax,%edi
f0103bd5:	39 c6                	cmp    %eax,%esi
f0103bd7:	7f 3c                	jg     f0103c15 <debuginfo_eip+0x202>
	       && stabs[lline].n_type != N_SOL
f0103bd9:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103bdd:	80 f9 84             	cmp    $0x84,%cl
f0103be0:	75 08                	jne    f0103bea <debuginfo_eip+0x1d7>
f0103be2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103be5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103be8:	eb 11                	jmp    f0103bfb <debuginfo_eip+0x1e8>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103bea:	80 f9 64             	cmp    $0x64,%cl
f0103bed:	75 de                	jne    f0103bcd <debuginfo_eip+0x1ba>
f0103bef:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0103bf3:	74 d8                	je     f0103bcd <debuginfo_eip+0x1ba>
f0103bf5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103bf8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103bfb:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103bfe:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0103c01:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0103c04:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0103c07:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0103c0a:	39 d0                	cmp    %edx,%eax
f0103c0c:	73 0a                	jae    f0103c18 <debuginfo_eip+0x205>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103c0e:	03 45 c0             	add    -0x40(%ebp),%eax
f0103c11:	89 03                	mov    %eax,(%ebx)
f0103c13:	eb 03                	jmp    f0103c18 <debuginfo_eip+0x205>
f0103c15:	8b 5d 0c             	mov    0xc(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103c18:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103c1b:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103c1e:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103c23:	39 f2                	cmp    %esi,%edx
f0103c25:	7d 4b                	jge    f0103c72 <debuginfo_eip+0x25f>
		for (lline = lfun + 1;
f0103c27:	83 c2 01             	add    $0x1,%edx
f0103c2a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103c2d:	89 d0                	mov    %edx,%eax
f0103c2f:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103c32:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103c35:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103c38:	eb 04                	jmp    f0103c3e <debuginfo_eip+0x22b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103c3a:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103c3e:	39 c6                	cmp    %eax,%esi
f0103c40:	7e 2b                	jle    f0103c6d <debuginfo_eip+0x25a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103c42:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103c46:	83 c0 01             	add    $0x1,%eax
f0103c49:	83 c2 0c             	add    $0xc,%edx
f0103c4c:	80 f9 a0             	cmp    $0xa0,%cl
f0103c4f:	74 e9                	je     f0103c3a <debuginfo_eip+0x227>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103c51:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c56:	eb 1a                	jmp    f0103c72 <debuginfo_eip+0x25f>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103c58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c5d:	eb 13                	jmp    f0103c72 <debuginfo_eip+0x25f>
f0103c5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c64:	eb 0c                	jmp    f0103c72 <debuginfo_eip+0x25f>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103c66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c6b:	eb 05                	jmp    f0103c72 <debuginfo_eip+0x25f>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103c6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103c72:	83 c4 4c             	add    $0x4c,%esp
f0103c75:	5b                   	pop    %ebx
f0103c76:	5e                   	pop    %esi
f0103c77:	5f                   	pop    %edi
f0103c78:	5d                   	pop    %ebp
f0103c79:	c3                   	ret    
f0103c7a:	66 90                	xchg   %ax,%ax
f0103c7c:	66 90                	xchg   %ax,%ax
f0103c7e:	66 90                	xchg   %ax,%ax

f0103c80 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103c80:	55                   	push   %ebp
f0103c81:	89 e5                	mov    %esp,%ebp
f0103c83:	57                   	push   %edi
f0103c84:	56                   	push   %esi
f0103c85:	53                   	push   %ebx
f0103c86:	83 ec 3c             	sub    $0x3c,%esp
f0103c89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103c8c:	89 d7                	mov    %edx,%edi
f0103c8e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c91:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103c94:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c97:	89 c3                	mov    %eax,%ebx
f0103c99:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103c9c:	8b 45 10             	mov    0x10(%ebp),%eax
f0103c9f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103ca2:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103ca7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103caa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103cad:	39 d9                	cmp    %ebx,%ecx
f0103caf:	72 05                	jb     f0103cb6 <printnum+0x36>
f0103cb1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0103cb4:	77 69                	ja     f0103d1f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103cb6:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0103cb9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0103cbd:	83 ee 01             	sub    $0x1,%esi
f0103cc0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103cc4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103cc8:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103ccc:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0103cd0:	89 c3                	mov    %eax,%ebx
f0103cd2:	89 d6                	mov    %edx,%esi
f0103cd4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103cd7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103cda:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103cde:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103ce2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ce5:	89 04 24             	mov    %eax,(%esp)
f0103ce8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103ceb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cef:	e8 0c 0a 00 00       	call   f0104700 <__udivdi3>
f0103cf4:	89 d9                	mov    %ebx,%ecx
f0103cf6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103cfa:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103cfe:	89 04 24             	mov    %eax,(%esp)
f0103d01:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103d05:	89 fa                	mov    %edi,%edx
f0103d07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103d0a:	e8 71 ff ff ff       	call   f0103c80 <printnum>
f0103d0f:	eb 1b                	jmp    f0103d2c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103d11:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103d15:	8b 45 18             	mov    0x18(%ebp),%eax
f0103d18:	89 04 24             	mov    %eax,(%esp)
f0103d1b:	ff d3                	call   *%ebx
f0103d1d:	eb 03                	jmp    f0103d22 <printnum+0xa2>
f0103d1f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103d22:	83 ee 01             	sub    $0x1,%esi
f0103d25:	85 f6                	test   %esi,%esi
f0103d27:	7f e8                	jg     f0103d11 <printnum+0x91>
f0103d29:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103d2c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103d30:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103d34:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103d37:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103d3a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d3e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103d42:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103d45:	89 04 24             	mov    %eax,(%esp)
f0103d48:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d4f:	e8 dc 0a 00 00       	call   f0104830 <__umoddi3>
f0103d54:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103d58:	0f be 80 ea 5e 10 f0 	movsbl -0xfefa116(%eax),%eax
f0103d5f:	89 04 24             	mov    %eax,(%esp)
f0103d62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103d65:	ff d0                	call   *%eax
}
f0103d67:	83 c4 3c             	add    $0x3c,%esp
f0103d6a:	5b                   	pop    %ebx
f0103d6b:	5e                   	pop    %esi
f0103d6c:	5f                   	pop    %edi
f0103d6d:	5d                   	pop    %ebp
f0103d6e:	c3                   	ret    

f0103d6f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103d6f:	55                   	push   %ebp
f0103d70:	89 e5                	mov    %esp,%ebp
f0103d72:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103d75:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103d79:	8b 10                	mov    (%eax),%edx
f0103d7b:	3b 50 04             	cmp    0x4(%eax),%edx
f0103d7e:	73 0a                	jae    f0103d8a <sprintputch+0x1b>
		*b->buf++ = ch;
f0103d80:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103d83:	89 08                	mov    %ecx,(%eax)
f0103d85:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d88:	88 02                	mov    %al,(%edx)
}
f0103d8a:	5d                   	pop    %ebp
f0103d8b:	c3                   	ret    

f0103d8c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103d8c:	55                   	push   %ebp
f0103d8d:	89 e5                	mov    %esp,%ebp
f0103d8f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0103d92:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103d95:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d99:	8b 45 10             	mov    0x10(%ebp),%eax
f0103d9c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103da0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103da3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103da7:	8b 45 08             	mov    0x8(%ebp),%eax
f0103daa:	89 04 24             	mov    %eax,(%esp)
f0103dad:	e8 02 00 00 00       	call   f0103db4 <vprintfmt>
	va_end(ap);
}
f0103db2:	c9                   	leave  
f0103db3:	c3                   	ret    

f0103db4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103db4:	55                   	push   %ebp
f0103db5:	89 e5                	mov    %esp,%ebp
f0103db7:	57                   	push   %edi
f0103db8:	56                   	push   %esi
f0103db9:	53                   	push   %ebx
f0103dba:	83 ec 3c             	sub    $0x3c,%esp
f0103dbd:	8b 75 08             	mov    0x8(%ebp),%esi
f0103dc0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103dc3:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103dc6:	eb 11                	jmp    f0103dd9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103dc8:	85 c0                	test   %eax,%eax
f0103dca:	0f 84 48 04 00 00    	je     f0104218 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
f0103dd0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103dd4:	89 04 24             	mov    %eax,(%esp)
f0103dd7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103dd9:	83 c7 01             	add    $0x1,%edi
f0103ddc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103de0:	83 f8 25             	cmp    $0x25,%eax
f0103de3:	75 e3                	jne    f0103dc8 <vprintfmt+0x14>
f0103de5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0103de9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103df0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103df7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0103dfe:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103e03:	eb 1f                	jmp    f0103e24 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e05:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103e08:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0103e0c:	eb 16                	jmp    f0103e24 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103e11:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103e15:	eb 0d                	jmp    f0103e24 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103e17:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103e1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103e1d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e24:	8d 47 01             	lea    0x1(%edi),%eax
f0103e27:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103e2a:	0f b6 17             	movzbl (%edi),%edx
f0103e2d:	0f b6 c2             	movzbl %dl,%eax
f0103e30:	83 ea 23             	sub    $0x23,%edx
f0103e33:	80 fa 55             	cmp    $0x55,%dl
f0103e36:	0f 87 bf 03 00 00    	ja     f01041fb <vprintfmt+0x447>
f0103e3c:	0f b6 d2             	movzbl %dl,%edx
f0103e3f:	ff 24 95 80 5f 10 f0 	jmp    *-0xfefa080(,%edx,4)
f0103e46:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e49:	ba 00 00 00 00       	mov    $0x0,%edx
f0103e4e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103e51:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0103e54:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0103e58:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f0103e5b:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0103e5e:	83 f9 09             	cmp    $0x9,%ecx
f0103e61:	77 3c                	ja     f0103e9f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103e63:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103e66:	eb e9                	jmp    f0103e51 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103e68:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e6b:	8b 00                	mov    (%eax),%eax
f0103e6d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103e70:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e73:	8d 40 04             	lea    0x4(%eax),%eax
f0103e76:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e79:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103e7c:	eb 27                	jmp    f0103ea5 <vprintfmt+0xf1>
f0103e7e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103e81:	85 d2                	test   %edx,%edx
f0103e83:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e88:	0f 49 c2             	cmovns %edx,%eax
f0103e8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e8e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e91:	eb 91                	jmp    f0103e24 <vprintfmt+0x70>
f0103e93:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103e96:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103e9d:	eb 85                	jmp    f0103e24 <vprintfmt+0x70>
f0103e9f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103ea2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0103ea5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103ea9:	0f 89 75 ff ff ff    	jns    f0103e24 <vprintfmt+0x70>
f0103eaf:	e9 63 ff ff ff       	jmp    f0103e17 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103eb4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103eb7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103eba:	e9 65 ff ff ff       	jmp    f0103e24 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ebf:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103ec2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103ec6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103eca:	8b 00                	mov    (%eax),%eax
f0103ecc:	89 04 24             	mov    %eax,(%esp)
f0103ecf:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ed1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103ed4:	e9 00 ff ff ff       	jmp    f0103dd9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ed9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103edc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103ee0:	8b 00                	mov    (%eax),%eax
f0103ee2:	99                   	cltd   
f0103ee3:	31 d0                	xor    %edx,%eax
f0103ee5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103ee7:	83 f8 07             	cmp    $0x7,%eax
f0103eea:	7f 0b                	jg     f0103ef7 <vprintfmt+0x143>
f0103eec:	8b 14 85 e0 60 10 f0 	mov    -0xfef9f20(,%eax,4),%edx
f0103ef3:	85 d2                	test   %edx,%edx
f0103ef5:	75 20                	jne    f0103f17 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
f0103ef7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103efb:	c7 44 24 08 02 5f 10 	movl   $0xf0105f02,0x8(%esp)
f0103f02:	f0 
f0103f03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f07:	89 34 24             	mov    %esi,(%esp)
f0103f0a:	e8 7d fe ff ff       	call   f0103d8c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f0f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103f12:	e9 c2 fe ff ff       	jmp    f0103dd9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0103f17:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103f1b:	c7 44 24 08 bc 4e 10 	movl   $0xf0104ebc,0x8(%esp)
f0103f22:	f0 
f0103f23:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f27:	89 34 24             	mov    %esi,(%esp)
f0103f2a:	e8 5d fe ff ff       	call   f0103d8c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f2f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103f32:	e9 a2 fe ff ff       	jmp    f0103dd9 <vprintfmt+0x25>
f0103f37:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f3a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103f3d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103f40:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103f43:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103f47:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103f49:	85 ff                	test   %edi,%edi
f0103f4b:	b8 fb 5e 10 f0       	mov    $0xf0105efb,%eax
f0103f50:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103f53:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103f57:	0f 84 92 00 00 00    	je     f0103fef <vprintfmt+0x23b>
f0103f5d:	85 c9                	test   %ecx,%ecx
f0103f5f:	0f 8e 98 00 00 00    	jle    f0103ffd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103f65:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103f69:	89 3c 24             	mov    %edi,(%esp)
f0103f6c:	e8 17 04 00 00       	call   f0104388 <strnlen>
f0103f71:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103f74:	29 c1                	sub    %eax,%ecx
f0103f76:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
f0103f79:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103f7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103f80:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103f83:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103f85:	eb 0f                	jmp    f0103f96 <vprintfmt+0x1e2>
					putch(padc, putdat);
f0103f87:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f8e:	89 04 24             	mov    %eax,(%esp)
f0103f91:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103f93:	83 ef 01             	sub    $0x1,%edi
f0103f96:	85 ff                	test   %edi,%edi
f0103f98:	7f ed                	jg     f0103f87 <vprintfmt+0x1d3>
f0103f9a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103f9d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103fa0:	85 c9                	test   %ecx,%ecx
f0103fa2:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fa7:	0f 49 c1             	cmovns %ecx,%eax
f0103faa:	29 c1                	sub    %eax,%ecx
f0103fac:	89 75 08             	mov    %esi,0x8(%ebp)
f0103faf:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103fb2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103fb5:	89 cb                	mov    %ecx,%ebx
f0103fb7:	eb 50                	jmp    f0104009 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103fb9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103fbd:	74 1e                	je     f0103fdd <vprintfmt+0x229>
f0103fbf:	0f be d2             	movsbl %dl,%edx
f0103fc2:	83 ea 20             	sub    $0x20,%edx
f0103fc5:	83 fa 5e             	cmp    $0x5e,%edx
f0103fc8:	76 13                	jbe    f0103fdd <vprintfmt+0x229>
					putch('?', putdat);
f0103fca:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103fcd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fd1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0103fd8:	ff 55 08             	call   *0x8(%ebp)
f0103fdb:	eb 0d                	jmp    f0103fea <vprintfmt+0x236>
				else
					putch(ch, putdat);
f0103fdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103fe0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103fe4:	89 04 24             	mov    %eax,(%esp)
f0103fe7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103fea:	83 eb 01             	sub    $0x1,%ebx
f0103fed:	eb 1a                	jmp    f0104009 <vprintfmt+0x255>
f0103fef:	89 75 08             	mov    %esi,0x8(%ebp)
f0103ff2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103ff5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103ff8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103ffb:	eb 0c                	jmp    f0104009 <vprintfmt+0x255>
f0103ffd:	89 75 08             	mov    %esi,0x8(%ebp)
f0104000:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104003:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104006:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104009:	83 c7 01             	add    $0x1,%edi
f010400c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0104010:	0f be c2             	movsbl %dl,%eax
f0104013:	85 c0                	test   %eax,%eax
f0104015:	74 25                	je     f010403c <vprintfmt+0x288>
f0104017:	85 f6                	test   %esi,%esi
f0104019:	78 9e                	js     f0103fb9 <vprintfmt+0x205>
f010401b:	83 ee 01             	sub    $0x1,%esi
f010401e:	79 99                	jns    f0103fb9 <vprintfmt+0x205>
f0104020:	89 df                	mov    %ebx,%edi
f0104022:	8b 75 08             	mov    0x8(%ebp),%esi
f0104025:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104028:	eb 1a                	jmp    f0104044 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010402a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010402e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0104035:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104037:	83 ef 01             	sub    $0x1,%edi
f010403a:	eb 08                	jmp    f0104044 <vprintfmt+0x290>
f010403c:	89 df                	mov    %ebx,%edi
f010403e:	8b 75 08             	mov    0x8(%ebp),%esi
f0104041:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104044:	85 ff                	test   %edi,%edi
f0104046:	7f e2                	jg     f010402a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104048:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010404b:	e9 89 fd ff ff       	jmp    f0103dd9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104050:	83 f9 01             	cmp    $0x1,%ecx
f0104053:	7e 19                	jle    f010406e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
f0104055:	8b 45 14             	mov    0x14(%ebp),%eax
f0104058:	8b 50 04             	mov    0x4(%eax),%edx
f010405b:	8b 00                	mov    (%eax),%eax
f010405d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104060:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104063:	8b 45 14             	mov    0x14(%ebp),%eax
f0104066:	8d 40 08             	lea    0x8(%eax),%eax
f0104069:	89 45 14             	mov    %eax,0x14(%ebp)
f010406c:	eb 38                	jmp    f01040a6 <vprintfmt+0x2f2>
	else if (lflag)
f010406e:	85 c9                	test   %ecx,%ecx
f0104070:	74 1b                	je     f010408d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
f0104072:	8b 45 14             	mov    0x14(%ebp),%eax
f0104075:	8b 00                	mov    (%eax),%eax
f0104077:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010407a:	89 c1                	mov    %eax,%ecx
f010407c:	c1 f9 1f             	sar    $0x1f,%ecx
f010407f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104082:	8b 45 14             	mov    0x14(%ebp),%eax
f0104085:	8d 40 04             	lea    0x4(%eax),%eax
f0104088:	89 45 14             	mov    %eax,0x14(%ebp)
f010408b:	eb 19                	jmp    f01040a6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
f010408d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104090:	8b 00                	mov    (%eax),%eax
f0104092:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104095:	89 c1                	mov    %eax,%ecx
f0104097:	c1 f9 1f             	sar    $0x1f,%ecx
f010409a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010409d:	8b 45 14             	mov    0x14(%ebp),%eax
f01040a0:	8d 40 04             	lea    0x4(%eax),%eax
f01040a3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01040a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01040a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01040ac:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01040b1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01040b5:	0f 89 04 01 00 00    	jns    f01041bf <vprintfmt+0x40b>
				putch('-', putdat);
f01040bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01040bf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01040c6:	ff d6                	call   *%esi
				num = -(long long) num;
f01040c8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01040cb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01040ce:	f7 da                	neg    %edx
f01040d0:	83 d1 00             	adc    $0x0,%ecx
f01040d3:	f7 d9                	neg    %ecx
f01040d5:	e9 e5 00 00 00       	jmp    f01041bf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01040da:	83 f9 01             	cmp    $0x1,%ecx
f01040dd:	7e 10                	jle    f01040ef <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
f01040df:	8b 45 14             	mov    0x14(%ebp),%eax
f01040e2:	8b 10                	mov    (%eax),%edx
f01040e4:	8b 48 04             	mov    0x4(%eax),%ecx
f01040e7:	8d 40 08             	lea    0x8(%eax),%eax
f01040ea:	89 45 14             	mov    %eax,0x14(%ebp)
f01040ed:	eb 26                	jmp    f0104115 <vprintfmt+0x361>
	else if (lflag)
f01040ef:	85 c9                	test   %ecx,%ecx
f01040f1:	74 12                	je     f0104105 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
f01040f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01040f6:	8b 10                	mov    (%eax),%edx
f01040f8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01040fd:	8d 40 04             	lea    0x4(%eax),%eax
f0104100:	89 45 14             	mov    %eax,0x14(%ebp)
f0104103:	eb 10                	jmp    f0104115 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
f0104105:	8b 45 14             	mov    0x14(%ebp),%eax
f0104108:	8b 10                	mov    (%eax),%edx
f010410a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010410f:	8d 40 04             	lea    0x4(%eax),%eax
f0104112:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0104115:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f010411a:	e9 a0 00 00 00       	jmp    f01041bf <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f010411f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104123:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010412a:	ff d6                	call   *%esi
			putch('X', putdat);
f010412c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104130:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0104137:	ff d6                	call   *%esi
			putch('X', putdat);
f0104139:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010413d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0104144:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104146:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0104149:	e9 8b fc ff ff       	jmp    f0103dd9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
f010414e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104152:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0104159:	ff d6                	call   *%esi
			putch('x', putdat);
f010415b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010415f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0104166:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104168:	8b 45 14             	mov    0x14(%ebp),%eax
f010416b:	8b 10                	mov    (%eax),%edx
f010416d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f0104172:	8d 40 04             	lea    0x4(%eax),%eax
f0104175:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104178:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f010417d:	eb 40                	jmp    f01041bf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010417f:	83 f9 01             	cmp    $0x1,%ecx
f0104182:	7e 10                	jle    f0104194 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
f0104184:	8b 45 14             	mov    0x14(%ebp),%eax
f0104187:	8b 10                	mov    (%eax),%edx
f0104189:	8b 48 04             	mov    0x4(%eax),%ecx
f010418c:	8d 40 08             	lea    0x8(%eax),%eax
f010418f:	89 45 14             	mov    %eax,0x14(%ebp)
f0104192:	eb 26                	jmp    f01041ba <vprintfmt+0x406>
	else if (lflag)
f0104194:	85 c9                	test   %ecx,%ecx
f0104196:	74 12                	je     f01041aa <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
f0104198:	8b 45 14             	mov    0x14(%ebp),%eax
f010419b:	8b 10                	mov    (%eax),%edx
f010419d:	b9 00 00 00 00       	mov    $0x0,%ecx
f01041a2:	8d 40 04             	lea    0x4(%eax),%eax
f01041a5:	89 45 14             	mov    %eax,0x14(%ebp)
f01041a8:	eb 10                	jmp    f01041ba <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
f01041aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01041ad:	8b 10                	mov    (%eax),%edx
f01041af:	b9 00 00 00 00       	mov    $0x0,%ecx
f01041b4:	8d 40 04             	lea    0x4(%eax),%eax
f01041b7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01041ba:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f01041bf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01041c3:	89 44 24 10          	mov    %eax,0x10(%esp)
f01041c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01041ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01041ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01041d2:	89 14 24             	mov    %edx,(%esp)
f01041d5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01041d9:	89 da                	mov    %ebx,%edx
f01041db:	89 f0                	mov    %esi,%eax
f01041dd:	e8 9e fa ff ff       	call   f0103c80 <printnum>
			break;
f01041e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01041e5:	e9 ef fb ff ff       	jmp    f0103dd9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01041ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01041ee:	89 04 24             	mov    %eax,(%esp)
f01041f1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01041f6:	e9 de fb ff ff       	jmp    f0103dd9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01041fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01041ff:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0104206:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104208:	eb 03                	jmp    f010420d <vprintfmt+0x459>
f010420a:	83 ef 01             	sub    $0x1,%edi
f010420d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104211:	75 f7                	jne    f010420a <vprintfmt+0x456>
f0104213:	e9 c1 fb ff ff       	jmp    f0103dd9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0104218:	83 c4 3c             	add    $0x3c,%esp
f010421b:	5b                   	pop    %ebx
f010421c:	5e                   	pop    %esi
f010421d:	5f                   	pop    %edi
f010421e:	5d                   	pop    %ebp
f010421f:	c3                   	ret    

f0104220 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104220:	55                   	push   %ebp
f0104221:	89 e5                	mov    %esp,%ebp
f0104223:	83 ec 28             	sub    $0x28,%esp
f0104226:	8b 45 08             	mov    0x8(%ebp),%eax
f0104229:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010422c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010422f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104233:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104236:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010423d:	85 c0                	test   %eax,%eax
f010423f:	74 30                	je     f0104271 <vsnprintf+0x51>
f0104241:	85 d2                	test   %edx,%edx
f0104243:	7e 2c                	jle    f0104271 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104245:	8b 45 14             	mov    0x14(%ebp),%eax
f0104248:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010424c:	8b 45 10             	mov    0x10(%ebp),%eax
f010424f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104253:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104256:	89 44 24 04          	mov    %eax,0x4(%esp)
f010425a:	c7 04 24 6f 3d 10 f0 	movl   $0xf0103d6f,(%esp)
f0104261:	e8 4e fb ff ff       	call   f0103db4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104266:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104269:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010426c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010426f:	eb 05                	jmp    f0104276 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104271:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104276:	c9                   	leave  
f0104277:	c3                   	ret    

f0104278 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104278:	55                   	push   %ebp
f0104279:	89 e5                	mov    %esp,%ebp
f010427b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010427e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104281:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104285:	8b 45 10             	mov    0x10(%ebp),%eax
f0104288:	89 44 24 08          	mov    %eax,0x8(%esp)
f010428c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010428f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104293:	8b 45 08             	mov    0x8(%ebp),%eax
f0104296:	89 04 24             	mov    %eax,(%esp)
f0104299:	e8 82 ff ff ff       	call   f0104220 <vsnprintf>
	va_end(ap);

	return rc;
}
f010429e:	c9                   	leave  
f010429f:	c3                   	ret    

f01042a0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01042a0:	55                   	push   %ebp
f01042a1:	89 e5                	mov    %esp,%ebp
f01042a3:	57                   	push   %edi
f01042a4:	56                   	push   %esi
f01042a5:	53                   	push   %ebx
f01042a6:	83 ec 1c             	sub    $0x1c,%esp
f01042a9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01042ac:	85 c0                	test   %eax,%eax
f01042ae:	74 10                	je     f01042c0 <readline+0x20>
		cprintf("%s", prompt);
f01042b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042b4:	c7 04 24 bc 4e 10 f0 	movl   $0xf0104ebc,(%esp)
f01042bb:	e8 2e f2 ff ff       	call   f01034ee <cprintf>

	i = 0;
	echoing = iscons(0);
f01042c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01042c7:	e8 66 c3 ff ff       	call   f0100632 <iscons>
f01042cc:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01042ce:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01042d3:	e8 49 c3 ff ff       	call   f0100621 <getchar>
f01042d8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01042da:	85 c0                	test   %eax,%eax
f01042dc:	79 17                	jns    f01042f5 <readline+0x55>
			cprintf("read error: %e\n", c);
f01042de:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042e2:	c7 04 24 00 61 10 f0 	movl   $0xf0106100,(%esp)
f01042e9:	e8 00 f2 ff ff       	call   f01034ee <cprintf>
			return NULL;
f01042ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01042f3:	eb 6d                	jmp    f0104362 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01042f5:	83 f8 7f             	cmp    $0x7f,%eax
f01042f8:	74 05                	je     f01042ff <readline+0x5f>
f01042fa:	83 f8 08             	cmp    $0x8,%eax
f01042fd:	75 19                	jne    f0104318 <readline+0x78>
f01042ff:	85 f6                	test   %esi,%esi
f0104301:	7e 15                	jle    f0104318 <readline+0x78>
			if (echoing)
f0104303:	85 ff                	test   %edi,%edi
f0104305:	74 0c                	je     f0104313 <readline+0x73>
				cputchar('\b');
f0104307:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010430e:	e8 fe c2 ff ff       	call   f0100611 <cputchar>
			i--;
f0104313:	83 ee 01             	sub    $0x1,%esi
f0104316:	eb bb                	jmp    f01042d3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104318:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010431e:	7f 1c                	jg     f010433c <readline+0x9c>
f0104320:	83 fb 1f             	cmp    $0x1f,%ebx
f0104323:	7e 17                	jle    f010433c <readline+0x9c>
			if (echoing)
f0104325:	85 ff                	test   %edi,%edi
f0104327:	74 08                	je     f0104331 <readline+0x91>
				cputchar(c);
f0104329:	89 1c 24             	mov    %ebx,(%esp)
f010432c:	e8 e0 c2 ff ff       	call   f0100611 <cputchar>
			buf[i++] = c;
f0104331:	88 9e 80 c9 17 f0    	mov    %bl,-0xfe83680(%esi)
f0104337:	8d 76 01             	lea    0x1(%esi),%esi
f010433a:	eb 97                	jmp    f01042d3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010433c:	83 fb 0d             	cmp    $0xd,%ebx
f010433f:	74 05                	je     f0104346 <readline+0xa6>
f0104341:	83 fb 0a             	cmp    $0xa,%ebx
f0104344:	75 8d                	jne    f01042d3 <readline+0x33>
			if (echoing)
f0104346:	85 ff                	test   %edi,%edi
f0104348:	74 0c                	je     f0104356 <readline+0xb6>
				cputchar('\n');
f010434a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104351:	e8 bb c2 ff ff       	call   f0100611 <cputchar>
			buf[i] = 0;
f0104356:	c6 86 80 c9 17 f0 00 	movb   $0x0,-0xfe83680(%esi)
			return buf;
f010435d:	b8 80 c9 17 f0       	mov    $0xf017c980,%eax
		}
	}
}
f0104362:	83 c4 1c             	add    $0x1c,%esp
f0104365:	5b                   	pop    %ebx
f0104366:	5e                   	pop    %esi
f0104367:	5f                   	pop    %edi
f0104368:	5d                   	pop    %ebp
f0104369:	c3                   	ret    
f010436a:	66 90                	xchg   %ax,%ax
f010436c:	66 90                	xchg   %ax,%ax
f010436e:	66 90                	xchg   %ax,%ax

f0104370 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104370:	55                   	push   %ebp
f0104371:	89 e5                	mov    %esp,%ebp
f0104373:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104376:	b8 00 00 00 00       	mov    $0x0,%eax
f010437b:	eb 03                	jmp    f0104380 <strlen+0x10>
		n++;
f010437d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104380:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104384:	75 f7                	jne    f010437d <strlen+0xd>
		n++;
	return n;
}
f0104386:	5d                   	pop    %ebp
f0104387:	c3                   	ret    

f0104388 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104388:	55                   	push   %ebp
f0104389:	89 e5                	mov    %esp,%ebp
f010438b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010438e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104391:	b8 00 00 00 00       	mov    $0x0,%eax
f0104396:	eb 03                	jmp    f010439b <strnlen+0x13>
		n++;
f0104398:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010439b:	39 d0                	cmp    %edx,%eax
f010439d:	74 06                	je     f01043a5 <strnlen+0x1d>
f010439f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01043a3:	75 f3                	jne    f0104398 <strnlen+0x10>
		n++;
	return n;
}
f01043a5:	5d                   	pop    %ebp
f01043a6:	c3                   	ret    

f01043a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01043a7:	55                   	push   %ebp
f01043a8:	89 e5                	mov    %esp,%ebp
f01043aa:	53                   	push   %ebx
f01043ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01043ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01043b1:	89 c2                	mov    %eax,%edx
f01043b3:	83 c2 01             	add    $0x1,%edx
f01043b6:	83 c1 01             	add    $0x1,%ecx
f01043b9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01043bd:	88 5a ff             	mov    %bl,-0x1(%edx)
f01043c0:	84 db                	test   %bl,%bl
f01043c2:	75 ef                	jne    f01043b3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01043c4:	5b                   	pop    %ebx
f01043c5:	5d                   	pop    %ebp
f01043c6:	c3                   	ret    

f01043c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01043c7:	55                   	push   %ebp
f01043c8:	89 e5                	mov    %esp,%ebp
f01043ca:	53                   	push   %ebx
f01043cb:	83 ec 08             	sub    $0x8,%esp
f01043ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01043d1:	89 1c 24             	mov    %ebx,(%esp)
f01043d4:	e8 97 ff ff ff       	call   f0104370 <strlen>
	strcpy(dst + len, src);
f01043d9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01043dc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01043e0:	01 d8                	add    %ebx,%eax
f01043e2:	89 04 24             	mov    %eax,(%esp)
f01043e5:	e8 bd ff ff ff       	call   f01043a7 <strcpy>
	return dst;
}
f01043ea:	89 d8                	mov    %ebx,%eax
f01043ec:	83 c4 08             	add    $0x8,%esp
f01043ef:	5b                   	pop    %ebx
f01043f0:	5d                   	pop    %ebp
f01043f1:	c3                   	ret    

f01043f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01043f2:	55                   	push   %ebp
f01043f3:	89 e5                	mov    %esp,%ebp
f01043f5:	56                   	push   %esi
f01043f6:	53                   	push   %ebx
f01043f7:	8b 75 08             	mov    0x8(%ebp),%esi
f01043fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01043fd:	89 f3                	mov    %esi,%ebx
f01043ff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104402:	89 f2                	mov    %esi,%edx
f0104404:	eb 0f                	jmp    f0104415 <strncpy+0x23>
		*dst++ = *src;
f0104406:	83 c2 01             	add    $0x1,%edx
f0104409:	0f b6 01             	movzbl (%ecx),%eax
f010440c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010440f:	80 39 01             	cmpb   $0x1,(%ecx)
f0104412:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104415:	39 da                	cmp    %ebx,%edx
f0104417:	75 ed                	jne    f0104406 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104419:	89 f0                	mov    %esi,%eax
f010441b:	5b                   	pop    %ebx
f010441c:	5e                   	pop    %esi
f010441d:	5d                   	pop    %ebp
f010441e:	c3                   	ret    

f010441f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010441f:	55                   	push   %ebp
f0104420:	89 e5                	mov    %esp,%ebp
f0104422:	56                   	push   %esi
f0104423:	53                   	push   %ebx
f0104424:	8b 75 08             	mov    0x8(%ebp),%esi
f0104427:	8b 55 0c             	mov    0xc(%ebp),%edx
f010442a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010442d:	89 f0                	mov    %esi,%eax
f010442f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104433:	85 c9                	test   %ecx,%ecx
f0104435:	75 0b                	jne    f0104442 <strlcpy+0x23>
f0104437:	eb 1d                	jmp    f0104456 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104439:	83 c0 01             	add    $0x1,%eax
f010443c:	83 c2 01             	add    $0x1,%edx
f010443f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104442:	39 d8                	cmp    %ebx,%eax
f0104444:	74 0b                	je     f0104451 <strlcpy+0x32>
f0104446:	0f b6 0a             	movzbl (%edx),%ecx
f0104449:	84 c9                	test   %cl,%cl
f010444b:	75 ec                	jne    f0104439 <strlcpy+0x1a>
f010444d:	89 c2                	mov    %eax,%edx
f010444f:	eb 02                	jmp    f0104453 <strlcpy+0x34>
f0104451:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0104453:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0104456:	29 f0                	sub    %esi,%eax
}
f0104458:	5b                   	pop    %ebx
f0104459:	5e                   	pop    %esi
f010445a:	5d                   	pop    %ebp
f010445b:	c3                   	ret    

f010445c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010445c:	55                   	push   %ebp
f010445d:	89 e5                	mov    %esp,%ebp
f010445f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104462:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104465:	eb 06                	jmp    f010446d <strcmp+0x11>
		p++, q++;
f0104467:	83 c1 01             	add    $0x1,%ecx
f010446a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010446d:	0f b6 01             	movzbl (%ecx),%eax
f0104470:	84 c0                	test   %al,%al
f0104472:	74 04                	je     f0104478 <strcmp+0x1c>
f0104474:	3a 02                	cmp    (%edx),%al
f0104476:	74 ef                	je     f0104467 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104478:	0f b6 c0             	movzbl %al,%eax
f010447b:	0f b6 12             	movzbl (%edx),%edx
f010447e:	29 d0                	sub    %edx,%eax
}
f0104480:	5d                   	pop    %ebp
f0104481:	c3                   	ret    

f0104482 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104482:	55                   	push   %ebp
f0104483:	89 e5                	mov    %esp,%ebp
f0104485:	53                   	push   %ebx
f0104486:	8b 45 08             	mov    0x8(%ebp),%eax
f0104489:	8b 55 0c             	mov    0xc(%ebp),%edx
f010448c:	89 c3                	mov    %eax,%ebx
f010448e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104491:	eb 06                	jmp    f0104499 <strncmp+0x17>
		n--, p++, q++;
f0104493:	83 c0 01             	add    $0x1,%eax
f0104496:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104499:	39 d8                	cmp    %ebx,%eax
f010449b:	74 15                	je     f01044b2 <strncmp+0x30>
f010449d:	0f b6 08             	movzbl (%eax),%ecx
f01044a0:	84 c9                	test   %cl,%cl
f01044a2:	74 04                	je     f01044a8 <strncmp+0x26>
f01044a4:	3a 0a                	cmp    (%edx),%cl
f01044a6:	74 eb                	je     f0104493 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01044a8:	0f b6 00             	movzbl (%eax),%eax
f01044ab:	0f b6 12             	movzbl (%edx),%edx
f01044ae:	29 d0                	sub    %edx,%eax
f01044b0:	eb 05                	jmp    f01044b7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01044b2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01044b7:	5b                   	pop    %ebx
f01044b8:	5d                   	pop    %ebp
f01044b9:	c3                   	ret    

f01044ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01044ba:	55                   	push   %ebp
f01044bb:	89 e5                	mov    %esp,%ebp
f01044bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01044c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01044c4:	eb 07                	jmp    f01044cd <strchr+0x13>
		if (*s == c)
f01044c6:	38 ca                	cmp    %cl,%dl
f01044c8:	74 0f                	je     f01044d9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01044ca:	83 c0 01             	add    $0x1,%eax
f01044cd:	0f b6 10             	movzbl (%eax),%edx
f01044d0:	84 d2                	test   %dl,%dl
f01044d2:	75 f2                	jne    f01044c6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01044d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01044d9:	5d                   	pop    %ebp
f01044da:	c3                   	ret    

f01044db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01044db:	55                   	push   %ebp
f01044dc:	89 e5                	mov    %esp,%ebp
f01044de:	8b 45 08             	mov    0x8(%ebp),%eax
f01044e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01044e5:	eb 07                	jmp    f01044ee <strfind+0x13>
		if (*s == c)
f01044e7:	38 ca                	cmp    %cl,%dl
f01044e9:	74 0a                	je     f01044f5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01044eb:	83 c0 01             	add    $0x1,%eax
f01044ee:	0f b6 10             	movzbl (%eax),%edx
f01044f1:	84 d2                	test   %dl,%dl
f01044f3:	75 f2                	jne    f01044e7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f01044f5:	5d                   	pop    %ebp
f01044f6:	c3                   	ret    

f01044f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01044f7:	55                   	push   %ebp
f01044f8:	89 e5                	mov    %esp,%ebp
f01044fa:	57                   	push   %edi
f01044fb:	56                   	push   %esi
f01044fc:	53                   	push   %ebx
f01044fd:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104500:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104503:	85 c9                	test   %ecx,%ecx
f0104505:	74 36                	je     f010453d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104507:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010450d:	75 28                	jne    f0104537 <memset+0x40>
f010450f:	f6 c1 03             	test   $0x3,%cl
f0104512:	75 23                	jne    f0104537 <memset+0x40>
		c &= 0xFF;
f0104514:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104518:	89 d3                	mov    %edx,%ebx
f010451a:	c1 e3 08             	shl    $0x8,%ebx
f010451d:	89 d6                	mov    %edx,%esi
f010451f:	c1 e6 18             	shl    $0x18,%esi
f0104522:	89 d0                	mov    %edx,%eax
f0104524:	c1 e0 10             	shl    $0x10,%eax
f0104527:	09 f0                	or     %esi,%eax
f0104529:	09 c2                	or     %eax,%edx
f010452b:	89 d0                	mov    %edx,%eax
f010452d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010452f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104532:	fc                   	cld    
f0104533:	f3 ab                	rep stos %eax,%es:(%edi)
f0104535:	eb 06                	jmp    f010453d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104537:	8b 45 0c             	mov    0xc(%ebp),%eax
f010453a:	fc                   	cld    
f010453b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010453d:	89 f8                	mov    %edi,%eax
f010453f:	5b                   	pop    %ebx
f0104540:	5e                   	pop    %esi
f0104541:	5f                   	pop    %edi
f0104542:	5d                   	pop    %ebp
f0104543:	c3                   	ret    

f0104544 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104544:	55                   	push   %ebp
f0104545:	89 e5                	mov    %esp,%ebp
f0104547:	57                   	push   %edi
f0104548:	56                   	push   %esi
f0104549:	8b 45 08             	mov    0x8(%ebp),%eax
f010454c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010454f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104552:	39 c6                	cmp    %eax,%esi
f0104554:	73 35                	jae    f010458b <memmove+0x47>
f0104556:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104559:	39 d0                	cmp    %edx,%eax
f010455b:	73 2e                	jae    f010458b <memmove+0x47>
		s += n;
		d += n;
f010455d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0104560:	89 d6                	mov    %edx,%esi
f0104562:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104564:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010456a:	75 13                	jne    f010457f <memmove+0x3b>
f010456c:	f6 c1 03             	test   $0x3,%cl
f010456f:	75 0e                	jne    f010457f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104571:	83 ef 04             	sub    $0x4,%edi
f0104574:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104577:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010457a:	fd                   	std    
f010457b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010457d:	eb 09                	jmp    f0104588 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010457f:	83 ef 01             	sub    $0x1,%edi
f0104582:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104585:	fd                   	std    
f0104586:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104588:	fc                   	cld    
f0104589:	eb 1d                	jmp    f01045a8 <memmove+0x64>
f010458b:	89 f2                	mov    %esi,%edx
f010458d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010458f:	f6 c2 03             	test   $0x3,%dl
f0104592:	75 0f                	jne    f01045a3 <memmove+0x5f>
f0104594:	f6 c1 03             	test   $0x3,%cl
f0104597:	75 0a                	jne    f01045a3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104599:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010459c:	89 c7                	mov    %eax,%edi
f010459e:	fc                   	cld    
f010459f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01045a1:	eb 05                	jmp    f01045a8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01045a3:	89 c7                	mov    %eax,%edi
f01045a5:	fc                   	cld    
f01045a6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01045a8:	5e                   	pop    %esi
f01045a9:	5f                   	pop    %edi
f01045aa:	5d                   	pop    %ebp
f01045ab:	c3                   	ret    

f01045ac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01045ac:	55                   	push   %ebp
f01045ad:	89 e5                	mov    %esp,%ebp
f01045af:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01045b2:	8b 45 10             	mov    0x10(%ebp),%eax
f01045b5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045b9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01045bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01045c3:	89 04 24             	mov    %eax,(%esp)
f01045c6:	e8 79 ff ff ff       	call   f0104544 <memmove>
}
f01045cb:	c9                   	leave  
f01045cc:	c3                   	ret    

f01045cd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01045cd:	55                   	push   %ebp
f01045ce:	89 e5                	mov    %esp,%ebp
f01045d0:	56                   	push   %esi
f01045d1:	53                   	push   %ebx
f01045d2:	8b 55 08             	mov    0x8(%ebp),%edx
f01045d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01045d8:	89 d6                	mov    %edx,%esi
f01045da:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01045dd:	eb 1a                	jmp    f01045f9 <memcmp+0x2c>
		if (*s1 != *s2)
f01045df:	0f b6 02             	movzbl (%edx),%eax
f01045e2:	0f b6 19             	movzbl (%ecx),%ebx
f01045e5:	38 d8                	cmp    %bl,%al
f01045e7:	74 0a                	je     f01045f3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01045e9:	0f b6 c0             	movzbl %al,%eax
f01045ec:	0f b6 db             	movzbl %bl,%ebx
f01045ef:	29 d8                	sub    %ebx,%eax
f01045f1:	eb 0f                	jmp    f0104602 <memcmp+0x35>
		s1++, s2++;
f01045f3:	83 c2 01             	add    $0x1,%edx
f01045f6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01045f9:	39 f2                	cmp    %esi,%edx
f01045fb:	75 e2                	jne    f01045df <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01045fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104602:	5b                   	pop    %ebx
f0104603:	5e                   	pop    %esi
f0104604:	5d                   	pop    %ebp
f0104605:	c3                   	ret    

f0104606 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104606:	55                   	push   %ebp
f0104607:	89 e5                	mov    %esp,%ebp
f0104609:	8b 45 08             	mov    0x8(%ebp),%eax
f010460c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010460f:	89 c2                	mov    %eax,%edx
f0104611:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104614:	eb 07                	jmp    f010461d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104616:	38 08                	cmp    %cl,(%eax)
f0104618:	74 07                	je     f0104621 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010461a:	83 c0 01             	add    $0x1,%eax
f010461d:	39 d0                	cmp    %edx,%eax
f010461f:	72 f5                	jb     f0104616 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104621:	5d                   	pop    %ebp
f0104622:	c3                   	ret    

f0104623 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104623:	55                   	push   %ebp
f0104624:	89 e5                	mov    %esp,%ebp
f0104626:	57                   	push   %edi
f0104627:	56                   	push   %esi
f0104628:	53                   	push   %ebx
f0104629:	8b 55 08             	mov    0x8(%ebp),%edx
f010462c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010462f:	eb 03                	jmp    f0104634 <strtol+0x11>
		s++;
f0104631:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104634:	0f b6 0a             	movzbl (%edx),%ecx
f0104637:	80 f9 09             	cmp    $0x9,%cl
f010463a:	74 f5                	je     f0104631 <strtol+0xe>
f010463c:	80 f9 20             	cmp    $0x20,%cl
f010463f:	74 f0                	je     f0104631 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104641:	80 f9 2b             	cmp    $0x2b,%cl
f0104644:	75 0a                	jne    f0104650 <strtol+0x2d>
		s++;
f0104646:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104649:	bf 00 00 00 00       	mov    $0x0,%edi
f010464e:	eb 11                	jmp    f0104661 <strtol+0x3e>
f0104650:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104655:	80 f9 2d             	cmp    $0x2d,%cl
f0104658:	75 07                	jne    f0104661 <strtol+0x3e>
		s++, neg = 1;
f010465a:	8d 52 01             	lea    0x1(%edx),%edx
f010465d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104661:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0104666:	75 15                	jne    f010467d <strtol+0x5a>
f0104668:	80 3a 30             	cmpb   $0x30,(%edx)
f010466b:	75 10                	jne    f010467d <strtol+0x5a>
f010466d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104671:	75 0a                	jne    f010467d <strtol+0x5a>
		s += 2, base = 16;
f0104673:	83 c2 02             	add    $0x2,%edx
f0104676:	b8 10 00 00 00       	mov    $0x10,%eax
f010467b:	eb 10                	jmp    f010468d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f010467d:	85 c0                	test   %eax,%eax
f010467f:	75 0c                	jne    f010468d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104681:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104683:	80 3a 30             	cmpb   $0x30,(%edx)
f0104686:	75 05                	jne    f010468d <strtol+0x6a>
		s++, base = 8;
f0104688:	83 c2 01             	add    $0x1,%edx
f010468b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f010468d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104692:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104695:	0f b6 0a             	movzbl (%edx),%ecx
f0104698:	8d 71 d0             	lea    -0x30(%ecx),%esi
f010469b:	89 f0                	mov    %esi,%eax
f010469d:	3c 09                	cmp    $0x9,%al
f010469f:	77 08                	ja     f01046a9 <strtol+0x86>
			dig = *s - '0';
f01046a1:	0f be c9             	movsbl %cl,%ecx
f01046a4:	83 e9 30             	sub    $0x30,%ecx
f01046a7:	eb 20                	jmp    f01046c9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f01046a9:	8d 71 9f             	lea    -0x61(%ecx),%esi
f01046ac:	89 f0                	mov    %esi,%eax
f01046ae:	3c 19                	cmp    $0x19,%al
f01046b0:	77 08                	ja     f01046ba <strtol+0x97>
			dig = *s - 'a' + 10;
f01046b2:	0f be c9             	movsbl %cl,%ecx
f01046b5:	83 e9 57             	sub    $0x57,%ecx
f01046b8:	eb 0f                	jmp    f01046c9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f01046ba:	8d 71 bf             	lea    -0x41(%ecx),%esi
f01046bd:	89 f0                	mov    %esi,%eax
f01046bf:	3c 19                	cmp    $0x19,%al
f01046c1:	77 16                	ja     f01046d9 <strtol+0xb6>
			dig = *s - 'A' + 10;
f01046c3:	0f be c9             	movsbl %cl,%ecx
f01046c6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01046c9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f01046cc:	7d 0f                	jge    f01046dd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f01046ce:	83 c2 01             	add    $0x1,%edx
f01046d1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f01046d5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f01046d7:	eb bc                	jmp    f0104695 <strtol+0x72>
f01046d9:	89 d8                	mov    %ebx,%eax
f01046db:	eb 02                	jmp    f01046df <strtol+0xbc>
f01046dd:	89 d8                	mov    %ebx,%eax

	if (endptr)
f01046df:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01046e3:	74 05                	je     f01046ea <strtol+0xc7>
		*endptr = (char *) s;
f01046e5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01046e8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01046ea:	f7 d8                	neg    %eax
f01046ec:	85 ff                	test   %edi,%edi
f01046ee:	0f 44 c3             	cmove  %ebx,%eax
}
f01046f1:	5b                   	pop    %ebx
f01046f2:	5e                   	pop    %esi
f01046f3:	5f                   	pop    %edi
f01046f4:	5d                   	pop    %ebp
f01046f5:	c3                   	ret    
f01046f6:	66 90                	xchg   %ax,%ax
f01046f8:	66 90                	xchg   %ax,%ax
f01046fa:	66 90                	xchg   %ax,%ax
f01046fc:	66 90                	xchg   %ax,%ax
f01046fe:	66 90                	xchg   %ax,%ax

f0104700 <__udivdi3>:
f0104700:	55                   	push   %ebp
f0104701:	57                   	push   %edi
f0104702:	56                   	push   %esi
f0104703:	83 ec 0c             	sub    $0xc,%esp
f0104706:	8b 44 24 28          	mov    0x28(%esp),%eax
f010470a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010470e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0104712:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0104716:	85 c0                	test   %eax,%eax
f0104718:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010471c:	89 ea                	mov    %ebp,%edx
f010471e:	89 0c 24             	mov    %ecx,(%esp)
f0104721:	75 2d                	jne    f0104750 <__udivdi3+0x50>
f0104723:	39 e9                	cmp    %ebp,%ecx
f0104725:	77 61                	ja     f0104788 <__udivdi3+0x88>
f0104727:	85 c9                	test   %ecx,%ecx
f0104729:	89 ce                	mov    %ecx,%esi
f010472b:	75 0b                	jne    f0104738 <__udivdi3+0x38>
f010472d:	b8 01 00 00 00       	mov    $0x1,%eax
f0104732:	31 d2                	xor    %edx,%edx
f0104734:	f7 f1                	div    %ecx
f0104736:	89 c6                	mov    %eax,%esi
f0104738:	31 d2                	xor    %edx,%edx
f010473a:	89 e8                	mov    %ebp,%eax
f010473c:	f7 f6                	div    %esi
f010473e:	89 c5                	mov    %eax,%ebp
f0104740:	89 f8                	mov    %edi,%eax
f0104742:	f7 f6                	div    %esi
f0104744:	89 ea                	mov    %ebp,%edx
f0104746:	83 c4 0c             	add    $0xc,%esp
f0104749:	5e                   	pop    %esi
f010474a:	5f                   	pop    %edi
f010474b:	5d                   	pop    %ebp
f010474c:	c3                   	ret    
f010474d:	8d 76 00             	lea    0x0(%esi),%esi
f0104750:	39 e8                	cmp    %ebp,%eax
f0104752:	77 24                	ja     f0104778 <__udivdi3+0x78>
f0104754:	0f bd e8             	bsr    %eax,%ebp
f0104757:	83 f5 1f             	xor    $0x1f,%ebp
f010475a:	75 3c                	jne    f0104798 <__udivdi3+0x98>
f010475c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104760:	39 34 24             	cmp    %esi,(%esp)
f0104763:	0f 86 9f 00 00 00    	jbe    f0104808 <__udivdi3+0x108>
f0104769:	39 d0                	cmp    %edx,%eax
f010476b:	0f 82 97 00 00 00    	jb     f0104808 <__udivdi3+0x108>
f0104771:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104778:	31 d2                	xor    %edx,%edx
f010477a:	31 c0                	xor    %eax,%eax
f010477c:	83 c4 0c             	add    $0xc,%esp
f010477f:	5e                   	pop    %esi
f0104780:	5f                   	pop    %edi
f0104781:	5d                   	pop    %ebp
f0104782:	c3                   	ret    
f0104783:	90                   	nop
f0104784:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104788:	89 f8                	mov    %edi,%eax
f010478a:	f7 f1                	div    %ecx
f010478c:	31 d2                	xor    %edx,%edx
f010478e:	83 c4 0c             	add    $0xc,%esp
f0104791:	5e                   	pop    %esi
f0104792:	5f                   	pop    %edi
f0104793:	5d                   	pop    %ebp
f0104794:	c3                   	ret    
f0104795:	8d 76 00             	lea    0x0(%esi),%esi
f0104798:	89 e9                	mov    %ebp,%ecx
f010479a:	8b 3c 24             	mov    (%esp),%edi
f010479d:	d3 e0                	shl    %cl,%eax
f010479f:	89 c6                	mov    %eax,%esi
f01047a1:	b8 20 00 00 00       	mov    $0x20,%eax
f01047a6:	29 e8                	sub    %ebp,%eax
f01047a8:	89 c1                	mov    %eax,%ecx
f01047aa:	d3 ef                	shr    %cl,%edi
f01047ac:	89 e9                	mov    %ebp,%ecx
f01047ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01047b2:	8b 3c 24             	mov    (%esp),%edi
f01047b5:	09 74 24 08          	or     %esi,0x8(%esp)
f01047b9:	89 d6                	mov    %edx,%esi
f01047bb:	d3 e7                	shl    %cl,%edi
f01047bd:	89 c1                	mov    %eax,%ecx
f01047bf:	89 3c 24             	mov    %edi,(%esp)
f01047c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01047c6:	d3 ee                	shr    %cl,%esi
f01047c8:	89 e9                	mov    %ebp,%ecx
f01047ca:	d3 e2                	shl    %cl,%edx
f01047cc:	89 c1                	mov    %eax,%ecx
f01047ce:	d3 ef                	shr    %cl,%edi
f01047d0:	09 d7                	or     %edx,%edi
f01047d2:	89 f2                	mov    %esi,%edx
f01047d4:	89 f8                	mov    %edi,%eax
f01047d6:	f7 74 24 08          	divl   0x8(%esp)
f01047da:	89 d6                	mov    %edx,%esi
f01047dc:	89 c7                	mov    %eax,%edi
f01047de:	f7 24 24             	mull   (%esp)
f01047e1:	39 d6                	cmp    %edx,%esi
f01047e3:	89 14 24             	mov    %edx,(%esp)
f01047e6:	72 30                	jb     f0104818 <__udivdi3+0x118>
f01047e8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01047ec:	89 e9                	mov    %ebp,%ecx
f01047ee:	d3 e2                	shl    %cl,%edx
f01047f0:	39 c2                	cmp    %eax,%edx
f01047f2:	73 05                	jae    f01047f9 <__udivdi3+0xf9>
f01047f4:	3b 34 24             	cmp    (%esp),%esi
f01047f7:	74 1f                	je     f0104818 <__udivdi3+0x118>
f01047f9:	89 f8                	mov    %edi,%eax
f01047fb:	31 d2                	xor    %edx,%edx
f01047fd:	e9 7a ff ff ff       	jmp    f010477c <__udivdi3+0x7c>
f0104802:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104808:	31 d2                	xor    %edx,%edx
f010480a:	b8 01 00 00 00       	mov    $0x1,%eax
f010480f:	e9 68 ff ff ff       	jmp    f010477c <__udivdi3+0x7c>
f0104814:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104818:	8d 47 ff             	lea    -0x1(%edi),%eax
f010481b:	31 d2                	xor    %edx,%edx
f010481d:	83 c4 0c             	add    $0xc,%esp
f0104820:	5e                   	pop    %esi
f0104821:	5f                   	pop    %edi
f0104822:	5d                   	pop    %ebp
f0104823:	c3                   	ret    
f0104824:	66 90                	xchg   %ax,%ax
f0104826:	66 90                	xchg   %ax,%ax
f0104828:	66 90                	xchg   %ax,%ax
f010482a:	66 90                	xchg   %ax,%ax
f010482c:	66 90                	xchg   %ax,%ax
f010482e:	66 90                	xchg   %ax,%ax

f0104830 <__umoddi3>:
f0104830:	55                   	push   %ebp
f0104831:	57                   	push   %edi
f0104832:	56                   	push   %esi
f0104833:	83 ec 14             	sub    $0x14,%esp
f0104836:	8b 44 24 28          	mov    0x28(%esp),%eax
f010483a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010483e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0104842:	89 c7                	mov    %eax,%edi
f0104844:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104848:	8b 44 24 30          	mov    0x30(%esp),%eax
f010484c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0104850:	89 34 24             	mov    %esi,(%esp)
f0104853:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104857:	85 c0                	test   %eax,%eax
f0104859:	89 c2                	mov    %eax,%edx
f010485b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010485f:	75 17                	jne    f0104878 <__umoddi3+0x48>
f0104861:	39 fe                	cmp    %edi,%esi
f0104863:	76 4b                	jbe    f01048b0 <__umoddi3+0x80>
f0104865:	89 c8                	mov    %ecx,%eax
f0104867:	89 fa                	mov    %edi,%edx
f0104869:	f7 f6                	div    %esi
f010486b:	89 d0                	mov    %edx,%eax
f010486d:	31 d2                	xor    %edx,%edx
f010486f:	83 c4 14             	add    $0x14,%esp
f0104872:	5e                   	pop    %esi
f0104873:	5f                   	pop    %edi
f0104874:	5d                   	pop    %ebp
f0104875:	c3                   	ret    
f0104876:	66 90                	xchg   %ax,%ax
f0104878:	39 f8                	cmp    %edi,%eax
f010487a:	77 54                	ja     f01048d0 <__umoddi3+0xa0>
f010487c:	0f bd e8             	bsr    %eax,%ebp
f010487f:	83 f5 1f             	xor    $0x1f,%ebp
f0104882:	75 5c                	jne    f01048e0 <__umoddi3+0xb0>
f0104884:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0104888:	39 3c 24             	cmp    %edi,(%esp)
f010488b:	0f 87 e7 00 00 00    	ja     f0104978 <__umoddi3+0x148>
f0104891:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104895:	29 f1                	sub    %esi,%ecx
f0104897:	19 c7                	sbb    %eax,%edi
f0104899:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010489d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01048a1:	8b 44 24 08          	mov    0x8(%esp),%eax
f01048a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01048a9:	83 c4 14             	add    $0x14,%esp
f01048ac:	5e                   	pop    %esi
f01048ad:	5f                   	pop    %edi
f01048ae:	5d                   	pop    %ebp
f01048af:	c3                   	ret    
f01048b0:	85 f6                	test   %esi,%esi
f01048b2:	89 f5                	mov    %esi,%ebp
f01048b4:	75 0b                	jne    f01048c1 <__umoddi3+0x91>
f01048b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01048bb:	31 d2                	xor    %edx,%edx
f01048bd:	f7 f6                	div    %esi
f01048bf:	89 c5                	mov    %eax,%ebp
f01048c1:	8b 44 24 04          	mov    0x4(%esp),%eax
f01048c5:	31 d2                	xor    %edx,%edx
f01048c7:	f7 f5                	div    %ebp
f01048c9:	89 c8                	mov    %ecx,%eax
f01048cb:	f7 f5                	div    %ebp
f01048cd:	eb 9c                	jmp    f010486b <__umoddi3+0x3b>
f01048cf:	90                   	nop
f01048d0:	89 c8                	mov    %ecx,%eax
f01048d2:	89 fa                	mov    %edi,%edx
f01048d4:	83 c4 14             	add    $0x14,%esp
f01048d7:	5e                   	pop    %esi
f01048d8:	5f                   	pop    %edi
f01048d9:	5d                   	pop    %ebp
f01048da:	c3                   	ret    
f01048db:	90                   	nop
f01048dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01048e0:	8b 04 24             	mov    (%esp),%eax
f01048e3:	be 20 00 00 00       	mov    $0x20,%esi
f01048e8:	89 e9                	mov    %ebp,%ecx
f01048ea:	29 ee                	sub    %ebp,%esi
f01048ec:	d3 e2                	shl    %cl,%edx
f01048ee:	89 f1                	mov    %esi,%ecx
f01048f0:	d3 e8                	shr    %cl,%eax
f01048f2:	89 e9                	mov    %ebp,%ecx
f01048f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048f8:	8b 04 24             	mov    (%esp),%eax
f01048fb:	09 54 24 04          	or     %edx,0x4(%esp)
f01048ff:	89 fa                	mov    %edi,%edx
f0104901:	d3 e0                	shl    %cl,%eax
f0104903:	89 f1                	mov    %esi,%ecx
f0104905:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104909:	8b 44 24 10          	mov    0x10(%esp),%eax
f010490d:	d3 ea                	shr    %cl,%edx
f010490f:	89 e9                	mov    %ebp,%ecx
f0104911:	d3 e7                	shl    %cl,%edi
f0104913:	89 f1                	mov    %esi,%ecx
f0104915:	d3 e8                	shr    %cl,%eax
f0104917:	89 e9                	mov    %ebp,%ecx
f0104919:	09 f8                	or     %edi,%eax
f010491b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f010491f:	f7 74 24 04          	divl   0x4(%esp)
f0104923:	d3 e7                	shl    %cl,%edi
f0104925:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104929:	89 d7                	mov    %edx,%edi
f010492b:	f7 64 24 08          	mull   0x8(%esp)
f010492f:	39 d7                	cmp    %edx,%edi
f0104931:	89 c1                	mov    %eax,%ecx
f0104933:	89 14 24             	mov    %edx,(%esp)
f0104936:	72 2c                	jb     f0104964 <__umoddi3+0x134>
f0104938:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f010493c:	72 22                	jb     f0104960 <__umoddi3+0x130>
f010493e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0104942:	29 c8                	sub    %ecx,%eax
f0104944:	19 d7                	sbb    %edx,%edi
f0104946:	89 e9                	mov    %ebp,%ecx
f0104948:	89 fa                	mov    %edi,%edx
f010494a:	d3 e8                	shr    %cl,%eax
f010494c:	89 f1                	mov    %esi,%ecx
f010494e:	d3 e2                	shl    %cl,%edx
f0104950:	89 e9                	mov    %ebp,%ecx
f0104952:	d3 ef                	shr    %cl,%edi
f0104954:	09 d0                	or     %edx,%eax
f0104956:	89 fa                	mov    %edi,%edx
f0104958:	83 c4 14             	add    $0x14,%esp
f010495b:	5e                   	pop    %esi
f010495c:	5f                   	pop    %edi
f010495d:	5d                   	pop    %ebp
f010495e:	c3                   	ret    
f010495f:	90                   	nop
f0104960:	39 d7                	cmp    %edx,%edi
f0104962:	75 da                	jne    f010493e <__umoddi3+0x10e>
f0104964:	8b 14 24             	mov    (%esp),%edx
f0104967:	89 c1                	mov    %eax,%ecx
f0104969:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f010496d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0104971:	eb cb                	jmp    f010493e <__umoddi3+0x10e>
f0104973:	90                   	nop
f0104974:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104978:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f010497c:	0f 82 0f ff ff ff    	jb     f0104891 <__umoddi3+0x61>
f0104982:	e9 1a ff ff ff       	jmp    f01048a1 <__umoddi3+0x71>
