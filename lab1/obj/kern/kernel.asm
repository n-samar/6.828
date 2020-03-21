
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
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 12 01 00    	add    $0x112be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 98 08 ff ff    	lea    -0xf768(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 81 0a 00 00       	call   f0100ae4 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7f 2b                	jg     f0100095 <test_backtrace+0x55>
		test_backtrace(x-1);
	else
		mon_backtrace(0, 0, 0);
f010006a:	83 ec 04             	sub    $0x4,%esp
f010006d:	6a 00                	push   $0x0
f010006f:	6a 00                	push   $0x0
f0100071:	6a 00                	push   $0x0
f0100073:	e8 22 08 00 00       	call   f010089a <mon_backtrace>
f0100078:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007b:	83 ec 08             	sub    $0x8,%esp
f010007e:	56                   	push   %esi
f010007f:	8d 83 b4 08 ff ff    	lea    -0xf74c(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 59 0a 00 00       	call   f0100ae4 <cprintf>
}
f010008b:	83 c4 10             	add    $0x10,%esp
f010008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100091:	5b                   	pop    %ebx
f0100092:	5e                   	pop    %esi
f0100093:	5d                   	pop    %ebp
f0100094:	c3                   	ret    
		test_backtrace(x-1);
f0100095:	83 ec 0c             	sub    $0xc,%esp
f0100098:	8d 46 ff             	lea    -0x1(%esi),%eax
f010009b:	50                   	push   %eax
f010009c:	e8 9f ff ff ff       	call   f0100040 <test_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d5                	jmp    f010007b <test_backtrace+0x3b>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 12 01 00    	add    $0x11256,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000be:	c7 c0 a0 36 11 f0    	mov    $0xf01136a0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 8d 16 00 00       	call   f010175c <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 3d 05 00 00       	call   f0100611 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 cf 08 ff ff    	lea    -0xf731(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 fc 09 00 00       	call   f0100ae4 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 2b 08 00 00       	call   f010092c <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	57                   	push   %edi
f010010a:	56                   	push   %esi
f010010b:	53                   	push   %ebx
f010010c:	83 ec 0c             	sub    $0xc,%esp
f010010f:	e8 a8 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100114:	81 c3 f4 11 01 00    	add    $0x111f4,%ebx
f010011a:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f010011d:	c7 c0 a4 36 11 f0    	mov    $0xf01136a4,%eax
f0100123:	83 38 00             	cmpl   $0x0,(%eax)
f0100126:	74 0f                	je     f0100137 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100128:	83 ec 0c             	sub    $0xc,%esp
f010012b:	6a 00                	push   $0x0
f010012d:	e8 fa 07 00 00       	call   f010092c <monitor>
f0100132:	83 c4 10             	add    $0x10,%esp
f0100135:	eb f1                	jmp    f0100128 <_panic+0x22>
	panicstr = fmt;
f0100137:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100139:	fa                   	cli    
f010013a:	fc                   	cld    
	va_start(ap, fmt);
f010013b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013e:	83 ec 04             	sub    $0x4,%esp
f0100141:	ff 75 0c             	pushl  0xc(%ebp)
f0100144:	ff 75 08             	pushl  0x8(%ebp)
f0100147:	8d 83 ea 08 ff ff    	lea    -0xf716(%ebx),%eax
f010014d:	50                   	push   %eax
f010014e:	e8 91 09 00 00       	call   f0100ae4 <cprintf>
	vcprintf(fmt, ap);
f0100153:	83 c4 08             	add    $0x8,%esp
f0100156:	56                   	push   %esi
f0100157:	57                   	push   %edi
f0100158:	e8 50 09 00 00       	call   f0100aad <vcprintf>
	cprintf("\n");
f010015d:	8d 83 28 09 ff ff    	lea    -0xf6d8(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 79 09 00 00       	call   f0100ae4 <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb b8                	jmp    f0100128 <_panic+0x22>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 8e 11 01 00    	add    $0x1118e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	pushl  0xc(%ebp)
f0100189:	ff 75 08             	pushl  0x8(%ebp)
f010018c:	8d 83 02 09 ff ff    	lea    -0xf6fe(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 4c 09 00 00       	call   f0100ae4 <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 09 09 00 00       	call   f0100aad <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 28 09 ff ff    	lea    -0xf6d8(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 32 09 00 00       	call   f0100ae4 <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c9:	a8 01                	test   $0x1,%al
f01001cb:	74 0b                	je     f01001d8 <serial_proc_data+0x18>
f01001cd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d3:	0f b6 c0             	movzbl %al,%eax
}
f01001d6:	5d                   	pop    %ebp
f01001d7:	c3                   	ret    
		return -1;
f01001d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001dd:	eb f7                	jmp    f01001d6 <serial_proc_data+0x16>

f01001df <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001df:	55                   	push   %ebp
f01001e0:	89 e5                	mov    %esp,%ebp
f01001e2:	56                   	push   %esi
f01001e3:	53                   	push   %ebx
f01001e4:	e8 d3 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01001e9:	81 c3 1f 11 01 00    	add    $0x1111f,%ebx
f01001ef:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001f1:	ff d6                	call   *%esi
f01001f3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f6:	74 2e                	je     f0100226 <cons_intr+0x47>
		if (c == 0)
f01001f8:	85 c0                	test   %eax,%eax
f01001fa:	74 f5                	je     f01001f1 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001fc:	8b 8b 7c 1f 00 00    	mov    0x1f7c(%ebx),%ecx
f0100202:	8d 51 01             	lea    0x1(%ecx),%edx
f0100205:	89 93 7c 1f 00 00    	mov    %edx,0x1f7c(%ebx)
f010020b:	88 84 0b 78 1d 00 00 	mov    %al,0x1d78(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100212:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100218:	75 d7                	jne    f01001f1 <cons_intr+0x12>
			cons.wpos = 0;
f010021a:	c7 83 7c 1f 00 00 00 	movl   $0x0,0x1f7c(%ebx)
f0100221:	00 00 00 
f0100224:	eb cb                	jmp    f01001f1 <cons_intr+0x12>
	}
}
f0100226:	5b                   	pop    %ebx
f0100227:	5e                   	pop    %esi
f0100228:	5d                   	pop    %ebp
f0100229:	c3                   	ret    

f010022a <kbd_proc_data>:
{
f010022a:	55                   	push   %ebp
f010022b:	89 e5                	mov    %esp,%ebp
f010022d:	56                   	push   %esi
f010022e:	53                   	push   %ebx
f010022f:	e8 88 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100234:	81 c3 d4 10 01 00    	add    $0x110d4,%ebx
f010023a:	ba 64 00 00 00       	mov    $0x64,%edx
f010023f:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100240:	a8 01                	test   $0x1,%al
f0100242:	0f 84 06 01 00 00    	je     f010034e <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f0100248:	a8 20                	test   $0x20,%al
f010024a:	0f 85 05 01 00 00    	jne    f0100355 <kbd_proc_data+0x12b>
f0100250:	ba 60 00 00 00       	mov    $0x60,%edx
f0100255:	ec                   	in     (%dx),%al
f0100256:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100258:	3c e0                	cmp    $0xe0,%al
f010025a:	0f 84 93 00 00 00    	je     f01002f3 <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f0100260:	84 c0                	test   %al,%al
f0100262:	0f 88 a0 00 00 00    	js     f0100308 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100268:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010026e:	f6 c1 40             	test   $0x40,%cl
f0100271:	74 0e                	je     f0100281 <kbd_proc_data+0x57>
		data |= 0x80;
f0100273:	83 c8 80             	or     $0xffffff80,%eax
f0100276:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100278:	83 e1 bf             	and    $0xffffffbf,%ecx
f010027b:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f0100281:	0f b6 d2             	movzbl %dl,%edx
f0100284:	0f b6 84 13 58 0a ff 	movzbl -0xf5a8(%ebx,%edx,1),%eax
f010028b:	ff 
f010028c:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f0100292:	0f b6 8c 13 58 09 ff 	movzbl -0xf6a8(%ebx,%edx,1),%ecx
f0100299:	ff 
f010029a:	31 c8                	xor    %ecx,%eax
f010029c:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002a2:	89 c1                	mov    %eax,%ecx
f01002a4:	83 e1 03             	and    $0x3,%ecx
f01002a7:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002ae:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002b2:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002b5:	a8 08                	test   $0x8,%al
f01002b7:	74 0d                	je     f01002c6 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f01002b9:	89 f2                	mov    %esi,%edx
f01002bb:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002be:	83 f9 19             	cmp    $0x19,%ecx
f01002c1:	77 7a                	ja     f010033d <kbd_proc_data+0x113>
			c += 'A' - 'a';
f01002c3:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002c6:	f7 d0                	not    %eax
f01002c8:	a8 06                	test   $0x6,%al
f01002ca:	75 33                	jne    f01002ff <kbd_proc_data+0xd5>
f01002cc:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002d2:	75 2b                	jne    f01002ff <kbd_proc_data+0xd5>
		cprintf("\01Rebooting!\02\n");
f01002d4:	83 ec 0c             	sub    $0xc,%esp
f01002d7:	8d 83 1c 09 ff ff    	lea    -0xf6e4(%ebx),%eax
f01002dd:	50                   	push   %eax
f01002de:	e8 01 08 00 00       	call   f0100ae4 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e8:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ed:	ee                   	out    %al,(%dx)
f01002ee:	83 c4 10             	add    $0x10,%esp
f01002f1:	eb 0c                	jmp    f01002ff <kbd_proc_data+0xd5>
		shift |= E0ESC;
f01002f3:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002fa:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002ff:	89 f0                	mov    %esi,%eax
f0100301:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100304:	5b                   	pop    %ebx
f0100305:	5e                   	pop    %esi
f0100306:	5d                   	pop    %ebp
f0100307:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100308:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010030e:	89 ce                	mov    %ecx,%esi
f0100310:	83 e6 40             	and    $0x40,%esi
f0100313:	83 e0 7f             	and    $0x7f,%eax
f0100316:	85 f6                	test   %esi,%esi
f0100318:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010031b:	0f b6 d2             	movzbl %dl,%edx
f010031e:	0f b6 84 13 58 0a ff 	movzbl -0xf5a8(%ebx,%edx,1),%eax
f0100325:	ff 
f0100326:	83 c8 40             	or     $0x40,%eax
f0100329:	0f b6 c0             	movzbl %al,%eax
f010032c:	f7 d0                	not    %eax
f010032e:	21 c8                	and    %ecx,%eax
f0100330:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f0100336:	be 00 00 00 00       	mov    $0x0,%esi
f010033b:	eb c2                	jmp    f01002ff <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f010033d:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100340:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100343:	83 fa 1a             	cmp    $0x1a,%edx
f0100346:	0f 42 f1             	cmovb  %ecx,%esi
f0100349:	e9 78 ff ff ff       	jmp    f01002c6 <kbd_proc_data+0x9c>
		return -1;
f010034e:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100353:	eb aa                	jmp    f01002ff <kbd_proc_data+0xd5>
		return -1;
f0100355:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035a:	eb a3                	jmp    f01002ff <kbd_proc_data+0xd5>

f010035c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010035c:	55                   	push   %ebp
f010035d:	89 e5                	mov    %esp,%ebp
f010035f:	57                   	push   %edi
f0100360:	56                   	push   %esi
f0100361:	53                   	push   %ebx
f0100362:	83 ec 1c             	sub    $0x1c,%esp
f0100365:	e8 52 fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010036a:	81 c3 9e 0f 01 00    	add    $0x10f9e,%ebx
f0100370:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100373:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100378:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010037d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100382:	eb 09                	jmp    f010038d <cons_putc+0x31>
f0100384:	89 ca                	mov    %ecx,%edx
f0100386:	ec                   	in     (%dx),%al
f0100387:	ec                   	in     (%dx),%al
f0100388:	ec                   	in     (%dx),%al
f0100389:	ec                   	in     (%dx),%al
	     i++)
f010038a:	83 c6 01             	add    $0x1,%esi
f010038d:	89 fa                	mov    %edi,%edx
f010038f:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100390:	a8 20                	test   $0x20,%al
f0100392:	75 08                	jne    f010039c <cons_putc+0x40>
f0100394:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010039a:	7e e8                	jle    f0100384 <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f010039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010039f:	89 f8                	mov    %edi,%eax
f01003a1:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003a9:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003aa:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003af:	bf 79 03 00 00       	mov    $0x379,%edi
f01003b4:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b9:	eb 09                	jmp    f01003c4 <cons_putc+0x68>
f01003bb:	89 ca                	mov    %ecx,%edx
f01003bd:	ec                   	in     (%dx),%al
f01003be:	ec                   	in     (%dx),%al
f01003bf:	ec                   	in     (%dx),%al
f01003c0:	ec                   	in     (%dx),%al
f01003c1:	83 c6 01             	add    $0x1,%esi
f01003c4:	89 fa                	mov    %edi,%edx
f01003c6:	ec                   	in     (%dx),%al
f01003c7:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003cd:	7f 04                	jg     f01003d3 <cons_putc+0x77>
f01003cf:	84 c0                	test   %al,%al
f01003d1:	79 e8                	jns    f01003bb <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d3:	ba 78 03 00 00       	mov    $0x378,%edx
f01003d8:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003dc:	ee                   	out    %al,(%dx)
f01003dd:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003e7:	ee                   	out    %al,(%dx)
f01003e8:	b8 08 00 00 00       	mov    $0x8,%eax
f01003ed:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003f1:	89 fa                	mov    %edi,%edx
f01003f3:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003f9:	89 f8                	mov    %edi,%eax
f01003fb:	80 cc 07             	or     $0x7,%ah
f01003fe:	85 d2                	test   %edx,%edx
f0100400:	0f 45 c7             	cmovne %edi,%eax
f0100403:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100406:	0f b6 c0             	movzbl %al,%eax
f0100409:	83 f8 09             	cmp    $0x9,%eax
f010040c:	0f 84 b9 00 00 00    	je     f01004cb <cons_putc+0x16f>
f0100412:	83 f8 09             	cmp    $0x9,%eax
f0100415:	7e 74                	jle    f010048b <cons_putc+0x12f>
f0100417:	83 f8 0a             	cmp    $0xa,%eax
f010041a:	0f 84 9e 00 00 00    	je     f01004be <cons_putc+0x162>
f0100420:	83 f8 0d             	cmp    $0xd,%eax
f0100423:	0f 85 d9 00 00 00    	jne    f0100502 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100429:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100430:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100436:	c1 e8 16             	shr    $0x16,%eax
f0100439:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010043c:	c1 e0 04             	shl    $0x4,%eax
f010043f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100446:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010044d:	cf 07 
f010044f:	0f 87 d4 00 00 00    	ja     f0100529 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100455:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f010045b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100460:	89 ca                	mov    %ecx,%edx
f0100462:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100463:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f010046a:	8d 71 01             	lea    0x1(%ecx),%esi
f010046d:	89 d8                	mov    %ebx,%eax
f010046f:	66 c1 e8 08          	shr    $0x8,%ax
f0100473:	89 f2                	mov    %esi,%edx
f0100475:	ee                   	out    %al,(%dx)
f0100476:	b8 0f 00 00 00       	mov    $0xf,%eax
f010047b:	89 ca                	mov    %ecx,%edx
f010047d:	ee                   	out    %al,(%dx)
f010047e:	89 d8                	mov    %ebx,%eax
f0100480:	89 f2                	mov    %esi,%edx
f0100482:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100483:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100486:	5b                   	pop    %ebx
f0100487:	5e                   	pop    %esi
f0100488:	5f                   	pop    %edi
f0100489:	5d                   	pop    %ebp
f010048a:	c3                   	ret    
	switch (c & 0xff) {
f010048b:	83 f8 08             	cmp    $0x8,%eax
f010048e:	75 72                	jne    f0100502 <cons_putc+0x1a6>
		if (crt_pos > 0) {
f0100490:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100497:	66 85 c0             	test   %ax,%ax
f010049a:	74 b9                	je     f0100455 <cons_putc+0xf9>
			crt_pos--;
f010049c:	83 e8 01             	sub    $0x1,%eax
f010049f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a6:	0f b7 c0             	movzwl %ax,%eax
f01004a9:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004ad:	b2 00                	mov    $0x0,%dl
f01004af:	83 ca 20             	or     $0x20,%edx
f01004b2:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f01004b8:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004bc:	eb 88                	jmp    f0100446 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f01004be:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f01004c5:	50 
f01004c6:	e9 5e ff ff ff       	jmp    f0100429 <cons_putc+0xcd>
		cons_putc(' ');
f01004cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d0:	e8 87 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004d5:	b8 20 00 00 00       	mov    $0x20,%eax
f01004da:	e8 7d fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004df:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e4:	e8 73 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004e9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ee:	e8 69 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f8:	e8 5f fe ff ff       	call   f010035c <cons_putc>
f01004fd:	e9 44 ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100502:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100509:	8d 50 01             	lea    0x1(%eax),%edx
f010050c:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100513:	0f b7 c0             	movzwl %ax,%eax
f0100516:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010051c:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100520:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100524:	e9 1d ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100529:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010052f:	83 ec 04             	sub    $0x4,%esp
f0100532:	68 00 0f 00 00       	push   $0xf00
f0100537:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010053d:	52                   	push   %edx
f010053e:	50                   	push   %eax
f010053f:	e8 65 12 00 00       	call   f01017a9 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100544:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010054a:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100550:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100556:	83 c4 10             	add    $0x10,%esp
f0100559:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010055e:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100561:	39 d0                	cmp    %edx,%eax
f0100563:	75 f4                	jne    f0100559 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100565:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010056c:	50 
f010056d:	e9 e3 fe ff ff       	jmp    f0100455 <cons_putc+0xf9>

f0100572 <serial_intr>:
{
f0100572:	e8 e7 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f0100577:	05 91 0d 01 00       	add    $0x10d91,%eax
	if (serial_exists)
f010057c:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100583:	75 02                	jne    f0100587 <serial_intr+0x15>
f0100585:	f3 c3                	repz ret 
{
f0100587:	55                   	push   %ebp
f0100588:	89 e5                	mov    %esp,%ebp
f010058a:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010058d:	8d 80 b8 ee fe ff    	lea    -0x11148(%eax),%eax
f0100593:	e8 47 fc ff ff       	call   f01001df <cons_intr>
}
f0100598:	c9                   	leave  
f0100599:	c3                   	ret    

f010059a <kbd_intr>:
{
f010059a:	55                   	push   %ebp
f010059b:	89 e5                	mov    %esp,%ebp
f010059d:	83 ec 08             	sub    $0x8,%esp
f01005a0:	e8 b9 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f01005a5:	05 63 0d 01 00       	add    $0x10d63,%eax
	cons_intr(kbd_proc_data);
f01005aa:	8d 80 22 ef fe ff    	lea    -0x110de(%eax),%eax
f01005b0:	e8 2a fc ff ff       	call   f01001df <cons_intr>
}
f01005b5:	c9                   	leave  
f01005b6:	c3                   	ret    

f01005b7 <cons_getc>:
{
f01005b7:	55                   	push   %ebp
f01005b8:	89 e5                	mov    %esp,%ebp
f01005ba:	53                   	push   %ebx
f01005bb:	83 ec 04             	sub    $0x4,%esp
f01005be:	e8 f9 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005c3:	81 c3 45 0d 01 00    	add    $0x10d45,%ebx
	serial_intr();
f01005c9:	e8 a4 ff ff ff       	call   f0100572 <serial_intr>
	kbd_intr();
f01005ce:	e8 c7 ff ff ff       	call   f010059a <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005d3:	8b 93 78 1f 00 00    	mov    0x1f78(%ebx),%edx
	return 0;
f01005d9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005de:	3b 93 7c 1f 00 00    	cmp    0x1f7c(%ebx),%edx
f01005e4:	74 19                	je     f01005ff <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
f01005e9:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
f01005ef:	0f b6 84 13 78 1d 00 	movzbl 0x1d78(%ebx,%edx,1),%eax
f01005f6:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005f7:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005fd:	74 06                	je     f0100605 <cons_getc+0x4e>
}
f01005ff:	83 c4 04             	add    $0x4,%esp
f0100602:	5b                   	pop    %ebx
f0100603:	5d                   	pop    %ebp
f0100604:	c3                   	ret    
			cons.rpos = 0;
f0100605:	c7 83 78 1f 00 00 00 	movl   $0x0,0x1f78(%ebx)
f010060c:	00 00 00 
f010060f:	eb ee                	jmp    f01005ff <cons_getc+0x48>

f0100611 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100611:	55                   	push   %ebp
f0100612:	89 e5                	mov    %esp,%ebp
f0100614:	57                   	push   %edi
f0100615:	56                   	push   %esi
f0100616:	53                   	push   %ebx
f0100617:	83 ec 1c             	sub    $0x1c,%esp
f010061a:	e8 9d fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010061f:	81 c3 e9 0c 01 00    	add    $0x10ce9,%ebx
	was = *cp;
f0100625:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010062c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100633:	5a a5 
	if (*cp != 0xA55A) {
f0100635:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010063c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100640:	0f 84 bc 00 00 00    	je     f0100702 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100646:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f010064d:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100650:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100657:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f010065d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100662:	89 fa                	mov    %edi,%edx
f0100664:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100665:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100668:	89 ca                	mov    %ecx,%edx
f010066a:	ec                   	in     (%dx),%al
f010066b:	0f b6 f0             	movzbl %al,%esi
f010066e:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100671:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100676:	89 fa                	mov    %edi,%edx
f0100678:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100679:	89 ca                	mov    %ecx,%edx
f010067b:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010067f:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f0100685:	0f b6 c0             	movzbl %al,%eax
f0100688:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010068a:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100691:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100696:	89 c8                	mov    %ecx,%eax
f0100698:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010069d:	ee                   	out    %al,(%dx)
f010069e:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006a3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a8:	89 fa                	mov    %edi,%edx
f01006aa:	ee                   	out    %al,(%dx)
f01006ab:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006b0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006b5:	ee                   	out    %al,(%dx)
f01006b6:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006bb:	89 c8                	mov    %ecx,%eax
f01006bd:	89 f2                	mov    %esi,%edx
f01006bf:	ee                   	out    %al,(%dx)
f01006c0:	b8 03 00 00 00       	mov    $0x3,%eax
f01006c5:	89 fa                	mov    %edi,%edx
f01006c7:	ee                   	out    %al,(%dx)
f01006c8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006cd:	89 c8                	mov    %ecx,%eax
f01006cf:	ee                   	out    %al,(%dx)
f01006d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01006d5:	89 f2                	mov    %esi,%edx
f01006d7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006dd:	ec                   	in     (%dx),%al
f01006de:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006e0:	3c ff                	cmp    $0xff,%al
f01006e2:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f01006e9:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006ee:	ec                   	in     (%dx),%al
f01006ef:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006f4:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006f5:	80 f9 ff             	cmp    $0xff,%cl
f01006f8:	74 25                	je     f010071f <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006fd:	5b                   	pop    %ebx
f01006fe:	5e                   	pop    %esi
f01006ff:	5f                   	pop    %edi
f0100700:	5d                   	pop    %ebp
f0100701:	c3                   	ret    
		*cp = was;
f0100702:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100709:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f0100710:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100713:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f010071a:	e9 38 ff ff ff       	jmp    f0100657 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f010071f:	83 ec 0c             	sub    $0xc,%esp
f0100722:	8d 83 2a 09 ff ff    	lea    -0xf6d6(%ebx),%eax
f0100728:	50                   	push   %eax
f0100729:	e8 b6 03 00 00       	call   f0100ae4 <cprintf>
f010072e:	83 c4 10             	add    $0x10,%esp
}
f0100731:	eb c7                	jmp    f01006fa <cons_init+0xe9>

f0100733 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100733:	55                   	push   %ebp
f0100734:	89 e5                	mov    %esp,%ebp
f0100736:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100739:	8b 45 08             	mov    0x8(%ebp),%eax
f010073c:	e8 1b fc ff ff       	call   f010035c <cons_putc>
}
f0100741:	c9                   	leave  
f0100742:	c3                   	ret    

f0100743 <getchar>:

int
getchar(void)
{
f0100743:	55                   	push   %ebp
f0100744:	89 e5                	mov    %esp,%ebp
f0100746:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100749:	e8 69 fe ff ff       	call   f01005b7 <cons_getc>
f010074e:	85 c0                	test   %eax,%eax
f0100750:	74 f7                	je     f0100749 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100752:	c9                   	leave  
f0100753:	c3                   	ret    

f0100754 <iscons>:

int
iscons(int fdnum)
{
f0100754:	55                   	push   %ebp
f0100755:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100757:	b8 01 00 00 00       	mov    $0x1,%eax
f010075c:	5d                   	pop    %ebp
f010075d:	c3                   	ret    

f010075e <__x86.get_pc_thunk.ax>:
f010075e:	8b 04 24             	mov    (%esp),%eax
f0100761:	c3                   	ret    

f0100762 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100762:	55                   	push   %ebp
f0100763:	89 e5                	mov    %esp,%ebp
f0100765:	56                   	push   %esi
f0100766:	53                   	push   %ebx
f0100767:	e8 50 fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010076c:	81 c3 9c 0b 01 00    	add    $0x10b9c,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100772:	83 ec 04             	sub    $0x4,%esp
f0100775:	8d 83 58 0b ff ff    	lea    -0xf4a8(%ebx),%eax
f010077b:	50                   	push   %eax
f010077c:	8d 83 76 0b ff ff    	lea    -0xf48a(%ebx),%eax
f0100782:	50                   	push   %eax
f0100783:	8d b3 7b 0b ff ff    	lea    -0xf485(%ebx),%esi
f0100789:	56                   	push   %esi
f010078a:	e8 55 03 00 00       	call   f0100ae4 <cprintf>
f010078f:	83 c4 0c             	add    $0xc,%esp
f0100792:	8d 83 18 0c ff ff    	lea    -0xf3e8(%ebx),%eax
f0100798:	50                   	push   %eax
f0100799:	8d 83 84 0b ff ff    	lea    -0xf47c(%ebx),%eax
f010079f:	50                   	push   %eax
f01007a0:	56                   	push   %esi
f01007a1:	e8 3e 03 00 00       	call   f0100ae4 <cprintf>
f01007a6:	83 c4 0c             	add    $0xc,%esp
f01007a9:	8d 83 40 0c ff ff    	lea    -0xf3c0(%ebx),%eax
f01007af:	50                   	push   %eax
f01007b0:	8d 83 8d 0b ff ff    	lea    -0xf473(%ebx),%eax
f01007b6:	50                   	push   %eax
f01007b7:	56                   	push   %esi
f01007b8:	e8 27 03 00 00       	call   f0100ae4 <cprintf>
	return 0;
}
f01007bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01007c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007c5:	5b                   	pop    %ebx
f01007c6:	5e                   	pop    %esi
f01007c7:	5d                   	pop    %ebp
f01007c8:	c3                   	ret    

f01007c9 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007c9:	55                   	push   %ebp
f01007ca:	89 e5                	mov    %esp,%ebp
f01007cc:	57                   	push   %edi
f01007cd:	56                   	push   %esi
f01007ce:	53                   	push   %ebx
f01007cf:	83 ec 18             	sub    $0x18,%esp
f01007d2:	e8 e5 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007d7:	81 c3 31 0b 01 00    	add    $0x10b31,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007dd:	8d 83 97 0b ff ff    	lea    -0xf469(%ebx),%eax
f01007e3:	50                   	push   %eax
f01007e4:	e8 fb 02 00 00       	call   f0100ae4 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007e9:	83 c4 08             	add    $0x8,%esp
f01007ec:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007f2:	8d 83 70 0c ff ff    	lea    -0xf390(%ebx),%eax
f01007f8:	50                   	push   %eax
f01007f9:	e8 e6 02 00 00       	call   f0100ae4 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007fe:	83 c4 0c             	add    $0xc,%esp
f0100801:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f0100807:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f010080d:	50                   	push   %eax
f010080e:	57                   	push   %edi
f010080f:	8d 83 98 0c ff ff    	lea    -0xf368(%ebx),%eax
f0100815:	50                   	push   %eax
f0100816:	e8 c9 02 00 00       	call   f0100ae4 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010081b:	83 c4 0c             	add    $0xc,%esp
f010081e:	c7 c0 99 1b 10 f0    	mov    $0xf0101b99,%eax
f0100824:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010082a:	52                   	push   %edx
f010082b:	50                   	push   %eax
f010082c:	8d 83 bc 0c ff ff    	lea    -0xf344(%ebx),%eax
f0100832:	50                   	push   %eax
f0100833:	e8 ac 02 00 00       	call   f0100ae4 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100838:	83 c4 0c             	add    $0xc,%esp
f010083b:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f0100841:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100847:	52                   	push   %edx
f0100848:	50                   	push   %eax
f0100849:	8d 83 e0 0c ff ff    	lea    -0xf320(%ebx),%eax
f010084f:	50                   	push   %eax
f0100850:	e8 8f 02 00 00       	call   f0100ae4 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100855:	83 c4 0c             	add    $0xc,%esp
f0100858:	c7 c6 a0 36 11 f0    	mov    $0xf01136a0,%esi
f010085e:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100864:	50                   	push   %eax
f0100865:	56                   	push   %esi
f0100866:	8d 83 04 0d ff ff    	lea    -0xf2fc(%ebx),%eax
f010086c:	50                   	push   %eax
f010086d:	e8 72 02 00 00       	call   f0100ae4 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100872:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100875:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f010087b:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f010087d:	c1 fe 0a             	sar    $0xa,%esi
f0100880:	56                   	push   %esi
f0100881:	8d 83 28 0d ff ff    	lea    -0xf2d8(%ebx),%eax
f0100887:	50                   	push   %eax
f0100888:	e8 57 02 00 00       	call   f0100ae4 <cprintf>
	return 0;
}
f010088d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100892:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100895:	5b                   	pop    %ebx
f0100896:	5e                   	pop    %esi
f0100897:	5f                   	pop    %edi
f0100898:	5d                   	pop    %ebp
f0100899:	c3                   	ret    

f010089a <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010089a:	55                   	push   %ebp
f010089b:	89 e5                	mov    %esp,%ebp
f010089d:	57                   	push   %edi
f010089e:	56                   	push   %esi
f010089f:	53                   	push   %ebx
f01008a0:	83 ec 48             	sub    $0x48,%esp
f01008a3:	e8 14 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01008a8:	81 c3 60 0a 01 00    	add    $0x10a60,%ebx
	cprintf("Stack backtrace: \n");
f01008ae:	8d 83 b0 0b ff ff    	lea    -0xf450(%ebx),%eax
f01008b4:	50                   	push   %eax
f01008b5:	e8 2a 02 00 00       	call   f0100ae4 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ba:	89 ee                	mov    %ebp,%esi
	int* p = (int*)read_ebp();	
	while (p) {
f01008bc:	83 c4 10             	add    $0x10,%esp
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", p, *(p+1), *(p+2), *(p+3), *(p+4), *(p+5), *(p+6));
f01008bf:	8d bb 54 0d ff ff    	lea    -0xf2ac(%ebx),%edi
		struct Eipdebuginfo info;
		debuginfo_eip(*(p+1), &info) != -1;
f01008c5:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008c8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	while (p) {
f01008cb:	eb 4e                	jmp    f010091b <mon_backtrace+0x81>
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", p, *(p+1), *(p+2), *(p+3), *(p+4), *(p+5), *(p+6));
f01008cd:	ff 76 18             	pushl  0x18(%esi)
f01008d0:	ff 76 14             	pushl  0x14(%esi)
f01008d3:	ff 76 10             	pushl  0x10(%esi)
f01008d6:	ff 76 0c             	pushl  0xc(%esi)
f01008d9:	ff 76 08             	pushl  0x8(%esi)
f01008dc:	ff 76 04             	pushl  0x4(%esi)
f01008df:	56                   	push   %esi
f01008e0:	57                   	push   %edi
f01008e1:	e8 fe 01 00 00       	call   f0100ae4 <cprintf>
		debuginfo_eip(*(p+1), &info) != -1;
f01008e6:	83 c4 18             	add    $0x18,%esp
f01008e9:	ff 75 c4             	pushl  -0x3c(%ebp)
f01008ec:	ff 76 04             	pushl  0x4(%esi)
f01008ef:	e8 f4 02 00 00       	call   f0100be8 <debuginfo_eip>
		cprintf("       %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, *(p+1)-info.eip_fn_addr);
f01008f4:	83 c4 08             	add    $0x8,%esp
f01008f7:	8b 46 04             	mov    0x4(%esi),%eax
f01008fa:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01008fd:	50                   	push   %eax
f01008fe:	ff 75 d8             	pushl  -0x28(%ebp)
f0100901:	ff 75 dc             	pushl  -0x24(%ebp)
f0100904:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100907:	ff 75 d0             	pushl  -0x30(%ebp)
f010090a:	8d 83 c3 0b ff ff    	lea    -0xf43d(%ebx),%eax
f0100910:	50                   	push   %eax
f0100911:	e8 ce 01 00 00       	call   f0100ae4 <cprintf>
		p = (int*) *p;		
f0100916:	8b 36                	mov    (%esi),%esi
f0100918:	83 c4 20             	add    $0x20,%esp
	while (p) {
f010091b:	85 f6                	test   %esi,%esi
f010091d:	75 ae                	jne    f01008cd <mon_backtrace+0x33>
	}
	return 0;
}
f010091f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100924:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100927:	5b                   	pop    %ebx
f0100928:	5e                   	pop    %esi
f0100929:	5f                   	pop    %edi
f010092a:	5d                   	pop    %ebp
f010092b:	c3                   	ret    

f010092c <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010092c:	55                   	push   %ebp
f010092d:	89 e5                	mov    %esp,%ebp
f010092f:	57                   	push   %edi
f0100930:	56                   	push   %esi
f0100931:	53                   	push   %ebx
f0100932:	83 ec 68             	sub    $0x68,%esp
f0100935:	e8 82 f8 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010093a:	81 c3 ce 09 01 00    	add    $0x109ce,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100940:	8d 83 8c 0d ff ff    	lea    -0xf274(%ebx),%eax
f0100946:	50                   	push   %eax
f0100947:	e8 98 01 00 00       	call   f0100ae4 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010094c:	8d 83 b0 0d ff ff    	lea    -0xf250(%ebx),%eax
f0100952:	89 04 24             	mov    %eax,(%esp)
f0100955:	e8 8a 01 00 00       	call   f0100ae4 <cprintf>
f010095a:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010095d:	8d bb de 0b ff ff    	lea    -0xf422(%ebx),%edi
f0100963:	eb 4a                	jmp    f01009af <monitor+0x83>
f0100965:	83 ec 08             	sub    $0x8,%esp
f0100968:	0f be c0             	movsbl %al,%eax
f010096b:	50                   	push   %eax
f010096c:	57                   	push   %edi
f010096d:	e8 ad 0d 00 00       	call   f010171f <strchr>
f0100972:	83 c4 10             	add    $0x10,%esp
f0100975:	85 c0                	test   %eax,%eax
f0100977:	74 08                	je     f0100981 <monitor+0x55>
			*buf++ = 0;
f0100979:	c6 06 00             	movb   $0x0,(%esi)
f010097c:	8d 76 01             	lea    0x1(%esi),%esi
f010097f:	eb 79                	jmp    f01009fa <monitor+0xce>
		if (*buf == 0)
f0100981:	80 3e 00             	cmpb   $0x0,(%esi)
f0100984:	74 7f                	je     f0100a05 <monitor+0xd9>
		if (argc == MAXARGS-1) {
f0100986:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f010098a:	74 0f                	je     f010099b <monitor+0x6f>
		argv[argc++] = buf;
f010098c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010098f:	8d 48 01             	lea    0x1(%eax),%ecx
f0100992:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100995:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f0100999:	eb 44                	jmp    f01009df <monitor+0xb3>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010099b:	83 ec 08             	sub    $0x8,%esp
f010099e:	6a 10                	push   $0x10
f01009a0:	8d 83 e3 0b ff ff    	lea    -0xf41d(%ebx),%eax
f01009a6:	50                   	push   %eax
f01009a7:	e8 38 01 00 00       	call   f0100ae4 <cprintf>
f01009ac:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01009af:	8d 83 da 0b ff ff    	lea    -0xf426(%ebx),%eax
f01009b5:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01009b8:	83 ec 0c             	sub    $0xc,%esp
f01009bb:	ff 75 a4             	pushl  -0x5c(%ebp)
f01009be:	e8 24 0b 00 00       	call   f01014e7 <readline>
f01009c3:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01009c5:	83 c4 10             	add    $0x10,%esp
f01009c8:	85 c0                	test   %eax,%eax
f01009ca:	74 ec                	je     f01009b8 <monitor+0x8c>
	argv[argc] = 0;
f01009cc:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009d3:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01009da:	eb 1e                	jmp    f01009fa <monitor+0xce>
			buf++;
f01009dc:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009df:	0f b6 06             	movzbl (%esi),%eax
f01009e2:	84 c0                	test   %al,%al
f01009e4:	74 14                	je     f01009fa <monitor+0xce>
f01009e6:	83 ec 08             	sub    $0x8,%esp
f01009e9:	0f be c0             	movsbl %al,%eax
f01009ec:	50                   	push   %eax
f01009ed:	57                   	push   %edi
f01009ee:	e8 2c 0d 00 00       	call   f010171f <strchr>
f01009f3:	83 c4 10             	add    $0x10,%esp
f01009f6:	85 c0                	test   %eax,%eax
f01009f8:	74 e2                	je     f01009dc <monitor+0xb0>
		while (*buf && strchr(WHITESPACE, *buf))
f01009fa:	0f b6 06             	movzbl (%esi),%eax
f01009fd:	84 c0                	test   %al,%al
f01009ff:	0f 85 60 ff ff ff    	jne    f0100965 <monitor+0x39>
	argv[argc] = 0;
f0100a05:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a08:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a0f:	00 
	if (argc == 0)
f0100a10:	85 c0                	test   %eax,%eax
f0100a12:	74 9b                	je     f01009af <monitor+0x83>
f0100a14:	8d b3 18 1d 00 00    	lea    0x1d18(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a1a:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%ebp)
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a21:	83 ec 08             	sub    $0x8,%esp
f0100a24:	ff 36                	pushl  (%esi)
f0100a26:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a29:	e8 93 0c 00 00       	call   f01016c1 <strcmp>
f0100a2e:	83 c4 10             	add    $0x10,%esp
f0100a31:	85 c0                	test   %eax,%eax
f0100a33:	74 29                	je     f0100a5e <monitor+0x132>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a35:	83 45 a0 01          	addl   $0x1,-0x60(%ebp)
f0100a39:	8b 45 a0             	mov    -0x60(%ebp),%eax
f0100a3c:	83 c6 0c             	add    $0xc,%esi
f0100a3f:	83 f8 03             	cmp    $0x3,%eax
f0100a42:	75 dd                	jne    f0100a21 <monitor+0xf5>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a44:	83 ec 08             	sub    $0x8,%esp
f0100a47:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a4a:	8d 83 00 0c ff ff    	lea    -0xf400(%ebx),%eax
f0100a50:	50                   	push   %eax
f0100a51:	e8 8e 00 00 00       	call   f0100ae4 <cprintf>
f0100a56:	83 c4 10             	add    $0x10,%esp
f0100a59:	e9 51 ff ff ff       	jmp    f01009af <monitor+0x83>
			return commands[i].func(argc, argv, tf);
f0100a5e:	83 ec 04             	sub    $0x4,%esp
f0100a61:	8b 45 a0             	mov    -0x60(%ebp),%eax
f0100a64:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a67:	ff 75 08             	pushl  0x8(%ebp)
f0100a6a:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a6d:	52                   	push   %edx
f0100a6e:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100a71:	ff 94 83 20 1d 00 00 	call   *0x1d20(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a78:	83 c4 10             	add    $0x10,%esp
f0100a7b:	85 c0                	test   %eax,%eax
f0100a7d:	0f 89 2c ff ff ff    	jns    f01009af <monitor+0x83>
				break;
	}
}
f0100a83:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a86:	5b                   	pop    %ebx
f0100a87:	5e                   	pop    %esi
f0100a88:	5f                   	pop    %edi
f0100a89:	5d                   	pop    %ebp
f0100a8a:	c3                   	ret    

f0100a8b <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100a8b:	55                   	push   %ebp
f0100a8c:	89 e5                	mov    %esp,%ebp
f0100a8e:	53                   	push   %ebx
f0100a8f:	83 ec 10             	sub    $0x10,%esp
f0100a92:	e8 25 f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100a97:	81 c3 71 08 01 00    	add    $0x10871,%ebx
	cputchar(ch);
f0100a9d:	ff 75 08             	pushl  0x8(%ebp)
f0100aa0:	e8 8e fc ff ff       	call   f0100733 <cputchar>
	*cnt++;
}
f0100aa5:	83 c4 10             	add    $0x10,%esp
f0100aa8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100aab:	c9                   	leave  
f0100aac:	c3                   	ret    

f0100aad <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100aad:	55                   	push   %ebp
f0100aae:	89 e5                	mov    %esp,%ebp
f0100ab0:	53                   	push   %ebx
f0100ab1:	83 ec 14             	sub    $0x14,%esp
f0100ab4:	e8 03 f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100ab9:	81 c3 4f 08 01 00    	add    $0x1084f,%ebx
	int cnt = 0;
f0100abf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100ac6:	ff 75 0c             	pushl  0xc(%ebp)
f0100ac9:	ff 75 08             	pushl  0x8(%ebp)
f0100acc:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100acf:	50                   	push   %eax
f0100ad0:	8d 83 83 f7 fe ff    	lea    -0x1087d(%ebx),%eax
f0100ad6:	50                   	push   %eax
f0100ad7:	e8 c9 04 00 00       	call   f0100fa5 <vprintfmt>
	return cnt;
}
f0100adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100adf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ae2:	c9                   	leave  
f0100ae3:	c3                   	ret    

f0100ae4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100ae4:	55                   	push   %ebp
f0100ae5:	89 e5                	mov    %esp,%ebp
f0100ae7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100aea:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100aed:	50                   	push   %eax
f0100aee:	ff 75 08             	pushl  0x8(%ebp)
f0100af1:	e8 b7 ff ff ff       	call   f0100aad <vcprintf>
	va_end(ap);

	return cnt;
}
f0100af6:	c9                   	leave  
f0100af7:	c3                   	ret    

f0100af8 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100af8:	55                   	push   %ebp
f0100af9:	89 e5                	mov    %esp,%ebp
f0100afb:	57                   	push   %edi
f0100afc:	56                   	push   %esi
f0100afd:	53                   	push   %ebx
f0100afe:	83 ec 14             	sub    $0x14,%esp
f0100b01:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b04:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b07:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b0a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b0d:	8b 32                	mov    (%edx),%esi
f0100b0f:	8b 01                	mov    (%ecx),%eax
f0100b11:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b14:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b1b:	eb 2f                	jmp    f0100b4c <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100b1d:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b20:	39 c6                	cmp    %eax,%esi
f0100b22:	7f 49                	jg     f0100b6d <stab_binsearch+0x75>
f0100b24:	0f b6 0a             	movzbl (%edx),%ecx
f0100b27:	83 ea 0c             	sub    $0xc,%edx
f0100b2a:	39 f9                	cmp    %edi,%ecx
f0100b2c:	75 ef                	jne    f0100b1d <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b2e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b31:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b34:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b38:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b3b:	73 35                	jae    f0100b72 <stab_binsearch+0x7a>
			*region_left = m;
f0100b3d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b40:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100b42:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0100b45:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100b4c:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100b4f:	7f 4e                	jg     f0100b9f <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0100b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b54:	01 f0                	add    %esi,%eax
f0100b56:	89 c3                	mov    %eax,%ebx
f0100b58:	c1 eb 1f             	shr    $0x1f,%ebx
f0100b5b:	01 c3                	add    %eax,%ebx
f0100b5d:	d1 fb                	sar    %ebx
f0100b5f:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b62:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b65:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100b69:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b6b:	eb b3                	jmp    f0100b20 <stab_binsearch+0x28>
			l = true_m + 1;
f0100b6d:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100b70:	eb da                	jmp    f0100b4c <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100b72:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b75:	76 14                	jbe    f0100b8b <stab_binsearch+0x93>
			*region_right = m - 1;
f0100b77:	83 e8 01             	sub    $0x1,%eax
f0100b7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b7d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100b80:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100b82:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b89:	eb c1                	jmp    f0100b4c <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100b8b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b8e:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100b90:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100b94:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100b96:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b9d:	eb ad                	jmp    f0100b4c <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100b9f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100ba3:	74 16                	je     f0100bbb <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ba5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ba8:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100baa:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bad:	8b 0e                	mov    (%esi),%ecx
f0100baf:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bb2:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100bb5:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100bb9:	eb 12                	jmp    f0100bcd <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0100bbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bbe:	8b 00                	mov    (%eax),%eax
f0100bc0:	83 e8 01             	sub    $0x1,%eax
f0100bc3:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100bc6:	89 07                	mov    %eax,(%edi)
f0100bc8:	eb 16                	jmp    f0100be0 <stab_binsearch+0xe8>
		     l--)
f0100bca:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100bcd:	39 c1                	cmp    %eax,%ecx
f0100bcf:	7d 0a                	jge    f0100bdb <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0100bd1:	0f b6 1a             	movzbl (%edx),%ebx
f0100bd4:	83 ea 0c             	sub    $0xc,%edx
f0100bd7:	39 fb                	cmp    %edi,%ebx
f0100bd9:	75 ef                	jne    f0100bca <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0100bdb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100bde:	89 07                	mov    %eax,(%edi)
	}
}
f0100be0:	83 c4 14             	add    $0x14,%esp
f0100be3:	5b                   	pop    %ebx
f0100be4:	5e                   	pop    %esi
f0100be5:	5f                   	pop    %edi
f0100be6:	5d                   	pop    %ebp
f0100be7:	c3                   	ret    

f0100be8 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100be8:	55                   	push   %ebp
f0100be9:	89 e5                	mov    %esp,%ebp
f0100beb:	57                   	push   %edi
f0100bec:	56                   	push   %esi
f0100bed:	53                   	push   %ebx
f0100bee:	83 ec 3c             	sub    $0x3c,%esp
f0100bf1:	e8 c6 f5 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100bf6:	81 c3 12 07 01 00    	add    $0x10712,%ebx
f0100bfc:	8b 75 08             	mov    0x8(%ebp),%esi
f0100bff:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c02:	8d 83 d8 0d ff ff    	lea    -0xf228(%ebx),%eax
f0100c08:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0100c0a:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0100c11:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f0100c14:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0100c1b:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f0100c1e:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c25:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100c2b:	0f 86 58 01 00 00    	jbe    f0100d89 <debuginfo_eip+0x1a1>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c31:	c7 c0 89 60 10 f0    	mov    $0xf0106089,%eax
f0100c37:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100c3d:	0f 86 2e 02 00 00    	jbe    f0100e71 <debuginfo_eip+0x289>
f0100c43:	c7 c0 06 7a 10 f0    	mov    $0xf0107a06,%eax
f0100c49:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100c4d:	0f 85 25 02 00 00    	jne    f0100e78 <debuginfo_eip+0x290>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c53:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c5a:	c7 c0 fc 22 10 f0    	mov    $0xf01022fc,%eax
f0100c60:	c7 c2 88 60 10 f0    	mov    $0xf0106088,%edx
f0100c66:	29 c2                	sub    %eax,%edx
f0100c68:	c1 fa 02             	sar    $0x2,%edx
f0100c6b:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100c71:	83 ea 01             	sub    $0x1,%edx
f0100c74:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100c77:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100c7a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100c7d:	83 ec 08             	sub    $0x8,%esp
f0100c80:	56                   	push   %esi
f0100c81:	6a 64                	push   $0x64
f0100c83:	e8 70 fe ff ff       	call   f0100af8 <stab_binsearch>
	if (lfile == 0)
f0100c88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c8b:	83 c4 10             	add    $0x10,%esp
f0100c8e:	85 c0                	test   %eax,%eax
f0100c90:	0f 84 e9 01 00 00    	je     f0100e7f <debuginfo_eip+0x297>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100c96:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100c99:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c9c:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100c9f:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100ca2:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ca5:	83 ec 08             	sub    $0x8,%esp
f0100ca8:	56                   	push   %esi
f0100ca9:	6a 24                	push   $0x24
f0100cab:	c7 c0 fc 22 10 f0    	mov    $0xf01022fc,%eax
f0100cb1:	e8 42 fe ff ff       	call   f0100af8 <stab_binsearch>

	if (lfun <= rfun) {
f0100cb6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cb9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100cbc:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100cbf:	83 c4 10             	add    $0x10,%esp
f0100cc2:	39 c8                	cmp    %ecx,%eax
f0100cc4:	0f 8f d7 00 00 00    	jg     f0100da1 <debuginfo_eip+0x1b9>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100cca:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100ccd:	c7 c1 fc 22 10 f0    	mov    $0xf01022fc,%ecx
f0100cd3:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100cd6:	8b 11                	mov    (%ecx),%edx
f0100cd8:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0100cdb:	c7 c2 06 7a 10 f0    	mov    $0xf0107a06,%edx
f0100ce1:	81 ea 89 60 10 f0    	sub    $0xf0106089,%edx
f0100ce7:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f0100cea:	73 0c                	jae    f0100cf8 <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100cec:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100cef:	81 c2 89 60 10 f0    	add    $0xf0106089,%edx
f0100cf5:	89 57 08             	mov    %edx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100cf8:	8b 51 08             	mov    0x8(%ecx),%edx
f0100cfb:	89 57 10             	mov    %edx,0x10(%edi)
		addr -= info->eip_fn_addr;
f0100cfe:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100d00:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100d03:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100d06:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d09:	83 ec 08             	sub    $0x8,%esp
f0100d0c:	6a 3a                	push   $0x3a
f0100d0e:	ff 77 08             	pushl  0x8(%edi)
f0100d11:	e8 2a 0a 00 00       	call   f0101740 <strfind>
f0100d16:	2b 47 08             	sub    0x8(%edi),%eax
f0100d19:	89 47 0c             	mov    %eax,0xc(%edi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100d1c:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100d1f:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100d22:	83 c4 08             	add    $0x8,%esp
f0100d25:	56                   	push   %esi
f0100d26:	6a 44                	push   $0x44
f0100d28:	c7 c0 fc 22 10 f0    	mov    $0xf01022fc,%eax
f0100d2e:	e8 c5 fd ff ff       	call   f0100af8 <stab_binsearch>
	int lline_tmp = lline;
f0100d33:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	if (rline < lline_tmp)
f0100d36:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100d39:	83 c4 10             	add    $0x10,%esp
f0100d3c:	39 c6                	cmp    %eax,%esi
f0100d3e:	0f 8c 42 01 00 00    	jl     f0100e86 <debuginfo_eip+0x29e>
f0100d44:	89 c1                	mov    %eax,%ecx
f0100d46:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d49:	c1 e2 02             	shl    $0x2,%edx
f0100d4c:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0100d4f:	81 c2 fc 22 10 f0    	add    $0xf01022fc,%edx
		return -1;
	while (lline_tmp <= rline) {
		if (stabs[lline_tmp].n_type == N_SLINE) {
f0100d55:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0100d58:	80 7a 04 44          	cmpb   $0x44,0x4(%edx)
f0100d5c:	74 57                	je     f0100db5 <debuginfo_eip+0x1cd>
			info->eip_line = stabs[lline_tmp].n_desc;
			break;
		}
		if (rline == lline_tmp) {
f0100d5e:	39 c6                	cmp    %eax,%esi
f0100d60:	0f 84 27 01 00 00    	je     f0100e8d <debuginfo_eip+0x2a5>
			return -1;
		}
		lline_tmp++;
f0100d66:	83 c0 01             	add    $0x1,%eax
f0100d69:	83 c2 0c             	add    $0xc,%edx
	while (lline_tmp <= rline) {
f0100d6c:	39 c6                	cmp    %eax,%esi
f0100d6e:	7d e5                	jge    f0100d55 <debuginfo_eip+0x16d>
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d70:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100d73:	c7 c0 fc 22 10 f0    	mov    $0xf01022fc,%eax
f0100d79:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100d7c:	8d 44 02 04          	lea    0x4(%edx,%eax,1),%eax
f0100d80:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0100d84:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0100d87:	eb 3f                	jmp    f0100dc8 <debuginfo_eip+0x1e0>
  	        panic("User address");
f0100d89:	83 ec 04             	sub    $0x4,%esp
f0100d8c:	8d 83 e2 0d ff ff    	lea    -0xf21e(%ebx),%eax
f0100d92:	50                   	push   %eax
f0100d93:	6a 7f                	push   $0x7f
f0100d95:	8d 83 ef 0d ff ff    	lea    -0xf211(%ebx),%eax
f0100d9b:	50                   	push   %eax
f0100d9c:	e8 65 f3 ff ff       	call   f0100106 <_panic>
		info->eip_fn_addr = addr;
f0100da1:	89 77 10             	mov    %esi,0x10(%edi)
		lline = lfile;
f0100da4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100da7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100daa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100dad:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100db0:	e9 54 ff ff ff       	jmp    f0100d09 <debuginfo_eip+0x121>
			info->eip_line = stabs[lline_tmp].n_desc;
f0100db5:	0f b7 42 06          	movzwl 0x6(%edx),%eax
f0100db9:	89 47 04             	mov    %eax,0x4(%edi)
			break;
f0100dbc:	eb b2                	jmp    f0100d70 <debuginfo_eip+0x188>
f0100dbe:	83 e9 01             	sub    $0x1,%ecx
f0100dc1:	83 e8 0c             	sub    $0xc,%eax
f0100dc4:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0100dc8:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	while (lline >= lfile
f0100dcb:	39 ce                	cmp    %ecx,%esi
f0100dcd:	7f 24                	jg     f0100df3 <debuginfo_eip+0x20b>
	       && stabs[lline].n_type != N_SOL
f0100dcf:	0f b6 10             	movzbl (%eax),%edx
f0100dd2:	80 fa 84             	cmp    $0x84,%dl
f0100dd5:	74 46                	je     f0100e1d <debuginfo_eip+0x235>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100dd7:	80 fa 64             	cmp    $0x64,%dl
f0100dda:	75 e2                	jne    f0100dbe <debuginfo_eip+0x1d6>
f0100ddc:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100de0:	74 dc                	je     f0100dbe <debuginfo_eip+0x1d6>
f0100de2:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100de5:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100de9:	74 3b                	je     f0100e26 <debuginfo_eip+0x23e>
f0100deb:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100dee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100df1:	eb 33                	jmp    f0100e26 <debuginfo_eip+0x23e>
f0100df3:	8b 7d 0c             	mov    0xc(%ebp),%edi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100df6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100df9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100dfc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100e01:	39 f2                	cmp    %esi,%edx
f0100e03:	0f 8d 89 00 00 00    	jge    f0100e92 <debuginfo_eip+0x2aa>
		for (lline = lfun + 1;
f0100e09:	83 c2 01             	add    $0x1,%edx
f0100e0c:	89 d0                	mov    %edx,%eax
f0100e0e:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0100e11:	c7 c2 fc 22 10 f0    	mov    $0xf01022fc,%edx
f0100e17:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100e1b:	eb 3b                	jmp    f0100e58 <debuginfo_eip+0x270>
f0100e1d:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100e20:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100e24:	75 26                	jne    f0100e4c <debuginfo_eip+0x264>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e26:	8d 14 49             	lea    (%ecx,%ecx,2),%edx
f0100e29:	c7 c0 fc 22 10 f0    	mov    $0xf01022fc,%eax
f0100e2f:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100e32:	c7 c0 06 7a 10 f0    	mov    $0xf0107a06,%eax
f0100e38:	81 e8 89 60 10 f0    	sub    $0xf0106089,%eax
f0100e3e:	39 c2                	cmp    %eax,%edx
f0100e40:	73 b4                	jae    f0100df6 <debuginfo_eip+0x20e>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e42:	81 c2 89 60 10 f0    	add    $0xf0106089,%edx
f0100e48:	89 17                	mov    %edx,(%edi)
f0100e4a:	eb aa                	jmp    f0100df6 <debuginfo_eip+0x20e>
f0100e4c:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100e4f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100e52:	eb d2                	jmp    f0100e26 <debuginfo_eip+0x23e>
			info->eip_fn_narg++;
f0100e54:	83 47 14 01          	addl   $0x1,0x14(%edi)
		for (lline = lfun + 1;
f0100e58:	39 c6                	cmp    %eax,%esi
f0100e5a:	7e 3e                	jle    f0100e9a <debuginfo_eip+0x2b2>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e5c:	0f b6 0a             	movzbl (%edx),%ecx
f0100e5f:	83 c0 01             	add    $0x1,%eax
f0100e62:	83 c2 0c             	add    $0xc,%edx
f0100e65:	80 f9 a0             	cmp    $0xa0,%cl
f0100e68:	74 ea                	je     f0100e54 <debuginfo_eip+0x26c>
	return 0;
f0100e6a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e6f:	eb 21                	jmp    f0100e92 <debuginfo_eip+0x2aa>
		return -1;
f0100e71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e76:	eb 1a                	jmp    f0100e92 <debuginfo_eip+0x2aa>
f0100e78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e7d:	eb 13                	jmp    f0100e92 <debuginfo_eip+0x2aa>
		return -1;
f0100e7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e84:	eb 0c                	jmp    f0100e92 <debuginfo_eip+0x2aa>
		return -1;
f0100e86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e8b:	eb 05                	jmp    f0100e92 <debuginfo_eip+0x2aa>
			return -1;
f0100e8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100e92:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e95:	5b                   	pop    %ebx
f0100e96:	5e                   	pop    %esi
f0100e97:	5f                   	pop    %edi
f0100e98:	5d                   	pop    %ebp
f0100e99:	c3                   	ret    
	return 0;
f0100e9a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e9f:	eb f1                	jmp    f0100e92 <debuginfo_eip+0x2aa>

f0100ea1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ea1:	55                   	push   %ebp
f0100ea2:	89 e5                	mov    %esp,%ebp
f0100ea4:	57                   	push   %edi
f0100ea5:	56                   	push   %esi
f0100ea6:	53                   	push   %ebx
f0100ea7:	83 ec 2c             	sub    $0x2c,%esp
f0100eaa:	e8 34 06 00 00       	call   f01014e3 <__x86.get_pc_thunk.cx>
f0100eaf:	81 c1 59 04 01 00    	add    $0x10459,%ecx
f0100eb5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100eb8:	89 c7                	mov    %eax,%edi
f0100eba:	89 d6                	mov    %edx,%esi
f0100ebc:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ebf:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ec2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100ec5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100ec8:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100ecb:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ed0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0100ed3:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0100ed6:	39 d3                	cmp    %edx,%ebx
f0100ed8:	72 09                	jb     f0100ee3 <printnum+0x42>
f0100eda:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100edd:	0f 87 83 00 00 00    	ja     f0100f66 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100ee3:	83 ec 0c             	sub    $0xc,%esp
f0100ee6:	ff 75 18             	pushl  0x18(%ebp)
f0100ee9:	8b 45 14             	mov    0x14(%ebp),%eax
f0100eec:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100eef:	53                   	push   %ebx
f0100ef0:	ff 75 10             	pushl  0x10(%ebp)
f0100ef3:	83 ec 08             	sub    $0x8,%esp
f0100ef6:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ef9:	ff 75 d8             	pushl  -0x28(%ebp)
f0100efc:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100eff:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f02:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100f05:	e8 56 0a 00 00       	call   f0101960 <__udivdi3>
f0100f0a:	83 c4 18             	add    $0x18,%esp
f0100f0d:	52                   	push   %edx
f0100f0e:	50                   	push   %eax
f0100f0f:	89 f2                	mov    %esi,%edx
f0100f11:	89 f8                	mov    %edi,%eax
f0100f13:	e8 89 ff ff ff       	call   f0100ea1 <printnum>
f0100f18:	83 c4 20             	add    $0x20,%esp
f0100f1b:	eb 13                	jmp    f0100f30 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100f1d:	83 ec 08             	sub    $0x8,%esp
f0100f20:	56                   	push   %esi
f0100f21:	ff 75 18             	pushl  0x18(%ebp)
f0100f24:	ff d7                	call   *%edi
f0100f26:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100f29:	83 eb 01             	sub    $0x1,%ebx
f0100f2c:	85 db                	test   %ebx,%ebx
f0100f2e:	7f ed                	jg     f0100f1d <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100f30:	83 ec 08             	sub    $0x8,%esp
f0100f33:	56                   	push   %esi
f0100f34:	83 ec 04             	sub    $0x4,%esp
f0100f37:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f3a:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f3d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f40:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f43:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100f46:	89 f3                	mov    %esi,%ebx
f0100f48:	e8 33 0b 00 00       	call   f0101a80 <__umoddi3>
f0100f4d:	83 c4 14             	add    $0x14,%esp
f0100f50:	0f be 84 06 fd 0d ff 	movsbl -0xf203(%esi,%eax,1),%eax
f0100f57:	ff 
f0100f58:	50                   	push   %eax
f0100f59:	ff d7                	call   *%edi
}
f0100f5b:	83 c4 10             	add    $0x10,%esp
f0100f5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f61:	5b                   	pop    %ebx
f0100f62:	5e                   	pop    %esi
f0100f63:	5f                   	pop    %edi
f0100f64:	5d                   	pop    %ebp
f0100f65:	c3                   	ret    
f0100f66:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100f69:	eb be                	jmp    f0100f29 <printnum+0x88>

f0100f6b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f6b:	55                   	push   %ebp
f0100f6c:	89 e5                	mov    %esp,%ebp
f0100f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f71:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100f75:	8b 10                	mov    (%eax),%edx
f0100f77:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f7a:	73 0a                	jae    f0100f86 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100f7c:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100f7f:	89 08                	mov    %ecx,(%eax)
f0100f81:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f84:	88 02                	mov    %al,(%edx)
}
f0100f86:	5d                   	pop    %ebp
f0100f87:	c3                   	ret    

f0100f88 <printfmt>:
{
f0100f88:	55                   	push   %ebp
f0100f89:	89 e5                	mov    %esp,%ebp
f0100f8b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100f8e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f91:	50                   	push   %eax
f0100f92:	ff 75 10             	pushl  0x10(%ebp)
f0100f95:	ff 75 0c             	pushl  0xc(%ebp)
f0100f98:	ff 75 08             	pushl  0x8(%ebp)
f0100f9b:	e8 05 00 00 00       	call   f0100fa5 <vprintfmt>
}
f0100fa0:	83 c4 10             	add    $0x10,%esp
f0100fa3:	c9                   	leave  
f0100fa4:	c3                   	ret    

f0100fa5 <vprintfmt>:
{
f0100fa5:	55                   	push   %ebp
f0100fa6:	89 e5                	mov    %esp,%ebp
f0100fa8:	57                   	push   %edi
f0100fa9:	56                   	push   %esi
f0100faa:	53                   	push   %ebx
f0100fab:	83 ec 2c             	sub    $0x2c,%esp
f0100fae:	e8 09 f2 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100fb3:	81 c3 55 03 01 00    	add    $0x10355,%ebx
f0100fb9:	8b 75 10             	mov    0x10(%ebp),%esi
	int green_text = 0;
f0100fbc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100fc3:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100fc5:	8d 77 01             	lea    0x1(%edi),%esi
f0100fc8:	0f b6 07             	movzbl (%edi),%eax
f0100fcb:	83 f8 25             	cmp    $0x25,%eax
f0100fce:	74 35                	je     f0101005 <vprintfmt+0x60>
			if (ch == '\0')
f0100fd0:	85 c0                	test   %eax,%eax
f0100fd2:	0f 84 8a 04 00 00    	je     f0101462 <.L23+0x20>
				green_text = ~green_text;
f0100fd8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100fdb:	89 ca                	mov    %ecx,%edx
f0100fdd:	f7 d2                	not    %edx
f0100fdf:	83 f8 61             	cmp    $0x61,%eax
f0100fe2:	0f 45 d1             	cmovne %ecx,%edx
f0100fe5:	89 d1                	mov    %edx,%ecx
f0100fe7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				ch |= 0x0200;
f0100fea:	89 c2                	mov    %eax,%edx
f0100fec:	80 ce 02             	or     $0x2,%dh
f0100fef:	85 c9                	test   %ecx,%ecx
f0100ff1:	0f 45 c2             	cmovne %edx,%eax
			putch(ch, putdat);
f0100ff4:	83 ec 08             	sub    $0x8,%esp
f0100ff7:	ff 75 0c             	pushl  0xc(%ebp)
f0100ffa:	50                   	push   %eax
f0100ffb:	ff 55 08             	call   *0x8(%ebp)
f0100ffe:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101001:	89 f7                	mov    %esi,%edi
f0101003:	eb c0                	jmp    f0100fc5 <vprintfmt+0x20>
		padc = ' ';
f0101005:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0101009:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0101010:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0101017:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f010101e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101023:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101026:	8d 7e 01             	lea    0x1(%esi),%edi
f0101029:	0f b6 16             	movzbl (%esi),%edx
f010102c:	8d 42 dd             	lea    -0x23(%edx),%eax
f010102f:	3c 55                	cmp    $0x55,%al
f0101031:	0f 87 0b 04 00 00    	ja     f0101442 <.L23>
f0101037:	0f b6 c0             	movzbl %al,%eax
f010103a:	89 d9                	mov    %ebx,%ecx
f010103c:	03 8c 83 8c 0e ff ff 	add    -0xf174(%ebx,%eax,4),%ecx
f0101043:	ff e1                	jmp    *%ecx

f0101045 <.L70>:
f0101045:	89 fe                	mov    %edi,%esi
			padc = '-';
f0101047:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010104b:	eb d9                	jmp    f0101026 <vprintfmt+0x81>

f010104d <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f010104d:	89 fe                	mov    %edi,%esi
			padc = '0';
f010104f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0101053:	eb d1                	jmp    f0101026 <vprintfmt+0x81>

f0101055 <.L30>:
		switch (ch = *(unsigned char *) fmt++) {
f0101055:	0f b6 d2             	movzbl %dl,%edx
f0101058:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
f010105a:	b8 00 00 00 00       	mov    $0x0,%eax
f010105f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
				precision = precision * 10 + ch - '0';
f0101062:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101065:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0101069:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
f010106c:	8d 7a d0             	lea    -0x30(%edx),%edi
f010106f:	83 ff 09             	cmp    $0x9,%edi
f0101072:	77 52                	ja     f01010c6 <.L24+0xe>
			for (precision = 0; ; ++fmt) {
f0101074:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0101077:	eb e9                	jmp    f0101062 <.L30+0xd>

f0101079 <.L27>:
			precision = va_arg(ap, int);
f0101079:	8b 45 14             	mov    0x14(%ebp),%eax
f010107c:	8b 00                	mov    (%eax),%eax
f010107e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101081:	8b 45 14             	mov    0x14(%ebp),%eax
f0101084:	8d 40 04             	lea    0x4(%eax),%eax
f0101087:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010108a:	89 fe                	mov    %edi,%esi
			if (width < 0)
f010108c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101090:	79 94                	jns    f0101026 <vprintfmt+0x81>
				width = precision, precision = -1;
f0101092:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101095:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101098:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f010109f:	eb 85                	jmp    f0101026 <vprintfmt+0x81>

f01010a1 <.L28>:
f01010a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010a4:	85 c0                	test   %eax,%eax
f01010a6:	be 00 00 00 00       	mov    $0x0,%esi
f01010ab:	0f 49 f0             	cmovns %eax,%esi
f01010ae:	89 75 e0             	mov    %esi,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010b1:	89 fe                	mov    %edi,%esi
f01010b3:	e9 6e ff ff ff       	jmp    f0101026 <vprintfmt+0x81>

f01010b8 <.L24>:
f01010b8:	89 fe                	mov    %edi,%esi
			altflag = 1;
f01010ba:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01010c1:	e9 60 ff ff ff       	jmp    f0101026 <vprintfmt+0x81>
f01010c6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01010c9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01010cc:	eb be                	jmp    f010108c <.L27+0x13>

f01010ce <.L34>:
			lflag++;
f01010ce:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010d2:	89 fe                	mov    %edi,%esi
			goto reswitch;
f01010d4:	e9 4d ff ff ff       	jmp    f0101026 <vprintfmt+0x81>

f01010d9 <.L31>:
			putch(va_arg(ap, int), putdat);
f01010d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01010dc:	8d 70 04             	lea    0x4(%eax),%esi
f01010df:	83 ec 08             	sub    $0x8,%esp
f01010e2:	ff 75 0c             	pushl  0xc(%ebp)
f01010e5:	ff 30                	pushl  (%eax)
f01010e7:	ff 55 08             	call   *0x8(%ebp)
			break;
f01010ea:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01010ed:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
f01010f0:	e9 d0 fe ff ff       	jmp    f0100fc5 <vprintfmt+0x20>

f01010f5 <.L33>:
			err = va_arg(ap, int);
f01010f5:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f8:	8d 70 04             	lea    0x4(%eax),%esi
f01010fb:	8b 00                	mov    (%eax),%eax
f01010fd:	99                   	cltd   
f01010fe:	31 d0                	xor    %edx,%eax
f0101100:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101102:	83 f8 06             	cmp    $0x6,%eax
f0101105:	7f 29                	jg     f0101130 <.L33+0x3b>
f0101107:	8b 94 83 3c 1d 00 00 	mov    0x1d3c(%ebx,%eax,4),%edx
f010110e:	85 d2                	test   %edx,%edx
f0101110:	74 1e                	je     f0101130 <.L33+0x3b>
				printfmt(putch, putdat, "%s", p);
f0101112:	52                   	push   %edx
f0101113:	8d 83 1e 0e ff ff    	lea    -0xf1e2(%ebx),%eax
f0101119:	50                   	push   %eax
f010111a:	ff 75 0c             	pushl  0xc(%ebp)
f010111d:	ff 75 08             	pushl  0x8(%ebp)
f0101120:	e8 63 fe ff ff       	call   f0100f88 <printfmt>
f0101125:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101128:	89 75 14             	mov    %esi,0x14(%ebp)
f010112b:	e9 95 fe ff ff       	jmp    f0100fc5 <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
f0101130:	50                   	push   %eax
f0101131:	8d 83 15 0e ff ff    	lea    -0xf1eb(%ebx),%eax
f0101137:	50                   	push   %eax
f0101138:	ff 75 0c             	pushl  0xc(%ebp)
f010113b:	ff 75 08             	pushl  0x8(%ebp)
f010113e:	e8 45 fe ff ff       	call   f0100f88 <printfmt>
f0101143:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101146:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0101149:	e9 77 fe ff ff       	jmp    f0100fc5 <vprintfmt+0x20>

f010114e <.L37>:
			if ((p = va_arg(ap, char *)) == NULL)
f010114e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101151:	83 c0 04             	add    $0x4,%eax
f0101154:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101157:	8b 45 14             	mov    0x14(%ebp),%eax
f010115a:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f010115c:	85 f6                	test   %esi,%esi
f010115e:	8d 83 0e 0e ff ff    	lea    -0xf1f2(%ebx),%eax
f0101164:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0101167:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010116b:	0f 8e b4 00 00 00    	jle    f0101225 <.L37+0xd7>
f0101171:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0101175:	75 08                	jne    f010117f <.L37+0x31>
f0101177:	89 7d 10             	mov    %edi,0x10(%ebp)
f010117a:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010117d:	eb 6c                	jmp    f01011eb <.L37+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
f010117f:	83 ec 08             	sub    $0x8,%esp
f0101182:	ff 75 cc             	pushl  -0x34(%ebp)
f0101185:	56                   	push   %esi
f0101186:	e8 71 04 00 00       	call   f01015fc <strnlen>
f010118b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010118e:	29 c1                	sub    %eax,%ecx
f0101190:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101193:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0101196:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010119a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010119d:	89 ce                	mov    %ecx,%esi
f010119f:	89 7d 10             	mov    %edi,0x10(%ebp)
f01011a2:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f01011a4:	85 f6                	test   %esi,%esi
f01011a6:	7e 12                	jle    f01011ba <.L37+0x6c>
					putch(padc, putdat);
f01011a8:	83 ec 08             	sub    $0x8,%esp
f01011ab:	ff 75 0c             	pushl  0xc(%ebp)
f01011ae:	57                   	push   %edi
f01011af:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01011b2:	83 ee 01             	sub    $0x1,%esi
f01011b5:	83 c4 10             	add    $0x10,%esp
f01011b8:	eb ea                	jmp    f01011a4 <.L37+0x56>
f01011ba:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01011bd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01011c0:	85 c9                	test   %ecx,%ecx
f01011c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01011c7:	0f 49 c1             	cmovns %ecx,%eax
f01011ca:	29 c1                	sub    %eax,%ecx
f01011cc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01011cf:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01011d2:	eb 17                	jmp    f01011eb <.L37+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
f01011d4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01011d8:	75 30                	jne    f010120a <.L37+0xbc>
					putch(ch, putdat);
f01011da:	83 ec 08             	sub    $0x8,%esp
f01011dd:	ff 75 0c             	pushl  0xc(%ebp)
f01011e0:	50                   	push   %eax
f01011e1:	ff 55 08             	call   *0x8(%ebp)
f01011e4:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01011e7:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01011eb:	83 c6 01             	add    $0x1,%esi
f01011ee:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f01011f2:	0f be c2             	movsbl %dl,%eax
f01011f5:	85 c0                	test   %eax,%eax
f01011f7:	74 58                	je     f0101251 <.L37+0x103>
f01011f9:	85 ff                	test   %edi,%edi
f01011fb:	78 d7                	js     f01011d4 <.L37+0x86>
f01011fd:	83 ef 01             	sub    $0x1,%edi
f0101200:	79 d2                	jns    f01011d4 <.L37+0x86>
f0101202:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101205:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101208:	eb 32                	jmp    f010123c <.L37+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
f010120a:	0f be d2             	movsbl %dl,%edx
f010120d:	83 ea 20             	sub    $0x20,%edx
f0101210:	83 fa 5e             	cmp    $0x5e,%edx
f0101213:	76 c5                	jbe    f01011da <.L37+0x8c>
					putch('?', putdat);
f0101215:	83 ec 08             	sub    $0x8,%esp
f0101218:	ff 75 0c             	pushl  0xc(%ebp)
f010121b:	6a 3f                	push   $0x3f
f010121d:	ff 55 08             	call   *0x8(%ebp)
f0101220:	83 c4 10             	add    $0x10,%esp
f0101223:	eb c2                	jmp    f01011e7 <.L37+0x99>
f0101225:	89 7d 10             	mov    %edi,0x10(%ebp)
f0101228:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010122b:	eb be                	jmp    f01011eb <.L37+0x9d>
				putch(' ', putdat);
f010122d:	83 ec 08             	sub    $0x8,%esp
f0101230:	57                   	push   %edi
f0101231:	6a 20                	push   $0x20
f0101233:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f0101236:	83 ee 01             	sub    $0x1,%esi
f0101239:	83 c4 10             	add    $0x10,%esp
f010123c:	85 f6                	test   %esi,%esi
f010123e:	7f ed                	jg     f010122d <.L37+0xdf>
f0101240:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0101243:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
f0101246:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101249:	89 45 14             	mov    %eax,0x14(%ebp)
f010124c:	e9 74 fd ff ff       	jmp    f0100fc5 <vprintfmt+0x20>
f0101251:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101254:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101257:	eb e3                	jmp    f010123c <.L37+0xee>

f0101259 <.L32>:
f0101259:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f010125c:	83 f9 01             	cmp    $0x1,%ecx
f010125f:	7e 42                	jle    f01012a3 <.L32+0x4a>
		return va_arg(*ap, long long);
f0101261:	8b 45 14             	mov    0x14(%ebp),%eax
f0101264:	8b 50 04             	mov    0x4(%eax),%edx
f0101267:	8b 00                	mov    (%eax),%eax
f0101269:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010126c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010126f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101272:	8d 40 08             	lea    0x8(%eax),%eax
f0101275:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101278:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010127c:	79 5f                	jns    f01012dd <.L32+0x84>
				putch('-', putdat);
f010127e:	83 ec 08             	sub    $0x8,%esp
f0101281:	ff 75 0c             	pushl  0xc(%ebp)
f0101284:	6a 2d                	push   $0x2d
f0101286:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101289:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010128c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010128f:	f7 da                	neg    %edx
f0101291:	83 d1 00             	adc    $0x0,%ecx
f0101294:	f7 d9                	neg    %ecx
f0101296:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101299:	b8 0a 00 00 00       	mov    $0xa,%eax
f010129e:	e9 1c 01 00 00       	jmp    f01013bf <.L36+0x2e>
	else if (lflag)
f01012a3:	85 c9                	test   %ecx,%ecx
f01012a5:	75 1b                	jne    f01012c2 <.L32+0x69>
		return va_arg(*ap, int);
f01012a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01012aa:	8b 30                	mov    (%eax),%esi
f01012ac:	89 75 d8             	mov    %esi,-0x28(%ebp)
f01012af:	89 f0                	mov    %esi,%eax
f01012b1:	c1 f8 1f             	sar    $0x1f,%eax
f01012b4:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01012b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01012ba:	8d 40 04             	lea    0x4(%eax),%eax
f01012bd:	89 45 14             	mov    %eax,0x14(%ebp)
f01012c0:	eb b6                	jmp    f0101278 <.L32+0x1f>
		return va_arg(*ap, long);
f01012c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01012c5:	8b 30                	mov    (%eax),%esi
f01012c7:	89 75 d8             	mov    %esi,-0x28(%ebp)
f01012ca:	89 f0                	mov    %esi,%eax
f01012cc:	c1 f8 1f             	sar    $0x1f,%eax
f01012cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01012d2:	8b 45 14             	mov    0x14(%ebp),%eax
f01012d5:	8d 40 04             	lea    0x4(%eax),%eax
f01012d8:	89 45 14             	mov    %eax,0x14(%ebp)
f01012db:	eb 9b                	jmp    f0101278 <.L32+0x1f>
			num = getint(&ap, lflag);
f01012dd:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01012e0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01012e3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012e8:	e9 d2 00 00 00       	jmp    f01013bf <.L36+0x2e>

f01012ed <.L38>:
f01012ed:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01012f0:	83 f9 01             	cmp    $0x1,%ecx
f01012f3:	7e 18                	jle    f010130d <.L38+0x20>
		return va_arg(*ap, unsigned long long);
f01012f5:	8b 45 14             	mov    0x14(%ebp),%eax
f01012f8:	8b 10                	mov    (%eax),%edx
f01012fa:	8b 48 04             	mov    0x4(%eax),%ecx
f01012fd:	8d 40 08             	lea    0x8(%eax),%eax
f0101300:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101303:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101308:	e9 b2 00 00 00       	jmp    f01013bf <.L36+0x2e>
	else if (lflag)
f010130d:	85 c9                	test   %ecx,%ecx
f010130f:	75 1a                	jne    f010132b <.L38+0x3e>
		return va_arg(*ap, unsigned int);
f0101311:	8b 45 14             	mov    0x14(%ebp),%eax
f0101314:	8b 10                	mov    (%eax),%edx
f0101316:	b9 00 00 00 00       	mov    $0x0,%ecx
f010131b:	8d 40 04             	lea    0x4(%eax),%eax
f010131e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101321:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101326:	e9 94 00 00 00       	jmp    f01013bf <.L36+0x2e>
		return va_arg(*ap, unsigned long);
f010132b:	8b 45 14             	mov    0x14(%ebp),%eax
f010132e:	8b 10                	mov    (%eax),%edx
f0101330:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101335:	8d 40 04             	lea    0x4(%eax),%eax
f0101338:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010133b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101340:	eb 7d                	jmp    f01013bf <.L36+0x2e>

f0101342 <.L35>:
f0101342:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0101345:	83 f9 01             	cmp    $0x1,%ecx
f0101348:	7e 15                	jle    f010135f <.L35+0x1d>
		return va_arg(*ap, unsigned long long);
f010134a:	8b 45 14             	mov    0x14(%ebp),%eax
f010134d:	8b 10                	mov    (%eax),%edx
f010134f:	8b 48 04             	mov    0x4(%eax),%ecx
f0101352:	8d 40 08             	lea    0x8(%eax),%eax
f0101355:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101358:	b8 08 00 00 00       	mov    $0x8,%eax
f010135d:	eb 60                	jmp    f01013bf <.L36+0x2e>
	else if (lflag)
f010135f:	85 c9                	test   %ecx,%ecx
f0101361:	75 17                	jne    f010137a <.L35+0x38>
		return va_arg(*ap, unsigned int);
f0101363:	8b 45 14             	mov    0x14(%ebp),%eax
f0101366:	8b 10                	mov    (%eax),%edx
f0101368:	b9 00 00 00 00       	mov    $0x0,%ecx
f010136d:	8d 40 04             	lea    0x4(%eax),%eax
f0101370:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101373:	b8 08 00 00 00       	mov    $0x8,%eax
f0101378:	eb 45                	jmp    f01013bf <.L36+0x2e>
		return va_arg(*ap, unsigned long);
f010137a:	8b 45 14             	mov    0x14(%ebp),%eax
f010137d:	8b 10                	mov    (%eax),%edx
f010137f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101384:	8d 40 04             	lea    0x4(%eax),%eax
f0101387:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010138a:	b8 08 00 00 00       	mov    $0x8,%eax
f010138f:	eb 2e                	jmp    f01013bf <.L36+0x2e>

f0101391 <.L36>:
			putch('0', putdat);
f0101391:	83 ec 08             	sub    $0x8,%esp
f0101394:	ff 75 0c             	pushl  0xc(%ebp)
f0101397:	6a 30                	push   $0x30
f0101399:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010139c:	83 c4 08             	add    $0x8,%esp
f010139f:	ff 75 0c             	pushl  0xc(%ebp)
f01013a2:	6a 78                	push   $0x78
f01013a4:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f01013a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01013aa:	8b 10                	mov    (%eax),%edx
f01013ac:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01013b1:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01013b4:	8d 40 04             	lea    0x4(%eax),%eax
f01013b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013ba:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01013bf:	83 ec 0c             	sub    $0xc,%esp
f01013c2:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
f01013c6:	56                   	push   %esi
f01013c7:	ff 75 e0             	pushl  -0x20(%ebp)
f01013ca:	50                   	push   %eax
f01013cb:	51                   	push   %ecx
f01013cc:	52                   	push   %edx
f01013cd:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01013d3:	e8 c9 fa ff ff       	call   f0100ea1 <printnum>
			break;
f01013d8:	83 c4 20             	add    $0x20,%esp
f01013db:	e9 e5 fb ff ff       	jmp    f0100fc5 <vprintfmt+0x20>

f01013e0 <.L39>:
f01013e0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01013e3:	83 f9 01             	cmp    $0x1,%ecx
f01013e6:	7e 15                	jle    f01013fd <.L39+0x1d>
		return va_arg(*ap, unsigned long long);
f01013e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01013eb:	8b 10                	mov    (%eax),%edx
f01013ed:	8b 48 04             	mov    0x4(%eax),%ecx
f01013f0:	8d 40 08             	lea    0x8(%eax),%eax
f01013f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013f6:	b8 10 00 00 00       	mov    $0x10,%eax
f01013fb:	eb c2                	jmp    f01013bf <.L36+0x2e>
	else if (lflag)
f01013fd:	85 c9                	test   %ecx,%ecx
f01013ff:	75 17                	jne    f0101418 <.L39+0x38>
		return va_arg(*ap, unsigned int);
f0101401:	8b 45 14             	mov    0x14(%ebp),%eax
f0101404:	8b 10                	mov    (%eax),%edx
f0101406:	b9 00 00 00 00       	mov    $0x0,%ecx
f010140b:	8d 40 04             	lea    0x4(%eax),%eax
f010140e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101411:	b8 10 00 00 00       	mov    $0x10,%eax
f0101416:	eb a7                	jmp    f01013bf <.L36+0x2e>
		return va_arg(*ap, unsigned long);
f0101418:	8b 45 14             	mov    0x14(%ebp),%eax
f010141b:	8b 10                	mov    (%eax),%edx
f010141d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101422:	8d 40 04             	lea    0x4(%eax),%eax
f0101425:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101428:	b8 10 00 00 00       	mov    $0x10,%eax
f010142d:	eb 90                	jmp    f01013bf <.L36+0x2e>

f010142f <.L26>:
			putch(ch, putdat);
f010142f:	83 ec 08             	sub    $0x8,%esp
f0101432:	ff 75 0c             	pushl  0xc(%ebp)
f0101435:	6a 25                	push   $0x25
f0101437:	ff 55 08             	call   *0x8(%ebp)
			break;
f010143a:	83 c4 10             	add    $0x10,%esp
f010143d:	e9 83 fb ff ff       	jmp    f0100fc5 <vprintfmt+0x20>

f0101442 <.L23>:
			putch('%', putdat);
f0101442:	83 ec 08             	sub    $0x8,%esp
f0101445:	ff 75 0c             	pushl  0xc(%ebp)
f0101448:	6a 25                	push   $0x25
f010144a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010144d:	83 c4 10             	add    $0x10,%esp
f0101450:	89 f7                	mov    %esi,%edi
f0101452:	eb 03                	jmp    f0101457 <.L23+0x15>
f0101454:	83 ef 01             	sub    $0x1,%edi
f0101457:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010145b:	75 f7                	jne    f0101454 <.L23+0x12>
f010145d:	e9 63 fb ff ff       	jmp    f0100fc5 <vprintfmt+0x20>
}
f0101462:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101465:	5b                   	pop    %ebx
f0101466:	5e                   	pop    %esi
f0101467:	5f                   	pop    %edi
f0101468:	5d                   	pop    %ebp
f0101469:	c3                   	ret    

f010146a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010146a:	55                   	push   %ebp
f010146b:	89 e5                	mov    %esp,%ebp
f010146d:	53                   	push   %ebx
f010146e:	83 ec 14             	sub    $0x14,%esp
f0101471:	e8 46 ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0101476:	81 c3 92 fe 00 00    	add    $0xfe92,%ebx
f010147c:	8b 45 08             	mov    0x8(%ebp),%eax
f010147f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101482:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101485:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101489:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010148c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101493:	85 c0                	test   %eax,%eax
f0101495:	74 2b                	je     f01014c2 <vsnprintf+0x58>
f0101497:	85 d2                	test   %edx,%edx
f0101499:	7e 27                	jle    f01014c2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010149b:	ff 75 14             	pushl  0x14(%ebp)
f010149e:	ff 75 10             	pushl  0x10(%ebp)
f01014a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01014a4:	50                   	push   %eax
f01014a5:	8d 83 63 fc fe ff    	lea    -0x1039d(%ebx),%eax
f01014ab:	50                   	push   %eax
f01014ac:	e8 f4 fa ff ff       	call   f0100fa5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01014b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01014b4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01014b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01014ba:	83 c4 10             	add    $0x10,%esp
}
f01014bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014c0:	c9                   	leave  
f01014c1:	c3                   	ret    
		return -E_INVAL;
f01014c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01014c7:	eb f4                	jmp    f01014bd <vsnprintf+0x53>

f01014c9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01014c9:	55                   	push   %ebp
f01014ca:	89 e5                	mov    %esp,%ebp
f01014cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01014cf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01014d2:	50                   	push   %eax
f01014d3:	ff 75 10             	pushl  0x10(%ebp)
f01014d6:	ff 75 0c             	pushl  0xc(%ebp)
f01014d9:	ff 75 08             	pushl  0x8(%ebp)
f01014dc:	e8 89 ff ff ff       	call   f010146a <vsnprintf>
	va_end(ap);

	return rc;
}
f01014e1:	c9                   	leave  
f01014e2:	c3                   	ret    

f01014e3 <__x86.get_pc_thunk.cx>:
f01014e3:	8b 0c 24             	mov    (%esp),%ecx
f01014e6:	c3                   	ret    

f01014e7 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01014e7:	55                   	push   %ebp
f01014e8:	89 e5                	mov    %esp,%ebp
f01014ea:	57                   	push   %edi
f01014eb:	56                   	push   %esi
f01014ec:	53                   	push   %ebx
f01014ed:	83 ec 1c             	sub    $0x1c,%esp
f01014f0:	e8 c7 ec ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01014f5:	81 c3 13 fe 00 00    	add    $0xfe13,%ebx
f01014fb:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01014fe:	85 c0                	test   %eax,%eax
f0101500:	74 13                	je     f0101515 <readline+0x2e>
		cprintf("%s", prompt);
f0101502:	83 ec 08             	sub    $0x8,%esp
f0101505:	50                   	push   %eax
f0101506:	8d 83 1e 0e ff ff    	lea    -0xf1e2(%ebx),%eax
f010150c:	50                   	push   %eax
f010150d:	e8 d2 f5 ff ff       	call   f0100ae4 <cprintf>
f0101512:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101515:	83 ec 0c             	sub    $0xc,%esp
f0101518:	6a 00                	push   $0x0
f010151a:	e8 35 f2 ff ff       	call   f0100754 <iscons>
f010151f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101522:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101525:	bf 00 00 00 00       	mov    $0x0,%edi
f010152a:	eb 46                	jmp    f0101572 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010152c:	83 ec 08             	sub    $0x8,%esp
f010152f:	50                   	push   %eax
f0101530:	8d 83 e4 0f ff ff    	lea    -0xf01c(%ebx),%eax
f0101536:	50                   	push   %eax
f0101537:	e8 a8 f5 ff ff       	call   f0100ae4 <cprintf>
			return NULL;
f010153c:	83 c4 10             	add    $0x10,%esp
f010153f:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0101544:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101547:	5b                   	pop    %ebx
f0101548:	5e                   	pop    %esi
f0101549:	5f                   	pop    %edi
f010154a:	5d                   	pop    %ebp
f010154b:	c3                   	ret    
			if (echoing)
f010154c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101550:	75 05                	jne    f0101557 <readline+0x70>
			i--;
f0101552:	83 ef 01             	sub    $0x1,%edi
f0101555:	eb 1b                	jmp    f0101572 <readline+0x8b>
				cputchar('\b');
f0101557:	83 ec 0c             	sub    $0xc,%esp
f010155a:	6a 08                	push   $0x8
f010155c:	e8 d2 f1 ff ff       	call   f0100733 <cputchar>
f0101561:	83 c4 10             	add    $0x10,%esp
f0101564:	eb ec                	jmp    f0101552 <readline+0x6b>
			buf[i++] = c;
f0101566:	89 f0                	mov    %esi,%eax
f0101568:	88 84 3b 98 1f 00 00 	mov    %al,0x1f98(%ebx,%edi,1)
f010156f:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0101572:	e8 cc f1 ff ff       	call   f0100743 <getchar>
f0101577:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0101579:	85 c0                	test   %eax,%eax
f010157b:	78 af                	js     f010152c <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010157d:	83 f8 08             	cmp    $0x8,%eax
f0101580:	0f 94 c2             	sete   %dl
f0101583:	83 f8 7f             	cmp    $0x7f,%eax
f0101586:	0f 94 c0             	sete   %al
f0101589:	08 c2                	or     %al,%dl
f010158b:	74 04                	je     f0101591 <readline+0xaa>
f010158d:	85 ff                	test   %edi,%edi
f010158f:	7f bb                	jg     f010154c <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101591:	83 fe 1f             	cmp    $0x1f,%esi
f0101594:	7e 1c                	jle    f01015b2 <readline+0xcb>
f0101596:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f010159c:	7f 14                	jg     f01015b2 <readline+0xcb>
			if (echoing)
f010159e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015a2:	74 c2                	je     f0101566 <readline+0x7f>
				cputchar(c);
f01015a4:	83 ec 0c             	sub    $0xc,%esp
f01015a7:	56                   	push   %esi
f01015a8:	e8 86 f1 ff ff       	call   f0100733 <cputchar>
f01015ad:	83 c4 10             	add    $0x10,%esp
f01015b0:	eb b4                	jmp    f0101566 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f01015b2:	83 fe 0a             	cmp    $0xa,%esi
f01015b5:	74 05                	je     f01015bc <readline+0xd5>
f01015b7:	83 fe 0d             	cmp    $0xd,%esi
f01015ba:	75 b6                	jne    f0101572 <readline+0x8b>
			if (echoing)
f01015bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015c0:	75 13                	jne    f01015d5 <readline+0xee>
			buf[i] = 0;
f01015c2:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f01015c9:	00 
			return buf;
f01015ca:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f01015d0:	e9 6f ff ff ff       	jmp    f0101544 <readline+0x5d>
				cputchar('\n');
f01015d5:	83 ec 0c             	sub    $0xc,%esp
f01015d8:	6a 0a                	push   $0xa
f01015da:	e8 54 f1 ff ff       	call   f0100733 <cputchar>
f01015df:	83 c4 10             	add    $0x10,%esp
f01015e2:	eb de                	jmp    f01015c2 <readline+0xdb>

f01015e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01015e4:	55                   	push   %ebp
f01015e5:	89 e5                	mov    %esp,%ebp
f01015e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01015ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01015ef:	eb 03                	jmp    f01015f4 <strlen+0x10>
		n++;
f01015f1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01015f4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01015f8:	75 f7                	jne    f01015f1 <strlen+0xd>
	return n;
}
f01015fa:	5d                   	pop    %ebp
f01015fb:	c3                   	ret    

f01015fc <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01015fc:	55                   	push   %ebp
f01015fd:	89 e5                	mov    %esp,%ebp
f01015ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101602:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101605:	b8 00 00 00 00       	mov    $0x0,%eax
f010160a:	eb 03                	jmp    f010160f <strnlen+0x13>
		n++;
f010160c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010160f:	39 d0                	cmp    %edx,%eax
f0101611:	74 06                	je     f0101619 <strnlen+0x1d>
f0101613:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101617:	75 f3                	jne    f010160c <strnlen+0x10>
	return n;
}
f0101619:	5d                   	pop    %ebp
f010161a:	c3                   	ret    

f010161b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010161b:	55                   	push   %ebp
f010161c:	89 e5                	mov    %esp,%ebp
f010161e:	53                   	push   %ebx
f010161f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101622:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101625:	89 c2                	mov    %eax,%edx
f0101627:	83 c1 01             	add    $0x1,%ecx
f010162a:	83 c2 01             	add    $0x1,%edx
f010162d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101631:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101634:	84 db                	test   %bl,%bl
f0101636:	75 ef                	jne    f0101627 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101638:	5b                   	pop    %ebx
f0101639:	5d                   	pop    %ebp
f010163a:	c3                   	ret    

f010163b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010163b:	55                   	push   %ebp
f010163c:	89 e5                	mov    %esp,%ebp
f010163e:	53                   	push   %ebx
f010163f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101642:	53                   	push   %ebx
f0101643:	e8 9c ff ff ff       	call   f01015e4 <strlen>
f0101648:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010164b:	ff 75 0c             	pushl  0xc(%ebp)
f010164e:	01 d8                	add    %ebx,%eax
f0101650:	50                   	push   %eax
f0101651:	e8 c5 ff ff ff       	call   f010161b <strcpy>
	return dst;
}
f0101656:	89 d8                	mov    %ebx,%eax
f0101658:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010165b:	c9                   	leave  
f010165c:	c3                   	ret    

f010165d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010165d:	55                   	push   %ebp
f010165e:	89 e5                	mov    %esp,%ebp
f0101660:	56                   	push   %esi
f0101661:	53                   	push   %ebx
f0101662:	8b 75 08             	mov    0x8(%ebp),%esi
f0101665:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101668:	89 f3                	mov    %esi,%ebx
f010166a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010166d:	89 f2                	mov    %esi,%edx
f010166f:	eb 0f                	jmp    f0101680 <strncpy+0x23>
		*dst++ = *src;
f0101671:	83 c2 01             	add    $0x1,%edx
f0101674:	0f b6 01             	movzbl (%ecx),%eax
f0101677:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010167a:	80 39 01             	cmpb   $0x1,(%ecx)
f010167d:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0101680:	39 da                	cmp    %ebx,%edx
f0101682:	75 ed                	jne    f0101671 <strncpy+0x14>
	}
	return ret;
}
f0101684:	89 f0                	mov    %esi,%eax
f0101686:	5b                   	pop    %ebx
f0101687:	5e                   	pop    %esi
f0101688:	5d                   	pop    %ebp
f0101689:	c3                   	ret    

f010168a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010168a:	55                   	push   %ebp
f010168b:	89 e5                	mov    %esp,%ebp
f010168d:	56                   	push   %esi
f010168e:	53                   	push   %ebx
f010168f:	8b 75 08             	mov    0x8(%ebp),%esi
f0101692:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101695:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101698:	89 f0                	mov    %esi,%eax
f010169a:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010169e:	85 c9                	test   %ecx,%ecx
f01016a0:	75 0b                	jne    f01016ad <strlcpy+0x23>
f01016a2:	eb 17                	jmp    f01016bb <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01016a4:	83 c2 01             	add    $0x1,%edx
f01016a7:	83 c0 01             	add    $0x1,%eax
f01016aa:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f01016ad:	39 d8                	cmp    %ebx,%eax
f01016af:	74 07                	je     f01016b8 <strlcpy+0x2e>
f01016b1:	0f b6 0a             	movzbl (%edx),%ecx
f01016b4:	84 c9                	test   %cl,%cl
f01016b6:	75 ec                	jne    f01016a4 <strlcpy+0x1a>
		*dst = '\0';
f01016b8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01016bb:	29 f0                	sub    %esi,%eax
}
f01016bd:	5b                   	pop    %ebx
f01016be:	5e                   	pop    %esi
f01016bf:	5d                   	pop    %ebp
f01016c0:	c3                   	ret    

f01016c1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01016c1:	55                   	push   %ebp
f01016c2:	89 e5                	mov    %esp,%ebp
f01016c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01016ca:	eb 06                	jmp    f01016d2 <strcmp+0x11>
		p++, q++;
f01016cc:	83 c1 01             	add    $0x1,%ecx
f01016cf:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01016d2:	0f b6 01             	movzbl (%ecx),%eax
f01016d5:	84 c0                	test   %al,%al
f01016d7:	74 04                	je     f01016dd <strcmp+0x1c>
f01016d9:	3a 02                	cmp    (%edx),%al
f01016db:	74 ef                	je     f01016cc <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01016dd:	0f b6 c0             	movzbl %al,%eax
f01016e0:	0f b6 12             	movzbl (%edx),%edx
f01016e3:	29 d0                	sub    %edx,%eax
}
f01016e5:	5d                   	pop    %ebp
f01016e6:	c3                   	ret    

f01016e7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01016e7:	55                   	push   %ebp
f01016e8:	89 e5                	mov    %esp,%ebp
f01016ea:	53                   	push   %ebx
f01016eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01016ee:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016f1:	89 c3                	mov    %eax,%ebx
f01016f3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01016f6:	eb 06                	jmp    f01016fe <strncmp+0x17>
		n--, p++, q++;
f01016f8:	83 c0 01             	add    $0x1,%eax
f01016fb:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01016fe:	39 d8                	cmp    %ebx,%eax
f0101700:	74 16                	je     f0101718 <strncmp+0x31>
f0101702:	0f b6 08             	movzbl (%eax),%ecx
f0101705:	84 c9                	test   %cl,%cl
f0101707:	74 04                	je     f010170d <strncmp+0x26>
f0101709:	3a 0a                	cmp    (%edx),%cl
f010170b:	74 eb                	je     f01016f8 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010170d:	0f b6 00             	movzbl (%eax),%eax
f0101710:	0f b6 12             	movzbl (%edx),%edx
f0101713:	29 d0                	sub    %edx,%eax
}
f0101715:	5b                   	pop    %ebx
f0101716:	5d                   	pop    %ebp
f0101717:	c3                   	ret    
		return 0;
f0101718:	b8 00 00 00 00       	mov    $0x0,%eax
f010171d:	eb f6                	jmp    f0101715 <strncmp+0x2e>

f010171f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010171f:	55                   	push   %ebp
f0101720:	89 e5                	mov    %esp,%ebp
f0101722:	8b 45 08             	mov    0x8(%ebp),%eax
f0101725:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101729:	0f b6 10             	movzbl (%eax),%edx
f010172c:	84 d2                	test   %dl,%dl
f010172e:	74 09                	je     f0101739 <strchr+0x1a>
		if (*s == c)
f0101730:	38 ca                	cmp    %cl,%dl
f0101732:	74 0a                	je     f010173e <strchr+0x1f>
	for (; *s; s++)
f0101734:	83 c0 01             	add    $0x1,%eax
f0101737:	eb f0                	jmp    f0101729 <strchr+0xa>
			return (char *) s;
	return 0;
f0101739:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010173e:	5d                   	pop    %ebp
f010173f:	c3                   	ret    

f0101740 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101740:	55                   	push   %ebp
f0101741:	89 e5                	mov    %esp,%ebp
f0101743:	8b 45 08             	mov    0x8(%ebp),%eax
f0101746:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010174a:	eb 03                	jmp    f010174f <strfind+0xf>
f010174c:	83 c0 01             	add    $0x1,%eax
f010174f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101752:	38 ca                	cmp    %cl,%dl
f0101754:	74 04                	je     f010175a <strfind+0x1a>
f0101756:	84 d2                	test   %dl,%dl
f0101758:	75 f2                	jne    f010174c <strfind+0xc>
			break;
	return (char *) s;
}
f010175a:	5d                   	pop    %ebp
f010175b:	c3                   	ret    

f010175c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010175c:	55                   	push   %ebp
f010175d:	89 e5                	mov    %esp,%ebp
f010175f:	57                   	push   %edi
f0101760:	56                   	push   %esi
f0101761:	53                   	push   %ebx
f0101762:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101765:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101768:	85 c9                	test   %ecx,%ecx
f010176a:	74 13                	je     f010177f <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010176c:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101772:	75 05                	jne    f0101779 <memset+0x1d>
f0101774:	f6 c1 03             	test   $0x3,%cl
f0101777:	74 0d                	je     f0101786 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101779:	8b 45 0c             	mov    0xc(%ebp),%eax
f010177c:	fc                   	cld    
f010177d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010177f:	89 f8                	mov    %edi,%eax
f0101781:	5b                   	pop    %ebx
f0101782:	5e                   	pop    %esi
f0101783:	5f                   	pop    %edi
f0101784:	5d                   	pop    %ebp
f0101785:	c3                   	ret    
		c &= 0xFF;
f0101786:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010178a:	89 d3                	mov    %edx,%ebx
f010178c:	c1 e3 08             	shl    $0x8,%ebx
f010178f:	89 d0                	mov    %edx,%eax
f0101791:	c1 e0 18             	shl    $0x18,%eax
f0101794:	89 d6                	mov    %edx,%esi
f0101796:	c1 e6 10             	shl    $0x10,%esi
f0101799:	09 f0                	or     %esi,%eax
f010179b:	09 c2                	or     %eax,%edx
f010179d:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f010179f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01017a2:	89 d0                	mov    %edx,%eax
f01017a4:	fc                   	cld    
f01017a5:	f3 ab                	rep stos %eax,%es:(%edi)
f01017a7:	eb d6                	jmp    f010177f <memset+0x23>

f01017a9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01017a9:	55                   	push   %ebp
f01017aa:	89 e5                	mov    %esp,%ebp
f01017ac:	57                   	push   %edi
f01017ad:	56                   	push   %esi
f01017ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01017b1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01017b7:	39 c6                	cmp    %eax,%esi
f01017b9:	73 35                	jae    f01017f0 <memmove+0x47>
f01017bb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01017be:	39 c2                	cmp    %eax,%edx
f01017c0:	76 2e                	jbe    f01017f0 <memmove+0x47>
		s += n;
		d += n;
f01017c2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017c5:	89 d6                	mov    %edx,%esi
f01017c7:	09 fe                	or     %edi,%esi
f01017c9:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01017cf:	74 0c                	je     f01017dd <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01017d1:	83 ef 01             	sub    $0x1,%edi
f01017d4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01017d7:	fd                   	std    
f01017d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01017da:	fc                   	cld    
f01017db:	eb 21                	jmp    f01017fe <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017dd:	f6 c1 03             	test   $0x3,%cl
f01017e0:	75 ef                	jne    f01017d1 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01017e2:	83 ef 04             	sub    $0x4,%edi
f01017e5:	8d 72 fc             	lea    -0x4(%edx),%esi
f01017e8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01017eb:	fd                   	std    
f01017ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017ee:	eb ea                	jmp    f01017da <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017f0:	89 f2                	mov    %esi,%edx
f01017f2:	09 c2                	or     %eax,%edx
f01017f4:	f6 c2 03             	test   $0x3,%dl
f01017f7:	74 09                	je     f0101802 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01017f9:	89 c7                	mov    %eax,%edi
f01017fb:	fc                   	cld    
f01017fc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01017fe:	5e                   	pop    %esi
f01017ff:	5f                   	pop    %edi
f0101800:	5d                   	pop    %ebp
f0101801:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101802:	f6 c1 03             	test   $0x3,%cl
f0101805:	75 f2                	jne    f01017f9 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101807:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010180a:	89 c7                	mov    %eax,%edi
f010180c:	fc                   	cld    
f010180d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010180f:	eb ed                	jmp    f01017fe <memmove+0x55>

f0101811 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101811:	55                   	push   %ebp
f0101812:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101814:	ff 75 10             	pushl  0x10(%ebp)
f0101817:	ff 75 0c             	pushl  0xc(%ebp)
f010181a:	ff 75 08             	pushl  0x8(%ebp)
f010181d:	e8 87 ff ff ff       	call   f01017a9 <memmove>
}
f0101822:	c9                   	leave  
f0101823:	c3                   	ret    

f0101824 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101824:	55                   	push   %ebp
f0101825:	89 e5                	mov    %esp,%ebp
f0101827:	56                   	push   %esi
f0101828:	53                   	push   %ebx
f0101829:	8b 45 08             	mov    0x8(%ebp),%eax
f010182c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010182f:	89 c6                	mov    %eax,%esi
f0101831:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101834:	39 f0                	cmp    %esi,%eax
f0101836:	74 1c                	je     f0101854 <memcmp+0x30>
		if (*s1 != *s2)
f0101838:	0f b6 08             	movzbl (%eax),%ecx
f010183b:	0f b6 1a             	movzbl (%edx),%ebx
f010183e:	38 d9                	cmp    %bl,%cl
f0101840:	75 08                	jne    f010184a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0101842:	83 c0 01             	add    $0x1,%eax
f0101845:	83 c2 01             	add    $0x1,%edx
f0101848:	eb ea                	jmp    f0101834 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f010184a:	0f b6 c1             	movzbl %cl,%eax
f010184d:	0f b6 db             	movzbl %bl,%ebx
f0101850:	29 d8                	sub    %ebx,%eax
f0101852:	eb 05                	jmp    f0101859 <memcmp+0x35>
	}

	return 0;
f0101854:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101859:	5b                   	pop    %ebx
f010185a:	5e                   	pop    %esi
f010185b:	5d                   	pop    %ebp
f010185c:	c3                   	ret    

f010185d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010185d:	55                   	push   %ebp
f010185e:	89 e5                	mov    %esp,%ebp
f0101860:	8b 45 08             	mov    0x8(%ebp),%eax
f0101863:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101866:	89 c2                	mov    %eax,%edx
f0101868:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010186b:	39 d0                	cmp    %edx,%eax
f010186d:	73 09                	jae    f0101878 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f010186f:	38 08                	cmp    %cl,(%eax)
f0101871:	74 05                	je     f0101878 <memfind+0x1b>
	for (; s < ends; s++)
f0101873:	83 c0 01             	add    $0x1,%eax
f0101876:	eb f3                	jmp    f010186b <memfind+0xe>
			break;
	return (void *) s;
}
f0101878:	5d                   	pop    %ebp
f0101879:	c3                   	ret    

f010187a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010187a:	55                   	push   %ebp
f010187b:	89 e5                	mov    %esp,%ebp
f010187d:	57                   	push   %edi
f010187e:	56                   	push   %esi
f010187f:	53                   	push   %ebx
f0101880:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101883:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101886:	eb 03                	jmp    f010188b <strtol+0x11>
		s++;
f0101888:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f010188b:	0f b6 01             	movzbl (%ecx),%eax
f010188e:	3c 20                	cmp    $0x20,%al
f0101890:	74 f6                	je     f0101888 <strtol+0xe>
f0101892:	3c 09                	cmp    $0x9,%al
f0101894:	74 f2                	je     f0101888 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0101896:	3c 2b                	cmp    $0x2b,%al
f0101898:	74 2e                	je     f01018c8 <strtol+0x4e>
	int neg = 0;
f010189a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f010189f:	3c 2d                	cmp    $0x2d,%al
f01018a1:	74 2f                	je     f01018d2 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01018a3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01018a9:	75 05                	jne    f01018b0 <strtol+0x36>
f01018ab:	80 39 30             	cmpb   $0x30,(%ecx)
f01018ae:	74 2c                	je     f01018dc <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01018b0:	85 db                	test   %ebx,%ebx
f01018b2:	75 0a                	jne    f01018be <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01018b4:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f01018b9:	80 39 30             	cmpb   $0x30,(%ecx)
f01018bc:	74 28                	je     f01018e6 <strtol+0x6c>
		base = 10;
f01018be:	b8 00 00 00 00       	mov    $0x0,%eax
f01018c3:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01018c6:	eb 50                	jmp    f0101918 <strtol+0x9e>
		s++;
f01018c8:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01018cb:	bf 00 00 00 00       	mov    $0x0,%edi
f01018d0:	eb d1                	jmp    f01018a3 <strtol+0x29>
		s++, neg = 1;
f01018d2:	83 c1 01             	add    $0x1,%ecx
f01018d5:	bf 01 00 00 00       	mov    $0x1,%edi
f01018da:	eb c7                	jmp    f01018a3 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01018dc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01018e0:	74 0e                	je     f01018f0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01018e2:	85 db                	test   %ebx,%ebx
f01018e4:	75 d8                	jne    f01018be <strtol+0x44>
		s++, base = 8;
f01018e6:	83 c1 01             	add    $0x1,%ecx
f01018e9:	bb 08 00 00 00       	mov    $0x8,%ebx
f01018ee:	eb ce                	jmp    f01018be <strtol+0x44>
		s += 2, base = 16;
f01018f0:	83 c1 02             	add    $0x2,%ecx
f01018f3:	bb 10 00 00 00       	mov    $0x10,%ebx
f01018f8:	eb c4                	jmp    f01018be <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01018fa:	8d 72 9f             	lea    -0x61(%edx),%esi
f01018fd:	89 f3                	mov    %esi,%ebx
f01018ff:	80 fb 19             	cmp    $0x19,%bl
f0101902:	77 29                	ja     f010192d <strtol+0xb3>
			dig = *s - 'a' + 10;
f0101904:	0f be d2             	movsbl %dl,%edx
f0101907:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010190a:	3b 55 10             	cmp    0x10(%ebp),%edx
f010190d:	7d 30                	jge    f010193f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f010190f:	83 c1 01             	add    $0x1,%ecx
f0101912:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101916:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101918:	0f b6 11             	movzbl (%ecx),%edx
f010191b:	8d 72 d0             	lea    -0x30(%edx),%esi
f010191e:	89 f3                	mov    %esi,%ebx
f0101920:	80 fb 09             	cmp    $0x9,%bl
f0101923:	77 d5                	ja     f01018fa <strtol+0x80>
			dig = *s - '0';
f0101925:	0f be d2             	movsbl %dl,%edx
f0101928:	83 ea 30             	sub    $0x30,%edx
f010192b:	eb dd                	jmp    f010190a <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f010192d:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101930:	89 f3                	mov    %esi,%ebx
f0101932:	80 fb 19             	cmp    $0x19,%bl
f0101935:	77 08                	ja     f010193f <strtol+0xc5>
			dig = *s - 'A' + 10;
f0101937:	0f be d2             	movsbl %dl,%edx
f010193a:	83 ea 37             	sub    $0x37,%edx
f010193d:	eb cb                	jmp    f010190a <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f010193f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101943:	74 05                	je     f010194a <strtol+0xd0>
		*endptr = (char *) s;
f0101945:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101948:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010194a:	89 c2                	mov    %eax,%edx
f010194c:	f7 da                	neg    %edx
f010194e:	85 ff                	test   %edi,%edi
f0101950:	0f 45 c2             	cmovne %edx,%eax
}
f0101953:	5b                   	pop    %ebx
f0101954:	5e                   	pop    %esi
f0101955:	5f                   	pop    %edi
f0101956:	5d                   	pop    %ebp
f0101957:	c3                   	ret    
f0101958:	66 90                	xchg   %ax,%ax
f010195a:	66 90                	xchg   %ax,%ax
f010195c:	66 90                	xchg   %ax,%ax
f010195e:	66 90                	xchg   %ax,%ax

f0101960 <__udivdi3>:
f0101960:	55                   	push   %ebp
f0101961:	57                   	push   %edi
f0101962:	56                   	push   %esi
f0101963:	53                   	push   %ebx
f0101964:	83 ec 1c             	sub    $0x1c,%esp
f0101967:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010196b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010196f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101973:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101977:	85 d2                	test   %edx,%edx
f0101979:	75 35                	jne    f01019b0 <__udivdi3+0x50>
f010197b:	39 f3                	cmp    %esi,%ebx
f010197d:	0f 87 bd 00 00 00    	ja     f0101a40 <__udivdi3+0xe0>
f0101983:	85 db                	test   %ebx,%ebx
f0101985:	89 d9                	mov    %ebx,%ecx
f0101987:	75 0b                	jne    f0101994 <__udivdi3+0x34>
f0101989:	b8 01 00 00 00       	mov    $0x1,%eax
f010198e:	31 d2                	xor    %edx,%edx
f0101990:	f7 f3                	div    %ebx
f0101992:	89 c1                	mov    %eax,%ecx
f0101994:	31 d2                	xor    %edx,%edx
f0101996:	89 f0                	mov    %esi,%eax
f0101998:	f7 f1                	div    %ecx
f010199a:	89 c6                	mov    %eax,%esi
f010199c:	89 e8                	mov    %ebp,%eax
f010199e:	89 f7                	mov    %esi,%edi
f01019a0:	f7 f1                	div    %ecx
f01019a2:	89 fa                	mov    %edi,%edx
f01019a4:	83 c4 1c             	add    $0x1c,%esp
f01019a7:	5b                   	pop    %ebx
f01019a8:	5e                   	pop    %esi
f01019a9:	5f                   	pop    %edi
f01019aa:	5d                   	pop    %ebp
f01019ab:	c3                   	ret    
f01019ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019b0:	39 f2                	cmp    %esi,%edx
f01019b2:	77 7c                	ja     f0101a30 <__udivdi3+0xd0>
f01019b4:	0f bd fa             	bsr    %edx,%edi
f01019b7:	83 f7 1f             	xor    $0x1f,%edi
f01019ba:	0f 84 98 00 00 00    	je     f0101a58 <__udivdi3+0xf8>
f01019c0:	89 f9                	mov    %edi,%ecx
f01019c2:	b8 20 00 00 00       	mov    $0x20,%eax
f01019c7:	29 f8                	sub    %edi,%eax
f01019c9:	d3 e2                	shl    %cl,%edx
f01019cb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01019cf:	89 c1                	mov    %eax,%ecx
f01019d1:	89 da                	mov    %ebx,%edx
f01019d3:	d3 ea                	shr    %cl,%edx
f01019d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01019d9:	09 d1                	or     %edx,%ecx
f01019db:	89 f2                	mov    %esi,%edx
f01019dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01019e1:	89 f9                	mov    %edi,%ecx
f01019e3:	d3 e3                	shl    %cl,%ebx
f01019e5:	89 c1                	mov    %eax,%ecx
f01019e7:	d3 ea                	shr    %cl,%edx
f01019e9:	89 f9                	mov    %edi,%ecx
f01019eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01019ef:	d3 e6                	shl    %cl,%esi
f01019f1:	89 eb                	mov    %ebp,%ebx
f01019f3:	89 c1                	mov    %eax,%ecx
f01019f5:	d3 eb                	shr    %cl,%ebx
f01019f7:	09 de                	or     %ebx,%esi
f01019f9:	89 f0                	mov    %esi,%eax
f01019fb:	f7 74 24 08          	divl   0x8(%esp)
f01019ff:	89 d6                	mov    %edx,%esi
f0101a01:	89 c3                	mov    %eax,%ebx
f0101a03:	f7 64 24 0c          	mull   0xc(%esp)
f0101a07:	39 d6                	cmp    %edx,%esi
f0101a09:	72 0c                	jb     f0101a17 <__udivdi3+0xb7>
f0101a0b:	89 f9                	mov    %edi,%ecx
f0101a0d:	d3 e5                	shl    %cl,%ebp
f0101a0f:	39 c5                	cmp    %eax,%ebp
f0101a11:	73 5d                	jae    f0101a70 <__udivdi3+0x110>
f0101a13:	39 d6                	cmp    %edx,%esi
f0101a15:	75 59                	jne    f0101a70 <__udivdi3+0x110>
f0101a17:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101a1a:	31 ff                	xor    %edi,%edi
f0101a1c:	89 fa                	mov    %edi,%edx
f0101a1e:	83 c4 1c             	add    $0x1c,%esp
f0101a21:	5b                   	pop    %ebx
f0101a22:	5e                   	pop    %esi
f0101a23:	5f                   	pop    %edi
f0101a24:	5d                   	pop    %ebp
f0101a25:	c3                   	ret    
f0101a26:	8d 76 00             	lea    0x0(%esi),%esi
f0101a29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0101a30:	31 ff                	xor    %edi,%edi
f0101a32:	31 c0                	xor    %eax,%eax
f0101a34:	89 fa                	mov    %edi,%edx
f0101a36:	83 c4 1c             	add    $0x1c,%esp
f0101a39:	5b                   	pop    %ebx
f0101a3a:	5e                   	pop    %esi
f0101a3b:	5f                   	pop    %edi
f0101a3c:	5d                   	pop    %ebp
f0101a3d:	c3                   	ret    
f0101a3e:	66 90                	xchg   %ax,%ax
f0101a40:	31 ff                	xor    %edi,%edi
f0101a42:	89 e8                	mov    %ebp,%eax
f0101a44:	89 f2                	mov    %esi,%edx
f0101a46:	f7 f3                	div    %ebx
f0101a48:	89 fa                	mov    %edi,%edx
f0101a4a:	83 c4 1c             	add    $0x1c,%esp
f0101a4d:	5b                   	pop    %ebx
f0101a4e:	5e                   	pop    %esi
f0101a4f:	5f                   	pop    %edi
f0101a50:	5d                   	pop    %ebp
f0101a51:	c3                   	ret    
f0101a52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a58:	39 f2                	cmp    %esi,%edx
f0101a5a:	72 06                	jb     f0101a62 <__udivdi3+0x102>
f0101a5c:	31 c0                	xor    %eax,%eax
f0101a5e:	39 eb                	cmp    %ebp,%ebx
f0101a60:	77 d2                	ja     f0101a34 <__udivdi3+0xd4>
f0101a62:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a67:	eb cb                	jmp    f0101a34 <__udivdi3+0xd4>
f0101a69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a70:	89 d8                	mov    %ebx,%eax
f0101a72:	31 ff                	xor    %edi,%edi
f0101a74:	eb be                	jmp    f0101a34 <__udivdi3+0xd4>
f0101a76:	66 90                	xchg   %ax,%ax
f0101a78:	66 90                	xchg   %ax,%ax
f0101a7a:	66 90                	xchg   %ax,%ax
f0101a7c:	66 90                	xchg   %ax,%ax
f0101a7e:	66 90                	xchg   %ax,%ax

f0101a80 <__umoddi3>:
f0101a80:	55                   	push   %ebp
f0101a81:	57                   	push   %edi
f0101a82:	56                   	push   %esi
f0101a83:	53                   	push   %ebx
f0101a84:	83 ec 1c             	sub    $0x1c,%esp
f0101a87:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0101a8b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101a8f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101a93:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101a97:	85 ed                	test   %ebp,%ebp
f0101a99:	89 f0                	mov    %esi,%eax
f0101a9b:	89 da                	mov    %ebx,%edx
f0101a9d:	75 19                	jne    f0101ab8 <__umoddi3+0x38>
f0101a9f:	39 df                	cmp    %ebx,%edi
f0101aa1:	0f 86 b1 00 00 00    	jbe    f0101b58 <__umoddi3+0xd8>
f0101aa7:	f7 f7                	div    %edi
f0101aa9:	89 d0                	mov    %edx,%eax
f0101aab:	31 d2                	xor    %edx,%edx
f0101aad:	83 c4 1c             	add    $0x1c,%esp
f0101ab0:	5b                   	pop    %ebx
f0101ab1:	5e                   	pop    %esi
f0101ab2:	5f                   	pop    %edi
f0101ab3:	5d                   	pop    %ebp
f0101ab4:	c3                   	ret    
f0101ab5:	8d 76 00             	lea    0x0(%esi),%esi
f0101ab8:	39 dd                	cmp    %ebx,%ebp
f0101aba:	77 f1                	ja     f0101aad <__umoddi3+0x2d>
f0101abc:	0f bd cd             	bsr    %ebp,%ecx
f0101abf:	83 f1 1f             	xor    $0x1f,%ecx
f0101ac2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101ac6:	0f 84 b4 00 00 00    	je     f0101b80 <__umoddi3+0x100>
f0101acc:	b8 20 00 00 00       	mov    $0x20,%eax
f0101ad1:	89 c2                	mov    %eax,%edx
f0101ad3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101ad7:	29 c2                	sub    %eax,%edx
f0101ad9:	89 c1                	mov    %eax,%ecx
f0101adb:	89 f8                	mov    %edi,%eax
f0101add:	d3 e5                	shl    %cl,%ebp
f0101adf:	89 d1                	mov    %edx,%ecx
f0101ae1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101ae5:	d3 e8                	shr    %cl,%eax
f0101ae7:	09 c5                	or     %eax,%ebp
f0101ae9:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101aed:	89 c1                	mov    %eax,%ecx
f0101aef:	d3 e7                	shl    %cl,%edi
f0101af1:	89 d1                	mov    %edx,%ecx
f0101af3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101af7:	89 df                	mov    %ebx,%edi
f0101af9:	d3 ef                	shr    %cl,%edi
f0101afb:	89 c1                	mov    %eax,%ecx
f0101afd:	89 f0                	mov    %esi,%eax
f0101aff:	d3 e3                	shl    %cl,%ebx
f0101b01:	89 d1                	mov    %edx,%ecx
f0101b03:	89 fa                	mov    %edi,%edx
f0101b05:	d3 e8                	shr    %cl,%eax
f0101b07:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101b0c:	09 d8                	or     %ebx,%eax
f0101b0e:	f7 f5                	div    %ebp
f0101b10:	d3 e6                	shl    %cl,%esi
f0101b12:	89 d1                	mov    %edx,%ecx
f0101b14:	f7 64 24 08          	mull   0x8(%esp)
f0101b18:	39 d1                	cmp    %edx,%ecx
f0101b1a:	89 c3                	mov    %eax,%ebx
f0101b1c:	89 d7                	mov    %edx,%edi
f0101b1e:	72 06                	jb     f0101b26 <__umoddi3+0xa6>
f0101b20:	75 0e                	jne    f0101b30 <__umoddi3+0xb0>
f0101b22:	39 c6                	cmp    %eax,%esi
f0101b24:	73 0a                	jae    f0101b30 <__umoddi3+0xb0>
f0101b26:	2b 44 24 08          	sub    0x8(%esp),%eax
f0101b2a:	19 ea                	sbb    %ebp,%edx
f0101b2c:	89 d7                	mov    %edx,%edi
f0101b2e:	89 c3                	mov    %eax,%ebx
f0101b30:	89 ca                	mov    %ecx,%edx
f0101b32:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101b37:	29 de                	sub    %ebx,%esi
f0101b39:	19 fa                	sbb    %edi,%edx
f0101b3b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0101b3f:	89 d0                	mov    %edx,%eax
f0101b41:	d3 e0                	shl    %cl,%eax
f0101b43:	89 d9                	mov    %ebx,%ecx
f0101b45:	d3 ee                	shr    %cl,%esi
f0101b47:	d3 ea                	shr    %cl,%edx
f0101b49:	09 f0                	or     %esi,%eax
f0101b4b:	83 c4 1c             	add    $0x1c,%esp
f0101b4e:	5b                   	pop    %ebx
f0101b4f:	5e                   	pop    %esi
f0101b50:	5f                   	pop    %edi
f0101b51:	5d                   	pop    %ebp
f0101b52:	c3                   	ret    
f0101b53:	90                   	nop
f0101b54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b58:	85 ff                	test   %edi,%edi
f0101b5a:	89 f9                	mov    %edi,%ecx
f0101b5c:	75 0b                	jne    f0101b69 <__umoddi3+0xe9>
f0101b5e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b63:	31 d2                	xor    %edx,%edx
f0101b65:	f7 f7                	div    %edi
f0101b67:	89 c1                	mov    %eax,%ecx
f0101b69:	89 d8                	mov    %ebx,%eax
f0101b6b:	31 d2                	xor    %edx,%edx
f0101b6d:	f7 f1                	div    %ecx
f0101b6f:	89 f0                	mov    %esi,%eax
f0101b71:	f7 f1                	div    %ecx
f0101b73:	e9 31 ff ff ff       	jmp    f0101aa9 <__umoddi3+0x29>
f0101b78:	90                   	nop
f0101b79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b80:	39 dd                	cmp    %ebx,%ebp
f0101b82:	72 08                	jb     f0101b8c <__umoddi3+0x10c>
f0101b84:	39 f7                	cmp    %esi,%edi
f0101b86:	0f 87 21 ff ff ff    	ja     f0101aad <__umoddi3+0x2d>
f0101b8c:	89 da                	mov    %ebx,%edx
f0101b8e:	89 f0                	mov    %esi,%eax
f0101b90:	29 f8                	sub    %edi,%eax
f0101b92:	19 ea                	sbb    %ebp,%edx
f0101b94:	e9 14 ff ff ff       	jmp    f0101aad <__umoddi3+0x2d>
