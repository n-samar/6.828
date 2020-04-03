
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
f0100015:	b8 00 20 18 00       	mov    $0x182000,%eax
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
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
f0100047:	e8 1b 01 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f010004c:	81 c3 d4 0f 08 00    	add    $0x80fd4,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 00 40 18 f0    	mov    $0xf0184000,%eax
f0100058:	c7 c2 00 31 18 f0    	mov    $0xf0183100,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 09 51 00 00       	call   f0105172 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 4e 05 00 00       	call   f01005bc <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 a0 45 f8 ff    	lea    -0x7ba60(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 76 3a 00 00       	call   f0103af8 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 55 13 00 00       	call   f01013dc <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100087:	e8 9b 33 00 00       	call   f0103427 <env_init>
	trap_init();
f010008c:	e8 1a 3b 00 00       	call   f0103bab <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100091:	83 c4 08             	add    $0x8,%esp
f0100094:	6a 00                	push   $0x0
f0100096:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f010009c:	e8 8a 35 00 00       	call   f010362b <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a1:	83 c4 04             	add    $0x4,%esp
f01000a4:	c7 c0 4c 33 18 f0    	mov    $0xf018334c,%eax
f01000aa:	ff 30                	pushl  (%eax)
f01000ac:	e8 47 39 00 00       	call   f01039f8 <env_run>

f01000b1 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000b1:	55                   	push   %ebp
f01000b2:	89 e5                	mov    %esp,%ebp
f01000b4:	57                   	push   %edi
f01000b5:	56                   	push   %esi
f01000b6:	53                   	push   %ebx
f01000b7:	83 ec 0c             	sub    $0xc,%esp
f01000ba:	e8 a8 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f01000bf:	81 c3 61 0f 08 00    	add    $0x80f61,%ebx
f01000c5:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f01000c8:	c7 c0 04 40 18 f0    	mov    $0xf0184004,%eax
f01000ce:	83 38 00             	cmpl   $0x0,(%eax)
f01000d1:	74 0f                	je     f01000e2 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 fa 07 00 00       	call   f01008d7 <monitor>
f01000dd:	83 c4 10             	add    $0x10,%esp
f01000e0:	eb f1                	jmp    f01000d3 <_panic+0x22>
	panicstr = fmt;
f01000e2:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f01000e4:	fa                   	cli    
f01000e5:	fc                   	cld    
	va_start(ap, fmt);
f01000e6:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f01000e9:	83 ec 04             	sub    $0x4,%esp
f01000ec:	ff 75 0c             	pushl  0xc(%ebp)
f01000ef:	ff 75 08             	pushl  0x8(%ebp)
f01000f2:	8d 83 bb 45 f8 ff    	lea    -0x7ba45(%ebx),%eax
f01000f8:	50                   	push   %eax
f01000f9:	e8 fa 39 00 00       	call   f0103af8 <cprintf>
	vcprintf(fmt, ap);
f01000fe:	83 c4 08             	add    $0x8,%esp
f0100101:	56                   	push   %esi
f0100102:	57                   	push   %edi
f0100103:	e8 b9 39 00 00       	call   f0103ac1 <vcprintf>
	cprintf("\n");
f0100108:	8d 83 89 48 f8 ff    	lea    -0x7b777(%ebx),%eax
f010010e:	89 04 24             	mov    %eax,(%esp)
f0100111:	e8 e2 39 00 00       	call   f0103af8 <cprintf>
f0100116:	83 c4 10             	add    $0x10,%esp
f0100119:	eb b8                	jmp    f01000d3 <_panic+0x22>

f010011b <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010011b:	55                   	push   %ebp
f010011c:	89 e5                	mov    %esp,%ebp
f010011e:	56                   	push   %esi
f010011f:	53                   	push   %ebx
f0100120:	e8 42 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100125:	81 c3 fb 0e 08 00    	add    $0x80efb,%ebx
	va_list ap;

	va_start(ap, fmt);
f010012b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010012e:	83 ec 04             	sub    $0x4,%esp
f0100131:	ff 75 0c             	pushl  0xc(%ebp)
f0100134:	ff 75 08             	pushl  0x8(%ebp)
f0100137:	8d 83 d3 45 f8 ff    	lea    -0x7ba2d(%ebx),%eax
f010013d:	50                   	push   %eax
f010013e:	e8 b5 39 00 00       	call   f0103af8 <cprintf>
	vcprintf(fmt, ap);
f0100143:	83 c4 08             	add    $0x8,%esp
f0100146:	56                   	push   %esi
f0100147:	ff 75 10             	pushl  0x10(%ebp)
f010014a:	e8 72 39 00 00       	call   f0103ac1 <vcprintf>
	cprintf("\n");
f010014f:	8d 83 89 48 f8 ff    	lea    -0x7b777(%ebx),%eax
f0100155:	89 04 24             	mov    %eax,(%esp)
f0100158:	e8 9b 39 00 00       	call   f0103af8 <cprintf>
	va_end(ap);
}
f010015d:	83 c4 10             	add    $0x10,%esp
f0100160:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100163:	5b                   	pop    %ebx
f0100164:	5e                   	pop    %esi
f0100165:	5d                   	pop    %ebp
f0100166:	c3                   	ret    

f0100167 <__x86.get_pc_thunk.bx>:
f0100167:	8b 1c 24             	mov    (%esp),%ebx
f010016a:	c3                   	ret    

f010016b <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010016b:	55                   	push   %ebp
f010016c:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010016e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100173:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100174:	a8 01                	test   $0x1,%al
f0100176:	74 0b                	je     f0100183 <serial_proc_data+0x18>
f0100178:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010017d:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010017e:	0f b6 c0             	movzbl %al,%eax
}
f0100181:	5d                   	pop    %ebp
f0100182:	c3                   	ret    
		return -1;
f0100183:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100188:	eb f7                	jmp    f0100181 <serial_proc_data+0x16>

f010018a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010018a:	55                   	push   %ebp
f010018b:	89 e5                	mov    %esp,%ebp
f010018d:	56                   	push   %esi
f010018e:	53                   	push   %ebx
f010018f:	e8 d3 ff ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100194:	81 c3 8c 0e 08 00    	add    $0x80e8c,%ebx
f010019a:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f010019c:	ff d6                	call   *%esi
f010019e:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001a1:	74 2e                	je     f01001d1 <cons_intr+0x47>
		if (c == 0)
f01001a3:	85 c0                	test   %eax,%eax
f01001a5:	74 f5                	je     f010019c <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a7:	8b 8b 04 23 00 00    	mov    0x2304(%ebx),%ecx
f01001ad:	8d 51 01             	lea    0x1(%ecx),%edx
f01001b0:	89 93 04 23 00 00    	mov    %edx,0x2304(%ebx)
f01001b6:	88 84 0b 00 21 00 00 	mov    %al,0x2100(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001bd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c3:	75 d7                	jne    f010019c <cons_intr+0x12>
			cons.wpos = 0;
f01001c5:	c7 83 04 23 00 00 00 	movl   $0x0,0x2304(%ebx)
f01001cc:	00 00 00 
f01001cf:	eb cb                	jmp    f010019c <cons_intr+0x12>
	}
}
f01001d1:	5b                   	pop    %ebx
f01001d2:	5e                   	pop    %esi
f01001d3:	5d                   	pop    %ebp
f01001d4:	c3                   	ret    

f01001d5 <kbd_proc_data>:
{
f01001d5:	55                   	push   %ebp
f01001d6:	89 e5                	mov    %esp,%ebp
f01001d8:	56                   	push   %esi
f01001d9:	53                   	push   %ebx
f01001da:	e8 88 ff ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01001df:	81 c3 41 0e 08 00    	add    $0x80e41,%ebx
f01001e5:	ba 64 00 00 00       	mov    $0x64,%edx
f01001ea:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01001eb:	a8 01                	test   $0x1,%al
f01001ed:	0f 84 06 01 00 00    	je     f01002f9 <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f01001f3:	a8 20                	test   $0x20,%al
f01001f5:	0f 85 05 01 00 00    	jne    f0100300 <kbd_proc_data+0x12b>
f01001fb:	ba 60 00 00 00       	mov    $0x60,%edx
f0100200:	ec                   	in     (%dx),%al
f0100201:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100203:	3c e0                	cmp    $0xe0,%al
f0100205:	0f 84 93 00 00 00    	je     f010029e <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f010020b:	84 c0                	test   %al,%al
f010020d:	0f 88 a0 00 00 00    	js     f01002b3 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100213:	8b 8b e0 20 00 00    	mov    0x20e0(%ebx),%ecx
f0100219:	f6 c1 40             	test   $0x40,%cl
f010021c:	74 0e                	je     f010022c <kbd_proc_data+0x57>
		data |= 0x80;
f010021e:	83 c8 80             	or     $0xffffff80,%eax
f0100221:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100223:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100226:	89 8b e0 20 00 00    	mov    %ecx,0x20e0(%ebx)
	shift |= shiftcode[data];
f010022c:	0f b6 d2             	movzbl %dl,%edx
f010022f:	0f b6 84 13 20 47 f8 	movzbl -0x7b8e0(%ebx,%edx,1),%eax
f0100236:	ff 
f0100237:	0b 83 e0 20 00 00    	or     0x20e0(%ebx),%eax
	shift ^= togglecode[data];
f010023d:	0f b6 8c 13 20 46 f8 	movzbl -0x7b9e0(%ebx,%edx,1),%ecx
f0100244:	ff 
f0100245:	31 c8                	xor    %ecx,%eax
f0100247:	89 83 e0 20 00 00    	mov    %eax,0x20e0(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f010024d:	89 c1                	mov    %eax,%ecx
f010024f:	83 e1 03             	and    $0x3,%ecx
f0100252:	8b 8c 8b 00 20 00 00 	mov    0x2000(%ebx,%ecx,4),%ecx
f0100259:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010025d:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f0100260:	a8 08                	test   $0x8,%al
f0100262:	74 0d                	je     f0100271 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f0100264:	89 f2                	mov    %esi,%edx
f0100266:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f0100269:	83 f9 19             	cmp    $0x19,%ecx
f010026c:	77 7a                	ja     f01002e8 <kbd_proc_data+0x113>
			c += 'A' - 'a';
f010026e:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100271:	f7 d0                	not    %eax
f0100273:	a8 06                	test   $0x6,%al
f0100275:	75 33                	jne    f01002aa <kbd_proc_data+0xd5>
f0100277:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010027d:	75 2b                	jne    f01002aa <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f010027f:	83 ec 0c             	sub    $0xc,%esp
f0100282:	8d 83 ed 45 f8 ff    	lea    -0x7ba13(%ebx),%eax
f0100288:	50                   	push   %eax
f0100289:	e8 6a 38 00 00       	call   f0103af8 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010028e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100293:	ba 92 00 00 00       	mov    $0x92,%edx
f0100298:	ee                   	out    %al,(%dx)
f0100299:	83 c4 10             	add    $0x10,%esp
f010029c:	eb 0c                	jmp    f01002aa <kbd_proc_data+0xd5>
		shift |= E0ESC;
f010029e:	83 8b e0 20 00 00 40 	orl    $0x40,0x20e0(%ebx)
		return 0;
f01002a5:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002aa:	89 f0                	mov    %esi,%eax
f01002ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002af:	5b                   	pop    %ebx
f01002b0:	5e                   	pop    %esi
f01002b1:	5d                   	pop    %ebp
f01002b2:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002b3:	8b 8b e0 20 00 00    	mov    0x20e0(%ebx),%ecx
f01002b9:	89 ce                	mov    %ecx,%esi
f01002bb:	83 e6 40             	and    $0x40,%esi
f01002be:	83 e0 7f             	and    $0x7f,%eax
f01002c1:	85 f6                	test   %esi,%esi
f01002c3:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002c6:	0f b6 d2             	movzbl %dl,%edx
f01002c9:	0f b6 84 13 20 47 f8 	movzbl -0x7b8e0(%ebx,%edx,1),%eax
f01002d0:	ff 
f01002d1:	83 c8 40             	or     $0x40,%eax
f01002d4:	0f b6 c0             	movzbl %al,%eax
f01002d7:	f7 d0                	not    %eax
f01002d9:	21 c8                	and    %ecx,%eax
f01002db:	89 83 e0 20 00 00    	mov    %eax,0x20e0(%ebx)
		return 0;
f01002e1:	be 00 00 00 00       	mov    $0x0,%esi
f01002e6:	eb c2                	jmp    f01002aa <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f01002e8:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002eb:	8d 4e 20             	lea    0x20(%esi),%ecx
f01002ee:	83 fa 1a             	cmp    $0x1a,%edx
f01002f1:	0f 42 f1             	cmovb  %ecx,%esi
f01002f4:	e9 78 ff ff ff       	jmp    f0100271 <kbd_proc_data+0x9c>
		return -1;
f01002f9:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01002fe:	eb aa                	jmp    f01002aa <kbd_proc_data+0xd5>
		return -1;
f0100300:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100305:	eb a3                	jmp    f01002aa <kbd_proc_data+0xd5>

f0100307 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100307:	55                   	push   %ebp
f0100308:	89 e5                	mov    %esp,%ebp
f010030a:	57                   	push   %edi
f010030b:	56                   	push   %esi
f010030c:	53                   	push   %ebx
f010030d:	83 ec 1c             	sub    $0x1c,%esp
f0100310:	e8 52 fe ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100315:	81 c3 0b 0d 08 00    	add    $0x80d0b,%ebx
f010031b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f010031e:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100323:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100328:	b9 84 00 00 00       	mov    $0x84,%ecx
f010032d:	eb 09                	jmp    f0100338 <cons_putc+0x31>
f010032f:	89 ca                	mov    %ecx,%edx
f0100331:	ec                   	in     (%dx),%al
f0100332:	ec                   	in     (%dx),%al
f0100333:	ec                   	in     (%dx),%al
f0100334:	ec                   	in     (%dx),%al
	     i++)
f0100335:	83 c6 01             	add    $0x1,%esi
f0100338:	89 fa                	mov    %edi,%edx
f010033a:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010033b:	a8 20                	test   $0x20,%al
f010033d:	75 08                	jne    f0100347 <cons_putc+0x40>
f010033f:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100345:	7e e8                	jle    f010032f <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f0100347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010034a:	89 f8                	mov    %edi,%eax
f010034c:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010034f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100354:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100355:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010035a:	bf 79 03 00 00       	mov    $0x379,%edi
f010035f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100364:	eb 09                	jmp    f010036f <cons_putc+0x68>
f0100366:	89 ca                	mov    %ecx,%edx
f0100368:	ec                   	in     (%dx),%al
f0100369:	ec                   	in     (%dx),%al
f010036a:	ec                   	in     (%dx),%al
f010036b:	ec                   	in     (%dx),%al
f010036c:	83 c6 01             	add    $0x1,%esi
f010036f:	89 fa                	mov    %edi,%edx
f0100371:	ec                   	in     (%dx),%al
f0100372:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100378:	7f 04                	jg     f010037e <cons_putc+0x77>
f010037a:	84 c0                	test   %al,%al
f010037c:	79 e8                	jns    f0100366 <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010037e:	ba 78 03 00 00       	mov    $0x378,%edx
f0100383:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0100387:	ee                   	out    %al,(%dx)
f0100388:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010038d:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100392:	ee                   	out    %al,(%dx)
f0100393:	b8 08 00 00 00       	mov    $0x8,%eax
f0100398:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010039c:	89 fa                	mov    %edi,%edx
f010039e:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003a4:	89 f8                	mov    %edi,%eax
f01003a6:	80 cc 07             	or     $0x7,%ah
f01003a9:	85 d2                	test   %edx,%edx
f01003ab:	0f 45 c7             	cmovne %edi,%eax
f01003ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f01003b1:	0f b6 c0             	movzbl %al,%eax
f01003b4:	83 f8 09             	cmp    $0x9,%eax
f01003b7:	0f 84 b9 00 00 00    	je     f0100476 <cons_putc+0x16f>
f01003bd:	83 f8 09             	cmp    $0x9,%eax
f01003c0:	7e 74                	jle    f0100436 <cons_putc+0x12f>
f01003c2:	83 f8 0a             	cmp    $0xa,%eax
f01003c5:	0f 84 9e 00 00 00    	je     f0100469 <cons_putc+0x162>
f01003cb:	83 f8 0d             	cmp    $0xd,%eax
f01003ce:	0f 85 d9 00 00 00    	jne    f01004ad <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f01003d4:	0f b7 83 08 23 00 00 	movzwl 0x2308(%ebx),%eax
f01003db:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003e1:	c1 e8 16             	shr    $0x16,%eax
f01003e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003e7:	c1 e0 04             	shl    $0x4,%eax
f01003ea:	66 89 83 08 23 00 00 	mov    %ax,0x2308(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01003f1:	66 81 bb 08 23 00 00 	cmpw   $0x7cf,0x2308(%ebx)
f01003f8:	cf 07 
f01003fa:	0f 87 d4 00 00 00    	ja     f01004d4 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100400:	8b 8b 10 23 00 00    	mov    0x2310(%ebx),%ecx
f0100406:	b8 0e 00 00 00       	mov    $0xe,%eax
f010040b:	89 ca                	mov    %ecx,%edx
f010040d:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010040e:	0f b7 9b 08 23 00 00 	movzwl 0x2308(%ebx),%ebx
f0100415:	8d 71 01             	lea    0x1(%ecx),%esi
f0100418:	89 d8                	mov    %ebx,%eax
f010041a:	66 c1 e8 08          	shr    $0x8,%ax
f010041e:	89 f2                	mov    %esi,%edx
f0100420:	ee                   	out    %al,(%dx)
f0100421:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100426:	89 ca                	mov    %ecx,%edx
f0100428:	ee                   	out    %al,(%dx)
f0100429:	89 d8                	mov    %ebx,%eax
f010042b:	89 f2                	mov    %esi,%edx
f010042d:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010042e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100431:	5b                   	pop    %ebx
f0100432:	5e                   	pop    %esi
f0100433:	5f                   	pop    %edi
f0100434:	5d                   	pop    %ebp
f0100435:	c3                   	ret    
	switch (c & 0xff) {
f0100436:	83 f8 08             	cmp    $0x8,%eax
f0100439:	75 72                	jne    f01004ad <cons_putc+0x1a6>
		if (crt_pos > 0) {
f010043b:	0f b7 83 08 23 00 00 	movzwl 0x2308(%ebx),%eax
f0100442:	66 85 c0             	test   %ax,%ax
f0100445:	74 b9                	je     f0100400 <cons_putc+0xf9>
			crt_pos--;
f0100447:	83 e8 01             	sub    $0x1,%eax
f010044a:	66 89 83 08 23 00 00 	mov    %ax,0x2308(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100451:	0f b7 c0             	movzwl %ax,%eax
f0100454:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100458:	b2 00                	mov    $0x0,%dl
f010045a:	83 ca 20             	or     $0x20,%edx
f010045d:	8b 8b 0c 23 00 00    	mov    0x230c(%ebx),%ecx
f0100463:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100467:	eb 88                	jmp    f01003f1 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f0100469:	66 83 83 08 23 00 00 	addw   $0x50,0x2308(%ebx)
f0100470:	50 
f0100471:	e9 5e ff ff ff       	jmp    f01003d4 <cons_putc+0xcd>
		cons_putc(' ');
f0100476:	b8 20 00 00 00       	mov    $0x20,%eax
f010047b:	e8 87 fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f0100480:	b8 20 00 00 00       	mov    $0x20,%eax
f0100485:	e8 7d fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f010048a:	b8 20 00 00 00       	mov    $0x20,%eax
f010048f:	e8 73 fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f0100494:	b8 20 00 00 00       	mov    $0x20,%eax
f0100499:	e8 69 fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f010049e:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a3:	e8 5f fe ff ff       	call   f0100307 <cons_putc>
f01004a8:	e9 44 ff ff ff       	jmp    f01003f1 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004ad:	0f b7 83 08 23 00 00 	movzwl 0x2308(%ebx),%eax
f01004b4:	8d 50 01             	lea    0x1(%eax),%edx
f01004b7:	66 89 93 08 23 00 00 	mov    %dx,0x2308(%ebx)
f01004be:	0f b7 c0             	movzwl %ax,%eax
f01004c1:	8b 93 0c 23 00 00    	mov    0x230c(%ebx),%edx
f01004c7:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004cb:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004cf:	e9 1d ff ff ff       	jmp    f01003f1 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004d4:	8b 83 0c 23 00 00    	mov    0x230c(%ebx),%eax
f01004da:	83 ec 04             	sub    $0x4,%esp
f01004dd:	68 00 0f 00 00       	push   $0xf00
f01004e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004e8:	52                   	push   %edx
f01004e9:	50                   	push   %eax
f01004ea:	e8 d0 4c 00 00       	call   f01051bf <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004ef:	8b 93 0c 23 00 00    	mov    0x230c(%ebx),%edx
f01004f5:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004fb:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100501:	83 c4 10             	add    $0x10,%esp
f0100504:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100509:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010050c:	39 d0                	cmp    %edx,%eax
f010050e:	75 f4                	jne    f0100504 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100510:	66 83 ab 08 23 00 00 	subw   $0x50,0x2308(%ebx)
f0100517:	50 
f0100518:	e9 e3 fe ff ff       	jmp    f0100400 <cons_putc+0xf9>

f010051d <serial_intr>:
{
f010051d:	e8 e7 01 00 00       	call   f0100709 <__x86.get_pc_thunk.ax>
f0100522:	05 fe 0a 08 00       	add    $0x80afe,%eax
	if (serial_exists)
f0100527:	80 b8 14 23 00 00 00 	cmpb   $0x0,0x2314(%eax)
f010052e:	75 02                	jne    f0100532 <serial_intr+0x15>
f0100530:	f3 c3                	repz ret 
{
f0100532:	55                   	push   %ebp
f0100533:	89 e5                	mov    %esp,%ebp
f0100535:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100538:	8d 80 4b f1 f7 ff    	lea    -0x80eb5(%eax),%eax
f010053e:	e8 47 fc ff ff       	call   f010018a <cons_intr>
}
f0100543:	c9                   	leave  
f0100544:	c3                   	ret    

f0100545 <kbd_intr>:
{
f0100545:	55                   	push   %ebp
f0100546:	89 e5                	mov    %esp,%ebp
f0100548:	83 ec 08             	sub    $0x8,%esp
f010054b:	e8 b9 01 00 00       	call   f0100709 <__x86.get_pc_thunk.ax>
f0100550:	05 d0 0a 08 00       	add    $0x80ad0,%eax
	cons_intr(kbd_proc_data);
f0100555:	8d 80 b5 f1 f7 ff    	lea    -0x80e4b(%eax),%eax
f010055b:	e8 2a fc ff ff       	call   f010018a <cons_intr>
}
f0100560:	c9                   	leave  
f0100561:	c3                   	ret    

f0100562 <cons_getc>:
{
f0100562:	55                   	push   %ebp
f0100563:	89 e5                	mov    %esp,%ebp
f0100565:	53                   	push   %ebx
f0100566:	83 ec 04             	sub    $0x4,%esp
f0100569:	e8 f9 fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010056e:	81 c3 b2 0a 08 00    	add    $0x80ab2,%ebx
	serial_intr();
f0100574:	e8 a4 ff ff ff       	call   f010051d <serial_intr>
	kbd_intr();
f0100579:	e8 c7 ff ff ff       	call   f0100545 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f010057e:	8b 93 00 23 00 00    	mov    0x2300(%ebx),%edx
	return 0;
f0100584:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f0100589:	3b 93 04 23 00 00    	cmp    0x2304(%ebx),%edx
f010058f:	74 19                	je     f01005aa <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f0100591:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100594:	89 8b 00 23 00 00    	mov    %ecx,0x2300(%ebx)
f010059a:	0f b6 84 13 00 21 00 	movzbl 0x2100(%ebx,%edx,1),%eax
f01005a1:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005a2:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005a8:	74 06                	je     f01005b0 <cons_getc+0x4e>
}
f01005aa:	83 c4 04             	add    $0x4,%esp
f01005ad:	5b                   	pop    %ebx
f01005ae:	5d                   	pop    %ebp
f01005af:	c3                   	ret    
			cons.rpos = 0;
f01005b0:	c7 83 00 23 00 00 00 	movl   $0x0,0x2300(%ebx)
f01005b7:	00 00 00 
f01005ba:	eb ee                	jmp    f01005aa <cons_getc+0x48>

f01005bc <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005bc:	55                   	push   %ebp
f01005bd:	89 e5                	mov    %esp,%ebp
f01005bf:	57                   	push   %edi
f01005c0:	56                   	push   %esi
f01005c1:	53                   	push   %ebx
f01005c2:	83 ec 1c             	sub    $0x1c,%esp
f01005c5:	e8 9d fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01005ca:	81 c3 56 0a 08 00    	add    $0x80a56,%ebx
	was = *cp;
f01005d0:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005d7:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005de:	5a a5 
	if (*cp != 0xA55A) {
f01005e0:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005e7:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005eb:	0f 84 bc 00 00 00    	je     f01006ad <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f01005f1:	c7 83 10 23 00 00 b4 	movl   $0x3b4,0x2310(%ebx)
f01005f8:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005fb:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100602:	8b bb 10 23 00 00    	mov    0x2310(%ebx),%edi
f0100608:	b8 0e 00 00 00       	mov    $0xe,%eax
f010060d:	89 fa                	mov    %edi,%edx
f010060f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100610:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100613:	89 ca                	mov    %ecx,%edx
f0100615:	ec                   	in     (%dx),%al
f0100616:	0f b6 f0             	movzbl %al,%esi
f0100619:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010061c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100621:	89 fa                	mov    %edi,%edx
f0100623:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100624:	89 ca                	mov    %ecx,%edx
f0100626:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100627:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010062a:	89 bb 0c 23 00 00    	mov    %edi,0x230c(%ebx)
	pos |= inb(addr_6845 + 1);
f0100630:	0f b6 c0             	movzbl %al,%eax
f0100633:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f0100635:	66 89 b3 08 23 00 00 	mov    %si,0x2308(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010063c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100641:	89 c8                	mov    %ecx,%eax
f0100643:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100648:	ee                   	out    %al,(%dx)
f0100649:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010064e:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100653:	89 fa                	mov    %edi,%edx
f0100655:	ee                   	out    %al,(%dx)
f0100656:	b8 0c 00 00 00       	mov    $0xc,%eax
f010065b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100660:	ee                   	out    %al,(%dx)
f0100661:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100666:	89 c8                	mov    %ecx,%eax
f0100668:	89 f2                	mov    %esi,%edx
f010066a:	ee                   	out    %al,(%dx)
f010066b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100670:	89 fa                	mov    %edi,%edx
f0100672:	ee                   	out    %al,(%dx)
f0100673:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100678:	89 c8                	mov    %ecx,%eax
f010067a:	ee                   	out    %al,(%dx)
f010067b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100680:	89 f2                	mov    %esi,%edx
f0100682:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100683:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100688:	ec                   	in     (%dx),%al
f0100689:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010068b:	3c ff                	cmp    $0xff,%al
f010068d:	0f 95 83 14 23 00 00 	setne  0x2314(%ebx)
f0100694:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100699:	ec                   	in     (%dx),%al
f010069a:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010069f:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006a0:	80 f9 ff             	cmp    $0xff,%cl
f01006a3:	74 25                	je     f01006ca <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006a8:	5b                   	pop    %ebx
f01006a9:	5e                   	pop    %esi
f01006aa:	5f                   	pop    %edi
f01006ab:	5d                   	pop    %ebp
f01006ac:	c3                   	ret    
		*cp = was;
f01006ad:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006b4:	c7 83 10 23 00 00 d4 	movl   $0x3d4,0x2310(%ebx)
f01006bb:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006be:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f01006c5:	e9 38 ff ff ff       	jmp    f0100602 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f01006ca:	83 ec 0c             	sub    $0xc,%esp
f01006cd:	8d 83 f9 45 f8 ff    	lea    -0x7ba07(%ebx),%eax
f01006d3:	50                   	push   %eax
f01006d4:	e8 1f 34 00 00       	call   f0103af8 <cprintf>
f01006d9:	83 c4 10             	add    $0x10,%esp
}
f01006dc:	eb c7                	jmp    f01006a5 <cons_init+0xe9>

f01006de <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006de:	55                   	push   %ebp
f01006df:	89 e5                	mov    %esp,%ebp
f01006e1:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01006e7:	e8 1b fc ff ff       	call   f0100307 <cons_putc>
}
f01006ec:	c9                   	leave  
f01006ed:	c3                   	ret    

f01006ee <getchar>:

int
getchar(void)
{
f01006ee:	55                   	push   %ebp
f01006ef:	89 e5                	mov    %esp,%ebp
f01006f1:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006f4:	e8 69 fe ff ff       	call   f0100562 <cons_getc>
f01006f9:	85 c0                	test   %eax,%eax
f01006fb:	74 f7                	je     f01006f4 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006fd:	c9                   	leave  
f01006fe:	c3                   	ret    

f01006ff <iscons>:

int
iscons(int fdnum)
{
f01006ff:	55                   	push   %ebp
f0100700:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100702:	b8 01 00 00 00       	mov    $0x1,%eax
f0100707:	5d                   	pop    %ebp
f0100708:	c3                   	ret    

f0100709 <__x86.get_pc_thunk.ax>:
f0100709:	8b 04 24             	mov    (%esp),%eax
f010070c:	c3                   	ret    

f010070d <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010070d:	55                   	push   %ebp
f010070e:	89 e5                	mov    %esp,%ebp
f0100710:	56                   	push   %esi
f0100711:	53                   	push   %ebx
f0100712:	e8 50 fa ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100717:	81 c3 09 09 08 00    	add    $0x80909,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010071d:	83 ec 04             	sub    $0x4,%esp
f0100720:	8d 83 20 48 f8 ff    	lea    -0x7b7e0(%ebx),%eax
f0100726:	50                   	push   %eax
f0100727:	8d 83 3e 48 f8 ff    	lea    -0x7b7c2(%ebx),%eax
f010072d:	50                   	push   %eax
f010072e:	8d b3 43 48 f8 ff    	lea    -0x7b7bd(%ebx),%esi
f0100734:	56                   	push   %esi
f0100735:	e8 be 33 00 00       	call   f0103af8 <cprintf>
f010073a:	83 c4 0c             	add    $0xc,%esp
f010073d:	8d 83 e0 48 f8 ff    	lea    -0x7b720(%ebx),%eax
f0100743:	50                   	push   %eax
f0100744:	8d 83 4c 48 f8 ff    	lea    -0x7b7b4(%ebx),%eax
f010074a:	50                   	push   %eax
f010074b:	56                   	push   %esi
f010074c:	e8 a7 33 00 00       	call   f0103af8 <cprintf>
f0100751:	83 c4 0c             	add    $0xc,%esp
f0100754:	8d 83 08 49 f8 ff    	lea    -0x7b6f8(%ebx),%eax
f010075a:	50                   	push   %eax
f010075b:	8d 83 55 48 f8 ff    	lea    -0x7b7ab(%ebx),%eax
f0100761:	50                   	push   %eax
f0100762:	56                   	push   %esi
f0100763:	e8 90 33 00 00       	call   f0103af8 <cprintf>
	return 0;
}
f0100768:	b8 00 00 00 00       	mov    $0x0,%eax
f010076d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100770:	5b                   	pop    %ebx
f0100771:	5e                   	pop    %esi
f0100772:	5d                   	pop    %ebp
f0100773:	c3                   	ret    

f0100774 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100774:	55                   	push   %ebp
f0100775:	89 e5                	mov    %esp,%ebp
f0100777:	57                   	push   %edi
f0100778:	56                   	push   %esi
f0100779:	53                   	push   %ebx
f010077a:	83 ec 18             	sub    $0x18,%esp
f010077d:	e8 e5 f9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100782:	81 c3 9e 08 08 00    	add    $0x8089e,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100788:	8d 83 5f 48 f8 ff    	lea    -0x7b7a1(%ebx),%eax
f010078e:	50                   	push   %eax
f010078f:	e8 64 33 00 00       	call   f0103af8 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100794:	83 c4 08             	add    $0x8,%esp
f0100797:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
f010079d:	8d 83 38 49 f8 ff    	lea    -0x7b6c8(%ebx),%eax
f01007a3:	50                   	push   %eax
f01007a4:	e8 4f 33 00 00       	call   f0103af8 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007a9:	83 c4 0c             	add    $0xc,%esp
f01007ac:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007b2:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007b8:	50                   	push   %eax
f01007b9:	57                   	push   %edi
f01007ba:	8d 83 60 49 f8 ff    	lea    -0x7b6a0(%ebx),%eax
f01007c0:	50                   	push   %eax
f01007c1:	e8 32 33 00 00       	call   f0103af8 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007c6:	83 c4 0c             	add    $0xc,%esp
f01007c9:	c7 c0 a9 55 10 f0    	mov    $0xf01055a9,%eax
f01007cf:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007d5:	52                   	push   %edx
f01007d6:	50                   	push   %eax
f01007d7:	8d 83 84 49 f8 ff    	lea    -0x7b67c(%ebx),%eax
f01007dd:	50                   	push   %eax
f01007de:	e8 15 33 00 00       	call   f0103af8 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007e3:	83 c4 0c             	add    $0xc,%esp
f01007e6:	c7 c0 00 31 18 f0    	mov    $0xf0183100,%eax
f01007ec:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007f2:	52                   	push   %edx
f01007f3:	50                   	push   %eax
f01007f4:	8d 83 a8 49 f8 ff    	lea    -0x7b658(%ebx),%eax
f01007fa:	50                   	push   %eax
f01007fb:	e8 f8 32 00 00       	call   f0103af8 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100800:	83 c4 0c             	add    $0xc,%esp
f0100803:	c7 c6 00 40 18 f0    	mov    $0xf0184000,%esi
f0100809:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010080f:	50                   	push   %eax
f0100810:	56                   	push   %esi
f0100811:	8d 83 cc 49 f8 ff    	lea    -0x7b634(%ebx),%eax
f0100817:	50                   	push   %eax
f0100818:	e8 db 32 00 00       	call   f0103af8 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010081d:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100820:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f0100826:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100828:	c1 fe 0a             	sar    $0xa,%esi
f010082b:	56                   	push   %esi
f010082c:	8d 83 f0 49 f8 ff    	lea    -0x7b610(%ebx),%eax
f0100832:	50                   	push   %eax
f0100833:	e8 c0 32 00 00       	call   f0103af8 <cprintf>
	return 0;
}
f0100838:	b8 00 00 00 00       	mov    $0x0,%eax
f010083d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100840:	5b                   	pop    %ebx
f0100841:	5e                   	pop    %esi
f0100842:	5f                   	pop    %edi
f0100843:	5d                   	pop    %ebp
f0100844:	c3                   	ret    

f0100845 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100845:	55                   	push   %ebp
f0100846:	89 e5                	mov    %esp,%ebp
f0100848:	57                   	push   %edi
f0100849:	56                   	push   %esi
f010084a:	53                   	push   %ebx
f010084b:	83 ec 48             	sub    $0x48,%esp
f010084e:	e8 14 f9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100853:	81 c3 cd 07 08 00    	add    $0x807cd,%ebx
	cprintf("Stack backtrace: \n");
f0100859:	8d 83 78 48 f8 ff    	lea    -0x7b788(%ebx),%eax
f010085f:	50                   	push   %eax
f0100860:	e8 93 32 00 00       	call   f0103af8 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100865:	89 ee                	mov    %ebp,%esi
	int* p = (int*)read_ebp();	
	while (p) {
f0100867:	83 c4 10             	add    $0x10,%esp
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", p, *(p+1), *(p+2), *(p+3), *(p+4), *(p+5), *(p+6));
f010086a:	8d bb 1c 4a f8 ff    	lea    -0x7b5e4(%ebx),%edi
		struct Eipdebuginfo info;
		debuginfo_eip(*(p+1), &info) != -1;
f0100870:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100873:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	while (p) {
f0100876:	eb 4e                	jmp    f01008c6 <mon_backtrace+0x81>
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", p, *(p+1), *(p+2), *(p+3), *(p+4), *(p+5), *(p+6));
f0100878:	ff 76 18             	pushl  0x18(%esi)
f010087b:	ff 76 14             	pushl  0x14(%esi)
f010087e:	ff 76 10             	pushl  0x10(%esi)
f0100881:	ff 76 0c             	pushl  0xc(%esi)
f0100884:	ff 76 08             	pushl  0x8(%esi)
f0100887:	ff 76 04             	pushl  0x4(%esi)
f010088a:	56                   	push   %esi
f010088b:	57                   	push   %edi
f010088c:	e8 67 32 00 00       	call   f0103af8 <cprintf>
		debuginfo_eip(*(p+1), &info) != -1;
f0100891:	83 c4 18             	add    $0x18,%esp
f0100894:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100897:	ff 76 04             	pushl  0x4(%esi)
f010089a:	e8 53 3d 00 00       	call   f01045f2 <debuginfo_eip>
		cprintf("       %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, *(p+1)-info.eip_fn_addr);
f010089f:	83 c4 08             	add    $0x8,%esp
f01008a2:	8b 46 04             	mov    0x4(%esi),%eax
f01008a5:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01008a8:	50                   	push   %eax
f01008a9:	ff 75 d8             	pushl  -0x28(%ebp)
f01008ac:	ff 75 dc             	pushl  -0x24(%ebp)
f01008af:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008b2:	ff 75 d0             	pushl  -0x30(%ebp)
f01008b5:	8d 83 8b 48 f8 ff    	lea    -0x7b775(%ebx),%eax
f01008bb:	50                   	push   %eax
f01008bc:	e8 37 32 00 00       	call   f0103af8 <cprintf>
		p = (int*) *p;		
f01008c1:	8b 36                	mov    (%esi),%esi
f01008c3:	83 c4 20             	add    $0x20,%esp
	while (p) {
f01008c6:	85 f6                	test   %esi,%esi
f01008c8:	75 ae                	jne    f0100878 <mon_backtrace+0x33>
	}	
	return 0;
}
f01008ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01008cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008d2:	5b                   	pop    %ebx
f01008d3:	5e                   	pop    %esi
f01008d4:	5f                   	pop    %edi
f01008d5:	5d                   	pop    %ebp
f01008d6:	c3                   	ret    

f01008d7 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008d7:	55                   	push   %ebp
f01008d8:	89 e5                	mov    %esp,%ebp
f01008da:	57                   	push   %edi
f01008db:	56                   	push   %esi
f01008dc:	53                   	push   %ebx
f01008dd:	83 ec 68             	sub    $0x68,%esp
f01008e0:	e8 82 f8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01008e5:	81 c3 3b 07 08 00    	add    $0x8073b,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008eb:	8d 83 54 4a f8 ff    	lea    -0x7b5ac(%ebx),%eax
f01008f1:	50                   	push   %eax
f01008f2:	e8 01 32 00 00       	call   f0103af8 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008f7:	8d 83 78 4a f8 ff    	lea    -0x7b588(%ebx),%eax
f01008fd:	89 04 24             	mov    %eax,(%esp)
f0100900:	e8 f3 31 00 00       	call   f0103af8 <cprintf>

	if (tf != NULL)
f0100905:	83 c4 10             	add    $0x10,%esp
f0100908:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010090c:	74 0e                	je     f010091c <monitor+0x45>
		print_trapframe(tf);
f010090e:	83 ec 0c             	sub    $0xc,%esp
f0100911:	ff 75 08             	pushl  0x8(%ebp)
f0100914:	e8 bc 36 00 00       	call   f0103fd5 <print_trapframe>
f0100919:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010091c:	8d bb a6 48 f8 ff    	lea    -0x7b75a(%ebx),%edi
f0100922:	eb 4a                	jmp    f010096e <monitor+0x97>
f0100924:	83 ec 08             	sub    $0x8,%esp
f0100927:	0f be c0             	movsbl %al,%eax
f010092a:	50                   	push   %eax
f010092b:	57                   	push   %edi
f010092c:	e8 04 48 00 00       	call   f0105135 <strchr>
f0100931:	83 c4 10             	add    $0x10,%esp
f0100934:	85 c0                	test   %eax,%eax
f0100936:	74 08                	je     f0100940 <monitor+0x69>
			*buf++ = 0;
f0100938:	c6 06 00             	movb   $0x0,(%esi)
f010093b:	8d 76 01             	lea    0x1(%esi),%esi
f010093e:	eb 76                	jmp    f01009b6 <monitor+0xdf>
		if (*buf == 0)
f0100940:	80 3e 00             	cmpb   $0x0,(%esi)
f0100943:	74 7c                	je     f01009c1 <monitor+0xea>
		if (argc == MAXARGS-1) {
f0100945:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f0100949:	74 0f                	je     f010095a <monitor+0x83>
		argv[argc++] = buf;
f010094b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010094e:	8d 48 01             	lea    0x1(%eax),%ecx
f0100951:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100954:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f0100958:	eb 41                	jmp    f010099b <monitor+0xc4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010095a:	83 ec 08             	sub    $0x8,%esp
f010095d:	6a 10                	push   $0x10
f010095f:	8d 83 ab 48 f8 ff    	lea    -0x7b755(%ebx),%eax
f0100965:	50                   	push   %eax
f0100966:	e8 8d 31 00 00       	call   f0103af8 <cprintf>
f010096b:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010096e:	8d 83 a2 48 f8 ff    	lea    -0x7b75e(%ebx),%eax
f0100974:	89 c6                	mov    %eax,%esi
f0100976:	83 ec 0c             	sub    $0xc,%esp
f0100979:	56                   	push   %esi
f010097a:	e8 7e 45 00 00       	call   f0104efd <readline>
		if (buf != NULL)
f010097f:	83 c4 10             	add    $0x10,%esp
f0100982:	85 c0                	test   %eax,%eax
f0100984:	74 f0                	je     f0100976 <monitor+0x9f>
f0100986:	89 c6                	mov    %eax,%esi
	argv[argc] = 0;
f0100988:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f010098f:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100996:	eb 1e                	jmp    f01009b6 <monitor+0xdf>
			buf++;
f0100998:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010099b:	0f b6 06             	movzbl (%esi),%eax
f010099e:	84 c0                	test   %al,%al
f01009a0:	74 14                	je     f01009b6 <monitor+0xdf>
f01009a2:	83 ec 08             	sub    $0x8,%esp
f01009a5:	0f be c0             	movsbl %al,%eax
f01009a8:	50                   	push   %eax
f01009a9:	57                   	push   %edi
f01009aa:	e8 86 47 00 00       	call   f0105135 <strchr>
f01009af:	83 c4 10             	add    $0x10,%esp
f01009b2:	85 c0                	test   %eax,%eax
f01009b4:	74 e2                	je     f0100998 <monitor+0xc1>
		while (*buf && strchr(WHITESPACE, *buf))
f01009b6:	0f b6 06             	movzbl (%esi),%eax
f01009b9:	84 c0                	test   %al,%al
f01009bb:	0f 85 63 ff ff ff    	jne    f0100924 <monitor+0x4d>
	argv[argc] = 0;
f01009c1:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009c4:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f01009cb:	00 
	if (argc == 0)
f01009cc:	85 c0                	test   %eax,%eax
f01009ce:	74 9e                	je     f010096e <monitor+0x97>
f01009d0:	8d b3 20 20 00 00    	lea    0x2020(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01009db:	89 7d a0             	mov    %edi,-0x60(%ebp)
f01009de:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f01009e0:	83 ec 08             	sub    $0x8,%esp
f01009e3:	ff 36                	pushl  (%esi)
f01009e5:	ff 75 a8             	pushl  -0x58(%ebp)
f01009e8:	e8 ea 46 00 00       	call   f01050d7 <strcmp>
f01009ed:	83 c4 10             	add    $0x10,%esp
f01009f0:	85 c0                	test   %eax,%eax
f01009f2:	74 28                	je     f0100a1c <monitor+0x145>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009f4:	83 c7 01             	add    $0x1,%edi
f01009f7:	83 c6 0c             	add    $0xc,%esi
f01009fa:	83 ff 03             	cmp    $0x3,%edi
f01009fd:	75 e1                	jne    f01009e0 <monitor+0x109>
f01009ff:	8b 7d a0             	mov    -0x60(%ebp),%edi
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a02:	83 ec 08             	sub    $0x8,%esp
f0100a05:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a08:	8d 83 c8 48 f8 ff    	lea    -0x7b738(%ebx),%eax
f0100a0e:	50                   	push   %eax
f0100a0f:	e8 e4 30 00 00       	call   f0103af8 <cprintf>
f0100a14:	83 c4 10             	add    $0x10,%esp
f0100a17:	e9 52 ff ff ff       	jmp    f010096e <monitor+0x97>
f0100a1c:	89 f8                	mov    %edi,%eax
f0100a1e:	8b 7d a0             	mov    -0x60(%ebp),%edi
			return commands[i].func(argc, argv, tf);
f0100a21:	83 ec 04             	sub    $0x4,%esp
f0100a24:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a27:	ff 75 08             	pushl  0x8(%ebp)
f0100a2a:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a2d:	52                   	push   %edx
f0100a2e:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100a31:	ff 94 83 28 20 00 00 	call   *0x2028(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a38:	83 c4 10             	add    $0x10,%esp
f0100a3b:	85 c0                	test   %eax,%eax
f0100a3d:	0f 89 2b ff ff ff    	jns    f010096e <monitor+0x97>
				break;
	}
}
f0100a43:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a46:	5b                   	pop    %ebx
f0100a47:	5e                   	pop    %esi
f0100a48:	5f                   	pop    %edi
f0100a49:	5d                   	pop    %ebp
f0100a4a:	c3                   	ret    

f0100a4b <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a4b:	55                   	push   %ebp
f0100a4c:	89 e5                	mov    %esp,%ebp
f0100a4e:	57                   	push   %edi
f0100a4f:	56                   	push   %esi
f0100a50:	53                   	push   %ebx
f0100a51:	e8 7a 28 00 00       	call   f01032d0 <__x86.get_pc_thunk.si>
f0100a56:	81 c6 ca 05 08 00    	add    $0x805ca,%esi
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a5c:	83 be 18 23 00 00 00 	cmpl   $0x0,0x2318(%esi)
f0100a63:	74 21                	je     f0100a86 <boot_alloc+0x3b>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	char *top_page = ROUNDUP((char*)nextfree + n, PGSIZE);
f0100a65:	8b be 18 23 00 00    	mov    0x2318(%esi),%edi
f0100a6b:	8d 8c 07 ff 0f 00 00 	lea    0xfff(%edi,%eax,1),%ecx
f0100a72:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	char *ret_val = nextfree;
	while (nextfree < top_page) {
f0100a78:	89 fa                	mov    %edi,%edx
f0100a7a:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100a7f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100a84:	eb 28                	jmp    f0100aae <boot_alloc+0x63>
		nextfree = ROUNDUP((char*)end, PGSIZE) + PGSIZE;
f0100a86:	c7 c2 00 40 18 f0    	mov    $0xf0184000,%edx
f0100a8c:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100a92:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a98:	81 c2 00 10 00 00    	add    $0x1000,%edx
f0100a9e:	89 96 18 23 00 00    	mov    %edx,0x2318(%esi)
f0100aa4:	eb bf                	jmp    f0100a65 <boot_alloc+0x1a>
		nextfree+=PGSIZE;
f0100aa6:	81 c2 00 10 00 00    	add    $0x1000,%edx
f0100aac:	89 c3                	mov    %eax,%ebx
	while (nextfree < top_page) {
f0100aae:	39 d1                	cmp    %edx,%ecx
f0100ab0:	77 f4                	ja     f0100aa6 <boot_alloc+0x5b>
f0100ab2:	84 db                	test   %bl,%bl
f0100ab4:	75 07                	jne    f0100abd <boot_alloc+0x72>
	}
	return ret_val;
}
f0100ab6:	89 f8                	mov    %edi,%eax
f0100ab8:	5b                   	pop    %ebx
f0100ab9:	5e                   	pop    %esi
f0100aba:	5f                   	pop    %edi
f0100abb:	5d                   	pop    %ebp
f0100abc:	c3                   	ret    
f0100abd:	89 96 18 23 00 00    	mov    %edx,0x2318(%esi)
	return ret_val;
f0100ac3:	eb f1                	jmp    f0100ab6 <boot_alloc+0x6b>

f0100ac5 <nvram_read>:
{
f0100ac5:	55                   	push   %ebp
f0100ac6:	89 e5                	mov    %esp,%ebp
f0100ac8:	57                   	push   %edi
f0100ac9:	56                   	push   %esi
f0100aca:	53                   	push   %ebx
f0100acb:	83 ec 18             	sub    $0x18,%esp
f0100ace:	e8 94 f6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100ad3:	81 c3 4d 05 08 00    	add    $0x8054d,%ebx
f0100ad9:	89 c7                	mov    %eax,%edi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100adb:	50                   	push   %eax
f0100adc:	e8 90 2f 00 00       	call   f0103a71 <mc146818_read>
f0100ae1:	89 c6                	mov    %eax,%esi
f0100ae3:	83 c7 01             	add    $0x1,%edi
f0100ae6:	89 3c 24             	mov    %edi,(%esp)
f0100ae9:	e8 83 2f 00 00       	call   f0103a71 <mc146818_read>
f0100aee:	c1 e0 08             	shl    $0x8,%eax
f0100af1:	09 f0                	or     %esi,%eax
}
f0100af3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100af6:	5b                   	pop    %ebx
f0100af7:	5e                   	pop    %esi
f0100af8:	5f                   	pop    %edi
f0100af9:	5d                   	pop    %ebp
f0100afa:	c3                   	ret    

f0100afb <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100afb:	55                   	push   %ebp
f0100afc:	89 e5                	mov    %esp,%ebp
f0100afe:	56                   	push   %esi
f0100aff:	53                   	push   %ebx
f0100b00:	e8 c7 27 00 00       	call   f01032cc <__x86.get_pc_thunk.cx>
f0100b05:	81 c1 1b 05 08 00    	add    $0x8051b,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b0b:	89 d3                	mov    %edx,%ebx
f0100b0d:	c1 eb 16             	shr    $0x16,%ebx
	if (!(*pgdir & PTE_P))
f0100b10:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f0100b13:	a8 01                	test   $0x1,%al
f0100b15:	74 5a                	je     f0100b71 <check_va2pa+0x76>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b17:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b1c:	89 c6                	mov    %eax,%esi
f0100b1e:	c1 ee 0c             	shr    $0xc,%esi
f0100b21:	c7 c3 08 40 18 f0    	mov    $0xf0184008,%ebx
f0100b27:	3b 33                	cmp    (%ebx),%esi
f0100b29:	73 2b                	jae    f0100b56 <check_va2pa+0x5b>
	if (!(p[PTX(va)] & PTE_P))
f0100b2b:	c1 ea 0c             	shr    $0xc,%edx
f0100b2e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b34:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b3b:	89 c2                	mov    %eax,%edx
f0100b3d:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b40:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b45:	85 d2                	test   %edx,%edx
f0100b47:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b4c:	0f 44 c2             	cmove  %edx,%eax
}
f0100b4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b52:	5b                   	pop    %ebx
f0100b53:	5e                   	pop    %esi
f0100b54:	5d                   	pop    %ebp
f0100b55:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b56:	50                   	push   %eax
f0100b57:	8d 81 a0 4a f8 ff    	lea    -0x7b560(%ecx),%eax
f0100b5d:	50                   	push   %eax
f0100b5e:	68 37 03 00 00       	push   $0x337
f0100b63:	8d 81 ad 52 f8 ff    	lea    -0x7ad53(%ecx),%eax
f0100b69:	50                   	push   %eax
f0100b6a:	89 cb                	mov    %ecx,%ebx
f0100b6c:	e8 40 f5 ff ff       	call   f01000b1 <_panic>
		return ~0;
f0100b71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b76:	eb d7                	jmp    f0100b4f <check_va2pa+0x54>

f0100b78 <check_page_free_list>:
{
f0100b78:	55                   	push   %ebp
f0100b79:	89 e5                	mov    %esp,%ebp
f0100b7b:	57                   	push   %edi
f0100b7c:	56                   	push   %esi
f0100b7d:	53                   	push   %ebx
f0100b7e:	83 ec 3c             	sub    $0x3c,%esp
f0100b81:	e8 4e 27 00 00       	call   f01032d4 <__x86.get_pc_thunk.di>
f0100b86:	81 c7 9a 04 08 00    	add    $0x8049a,%edi
f0100b8c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b8f:	84 c0                	test   %al,%al
f0100b91:	0f 85 dd 02 00 00    	jne    f0100e74 <check_page_free_list+0x2fc>
	if (!page_free_list)
f0100b97:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100b9a:	83 b8 20 23 00 00 00 	cmpl   $0x0,0x2320(%eax)
f0100ba1:	74 0c                	je     f0100baf <check_page_free_list+0x37>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ba3:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
f0100baa:	e9 2f 03 00 00       	jmp    f0100ede <check_page_free_list+0x366>
		panic("'page_free_list' is a null pointer!");
f0100baf:	83 ec 04             	sub    $0x4,%esp
f0100bb2:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100bb5:	8d 83 c4 4a f8 ff    	lea    -0x7b53c(%ebx),%eax
f0100bbb:	50                   	push   %eax
f0100bbc:	68 73 02 00 00       	push   $0x273
f0100bc1:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0100bc7:	50                   	push   %eax
f0100bc8:	e8 e4 f4 ff ff       	call   f01000b1 <_panic>
f0100bcd:	50                   	push   %eax
f0100bce:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100bd1:	8d 83 a0 4a f8 ff    	lea    -0x7b560(%ebx),%eax
f0100bd7:	50                   	push   %eax
f0100bd8:	6a 56                	push   $0x56
f0100bda:	8d 83 b9 52 f8 ff    	lea    -0x7ad47(%ebx),%eax
f0100be0:	50                   	push   %eax
f0100be1:	e8 cb f4 ff ff       	call   f01000b1 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100be6:	8b 36                	mov    (%esi),%esi
f0100be8:	85 f6                	test   %esi,%esi
f0100bea:	74 40                	je     f0100c2c <check_page_free_list+0xb4>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bec:	89 f0                	mov    %esi,%eax
f0100bee:	2b 07                	sub    (%edi),%eax
f0100bf0:	c1 f8 03             	sar    $0x3,%eax
f0100bf3:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bf6:	89 c2                	mov    %eax,%edx
f0100bf8:	c1 ea 16             	shr    $0x16,%edx
f0100bfb:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100bfe:	73 e6                	jae    f0100be6 <check_page_free_list+0x6e>
	if (PGNUM(pa) >= npages)
f0100c00:	89 c2                	mov    %eax,%edx
f0100c02:	c1 ea 0c             	shr    $0xc,%edx
f0100c05:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100c08:	3b 11                	cmp    (%ecx),%edx
f0100c0a:	73 c1                	jae    f0100bcd <check_page_free_list+0x55>
			memset(page2kva(pp), 0x97, 128);
f0100c0c:	83 ec 04             	sub    $0x4,%esp
f0100c0f:	68 80 00 00 00       	push   $0x80
f0100c14:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c19:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c1e:	50                   	push   %eax
f0100c1f:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c22:	e8 4b 45 00 00       	call   f0105172 <memset>
f0100c27:	83 c4 10             	add    $0x10,%esp
f0100c2a:	eb ba                	jmp    f0100be6 <check_page_free_list+0x6e>
	first_free_page = (char *) boot_alloc(0);
f0100c2c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c31:	e8 15 fe ff ff       	call   f0100a4b <boot_alloc>
f0100c36:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c39:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100c3c:	8b 97 20 23 00 00    	mov    0x2320(%edi),%edx
		assert(pp >= pages);
f0100c42:	c7 c0 10 40 18 f0    	mov    $0xf0184010,%eax
f0100c48:	8b 08                	mov    (%eax),%ecx
		assert(pp < pages + npages);
f0100c4a:	c7 c0 08 40 18 f0    	mov    $0xf0184008,%eax
f0100c50:	8b 00                	mov    (%eax),%eax
f0100c52:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100c55:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c58:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c5b:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c60:	89 75 d0             	mov    %esi,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c63:	e9 08 01 00 00       	jmp    f0100d70 <check_page_free_list+0x1f8>
		assert(pp >= pages);
f0100c68:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c6b:	8d 83 c7 52 f8 ff    	lea    -0x7ad39(%ebx),%eax
f0100c71:	50                   	push   %eax
f0100c72:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0100c78:	50                   	push   %eax
f0100c79:	68 8d 02 00 00       	push   $0x28d
f0100c7e:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0100c84:	50                   	push   %eax
f0100c85:	e8 27 f4 ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f0100c8a:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c8d:	8d 83 e8 52 f8 ff    	lea    -0x7ad18(%ebx),%eax
f0100c93:	50                   	push   %eax
f0100c94:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0100c9a:	50                   	push   %eax
f0100c9b:	68 8e 02 00 00       	push   $0x28e
f0100ca0:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0100ca6:	50                   	push   %eax
f0100ca7:	e8 05 f4 ff ff       	call   f01000b1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cac:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100caf:	8d 83 e8 4a f8 ff    	lea    -0x7b518(%ebx),%eax
f0100cb5:	50                   	push   %eax
f0100cb6:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0100cbc:	50                   	push   %eax
f0100cbd:	68 8f 02 00 00       	push   $0x28f
f0100cc2:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0100cc8:	50                   	push   %eax
f0100cc9:	e8 e3 f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != 0);
f0100cce:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100cd1:	8d 83 fc 52 f8 ff    	lea    -0x7ad04(%ebx),%eax
f0100cd7:	50                   	push   %eax
f0100cd8:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0100cde:	50                   	push   %eax
f0100cdf:	68 92 02 00 00       	push   $0x292
f0100ce4:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0100cea:	50                   	push   %eax
f0100ceb:	e8 c1 f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cf0:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100cf3:	8d 83 0d 53 f8 ff    	lea    -0x7acf3(%ebx),%eax
f0100cf9:	50                   	push   %eax
f0100cfa:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0100d00:	50                   	push   %eax
f0100d01:	68 93 02 00 00       	push   $0x293
f0100d06:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0100d0c:	50                   	push   %eax
f0100d0d:	e8 9f f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d12:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d15:	8d 83 1c 4b f8 ff    	lea    -0x7b4e4(%ebx),%eax
f0100d1b:	50                   	push   %eax
f0100d1c:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0100d22:	50                   	push   %eax
f0100d23:	68 94 02 00 00       	push   $0x294
f0100d28:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0100d2e:	50                   	push   %eax
f0100d2f:	e8 7d f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d34:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d37:	8d 83 26 53 f8 ff    	lea    -0x7acda(%ebx),%eax
f0100d3d:	50                   	push   %eax
f0100d3e:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0100d44:	50                   	push   %eax
f0100d45:	68 95 02 00 00       	push   $0x295
f0100d4a:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0100d50:	50                   	push   %eax
f0100d51:	e8 5b f3 ff ff       	call   f01000b1 <_panic>
	if (PGNUM(pa) >= npages)
f0100d56:	89 c6                	mov    %eax,%esi
f0100d58:	c1 ee 0c             	shr    $0xc,%esi
f0100d5b:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f0100d5e:	76 70                	jbe    f0100dd0 <check_page_free_list+0x258>
	return (void *)(pa + KERNBASE);
f0100d60:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d65:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100d68:	77 7f                	ja     f0100de9 <check_page_free_list+0x271>
			++nfree_extmem;
f0100d6a:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d6e:	8b 12                	mov    (%edx),%edx
f0100d70:	85 d2                	test   %edx,%edx
f0100d72:	0f 84 93 00 00 00    	je     f0100e0b <check_page_free_list+0x293>
		assert(pp >= pages);
f0100d78:	39 d1                	cmp    %edx,%ecx
f0100d7a:	0f 87 e8 fe ff ff    	ja     f0100c68 <check_page_free_list+0xf0>
		assert(pp < pages + npages);
f0100d80:	39 d3                	cmp    %edx,%ebx
f0100d82:	0f 86 02 ff ff ff    	jbe    f0100c8a <check_page_free_list+0x112>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d88:	89 d0                	mov    %edx,%eax
f0100d8a:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100d8d:	a8 07                	test   $0x7,%al
f0100d8f:	0f 85 17 ff ff ff    	jne    f0100cac <check_page_free_list+0x134>
	return (pp - pages) << PGSHIFT;
f0100d95:	c1 f8 03             	sar    $0x3,%eax
f0100d98:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100d9b:	85 c0                	test   %eax,%eax
f0100d9d:	0f 84 2b ff ff ff    	je     f0100cce <check_page_free_list+0x156>
		assert(page2pa(pp) != IOPHYSMEM);
f0100da3:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100da8:	0f 84 42 ff ff ff    	je     f0100cf0 <check_page_free_list+0x178>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100dae:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100db3:	0f 84 59 ff ff ff    	je     f0100d12 <check_page_free_list+0x19a>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100db9:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100dbe:	0f 84 70 ff ff ff    	je     f0100d34 <check_page_free_list+0x1bc>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dc4:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100dc9:	77 8b                	ja     f0100d56 <check_page_free_list+0x1de>
			++nfree_basemem;
f0100dcb:	83 c7 01             	add    $0x1,%edi
f0100dce:	eb 9e                	jmp    f0100d6e <check_page_free_list+0x1f6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dd0:	50                   	push   %eax
f0100dd1:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100dd4:	8d 83 a0 4a f8 ff    	lea    -0x7b560(%ebx),%eax
f0100dda:	50                   	push   %eax
f0100ddb:	6a 56                	push   $0x56
f0100ddd:	8d 83 b9 52 f8 ff    	lea    -0x7ad47(%ebx),%eax
f0100de3:	50                   	push   %eax
f0100de4:	e8 c8 f2 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100de9:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100dec:	8d 83 40 4b f8 ff    	lea    -0x7b4c0(%ebx),%eax
f0100df2:	50                   	push   %eax
f0100df3:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0100df9:	50                   	push   %eax
f0100dfa:	68 96 02 00 00       	push   $0x296
f0100dff:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0100e05:	50                   	push   %eax
f0100e06:	e8 a6 f2 ff ff       	call   f01000b1 <_panic>
f0100e0b:	8b 75 d0             	mov    -0x30(%ebp),%esi
	assert(nfree_basemem > 0);
f0100e0e:	85 ff                	test   %edi,%edi
f0100e10:	7e 1e                	jle    f0100e30 <check_page_free_list+0x2b8>
	assert(nfree_extmem > 0);
f0100e12:	85 f6                	test   %esi,%esi
f0100e14:	7e 3c                	jle    f0100e52 <check_page_free_list+0x2da>
	cprintf("check_page_free_list() succeeded!\n");
f0100e16:	83 ec 0c             	sub    $0xc,%esp
f0100e19:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e1c:	8d 83 88 4b f8 ff    	lea    -0x7b478(%ebx),%eax
f0100e22:	50                   	push   %eax
f0100e23:	e8 d0 2c 00 00       	call   f0103af8 <cprintf>
}
f0100e28:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e2b:	5b                   	pop    %ebx
f0100e2c:	5e                   	pop    %esi
f0100e2d:	5f                   	pop    %edi
f0100e2e:	5d                   	pop    %ebp
f0100e2f:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e30:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e33:	8d 83 40 53 f8 ff    	lea    -0x7acc0(%ebx),%eax
f0100e39:	50                   	push   %eax
f0100e3a:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0100e40:	50                   	push   %eax
f0100e41:	68 9e 02 00 00       	push   $0x29e
f0100e46:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0100e4c:	50                   	push   %eax
f0100e4d:	e8 5f f2 ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f0100e52:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e55:	8d 83 52 53 f8 ff    	lea    -0x7acae(%ebx),%eax
f0100e5b:	50                   	push   %eax
f0100e5c:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0100e62:	50                   	push   %eax
f0100e63:	68 9f 02 00 00       	push   $0x29f
f0100e68:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0100e6e:	50                   	push   %eax
f0100e6f:	e8 3d f2 ff ff       	call   f01000b1 <_panic>
	if (!page_free_list)
f0100e74:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100e77:	8b 80 20 23 00 00    	mov    0x2320(%eax),%eax
f0100e7d:	85 c0                	test   %eax,%eax
f0100e7f:	0f 84 2a fd ff ff    	je     f0100baf <check_page_free_list+0x37>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e85:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100e88:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e8b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e8e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100e91:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100e94:	c7 c3 10 40 18 f0    	mov    $0xf0184010,%ebx
f0100e9a:	89 c2                	mov    %eax,%edx
f0100e9c:	2b 13                	sub    (%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100e9e:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ea4:	0f 95 c2             	setne  %dl
f0100ea7:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100eaa:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100eae:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100eb0:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100eb4:	8b 00                	mov    (%eax),%eax
f0100eb6:	85 c0                	test   %eax,%eax
f0100eb8:	75 e0                	jne    f0100e9a <check_page_free_list+0x322>
		*tp[1] = 0;
f0100eba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ebd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ec3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ec6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ec9:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ecb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ece:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100ed1:	89 87 20 23 00 00    	mov    %eax,0x2320(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ed7:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ede:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100ee1:	8b b0 20 23 00 00    	mov    0x2320(%eax),%esi
f0100ee7:	c7 c7 10 40 18 f0    	mov    $0xf0184010,%edi
	if (PGNUM(pa) >= npages)
f0100eed:	c7 c0 08 40 18 f0    	mov    $0xf0184008,%eax
f0100ef3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100ef6:	e9 ed fc ff ff       	jmp    f0100be8 <check_page_free_list+0x70>

f0100efb <page_init>:
{
f0100efb:	55                   	push   %ebp
f0100efc:	89 e5                	mov    %esp,%ebp
f0100efe:	57                   	push   %edi
f0100eff:	56                   	push   %esi
f0100f00:	53                   	push   %ebx
f0100f01:	83 ec 20             	sub    $0x20,%esp
f0100f04:	e8 5e f2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100f09:	81 c3 17 01 08 00    	add    $0x80117,%ebx
	page_free_list = NULL;
f0100f0f:	c7 83 20 23 00 00 00 	movl   $0x0,0x2320(%ebx)
f0100f16:	00 00 00 
	char *nextfree = (char*)boot_alloc(0);	
f0100f19:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f1e:	e8 28 fb ff ff       	call   f0100a4b <boot_alloc>
f0100f23:	89 45 e0             	mov    %eax,-0x20(%ebp)
		} else if (i >= 1 && i < npages_basemem) {
f0100f26:	8b 83 24 23 00 00    	mov    0x2324(%ebx),%eax
f0100f2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (i = 0; i < npages; i++) {
f0100f2f:	c6 45 e4 00          	movb   $0x0,-0x1c(%ebp)
f0100f33:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0100f3a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f3f:	c7 c2 08 40 18 f0    	mov    $0xf0184008,%edx
				pages[i].pp_ref = 1;
f0100f45:	c7 c6 10 40 18 f0    	mov    $0xf0184010,%esi
f0100f4b:	89 75 d8             	mov    %esi,-0x28(%ebp)
				pages[i].pp_ref = 0;
f0100f4e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
			pages[i].pp_ref = 1;
f0100f51:	89 75 dc             	mov    %esi,-0x24(%ebp)
			pages[i].pp_ref = 0;
f0100f54:	89 75 e8             	mov    %esi,-0x18(%ebp)
	for (i = 0; i < npages; i++) {
f0100f57:	eb 2d                	jmp    f0100f86 <page_init+0x8b>
		} else if (i >= 1 && i < npages_basemem) {
f0100f59:	39 45 ec             	cmp    %eax,-0x14(%ebp)
f0100f5c:	76 4a                	jbe    f0100fa8 <page_init+0xad>
f0100f5e:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
			pages[i].pp_ref = 0;
f0100f65:	89 cf                	mov    %ecx,%edi
f0100f67:	8b 75 e8             	mov    -0x18(%ebp),%esi
f0100f6a:	03 3e                	add    (%esi),%edi
f0100f6c:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
			pages[i].pp_link = page_free_list;
f0100f72:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0100f75:	89 37                	mov    %esi,(%edi)
			page_free_list = &pages[i];			
f0100f77:	8b 75 e8             	mov    -0x18(%ebp),%esi
f0100f7a:	03 0e                	add    (%esi),%ecx
f0100f7c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0100f7f:	c6 45 e4 01          	movb   $0x1,-0x1c(%ebp)
	for (i = 0; i < npages; i++) {
f0100f83:	83 c0 01             	add    $0x1,%eax
f0100f86:	39 02                	cmp    %eax,(%edx)
f0100f88:	0f 86 9e 00 00 00    	jbe    f010102c <page_init+0x131>
		if (i == 0) {
f0100f8e:	85 c0                	test   %eax,%eax
f0100f90:	75 c7                	jne    f0100f59 <page_init+0x5e>
			pages[i].pp_ref = 1;
f0100f92:	c7 c1 10 40 18 f0    	mov    $0xf0184010,%ecx
f0100f98:	8b 09                	mov    (%ecx),%ecx
f0100f9a:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
			pages[i].pp_link = NULL;
f0100fa0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0100fa6:	eb db                	jmp    f0100f83 <page_init+0x88>
f0100fa8:	8d 88 60 ff 0f 00    	lea    0xfff60(%eax),%ecx
f0100fae:	c1 e1 0c             	shl    $0xc,%ecx
		} else if (i * PGSIZE >= IOPHYSMEM && i * PGSIZE < EXTPHYSMEM) {
f0100fb1:	81 f9 ff ff 05 00    	cmp    $0x5ffff,%ecx
f0100fb7:	77 16                	ja     f0100fcf <page_init+0xd4>
			pages[i].pp_ref = 1;
f0100fb9:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0100fbc:	8b 0e                	mov    (%esi),%ecx
f0100fbe:	8d 0c c1             	lea    (%ecx,%eax,8),%ecx
f0100fc1:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
			pages[i].pp_link = NULL;
f0100fc7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0100fcd:	eb b4                	jmp    f0100f83 <page_init+0x88>
			if (i * PGSIZE + KERNBASE > (size_t)nextfree && i * PGSIZE < 0xE000000) {
f0100fcf:	8d b9 00 00 0a f0    	lea    -0xff60000(%ecx),%edi
f0100fd5:	39 7d e0             	cmp    %edi,-0x20(%ebp)
f0100fd8:	73 39                	jae    f0101013 <page_init+0x118>
f0100fda:	81 c1 00 00 0a 00    	add    $0xa0000,%ecx
f0100fe0:	81 f9 ff ff ff 0d    	cmp    $0xdffffff,%ecx
f0100fe6:	77 2b                	ja     f0101013 <page_init+0x118>
f0100fe8:	8d 3c c5 00 00 00 00 	lea    0x0(,%eax,8),%edi
				pages[i].pp_ref = 0;
f0100fef:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0100ff2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0100ff5:	03 3e                	add    (%esi),%edi
f0100ff7:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
				pages[i].pp_link = page_free_list;
f0100ffd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0101000:	89 0f                	mov    %ecx,(%edi)
				page_free_list = &pages[i];
f0101002:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101005:	03 0e                	add    (%esi),%ecx
f0101007:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010100a:	c6 45 e4 01          	movb   $0x1,-0x1c(%ebp)
f010100e:	e9 70 ff ff ff       	jmp    f0100f83 <page_init+0x88>
				pages[i].pp_ref = 1;
f0101013:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0101016:	8b 0e                	mov    (%esi),%ecx
f0101018:	8d 0c c1             	lea    (%ecx,%eax,8),%ecx
f010101b:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
				pages[i].pp_link = NULL;				
f0101021:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0101027:	e9 57 ff ff ff       	jmp    f0100f83 <page_init+0x88>
f010102c:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
f0101030:	75 08                	jne    f010103a <page_init+0x13f>
}
f0101032:	83 c4 20             	add    $0x20,%esp
f0101035:	5b                   	pop    %ebx
f0101036:	5e                   	pop    %esi
f0101037:	5f                   	pop    %edi
f0101038:	5d                   	pop    %ebp
f0101039:	c3                   	ret    
f010103a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010103d:	89 83 20 23 00 00    	mov    %eax,0x2320(%ebx)
f0101043:	eb ed                	jmp    f0101032 <page_init+0x137>

f0101045 <page_alloc>:
{
f0101045:	55                   	push   %ebp
f0101046:	89 e5                	mov    %esp,%ebp
f0101048:	56                   	push   %esi
f0101049:	53                   	push   %ebx
f010104a:	e8 18 f1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010104f:	81 c3 d1 ff 07 00    	add    $0x7ffd1,%ebx
	if (page_free_list == NULL)
f0101055:	8b b3 20 23 00 00    	mov    0x2320(%ebx),%esi
f010105b:	85 f6                	test   %esi,%esi
f010105d:	74 35                	je     f0101094 <page_alloc+0x4f>
	page_free_list = temp->pp_link;
f010105f:	8b 06                	mov    (%esi),%eax
f0101061:	89 83 20 23 00 00    	mov    %eax,0x2320(%ebx)
	temp->pp_link = NULL;
f0101067:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	return (pp - pages) << PGSHIFT;
f010106d:	c7 c0 10 40 18 f0    	mov    $0xf0184010,%eax
f0101073:	89 f2                	mov    %esi,%edx
f0101075:	2b 10                	sub    (%eax),%edx
f0101077:	89 d0                	mov    %edx,%eax
f0101079:	c1 f8 03             	sar    $0x3,%eax
f010107c:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010107f:	89 c1                	mov    %eax,%ecx
f0101081:	c1 e9 0c             	shr    $0xc,%ecx
f0101084:	c7 c2 08 40 18 f0    	mov    $0xf0184008,%edx
f010108a:	3b 0a                	cmp    (%edx),%ecx
f010108c:	73 0f                	jae    f010109d <page_alloc+0x58>
	if (alloc_flags & ALLOC_ZERO) {
f010108e:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101092:	75 1f                	jne    f01010b3 <page_alloc+0x6e>
}
f0101094:	89 f0                	mov    %esi,%eax
f0101096:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101099:	5b                   	pop    %ebx
f010109a:	5e                   	pop    %esi
f010109b:	5d                   	pop    %ebp
f010109c:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010109d:	50                   	push   %eax
f010109e:	8d 83 a0 4a f8 ff    	lea    -0x7b560(%ebx),%eax
f01010a4:	50                   	push   %eax
f01010a5:	6a 56                	push   $0x56
f01010a7:	8d 83 b9 52 f8 ff    	lea    -0x7ad47(%ebx),%eax
f01010ad:	50                   	push   %eax
f01010ae:	e8 fe ef ff ff       	call   f01000b1 <_panic>
		memset(kaddr, 0, PGSIZE);
f01010b3:	83 ec 04             	sub    $0x4,%esp
f01010b6:	68 00 10 00 00       	push   $0x1000
f01010bb:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01010bd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010c2:	50                   	push   %eax
f01010c3:	e8 aa 40 00 00       	call   f0105172 <memset>
f01010c8:	83 c4 10             	add    $0x10,%esp
f01010cb:	eb c7                	jmp    f0101094 <page_alloc+0x4f>

f01010cd <page_free>:
{
f01010cd:	55                   	push   %ebp
f01010ce:	89 e5                	mov    %esp,%ebp
f01010d0:	53                   	push   %ebx
f01010d1:	83 ec 04             	sub    $0x4,%esp
f01010d4:	e8 8e f0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01010d9:	81 c3 47 ff 07 00    	add    $0x7ff47,%ebx
f01010df:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0)
f01010e2:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010e7:	75 13                	jne    f01010fc <page_free+0x2f>
	pp->pp_link = page_free_list;
f01010e9:	8b 8b 20 23 00 00    	mov    0x2320(%ebx),%ecx
f01010ef:	89 08                	mov    %ecx,(%eax)
  	page_free_list = pp;	
f01010f1:	89 83 20 23 00 00    	mov    %eax,0x2320(%ebx)
}
f01010f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010fa:	c9                   	leave  
f01010fb:	c3                   	ret    
		panic("Attempt to free page that has references!");
f01010fc:	83 ec 04             	sub    $0x4,%esp
f01010ff:	8d 83 ac 4b f8 ff    	lea    -0x7b454(%ebx),%eax
f0101105:	50                   	push   %eax
f0101106:	68 68 01 00 00       	push   $0x168
f010110b:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0101111:	50                   	push   %eax
f0101112:	e8 9a ef ff ff       	call   f01000b1 <_panic>

f0101117 <page_decref>:
{
f0101117:	55                   	push   %ebp
f0101118:	89 e5                	mov    %esp,%ebp
f010111a:	83 ec 08             	sub    $0x8,%esp
f010111d:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101120:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101124:	83 e8 01             	sub    $0x1,%eax
f0101127:	66 89 42 04          	mov    %ax,0x4(%edx)
f010112b:	66 85 c0             	test   %ax,%ax
f010112e:	74 02                	je     f0101132 <page_decref+0x1b>
}
f0101130:	c9                   	leave  
f0101131:	c3                   	ret    
		page_free(pp);
f0101132:	83 ec 0c             	sub    $0xc,%esp
f0101135:	52                   	push   %edx
f0101136:	e8 92 ff ff ff       	call   f01010cd <page_free>
f010113b:	83 c4 10             	add    $0x10,%esp
}
f010113e:	eb f0                	jmp    f0101130 <page_decref+0x19>

f0101140 <pgdir_walk>:
{
f0101140:	55                   	push   %ebp
f0101141:	89 e5                	mov    %esp,%ebp
f0101143:	57                   	push   %edi
f0101144:	56                   	push   %esi
f0101145:	53                   	push   %ebx
f0101146:	83 ec 0c             	sub    $0xc,%esp
f0101149:	e8 19 f0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010114e:	81 c3 d2 fe 07 00    	add    $0x7fed2,%ebx
	pte_t *pte = (pte_t*) KADDR(PTE_ADDR(pgdir[PDX(va)]))+PTX(va);
f0101154:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101157:	c1 ef 16             	shr    $0x16,%edi
f010115a:	c1 e7 02             	shl    $0x2,%edi
f010115d:	03 7d 08             	add    0x8(%ebp),%edi
f0101160:	8b 07                	mov    (%edi),%eax
f0101162:	89 c2                	mov    %eax,%edx
f0101164:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f010116a:	89 d1                	mov    %edx,%ecx
f010116c:	c1 e9 0c             	shr    $0xc,%ecx
f010116f:	c7 c6 08 40 18 f0    	mov    $0xf0184008,%esi
f0101175:	39 0e                	cmp    %ecx,(%esi)
f0101177:	76 65                	jbe    f01011de <pgdir_walk+0x9e>
f0101179:	8b 75 0c             	mov    0xc(%ebp),%esi
f010117c:	c1 ee 0a             	shr    $0xa,%esi
f010117f:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
	if ((pgdir[PDX(va)] & PTE_P)) {
f0101185:	a8 01                	test   $0x1,%al
f0101187:	75 6e                	jne    f01011f7 <pgdir_walk+0xb7>
		if (create) {
f0101189:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010118d:	0f 84 89 00 00 00    	je     f010121c <pgdir_walk+0xdc>
			struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f0101193:	83 ec 0c             	sub    $0xc,%esp
f0101196:	6a 01                	push   $0x1
f0101198:	e8 a8 fe ff ff       	call   f0101045 <page_alloc>
			if (!pp)
f010119d:	83 c4 10             	add    $0x10,%esp
f01011a0:	85 c0                	test   %eax,%eax
f01011a2:	74 7f                	je     f0101223 <pgdir_walk+0xe3>
			pp->pp_ref++;
f01011a4:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01011a9:	c7 c1 10 40 18 f0    	mov    $0xf0184010,%ecx
f01011af:	89 c2                	mov    %eax,%edx
f01011b1:	2b 11                	sub    (%ecx),%edx
f01011b3:	c1 fa 03             	sar    $0x3,%edx
f01011b6:	c1 e2 0c             	shl    $0xc,%edx
			ui |= PTE_ADDR(page2pa(pp)); // Set physical page frame address
f01011b9:	83 ca 07             	or     $0x7,%edx
f01011bc:	89 17                	mov    %edx,(%edi)
f01011be:	2b 01                	sub    (%ecx),%eax
f01011c0:	c1 f8 03             	sar    $0x3,%eax
f01011c3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01011c6:	89 c1                	mov    %eax,%ecx
f01011c8:	c1 e9 0c             	shr    $0xc,%ecx
f01011cb:	c7 c2 08 40 18 f0    	mov    $0xf0184008,%edx
f01011d1:	3b 0a                	cmp    (%edx),%ecx
f01011d3:	73 31                	jae    f0101206 <pgdir_walk+0xc6>
			return ((pte_t*)PTE_ADDR(page2kva(pp))+PTX(va));			
f01011d5:	8d 84 06 00 00 00 f0 	lea    -0x10000000(%esi,%eax,1),%eax
f01011dc:	eb 20                	jmp    f01011fe <pgdir_walk+0xbe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011de:	52                   	push   %edx
f01011df:	8d 83 a0 4a f8 ff    	lea    -0x7b560(%ebx),%eax
f01011e5:	50                   	push   %eax
f01011e6:	68 92 01 00 00       	push   $0x192
f01011eb:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01011f1:	50                   	push   %eax
f01011f2:	e8 ba ee ff ff       	call   f01000b1 <_panic>
	pte_t *pte = (pte_t*) KADDR(PTE_ADDR(pgdir[PDX(va)]))+PTX(va);
f01011f7:	8d 84 32 00 00 00 f0 	lea    -0x10000000(%edx,%esi,1),%eax
}
f01011fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101201:	5b                   	pop    %ebx
f0101202:	5e                   	pop    %esi
f0101203:	5f                   	pop    %edi
f0101204:	5d                   	pop    %ebp
f0101205:	c3                   	ret    
f0101206:	50                   	push   %eax
f0101207:	8d 83 a0 4a f8 ff    	lea    -0x7b560(%ebx),%eax
f010120d:	50                   	push   %eax
f010120e:	6a 56                	push   $0x56
f0101210:	8d 83 b9 52 f8 ff    	lea    -0x7ad47(%ebx),%eax
f0101216:	50                   	push   %eax
f0101217:	e8 95 ee ff ff       	call   f01000b1 <_panic>
			return NULL;
f010121c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101221:	eb db                	jmp    f01011fe <pgdir_walk+0xbe>
				return NULL;
f0101223:	b8 00 00 00 00       	mov    $0x0,%eax
f0101228:	eb d4                	jmp    f01011fe <pgdir_walk+0xbe>

f010122a <boot_map_region>:
{
f010122a:	55                   	push   %ebp
f010122b:	89 e5                	mov    %esp,%ebp
f010122d:	57                   	push   %edi
f010122e:	56                   	push   %esi
f010122f:	53                   	push   %ebx
f0101230:	83 ec 1c             	sub    $0x1c,%esp
f0101233:	89 c7                	mov    %eax,%edi
f0101235:	89 d6                	mov    %edx,%esi
f0101237:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (uintptr_t va_i = 0; va_i < size; va_i+=PGSIZE) {
f010123a:	bb 00 00 00 00       	mov    $0x0,%ebx
		(*pte) = ((perm|PTE_P) & 0xFFF) | (~0xFFF & (pa+va_i));
f010123f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101242:	83 c8 01             	or     $0x1,%eax
f0101245:	25 ff 0f 00 00       	and    $0xfff,%eax
f010124a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (uintptr_t va_i = 0; va_i < size; va_i+=PGSIZE) {
f010124d:	eb 28                	jmp    f0101277 <boot_map_region+0x4d>
		pte = pgdir_walk(pgdir, (void*)(va+va_i), 1);
f010124f:	83 ec 04             	sub    $0x4,%esp
f0101252:	6a 01                	push   $0x1
f0101254:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0101257:	50                   	push   %eax
f0101258:	57                   	push   %edi
f0101259:	e8 e2 fe ff ff       	call   f0101140 <pgdir_walk>
		(*pte) = ((perm|PTE_P) & 0xFFF) | (~0xFFF & (pa+va_i));
f010125e:	89 da                	mov    %ebx,%edx
f0101260:	03 55 08             	add    0x8(%ebp),%edx
f0101263:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101269:	0b 55 e0             	or     -0x20(%ebp),%edx
f010126c:	89 10                	mov    %edx,(%eax)
	for (uintptr_t va_i = 0; va_i < size; va_i+=PGSIZE) {
f010126e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101274:	83 c4 10             	add    $0x10,%esp
f0101277:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010127a:	72 d3                	jb     f010124f <boot_map_region+0x25>
}
f010127c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010127f:	5b                   	pop    %ebx
f0101280:	5e                   	pop    %esi
f0101281:	5f                   	pop    %edi
f0101282:	5d                   	pop    %ebp
f0101283:	c3                   	ret    

f0101284 <page_lookup>:
{
f0101284:	55                   	push   %ebp
f0101285:	89 e5                	mov    %esp,%ebp
f0101287:	56                   	push   %esi
f0101288:	53                   	push   %ebx
f0101289:	e8 d9 ee ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010128e:	81 c3 92 fd 07 00    	add    $0x7fd92,%ebx
f0101294:	8b 75 10             	mov    0x10(%ebp),%esi
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0101297:	83 ec 04             	sub    $0x4,%esp
f010129a:	6a 00                	push   $0x0
f010129c:	ff 75 0c             	pushl  0xc(%ebp)
f010129f:	ff 75 08             	pushl  0x8(%ebp)
f01012a2:	e8 99 fe ff ff       	call   f0101140 <pgdir_walk>
	if (!pte)
f01012a7:	83 c4 10             	add    $0x10,%esp
f01012aa:	85 c0                	test   %eax,%eax
f01012ac:	74 3f                	je     f01012ed <page_lookup+0x69>
	if (pte_store)
f01012ae:	85 f6                	test   %esi,%esi
f01012b0:	74 02                	je     f01012b4 <page_lookup+0x30>
		*pte_store = pte;
f01012b2:	89 06                	mov    %eax,(%esi)
f01012b4:	8b 00                	mov    (%eax),%eax
f01012b6:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012b9:	c7 c2 08 40 18 f0    	mov    $0xf0184008,%edx
f01012bf:	39 02                	cmp    %eax,(%edx)
f01012c1:	76 12                	jbe    f01012d5 <page_lookup+0x51>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01012c3:	c7 c2 10 40 18 f0    	mov    $0xf0184010,%edx
f01012c9:	8b 12                	mov    (%edx),%edx
f01012cb:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01012ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012d1:	5b                   	pop    %ebx
f01012d2:	5e                   	pop    %esi
f01012d3:	5d                   	pop    %ebp
f01012d4:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01012d5:	83 ec 04             	sub    $0x4,%esp
f01012d8:	8d 83 d8 4b f8 ff    	lea    -0x7b428(%ebx),%eax
f01012de:	50                   	push   %eax
f01012df:	6a 4f                	push   $0x4f
f01012e1:	8d 83 b9 52 f8 ff    	lea    -0x7ad47(%ebx),%eax
f01012e7:	50                   	push   %eax
f01012e8:	e8 c4 ed ff ff       	call   f01000b1 <_panic>
		return NULL;
f01012ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01012f2:	eb da                	jmp    f01012ce <page_lookup+0x4a>

f01012f4 <page_remove>:
{
f01012f4:	55                   	push   %ebp
f01012f5:	89 e5                	mov    %esp,%ebp
f01012f7:	53                   	push   %ebx
f01012f8:	83 ec 18             	sub    $0x18,%esp
f01012fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte = (pte_t *)1;   // Ensure non-zero
f01012fe:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	struct PageInfo *pp = page_lookup(pgdir, va, &pte);
f0101305:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101308:	50                   	push   %eax
f0101309:	53                   	push   %ebx
f010130a:	ff 75 08             	pushl  0x8(%ebp)
f010130d:	e8 72 ff ff ff       	call   f0101284 <page_lookup>
	if (!pp)
f0101312:	83 c4 10             	add    $0x10,%esp
f0101315:	85 c0                	test   %eax,%eax
f0101317:	75 05                	jne    f010131e <page_remove+0x2a>
}
f0101319:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010131c:	c9                   	leave  
f010131d:	c3                   	ret    
	page_decref(pp);
f010131e:	83 ec 0c             	sub    $0xc,%esp
f0101321:	50                   	push   %eax
f0101322:	e8 f0 fd ff ff       	call   f0101117 <page_decref>
	*pte &= 0;      // Remove present flag
f0101327:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010132a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101330:	0f 01 3b             	invlpg (%ebx)
f0101333:	83 c4 10             	add    $0x10,%esp
f0101336:	eb e1                	jmp    f0101319 <page_remove+0x25>

f0101338 <page_insert>:
{
f0101338:	55                   	push   %ebp
f0101339:	89 e5                	mov    %esp,%ebp
f010133b:	57                   	push   %edi
f010133c:	56                   	push   %esi
f010133d:	53                   	push   %ebx
f010133e:	83 ec 10             	sub    $0x10,%esp
f0101341:	e8 21 ee ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0101346:	81 c3 da fc 07 00    	add    $0x7fcda,%ebx
f010134c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010134f:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0101352:	6a 00                	push   $0x0
f0101354:	57                   	push   %edi
f0101355:	ff 75 08             	pushl  0x8(%ebp)
f0101358:	e8 e3 fd ff ff       	call   f0101140 <pgdir_walk>
	if(pte && (*pte & PTE_P))
f010135d:	83 c4 10             	add    $0x10,%esp
f0101360:	85 c0                	test   %eax,%eax
f0101362:	74 05                	je     f0101369 <page_insert+0x31>
f0101364:	f6 00 01             	testb  $0x1,(%eax)
f0101367:	75 51                	jne    f01013ba <page_insert+0x82>
	pte = pgdir_walk(pgdir, va, 1);
f0101369:	83 ec 04             	sub    $0x4,%esp
f010136c:	6a 01                	push   $0x1
f010136e:	57                   	push   %edi
f010136f:	ff 75 08             	pushl  0x8(%ebp)
f0101372:	e8 c9 fd ff ff       	call   f0101140 <pgdir_walk>
	if (!pte)
f0101377:	83 c4 10             	add    $0x10,%esp
f010137a:	85 c0                	test   %eax,%eax
f010137c:	74 57                	je     f01013d5 <page_insert+0x9d>
	if (pp == page_free_list) {
f010137e:	8b 93 20 23 00 00    	mov    0x2320(%ebx),%edx
f0101384:	39 f2                	cmp    %esi,%edx
f0101386:	74 43                	je     f01013cb <page_insert+0x93>
	pp->pp_ref++;
f0101388:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	return (pp - pages) << PGSHIFT;
f010138d:	c7 c2 10 40 18 f0    	mov    $0xf0184010,%edx
f0101393:	2b 32                	sub    (%edx),%esi
f0101395:	89 f2                	mov    %esi,%edx
f0101397:	c1 fa 03             	sar    $0x3,%edx
f010139a:	c1 e2 0c             	shl    $0xc,%edx
	ui |= ((perm|PTE_P) & 0xFFF);
f010139d:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01013a0:	83 c9 01             	or     $0x1,%ecx
f01013a3:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
	ui |= p2p;
f01013a9:	09 ca                	or     %ecx,%edx
f01013ab:	89 10                	mov    %edx,(%eax)
	return 0;
f01013ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013b5:	5b                   	pop    %ebx
f01013b6:	5e                   	pop    %esi
f01013b7:	5f                   	pop    %edi
f01013b8:	5d                   	pop    %ebp
f01013b9:	c3                   	ret    
		page_remove(pgdir, va);
f01013ba:	83 ec 08             	sub    $0x8,%esp
f01013bd:	57                   	push   %edi
f01013be:	ff 75 08             	pushl  0x8(%ebp)
f01013c1:	e8 2e ff ff ff       	call   f01012f4 <page_remove>
f01013c6:	83 c4 10             	add    $0x10,%esp
f01013c9:	eb 9e                	jmp    f0101369 <page_insert+0x31>
		page_free_list = page_free_list->pp_link;
f01013cb:	8b 12                	mov    (%edx),%edx
f01013cd:	89 93 20 23 00 00    	mov    %edx,0x2320(%ebx)
f01013d3:	eb b3                	jmp    f0101388 <page_insert+0x50>
		return -E_NO_MEM;
f01013d5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01013da:	eb d6                	jmp    f01013b2 <page_insert+0x7a>

f01013dc <mem_init>:
{
f01013dc:	55                   	push   %ebp
f01013dd:	89 e5                	mov    %esp,%ebp
f01013df:	57                   	push   %edi
f01013e0:	56                   	push   %esi
f01013e1:	53                   	push   %ebx
f01013e2:	83 ec 3c             	sub    $0x3c,%esp
f01013e5:	e8 1f f3 ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f01013ea:	05 36 fc 07 00       	add    $0x7fc36,%eax
f01013ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f01013f2:	b8 15 00 00 00       	mov    $0x15,%eax
f01013f7:	e8 c9 f6 ff ff       	call   f0100ac5 <nvram_read>
f01013fc:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01013fe:	b8 17 00 00 00       	mov    $0x17,%eax
f0101403:	e8 bd f6 ff ff       	call   f0100ac5 <nvram_read>
f0101408:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010140a:	b8 34 00 00 00       	mov    $0x34,%eax
f010140f:	e8 b1 f6 ff ff       	call   f0100ac5 <nvram_read>
f0101414:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f0101417:	85 c0                	test   %eax,%eax
f0101419:	0f 85 e3 00 00 00    	jne    f0101502 <mem_init+0x126>
		totalmem = 1 * 1024 + extmem;
f010141f:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101425:	85 f6                	test   %esi,%esi
f0101427:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f010142a:	89 c1                	mov    %eax,%ecx
f010142c:	c1 e9 02             	shr    $0x2,%ecx
f010142f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101432:	c7 c2 08 40 18 f0    	mov    $0xf0184008,%edx
f0101438:	89 0a                	mov    %ecx,(%edx)
	npages_basemem = basemem / (PGSIZE / 1024);
f010143a:	89 da                	mov    %ebx,%edx
f010143c:	c1 ea 02             	shr    $0x2,%edx
f010143f:	89 97 24 23 00 00    	mov    %edx,0x2324(%edi)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101445:	89 c2                	mov    %eax,%edx
f0101447:	29 da                	sub    %ebx,%edx
f0101449:	52                   	push   %edx
f010144a:	53                   	push   %ebx
f010144b:	50                   	push   %eax
f010144c:	8d 87 f8 4b f8 ff    	lea    -0x7b408(%edi),%eax
f0101452:	50                   	push   %eax
f0101453:	89 fb                	mov    %edi,%ebx
f0101455:	e8 9e 26 00 00       	call   f0103af8 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010145a:	b8 00 10 00 00       	mov    $0x1000,%eax
f010145f:	e8 e7 f5 ff ff       	call   f0100a4b <boot_alloc>
f0101464:	c7 c6 0c 40 18 f0    	mov    $0xf018400c,%esi
f010146a:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);
f010146c:	83 c4 0c             	add    $0xc,%esp
f010146f:	68 00 10 00 00       	push   $0x1000
f0101474:	6a 00                	push   $0x0
f0101476:	50                   	push   %eax
f0101477:	e8 f6 3c 00 00       	call   f0105172 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010147c:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f010147e:	83 c4 10             	add    $0x10,%esp
f0101481:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101486:	0f 86 80 00 00 00    	jbe    f010150c <mem_init+0x130>
	return (physaddr_t)kva - KERNBASE;
f010148c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101492:	83 ca 05             	or     $0x5,%edx
f0101495:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = boot_alloc(npages * sizeof(struct PageInfo));
f010149b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010149e:	c7 c3 08 40 18 f0    	mov    $0xf0184008,%ebx
f01014a4:	8b 03                	mov    (%ebx),%eax
f01014a6:	c1 e0 03             	shl    $0x3,%eax
f01014a9:	e8 9d f5 ff ff       	call   f0100a4b <boot_alloc>
f01014ae:	c7 c6 10 40 18 f0    	mov    $0xf0184010,%esi
f01014b4:	89 06                	mov    %eax,(%esi)
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01014b6:	83 ec 04             	sub    $0x4,%esp
f01014b9:	8b 13                	mov    (%ebx),%edx
f01014bb:	c1 e2 03             	shl    $0x3,%edx
f01014be:	52                   	push   %edx
f01014bf:	6a 00                	push   $0x0
f01014c1:	50                   	push   %eax
f01014c2:	89 fb                	mov    %edi,%ebx
f01014c4:	e8 a9 3c 00 00       	call   f0105172 <memset>
	envs = boot_alloc(NENV * sizeof(struct Env));
f01014c9:	b8 00 80 01 00       	mov    $0x18000,%eax
f01014ce:	e8 78 f5 ff ff       	call   f0100a4b <boot_alloc>
f01014d3:	c7 c2 4c 33 18 f0    	mov    $0xf018334c,%edx
f01014d9:	89 02                	mov    %eax,(%edx)
	page_init();
f01014db:	e8 1b fa ff ff       	call   f0100efb <page_init>
	check_page_free_list(1);
f01014e0:	b8 01 00 00 00       	mov    $0x1,%eax
f01014e5:	e8 8e f6 ff ff       	call   f0100b78 <check_page_free_list>
	if (!pages)
f01014ea:	83 c4 10             	add    $0x10,%esp
f01014ed:	83 3e 00             	cmpl   $0x0,(%esi)
f01014f0:	74 36                	je     f0101528 <mem_init+0x14c>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014f5:	8b 80 20 23 00 00    	mov    0x2320(%eax),%eax
f01014fb:	be 00 00 00 00       	mov    $0x0,%esi
f0101500:	eb 49                	jmp    f010154b <mem_init+0x16f>
		totalmem = 16 * 1024 + ext16mem;
f0101502:	05 00 40 00 00       	add    $0x4000,%eax
f0101507:	e9 1e ff ff ff       	jmp    f010142a <mem_init+0x4e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010150c:	50                   	push   %eax
f010150d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101510:	8d 83 34 4c f8 ff    	lea    -0x7b3cc(%ebx),%eax
f0101516:	50                   	push   %eax
f0101517:	68 94 00 00 00       	push   $0x94
f010151c:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0101522:	50                   	push   %eax
f0101523:	e8 89 eb ff ff       	call   f01000b1 <_panic>
		panic("'pages' is a null pointer!");
f0101528:	83 ec 04             	sub    $0x4,%esp
f010152b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010152e:	8d 83 63 53 f8 ff    	lea    -0x7ac9d(%ebx),%eax
f0101534:	50                   	push   %eax
f0101535:	68 b2 02 00 00       	push   $0x2b2
f010153a:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0101540:	50                   	push   %eax
f0101541:	e8 6b eb ff ff       	call   f01000b1 <_panic>
		++nfree;
f0101546:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101549:	8b 00                	mov    (%eax),%eax
f010154b:	85 c0                	test   %eax,%eax
f010154d:	75 f7                	jne    f0101546 <mem_init+0x16a>
	assert((pp0 = page_alloc(0)));
f010154f:	83 ec 0c             	sub    $0xc,%esp
f0101552:	6a 00                	push   $0x0
f0101554:	e8 ec fa ff ff       	call   f0101045 <page_alloc>
f0101559:	89 c3                	mov    %eax,%ebx
f010155b:	83 c4 10             	add    $0x10,%esp
f010155e:	85 c0                	test   %eax,%eax
f0101560:	0f 84 3b 02 00 00    	je     f01017a1 <mem_init+0x3c5>
	assert((pp1 = page_alloc(0)));
f0101566:	83 ec 0c             	sub    $0xc,%esp
f0101569:	6a 00                	push   $0x0
f010156b:	e8 d5 fa ff ff       	call   f0101045 <page_alloc>
f0101570:	89 c7                	mov    %eax,%edi
f0101572:	83 c4 10             	add    $0x10,%esp
f0101575:	85 c0                	test   %eax,%eax
f0101577:	0f 84 46 02 00 00    	je     f01017c3 <mem_init+0x3e7>
	assert((pp2 = page_alloc(0)));
f010157d:	83 ec 0c             	sub    $0xc,%esp
f0101580:	6a 00                	push   $0x0
f0101582:	e8 be fa ff ff       	call   f0101045 <page_alloc>
f0101587:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010158a:	83 c4 10             	add    $0x10,%esp
f010158d:	85 c0                	test   %eax,%eax
f010158f:	0f 84 50 02 00 00    	je     f01017e5 <mem_init+0x409>
	assert(pp1 && pp1 != pp0);
f0101595:	39 fb                	cmp    %edi,%ebx
f0101597:	0f 84 6a 02 00 00    	je     f0101807 <mem_init+0x42b>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010159d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015a0:	39 c7                	cmp    %eax,%edi
f01015a2:	0f 84 81 02 00 00    	je     f0101829 <mem_init+0x44d>
f01015a8:	39 c3                	cmp    %eax,%ebx
f01015aa:	0f 84 79 02 00 00    	je     f0101829 <mem_init+0x44d>
	return (pp - pages) << PGSHIFT;
f01015b0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01015b3:	c7 c0 10 40 18 f0    	mov    $0xf0184010,%eax
f01015b9:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01015bb:	c7 c0 08 40 18 f0    	mov    $0xf0184008,%eax
f01015c1:	8b 10                	mov    (%eax),%edx
f01015c3:	c1 e2 0c             	shl    $0xc,%edx
f01015c6:	89 d8                	mov    %ebx,%eax
f01015c8:	29 c8                	sub    %ecx,%eax
f01015ca:	c1 f8 03             	sar    $0x3,%eax
f01015cd:	c1 e0 0c             	shl    $0xc,%eax
f01015d0:	39 d0                	cmp    %edx,%eax
f01015d2:	0f 83 73 02 00 00    	jae    f010184b <mem_init+0x46f>
f01015d8:	89 f8                	mov    %edi,%eax
f01015da:	29 c8                	sub    %ecx,%eax
f01015dc:	c1 f8 03             	sar    $0x3,%eax
f01015df:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01015e2:	39 c2                	cmp    %eax,%edx
f01015e4:	0f 86 83 02 00 00    	jbe    f010186d <mem_init+0x491>
f01015ea:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015ed:	29 c8                	sub    %ecx,%eax
f01015ef:	c1 f8 03             	sar    $0x3,%eax
f01015f2:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01015f5:	39 c2                	cmp    %eax,%edx
f01015f7:	0f 86 92 02 00 00    	jbe    f010188f <mem_init+0x4b3>
	fl = page_free_list;
f01015fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101600:	8b 88 20 23 00 00    	mov    0x2320(%eax),%ecx
f0101606:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101609:	c7 80 20 23 00 00 00 	movl   $0x0,0x2320(%eax)
f0101610:	00 00 00 
	assert(!page_alloc(0));
f0101613:	83 ec 0c             	sub    $0xc,%esp
f0101616:	6a 00                	push   $0x0
f0101618:	e8 28 fa ff ff       	call   f0101045 <page_alloc>
f010161d:	83 c4 10             	add    $0x10,%esp
f0101620:	85 c0                	test   %eax,%eax
f0101622:	0f 85 89 02 00 00    	jne    f01018b1 <mem_init+0x4d5>
	page_free(pp0);
f0101628:	83 ec 0c             	sub    $0xc,%esp
f010162b:	53                   	push   %ebx
f010162c:	e8 9c fa ff ff       	call   f01010cd <page_free>
	page_free(pp1);
f0101631:	89 3c 24             	mov    %edi,(%esp)
f0101634:	e8 94 fa ff ff       	call   f01010cd <page_free>
	page_free(pp2);
f0101639:	83 c4 04             	add    $0x4,%esp
f010163c:	ff 75 d0             	pushl  -0x30(%ebp)
f010163f:	e8 89 fa ff ff       	call   f01010cd <page_free>
	assert((pp0 = page_alloc(0)));
f0101644:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010164b:	e8 f5 f9 ff ff       	call   f0101045 <page_alloc>
f0101650:	89 c7                	mov    %eax,%edi
f0101652:	83 c4 10             	add    $0x10,%esp
f0101655:	85 c0                	test   %eax,%eax
f0101657:	0f 84 76 02 00 00    	je     f01018d3 <mem_init+0x4f7>
	assert((pp1 = page_alloc(0)));
f010165d:	83 ec 0c             	sub    $0xc,%esp
f0101660:	6a 00                	push   $0x0
f0101662:	e8 de f9 ff ff       	call   f0101045 <page_alloc>
f0101667:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010166a:	83 c4 10             	add    $0x10,%esp
f010166d:	85 c0                	test   %eax,%eax
f010166f:	0f 84 80 02 00 00    	je     f01018f5 <mem_init+0x519>
	assert((pp2 = page_alloc(0)));
f0101675:	83 ec 0c             	sub    $0xc,%esp
f0101678:	6a 00                	push   $0x0
f010167a:	e8 c6 f9 ff ff       	call   f0101045 <page_alloc>
f010167f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101682:	83 c4 10             	add    $0x10,%esp
f0101685:	85 c0                	test   %eax,%eax
f0101687:	0f 84 8a 02 00 00    	je     f0101917 <mem_init+0x53b>
	assert(pp1 && pp1 != pp0);
f010168d:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f0101690:	0f 84 a3 02 00 00    	je     f0101939 <mem_init+0x55d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101696:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101699:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010169c:	0f 84 b9 02 00 00    	je     f010195b <mem_init+0x57f>
f01016a2:	39 c7                	cmp    %eax,%edi
f01016a4:	0f 84 b1 02 00 00    	je     f010195b <mem_init+0x57f>
	assert(!page_alloc(0));
f01016aa:	83 ec 0c             	sub    $0xc,%esp
f01016ad:	6a 00                	push   $0x0
f01016af:	e8 91 f9 ff ff       	call   f0101045 <page_alloc>
f01016b4:	83 c4 10             	add    $0x10,%esp
f01016b7:	85 c0                	test   %eax,%eax
f01016b9:	0f 85 be 02 00 00    	jne    f010197d <mem_init+0x5a1>
f01016bf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016c2:	c7 c0 10 40 18 f0    	mov    $0xf0184010,%eax
f01016c8:	89 f9                	mov    %edi,%ecx
f01016ca:	2b 08                	sub    (%eax),%ecx
f01016cc:	89 c8                	mov    %ecx,%eax
f01016ce:	c1 f8 03             	sar    $0x3,%eax
f01016d1:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01016d4:	89 c1                	mov    %eax,%ecx
f01016d6:	c1 e9 0c             	shr    $0xc,%ecx
f01016d9:	c7 c2 08 40 18 f0    	mov    $0xf0184008,%edx
f01016df:	3b 0a                	cmp    (%edx),%ecx
f01016e1:	0f 83 b8 02 00 00    	jae    f010199f <mem_init+0x5c3>
	memset(page2kva(pp0), 1, PGSIZE);
f01016e7:	83 ec 04             	sub    $0x4,%esp
f01016ea:	68 00 10 00 00       	push   $0x1000
f01016ef:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01016f1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016f6:	50                   	push   %eax
f01016f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016fa:	e8 73 3a 00 00       	call   f0105172 <memset>
	page_free(pp0);
f01016ff:	89 3c 24             	mov    %edi,(%esp)
f0101702:	e8 c6 f9 ff ff       	call   f01010cd <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101707:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010170e:	e8 32 f9 ff ff       	call   f0101045 <page_alloc>
f0101713:	83 c4 10             	add    $0x10,%esp
f0101716:	85 c0                	test   %eax,%eax
f0101718:	0f 84 97 02 00 00    	je     f01019b5 <mem_init+0x5d9>
	assert(pp && pp0 == pp);
f010171e:	39 c7                	cmp    %eax,%edi
f0101720:	0f 85 b1 02 00 00    	jne    f01019d7 <mem_init+0x5fb>
	return (pp - pages) << PGSHIFT;
f0101726:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101729:	c7 c0 10 40 18 f0    	mov    $0xf0184010,%eax
f010172f:	89 fa                	mov    %edi,%edx
f0101731:	2b 10                	sub    (%eax),%edx
f0101733:	c1 fa 03             	sar    $0x3,%edx
f0101736:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101739:	89 d1                	mov    %edx,%ecx
f010173b:	c1 e9 0c             	shr    $0xc,%ecx
f010173e:	c7 c0 08 40 18 f0    	mov    $0xf0184008,%eax
f0101744:	3b 08                	cmp    (%eax),%ecx
f0101746:	0f 83 ad 02 00 00    	jae    f01019f9 <mem_init+0x61d>
	return (void *)(pa + KERNBASE);
f010174c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101752:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101758:	80 38 00             	cmpb   $0x0,(%eax)
f010175b:	0f 85 ae 02 00 00    	jne    f0101a0f <mem_init+0x633>
f0101761:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101764:	39 d0                	cmp    %edx,%eax
f0101766:	75 f0                	jne    f0101758 <mem_init+0x37c>
	page_free_list = fl;
f0101768:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010176b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010176e:	89 8b 20 23 00 00    	mov    %ecx,0x2320(%ebx)
	page_free(pp0);
f0101774:	83 ec 0c             	sub    $0xc,%esp
f0101777:	57                   	push   %edi
f0101778:	e8 50 f9 ff ff       	call   f01010cd <page_free>
	page_free(pp1);
f010177d:	83 c4 04             	add    $0x4,%esp
f0101780:	ff 75 d0             	pushl  -0x30(%ebp)
f0101783:	e8 45 f9 ff ff       	call   f01010cd <page_free>
	page_free(pp2);
f0101788:	83 c4 04             	add    $0x4,%esp
f010178b:	ff 75 cc             	pushl  -0x34(%ebp)
f010178e:	e8 3a f9 ff ff       	call   f01010cd <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101793:	8b 83 20 23 00 00    	mov    0x2320(%ebx),%eax
f0101799:	83 c4 10             	add    $0x10,%esp
f010179c:	e9 95 02 00 00       	jmp    f0101a36 <mem_init+0x65a>
	assert((pp0 = page_alloc(0)));
f01017a1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017a4:	8d 83 7e 53 f8 ff    	lea    -0x7ac82(%ebx),%eax
f01017aa:	50                   	push   %eax
f01017ab:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01017b1:	50                   	push   %eax
f01017b2:	68 ba 02 00 00       	push   $0x2ba
f01017b7:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01017bd:	50                   	push   %eax
f01017be:	e8 ee e8 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01017c3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017c6:	8d 83 94 53 f8 ff    	lea    -0x7ac6c(%ebx),%eax
f01017cc:	50                   	push   %eax
f01017cd:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01017d3:	50                   	push   %eax
f01017d4:	68 bb 02 00 00       	push   $0x2bb
f01017d9:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01017df:	50                   	push   %eax
f01017e0:	e8 cc e8 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01017e5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017e8:	8d 83 aa 53 f8 ff    	lea    -0x7ac56(%ebx),%eax
f01017ee:	50                   	push   %eax
f01017ef:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01017f5:	50                   	push   %eax
f01017f6:	68 bc 02 00 00       	push   $0x2bc
f01017fb:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0101801:	50                   	push   %eax
f0101802:	e8 aa e8 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0101807:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010180a:	8d 83 c0 53 f8 ff    	lea    -0x7ac40(%ebx),%eax
f0101810:	50                   	push   %eax
f0101811:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0101817:	50                   	push   %eax
f0101818:	68 bf 02 00 00       	push   $0x2bf
f010181d:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0101823:	50                   	push   %eax
f0101824:	e8 88 e8 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101829:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010182c:	8d 83 58 4c f8 ff    	lea    -0x7b3a8(%ebx),%eax
f0101832:	50                   	push   %eax
f0101833:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0101839:	50                   	push   %eax
f010183a:	68 c0 02 00 00       	push   $0x2c0
f010183f:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0101845:	50                   	push   %eax
f0101846:	e8 66 e8 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f010184b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010184e:	8d 83 d2 53 f8 ff    	lea    -0x7ac2e(%ebx),%eax
f0101854:	50                   	push   %eax
f0101855:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010185b:	50                   	push   %eax
f010185c:	68 c1 02 00 00       	push   $0x2c1
f0101861:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0101867:	50                   	push   %eax
f0101868:	e8 44 e8 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010186d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101870:	8d 83 ef 53 f8 ff    	lea    -0x7ac11(%ebx),%eax
f0101876:	50                   	push   %eax
f0101877:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010187d:	50                   	push   %eax
f010187e:	68 c2 02 00 00       	push   $0x2c2
f0101883:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0101889:	50                   	push   %eax
f010188a:	e8 22 e8 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010188f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101892:	8d 83 0c 54 f8 ff    	lea    -0x7abf4(%ebx),%eax
f0101898:	50                   	push   %eax
f0101899:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010189f:	50                   	push   %eax
f01018a0:	68 c3 02 00 00       	push   $0x2c3
f01018a5:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01018ab:	50                   	push   %eax
f01018ac:	e8 00 e8 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01018b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018b4:	8d 83 29 54 f8 ff    	lea    -0x7abd7(%ebx),%eax
f01018ba:	50                   	push   %eax
f01018bb:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01018c1:	50                   	push   %eax
f01018c2:	68 ca 02 00 00       	push   $0x2ca
f01018c7:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01018cd:	50                   	push   %eax
f01018ce:	e8 de e7 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f01018d3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018d6:	8d 83 7e 53 f8 ff    	lea    -0x7ac82(%ebx),%eax
f01018dc:	50                   	push   %eax
f01018dd:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01018e3:	50                   	push   %eax
f01018e4:	68 d1 02 00 00       	push   $0x2d1
f01018e9:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01018ef:	50                   	push   %eax
f01018f0:	e8 bc e7 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01018f5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018f8:	8d 83 94 53 f8 ff    	lea    -0x7ac6c(%ebx),%eax
f01018fe:	50                   	push   %eax
f01018ff:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0101905:	50                   	push   %eax
f0101906:	68 d2 02 00 00       	push   $0x2d2
f010190b:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0101911:	50                   	push   %eax
f0101912:	e8 9a e7 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101917:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010191a:	8d 83 aa 53 f8 ff    	lea    -0x7ac56(%ebx),%eax
f0101920:	50                   	push   %eax
f0101921:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0101927:	50                   	push   %eax
f0101928:	68 d3 02 00 00       	push   $0x2d3
f010192d:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0101933:	50                   	push   %eax
f0101934:	e8 78 e7 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0101939:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010193c:	8d 83 c0 53 f8 ff    	lea    -0x7ac40(%ebx),%eax
f0101942:	50                   	push   %eax
f0101943:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0101949:	50                   	push   %eax
f010194a:	68 d5 02 00 00       	push   $0x2d5
f010194f:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0101955:	50                   	push   %eax
f0101956:	e8 56 e7 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010195b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010195e:	8d 83 58 4c f8 ff    	lea    -0x7b3a8(%ebx),%eax
f0101964:	50                   	push   %eax
f0101965:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010196b:	50                   	push   %eax
f010196c:	68 d6 02 00 00       	push   $0x2d6
f0101971:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0101977:	50                   	push   %eax
f0101978:	e8 34 e7 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010197d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101980:	8d 83 29 54 f8 ff    	lea    -0x7abd7(%ebx),%eax
f0101986:	50                   	push   %eax
f0101987:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010198d:	50                   	push   %eax
f010198e:	68 d7 02 00 00       	push   $0x2d7
f0101993:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0101999:	50                   	push   %eax
f010199a:	e8 12 e7 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010199f:	50                   	push   %eax
f01019a0:	8d 83 a0 4a f8 ff    	lea    -0x7b560(%ebx),%eax
f01019a6:	50                   	push   %eax
f01019a7:	6a 56                	push   $0x56
f01019a9:	8d 83 b9 52 f8 ff    	lea    -0x7ad47(%ebx),%eax
f01019af:	50                   	push   %eax
f01019b0:	e8 fc e6 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01019b5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019b8:	8d 83 38 54 f8 ff    	lea    -0x7abc8(%ebx),%eax
f01019be:	50                   	push   %eax
f01019bf:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01019c5:	50                   	push   %eax
f01019c6:	68 dc 02 00 00       	push   $0x2dc
f01019cb:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01019d1:	50                   	push   %eax
f01019d2:	e8 da e6 ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f01019d7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019da:	8d 83 56 54 f8 ff    	lea    -0x7abaa(%ebx),%eax
f01019e0:	50                   	push   %eax
f01019e1:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01019e7:	50                   	push   %eax
f01019e8:	68 dd 02 00 00       	push   $0x2dd
f01019ed:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01019f3:	50                   	push   %eax
f01019f4:	e8 b8 e6 ff ff       	call   f01000b1 <_panic>
f01019f9:	52                   	push   %edx
f01019fa:	8d 83 a0 4a f8 ff    	lea    -0x7b560(%ebx),%eax
f0101a00:	50                   	push   %eax
f0101a01:	6a 56                	push   $0x56
f0101a03:	8d 83 b9 52 f8 ff    	lea    -0x7ad47(%ebx),%eax
f0101a09:	50                   	push   %eax
f0101a0a:	e8 a2 e6 ff ff       	call   f01000b1 <_panic>
		assert(c[i] == 0);
f0101a0f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a12:	8d 83 66 54 f8 ff    	lea    -0x7ab9a(%ebx),%eax
f0101a18:	50                   	push   %eax
f0101a19:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0101a1f:	50                   	push   %eax
f0101a20:	68 e0 02 00 00       	push   $0x2e0
f0101a25:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0101a2b:	50                   	push   %eax
f0101a2c:	e8 80 e6 ff ff       	call   f01000b1 <_panic>
		--nfree;
f0101a31:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a34:	8b 00                	mov    (%eax),%eax
f0101a36:	85 c0                	test   %eax,%eax
f0101a38:	75 f7                	jne    f0101a31 <mem_init+0x655>
	assert(nfree == 0);
f0101a3a:	85 f6                	test   %esi,%esi
f0101a3c:	0f 85 6f 08 00 00    	jne    f01022b1 <mem_init+0xed5>
	cprintf("check_page_alloc() succeeded!\n");
f0101a42:	83 ec 0c             	sub    $0xc,%esp
f0101a45:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a48:	8d 83 78 4c f8 ff    	lea    -0x7b388(%ebx),%eax
f0101a4e:	50                   	push   %eax
f0101a4f:	e8 a4 20 00 00       	call   f0103af8 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a5b:	e8 e5 f5 ff ff       	call   f0101045 <page_alloc>
f0101a60:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101a63:	83 c4 10             	add    $0x10,%esp
f0101a66:	85 c0                	test   %eax,%eax
f0101a68:	0f 84 65 08 00 00    	je     f01022d3 <mem_init+0xef7>
	assert((pp1 = page_alloc(0)));
f0101a6e:	83 ec 0c             	sub    $0xc,%esp
f0101a71:	6a 00                	push   $0x0
f0101a73:	e8 cd f5 ff ff       	call   f0101045 <page_alloc>
f0101a78:	89 c7                	mov    %eax,%edi
f0101a7a:	83 c4 10             	add    $0x10,%esp
f0101a7d:	85 c0                	test   %eax,%eax
f0101a7f:	0f 84 70 08 00 00    	je     f01022f5 <mem_init+0xf19>
	assert((pp2 = page_alloc(0)));
f0101a85:	83 ec 0c             	sub    $0xc,%esp
f0101a88:	6a 00                	push   $0x0
f0101a8a:	e8 b6 f5 ff ff       	call   f0101045 <page_alloc>
f0101a8f:	89 c6                	mov    %eax,%esi
f0101a91:	83 c4 10             	add    $0x10,%esp
f0101a94:	85 c0                	test   %eax,%eax
f0101a96:	0f 84 7b 08 00 00    	je     f0102317 <mem_init+0xf3b>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a9c:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0101a9f:	0f 84 94 08 00 00    	je     f0102339 <mem_init+0xf5d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101aa5:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101aa8:	0f 84 ad 08 00 00    	je     f010235b <mem_init+0xf7f>
f0101aae:	39 c7                	cmp    %eax,%edi
f0101ab0:	0f 84 a5 08 00 00    	je     f010235b <mem_init+0xf7f>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101ab6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ab9:	8b 88 20 23 00 00    	mov    0x2320(%eax),%ecx
f0101abf:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101ac2:	c7 80 20 23 00 00 00 	movl   $0x0,0x2320(%eax)
f0101ac9:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101acc:	83 ec 0c             	sub    $0xc,%esp
f0101acf:	6a 00                	push   $0x0
f0101ad1:	e8 6f f5 ff ff       	call   f0101045 <page_alloc>
f0101ad6:	83 c4 10             	add    $0x10,%esp
f0101ad9:	85 c0                	test   %eax,%eax
f0101adb:	0f 85 9c 08 00 00    	jne    f010237d <mem_init+0xfa1>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101ae1:	83 ec 04             	sub    $0x4,%esp
f0101ae4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ae7:	50                   	push   %eax
f0101ae8:	6a 00                	push   $0x0
f0101aea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101aed:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101af3:	ff 30                	pushl  (%eax)
f0101af5:	e8 8a f7 ff ff       	call   f0101284 <page_lookup>
f0101afa:	83 c4 10             	add    $0x10,%esp
f0101afd:	85 c0                	test   %eax,%eax
f0101aff:	0f 85 9a 08 00 00    	jne    f010239f <mem_init+0xfc3>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b05:	6a 02                	push   $0x2
f0101b07:	6a 00                	push   $0x0
f0101b09:	57                   	push   %edi
f0101b0a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b0d:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101b13:	ff 30                	pushl  (%eax)
f0101b15:	e8 1e f8 ff ff       	call   f0101338 <page_insert>
f0101b1a:	83 c4 10             	add    $0x10,%esp
f0101b1d:	85 c0                	test   %eax,%eax
f0101b1f:	0f 89 9c 08 00 00    	jns    f01023c1 <mem_init+0xfe5>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b25:	83 ec 0c             	sub    $0xc,%esp
f0101b28:	ff 75 d0             	pushl  -0x30(%ebp)
f0101b2b:	e8 9d f5 ff ff       	call   f01010cd <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b30:	6a 02                	push   $0x2
f0101b32:	6a 00                	push   $0x0
f0101b34:	57                   	push   %edi
f0101b35:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b38:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101b3e:	ff 30                	pushl  (%eax)
f0101b40:	e8 f3 f7 ff ff       	call   f0101338 <page_insert>
f0101b45:	83 c4 20             	add    $0x20,%esp
f0101b48:	85 c0                	test   %eax,%eax
f0101b4a:	0f 85 93 08 00 00    	jne    f01023e3 <mem_init+0x1007>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b50:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b53:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101b59:	8b 18                	mov    (%eax),%ebx
	return (pp - pages) << PGSHIFT;
f0101b5b:	c7 c0 10 40 18 f0    	mov    $0xf0184010,%eax
f0101b61:	8b 08                	mov    (%eax),%ecx
f0101b63:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101b66:	8b 13                	mov    (%ebx),%edx
f0101b68:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b6e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b71:	29 c8                	sub    %ecx,%eax
f0101b73:	c1 f8 03             	sar    $0x3,%eax
f0101b76:	c1 e0 0c             	shl    $0xc,%eax
f0101b79:	39 c2                	cmp    %eax,%edx
f0101b7b:	0f 85 84 08 00 00    	jne    f0102405 <mem_init+0x1029>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b81:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b86:	89 d8                	mov    %ebx,%eax
f0101b88:	e8 6e ef ff ff       	call   f0100afb <check_va2pa>
f0101b8d:	89 fa                	mov    %edi,%edx
f0101b8f:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101b92:	c1 fa 03             	sar    $0x3,%edx
f0101b95:	c1 e2 0c             	shl    $0xc,%edx
f0101b98:	39 d0                	cmp    %edx,%eax
f0101b9a:	0f 85 87 08 00 00    	jne    f0102427 <mem_init+0x104b>
	assert(pp1->pp_ref == 1);
f0101ba0:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ba5:	0f 85 9e 08 00 00    	jne    f0102449 <mem_init+0x106d>
	assert(pp0->pp_ref == 1);
f0101bab:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101bae:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101bb3:	0f 85 b2 08 00 00    	jne    f010246b <mem_init+0x108f>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bb9:	6a 02                	push   $0x2
f0101bbb:	68 00 10 00 00       	push   $0x1000
f0101bc0:	56                   	push   %esi
f0101bc1:	53                   	push   %ebx
f0101bc2:	e8 71 f7 ff ff       	call   f0101338 <page_insert>
f0101bc7:	83 c4 10             	add    $0x10,%esp
f0101bca:	85 c0                	test   %eax,%eax
f0101bcc:	0f 85 bb 08 00 00    	jne    f010248d <mem_init+0x10b1>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bd2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bd7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101bda:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101be0:	8b 00                	mov    (%eax),%eax
f0101be2:	e8 14 ef ff ff       	call   f0100afb <check_va2pa>
f0101be7:	c7 c2 10 40 18 f0    	mov    $0xf0184010,%edx
f0101bed:	89 f1                	mov    %esi,%ecx
f0101bef:	2b 0a                	sub    (%edx),%ecx
f0101bf1:	89 ca                	mov    %ecx,%edx
f0101bf3:	c1 fa 03             	sar    $0x3,%edx
f0101bf6:	c1 e2 0c             	shl    $0xc,%edx
f0101bf9:	39 d0                	cmp    %edx,%eax
f0101bfb:	0f 85 ae 08 00 00    	jne    f01024af <mem_init+0x10d3>
	assert(pp2->pp_ref == 1);
f0101c01:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c06:	0f 85 c5 08 00 00    	jne    f01024d1 <mem_init+0x10f5>

	// should be no free memory
	assert(!page_alloc(0));
f0101c0c:	83 ec 0c             	sub    $0xc,%esp
f0101c0f:	6a 00                	push   $0x0
f0101c11:	e8 2f f4 ff ff       	call   f0101045 <page_alloc>
f0101c16:	83 c4 10             	add    $0x10,%esp
f0101c19:	85 c0                	test   %eax,%eax
f0101c1b:	0f 85 d2 08 00 00    	jne    f01024f3 <mem_init+0x1117>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c21:	6a 02                	push   $0x2
f0101c23:	68 00 10 00 00       	push   $0x1000
f0101c28:	56                   	push   %esi
f0101c29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c2c:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101c32:	ff 30                	pushl  (%eax)
f0101c34:	e8 ff f6 ff ff       	call   f0101338 <page_insert>
f0101c39:	83 c4 10             	add    $0x10,%esp
f0101c3c:	85 c0                	test   %eax,%eax
f0101c3e:	0f 85 d1 08 00 00    	jne    f0102515 <mem_init+0x1139>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c44:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c49:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101c4c:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101c52:	8b 00                	mov    (%eax),%eax
f0101c54:	e8 a2 ee ff ff       	call   f0100afb <check_va2pa>
f0101c59:	c7 c2 10 40 18 f0    	mov    $0xf0184010,%edx
f0101c5f:	89 f1                	mov    %esi,%ecx
f0101c61:	2b 0a                	sub    (%edx),%ecx
f0101c63:	89 ca                	mov    %ecx,%edx
f0101c65:	c1 fa 03             	sar    $0x3,%edx
f0101c68:	c1 e2 0c             	shl    $0xc,%edx
f0101c6b:	39 d0                	cmp    %edx,%eax
f0101c6d:	0f 85 c4 08 00 00    	jne    f0102537 <mem_init+0x115b>
	assert(pp2->pp_ref == 1);
f0101c73:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c78:	0f 85 db 08 00 00    	jne    f0102559 <mem_init+0x117d>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c7e:	83 ec 0c             	sub    $0xc,%esp
f0101c81:	6a 00                	push   $0x0
f0101c83:	e8 bd f3 ff ff       	call   f0101045 <page_alloc>
f0101c88:	83 c4 10             	add    $0x10,%esp
f0101c8b:	85 c0                	test   %eax,%eax
f0101c8d:	0f 85 e8 08 00 00    	jne    f010257b <mem_init+0x119f>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c93:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101c96:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101c9c:	8b 10                	mov    (%eax),%edx
f0101c9e:	8b 02                	mov    (%edx),%eax
f0101ca0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101ca5:	89 c3                	mov    %eax,%ebx
f0101ca7:	c1 eb 0c             	shr    $0xc,%ebx
f0101caa:	c7 c1 08 40 18 f0    	mov    $0xf0184008,%ecx
f0101cb0:	3b 19                	cmp    (%ecx),%ebx
f0101cb2:	0f 83 e5 08 00 00    	jae    f010259d <mem_init+0x11c1>
	return (void *)(pa + KERNBASE);
f0101cb8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101cbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101cc0:	83 ec 04             	sub    $0x4,%esp
f0101cc3:	6a 00                	push   $0x0
f0101cc5:	68 00 10 00 00       	push   $0x1000
f0101cca:	52                   	push   %edx
f0101ccb:	e8 70 f4 ff ff       	call   f0101140 <pgdir_walk>
f0101cd0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101cd3:	8d 51 04             	lea    0x4(%ecx),%edx
f0101cd6:	83 c4 10             	add    $0x10,%esp
f0101cd9:	39 d0                	cmp    %edx,%eax
f0101cdb:	0f 85 d8 08 00 00    	jne    f01025b9 <mem_init+0x11dd>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ce1:	6a 06                	push   $0x6
f0101ce3:	68 00 10 00 00       	push   $0x1000
f0101ce8:	56                   	push   %esi
f0101ce9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cec:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101cf2:	ff 30                	pushl  (%eax)
f0101cf4:	e8 3f f6 ff ff       	call   f0101338 <page_insert>
f0101cf9:	83 c4 10             	add    $0x10,%esp
f0101cfc:	85 c0                	test   %eax,%eax
f0101cfe:	0f 85 d7 08 00 00    	jne    f01025db <mem_init+0x11ff>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d07:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101d0d:	8b 18                	mov    (%eax),%ebx
f0101d0f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d14:	89 d8                	mov    %ebx,%eax
f0101d16:	e8 e0 ed ff ff       	call   f0100afb <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101d1b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101d1e:	c7 c2 10 40 18 f0    	mov    $0xf0184010,%edx
f0101d24:	89 f1                	mov    %esi,%ecx
f0101d26:	2b 0a                	sub    (%edx),%ecx
f0101d28:	89 ca                	mov    %ecx,%edx
f0101d2a:	c1 fa 03             	sar    $0x3,%edx
f0101d2d:	c1 e2 0c             	shl    $0xc,%edx
f0101d30:	39 d0                	cmp    %edx,%eax
f0101d32:	0f 85 c5 08 00 00    	jne    f01025fd <mem_init+0x1221>
	assert(pp2->pp_ref == 1);
f0101d38:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d3d:	0f 85 dc 08 00 00    	jne    f010261f <mem_init+0x1243>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d43:	83 ec 04             	sub    $0x4,%esp
f0101d46:	6a 00                	push   $0x0
f0101d48:	68 00 10 00 00       	push   $0x1000
f0101d4d:	53                   	push   %ebx
f0101d4e:	e8 ed f3 ff ff       	call   f0101140 <pgdir_walk>
f0101d53:	83 c4 10             	add    $0x10,%esp
f0101d56:	f6 00 04             	testb  $0x4,(%eax)
f0101d59:	0f 84 e2 08 00 00    	je     f0102641 <mem_init+0x1265>
	assert(kern_pgdir[0] & PTE_U);
f0101d5f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d62:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101d68:	8b 00                	mov    (%eax),%eax
f0101d6a:	f6 00 04             	testb  $0x4,(%eax)
f0101d6d:	0f 84 f0 08 00 00    	je     f0102663 <mem_init+0x1287>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d73:	6a 02                	push   $0x2
f0101d75:	68 00 10 00 00       	push   $0x1000
f0101d7a:	56                   	push   %esi
f0101d7b:	50                   	push   %eax
f0101d7c:	e8 b7 f5 ff ff       	call   f0101338 <page_insert>
f0101d81:	83 c4 10             	add    $0x10,%esp
f0101d84:	85 c0                	test   %eax,%eax
f0101d86:	0f 85 f9 08 00 00    	jne    f0102685 <mem_init+0x12a9>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d8c:	83 ec 04             	sub    $0x4,%esp
f0101d8f:	6a 00                	push   $0x0
f0101d91:	68 00 10 00 00       	push   $0x1000
f0101d96:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d99:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101d9f:	ff 30                	pushl  (%eax)
f0101da1:	e8 9a f3 ff ff       	call   f0101140 <pgdir_walk>
f0101da6:	83 c4 10             	add    $0x10,%esp
f0101da9:	f6 00 02             	testb  $0x2,(%eax)
f0101dac:	0f 84 f5 08 00 00    	je     f01026a7 <mem_init+0x12cb>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101db2:	83 ec 04             	sub    $0x4,%esp
f0101db5:	6a 00                	push   $0x0
f0101db7:	68 00 10 00 00       	push   $0x1000
f0101dbc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dbf:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101dc5:	ff 30                	pushl  (%eax)
f0101dc7:	e8 74 f3 ff ff       	call   f0101140 <pgdir_walk>
f0101dcc:	83 c4 10             	add    $0x10,%esp
f0101dcf:	f6 00 04             	testb  $0x4,(%eax)
f0101dd2:	0f 85 f1 08 00 00    	jne    f01026c9 <mem_init+0x12ed>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101dd8:	6a 02                	push   $0x2
f0101dda:	68 00 00 40 00       	push   $0x400000
f0101ddf:	ff 75 d0             	pushl  -0x30(%ebp)
f0101de2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101de5:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101deb:	ff 30                	pushl  (%eax)
f0101ded:	e8 46 f5 ff ff       	call   f0101338 <page_insert>
f0101df2:	83 c4 10             	add    $0x10,%esp
f0101df5:	85 c0                	test   %eax,%eax
f0101df7:	0f 89 ee 08 00 00    	jns    f01026eb <mem_init+0x130f>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101dfd:	6a 02                	push   $0x2
f0101dff:	68 00 10 00 00       	push   $0x1000
f0101e04:	57                   	push   %edi
f0101e05:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e08:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101e0e:	ff 30                	pushl  (%eax)
f0101e10:	e8 23 f5 ff ff       	call   f0101338 <page_insert>
f0101e15:	83 c4 10             	add    $0x10,%esp
f0101e18:	85 c0                	test   %eax,%eax
f0101e1a:	0f 85 ed 08 00 00    	jne    f010270d <mem_init+0x1331>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e20:	83 ec 04             	sub    $0x4,%esp
f0101e23:	6a 00                	push   $0x0
f0101e25:	68 00 10 00 00       	push   $0x1000
f0101e2a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e2d:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101e33:	ff 30                	pushl  (%eax)
f0101e35:	e8 06 f3 ff ff       	call   f0101140 <pgdir_walk>
f0101e3a:	83 c4 10             	add    $0x10,%esp
f0101e3d:	f6 00 04             	testb  $0x4,(%eax)
f0101e40:	0f 85 e9 08 00 00    	jne    f010272f <mem_init+0x1353>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e46:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e49:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101e4f:	8b 18                	mov    (%eax),%ebx
f0101e51:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e56:	89 d8                	mov    %ebx,%eax
f0101e58:	e8 9e ec ff ff       	call   f0100afb <check_va2pa>
f0101e5d:	89 c2                	mov    %eax,%edx
f0101e5f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e62:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e65:	c7 c0 10 40 18 f0    	mov    $0xf0184010,%eax
f0101e6b:	89 f9                	mov    %edi,%ecx
f0101e6d:	2b 08                	sub    (%eax),%ecx
f0101e6f:	89 c8                	mov    %ecx,%eax
f0101e71:	c1 f8 03             	sar    $0x3,%eax
f0101e74:	c1 e0 0c             	shl    $0xc,%eax
f0101e77:	39 c2                	cmp    %eax,%edx
f0101e79:	0f 85 d2 08 00 00    	jne    f0102751 <mem_init+0x1375>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e7f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e84:	89 d8                	mov    %ebx,%eax
f0101e86:	e8 70 ec ff ff       	call   f0100afb <check_va2pa>
f0101e8b:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101e8e:	0f 85 df 08 00 00    	jne    f0102773 <mem_init+0x1397>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e94:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101e99:	0f 85 f6 08 00 00    	jne    f0102795 <mem_init+0x13b9>
	assert(pp2->pp_ref == 0);
f0101e9f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ea4:	0f 85 0d 09 00 00    	jne    f01027b7 <mem_init+0x13db>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101eaa:	83 ec 0c             	sub    $0xc,%esp
f0101ead:	6a 00                	push   $0x0
f0101eaf:	e8 91 f1 ff ff       	call   f0101045 <page_alloc>
f0101eb4:	83 c4 10             	add    $0x10,%esp
f0101eb7:	39 c6                	cmp    %eax,%esi
f0101eb9:	0f 85 1a 09 00 00    	jne    f01027d9 <mem_init+0x13fd>
f0101ebf:	85 c0                	test   %eax,%eax
f0101ec1:	0f 84 12 09 00 00    	je     f01027d9 <mem_init+0x13fd>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101ec7:	83 ec 08             	sub    $0x8,%esp
f0101eca:	6a 00                	push   $0x0
f0101ecc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ecf:	c7 c3 0c 40 18 f0    	mov    $0xf018400c,%ebx
f0101ed5:	ff 33                	pushl  (%ebx)
f0101ed7:	e8 18 f4 ff ff       	call   f01012f4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101edc:	8b 1b                	mov    (%ebx),%ebx
f0101ede:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ee3:	89 d8                	mov    %ebx,%eax
f0101ee5:	e8 11 ec ff ff       	call   f0100afb <check_va2pa>
f0101eea:	83 c4 10             	add    $0x10,%esp
f0101eed:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ef0:	0f 85 05 09 00 00    	jne    f01027fb <mem_init+0x141f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ef6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101efb:	89 d8                	mov    %ebx,%eax
f0101efd:	e8 f9 eb ff ff       	call   f0100afb <check_va2pa>
f0101f02:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101f05:	c7 c2 10 40 18 f0    	mov    $0xf0184010,%edx
f0101f0b:	89 f9                	mov    %edi,%ecx
f0101f0d:	2b 0a                	sub    (%edx),%ecx
f0101f0f:	89 ca                	mov    %ecx,%edx
f0101f11:	c1 fa 03             	sar    $0x3,%edx
f0101f14:	c1 e2 0c             	shl    $0xc,%edx
f0101f17:	39 d0                	cmp    %edx,%eax
f0101f19:	0f 85 fe 08 00 00    	jne    f010281d <mem_init+0x1441>
	assert(pp1->pp_ref == 1);
f0101f1f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101f24:	0f 85 15 09 00 00    	jne    f010283f <mem_init+0x1463>
	assert(pp2->pp_ref == 0);
f0101f2a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f2f:	0f 85 2c 09 00 00    	jne    f0102861 <mem_init+0x1485>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101f35:	6a 00                	push   $0x0
f0101f37:	68 00 10 00 00       	push   $0x1000
f0101f3c:	57                   	push   %edi
f0101f3d:	53                   	push   %ebx
f0101f3e:	e8 f5 f3 ff ff       	call   f0101338 <page_insert>
f0101f43:	83 c4 10             	add    $0x10,%esp
f0101f46:	85 c0                	test   %eax,%eax
f0101f48:	0f 85 35 09 00 00    	jne    f0102883 <mem_init+0x14a7>
	assert(pp1->pp_ref);
f0101f4e:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101f53:	0f 84 4c 09 00 00    	je     f01028a5 <mem_init+0x14c9>
	assert(pp1->pp_link == NULL);
f0101f59:	83 3f 00             	cmpl   $0x0,(%edi)
f0101f5c:	0f 85 65 09 00 00    	jne    f01028c7 <mem_init+0x14eb>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f62:	83 ec 08             	sub    $0x8,%esp
f0101f65:	68 00 10 00 00       	push   $0x1000
f0101f6a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f6d:	c7 c3 0c 40 18 f0    	mov    $0xf018400c,%ebx
f0101f73:	ff 33                	pushl  (%ebx)
f0101f75:	e8 7a f3 ff ff       	call   f01012f4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f7a:	8b 1b                	mov    (%ebx),%ebx
f0101f7c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f81:	89 d8                	mov    %ebx,%eax
f0101f83:	e8 73 eb ff ff       	call   f0100afb <check_va2pa>
f0101f88:	83 c4 10             	add    $0x10,%esp
f0101f8b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f8e:	0f 85 55 09 00 00    	jne    f01028e9 <mem_init+0x150d>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f94:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f99:	89 d8                	mov    %ebx,%eax
f0101f9b:	e8 5b eb ff ff       	call   f0100afb <check_va2pa>
f0101fa0:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fa3:	0f 85 62 09 00 00    	jne    f010290b <mem_init+0x152f>
	assert(pp1->pp_ref == 0);
f0101fa9:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101fae:	0f 85 79 09 00 00    	jne    f010292d <mem_init+0x1551>
	assert(pp2->pp_ref == 0);
f0101fb4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fb9:	0f 85 90 09 00 00    	jne    f010294f <mem_init+0x1573>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101fbf:	83 ec 0c             	sub    $0xc,%esp
f0101fc2:	6a 00                	push   $0x0
f0101fc4:	e8 7c f0 ff ff       	call   f0101045 <page_alloc>
f0101fc9:	83 c4 10             	add    $0x10,%esp
f0101fcc:	85 c0                	test   %eax,%eax
f0101fce:	0f 84 9d 09 00 00    	je     f0102971 <mem_init+0x1595>
f0101fd4:	39 c7                	cmp    %eax,%edi
f0101fd6:	0f 85 95 09 00 00    	jne    f0102971 <mem_init+0x1595>

	// should be no free memory
	assert(!page_alloc(0));
f0101fdc:	83 ec 0c             	sub    $0xc,%esp
f0101fdf:	6a 00                	push   $0x0
f0101fe1:	e8 5f f0 ff ff       	call   f0101045 <page_alloc>
f0101fe6:	83 c4 10             	add    $0x10,%esp
f0101fe9:	85 c0                	test   %eax,%eax
f0101feb:	0f 85 a2 09 00 00    	jne    f0102993 <mem_init+0x15b7>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ff1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ff4:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0101ffa:	8b 08                	mov    (%eax),%ecx
f0101ffc:	8b 11                	mov    (%ecx),%edx
f0101ffe:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102004:	c7 c0 10 40 18 f0    	mov    $0xf0184010,%eax
f010200a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010200d:	2b 18                	sub    (%eax),%ebx
f010200f:	89 d8                	mov    %ebx,%eax
f0102011:	c1 f8 03             	sar    $0x3,%eax
f0102014:	c1 e0 0c             	shl    $0xc,%eax
f0102017:	39 c2                	cmp    %eax,%edx
f0102019:	0f 85 96 09 00 00    	jne    f01029b5 <mem_init+0x15d9>
	kern_pgdir[0] = 0;
f010201f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102025:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102028:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010202d:	0f 85 a4 09 00 00    	jne    f01029d7 <mem_init+0x15fb>
	pp0->pp_ref = 0;
f0102033:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102036:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010203c:	83 ec 0c             	sub    $0xc,%esp
f010203f:	50                   	push   %eax
f0102040:	e8 88 f0 ff ff       	call   f01010cd <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102045:	83 c4 0c             	add    $0xc,%esp
f0102048:	6a 01                	push   $0x1
f010204a:	68 00 10 40 00       	push   $0x401000
f010204f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102052:	c7 c3 0c 40 18 f0    	mov    $0xf018400c,%ebx
f0102058:	ff 33                	pushl  (%ebx)
f010205a:	e8 e1 f0 ff ff       	call   f0101140 <pgdir_walk>
f010205f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102062:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102065:	8b 1b                	mov    (%ebx),%ebx
f0102067:	8b 53 04             	mov    0x4(%ebx),%edx
f010206a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0102070:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102073:	c7 c1 08 40 18 f0    	mov    $0xf0184008,%ecx
f0102079:	8b 09                	mov    (%ecx),%ecx
f010207b:	89 d0                	mov    %edx,%eax
f010207d:	c1 e8 0c             	shr    $0xc,%eax
f0102080:	83 c4 10             	add    $0x10,%esp
f0102083:	39 c8                	cmp    %ecx,%eax
f0102085:	0f 83 6e 09 00 00    	jae    f01029f9 <mem_init+0x161d>
	assert(ptep == ptep1 + PTX(va));
f010208b:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102091:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0102094:	0f 85 7b 09 00 00    	jne    f0102a15 <mem_init+0x1639>
	kern_pgdir[PDX(va)] = 0;
f010209a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f01020a1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01020a4:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	return (pp - pages) << PGSHIFT;
f01020aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020ad:	c7 c0 10 40 18 f0    	mov    $0xf0184010,%eax
f01020b3:	2b 18                	sub    (%eax),%ebx
f01020b5:	89 d8                	mov    %ebx,%eax
f01020b7:	c1 f8 03             	sar    $0x3,%eax
f01020ba:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01020bd:	89 c2                	mov    %eax,%edx
f01020bf:	c1 ea 0c             	shr    $0xc,%edx
f01020c2:	39 d1                	cmp    %edx,%ecx
f01020c4:	0f 86 6d 09 00 00    	jbe    f0102a37 <mem_init+0x165b>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01020ca:	83 ec 04             	sub    $0x4,%esp
f01020cd:	68 00 10 00 00       	push   $0x1000
f01020d2:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01020d7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020dc:	50                   	push   %eax
f01020dd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020e0:	e8 8d 30 00 00       	call   f0105172 <memset>
	page_free(pp0);
f01020e5:	83 c4 04             	add    $0x4,%esp
f01020e8:	ff 75 d0             	pushl  -0x30(%ebp)
f01020eb:	e8 dd ef ff ff       	call   f01010cd <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01020f0:	83 c4 0c             	add    $0xc,%esp
f01020f3:	6a 01                	push   $0x1
f01020f5:	6a 00                	push   $0x0
f01020f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020fa:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0102100:	ff 30                	pushl  (%eax)
f0102102:	e8 39 f0 ff ff       	call   f0101140 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0102107:	c7 c0 10 40 18 f0    	mov    $0xf0184010,%eax
f010210d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102110:	2b 10                	sub    (%eax),%edx
f0102112:	c1 fa 03             	sar    $0x3,%edx
f0102115:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102118:	89 d1                	mov    %edx,%ecx
f010211a:	c1 e9 0c             	shr    $0xc,%ecx
f010211d:	83 c4 10             	add    $0x10,%esp
f0102120:	c7 c0 08 40 18 f0    	mov    $0xf0184008,%eax
f0102126:	3b 08                	cmp    (%eax),%ecx
f0102128:	0f 83 22 09 00 00    	jae    f0102a50 <mem_init+0x1674>
	return (void *)(pa + KERNBASE);
f010212e:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102134:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102137:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010213d:	f6 00 01             	testb  $0x1,(%eax)
f0102140:	0f 85 23 09 00 00    	jne    f0102a69 <mem_init+0x168d>
f0102146:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0102149:	39 d0                	cmp    %edx,%eax
f010214b:	75 f0                	jne    f010213d <mem_init+0xd61>
	kern_pgdir[0] = 0;
f010214d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102150:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0102156:	8b 00                	mov    (%eax),%eax
f0102158:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010215e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102161:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102167:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010216a:	89 93 20 23 00 00    	mov    %edx,0x2320(%ebx)

	// free the pages we took
	page_free(pp0);
f0102170:	83 ec 0c             	sub    $0xc,%esp
f0102173:	50                   	push   %eax
f0102174:	e8 54 ef ff ff       	call   f01010cd <page_free>
	page_free(pp1);
f0102179:	89 3c 24             	mov    %edi,(%esp)
f010217c:	e8 4c ef ff ff       	call   f01010cd <page_free>
	page_free(pp2);
f0102181:	89 34 24             	mov    %esi,(%esp)
f0102184:	e8 44 ef ff ff       	call   f01010cd <page_free>

	cprintf("check_page() succeeded!\n");
f0102189:	8d 83 47 55 f8 ff    	lea    -0x7aab9(%ebx),%eax
f010218f:	89 04 24             	mov    %eax,(%esp)
f0102192:	e8 61 19 00 00       	call   f0103af8 <cprintf>
	boot_map_region(kern_pgdir, UPAGES,
f0102197:	c7 c0 10 40 18 f0    	mov    $0xf0184010,%eax
f010219d:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010219f:	83 c4 10             	add    $0x10,%esp
f01021a2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021a7:	0f 86 de 08 00 00    	jbe    f0102a8b <mem_init+0x16af>
			ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE),
f01021ad:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01021b0:	c7 c2 08 40 18 f0    	mov    $0xf0184008,%edx
f01021b6:	8b 12                	mov    (%edx),%edx
f01021b8:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	boot_map_region(kern_pgdir, UPAGES,
f01021bf:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01021c5:	83 ec 08             	sub    $0x8,%esp
f01021c8:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01021ca:	05 00 00 00 10       	add    $0x10000000,%eax
f01021cf:	50                   	push   %eax
f01021d0:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01021d5:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f01021db:	8b 00                	mov    (%eax),%eax
f01021dd:	e8 48 f0 ff ff       	call   f010122a <boot_map_region>
	boot_map_region(kern_pgdir, UENVS,
f01021e2:	c7 c0 4c 33 18 f0    	mov    $0xf018334c,%eax
f01021e8:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01021ea:	83 c4 10             	add    $0x10,%esp
f01021ed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021f2:	0f 86 af 08 00 00    	jbe    f0102aa7 <mem_init+0x16cb>
f01021f8:	83 ec 08             	sub    $0x8,%esp
f01021fb:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01021fd:	05 00 00 00 10       	add    $0x10000000,%eax
f0102202:	50                   	push   %eax
f0102203:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0102208:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010220d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102210:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0102216:	8b 00                	mov    (%eax),%eax
f0102218:	e8 0d f0 ff ff       	call   f010122a <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f010221d:	c7 c0 00 30 11 f0    	mov    $0xf0113000,%eax
f0102223:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102226:	83 c4 10             	add    $0x10,%esp
f0102229:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010222e:	0f 86 8f 08 00 00    	jbe    f0102ac3 <mem_init+0x16e7>
	boot_map_region(kern_pgdir, (uintptr_t)(KSTACKTOP-KSTKSIZE),
f0102234:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102237:	c7 c3 0c 40 18 f0    	mov    $0xf018400c,%ebx
f010223d:	83 ec 08             	sub    $0x8,%esp
f0102240:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f0102242:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102245:	05 00 00 00 10       	add    $0x10000000,%eax
f010224a:	50                   	push   %eax
f010224b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102250:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102255:	8b 03                	mov    (%ebx),%eax
f0102257:	e8 ce ef ff ff       	call   f010122a <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t)KERNBASE,
f010225c:	83 c4 08             	add    $0x8,%esp
f010225f:	6a 03                	push   $0x3
f0102261:	6a 00                	push   $0x0
f0102263:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102268:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010226d:	8b 03                	mov    (%ebx),%eax
f010226f:	e8 b6 ef ff ff       	call   f010122a <boot_map_region>
	pgdir = kern_pgdir;
f0102274:	8b 33                	mov    (%ebx),%esi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102276:	c7 c0 08 40 18 f0    	mov    $0xf0184008,%eax
f010227c:	8b 00                	mov    (%eax),%eax
f010227e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102281:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102288:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010228d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102290:	c7 c0 10 40 18 f0    	mov    $0xf0184010,%eax
f0102296:	8b 00                	mov    (%eax),%eax
f0102298:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f010229b:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f010229e:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f01022a4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f01022a7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01022ac:	e9 57 08 00 00       	jmp    f0102b08 <mem_init+0x172c>
	assert(nfree == 0);
f01022b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022b4:	8d 83 70 54 f8 ff    	lea    -0x7ab90(%ebx),%eax
f01022ba:	50                   	push   %eax
f01022bb:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01022c1:	50                   	push   %eax
f01022c2:	68 ed 02 00 00       	push   $0x2ed
f01022c7:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01022cd:	50                   	push   %eax
f01022ce:	e8 de dd ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f01022d3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022d6:	8d 83 7e 53 f8 ff    	lea    -0x7ac82(%ebx),%eax
f01022dc:	50                   	push   %eax
f01022dd:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01022e3:	50                   	push   %eax
f01022e4:	68 4b 03 00 00       	push   $0x34b
f01022e9:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01022ef:	50                   	push   %eax
f01022f0:	e8 bc dd ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01022f5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022f8:	8d 83 94 53 f8 ff    	lea    -0x7ac6c(%ebx),%eax
f01022fe:	50                   	push   %eax
f01022ff:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102305:	50                   	push   %eax
f0102306:	68 4c 03 00 00       	push   $0x34c
f010230b:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102311:	50                   	push   %eax
f0102312:	e8 9a dd ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102317:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010231a:	8d 83 aa 53 f8 ff    	lea    -0x7ac56(%ebx),%eax
f0102320:	50                   	push   %eax
f0102321:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102327:	50                   	push   %eax
f0102328:	68 4d 03 00 00       	push   $0x34d
f010232d:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102333:	50                   	push   %eax
f0102334:	e8 78 dd ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0102339:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010233c:	8d 83 c0 53 f8 ff    	lea    -0x7ac40(%ebx),%eax
f0102342:	50                   	push   %eax
f0102343:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102349:	50                   	push   %eax
f010234a:	68 50 03 00 00       	push   $0x350
f010234f:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102355:	50                   	push   %eax
f0102356:	e8 56 dd ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010235b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010235e:	8d 83 58 4c f8 ff    	lea    -0x7b3a8(%ebx),%eax
f0102364:	50                   	push   %eax
f0102365:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010236b:	50                   	push   %eax
f010236c:	68 51 03 00 00       	push   $0x351
f0102371:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102377:	50                   	push   %eax
f0102378:	e8 34 dd ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010237d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102380:	8d 83 29 54 f8 ff    	lea    -0x7abd7(%ebx),%eax
f0102386:	50                   	push   %eax
f0102387:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010238d:	50                   	push   %eax
f010238e:	68 58 03 00 00       	push   $0x358
f0102393:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102399:	50                   	push   %eax
f010239a:	e8 12 dd ff ff       	call   f01000b1 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010239f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023a2:	8d 83 98 4c f8 ff    	lea    -0x7b368(%ebx),%eax
f01023a8:	50                   	push   %eax
f01023a9:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01023af:	50                   	push   %eax
f01023b0:	68 5b 03 00 00       	push   $0x35b
f01023b5:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01023bb:	50                   	push   %eax
f01023bc:	e8 f0 dc ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01023c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023c4:	8d 83 d0 4c f8 ff    	lea    -0x7b330(%ebx),%eax
f01023ca:	50                   	push   %eax
f01023cb:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01023d1:	50                   	push   %eax
f01023d2:	68 5e 03 00 00       	push   $0x35e
f01023d7:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01023dd:	50                   	push   %eax
f01023de:	e8 ce dc ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01023e3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023e6:	8d 83 00 4d f8 ff    	lea    -0x7b300(%ebx),%eax
f01023ec:	50                   	push   %eax
f01023ed:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01023f3:	50                   	push   %eax
f01023f4:	68 62 03 00 00       	push   $0x362
f01023f9:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01023ff:	50                   	push   %eax
f0102400:	e8 ac dc ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102405:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102408:	8d 83 30 4d f8 ff    	lea    -0x7b2d0(%ebx),%eax
f010240e:	50                   	push   %eax
f010240f:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102415:	50                   	push   %eax
f0102416:	68 63 03 00 00       	push   $0x363
f010241b:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102421:	50                   	push   %eax
f0102422:	e8 8a dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102427:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010242a:	8d 83 58 4d f8 ff    	lea    -0x7b2a8(%ebx),%eax
f0102430:	50                   	push   %eax
f0102431:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102437:	50                   	push   %eax
f0102438:	68 64 03 00 00       	push   $0x364
f010243d:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102443:	50                   	push   %eax
f0102444:	e8 68 dc ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102449:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010244c:	8d 83 7b 54 f8 ff    	lea    -0x7ab85(%ebx),%eax
f0102452:	50                   	push   %eax
f0102453:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102459:	50                   	push   %eax
f010245a:	68 65 03 00 00       	push   $0x365
f010245f:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102465:	50                   	push   %eax
f0102466:	e8 46 dc ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f010246b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010246e:	8d 83 8c 54 f8 ff    	lea    -0x7ab74(%ebx),%eax
f0102474:	50                   	push   %eax
f0102475:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010247b:	50                   	push   %eax
f010247c:	68 66 03 00 00       	push   $0x366
f0102481:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102487:	50                   	push   %eax
f0102488:	e8 24 dc ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010248d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102490:	8d 83 88 4d f8 ff    	lea    -0x7b278(%ebx),%eax
f0102496:	50                   	push   %eax
f0102497:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010249d:	50                   	push   %eax
f010249e:	68 69 03 00 00       	push   $0x369
f01024a3:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01024a9:	50                   	push   %eax
f01024aa:	e8 02 dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024af:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024b2:	8d 83 c4 4d f8 ff    	lea    -0x7b23c(%ebx),%eax
f01024b8:	50                   	push   %eax
f01024b9:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01024bf:	50                   	push   %eax
f01024c0:	68 6a 03 00 00       	push   $0x36a
f01024c5:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01024cb:	50                   	push   %eax
f01024cc:	e8 e0 db ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01024d1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024d4:	8d 83 9d 54 f8 ff    	lea    -0x7ab63(%ebx),%eax
f01024da:	50                   	push   %eax
f01024db:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01024e1:	50                   	push   %eax
f01024e2:	68 6b 03 00 00       	push   $0x36b
f01024e7:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01024ed:	50                   	push   %eax
f01024ee:	e8 be db ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01024f3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024f6:	8d 83 29 54 f8 ff    	lea    -0x7abd7(%ebx),%eax
f01024fc:	50                   	push   %eax
f01024fd:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102503:	50                   	push   %eax
f0102504:	68 6e 03 00 00       	push   $0x36e
f0102509:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f010250f:	50                   	push   %eax
f0102510:	e8 9c db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102515:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102518:	8d 83 88 4d f8 ff    	lea    -0x7b278(%ebx),%eax
f010251e:	50                   	push   %eax
f010251f:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102525:	50                   	push   %eax
f0102526:	68 71 03 00 00       	push   $0x371
f010252b:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102531:	50                   	push   %eax
f0102532:	e8 7a db ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102537:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010253a:	8d 83 c4 4d f8 ff    	lea    -0x7b23c(%ebx),%eax
f0102540:	50                   	push   %eax
f0102541:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102547:	50                   	push   %eax
f0102548:	68 72 03 00 00       	push   $0x372
f010254d:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102553:	50                   	push   %eax
f0102554:	e8 58 db ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102559:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010255c:	8d 83 9d 54 f8 ff    	lea    -0x7ab63(%ebx),%eax
f0102562:	50                   	push   %eax
f0102563:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102569:	50                   	push   %eax
f010256a:	68 73 03 00 00       	push   $0x373
f010256f:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102575:	50                   	push   %eax
f0102576:	e8 36 db ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010257b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010257e:	8d 83 29 54 f8 ff    	lea    -0x7abd7(%ebx),%eax
f0102584:	50                   	push   %eax
f0102585:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010258b:	50                   	push   %eax
f010258c:	68 77 03 00 00       	push   $0x377
f0102591:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102597:	50                   	push   %eax
f0102598:	e8 14 db ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010259d:	50                   	push   %eax
f010259e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025a1:	8d 83 a0 4a f8 ff    	lea    -0x7b560(%ebx),%eax
f01025a7:	50                   	push   %eax
f01025a8:	68 7a 03 00 00       	push   $0x37a
f01025ad:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01025b3:	50                   	push   %eax
f01025b4:	e8 f8 da ff ff       	call   f01000b1 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01025b9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025bc:	8d 83 f4 4d f8 ff    	lea    -0x7b20c(%ebx),%eax
f01025c2:	50                   	push   %eax
f01025c3:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01025c9:	50                   	push   %eax
f01025ca:	68 7b 03 00 00       	push   $0x37b
f01025cf:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01025d5:	50                   	push   %eax
f01025d6:	e8 d6 da ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01025db:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025de:	8d 83 34 4e f8 ff    	lea    -0x7b1cc(%ebx),%eax
f01025e4:	50                   	push   %eax
f01025e5:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01025eb:	50                   	push   %eax
f01025ec:	68 7e 03 00 00       	push   $0x37e
f01025f1:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01025f7:	50                   	push   %eax
f01025f8:	e8 b4 da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01025fd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102600:	8d 83 c4 4d f8 ff    	lea    -0x7b23c(%ebx),%eax
f0102606:	50                   	push   %eax
f0102607:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010260d:	50                   	push   %eax
f010260e:	68 7f 03 00 00       	push   $0x37f
f0102613:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102619:	50                   	push   %eax
f010261a:	e8 92 da ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f010261f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102622:	8d 83 9d 54 f8 ff    	lea    -0x7ab63(%ebx),%eax
f0102628:	50                   	push   %eax
f0102629:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010262f:	50                   	push   %eax
f0102630:	68 80 03 00 00       	push   $0x380
f0102635:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f010263b:	50                   	push   %eax
f010263c:	e8 70 da ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102641:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102644:	8d 83 74 4e f8 ff    	lea    -0x7b18c(%ebx),%eax
f010264a:	50                   	push   %eax
f010264b:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102651:	50                   	push   %eax
f0102652:	68 81 03 00 00       	push   $0x381
f0102657:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f010265d:	50                   	push   %eax
f010265e:	e8 4e da ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102663:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102666:	8d 83 ae 54 f8 ff    	lea    -0x7ab52(%ebx),%eax
f010266c:	50                   	push   %eax
f010266d:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102673:	50                   	push   %eax
f0102674:	68 82 03 00 00       	push   $0x382
f0102679:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f010267f:	50                   	push   %eax
f0102680:	e8 2c da ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102685:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102688:	8d 83 88 4d f8 ff    	lea    -0x7b278(%ebx),%eax
f010268e:	50                   	push   %eax
f010268f:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102695:	50                   	push   %eax
f0102696:	68 85 03 00 00       	push   $0x385
f010269b:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01026a1:	50                   	push   %eax
f01026a2:	e8 0a da ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01026a7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026aa:	8d 83 a8 4e f8 ff    	lea    -0x7b158(%ebx),%eax
f01026b0:	50                   	push   %eax
f01026b1:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01026b7:	50                   	push   %eax
f01026b8:	68 86 03 00 00       	push   $0x386
f01026bd:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01026c3:	50                   	push   %eax
f01026c4:	e8 e8 d9 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01026c9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026cc:	8d 83 dc 4e f8 ff    	lea    -0x7b124(%ebx),%eax
f01026d2:	50                   	push   %eax
f01026d3:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01026d9:	50                   	push   %eax
f01026da:	68 87 03 00 00       	push   $0x387
f01026df:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01026e5:	50                   	push   %eax
f01026e6:	e8 c6 d9 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01026eb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026ee:	8d 83 14 4f f8 ff    	lea    -0x7b0ec(%ebx),%eax
f01026f4:	50                   	push   %eax
f01026f5:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01026fb:	50                   	push   %eax
f01026fc:	68 8a 03 00 00       	push   $0x38a
f0102701:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102707:	50                   	push   %eax
f0102708:	e8 a4 d9 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010270d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102710:	8d 83 4c 4f f8 ff    	lea    -0x7b0b4(%ebx),%eax
f0102716:	50                   	push   %eax
f0102717:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010271d:	50                   	push   %eax
f010271e:	68 8d 03 00 00       	push   $0x38d
f0102723:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102729:	50                   	push   %eax
f010272a:	e8 82 d9 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010272f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102732:	8d 83 dc 4e f8 ff    	lea    -0x7b124(%ebx),%eax
f0102738:	50                   	push   %eax
f0102739:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010273f:	50                   	push   %eax
f0102740:	68 8e 03 00 00       	push   $0x38e
f0102745:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f010274b:	50                   	push   %eax
f010274c:	e8 60 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102751:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102754:	8d 83 88 4f f8 ff    	lea    -0x7b078(%ebx),%eax
f010275a:	50                   	push   %eax
f010275b:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102761:	50                   	push   %eax
f0102762:	68 91 03 00 00       	push   $0x391
f0102767:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f010276d:	50                   	push   %eax
f010276e:	e8 3e d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102773:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102776:	8d 83 b4 4f f8 ff    	lea    -0x7b04c(%ebx),%eax
f010277c:	50                   	push   %eax
f010277d:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102783:	50                   	push   %eax
f0102784:	68 92 03 00 00       	push   $0x392
f0102789:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f010278f:	50                   	push   %eax
f0102790:	e8 1c d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 2);
f0102795:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102798:	8d 83 c4 54 f8 ff    	lea    -0x7ab3c(%ebx),%eax
f010279e:	50                   	push   %eax
f010279f:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01027a5:	50                   	push   %eax
f01027a6:	68 94 03 00 00       	push   $0x394
f01027ab:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01027b1:	50                   	push   %eax
f01027b2:	e8 fa d8 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01027b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027ba:	8d 83 d5 54 f8 ff    	lea    -0x7ab2b(%ebx),%eax
f01027c0:	50                   	push   %eax
f01027c1:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01027c7:	50                   	push   %eax
f01027c8:	68 95 03 00 00       	push   $0x395
f01027cd:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01027d3:	50                   	push   %eax
f01027d4:	e8 d8 d8 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01027d9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027dc:	8d 83 e4 4f f8 ff    	lea    -0x7b01c(%ebx),%eax
f01027e2:	50                   	push   %eax
f01027e3:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01027e9:	50                   	push   %eax
f01027ea:	68 98 03 00 00       	push   $0x398
f01027ef:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01027f5:	50                   	push   %eax
f01027f6:	e8 b6 d8 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01027fb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027fe:	8d 83 08 50 f8 ff    	lea    -0x7aff8(%ebx),%eax
f0102804:	50                   	push   %eax
f0102805:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010280b:	50                   	push   %eax
f010280c:	68 9c 03 00 00       	push   $0x39c
f0102811:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102817:	50                   	push   %eax
f0102818:	e8 94 d8 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010281d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102820:	8d 83 b4 4f f8 ff    	lea    -0x7b04c(%ebx),%eax
f0102826:	50                   	push   %eax
f0102827:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010282d:	50                   	push   %eax
f010282e:	68 9d 03 00 00       	push   $0x39d
f0102833:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102839:	50                   	push   %eax
f010283a:	e8 72 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f010283f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102842:	8d 83 7b 54 f8 ff    	lea    -0x7ab85(%ebx),%eax
f0102848:	50                   	push   %eax
f0102849:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010284f:	50                   	push   %eax
f0102850:	68 9e 03 00 00       	push   $0x39e
f0102855:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f010285b:	50                   	push   %eax
f010285c:	e8 50 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102861:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102864:	8d 83 d5 54 f8 ff    	lea    -0x7ab2b(%ebx),%eax
f010286a:	50                   	push   %eax
f010286b:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102871:	50                   	push   %eax
f0102872:	68 9f 03 00 00       	push   $0x39f
f0102877:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f010287d:	50                   	push   %eax
f010287e:	e8 2e d8 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102883:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102886:	8d 83 2c 50 f8 ff    	lea    -0x7afd4(%ebx),%eax
f010288c:	50                   	push   %eax
f010288d:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102893:	50                   	push   %eax
f0102894:	68 a2 03 00 00       	push   $0x3a2
f0102899:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f010289f:	50                   	push   %eax
f01028a0:	e8 0c d8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f01028a5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028a8:	8d 83 e6 54 f8 ff    	lea    -0x7ab1a(%ebx),%eax
f01028ae:	50                   	push   %eax
f01028af:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01028b5:	50                   	push   %eax
f01028b6:	68 a3 03 00 00       	push   $0x3a3
f01028bb:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01028c1:	50                   	push   %eax
f01028c2:	e8 ea d7 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f01028c7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028ca:	8d 83 f2 54 f8 ff    	lea    -0x7ab0e(%ebx),%eax
f01028d0:	50                   	push   %eax
f01028d1:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01028d7:	50                   	push   %eax
f01028d8:	68 a4 03 00 00       	push   $0x3a4
f01028dd:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01028e3:	50                   	push   %eax
f01028e4:	e8 c8 d7 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01028e9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028ec:	8d 83 08 50 f8 ff    	lea    -0x7aff8(%ebx),%eax
f01028f2:	50                   	push   %eax
f01028f3:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01028f9:	50                   	push   %eax
f01028fa:	68 a8 03 00 00       	push   $0x3a8
f01028ff:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102905:	50                   	push   %eax
f0102906:	e8 a6 d7 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010290b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010290e:	8d 83 64 50 f8 ff    	lea    -0x7af9c(%ebx),%eax
f0102914:	50                   	push   %eax
f0102915:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010291b:	50                   	push   %eax
f010291c:	68 a9 03 00 00       	push   $0x3a9
f0102921:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102927:	50                   	push   %eax
f0102928:	e8 84 d7 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f010292d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102930:	8d 83 07 55 f8 ff    	lea    -0x7aaf9(%ebx),%eax
f0102936:	50                   	push   %eax
f0102937:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010293d:	50                   	push   %eax
f010293e:	68 aa 03 00 00       	push   $0x3aa
f0102943:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102949:	50                   	push   %eax
f010294a:	e8 62 d7 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f010294f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102952:	8d 83 d5 54 f8 ff    	lea    -0x7ab2b(%ebx),%eax
f0102958:	50                   	push   %eax
f0102959:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010295f:	50                   	push   %eax
f0102960:	68 ab 03 00 00       	push   $0x3ab
f0102965:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f010296b:	50                   	push   %eax
f010296c:	e8 40 d7 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102971:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102974:	8d 83 8c 50 f8 ff    	lea    -0x7af74(%ebx),%eax
f010297a:	50                   	push   %eax
f010297b:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102981:	50                   	push   %eax
f0102982:	68 ae 03 00 00       	push   $0x3ae
f0102987:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f010298d:	50                   	push   %eax
f010298e:	e8 1e d7 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102993:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102996:	8d 83 29 54 f8 ff    	lea    -0x7abd7(%ebx),%eax
f010299c:	50                   	push   %eax
f010299d:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01029a3:	50                   	push   %eax
f01029a4:	68 b1 03 00 00       	push   $0x3b1
f01029a9:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01029af:	50                   	push   %eax
f01029b0:	e8 fc d6 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01029b5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029b8:	8d 83 30 4d f8 ff    	lea    -0x7b2d0(%ebx),%eax
f01029be:	50                   	push   %eax
f01029bf:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01029c5:	50                   	push   %eax
f01029c6:	68 b4 03 00 00       	push   $0x3b4
f01029cb:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01029d1:	50                   	push   %eax
f01029d2:	e8 da d6 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f01029d7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029da:	8d 83 8c 54 f8 ff    	lea    -0x7ab74(%ebx),%eax
f01029e0:	50                   	push   %eax
f01029e1:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01029e7:	50                   	push   %eax
f01029e8:	68 b6 03 00 00       	push   $0x3b6
f01029ed:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01029f3:	50                   	push   %eax
f01029f4:	e8 b8 d6 ff ff       	call   f01000b1 <_panic>
f01029f9:	52                   	push   %edx
f01029fa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029fd:	8d 83 a0 4a f8 ff    	lea    -0x7b560(%ebx),%eax
f0102a03:	50                   	push   %eax
f0102a04:	68 bd 03 00 00       	push   $0x3bd
f0102a09:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102a0f:	50                   	push   %eax
f0102a10:	e8 9c d6 ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102a15:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a18:	8d 83 18 55 f8 ff    	lea    -0x7aae8(%ebx),%eax
f0102a1e:	50                   	push   %eax
f0102a1f:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102a25:	50                   	push   %eax
f0102a26:	68 be 03 00 00       	push   $0x3be
f0102a2b:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102a31:	50                   	push   %eax
f0102a32:	e8 7a d6 ff ff       	call   f01000b1 <_panic>
f0102a37:	50                   	push   %eax
f0102a38:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a3b:	8d 83 a0 4a f8 ff    	lea    -0x7b560(%ebx),%eax
f0102a41:	50                   	push   %eax
f0102a42:	6a 56                	push   $0x56
f0102a44:	8d 83 b9 52 f8 ff    	lea    -0x7ad47(%ebx),%eax
f0102a4a:	50                   	push   %eax
f0102a4b:	e8 61 d6 ff ff       	call   f01000b1 <_panic>
f0102a50:	52                   	push   %edx
f0102a51:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a54:	8d 83 a0 4a f8 ff    	lea    -0x7b560(%ebx),%eax
f0102a5a:	50                   	push   %eax
f0102a5b:	6a 56                	push   $0x56
f0102a5d:	8d 83 b9 52 f8 ff    	lea    -0x7ad47(%ebx),%eax
f0102a63:	50                   	push   %eax
f0102a64:	e8 48 d6 ff ff       	call   f01000b1 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102a69:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a6c:	8d 83 30 55 f8 ff    	lea    -0x7aad0(%ebx),%eax
f0102a72:	50                   	push   %eax
f0102a73:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102a79:	50                   	push   %eax
f0102a7a:	68 c8 03 00 00       	push   $0x3c8
f0102a7f:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102a85:	50                   	push   %eax
f0102a86:	e8 26 d6 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a8b:	50                   	push   %eax
f0102a8c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a8f:	8d 83 34 4c f8 ff    	lea    -0x7b3cc(%ebx),%eax
f0102a95:	50                   	push   %eax
f0102a96:	68 c0 00 00 00       	push   $0xc0
f0102a9b:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102aa1:	50                   	push   %eax
f0102aa2:	e8 0a d6 ff ff       	call   f01000b1 <_panic>
f0102aa7:	50                   	push   %eax
f0102aa8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102aab:	8d 83 34 4c f8 ff    	lea    -0x7b3cc(%ebx),%eax
f0102ab1:	50                   	push   %eax
f0102ab2:	68 cc 00 00 00       	push   $0xcc
f0102ab7:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102abd:	50                   	push   %eax
f0102abe:	e8 ee d5 ff ff       	call   f01000b1 <_panic>
f0102ac3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ac6:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
f0102acc:	8d 83 34 4c f8 ff    	lea    -0x7b3cc(%ebx),%eax
f0102ad2:	50                   	push   %eax
f0102ad3:	68 dc 00 00 00       	push   $0xdc
f0102ad8:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102ade:	50                   	push   %eax
f0102adf:	e8 cd d5 ff ff       	call   f01000b1 <_panic>
f0102ae4:	ff 75 c0             	pushl  -0x40(%ebp)
f0102ae7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102aea:	8d 83 34 4c f8 ff    	lea    -0x7b3cc(%ebx),%eax
f0102af0:	50                   	push   %eax
f0102af1:	68 05 03 00 00       	push   $0x305
f0102af6:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102afc:	50                   	push   %eax
f0102afd:	e8 af d5 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0102b02:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102b08:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102b0b:	76 3f                	jbe    f0102b4c <mem_init+0x1770>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102b0d:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102b13:	89 f0                	mov    %esi,%eax
f0102b15:	e8 e1 df ff ff       	call   f0100afb <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102b1a:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102b21:	76 c1                	jbe    f0102ae4 <mem_init+0x1708>
f0102b23:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0102b26:	39 d0                	cmp    %edx,%eax
f0102b28:	74 d8                	je     f0102b02 <mem_init+0x1726>
f0102b2a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b2d:	8d 83 b0 50 f8 ff    	lea    -0x7af50(%ebx),%eax
f0102b33:	50                   	push   %eax
f0102b34:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102b3a:	50                   	push   %eax
f0102b3b:	68 05 03 00 00       	push   $0x305
f0102b40:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102b46:	50                   	push   %eax
f0102b47:	e8 65 d5 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102b4c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b4f:	c7 c0 4c 33 18 f0    	mov    $0xf018334c,%eax
f0102b55:	8b 00                	mov    (%eax),%eax
f0102b57:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102b5a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102b5d:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f0102b62:	8d 98 00 00 40 21    	lea    0x21400000(%eax),%ebx
f0102b68:	89 fa                	mov    %edi,%edx
f0102b6a:	89 f0                	mov    %esi,%eax
f0102b6c:	e8 8a df ff ff       	call   f0100afb <check_va2pa>
f0102b71:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102b78:	76 3d                	jbe    f0102bb7 <mem_init+0x17db>
f0102b7a:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0102b7d:	39 d0                	cmp    %edx,%eax
f0102b7f:	75 54                	jne    f0102bd5 <mem_init+0x17f9>
f0102b81:	81 c7 00 10 00 00    	add    $0x1000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102b87:	81 ff 00 80 c1 ee    	cmp    $0xeec18000,%edi
f0102b8d:	75 d9                	jne    f0102b68 <mem_init+0x178c>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102b8f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102b92:	c1 e7 0c             	shl    $0xc,%edi
f0102b95:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102b9a:	39 fb                	cmp    %edi,%ebx
f0102b9c:	73 7b                	jae    f0102c19 <mem_init+0x183d>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102b9e:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102ba4:	89 f0                	mov    %esi,%eax
f0102ba6:	e8 50 df ff ff       	call   f0100afb <check_va2pa>
f0102bab:	39 c3                	cmp    %eax,%ebx
f0102bad:	75 48                	jne    f0102bf7 <mem_init+0x181b>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102baf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102bb5:	eb e3                	jmp    f0102b9a <mem_init+0x17be>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bb7:	ff 75 cc             	pushl  -0x34(%ebp)
f0102bba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bbd:	8d 83 34 4c f8 ff    	lea    -0x7b3cc(%ebx),%eax
f0102bc3:	50                   	push   %eax
f0102bc4:	68 0a 03 00 00       	push   $0x30a
f0102bc9:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102bcf:	50                   	push   %eax
f0102bd0:	e8 dc d4 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102bd5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bd8:	8d 83 e4 50 f8 ff    	lea    -0x7af1c(%ebx),%eax
f0102bde:	50                   	push   %eax
f0102bdf:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102be5:	50                   	push   %eax
f0102be6:	68 0a 03 00 00       	push   $0x30a
f0102beb:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102bf1:	50                   	push   %eax
f0102bf2:	e8 ba d4 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102bf7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bfa:	8d 83 18 51 f8 ff    	lea    -0x7aee8(%ebx),%eax
f0102c00:	50                   	push   %eax
f0102c01:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102c07:	50                   	push   %eax
f0102c08:	68 0e 03 00 00       	push   $0x30e
f0102c0d:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102c13:	50                   	push   %eax
f0102c14:	e8 98 d4 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102c19:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102c1e:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102c21:	81 c7 00 80 00 20    	add    $0x20008000,%edi
f0102c27:	89 da                	mov    %ebx,%edx
f0102c29:	89 f0                	mov    %esi,%eax
f0102c2b:	e8 cb de ff ff       	call   f0100afb <check_va2pa>
f0102c30:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102c33:	39 c2                	cmp    %eax,%edx
f0102c35:	75 26                	jne    f0102c5d <mem_init+0x1881>
f0102c37:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102c3d:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102c43:	75 e2                	jne    f0102c27 <mem_init+0x184b>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102c45:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102c4a:	89 f0                	mov    %esi,%eax
f0102c4c:	e8 aa de ff ff       	call   f0100afb <check_va2pa>
f0102c51:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102c54:	75 29                	jne    f0102c7f <mem_init+0x18a3>
	for (i = 0; i < NPDENTRIES; i++) {
f0102c56:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c5b:	eb 6d                	jmp    f0102cca <mem_init+0x18ee>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102c5d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c60:	8d 83 40 51 f8 ff    	lea    -0x7aec0(%ebx),%eax
f0102c66:	50                   	push   %eax
f0102c67:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102c6d:	50                   	push   %eax
f0102c6e:	68 12 03 00 00       	push   $0x312
f0102c73:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102c79:	50                   	push   %eax
f0102c7a:	e8 32 d4 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102c7f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c82:	8d 83 88 51 f8 ff    	lea    -0x7ae78(%ebx),%eax
f0102c88:	50                   	push   %eax
f0102c89:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102c8f:	50                   	push   %eax
f0102c90:	68 13 03 00 00       	push   $0x313
f0102c95:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102c9b:	50                   	push   %eax
f0102c9c:	e8 10 d4 ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0102ca1:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102ca5:	74 52                	je     f0102cf9 <mem_init+0x191d>
	for (i = 0; i < NPDENTRIES; i++) {
f0102ca7:	83 c0 01             	add    $0x1,%eax
f0102caa:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102caf:	0f 87 bb 00 00 00    	ja     f0102d70 <mem_init+0x1994>
		switch (i) {
f0102cb5:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102cba:	72 0e                	jb     f0102cca <mem_init+0x18ee>
f0102cbc:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102cc1:	76 de                	jbe    f0102ca1 <mem_init+0x18c5>
f0102cc3:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102cc8:	74 d7                	je     f0102ca1 <mem_init+0x18c5>
			if (i >= PDX(KERNBASE)) {
f0102cca:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102ccf:	77 4a                	ja     f0102d1b <mem_init+0x193f>
				assert(pgdir[i] == 0);
f0102cd1:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102cd5:	74 d0                	je     f0102ca7 <mem_init+0x18cb>
f0102cd7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cda:	8d 83 82 55 f8 ff    	lea    -0x7aa7e(%ebx),%eax
f0102ce0:	50                   	push   %eax
f0102ce1:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102ce7:	50                   	push   %eax
f0102ce8:	68 23 03 00 00       	push   $0x323
f0102ced:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102cf3:	50                   	push   %eax
f0102cf4:	e8 b8 d3 ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0102cf9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cfc:	8d 83 60 55 f8 ff    	lea    -0x7aaa0(%ebx),%eax
f0102d02:	50                   	push   %eax
f0102d03:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102d09:	50                   	push   %eax
f0102d0a:	68 1c 03 00 00       	push   $0x31c
f0102d0f:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102d15:	50                   	push   %eax
f0102d16:	e8 96 d3 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102d1b:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102d1e:	f6 c2 01             	test   $0x1,%dl
f0102d21:	74 2b                	je     f0102d4e <mem_init+0x1972>
				assert(pgdir[i] & PTE_W);
f0102d23:	f6 c2 02             	test   $0x2,%dl
f0102d26:	0f 85 7b ff ff ff    	jne    f0102ca7 <mem_init+0x18cb>
f0102d2c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d2f:	8d 83 71 55 f8 ff    	lea    -0x7aa8f(%ebx),%eax
f0102d35:	50                   	push   %eax
f0102d36:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102d3c:	50                   	push   %eax
f0102d3d:	68 21 03 00 00       	push   $0x321
f0102d42:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102d48:	50                   	push   %eax
f0102d49:	e8 63 d3 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102d4e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d51:	8d 83 60 55 f8 ff    	lea    -0x7aaa0(%ebx),%eax
f0102d57:	50                   	push   %eax
f0102d58:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0102d5e:	50                   	push   %eax
f0102d5f:	68 20 03 00 00       	push   $0x320
f0102d64:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102d6a:	50                   	push   %eax
f0102d6b:	e8 41 d3 ff ff       	call   f01000b1 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102d70:	83 ec 0c             	sub    $0xc,%esp
f0102d73:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102d76:	8d 86 b8 51 f8 ff    	lea    -0x7ae48(%esi),%eax
f0102d7c:	50                   	push   %eax
f0102d7d:	89 f3                	mov    %esi,%ebx
f0102d7f:	e8 74 0d 00 00       	call   f0103af8 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102d84:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0102d8a:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102d8c:	83 c4 10             	add    $0x10,%esp
f0102d8f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d94:	0f 86 44 02 00 00    	jbe    f0102fde <mem_init+0x1c02>
	return (physaddr_t)kva - KERNBASE;
f0102d9a:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102d9f:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102da2:	b8 00 00 00 00       	mov    $0x0,%eax
f0102da7:	e8 cc dd ff ff       	call   f0100b78 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102dac:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102daf:	83 e0 f3             	and    $0xfffffff3,%eax
f0102db2:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102db7:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102dba:	83 ec 0c             	sub    $0xc,%esp
f0102dbd:	6a 00                	push   $0x0
f0102dbf:	e8 81 e2 ff ff       	call   f0101045 <page_alloc>
f0102dc4:	89 c6                	mov    %eax,%esi
f0102dc6:	83 c4 10             	add    $0x10,%esp
f0102dc9:	85 c0                	test   %eax,%eax
f0102dcb:	0f 84 29 02 00 00    	je     f0102ffa <mem_init+0x1c1e>
	assert((pp1 = page_alloc(0)));
f0102dd1:	83 ec 0c             	sub    $0xc,%esp
f0102dd4:	6a 00                	push   $0x0
f0102dd6:	e8 6a e2 ff ff       	call   f0101045 <page_alloc>
f0102ddb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102dde:	83 c4 10             	add    $0x10,%esp
f0102de1:	85 c0                	test   %eax,%eax
f0102de3:	0f 84 33 02 00 00    	je     f010301c <mem_init+0x1c40>
	assert((pp2 = page_alloc(0)));
f0102de9:	83 ec 0c             	sub    $0xc,%esp
f0102dec:	6a 00                	push   $0x0
f0102dee:	e8 52 e2 ff ff       	call   f0101045 <page_alloc>
f0102df3:	89 c7                	mov    %eax,%edi
f0102df5:	83 c4 10             	add    $0x10,%esp
f0102df8:	85 c0                	test   %eax,%eax
f0102dfa:	0f 84 3e 02 00 00    	je     f010303e <mem_init+0x1c62>
	page_free(pp0);
f0102e00:	83 ec 0c             	sub    $0xc,%esp
f0102e03:	56                   	push   %esi
f0102e04:	e8 c4 e2 ff ff       	call   f01010cd <page_free>
	return (pp - pages) << PGSHIFT;
f0102e09:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e0c:	c7 c0 10 40 18 f0    	mov    $0xf0184010,%eax
f0102e12:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102e15:	2b 08                	sub    (%eax),%ecx
f0102e17:	89 c8                	mov    %ecx,%eax
f0102e19:	c1 f8 03             	sar    $0x3,%eax
f0102e1c:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102e1f:	89 c1                	mov    %eax,%ecx
f0102e21:	c1 e9 0c             	shr    $0xc,%ecx
f0102e24:	83 c4 10             	add    $0x10,%esp
f0102e27:	c7 c2 08 40 18 f0    	mov    $0xf0184008,%edx
f0102e2d:	3b 0a                	cmp    (%edx),%ecx
f0102e2f:	0f 83 2b 02 00 00    	jae    f0103060 <mem_init+0x1c84>
	memset(page2kva(pp1), 1, PGSIZE);
f0102e35:	83 ec 04             	sub    $0x4,%esp
f0102e38:	68 00 10 00 00       	push   $0x1000
f0102e3d:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102e3f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102e44:	50                   	push   %eax
f0102e45:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e48:	e8 25 23 00 00       	call   f0105172 <memset>
	return (pp - pages) << PGSHIFT;
f0102e4d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e50:	c7 c0 10 40 18 f0    	mov    $0xf0184010,%eax
f0102e56:	89 f9                	mov    %edi,%ecx
f0102e58:	2b 08                	sub    (%eax),%ecx
f0102e5a:	89 c8                	mov    %ecx,%eax
f0102e5c:	c1 f8 03             	sar    $0x3,%eax
f0102e5f:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102e62:	89 c1                	mov    %eax,%ecx
f0102e64:	c1 e9 0c             	shr    $0xc,%ecx
f0102e67:	83 c4 10             	add    $0x10,%esp
f0102e6a:	c7 c2 08 40 18 f0    	mov    $0xf0184008,%edx
f0102e70:	3b 0a                	cmp    (%edx),%ecx
f0102e72:	0f 83 fe 01 00 00    	jae    f0103076 <mem_init+0x1c9a>
	memset(page2kva(pp2), 2, PGSIZE);
f0102e78:	83 ec 04             	sub    $0x4,%esp
f0102e7b:	68 00 10 00 00       	push   $0x1000
f0102e80:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102e82:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102e87:	50                   	push   %eax
f0102e88:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e8b:	e8 e2 22 00 00       	call   f0105172 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102e90:	6a 02                	push   $0x2
f0102e92:	68 00 10 00 00       	push   $0x1000
f0102e97:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102e9a:	53                   	push   %ebx
f0102e9b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e9e:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0102ea4:	ff 30                	pushl  (%eax)
f0102ea6:	e8 8d e4 ff ff       	call   f0101338 <page_insert>
	assert(pp1->pp_ref == 1);
f0102eab:	83 c4 20             	add    $0x20,%esp
f0102eae:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102eb3:	0f 85 d3 01 00 00    	jne    f010308c <mem_init+0x1cb0>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102eb9:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102ec0:	01 01 01 
f0102ec3:	0f 85 e5 01 00 00    	jne    f01030ae <mem_init+0x1cd2>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102ec9:	6a 02                	push   $0x2
f0102ecb:	68 00 10 00 00       	push   $0x1000
f0102ed0:	57                   	push   %edi
f0102ed1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ed4:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0102eda:	ff 30                	pushl  (%eax)
f0102edc:	e8 57 e4 ff ff       	call   f0101338 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ee1:	83 c4 10             	add    $0x10,%esp
f0102ee4:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102eeb:	02 02 02 
f0102eee:	0f 85 dc 01 00 00    	jne    f01030d0 <mem_init+0x1cf4>
	assert(pp2->pp_ref == 1);
f0102ef4:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ef9:	0f 85 f3 01 00 00    	jne    f01030f2 <mem_init+0x1d16>
	assert(pp1->pp_ref == 0);
f0102eff:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102f02:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102f07:	0f 85 07 02 00 00    	jne    f0103114 <mem_init+0x1d38>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102f0d:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102f14:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102f17:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f1a:	c7 c0 10 40 18 f0    	mov    $0xf0184010,%eax
f0102f20:	89 f9                	mov    %edi,%ecx
f0102f22:	2b 08                	sub    (%eax),%ecx
f0102f24:	89 c8                	mov    %ecx,%eax
f0102f26:	c1 f8 03             	sar    $0x3,%eax
f0102f29:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102f2c:	89 c1                	mov    %eax,%ecx
f0102f2e:	c1 e9 0c             	shr    $0xc,%ecx
f0102f31:	c7 c2 08 40 18 f0    	mov    $0xf0184008,%edx
f0102f37:	3b 0a                	cmp    (%edx),%ecx
f0102f39:	0f 83 f7 01 00 00    	jae    f0103136 <mem_init+0x1d5a>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f3f:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102f46:	03 03 03 
f0102f49:	0f 85 fd 01 00 00    	jne    f010314c <mem_init+0x1d70>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102f4f:	83 ec 08             	sub    $0x8,%esp
f0102f52:	68 00 10 00 00       	push   $0x1000
f0102f57:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f5a:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0102f60:	ff 30                	pushl  (%eax)
f0102f62:	e8 8d e3 ff ff       	call   f01012f4 <page_remove>
	assert(pp2->pp_ref == 0);
f0102f67:	83 c4 10             	add    $0x10,%esp
f0102f6a:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102f6f:	0f 85 f9 01 00 00    	jne    f010316e <mem_init+0x1d92>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102f75:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102f78:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0102f7e:	8b 08                	mov    (%eax),%ecx
f0102f80:	8b 11                	mov    (%ecx),%edx
f0102f82:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102f88:	c7 c0 10 40 18 f0    	mov    $0xf0184010,%eax
f0102f8e:	89 f7                	mov    %esi,%edi
f0102f90:	2b 38                	sub    (%eax),%edi
f0102f92:	89 f8                	mov    %edi,%eax
f0102f94:	c1 f8 03             	sar    $0x3,%eax
f0102f97:	c1 e0 0c             	shl    $0xc,%eax
f0102f9a:	39 c2                	cmp    %eax,%edx
f0102f9c:	0f 85 ee 01 00 00    	jne    f0103190 <mem_init+0x1db4>
	kern_pgdir[0] = 0;
f0102fa2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102fa8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102fad:	0f 85 ff 01 00 00    	jne    f01031b2 <mem_init+0x1dd6>
	pp0->pp_ref = 0;
f0102fb3:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102fb9:	83 ec 0c             	sub    $0xc,%esp
f0102fbc:	56                   	push   %esi
f0102fbd:	e8 0b e1 ff ff       	call   f01010cd <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102fc2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fc5:	8d 83 4c 52 f8 ff    	lea    -0x7adb4(%ebx),%eax
f0102fcb:	89 04 24             	mov    %eax,(%esp)
f0102fce:	e8 25 0b 00 00       	call   f0103af8 <cprintf>
}
f0102fd3:	83 c4 10             	add    $0x10,%esp
f0102fd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fd9:	5b                   	pop    %ebx
f0102fda:	5e                   	pop    %esi
f0102fdb:	5f                   	pop    %edi
f0102fdc:	5d                   	pop    %ebp
f0102fdd:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fde:	50                   	push   %eax
f0102fdf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fe2:	8d 83 34 4c f8 ff    	lea    -0x7b3cc(%ebx),%eax
f0102fe8:	50                   	push   %eax
f0102fe9:	68 f5 00 00 00       	push   $0xf5
f0102fee:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0102ff4:	50                   	push   %eax
f0102ff5:	e8 b7 d0 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0102ffa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ffd:	8d 83 7e 53 f8 ff    	lea    -0x7ac82(%ebx),%eax
f0103003:	50                   	push   %eax
f0103004:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010300a:	50                   	push   %eax
f010300b:	68 e3 03 00 00       	push   $0x3e3
f0103010:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0103016:	50                   	push   %eax
f0103017:	e8 95 d0 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f010301c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010301f:	8d 83 94 53 f8 ff    	lea    -0x7ac6c(%ebx),%eax
f0103025:	50                   	push   %eax
f0103026:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010302c:	50                   	push   %eax
f010302d:	68 e4 03 00 00       	push   $0x3e4
f0103032:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0103038:	50                   	push   %eax
f0103039:	e8 73 d0 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f010303e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103041:	8d 83 aa 53 f8 ff    	lea    -0x7ac56(%ebx),%eax
f0103047:	50                   	push   %eax
f0103048:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010304e:	50                   	push   %eax
f010304f:	68 e5 03 00 00       	push   $0x3e5
f0103054:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f010305a:	50                   	push   %eax
f010305b:	e8 51 d0 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103060:	50                   	push   %eax
f0103061:	8d 83 a0 4a f8 ff    	lea    -0x7b560(%ebx),%eax
f0103067:	50                   	push   %eax
f0103068:	6a 56                	push   $0x56
f010306a:	8d 83 b9 52 f8 ff    	lea    -0x7ad47(%ebx),%eax
f0103070:	50                   	push   %eax
f0103071:	e8 3b d0 ff ff       	call   f01000b1 <_panic>
f0103076:	50                   	push   %eax
f0103077:	8d 83 a0 4a f8 ff    	lea    -0x7b560(%ebx),%eax
f010307d:	50                   	push   %eax
f010307e:	6a 56                	push   $0x56
f0103080:	8d 83 b9 52 f8 ff    	lea    -0x7ad47(%ebx),%eax
f0103086:	50                   	push   %eax
f0103087:	e8 25 d0 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f010308c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010308f:	8d 83 7b 54 f8 ff    	lea    -0x7ab85(%ebx),%eax
f0103095:	50                   	push   %eax
f0103096:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010309c:	50                   	push   %eax
f010309d:	68 ea 03 00 00       	push   $0x3ea
f01030a2:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01030a8:	50                   	push   %eax
f01030a9:	e8 03 d0 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01030ae:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030b1:	8d 83 d8 51 f8 ff    	lea    -0x7ae28(%ebx),%eax
f01030b7:	50                   	push   %eax
f01030b8:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01030be:	50                   	push   %eax
f01030bf:	68 eb 03 00 00       	push   $0x3eb
f01030c4:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01030ca:	50                   	push   %eax
f01030cb:	e8 e1 cf ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01030d0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030d3:	8d 83 fc 51 f8 ff    	lea    -0x7ae04(%ebx),%eax
f01030d9:	50                   	push   %eax
f01030da:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01030e0:	50                   	push   %eax
f01030e1:	68 ed 03 00 00       	push   $0x3ed
f01030e6:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01030ec:	50                   	push   %eax
f01030ed:	e8 bf cf ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01030f2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030f5:	8d 83 9d 54 f8 ff    	lea    -0x7ab63(%ebx),%eax
f01030fb:	50                   	push   %eax
f01030fc:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0103102:	50                   	push   %eax
f0103103:	68 ee 03 00 00       	push   $0x3ee
f0103108:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f010310e:	50                   	push   %eax
f010310f:	e8 9d cf ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0103114:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103117:	8d 83 07 55 f8 ff    	lea    -0x7aaf9(%ebx),%eax
f010311d:	50                   	push   %eax
f010311e:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f0103124:	50                   	push   %eax
f0103125:	68 ef 03 00 00       	push   $0x3ef
f010312a:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0103130:	50                   	push   %eax
f0103131:	e8 7b cf ff ff       	call   f01000b1 <_panic>
f0103136:	50                   	push   %eax
f0103137:	8d 83 a0 4a f8 ff    	lea    -0x7b560(%ebx),%eax
f010313d:	50                   	push   %eax
f010313e:	6a 56                	push   $0x56
f0103140:	8d 83 b9 52 f8 ff    	lea    -0x7ad47(%ebx),%eax
f0103146:	50                   	push   %eax
f0103147:	e8 65 cf ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010314c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010314f:	8d 83 20 52 f8 ff    	lea    -0x7ade0(%ebx),%eax
f0103155:	50                   	push   %eax
f0103156:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010315c:	50                   	push   %eax
f010315d:	68 f1 03 00 00       	push   $0x3f1
f0103162:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f0103168:	50                   	push   %eax
f0103169:	e8 43 cf ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f010316e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103171:	8d 83 d5 54 f8 ff    	lea    -0x7ab2b(%ebx),%eax
f0103177:	50                   	push   %eax
f0103178:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010317e:	50                   	push   %eax
f010317f:	68 f3 03 00 00       	push   $0x3f3
f0103184:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f010318a:	50                   	push   %eax
f010318b:	e8 21 cf ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103190:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103193:	8d 83 30 4d f8 ff    	lea    -0x7b2d0(%ebx),%eax
f0103199:	50                   	push   %eax
f010319a:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01031a0:	50                   	push   %eax
f01031a1:	68 f6 03 00 00       	push   $0x3f6
f01031a6:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01031ac:	50                   	push   %eax
f01031ad:	e8 ff ce ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f01031b2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031b5:	8d 83 8c 54 f8 ff    	lea    -0x7ab74(%ebx),%eax
f01031bb:	50                   	push   %eax
f01031bc:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01031c2:	50                   	push   %eax
f01031c3:	68 f8 03 00 00       	push   $0x3f8
f01031c8:	8d 83 ad 52 f8 ff    	lea    -0x7ad53(%ebx),%eax
f01031ce:	50                   	push   %eax
f01031cf:	e8 dd ce ff ff       	call   f01000b1 <_panic>

f01031d4 <tlb_invalidate>:
{
f01031d4:	55                   	push   %ebp
f01031d5:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01031d7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031da:	0f 01 38             	invlpg (%eax)
}
f01031dd:	5d                   	pop    %ebp
f01031de:	c3                   	ret    

f01031df <user_mem_check>:
{
f01031df:	55                   	push   %ebp
f01031e0:	89 e5                	mov    %esp,%ebp
f01031e2:	57                   	push   %edi
f01031e3:	56                   	push   %esi
f01031e4:	53                   	push   %ebx
f01031e5:	83 ec 1c             	sub    $0x1c,%esp
f01031e8:	e8 1c d5 ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f01031ed:	05 33 de 07 00       	add    $0x7de33,%eax
f01031f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	const char *start = ROUNDDOWN(va, PGSIZE);
f01031f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01031f8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	const char *end = ROUNDUP((char *) va+len, PGSIZE);
f01031fe:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103201:	03 7d 10             	add    0x10(%ebp),%edi
f0103204:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f010320a:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
		if ((*pgdir_walk(env->env_pgdir, (void *)p, 0) & (perm | PTE_P)) != (perm | PTE_P)) {
f0103210:	8b 75 14             	mov    0x14(%ebp),%esi
f0103213:	83 ce 01             	or     $0x1,%esi
	for (const char *p = start; p < end; p += PGSIZE) {
f0103216:	39 fb                	cmp    %edi,%ebx
f0103218:	73 4c                	jae    f0103266 <user_mem_check+0x87>
		if ((*pgdir_walk(env->env_pgdir, (void *)p, 0) & (perm | PTE_P)) != (perm | PTE_P)) {
f010321a:	83 ec 04             	sub    $0x4,%esp
f010321d:	6a 00                	push   $0x0
f010321f:	53                   	push   %ebx
f0103220:	8b 45 08             	mov    0x8(%ebp),%eax
f0103223:	ff 70 5c             	pushl  0x5c(%eax)
f0103226:	e8 15 df ff ff       	call   f0101140 <pgdir_walk>
f010322b:	89 f2                	mov    %esi,%edx
f010322d:	23 10                	and    (%eax),%edx
f010322f:	83 c4 10             	add    $0x10,%esp
f0103232:	39 d6                	cmp    %edx,%esi
f0103234:	75 08                	jne    f010323e <user_mem_check+0x5f>
	for (const char *p = start; p < end; p += PGSIZE) {
f0103236:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010323c:	eb d8                	jmp    f0103216 <user_mem_check+0x37>
			if (p < (char *) va) 
f010323e:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103241:	73 13                	jae    f0103256 <user_mem_check+0x77>
				user_mem_check_addr = (int)va;
f0103243:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103246:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103249:	89 88 1c 23 00 00    	mov    %ecx,0x231c(%eax)
			return -E_FAULT;
f010324f:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103254:	eb 15                	jmp    f010326b <user_mem_check+0x8c>
				user_mem_check_addr = (int)p;
f0103256:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103259:	89 98 1c 23 00 00    	mov    %ebx,0x231c(%eax)
			return -E_FAULT;
f010325f:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103264:	eb 05                	jmp    f010326b <user_mem_check+0x8c>
	return 0;
f0103266:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010326b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010326e:	5b                   	pop    %ebx
f010326f:	5e                   	pop    %esi
f0103270:	5f                   	pop    %edi
f0103271:	5d                   	pop    %ebp
f0103272:	c3                   	ret    

f0103273 <user_mem_assert>:
{
f0103273:	55                   	push   %ebp
f0103274:	89 e5                	mov    %esp,%ebp
f0103276:	56                   	push   %esi
f0103277:	53                   	push   %ebx
f0103278:	e8 ea ce ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010327d:	81 c3 a3 dd 07 00    	add    $0x7dda3,%ebx
f0103283:	8b 75 08             	mov    0x8(%ebp),%esi
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103286:	8b 45 14             	mov    0x14(%ebp),%eax
f0103289:	83 c8 04             	or     $0x4,%eax
f010328c:	50                   	push   %eax
f010328d:	ff 75 10             	pushl  0x10(%ebp)
f0103290:	ff 75 0c             	pushl  0xc(%ebp)
f0103293:	56                   	push   %esi
f0103294:	e8 46 ff ff ff       	call   f01031df <user_mem_check>
f0103299:	83 c4 10             	add    $0x10,%esp
f010329c:	85 c0                	test   %eax,%eax
f010329e:	78 07                	js     f01032a7 <user_mem_assert+0x34>
}
f01032a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01032a3:	5b                   	pop    %ebx
f01032a4:	5e                   	pop    %esi
f01032a5:	5d                   	pop    %ebp
f01032a6:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f01032a7:	83 ec 04             	sub    $0x4,%esp
f01032aa:	ff b3 1c 23 00 00    	pushl  0x231c(%ebx)
f01032b0:	ff 76 48             	pushl  0x48(%esi)
f01032b3:	8d 83 78 52 f8 ff    	lea    -0x7ad88(%ebx),%eax
f01032b9:	50                   	push   %eax
f01032ba:	e8 39 08 00 00       	call   f0103af8 <cprintf>
		env_destroy(env);	// may not return
f01032bf:	89 34 24             	mov    %esi,(%esp)
f01032c2:	e8 c3 06 00 00       	call   f010398a <env_destroy>
f01032c7:	83 c4 10             	add    $0x10,%esp
}
f01032ca:	eb d4                	jmp    f01032a0 <user_mem_assert+0x2d>

f01032cc <__x86.get_pc_thunk.cx>:
f01032cc:	8b 0c 24             	mov    (%esp),%ecx
f01032cf:	c3                   	ret    

f01032d0 <__x86.get_pc_thunk.si>:
f01032d0:	8b 34 24             	mov    (%esp),%esi
f01032d3:	c3                   	ret    

f01032d4 <__x86.get_pc_thunk.di>:
f01032d4:	8b 3c 24             	mov    (%esp),%edi
f01032d7:	c3                   	ret    

f01032d8 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01032d8:	55                   	push   %ebp
f01032d9:	89 e5                	mov    %esp,%ebp
f01032db:	57                   	push   %edi
f01032dc:	56                   	push   %esi
f01032dd:	53                   	push   %ebx
f01032de:	83 ec 1c             	sub    $0x1c,%esp
f01032e1:	e8 81 ce ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01032e6:	81 c3 3a dd 07 00    	add    $0x7dd3a,%ebx
f01032ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	size_t size = ROUNDUP((char *) va+len, PGSIZE) - ROUNDDOWN((char *) va, PGSIZE);
f01032ef:	89 d7                	mov    %edx,%edi
f01032f1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01032f7:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f01032fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103303:	29 f8                	sub    %edi,%eax
f0103305:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	char *start = ROUNDDOWN((char *) va, PGSIZE);
	struct PageInfo *pp;
	for (int i = 0; i < size; i += PGSIZE) {
f0103308:	be 00 00 00 00       	mov    $0x0,%esi
f010330d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f0103310:	76 46                	jbe    f0103358 <region_alloc+0x80>
		pp = page_alloc(0);
f0103312:	83 ec 0c             	sub    $0xc,%esp
f0103315:	6a 00                	push   $0x0
f0103317:	e8 29 dd ff ff       	call   f0101045 <page_alloc>
		if (page_insert(e->env_pgdir, pp, (void *) (start+i), PTE_W | PTE_U | PTE_P) < 0) {
f010331c:	6a 07                	push   $0x7
f010331e:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0103321:	52                   	push   %edx
f0103322:	50                   	push   %eax
f0103323:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103326:	ff 70 5c             	pushl  0x5c(%eax)
f0103329:	e8 0a e0 ff ff       	call   f0101338 <page_insert>
f010332e:	83 c4 20             	add    $0x20,%esp
f0103331:	85 c0                	test   %eax,%eax
f0103333:	78 08                	js     f010333d <region_alloc+0x65>
	for (int i = 0; i < size; i += PGSIZE) {
f0103335:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010333b:	eb d0                	jmp    f010330d <region_alloc+0x35>
			panic("No memory for environment!\n");
f010333d:	83 ec 04             	sub    $0x4,%esp
f0103340:	8d 83 90 55 f8 ff    	lea    -0x7aa70(%ebx),%eax
f0103346:	50                   	push   %eax
f0103347:	68 27 01 00 00       	push   $0x127
f010334c:	8d 83 ac 55 f8 ff    	lea    -0x7aa54(%ebx),%eax
f0103352:	50                   	push   %eax
f0103353:	e8 59 cd ff ff       	call   f01000b1 <_panic>
		}
	}
}
f0103358:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010335b:	5b                   	pop    %ebx
f010335c:	5e                   	pop    %esi
f010335d:	5f                   	pop    %edi
f010335e:	5d                   	pop    %ebp
f010335f:	c3                   	ret    

f0103360 <envid2env>:
{
f0103360:	55                   	push   %ebp
f0103361:	89 e5                	mov    %esp,%ebp
f0103363:	53                   	push   %ebx
f0103364:	e8 63 ff ff ff       	call   f01032cc <__x86.get_pc_thunk.cx>
f0103369:	81 c1 b7 dc 07 00    	add    $0x7dcb7,%ecx
f010336f:	8b 55 08             	mov    0x8(%ebp),%edx
f0103372:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if (envid == 0) {
f0103375:	85 d2                	test   %edx,%edx
f0103377:	74 41                	je     f01033ba <envid2env+0x5a>
	e = &envs[ENVX(envid)];
f0103379:	89 d0                	mov    %edx,%eax
f010337b:	25 ff 03 00 00       	and    $0x3ff,%eax
f0103380:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103383:	c1 e0 05             	shl    $0x5,%eax
f0103386:	03 81 2c 23 00 00    	add    0x232c(%ecx),%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010338c:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f0103390:	74 3a                	je     f01033cc <envid2env+0x6c>
f0103392:	39 50 48             	cmp    %edx,0x48(%eax)
f0103395:	75 35                	jne    f01033cc <envid2env+0x6c>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103397:	84 db                	test   %bl,%bl
f0103399:	74 12                	je     f01033ad <envid2env+0x4d>
f010339b:	8b 91 28 23 00 00    	mov    0x2328(%ecx),%edx
f01033a1:	39 c2                	cmp    %eax,%edx
f01033a3:	74 08                	je     f01033ad <envid2env+0x4d>
f01033a5:	8b 5a 48             	mov    0x48(%edx),%ebx
f01033a8:	39 58 4c             	cmp    %ebx,0x4c(%eax)
f01033ab:	75 2f                	jne    f01033dc <envid2env+0x7c>
	*env_store = e;
f01033ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01033b0:	89 03                	mov    %eax,(%ebx)
	return 0;
f01033b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033b7:	5b                   	pop    %ebx
f01033b8:	5d                   	pop    %ebp
f01033b9:	c3                   	ret    
		*env_store = curenv;
f01033ba:	8b 81 28 23 00 00    	mov    0x2328(%ecx),%eax
f01033c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01033c3:	89 01                	mov    %eax,(%ecx)
		return 0;
f01033c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01033ca:	eb eb                	jmp    f01033b7 <envid2env+0x57>
		*env_store = 0;
f01033cc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01033d5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01033da:	eb db                	jmp    f01033b7 <envid2env+0x57>
		*env_store = 0;
f01033dc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01033e5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01033ea:	eb cb                	jmp    f01033b7 <envid2env+0x57>

f01033ec <env_init_percpu>:
{
f01033ec:	55                   	push   %ebp
f01033ed:	89 e5                	mov    %esp,%ebp
f01033ef:	e8 15 d3 ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f01033f4:	05 2c dc 07 00       	add    $0x7dc2c,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f01033f9:	8d 80 e0 1f 00 00    	lea    0x1fe0(%eax),%eax
f01033ff:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103402:	b8 23 00 00 00       	mov    $0x23,%eax
f0103407:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103409:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010340b:	b8 10 00 00 00       	mov    $0x10,%eax
f0103410:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103412:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103414:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103416:	ea 1d 34 10 f0 08 00 	ljmp   $0x8,$0xf010341d
	asm volatile("lldt %0" : : "r" (sel));
f010341d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103422:	0f 00 d0             	lldt   %ax
}
f0103425:	5d                   	pop    %ebp
f0103426:	c3                   	ret    

f0103427 <env_init>:
{
f0103427:	55                   	push   %ebp
f0103428:	89 e5                	mov    %esp,%ebp
f010342a:	e8 9d fe ff ff       	call   f01032cc <__x86.get_pc_thunk.cx>
f010342f:	81 c1 f1 db 07 00    	add    $0x7dbf1,%ecx
f0103435:	8b 81 2c 23 00 00    	mov    0x232c(%ecx),%eax
f010343b:	83 c0 60             	add    $0x60,%eax
	for (int i = 0; i < NENV; i++) {
f010343e:	ba 00 00 00 00       	mov    $0x0,%edx
		envs[i].env_status = ENV_FREE;
f0103443:	c7 40 f4 00 00 00 00 	movl   $0x0,-0xc(%eax)
		envs[i].env_id = 0;
f010344a:	c7 40 e8 00 00 00 00 	movl   $0x0,-0x18(%eax)
		if (i < NENV-1)
f0103451:	81 fa fe 03 00 00    	cmp    $0x3fe,%edx
f0103457:	7f 24                	jg     f010347d <env_init+0x56>
			envs[i].env_link = &envs[i+1];
f0103459:	89 40 e4             	mov    %eax,-0x1c(%eax)
	for (int i = 0; i < NENV; i++) {
f010345c:	83 c2 01             	add    $0x1,%edx
f010345f:	83 c0 60             	add    $0x60,%eax
f0103462:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0103468:	75 d9                	jne    f0103443 <env_init+0x1c>
	env_free_list = envs;
f010346a:	8b 81 2c 23 00 00    	mov    0x232c(%ecx),%eax
f0103470:	89 81 30 23 00 00    	mov    %eax,0x2330(%ecx)
	env_init_percpu();
f0103476:	e8 71 ff ff ff       	call   f01033ec <env_init_percpu>
}
f010347b:	5d                   	pop    %ebp
f010347c:	c3                   	ret    
			envs[i].env_link = NULL;
f010347d:	c7 40 e4 00 00 00 00 	movl   $0x0,-0x1c(%eax)
f0103484:	eb d6                	jmp    f010345c <env_init+0x35>

f0103486 <env_alloc>:
{
f0103486:	55                   	push   %ebp
f0103487:	89 e5                	mov    %esp,%ebp
f0103489:	56                   	push   %esi
f010348a:	53                   	push   %ebx
f010348b:	e8 d7 cc ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103490:	81 c3 90 db 07 00    	add    $0x7db90,%ebx
	if (!(e = env_free_list))
f0103496:	8b b3 30 23 00 00    	mov    0x2330(%ebx),%esi
f010349c:	85 f6                	test   %esi,%esi
f010349e:	0f 84 79 01 00 00    	je     f010361d <env_alloc+0x197>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01034a4:	83 ec 0c             	sub    $0xc,%esp
f01034a7:	6a 01                	push   $0x1
f01034a9:	e8 97 db ff ff       	call   f0101045 <page_alloc>
f01034ae:	83 c4 10             	add    $0x10,%esp
f01034b1:	85 c0                	test   %eax,%eax
f01034b3:	0f 84 6b 01 00 00    	je     f0103624 <env_alloc+0x19e>
	p->pp_ref++;
f01034b9:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01034be:	c7 c2 10 40 18 f0    	mov    $0xf0184010,%edx
f01034c4:	2b 02                	sub    (%edx),%eax
f01034c6:	c1 f8 03             	sar    $0x3,%eax
f01034c9:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01034cc:	89 c1                	mov    %eax,%ecx
f01034ce:	c1 e9 0c             	shr    $0xc,%ecx
f01034d1:	c7 c2 08 40 18 f0    	mov    $0xf0184008,%edx
f01034d7:	3b 0a                	cmp    (%edx),%ecx
f01034d9:	0f 83 0f 01 00 00    	jae    f01035ee <env_alloc+0x168>
	return (void *)(pa + KERNBASE);
f01034df:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *) page2kva(p);
f01034e4:	89 46 5c             	mov    %eax,0x5c(%esi)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01034e7:	83 ec 04             	sub    $0x4,%esp
f01034ea:	68 00 10 00 00       	push   $0x1000
f01034ef:	c7 c2 0c 40 18 f0    	mov    $0xf018400c,%edx
f01034f5:	ff 32                	pushl  (%edx)
f01034f7:	50                   	push   %eax
f01034f8:	e8 2a 1d 00 00       	call   f0105227 <memcpy>
f01034fd:	83 c4 10             	add    $0x10,%esp
f0103500:	b8 00 00 00 00       	mov    $0x0,%eax
		e->env_pgdir[i] = 0;
f0103505:	8b 56 5c             	mov    0x5c(%esi),%edx
f0103508:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f010350f:	83 c0 04             	add    $0x4,%eax
	for (int i = 0; i < UTOP / PTSIZE; i++)
f0103512:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103517:	75 ec                	jne    f0103505 <env_alloc+0x7f>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103519:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f010351c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103521:	0f 86 dd 00 00 00    	jbe    f0103604 <env_alloc+0x17e>
	return (physaddr_t)kva - KERNBASE;
f0103527:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010352d:	83 ca 05             	or     $0x5,%edx
f0103530:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103536:	8b 46 48             	mov    0x48(%esi),%eax
f0103539:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010353e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103543:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103548:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010354b:	89 f2                	mov    %esi,%edx
f010354d:	2b 93 2c 23 00 00    	sub    0x232c(%ebx),%edx
f0103553:	c1 fa 05             	sar    $0x5,%edx
f0103556:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010355c:	09 d0                	or     %edx,%eax
f010355e:	89 46 48             	mov    %eax,0x48(%esi)
	e->env_parent_id = parent_id;
f0103561:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103564:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f0103567:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f010356e:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f0103575:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010357c:	83 ec 04             	sub    $0x4,%esp
f010357f:	6a 44                	push   $0x44
f0103581:	6a 00                	push   $0x0
f0103583:	56                   	push   %esi
f0103584:	e8 e9 1b 00 00       	call   f0105172 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103589:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f010358f:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f0103595:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f010359b:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f01035a2:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	env_free_list = e->env_link;
f01035a8:	8b 46 44             	mov    0x44(%esi),%eax
f01035ab:	89 83 30 23 00 00    	mov    %eax,0x2330(%ebx)
	*newenv_store = e;
f01035b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01035b4:	89 30                	mov    %esi,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01035b6:	8b 4e 48             	mov    0x48(%esi),%ecx
f01035b9:	8b 83 28 23 00 00    	mov    0x2328(%ebx),%eax
f01035bf:	83 c4 10             	add    $0x10,%esp
f01035c2:	ba 00 00 00 00       	mov    $0x0,%edx
f01035c7:	85 c0                	test   %eax,%eax
f01035c9:	74 03                	je     f01035ce <env_alloc+0x148>
f01035cb:	8b 50 48             	mov    0x48(%eax),%edx
f01035ce:	83 ec 04             	sub    $0x4,%esp
f01035d1:	51                   	push   %ecx
f01035d2:	52                   	push   %edx
f01035d3:	8d 83 b7 55 f8 ff    	lea    -0x7aa49(%ebx),%eax
f01035d9:	50                   	push   %eax
f01035da:	e8 19 05 00 00       	call   f0103af8 <cprintf>
	return 0;
f01035df:	83 c4 10             	add    $0x10,%esp
f01035e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01035e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01035ea:	5b                   	pop    %ebx
f01035eb:	5e                   	pop    %esi
f01035ec:	5d                   	pop    %ebp
f01035ed:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01035ee:	50                   	push   %eax
f01035ef:	8d 83 a0 4a f8 ff    	lea    -0x7b560(%ebx),%eax
f01035f5:	50                   	push   %eax
f01035f6:	6a 56                	push   $0x56
f01035f8:	8d 83 b9 52 f8 ff    	lea    -0x7ad47(%ebx),%eax
f01035fe:	50                   	push   %eax
f01035ff:	e8 ad ca ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103604:	50                   	push   %eax
f0103605:	8d 83 34 4c f8 ff    	lea    -0x7b3cc(%ebx),%eax
f010360b:	50                   	push   %eax
f010360c:	68 cb 00 00 00       	push   $0xcb
f0103611:	8d 83 ac 55 f8 ff    	lea    -0x7aa54(%ebx),%eax
f0103617:	50                   	push   %eax
f0103618:	e8 94 ca ff ff       	call   f01000b1 <_panic>
		return -E_NO_FREE_ENV;
f010361d:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103622:	eb c3                	jmp    f01035e7 <env_alloc+0x161>
		return -E_NO_MEM;
f0103624:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103629:	eb bc                	jmp    f01035e7 <env_alloc+0x161>

f010362b <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010362b:	55                   	push   %ebp
f010362c:	89 e5                	mov    %esp,%ebp
f010362e:	57                   	push   %edi
f010362f:	56                   	push   %esi
f0103630:	53                   	push   %ebx
f0103631:	83 ec 34             	sub    $0x34,%esp
f0103634:	e8 2e cb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103639:	81 c3 e7 d9 07 00    	add    $0x7d9e7,%ebx
f010363f:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
	int r;
	if ((r = env_alloc(&e, 0)))
f0103642:	6a 00                	push   $0x0
f0103644:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103647:	50                   	push   %eax
f0103648:	e8 39 fe ff ff       	call   f0103486 <env_alloc>
f010364d:	83 c4 10             	add    $0x10,%esp
f0103650:	85 c0                	test   %eax,%eax
f0103652:	75 42                	jne    f0103696 <env_create+0x6b>
		panic("env_create: %e", r);
	e->env_type = type;	
f0103654:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103657:	89 c1                	mov    %eax,%ecx
f0103659:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010365c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010365f:	89 41 50             	mov    %eax,0x50(%ecx)
	if (elf->e_magic != ELF_MAGIC)
f0103662:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103668:	75 45                	jne    f01036af <env_create+0x84>
	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f010366a:	89 fe                	mov    %edi,%esi
f010366c:	03 77 1c             	add    0x1c(%edi),%esi
	eph = ph + elf->e_phnum;
f010366f:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
f0103673:	c1 e0 05             	shl    $0x5,%eax
f0103676:	01 f0                	add    %esi,%eax
f0103678:	89 c1                	mov    %eax,%ecx
	lcr3(PADDR(e->env_pgdir));
f010367a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010367d:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103680:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103685:	76 43                	jbe    f01036ca <env_create+0x9f>
	return (physaddr_t)kva - KERNBASE;
f0103687:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010368c:	0f 22 d8             	mov    %eax,%cr3
f010368f:	89 7d 08             	mov    %edi,0x8(%ebp)
f0103692:	89 cf                	mov    %ecx,%edi
f0103694:	eb 50                	jmp    f01036e6 <env_create+0xbb>
		panic("env_create: %e", r);
f0103696:	50                   	push   %eax
f0103697:	8d 83 cc 55 f8 ff    	lea    -0x7aa34(%ebx),%eax
f010369d:	50                   	push   %eax
f010369e:	68 8f 01 00 00       	push   $0x18f
f01036a3:	8d 83 ac 55 f8 ff    	lea    -0x7aa54(%ebx),%eax
f01036a9:	50                   	push   %eax
f01036aa:	e8 02 ca ff ff       	call   f01000b1 <_panic>
		panic("Invalid ELF header!\n");
f01036af:	83 ec 04             	sub    $0x4,%esp
f01036b2:	8d 83 db 55 f8 ff    	lea    -0x7aa25(%ebx),%eax
f01036b8:	50                   	push   %eax
f01036b9:	68 67 01 00 00       	push   $0x167
f01036be:	8d 83 ac 55 f8 ff    	lea    -0x7aa54(%ebx),%eax
f01036c4:	50                   	push   %eax
f01036c5:	e8 e7 c9 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036ca:	50                   	push   %eax
f01036cb:	8d 83 34 4c f8 ff    	lea    -0x7b3cc(%ebx),%eax
f01036d1:	50                   	push   %eax
f01036d2:	68 6c 01 00 00       	push   $0x16c
f01036d7:	8d 83 ac 55 f8 ff    	lea    -0x7aa54(%ebx),%eax
f01036dd:	50                   	push   %eax
f01036de:	e8 ce c9 ff ff       	call   f01000b1 <_panic>
	for (; ph < eph; ph++) {
f01036e3:	83 c6 20             	add    $0x20,%esi
f01036e6:	39 f7                	cmp    %esi,%edi
f01036e8:	76 44                	jbe    f010372e <env_create+0x103>
		if (ph->p_type == ELF_PROG_LOAD) {
f01036ea:	83 3e 01             	cmpl   $0x1,(%esi)
f01036ed:	75 f4                	jne    f01036e3 <env_create+0xb8>
			region_alloc(e, (char *) ph->p_va, ph->p_memsz);
f01036ef:	8b 4e 14             	mov    0x14(%esi),%ecx
f01036f2:	8b 56 08             	mov    0x8(%esi),%edx
f01036f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01036f8:	e8 db fb ff ff       	call   f01032d8 <region_alloc>
			memset((char *) ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);  // Clear padding
f01036fd:	8b 46 10             	mov    0x10(%esi),%eax
f0103700:	83 ec 04             	sub    $0x4,%esp
f0103703:	8b 56 14             	mov    0x14(%esi),%edx
f0103706:	29 c2                	sub    %eax,%edx
f0103708:	52                   	push   %edx
f0103709:	6a 00                	push   $0x0
f010370b:	03 46 08             	add    0x8(%esi),%eax
f010370e:	50                   	push   %eax
f010370f:	e8 5e 1a 00 00       	call   f0105172 <memset>
			memmove((char *) ph->p_va, (char *) binary + ph->p_offset, ph->p_filesz);
f0103714:	83 c4 0c             	add    $0xc,%esp
f0103717:	ff 76 10             	pushl  0x10(%esi)
f010371a:	8b 45 08             	mov    0x8(%ebp),%eax
f010371d:	03 46 04             	add    0x4(%esi),%eax
f0103720:	50                   	push   %eax
f0103721:	ff 76 08             	pushl  0x8(%esi)
f0103724:	e8 96 1a 00 00       	call   f01051bf <memmove>
f0103729:	83 c4 10             	add    $0x10,%esp
f010372c:	eb b5                	jmp    f01036e3 <env_create+0xb8>
f010372e:	8b 7d 08             	mov    0x8(%ebp),%edi
	lcr3(PADDR(kern_pgdir));
f0103731:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f0103737:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103739:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010373e:	76 2a                	jbe    f010376a <env_create+0x13f>
	return (physaddr_t)kva - KERNBASE;
f0103740:	05 00 00 00 10       	add    $0x10000000,%eax
f0103745:	0f 22 d8             	mov    %eax,%cr3
	e->env_tf.tf_eip = (uintptr_t)(elf->e_entry);
f0103748:	8b 47 18             	mov    0x18(%edi),%eax
f010374b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010374e:	89 43 30             	mov    %eax,0x30(%ebx)
	region_alloc(e, (char *) (USTACKTOP - PGSIZE), PGSIZE);	
f0103751:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103756:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010375b:	89 d8                	mov    %ebx,%eax
f010375d:	e8 76 fb ff ff       	call   f01032d8 <region_alloc>
	load_icode(e, binary);
}
f0103762:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103765:	5b                   	pop    %ebx
f0103766:	5e                   	pop    %esi
f0103767:	5f                   	pop    %edi
f0103768:	5d                   	pop    %ebp
f0103769:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010376a:	50                   	push   %eax
f010376b:	8d 83 34 4c f8 ff    	lea    -0x7b3cc(%ebx),%eax
f0103771:	50                   	push   %eax
f0103772:	68 75 01 00 00       	push   $0x175
f0103777:	8d 83 ac 55 f8 ff    	lea    -0x7aa54(%ebx),%eax
f010377d:	50                   	push   %eax
f010377e:	e8 2e c9 ff ff       	call   f01000b1 <_panic>

f0103783 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103783:	55                   	push   %ebp
f0103784:	89 e5                	mov    %esp,%ebp
f0103786:	57                   	push   %edi
f0103787:	56                   	push   %esi
f0103788:	53                   	push   %ebx
f0103789:	83 ec 2c             	sub    $0x2c,%esp
f010378c:	e8 d6 c9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103791:	81 c3 8f d8 07 00    	add    $0x7d88f,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103797:	8b 93 28 23 00 00    	mov    0x2328(%ebx),%edx
f010379d:	3b 55 08             	cmp    0x8(%ebp),%edx
f01037a0:	75 17                	jne    f01037b9 <env_free+0x36>
		lcr3(PADDR(kern_pgdir));
f01037a2:	c7 c0 0c 40 18 f0    	mov    $0xf018400c,%eax
f01037a8:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01037aa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037af:	76 46                	jbe    f01037f7 <env_free+0x74>
	return (physaddr_t)kva - KERNBASE;
f01037b1:	05 00 00 00 10       	add    $0x10000000,%eax
f01037b6:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01037b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01037bc:	8b 48 48             	mov    0x48(%eax),%ecx
f01037bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01037c4:	85 d2                	test   %edx,%edx
f01037c6:	74 03                	je     f01037cb <env_free+0x48>
f01037c8:	8b 42 48             	mov    0x48(%edx),%eax
f01037cb:	83 ec 04             	sub    $0x4,%esp
f01037ce:	51                   	push   %ecx
f01037cf:	50                   	push   %eax
f01037d0:	8d 83 f0 55 f8 ff    	lea    -0x7aa10(%ebx),%eax
f01037d6:	50                   	push   %eax
f01037d7:	e8 1c 03 00 00       	call   f0103af8 <cprintf>
f01037dc:	83 c4 10             	add    $0x10,%esp
f01037df:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	if (PGNUM(pa) >= npages)
f01037e6:	c7 c0 08 40 18 f0    	mov    $0xf0184008,%eax
f01037ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (PGNUM(pa) >= npages)
f01037ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01037f2:	e9 9f 00 00 00       	jmp    f0103896 <env_free+0x113>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037f7:	50                   	push   %eax
f01037f8:	8d 83 34 4c f8 ff    	lea    -0x7b3cc(%ebx),%eax
f01037fe:	50                   	push   %eax
f01037ff:	68 a2 01 00 00       	push   $0x1a2
f0103804:	8d 83 ac 55 f8 ff    	lea    -0x7aa54(%ebx),%eax
f010380a:	50                   	push   %eax
f010380b:	e8 a1 c8 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103810:	50                   	push   %eax
f0103811:	8d 83 a0 4a f8 ff    	lea    -0x7b560(%ebx),%eax
f0103817:	50                   	push   %eax
f0103818:	68 b1 01 00 00       	push   $0x1b1
f010381d:	8d 83 ac 55 f8 ff    	lea    -0x7aa54(%ebx),%eax
f0103823:	50                   	push   %eax
f0103824:	e8 88 c8 ff ff       	call   f01000b1 <_panic>
f0103829:	83 c6 04             	add    $0x4,%esi
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010382c:	39 fe                	cmp    %edi,%esi
f010382e:	74 24                	je     f0103854 <env_free+0xd1>
			if (pt[pteno] & PTE_P)
f0103830:	f6 06 01             	testb  $0x1,(%esi)
f0103833:	74 f4                	je     f0103829 <env_free+0xa6>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103835:	83 ec 08             	sub    $0x8,%esp
f0103838:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010383b:	01 f0                	add    %esi,%eax
f010383d:	c1 e0 0a             	shl    $0xa,%eax
f0103840:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103843:	50                   	push   %eax
f0103844:	8b 45 08             	mov    0x8(%ebp),%eax
f0103847:	ff 70 5c             	pushl  0x5c(%eax)
f010384a:	e8 a5 da ff ff       	call   f01012f4 <page_remove>
f010384f:	83 c4 10             	add    $0x10,%esp
f0103852:	eb d5                	jmp    f0103829 <env_free+0xa6>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103854:	8b 45 08             	mov    0x8(%ebp),%eax
f0103857:	8b 40 5c             	mov    0x5c(%eax),%eax
f010385a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010385d:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103864:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103867:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010386a:	3b 10                	cmp    (%eax),%edx
f010386c:	73 6f                	jae    f01038dd <env_free+0x15a>
		page_decref(pa2page(pa));
f010386e:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103871:	c7 c0 10 40 18 f0    	mov    $0xf0184010,%eax
f0103877:	8b 00                	mov    (%eax),%eax
f0103879:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010387c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010387f:	50                   	push   %eax
f0103880:	e8 92 d8 ff ff       	call   f0101117 <page_decref>
f0103885:	83 c4 10             	add    $0x10,%esp
f0103888:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f010388c:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010388f:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103894:	74 5f                	je     f01038f5 <env_free+0x172>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103896:	8b 45 08             	mov    0x8(%ebp),%eax
f0103899:	8b 40 5c             	mov    0x5c(%eax),%eax
f010389c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010389f:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01038a2:	a8 01                	test   $0x1,%al
f01038a4:	74 e2                	je     f0103888 <env_free+0x105>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01038a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01038ab:	89 c2                	mov    %eax,%edx
f01038ad:	c1 ea 0c             	shr    $0xc,%edx
f01038b0:	89 55 d8             	mov    %edx,-0x28(%ebp)
f01038b3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01038b6:	39 11                	cmp    %edx,(%ecx)
f01038b8:	0f 86 52 ff ff ff    	jbe    f0103810 <env_free+0x8d>
	return (void *)(pa + KERNBASE);
f01038be:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01038c4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01038c7:	c1 e2 14             	shl    $0x14,%edx
f01038ca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01038cd:	8d b8 00 10 00 f0    	lea    -0xffff000(%eax),%edi
f01038d3:	f7 d8                	neg    %eax
f01038d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01038d8:	e9 53 ff ff ff       	jmp    f0103830 <env_free+0xad>
		panic("pa2page called with invalid pa");
f01038dd:	83 ec 04             	sub    $0x4,%esp
f01038e0:	8d 83 d8 4b f8 ff    	lea    -0x7b428(%ebx),%eax
f01038e6:	50                   	push   %eax
f01038e7:	6a 4f                	push   $0x4f
f01038e9:	8d 83 b9 52 f8 ff    	lea    -0x7ad47(%ebx),%eax
f01038ef:	50                   	push   %eax
f01038f0:	e8 bc c7 ff ff       	call   f01000b1 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01038f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01038f8:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01038fb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103900:	76 57                	jbe    f0103959 <env_free+0x1d6>
	e->env_pgdir = 0;
f0103902:	8b 55 08             	mov    0x8(%ebp),%edx
f0103905:	c7 42 5c 00 00 00 00 	movl   $0x0,0x5c(%edx)
	return (physaddr_t)kva - KERNBASE;
f010390c:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103911:	c1 e8 0c             	shr    $0xc,%eax
f0103914:	c7 c2 08 40 18 f0    	mov    $0xf0184008,%edx
f010391a:	3b 02                	cmp    (%edx),%eax
f010391c:	73 54                	jae    f0103972 <env_free+0x1ef>
	page_decref(pa2page(pa));
f010391e:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103921:	c7 c2 10 40 18 f0    	mov    $0xf0184010,%edx
f0103927:	8b 12                	mov    (%edx),%edx
f0103929:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010392c:	50                   	push   %eax
f010392d:	e8 e5 d7 ff ff       	call   f0101117 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103932:	8b 45 08             	mov    0x8(%ebp),%eax
f0103935:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f010393c:	8b 83 30 23 00 00    	mov    0x2330(%ebx),%eax
f0103942:	8b 55 08             	mov    0x8(%ebp),%edx
f0103945:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103948:	89 93 30 23 00 00    	mov    %edx,0x2330(%ebx)
}
f010394e:	83 c4 10             	add    $0x10,%esp
f0103951:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103954:	5b                   	pop    %ebx
f0103955:	5e                   	pop    %esi
f0103956:	5f                   	pop    %edi
f0103957:	5d                   	pop    %ebp
f0103958:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103959:	50                   	push   %eax
f010395a:	8d 83 34 4c f8 ff    	lea    -0x7b3cc(%ebx),%eax
f0103960:	50                   	push   %eax
f0103961:	68 bf 01 00 00       	push   $0x1bf
f0103966:	8d 83 ac 55 f8 ff    	lea    -0x7aa54(%ebx),%eax
f010396c:	50                   	push   %eax
f010396d:	e8 3f c7 ff ff       	call   f01000b1 <_panic>
		panic("pa2page called with invalid pa");
f0103972:	83 ec 04             	sub    $0x4,%esp
f0103975:	8d 83 d8 4b f8 ff    	lea    -0x7b428(%ebx),%eax
f010397b:	50                   	push   %eax
f010397c:	6a 4f                	push   $0x4f
f010397e:	8d 83 b9 52 f8 ff    	lea    -0x7ad47(%ebx),%eax
f0103984:	50                   	push   %eax
f0103985:	e8 27 c7 ff ff       	call   f01000b1 <_panic>

f010398a <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f010398a:	55                   	push   %ebp
f010398b:	89 e5                	mov    %esp,%ebp
f010398d:	53                   	push   %ebx
f010398e:	83 ec 10             	sub    $0x10,%esp
f0103991:	e8 d1 c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103996:	81 c3 8a d6 07 00    	add    $0x7d68a,%ebx
	env_free(e);
f010399c:	ff 75 08             	pushl  0x8(%ebp)
f010399f:	e8 df fd ff ff       	call   f0103783 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01039a4:	8d 83 14 56 f8 ff    	lea    -0x7a9ec(%ebx),%eax
f01039aa:	89 04 24             	mov    %eax,(%esp)
f01039ad:	e8 46 01 00 00       	call   f0103af8 <cprintf>
f01039b2:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f01039b5:	83 ec 0c             	sub    $0xc,%esp
f01039b8:	6a 00                	push   $0x0
f01039ba:	e8 18 cf ff ff       	call   f01008d7 <monitor>
f01039bf:	83 c4 10             	add    $0x10,%esp
f01039c2:	eb f1                	jmp    f01039b5 <env_destroy+0x2b>

f01039c4 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01039c4:	55                   	push   %ebp
f01039c5:	89 e5                	mov    %esp,%ebp
f01039c7:	53                   	push   %ebx
f01039c8:	83 ec 08             	sub    $0x8,%esp
f01039cb:	e8 97 c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01039d0:	81 c3 50 d6 07 00    	add    $0x7d650,%ebx
	asm volatile(
f01039d6:	8b 65 08             	mov    0x8(%ebp),%esp
f01039d9:	61                   	popa   
f01039da:	07                   	pop    %es
f01039db:	1f                   	pop    %ds
f01039dc:	83 c4 08             	add    $0x8,%esp
f01039df:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01039e0:	8d 83 06 56 f8 ff    	lea    -0x7a9fa(%ebx),%eax
f01039e6:	50                   	push   %eax
f01039e7:	68 e8 01 00 00       	push   $0x1e8
f01039ec:	8d 83 ac 55 f8 ff    	lea    -0x7aa54(%ebx),%eax
f01039f2:	50                   	push   %eax
f01039f3:	e8 b9 c6 ff ff       	call   f01000b1 <_panic>

f01039f8 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01039f8:	55                   	push   %ebp
f01039f9:	89 e5                	mov    %esp,%ebp
f01039fb:	53                   	push   %ebx
f01039fc:	83 ec 04             	sub    $0x4,%esp
f01039ff:	e8 63 c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103a04:	81 c3 1c d6 07 00    	add    $0x7d61c,%ebx
f0103a0a:	8b 45 08             	mov    0x8(%ebp),%eax
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	if (curenv && curenv->env_status == ENV_RUNNING && curenv != e)
f0103a0d:	8b 93 28 23 00 00    	mov    0x2328(%ebx),%edx
f0103a13:	85 d2                	test   %edx,%edx
f0103a15:	74 0a                	je     f0103a21 <env_run+0x29>
f0103a17:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0103a1b:	75 04                	jne    f0103a21 <env_run+0x29>
f0103a1d:	39 c2                	cmp    %eax,%edx
f0103a1f:	75 35                	jne    f0103a56 <env_run+0x5e>
		curenv->env_status = ENV_RUNNABLE;
	
	curenv = e;
f0103a21:	89 83 28 23 00 00    	mov    %eax,0x2328(%ebx)
	curenv->env_status = ENV_RUNNING;
f0103a27:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103a2e:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0103a32:	8b 50 5c             	mov    0x5c(%eax),%edx
	if ((uint32_t)kva < KERNBASE)
f0103a35:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103a3b:	77 22                	ja     f0103a5f <env_run+0x67>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a3d:	52                   	push   %edx
f0103a3e:	8d 83 34 4c f8 ff    	lea    -0x7b3cc(%ebx),%eax
f0103a44:	50                   	push   %eax
f0103a45:	68 0d 02 00 00       	push   $0x20d
f0103a4a:	8d 83 ac 55 f8 ff    	lea    -0x7aa54(%ebx),%eax
f0103a50:	50                   	push   %eax
f0103a51:	e8 5b c6 ff ff       	call   f01000b1 <_panic>
		curenv->env_status = ENV_RUNNABLE;
f0103a56:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
f0103a5d:	eb c2                	jmp    f0103a21 <env_run+0x29>
	return (physaddr_t)kva - KERNBASE;
f0103a5f:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103a65:	0f 22 da             	mov    %edx,%cr3
	env_pop_tf(&curenv->env_tf);
f0103a68:	83 ec 0c             	sub    $0xc,%esp
f0103a6b:	50                   	push   %eax
f0103a6c:	e8 53 ff ff ff       	call   f01039c4 <env_pop_tf>

f0103a71 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103a71:	55                   	push   %ebp
f0103a72:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103a74:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a77:	ba 70 00 00 00       	mov    $0x70,%edx
f0103a7c:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103a7d:	ba 71 00 00 00       	mov    $0x71,%edx
f0103a82:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103a83:	0f b6 c0             	movzbl %al,%eax
}
f0103a86:	5d                   	pop    %ebp
f0103a87:	c3                   	ret    

f0103a88 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103a88:	55                   	push   %ebp
f0103a89:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103a8b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a8e:	ba 70 00 00 00       	mov    $0x70,%edx
f0103a93:	ee                   	out    %al,(%dx)
f0103a94:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a97:	ba 71 00 00 00       	mov    $0x71,%edx
f0103a9c:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103a9d:	5d                   	pop    %ebp
f0103a9e:	c3                   	ret    

f0103a9f <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103a9f:	55                   	push   %ebp
f0103aa0:	89 e5                	mov    %esp,%ebp
f0103aa2:	53                   	push   %ebx
f0103aa3:	83 ec 10             	sub    $0x10,%esp
f0103aa6:	e8 bc c6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103aab:	81 c3 75 d5 07 00    	add    $0x7d575,%ebx
	cputchar(ch);
f0103ab1:	ff 75 08             	pushl  0x8(%ebp)
f0103ab4:	e8 25 cc ff ff       	call   f01006de <cputchar>
	*cnt++;
}
f0103ab9:	83 c4 10             	add    $0x10,%esp
f0103abc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103abf:	c9                   	leave  
f0103ac0:	c3                   	ret    

f0103ac1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103ac1:	55                   	push   %ebp
f0103ac2:	89 e5                	mov    %esp,%ebp
f0103ac4:	53                   	push   %ebx
f0103ac5:	83 ec 14             	sub    $0x14,%esp
f0103ac8:	e8 9a c6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103acd:	81 c3 53 d5 07 00    	add    $0x7d553,%ebx
	int cnt = 0;
f0103ad3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103ada:	ff 75 0c             	pushl  0xc(%ebp)
f0103add:	ff 75 08             	pushl  0x8(%ebp)
f0103ae0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103ae3:	50                   	push   %eax
f0103ae4:	8d 83 7f 2a f8 ff    	lea    -0x7d581(%ebx),%eax
f0103aea:	50                   	push   %eax
f0103aeb:	e8 36 0f 00 00       	call   f0104a26 <vprintfmt>
	return cnt;
}
f0103af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103af3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103af6:	c9                   	leave  
f0103af7:	c3                   	ret    

f0103af8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103af8:	55                   	push   %ebp
f0103af9:	89 e5                	mov    %esp,%ebp
f0103afb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103afe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103b01:	50                   	push   %eax
f0103b02:	ff 75 08             	pushl  0x8(%ebp)
f0103b05:	e8 b7 ff ff ff       	call   f0103ac1 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103b0a:	c9                   	leave  
f0103b0b:	c3                   	ret    

f0103b0c <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103b0c:	55                   	push   %ebp
f0103b0d:	89 e5                	mov    %esp,%ebp
f0103b0f:	57                   	push   %edi
f0103b10:	56                   	push   %esi
f0103b11:	53                   	push   %ebx
f0103b12:	83 ec 04             	sub    $0x4,%esp
f0103b15:	e8 4d c6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103b1a:	81 c3 06 d5 07 00    	add    $0x7d506,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103b20:	c7 83 64 2b 00 00 00 	movl   $0xf0000000,0x2b64(%ebx)
f0103b27:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103b2a:	66 c7 83 68 2b 00 00 	movw   $0x10,0x2b68(%ebx)
f0103b31:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103b33:	66 c7 83 c6 2b 00 00 	movw   $0x68,0x2bc6(%ebx)
f0103b3a:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103b3c:	c7 c0 00 c3 11 f0    	mov    $0xf011c300,%eax
f0103b42:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f0103b48:	8d b3 60 2b 00 00    	lea    0x2b60(%ebx),%esi
f0103b4e:	66 89 70 2a          	mov    %si,0x2a(%eax)
f0103b52:	89 f2                	mov    %esi,%edx
f0103b54:	c1 ea 10             	shr    $0x10,%edx
f0103b57:	88 50 2c             	mov    %dl,0x2c(%eax)
f0103b5a:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f0103b5e:	83 e2 f0             	and    $0xfffffff0,%edx
f0103b61:	83 ca 09             	or     $0x9,%edx
f0103b64:	83 e2 9f             	and    $0xffffff9f,%edx
f0103b67:	83 ca 80             	or     $0xffffff80,%edx
f0103b6a:	88 55 f3             	mov    %dl,-0xd(%ebp)
f0103b6d:	88 50 2d             	mov    %dl,0x2d(%eax)
f0103b70:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f0103b74:	83 e1 c0             	and    $0xffffffc0,%ecx
f0103b77:	83 c9 40             	or     $0x40,%ecx
f0103b7a:	83 e1 7f             	and    $0x7f,%ecx
f0103b7d:	88 48 2e             	mov    %cl,0x2e(%eax)
f0103b80:	c1 ee 18             	shr    $0x18,%esi
f0103b83:	89 f1                	mov    %esi,%ecx
f0103b85:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103b88:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f0103b8c:	83 e2 ef             	and    $0xffffffef,%edx
f0103b8f:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f0103b92:	b8 28 00 00 00       	mov    $0x28,%eax
f0103b97:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103b9a:	8d 83 e8 1f 00 00    	lea    0x1fe8(%ebx),%eax
f0103ba0:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103ba3:	83 c4 04             	add    $0x4,%esp
f0103ba6:	5b                   	pop    %ebx
f0103ba7:	5e                   	pop    %esi
f0103ba8:	5f                   	pop    %edi
f0103ba9:	5d                   	pop    %ebp
f0103baa:	c3                   	ret    

f0103bab <trap_init>:
{
f0103bab:	55                   	push   %ebp
f0103bac:	89 e5                	mov    %esp,%ebp
f0103bae:	e8 56 cb ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f0103bb3:	05 6d d4 07 00       	add    $0x7d46d,%eax
	SETGATE(idt[T_DIVIDE], 1, 0x8, divide_handler, 0);
f0103bb8:	c7 c2 9a 43 10 f0    	mov    $0xf010439a,%edx
f0103bbe:	66 89 90 40 23 00 00 	mov    %dx,0x2340(%eax)
f0103bc5:	66 c7 80 42 23 00 00 	movw   $0x8,0x2342(%eax)
f0103bcc:	08 00 
f0103bce:	c6 80 44 23 00 00 00 	movb   $0x0,0x2344(%eax)
f0103bd5:	c6 80 45 23 00 00 8f 	movb   $0x8f,0x2345(%eax)
f0103bdc:	c1 ea 10             	shr    $0x10,%edx
f0103bdf:	66 89 90 46 23 00 00 	mov    %dx,0x2346(%eax)
	SETGATE(idt[T_DEBUG], 1, 0x8, debug_handler, 0);
f0103be6:	c7 c2 a0 43 10 f0    	mov    $0xf01043a0,%edx
f0103bec:	66 89 90 48 23 00 00 	mov    %dx,0x2348(%eax)
f0103bf3:	66 c7 80 4a 23 00 00 	movw   $0x8,0x234a(%eax)
f0103bfa:	08 00 
f0103bfc:	c6 80 4c 23 00 00 00 	movb   $0x0,0x234c(%eax)
f0103c03:	c6 80 4d 23 00 00 8f 	movb   $0x8f,0x234d(%eax)
f0103c0a:	c1 ea 10             	shr    $0x10,%edx
f0103c0d:	66 89 90 4e 23 00 00 	mov    %dx,0x234e(%eax)
	SETGATE(idt[T_NMI], 1, 0x8, nmi_handler, 0);
f0103c14:	c7 c2 a6 43 10 f0    	mov    $0xf01043a6,%edx
f0103c1a:	66 89 90 50 23 00 00 	mov    %dx,0x2350(%eax)
f0103c21:	66 c7 80 52 23 00 00 	movw   $0x8,0x2352(%eax)
f0103c28:	08 00 
f0103c2a:	c6 80 54 23 00 00 00 	movb   $0x0,0x2354(%eax)
f0103c31:	c6 80 55 23 00 00 8f 	movb   $0x8f,0x2355(%eax)
f0103c38:	c1 ea 10             	shr    $0x10,%edx
f0103c3b:	66 89 90 56 23 00 00 	mov    %dx,0x2356(%eax)
	SETGATE(idt[T_BRKPT], 1, 0x8, brkpt_handler, 3);
f0103c42:	c7 c2 ac 43 10 f0    	mov    $0xf01043ac,%edx
f0103c48:	66 89 90 58 23 00 00 	mov    %dx,0x2358(%eax)
f0103c4f:	66 c7 80 5a 23 00 00 	movw   $0x8,0x235a(%eax)
f0103c56:	08 00 
f0103c58:	c6 80 5c 23 00 00 00 	movb   $0x0,0x235c(%eax)
f0103c5f:	c6 80 5d 23 00 00 ef 	movb   $0xef,0x235d(%eax)
f0103c66:	c1 ea 10             	shr    $0x10,%edx
f0103c69:	66 89 90 5e 23 00 00 	mov    %dx,0x235e(%eax)
	SETGATE(idt[T_OFLOW], 1, 0x8, oflow_handler, 0);
f0103c70:	c7 c2 b2 43 10 f0    	mov    $0xf01043b2,%edx
f0103c76:	66 89 90 60 23 00 00 	mov    %dx,0x2360(%eax)
f0103c7d:	66 c7 80 62 23 00 00 	movw   $0x8,0x2362(%eax)
f0103c84:	08 00 
f0103c86:	c6 80 64 23 00 00 00 	movb   $0x0,0x2364(%eax)
f0103c8d:	c6 80 65 23 00 00 8f 	movb   $0x8f,0x2365(%eax)
f0103c94:	c1 ea 10             	shr    $0x10,%edx
f0103c97:	66 89 90 66 23 00 00 	mov    %dx,0x2366(%eax)
	SETGATE(idt[T_BOUND], 1, 0x8, bound_handler, 0);
f0103c9e:	c7 c2 b8 43 10 f0    	mov    $0xf01043b8,%edx
f0103ca4:	66 89 90 68 23 00 00 	mov    %dx,0x2368(%eax)
f0103cab:	66 c7 80 6a 23 00 00 	movw   $0x8,0x236a(%eax)
f0103cb2:	08 00 
f0103cb4:	c6 80 6c 23 00 00 00 	movb   $0x0,0x236c(%eax)
f0103cbb:	c6 80 6d 23 00 00 8f 	movb   $0x8f,0x236d(%eax)
f0103cc2:	c1 ea 10             	shr    $0x10,%edx
f0103cc5:	66 89 90 6e 23 00 00 	mov    %dx,0x236e(%eax)
	SETGATE(idt[T_ILLOP], 1, 0x8, illop_handler, 0);
f0103ccc:	c7 c2 be 43 10 f0    	mov    $0xf01043be,%edx
f0103cd2:	66 89 90 70 23 00 00 	mov    %dx,0x2370(%eax)
f0103cd9:	66 c7 80 72 23 00 00 	movw   $0x8,0x2372(%eax)
f0103ce0:	08 00 
f0103ce2:	c6 80 74 23 00 00 00 	movb   $0x0,0x2374(%eax)
f0103ce9:	c6 80 75 23 00 00 8f 	movb   $0x8f,0x2375(%eax)
f0103cf0:	c1 ea 10             	shr    $0x10,%edx
f0103cf3:	66 89 90 76 23 00 00 	mov    %dx,0x2376(%eax)
	SETGATE(idt[T_DEVICE], 1, 0x8, device_handler, 0);
f0103cfa:	c7 c2 c4 43 10 f0    	mov    $0xf01043c4,%edx
f0103d00:	66 89 90 78 23 00 00 	mov    %dx,0x2378(%eax)
f0103d07:	66 c7 80 7a 23 00 00 	movw   $0x8,0x237a(%eax)
f0103d0e:	08 00 
f0103d10:	c6 80 7c 23 00 00 00 	movb   $0x0,0x237c(%eax)
f0103d17:	c6 80 7d 23 00 00 8f 	movb   $0x8f,0x237d(%eax)
f0103d1e:	c1 ea 10             	shr    $0x10,%edx
f0103d21:	66 89 90 7e 23 00 00 	mov    %dx,0x237e(%eax)
	SETGATE(idt[T_DBLFLT], 1, 0x8, dblflt_handler, 0);
f0103d28:	c7 c2 ca 43 10 f0    	mov    $0xf01043ca,%edx
f0103d2e:	66 89 90 80 23 00 00 	mov    %dx,0x2380(%eax)
f0103d35:	66 c7 80 82 23 00 00 	movw   $0x8,0x2382(%eax)
f0103d3c:	08 00 
f0103d3e:	c6 80 84 23 00 00 00 	movb   $0x0,0x2384(%eax)
f0103d45:	c6 80 85 23 00 00 8f 	movb   $0x8f,0x2385(%eax)
f0103d4c:	c1 ea 10             	shr    $0x10,%edx
f0103d4f:	66 89 90 86 23 00 00 	mov    %dx,0x2386(%eax)
	SETGATE(idt[T_TSS], 1, 0x8, tss_handler, 0);
f0103d56:	c7 c2 ce 43 10 f0    	mov    $0xf01043ce,%edx
f0103d5c:	66 89 90 90 23 00 00 	mov    %dx,0x2390(%eax)
f0103d63:	66 c7 80 92 23 00 00 	movw   $0x8,0x2392(%eax)
f0103d6a:	08 00 
f0103d6c:	c6 80 94 23 00 00 00 	movb   $0x0,0x2394(%eax)
f0103d73:	c6 80 95 23 00 00 8f 	movb   $0x8f,0x2395(%eax)
f0103d7a:	c1 ea 10             	shr    $0x10,%edx
f0103d7d:	66 89 90 96 23 00 00 	mov    %dx,0x2396(%eax)
	SETGATE(idt[T_SEGNP], 1, 0x8, segnp_handler, 0);
f0103d84:	c7 c2 d2 43 10 f0    	mov    $0xf01043d2,%edx
f0103d8a:	66 89 90 98 23 00 00 	mov    %dx,0x2398(%eax)
f0103d91:	66 c7 80 9a 23 00 00 	movw   $0x8,0x239a(%eax)
f0103d98:	08 00 
f0103d9a:	c6 80 9c 23 00 00 00 	movb   $0x0,0x239c(%eax)
f0103da1:	c6 80 9d 23 00 00 8f 	movb   $0x8f,0x239d(%eax)
f0103da8:	c1 ea 10             	shr    $0x10,%edx
f0103dab:	66 89 90 9e 23 00 00 	mov    %dx,0x239e(%eax)
	SETGATE(idt[T_STACK], 1, 0x8, stack_handler, 0);
f0103db2:	c7 c2 d6 43 10 f0    	mov    $0xf01043d6,%edx
f0103db8:	66 89 90 a0 23 00 00 	mov    %dx,0x23a0(%eax)
f0103dbf:	66 c7 80 a2 23 00 00 	movw   $0x8,0x23a2(%eax)
f0103dc6:	08 00 
f0103dc8:	c6 80 a4 23 00 00 00 	movb   $0x0,0x23a4(%eax)
f0103dcf:	c6 80 a5 23 00 00 8f 	movb   $0x8f,0x23a5(%eax)
f0103dd6:	c1 ea 10             	shr    $0x10,%edx
f0103dd9:	66 89 90 a6 23 00 00 	mov    %dx,0x23a6(%eax)
	SETGATE(idt[T_GPFLT], 1, 0x8, gpflt_handler, 0);
f0103de0:	c7 c2 da 43 10 f0    	mov    $0xf01043da,%edx
f0103de6:	66 89 90 a8 23 00 00 	mov    %dx,0x23a8(%eax)
f0103ded:	66 c7 80 aa 23 00 00 	movw   $0x8,0x23aa(%eax)
f0103df4:	08 00 
f0103df6:	c6 80 ac 23 00 00 00 	movb   $0x0,0x23ac(%eax)
f0103dfd:	c6 80 ad 23 00 00 8f 	movb   $0x8f,0x23ad(%eax)
f0103e04:	c1 ea 10             	shr    $0x10,%edx
f0103e07:	66 89 90 ae 23 00 00 	mov    %dx,0x23ae(%eax)
	SETGATE(idt[T_PGFLT], 1, 0x8, pgflt_handler, 0);
f0103e0e:	c7 c2 de 43 10 f0    	mov    $0xf01043de,%edx
f0103e14:	66 89 90 b0 23 00 00 	mov    %dx,0x23b0(%eax)
f0103e1b:	66 c7 80 b2 23 00 00 	movw   $0x8,0x23b2(%eax)
f0103e22:	08 00 
f0103e24:	c6 80 b4 23 00 00 00 	movb   $0x0,0x23b4(%eax)
f0103e2b:	c6 80 b5 23 00 00 8f 	movb   $0x8f,0x23b5(%eax)
f0103e32:	c1 ea 10             	shr    $0x10,%edx
f0103e35:	66 89 90 b6 23 00 00 	mov    %dx,0x23b6(%eax)
	SETGATE(idt[T_FPERR], 1, 0x8, fperr_handler, 0);
f0103e3c:	c7 c2 e2 43 10 f0    	mov    $0xf01043e2,%edx
f0103e42:	66 89 90 c0 23 00 00 	mov    %dx,0x23c0(%eax)
f0103e49:	66 c7 80 c2 23 00 00 	movw   $0x8,0x23c2(%eax)
f0103e50:	08 00 
f0103e52:	c6 80 c4 23 00 00 00 	movb   $0x0,0x23c4(%eax)
f0103e59:	c6 80 c5 23 00 00 8f 	movb   $0x8f,0x23c5(%eax)
f0103e60:	c1 ea 10             	shr    $0x10,%edx
f0103e63:	66 89 90 c6 23 00 00 	mov    %dx,0x23c6(%eax)
	SETGATE(idt[T_ALIGN], 1, 0x8, align_handler, 0);
f0103e6a:	c7 c2 e8 43 10 f0    	mov    $0xf01043e8,%edx
f0103e70:	66 89 90 c8 23 00 00 	mov    %dx,0x23c8(%eax)
f0103e77:	66 c7 80 ca 23 00 00 	movw   $0x8,0x23ca(%eax)
f0103e7e:	08 00 
f0103e80:	c6 80 cc 23 00 00 00 	movb   $0x0,0x23cc(%eax)
f0103e87:	c6 80 cd 23 00 00 8f 	movb   $0x8f,0x23cd(%eax)
f0103e8e:	c1 ea 10             	shr    $0x10,%edx
f0103e91:	66 89 90 ce 23 00 00 	mov    %dx,0x23ce(%eax)
	SETGATE(idt[T_MCHK], 1, 0x8, mchk_handler, 0);
f0103e98:	c7 c2 ec 43 10 f0    	mov    $0xf01043ec,%edx
f0103e9e:	66 89 90 d0 23 00 00 	mov    %dx,0x23d0(%eax)
f0103ea5:	66 c7 80 d2 23 00 00 	movw   $0x8,0x23d2(%eax)
f0103eac:	08 00 
f0103eae:	c6 80 d4 23 00 00 00 	movb   $0x0,0x23d4(%eax)
f0103eb5:	c6 80 d5 23 00 00 8f 	movb   $0x8f,0x23d5(%eax)
f0103ebc:	c1 ea 10             	shr    $0x10,%edx
f0103ebf:	66 89 90 d6 23 00 00 	mov    %dx,0x23d6(%eax)
	SETGATE(idt[T_SIMDERR], 1, 0x8, simderr_handler, 0);
f0103ec6:	c7 c2 f0 43 10 f0    	mov    $0xf01043f0,%edx
f0103ecc:	66 89 90 d8 23 00 00 	mov    %dx,0x23d8(%eax)
f0103ed3:	66 c7 80 da 23 00 00 	movw   $0x8,0x23da(%eax)
f0103eda:	08 00 
f0103edc:	c6 80 dc 23 00 00 00 	movb   $0x0,0x23dc(%eax)
f0103ee3:	c6 80 dd 23 00 00 8f 	movb   $0x8f,0x23dd(%eax)
f0103eea:	c1 ea 10             	shr    $0x10,%edx
f0103eed:	66 89 90 de 23 00 00 	mov    %dx,0x23de(%eax)
	SETGATE(idt[T_SYSCALL], 1, 0x8, syscall_handler, 3);	
f0103ef4:	c7 c2 f4 43 10 f0    	mov    $0xf01043f4,%edx
f0103efa:	66 89 90 c0 24 00 00 	mov    %dx,0x24c0(%eax)
f0103f01:	66 c7 80 c2 24 00 00 	movw   $0x8,0x24c2(%eax)
f0103f08:	08 00 
f0103f0a:	c6 80 c4 24 00 00 00 	movb   $0x0,0x24c4(%eax)
f0103f11:	c6 80 c5 24 00 00 ef 	movb   $0xef,0x24c5(%eax)
f0103f18:	c1 ea 10             	shr    $0x10,%edx
f0103f1b:	66 89 90 c6 24 00 00 	mov    %dx,0x24c6(%eax)
	trap_init_percpu();
f0103f22:	e8 e5 fb ff ff       	call   f0103b0c <trap_init_percpu>
}
f0103f27:	5d                   	pop    %ebp
f0103f28:	c3                   	ret    

f0103f29 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103f29:	55                   	push   %ebp
f0103f2a:	89 e5                	mov    %esp,%ebp
f0103f2c:	56                   	push   %esi
f0103f2d:	53                   	push   %ebx
f0103f2e:	e8 34 c2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103f33:	81 c3 ed d0 07 00    	add    $0x7d0ed,%ebx
f0103f39:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103f3c:	83 ec 08             	sub    $0x8,%esp
f0103f3f:	ff 36                	pushl  (%esi)
f0103f41:	8d 83 4a 56 f8 ff    	lea    -0x7a9b6(%ebx),%eax
f0103f47:	50                   	push   %eax
f0103f48:	e8 ab fb ff ff       	call   f0103af8 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103f4d:	83 c4 08             	add    $0x8,%esp
f0103f50:	ff 76 04             	pushl  0x4(%esi)
f0103f53:	8d 83 59 56 f8 ff    	lea    -0x7a9a7(%ebx),%eax
f0103f59:	50                   	push   %eax
f0103f5a:	e8 99 fb ff ff       	call   f0103af8 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103f5f:	83 c4 08             	add    $0x8,%esp
f0103f62:	ff 76 08             	pushl  0x8(%esi)
f0103f65:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0103f6b:	50                   	push   %eax
f0103f6c:	e8 87 fb ff ff       	call   f0103af8 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103f71:	83 c4 08             	add    $0x8,%esp
f0103f74:	ff 76 0c             	pushl  0xc(%esi)
f0103f77:	8d 83 77 56 f8 ff    	lea    -0x7a989(%ebx),%eax
f0103f7d:	50                   	push   %eax
f0103f7e:	e8 75 fb ff ff       	call   f0103af8 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103f83:	83 c4 08             	add    $0x8,%esp
f0103f86:	ff 76 10             	pushl  0x10(%esi)
f0103f89:	8d 83 86 56 f8 ff    	lea    -0x7a97a(%ebx),%eax
f0103f8f:	50                   	push   %eax
f0103f90:	e8 63 fb ff ff       	call   f0103af8 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103f95:	83 c4 08             	add    $0x8,%esp
f0103f98:	ff 76 14             	pushl  0x14(%esi)
f0103f9b:	8d 83 95 56 f8 ff    	lea    -0x7a96b(%ebx),%eax
f0103fa1:	50                   	push   %eax
f0103fa2:	e8 51 fb ff ff       	call   f0103af8 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103fa7:	83 c4 08             	add    $0x8,%esp
f0103faa:	ff 76 18             	pushl  0x18(%esi)
f0103fad:	8d 83 a4 56 f8 ff    	lea    -0x7a95c(%ebx),%eax
f0103fb3:	50                   	push   %eax
f0103fb4:	e8 3f fb ff ff       	call   f0103af8 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103fb9:	83 c4 08             	add    $0x8,%esp
f0103fbc:	ff 76 1c             	pushl  0x1c(%esi)
f0103fbf:	8d 83 b3 56 f8 ff    	lea    -0x7a94d(%ebx),%eax
f0103fc5:	50                   	push   %eax
f0103fc6:	e8 2d fb ff ff       	call   f0103af8 <cprintf>
}
f0103fcb:	83 c4 10             	add    $0x10,%esp
f0103fce:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103fd1:	5b                   	pop    %ebx
f0103fd2:	5e                   	pop    %esi
f0103fd3:	5d                   	pop    %ebp
f0103fd4:	c3                   	ret    

f0103fd5 <print_trapframe>:
{
f0103fd5:	55                   	push   %ebp
f0103fd6:	89 e5                	mov    %esp,%ebp
f0103fd8:	57                   	push   %edi
f0103fd9:	56                   	push   %esi
f0103fda:	53                   	push   %ebx
f0103fdb:	83 ec 14             	sub    $0x14,%esp
f0103fde:	e8 84 c1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103fe3:	81 c3 3d d0 07 00    	add    $0x7d03d,%ebx
f0103fe9:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f0103fec:	56                   	push   %esi
f0103fed:	8d 83 e9 57 f8 ff    	lea    -0x7a817(%ebx),%eax
f0103ff3:	50                   	push   %eax
f0103ff4:	e8 ff fa ff ff       	call   f0103af8 <cprintf>
	print_regs(&tf->tf_regs);
f0103ff9:	89 34 24             	mov    %esi,(%esp)
f0103ffc:	e8 28 ff ff ff       	call   f0103f29 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104001:	83 c4 08             	add    $0x8,%esp
f0104004:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f0104008:	50                   	push   %eax
f0104009:	8d 83 04 57 f8 ff    	lea    -0x7a8fc(%ebx),%eax
f010400f:	50                   	push   %eax
f0104010:	e8 e3 fa ff ff       	call   f0103af8 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104015:	83 c4 08             	add    $0x8,%esp
f0104018:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f010401c:	50                   	push   %eax
f010401d:	8d 83 17 57 f8 ff    	lea    -0x7a8e9(%ebx),%eax
f0104023:	50                   	push   %eax
f0104024:	e8 cf fa ff ff       	call   f0103af8 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104029:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < ARRAY_SIZE(excnames))
f010402c:	83 c4 10             	add    $0x10,%esp
f010402f:	83 fa 13             	cmp    $0x13,%edx
f0104032:	0f 86 e9 00 00 00    	jbe    f0104121 <print_trapframe+0x14c>
	return "(unknown trap)";
f0104038:	83 fa 30             	cmp    $0x30,%edx
f010403b:	8d 83 c2 56 f8 ff    	lea    -0x7a93e(%ebx),%eax
f0104041:	8d 8b ce 56 f8 ff    	lea    -0x7a932(%ebx),%ecx
f0104047:	0f 45 c1             	cmovne %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010404a:	83 ec 04             	sub    $0x4,%esp
f010404d:	50                   	push   %eax
f010404e:	52                   	push   %edx
f010404f:	8d 83 2a 57 f8 ff    	lea    -0x7a8d6(%ebx),%eax
f0104055:	50                   	push   %eax
f0104056:	e8 9d fa ff ff       	call   f0103af8 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010405b:	83 c4 10             	add    $0x10,%esp
f010405e:	39 b3 40 2b 00 00    	cmp    %esi,0x2b40(%ebx)
f0104064:	0f 84 c3 00 00 00    	je     f010412d <print_trapframe+0x158>
	cprintf("  err  0x%08x", tf->tf_err);
f010406a:	83 ec 08             	sub    $0x8,%esp
f010406d:	ff 76 2c             	pushl  0x2c(%esi)
f0104070:	8d 83 4b 57 f8 ff    	lea    -0x7a8b5(%ebx),%eax
f0104076:	50                   	push   %eax
f0104077:	e8 7c fa ff ff       	call   f0103af8 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f010407c:	83 c4 10             	add    $0x10,%esp
f010407f:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0104083:	0f 85 c9 00 00 00    	jne    f0104152 <print_trapframe+0x17d>
			tf->tf_err & 1 ? "protection" : "not-present");
f0104089:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f010408c:	89 c2                	mov    %eax,%edx
f010408e:	83 e2 01             	and    $0x1,%edx
f0104091:	8d 8b dd 56 f8 ff    	lea    -0x7a923(%ebx),%ecx
f0104097:	8d 93 e8 56 f8 ff    	lea    -0x7a918(%ebx),%edx
f010409d:	0f 44 ca             	cmove  %edx,%ecx
f01040a0:	89 c2                	mov    %eax,%edx
f01040a2:	83 e2 02             	and    $0x2,%edx
f01040a5:	8d 93 f4 56 f8 ff    	lea    -0x7a90c(%ebx),%edx
f01040ab:	8d bb fa 56 f8 ff    	lea    -0x7a906(%ebx),%edi
f01040b1:	0f 44 d7             	cmove  %edi,%edx
f01040b4:	83 e0 04             	and    $0x4,%eax
f01040b7:	8d 83 ff 56 f8 ff    	lea    -0x7a901(%ebx),%eax
f01040bd:	8d bb 14 58 f8 ff    	lea    -0x7a7ec(%ebx),%edi
f01040c3:	0f 44 c7             	cmove  %edi,%eax
f01040c6:	51                   	push   %ecx
f01040c7:	52                   	push   %edx
f01040c8:	50                   	push   %eax
f01040c9:	8d 83 59 57 f8 ff    	lea    -0x7a8a7(%ebx),%eax
f01040cf:	50                   	push   %eax
f01040d0:	e8 23 fa ff ff       	call   f0103af8 <cprintf>
f01040d5:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01040d8:	83 ec 08             	sub    $0x8,%esp
f01040db:	ff 76 30             	pushl  0x30(%esi)
f01040de:	8d 83 68 57 f8 ff    	lea    -0x7a898(%ebx),%eax
f01040e4:	50                   	push   %eax
f01040e5:	e8 0e fa ff ff       	call   f0103af8 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01040ea:	83 c4 08             	add    $0x8,%esp
f01040ed:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01040f1:	50                   	push   %eax
f01040f2:	8d 83 77 57 f8 ff    	lea    -0x7a889(%ebx),%eax
f01040f8:	50                   	push   %eax
f01040f9:	e8 fa f9 ff ff       	call   f0103af8 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01040fe:	83 c4 08             	add    $0x8,%esp
f0104101:	ff 76 38             	pushl  0x38(%esi)
f0104104:	8d 83 8a 57 f8 ff    	lea    -0x7a876(%ebx),%eax
f010410a:	50                   	push   %eax
f010410b:	e8 e8 f9 ff ff       	call   f0103af8 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104110:	83 c4 10             	add    $0x10,%esp
f0104113:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0104117:	75 50                	jne    f0104169 <print_trapframe+0x194>
}
f0104119:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010411c:	5b                   	pop    %ebx
f010411d:	5e                   	pop    %esi
f010411e:	5f                   	pop    %edi
f010411f:	5d                   	pop    %ebp
f0104120:	c3                   	ret    
		return excnames[trapno];
f0104121:	8b 84 93 60 20 00 00 	mov    0x2060(%ebx,%edx,4),%eax
f0104128:	e9 1d ff ff ff       	jmp    f010404a <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010412d:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0104131:	0f 85 33 ff ff ff    	jne    f010406a <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104137:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010413a:	83 ec 08             	sub    $0x8,%esp
f010413d:	50                   	push   %eax
f010413e:	8d 83 3c 57 f8 ff    	lea    -0x7a8c4(%ebx),%eax
f0104144:	50                   	push   %eax
f0104145:	e8 ae f9 ff ff       	call   f0103af8 <cprintf>
f010414a:	83 c4 10             	add    $0x10,%esp
f010414d:	e9 18 ff ff ff       	jmp    f010406a <print_trapframe+0x95>
		cprintf("\n");
f0104152:	83 ec 0c             	sub    $0xc,%esp
f0104155:	8d 83 89 48 f8 ff    	lea    -0x7b777(%ebx),%eax
f010415b:	50                   	push   %eax
f010415c:	e8 97 f9 ff ff       	call   f0103af8 <cprintf>
f0104161:	83 c4 10             	add    $0x10,%esp
f0104164:	e9 6f ff ff ff       	jmp    f01040d8 <print_trapframe+0x103>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104169:	83 ec 08             	sub    $0x8,%esp
f010416c:	ff 76 3c             	pushl  0x3c(%esi)
f010416f:	8d 83 99 57 f8 ff    	lea    -0x7a867(%ebx),%eax
f0104175:	50                   	push   %eax
f0104176:	e8 7d f9 ff ff       	call   f0103af8 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010417b:	83 c4 08             	add    $0x8,%esp
f010417e:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f0104182:	50                   	push   %eax
f0104183:	8d 83 a8 57 f8 ff    	lea    -0x7a858(%ebx),%eax
f0104189:	50                   	push   %eax
f010418a:	e8 69 f9 ff ff       	call   f0103af8 <cprintf>
f010418f:	83 c4 10             	add    $0x10,%esp
}
f0104192:	eb 85                	jmp    f0104119 <print_trapframe+0x144>

f0104194 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104194:	55                   	push   %ebp
f0104195:	89 e5                	mov    %esp,%ebp
f0104197:	57                   	push   %edi
f0104198:	56                   	push   %esi
f0104199:	53                   	push   %ebx
f010419a:	83 ec 0c             	sub    $0xc,%esp
f010419d:	e8 c5 bf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01041a2:	81 c3 7e ce 07 00    	add    $0x7ce7e,%ebx
f01041a8:	8b 75 08             	mov    0x8(%ebp),%esi
f01041ab:	0f 20 d2             	mov    %cr2,%edx

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.

	if ((tf->tf_cs & 3) != 3) {
f01041ae:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01041b2:	83 e0 03             	and    $0x3,%eax
f01041b5:	66 83 f8 03          	cmp    $0x3,%ax
f01041b9:	75 38                	jne    f01041f3 <page_fault_handler+0x5f>
	
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041bb:	ff 76 30             	pushl  0x30(%esi)
f01041be:	52                   	push   %edx
f01041bf:	c7 c7 48 33 18 f0    	mov    $0xf0183348,%edi
f01041c5:	8b 07                	mov    (%edi),%eax
f01041c7:	ff 70 48             	pushl  0x48(%eax)
f01041ca:	8d 83 80 59 f8 ff    	lea    -0x7a680(%ebx),%eax
f01041d0:	50                   	push   %eax
f01041d1:	e8 22 f9 ff ff       	call   f0103af8 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01041d6:	89 34 24             	mov    %esi,(%esp)
f01041d9:	e8 f7 fd ff ff       	call   f0103fd5 <print_trapframe>
	env_destroy(curenv);
f01041de:	83 c4 04             	add    $0x4,%esp
f01041e1:	ff 37                	pushl  (%edi)
f01041e3:	e8 a2 f7 ff ff       	call   f010398a <env_destroy>
}
f01041e8:	83 c4 10             	add    $0x10,%esp
f01041eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01041ee:	5b                   	pop    %ebx
f01041ef:	5e                   	pop    %esi
f01041f0:	5f                   	pop    %edi
f01041f1:	5d                   	pop    %ebp
f01041f2:	c3                   	ret    
		panic("unhandled page fault in kernel");
f01041f3:	83 ec 04             	sub    $0x4,%esp
f01041f6:	8d 83 60 59 f8 ff    	lea    -0x7a6a0(%ebx),%eax
f01041fc:	50                   	push   %eax
f01041fd:	68 12 01 00 00       	push   $0x112
f0104202:	8d 83 bb 57 f8 ff    	lea    -0x7a845(%ebx),%eax
f0104208:	50                   	push   %eax
f0104209:	e8 a3 be ff ff       	call   f01000b1 <_panic>

f010420e <trap>:
{
f010420e:	55                   	push   %ebp
f010420f:	89 e5                	mov    %esp,%ebp
f0104211:	57                   	push   %edi
f0104212:	56                   	push   %esi
f0104213:	53                   	push   %ebx
f0104214:	83 ec 0c             	sub    $0xc,%esp
f0104217:	e8 4b bf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010421c:	81 c3 04 ce 07 00    	add    $0x7ce04,%ebx
f0104222:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0104225:	fc                   	cld    
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104226:	9c                   	pushf  
f0104227:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0104228:	f6 c4 02             	test   $0x2,%ah
f010422b:	74 1f                	je     f010424c <trap+0x3e>
f010422d:	8d 83 c7 57 f8 ff    	lea    -0x7a839(%ebx),%eax
f0104233:	50                   	push   %eax
f0104234:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010423a:	50                   	push   %eax
f010423b:	68 e7 00 00 00       	push   $0xe7
f0104240:	8d 83 bb 57 f8 ff    	lea    -0x7a845(%ebx),%eax
f0104246:	50                   	push   %eax
f0104247:	e8 65 be ff ff       	call   f01000b1 <_panic>
	cprintf("Incoming TRAP frame at %p\n", tf);
f010424c:	83 ec 08             	sub    $0x8,%esp
f010424f:	56                   	push   %esi
f0104250:	8d 83 e0 57 f8 ff    	lea    -0x7a820(%ebx),%eax
f0104256:	50                   	push   %eax
f0104257:	e8 9c f8 ff ff       	call   f0103af8 <cprintf>
	if ((tf->tf_cs & 3) == 3) {
f010425c:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104260:	83 e0 03             	and    $0x3,%eax
f0104263:	83 c4 10             	add    $0x10,%esp
f0104266:	66 83 f8 03          	cmp    $0x3,%ax
f010426a:	75 21                	jne    f010428d <trap+0x7f>
		assert(curenv);
f010426c:	c7 c0 48 33 18 f0    	mov    $0xf0183348,%eax
f0104272:	8b 00                	mov    (%eax),%eax
f0104274:	85 c0                	test   %eax,%eax
f0104276:	0f 84 94 00 00 00    	je     f0104310 <trap+0x102>
		curenv->env_tf = *tf;
f010427c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104281:	89 c7                	mov    %eax,%edi
f0104283:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104285:	c7 c0 48 33 18 f0    	mov    $0xf0183348,%eax
f010428b:	8b 30                	mov    (%eax),%esi
	last_tf = tf;
f010428d:	89 b3 40 2b 00 00    	mov    %esi,0x2b40(%ebx)
	if (tf->tf_trapno == T_PGFLT) {
f0104293:	8b 46 28             	mov    0x28(%esi),%eax
f0104296:	83 f8 0e             	cmp    $0xe,%eax
f0104299:	0f 84 90 00 00 00    	je     f010432f <trap+0x121>
	} else if (tf->tf_trapno == T_BRKPT) {
f010429f:	83 f8 03             	cmp    $0x3,%eax
f01042a2:	0f 84 98 00 00 00    	je     f0104340 <trap+0x132>
	} else if (tf->tf_trapno == T_SYSCALL) {
f01042a8:	83 f8 30             	cmp    $0x30,%eax
f01042ab:	0f 84 a0 00 00 00    	je     f0104351 <trap+0x143>
	print_trapframe(tf);
f01042b1:	83 ec 0c             	sub    $0xc,%esp
f01042b4:	56                   	push   %esi
f01042b5:	e8 1b fd ff ff       	call   f0103fd5 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01042ba:	83 c4 10             	add    $0x10,%esp
f01042bd:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01042c2:	0f 84 ad 00 00 00    	je     f0104375 <trap+0x167>
		env_destroy(curenv);
f01042c8:	83 ec 0c             	sub    $0xc,%esp
f01042cb:	c7 c0 48 33 18 f0    	mov    $0xf0183348,%eax
f01042d1:	ff 30                	pushl  (%eax)
f01042d3:	e8 b2 f6 ff ff       	call   f010398a <env_destroy>
f01042d8:	83 c4 10             	add    $0x10,%esp
	assert(curenv && curenv->env_status == ENV_RUNNING);
f01042db:	c7 c0 48 33 18 f0    	mov    $0xf0183348,%eax
f01042e1:	8b 00                	mov    (%eax),%eax
f01042e3:	85 c0                	test   %eax,%eax
f01042e5:	74 0a                	je     f01042f1 <trap+0xe3>
f01042e7:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01042eb:	0f 84 9f 00 00 00    	je     f0104390 <trap+0x182>
f01042f1:	8d 83 a4 59 f8 ff    	lea    -0x7a65c(%ebx),%eax
f01042f7:	50                   	push   %eax
f01042f8:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f01042fe:	50                   	push   %eax
f01042ff:	68 ff 00 00 00       	push   $0xff
f0104304:	8d 83 bb 57 f8 ff    	lea    -0x7a845(%ebx),%eax
f010430a:	50                   	push   %eax
f010430b:	e8 a1 bd ff ff       	call   f01000b1 <_panic>
		assert(curenv);
f0104310:	8d 83 fb 57 f8 ff    	lea    -0x7a805(%ebx),%eax
f0104316:	50                   	push   %eax
f0104317:	8d 83 d3 52 f8 ff    	lea    -0x7ad2d(%ebx),%eax
f010431d:	50                   	push   %eax
f010431e:	68 ed 00 00 00       	push   $0xed
f0104323:	8d 83 bb 57 f8 ff    	lea    -0x7a845(%ebx),%eax
f0104329:	50                   	push   %eax
f010432a:	e8 82 bd ff ff       	call   f01000b1 <_panic>
		page_fault_handler(tf);
f010432f:	83 ec 0c             	sub    $0xc,%esp
f0104332:	56                   	push   %esi
f0104333:	e8 5c fe ff ff       	call   f0104194 <page_fault_handler>
f0104338:	83 c4 10             	add    $0x10,%esp
f010433b:	e9 71 ff ff ff       	jmp    f01042b1 <trap+0xa3>
		monitor(tf);
f0104340:	83 ec 0c             	sub    $0xc,%esp
f0104343:	56                   	push   %esi
f0104344:	e8 8e c5 ff ff       	call   f01008d7 <monitor>
f0104349:	83 c4 10             	add    $0x10,%esp
f010434c:	e9 60 ff ff ff       	jmp    f01042b1 <trap+0xa3>
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx,
f0104351:	83 ec 08             	sub    $0x8,%esp
f0104354:	ff 76 04             	pushl  0x4(%esi)
f0104357:	ff 36                	pushl  (%esi)
f0104359:	ff 76 10             	pushl  0x10(%esi)
f010435c:	ff 76 18             	pushl  0x18(%esi)
f010435f:	ff 76 14             	pushl  0x14(%esi)
f0104362:	ff 76 1c             	pushl  0x1c(%esi)
f0104365:	e8 a1 00 00 00       	call   f010440b <syscall>
f010436a:	89 46 1c             	mov    %eax,0x1c(%esi)
f010436d:	83 c4 20             	add    $0x20,%esp
f0104370:	e9 66 ff ff ff       	jmp    f01042db <trap+0xcd>
		panic("unhandled trap in kernel");
f0104375:	83 ec 04             	sub    $0x4,%esp
f0104378:	8d 83 02 58 f8 ff    	lea    -0x7a7fe(%ebx),%eax
f010437e:	50                   	push   %eax
f010437f:	68 d8 00 00 00       	push   $0xd8
f0104384:	8d 83 bb 57 f8 ff    	lea    -0x7a845(%ebx),%eax
f010438a:	50                   	push   %eax
f010438b:	e8 21 bd ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f0104390:	83 ec 0c             	sub    $0xc,%esp
f0104393:	50                   	push   %eax
f0104394:	e8 5f f6 ff ff       	call   f01039f8 <env_run>
f0104399:	90                   	nop

f010439a <divide_handler>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

	TRAPHANDLER_NOEC(divide_handler, T_DIVIDE)
f010439a:	6a 00                	push   $0x0
f010439c:	6a 00                	push   $0x0
f010439e:	eb 5a                	jmp    f01043fa <_alltraps>

f01043a0 <debug_handler>:
	TRAPHANDLER_NOEC(debug_handler, T_DEBUG)
f01043a0:	6a 00                	push   $0x0
f01043a2:	6a 01                	push   $0x1
f01043a4:	eb 54                	jmp    f01043fa <_alltraps>

f01043a6 <nmi_handler>:
	TRAPHANDLER_NOEC(nmi_handler, T_NMI)	
f01043a6:	6a 00                	push   $0x0
f01043a8:	6a 02                	push   $0x2
f01043aa:	eb 4e                	jmp    f01043fa <_alltraps>

f01043ac <brkpt_handler>:
	TRAPHANDLER_NOEC(brkpt_handler, T_BRKPT)
f01043ac:	6a 00                	push   $0x0
f01043ae:	6a 03                	push   $0x3
f01043b0:	eb 48                	jmp    f01043fa <_alltraps>

f01043b2 <oflow_handler>:
	TRAPHANDLER_NOEC(oflow_handler, T_OFLOW)
f01043b2:	6a 00                	push   $0x0
f01043b4:	6a 04                	push   $0x4
f01043b6:	eb 42                	jmp    f01043fa <_alltraps>

f01043b8 <bound_handler>:
	TRAPHANDLER_NOEC(bound_handler, T_BOUND)
f01043b8:	6a 00                	push   $0x0
f01043ba:	6a 05                	push   $0x5
f01043bc:	eb 3c                	jmp    f01043fa <_alltraps>

f01043be <illop_handler>:
	TRAPHANDLER_NOEC(illop_handler, T_ILLOP)
f01043be:	6a 00                	push   $0x0
f01043c0:	6a 06                	push   $0x6
f01043c2:	eb 36                	jmp    f01043fa <_alltraps>

f01043c4 <device_handler>:
	TRAPHANDLER_NOEC(device_handler, T_DEVICE)
f01043c4:	6a 00                	push   $0x0
f01043c6:	6a 07                	push   $0x7
f01043c8:	eb 30                	jmp    f01043fa <_alltraps>

f01043ca <dblflt_handler>:
	TRAPHANDLER(dblflt_handler, T_DBLFLT)
f01043ca:	6a 08                	push   $0x8
f01043cc:	eb 2c                	jmp    f01043fa <_alltraps>

f01043ce <tss_handler>:
	TRAPHANDLER(tss_handler, T_TSS)
f01043ce:	6a 0a                	push   $0xa
f01043d0:	eb 28                	jmp    f01043fa <_alltraps>

f01043d2 <segnp_handler>:
	TRAPHANDLER(segnp_handler, T_SEGNP)
f01043d2:	6a 0b                	push   $0xb
f01043d4:	eb 24                	jmp    f01043fa <_alltraps>

f01043d6 <stack_handler>:
	TRAPHANDLER(stack_handler, T_STACK)
f01043d6:	6a 0c                	push   $0xc
f01043d8:	eb 20                	jmp    f01043fa <_alltraps>

f01043da <gpflt_handler>:
	TRAPHANDLER(gpflt_handler, T_GPFLT)
f01043da:	6a 0d                	push   $0xd
f01043dc:	eb 1c                	jmp    f01043fa <_alltraps>

f01043de <pgflt_handler>:
	TRAPHANDLER(pgflt_handler, T_PGFLT)
f01043de:	6a 0e                	push   $0xe
f01043e0:	eb 18                	jmp    f01043fa <_alltraps>

f01043e2 <fperr_handler>:
	TRAPHANDLER_NOEC(fperr_handler, T_FPERR)
f01043e2:	6a 00                	push   $0x0
f01043e4:	6a 10                	push   $0x10
f01043e6:	eb 12                	jmp    f01043fa <_alltraps>

f01043e8 <align_handler>:
	TRAPHANDLER(align_handler, T_ALIGN)
f01043e8:	6a 11                	push   $0x11
f01043ea:	eb 0e                	jmp    f01043fa <_alltraps>

f01043ec <mchk_handler>:
	TRAPHANDLER(mchk_handler, T_MCHK)
f01043ec:	6a 12                	push   $0x12
f01043ee:	eb 0a                	jmp    f01043fa <_alltraps>

f01043f0 <simderr_handler>:
	TRAPHANDLER(simderr_handler, T_SIMDERR)
f01043f0:	6a 13                	push   $0x13
f01043f2:	eb 06                	jmp    f01043fa <_alltraps>

f01043f4 <syscall_handler>:
	TRAPHANDLER_NOEC(syscall_handler, T_SYSCALL)
f01043f4:	6a 00                	push   $0x0
f01043f6:	6a 30                	push   $0x30
f01043f8:	eb 00                	jmp    f01043fa <_alltraps>

f01043fa <_alltraps>:
	
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	push %ds
f01043fa:	1e                   	push   %ds
	push %es	
f01043fb:	06                   	push   %es
	pushal
f01043fc:	60                   	pusha  
	movw $(GD_KD), %dx
f01043fd:	66 ba 10 00          	mov    $0x10,%dx
	movw %dx, %ds
f0104401:	8e da                	mov    %edx,%ds
	movw %dx, %es	
f0104403:	8e c2                	mov    %edx,%es
	pushl %esp
f0104405:	54                   	push   %esp
	call trap
f0104406:	e8 03 fe ff ff       	call   f010420e <trap>

f010440b <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010440b:	55                   	push   %ebp
f010440c:	89 e5                	mov    %esp,%ebp
f010440e:	53                   	push   %ebx
f010440f:	83 ec 14             	sub    $0x14,%esp
f0104412:	e8 50 bd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104417:	81 c3 09 cc 07 00    	add    $0x7cc09,%ebx
f010441d:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	switch (syscallno) {
f0104420:	83 f8 01             	cmp    $0x1,%eax
f0104423:	74 5e                	je     f0104483 <syscall+0x78>
f0104425:	83 f8 01             	cmp    $0x1,%eax
f0104428:	72 11                	jb     f010443b <syscall+0x30>
f010442a:	83 f8 02             	cmp    $0x2,%eax
f010442d:	74 5b                	je     f010448a <syscall+0x7f>
f010442f:	83 f8 03             	cmp    $0x3,%eax
f0104432:	74 63                	je     f0104497 <syscall+0x8c>
		break;
	case SYS_env_destroy:
		return sys_env_destroy(a1);
		break;
	default:
		return -E_INVAL;
f0104434:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104439:	eb 30                	jmp    f010446b <syscall+0x60>
	if ((curenv->env_tf.tf_cs & 3) == 3) {
f010443b:	c7 c0 48 33 18 f0    	mov    $0xf0183348,%eax
f0104441:	8b 10                	mov    (%eax),%edx
f0104443:	0f b7 42 34          	movzwl 0x34(%edx),%eax
f0104447:	83 e0 03             	and    $0x3,%eax
f010444a:	66 83 f8 03          	cmp    $0x3,%ax
f010444e:	74 20                	je     f0104470 <syscall+0x65>
	cprintf("%.*s", len, s);
f0104450:	83 ec 04             	sub    $0x4,%esp
f0104453:	ff 75 0c             	pushl  0xc(%ebp)
f0104456:	ff 75 10             	pushl  0x10(%ebp)
f0104459:	8d 83 d0 59 f8 ff    	lea    -0x7a630(%ebx),%eax
f010445f:	50                   	push   %eax
f0104460:	e8 93 f6 ff ff       	call   f0103af8 <cprintf>
		return (size_t) a2;
f0104465:	8b 45 10             	mov    0x10(%ebp),%eax
f0104468:	83 c4 10             	add    $0x10,%esp
	}
	return 0;
}
f010446b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010446e:	c9                   	leave  
f010446f:	c3                   	ret    
		user_mem_assert(curenv, s, len, PTE_U | PTE_P);
f0104470:	6a 05                	push   $0x5
f0104472:	ff 75 10             	pushl  0x10(%ebp)
f0104475:	ff 75 0c             	pushl  0xc(%ebp)
f0104478:	52                   	push   %edx
f0104479:	e8 f5 ed ff ff       	call   f0103273 <user_mem_assert>
f010447e:	83 c4 10             	add    $0x10,%esp
f0104481:	eb cd                	jmp    f0104450 <syscall+0x45>
	return cons_getc();
f0104483:	e8 da c0 ff ff       	call   f0100562 <cons_getc>
		return sys_cgetc();
f0104488:	eb e1                	jmp    f010446b <syscall+0x60>
	return curenv->env_id;
f010448a:	c7 c0 48 33 18 f0    	mov    $0xf0183348,%eax
f0104490:	8b 00                	mov    (%eax),%eax
f0104492:	8b 40 48             	mov    0x48(%eax),%eax
		return sys_getenvid();
f0104495:	eb d4                	jmp    f010446b <syscall+0x60>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104497:	83 ec 04             	sub    $0x4,%esp
f010449a:	6a 01                	push   $0x1
f010449c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010449f:	50                   	push   %eax
f01044a0:	ff 75 0c             	pushl  0xc(%ebp)
f01044a3:	e8 b8 ee ff ff       	call   f0103360 <envid2env>
f01044a8:	83 c4 10             	add    $0x10,%esp
f01044ab:	85 c0                	test   %eax,%eax
f01044ad:	78 bc                	js     f010446b <syscall+0x60>
	if (e == curenv)
f01044af:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01044b2:	c7 c0 48 33 18 f0    	mov    $0xf0183348,%eax
f01044b8:	8b 00                	mov    (%eax),%eax
f01044ba:	39 c2                	cmp    %eax,%edx
f01044bc:	74 2d                	je     f01044eb <syscall+0xe0>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01044be:	83 ec 04             	sub    $0x4,%esp
f01044c1:	ff 72 48             	pushl  0x48(%edx)
f01044c4:	ff 70 48             	pushl  0x48(%eax)
f01044c7:	8d 83 f0 59 f8 ff    	lea    -0x7a610(%ebx),%eax
f01044cd:	50                   	push   %eax
f01044ce:	e8 25 f6 ff ff       	call   f0103af8 <cprintf>
f01044d3:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01044d6:	83 ec 0c             	sub    $0xc,%esp
f01044d9:	ff 75 f4             	pushl  -0xc(%ebp)
f01044dc:	e8 a9 f4 ff ff       	call   f010398a <env_destroy>
f01044e1:	83 c4 10             	add    $0x10,%esp
	return 0;
f01044e4:	b8 00 00 00 00       	mov    $0x0,%eax
		return sys_env_destroy(a1);
f01044e9:	eb 80                	jmp    f010446b <syscall+0x60>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01044eb:	83 ec 08             	sub    $0x8,%esp
f01044ee:	ff 70 48             	pushl  0x48(%eax)
f01044f1:	8d 83 d5 59 f8 ff    	lea    -0x7a62b(%ebx),%eax
f01044f7:	50                   	push   %eax
f01044f8:	e8 fb f5 ff ff       	call   f0103af8 <cprintf>
f01044fd:	83 c4 10             	add    $0x10,%esp
f0104500:	eb d4                	jmp    f01044d6 <syscall+0xcb>

f0104502 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104502:	55                   	push   %ebp
f0104503:	89 e5                	mov    %esp,%ebp
f0104505:	57                   	push   %edi
f0104506:	56                   	push   %esi
f0104507:	53                   	push   %ebx
f0104508:	83 ec 14             	sub    $0x14,%esp
f010450b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010450e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104511:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104514:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104517:	8b 32                	mov    (%edx),%esi
f0104519:	8b 01                	mov    (%ecx),%eax
f010451b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010451e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104525:	eb 2f                	jmp    f0104556 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104527:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f010452a:	39 c6                	cmp    %eax,%esi
f010452c:	7f 49                	jg     f0104577 <stab_binsearch+0x75>
f010452e:	0f b6 0a             	movzbl (%edx),%ecx
f0104531:	83 ea 0c             	sub    $0xc,%edx
f0104534:	39 f9                	cmp    %edi,%ecx
f0104536:	75 ef                	jne    f0104527 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104538:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010453b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010453e:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104542:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104545:	73 35                	jae    f010457c <stab_binsearch+0x7a>
			*region_left = m;
f0104547:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010454a:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f010454c:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f010454f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104556:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0104559:	7f 4e                	jg     f01045a9 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f010455b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010455e:	01 f0                	add    %esi,%eax
f0104560:	89 c3                	mov    %eax,%ebx
f0104562:	c1 eb 1f             	shr    $0x1f,%ebx
f0104565:	01 c3                	add    %eax,%ebx
f0104567:	d1 fb                	sar    %ebx
f0104569:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010456c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010456f:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104573:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0104575:	eb b3                	jmp    f010452a <stab_binsearch+0x28>
			l = true_m + 1;
f0104577:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f010457a:	eb da                	jmp    f0104556 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f010457c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010457f:	76 14                	jbe    f0104595 <stab_binsearch+0x93>
			*region_right = m - 1;
f0104581:	83 e8 01             	sub    $0x1,%eax
f0104584:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104587:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010458a:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f010458c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104593:	eb c1                	jmp    f0104556 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104595:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104598:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010459a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010459e:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f01045a0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01045a7:	eb ad                	jmp    f0104556 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f01045a9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01045ad:	74 16                	je     f01045c5 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01045af:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01045b2:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01045b4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01045b7:	8b 0e                	mov    (%esi),%ecx
f01045b9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01045bc:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01045bf:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f01045c3:	eb 12                	jmp    f01045d7 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f01045c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01045c8:	8b 00                	mov    (%eax),%eax
f01045ca:	83 e8 01             	sub    $0x1,%eax
f01045cd:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01045d0:	89 07                	mov    %eax,(%edi)
f01045d2:	eb 16                	jmp    f01045ea <stab_binsearch+0xe8>
		     l--)
f01045d4:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01045d7:	39 c1                	cmp    %eax,%ecx
f01045d9:	7d 0a                	jge    f01045e5 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f01045db:	0f b6 1a             	movzbl (%edx),%ebx
f01045de:	83 ea 0c             	sub    $0xc,%edx
f01045e1:	39 fb                	cmp    %edi,%ebx
f01045e3:	75 ef                	jne    f01045d4 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f01045e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01045e8:	89 07                	mov    %eax,(%edi)
	}
}
f01045ea:	83 c4 14             	add    $0x14,%esp
f01045ed:	5b                   	pop    %ebx
f01045ee:	5e                   	pop    %esi
f01045ef:	5f                   	pop    %edi
f01045f0:	5d                   	pop    %ebp
f01045f1:	c3                   	ret    

f01045f2 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01045f2:	55                   	push   %ebp
f01045f3:	89 e5                	mov    %esp,%ebp
f01045f5:	57                   	push   %edi
f01045f6:	56                   	push   %esi
f01045f7:	53                   	push   %ebx
f01045f8:	83 ec 4c             	sub    $0x4c,%esp
f01045fb:	e8 d4 ec ff ff       	call   f01032d4 <__x86.get_pc_thunk.di>
f0104600:	81 c7 20 ca 07 00    	add    $0x7ca20,%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104606:	8d 87 08 5a f8 ff    	lea    -0x7a5f8(%edi),%eax
f010460c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010460f:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0104611:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104618:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f010461b:	89 f0                	mov    %esi,%eax
f010461d:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104624:	8b 75 08             	mov    0x8(%ebp),%esi
f0104627:	89 70 10             	mov    %esi,0x10(%eax)
	info->eip_fn_narg = 0;
f010462a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104631:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104637:	0f 86 54 01 00 00    	jbe    f0104791 <debuginfo_eip+0x19f>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010463d:	c7 c0 f8 21 11 f0    	mov    $0xf01121f8,%eax
f0104643:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104646:	c7 c0 45 f7 10 f0    	mov    $0xf010f745,%eax
f010464c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stab_end = __STAB_END__;
f010464f:	c7 c6 44 f7 10 f0    	mov    $0xf010f744,%esi
		stabs = __STAB_BEGIN__;
f0104655:	c7 c0 24 6c 10 f0    	mov    $0xf0106c24,%eax
f010465b:	89 45 bc             	mov    %eax,-0x44(%ebp)
		if (user_mem_check(curenv, stabstr, 1, PTE_U | PTE_P) < 0)
			return -1;				
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010465e:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104661:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
f0104664:	0f 83 88 02 00 00    	jae    f01048f2 <debuginfo_eip+0x300>
f010466a:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f010466e:	0f 85 85 02 00 00    	jne    f01048f9 <debuginfo_eip+0x307>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104674:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010467b:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f010467e:	29 de                	sub    %ebx,%esi
f0104680:	c1 fe 02             	sar    $0x2,%esi
f0104683:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104689:	83 e8 01             	sub    $0x1,%eax
f010468c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010468f:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104692:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104695:	83 ec 08             	sub    $0x8,%esp
f0104698:	ff 75 08             	pushl  0x8(%ebp)
f010469b:	6a 64                	push   $0x64
f010469d:	89 d8                	mov    %ebx,%eax
f010469f:	e8 5e fe ff ff       	call   f0104502 <stab_binsearch>
	if (lfile == 0)
f01046a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046a7:	83 c4 10             	add    $0x10,%esp
f01046aa:	85 c0                	test   %eax,%eax
f01046ac:	0f 84 4e 02 00 00    	je     f0104900 <debuginfo_eip+0x30e>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01046b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01046b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01046b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01046bb:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01046be:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01046c1:	83 ec 08             	sub    $0x8,%esp
f01046c4:	ff 75 08             	pushl  0x8(%ebp)
f01046c7:	6a 24                	push   $0x24
f01046c9:	89 d8                	mov    %ebx,%eax
f01046cb:	e8 32 fe ff ff       	call   f0104502 <stab_binsearch>

	if (lfun <= rfun) {
f01046d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01046d3:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01046d6:	83 c4 10             	add    $0x10,%esp
f01046d9:	39 d0                	cmp    %edx,%eax
f01046db:	0f 8f 3b 01 00 00    	jg     f010481c <debuginfo_eip+0x22a>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01046e1:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01046e4:	8d 1c 8b             	lea    (%ebx,%ecx,4),%ebx
f01046e7:	8b 0b                	mov    (%ebx),%ecx
f01046e9:	8b 75 b8             	mov    -0x48(%ebp),%esi
f01046ec:	2b 75 b4             	sub    -0x4c(%ebp),%esi
f01046ef:	39 f1                	cmp    %esi,%ecx
f01046f1:	73 09                	jae    f01046fc <debuginfo_eip+0x10a>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01046f3:	03 4d b4             	add    -0x4c(%ebp),%ecx
f01046f6:	8b 75 0c             	mov    0xc(%ebp),%esi
f01046f9:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01046fc:	8b 4b 08             	mov    0x8(%ebx),%ecx
f01046ff:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104702:	89 4e 10             	mov    %ecx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0104705:	29 4d 08             	sub    %ecx,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0104708:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010470b:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010470e:	83 ec 08             	sub    $0x8,%esp
f0104711:	6a 3a                	push   $0x3a
f0104713:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104716:	ff 70 08             	pushl  0x8(%eax)
f0104719:	89 fb                	mov    %edi,%ebx
f010471b:	e8 36 0a 00 00       	call   f0105156 <strfind>
f0104720:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104723:	2b 47 08             	sub    0x8(%edi),%eax
f0104726:	89 47 0c             	mov    %eax,0xc(%edi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104729:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010472c:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010472f:	83 c4 08             	add    $0x8,%esp
f0104732:	ff 75 08             	pushl  0x8(%ebp)
f0104735:	6a 44                	push   $0x44
f0104737:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010473a:	89 f0                	mov    %esi,%eax
f010473c:	e8 c1 fd ff ff       	call   f0104502 <stab_binsearch>
	int lline_tmp = lline;
f0104741:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	if (rline < lline_tmp)
f0104744:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104747:	83 c4 10             	add    $0x10,%esp
f010474a:	39 c3                	cmp    %eax,%ebx
f010474c:	0f 8c b5 01 00 00    	jl     f0104907 <debuginfo_eip+0x315>
f0104752:	89 c1                	mov    %eax,%ecx
f0104754:	8d 3c 40             	lea    (%eax,%eax,2),%edi
f0104757:	c1 e7 02             	shl    $0x2,%edi
f010475a:	8d 14 3e             	lea    (%esi,%edi,1),%edx
		return -1;
	while (lline_tmp <= rline) {
		if (stabs[lline_tmp].n_type == N_SLINE) {
f010475d:	80 7a 04 44          	cmpb   $0x44,0x4(%edx)
f0104761:	0f 84 cf 00 00 00    	je     f0104836 <debuginfo_eip+0x244>
			info->eip_line = stabs[lline_tmp].n_desc;
			break;
		}
		if (rline == lline_tmp) {
f0104767:	39 c3                	cmp    %eax,%ebx
f0104769:	0f 84 9f 01 00 00    	je     f010490e <debuginfo_eip+0x31c>
			return -1;
		}
		lline_tmp++;
f010476f:	83 c0 01             	add    $0x1,%eax
f0104772:	83 c2 0c             	add    $0xc,%edx
	while (lline_tmp <= rline) {
f0104775:	39 c3                	cmp    %eax,%ebx
f0104777:	7d e4                	jge    f010475d <debuginfo_eip+0x16b>
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104779:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010477c:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010477f:	8d 44 38 04          	lea    0x4(%eax,%edi,1),%eax
f0104783:	c6 45 c7 00          	movb   $0x0,-0x39(%ebp)
f0104787:	bf 01 00 00 00       	mov    $0x1,%edi
f010478c:	e9 bf 00 00 00       	jmp    f0104850 <debuginfo_eip+0x25e>
		if (user_mem_check(curenv, usd, 1, PTE_U | PTE_P) < 0)
f0104791:	6a 05                	push   $0x5
f0104793:	6a 01                	push   $0x1
f0104795:	68 00 00 20 00       	push   $0x200000
f010479a:	c7 c0 48 33 18 f0    	mov    $0xf0183348,%eax
f01047a0:	ff 30                	pushl  (%eax)
f01047a2:	89 fb                	mov    %edi,%ebx
f01047a4:	e8 36 ea ff ff       	call   f01031df <user_mem_check>
f01047a9:	83 c4 10             	add    $0x10,%esp
f01047ac:	85 c0                	test   %eax,%eax
f01047ae:	0f 88 30 01 00 00    	js     f01048e4 <debuginfo_eip+0x2f2>
		stabs = usd->stabs;
f01047b4:	a1 00 00 20 00       	mov    0x200000,%eax
f01047b9:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = usd->stab_end;
f01047bc:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f01047c2:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f01047c8:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f01047cb:	8b 1d 0c 00 20 00    	mov    0x20000c,%ebx
f01047d1:	89 5d b8             	mov    %ebx,-0x48(%ebp)
		if (user_mem_check(curenv, stabs, 1, PTE_U | PTE_P) < 0)
f01047d4:	6a 05                	push   $0x5
f01047d6:	6a 01                	push   $0x1
f01047d8:	50                   	push   %eax
f01047d9:	c7 c0 48 33 18 f0    	mov    $0xf0183348,%eax
f01047df:	ff 30                	pushl  (%eax)
f01047e1:	89 fb                	mov    %edi,%ebx
f01047e3:	e8 f7 e9 ff ff       	call   f01031df <user_mem_check>
f01047e8:	83 c4 10             	add    $0x10,%esp
f01047eb:	85 c0                	test   %eax,%eax
f01047ed:	0f 88 f8 00 00 00    	js     f01048eb <debuginfo_eip+0x2f9>
		if (user_mem_check(curenv, stabstr, 1, PTE_U | PTE_P) < 0)
f01047f3:	6a 05                	push   $0x5
f01047f5:	6a 01                	push   $0x1
f01047f7:	ff 75 b4             	pushl  -0x4c(%ebp)
f01047fa:	c7 c0 48 33 18 f0    	mov    $0xf0183348,%eax
f0104800:	ff 30                	pushl  (%eax)
f0104802:	e8 d8 e9 ff ff       	call   f01031df <user_mem_check>
f0104807:	83 c4 10             	add    $0x10,%esp
f010480a:	85 c0                	test   %eax,%eax
f010480c:	0f 89 4c fe ff ff    	jns    f010465e <debuginfo_eip+0x6c>
			return -1;				
f0104812:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104817:	e9 f7 00 00 00       	jmp    f0104913 <debuginfo_eip+0x321>
		info->eip_fn_addr = addr;
f010481c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010481f:	8b 75 08             	mov    0x8(%ebp),%esi
f0104822:	89 70 10             	mov    %esi,0x10(%eax)
		lline = lfile;
f0104825:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104828:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010482b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010482e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104831:	e9 d8 fe ff ff       	jmp    f010470e <debuginfo_eip+0x11c>
			info->eip_line = stabs[lline_tmp].n_desc;
f0104836:	0f b7 42 06          	movzwl 0x6(%edx),%eax
f010483a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010483d:	89 46 04             	mov    %eax,0x4(%esi)
			break;
f0104840:	e9 34 ff ff ff       	jmp    f0104779 <debuginfo_eip+0x187>
f0104845:	83 e9 01             	sub    $0x1,%ecx
f0104848:	83 e8 0c             	sub    $0xc,%eax
f010484b:	89 fb                	mov    %edi,%ebx
f010484d:	88 5d c7             	mov    %bl,-0x39(%ebp)
f0104850:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	while (lline >= lfile
f0104853:	39 ce                	cmp    %ecx,%esi
f0104855:	7f 45                	jg     f010489c <debuginfo_eip+0x2aa>
	       && stabs[lline].n_type != N_SOL
f0104857:	0f b6 10             	movzbl (%eax),%edx
f010485a:	80 fa 84             	cmp    $0x84,%dl
f010485d:	74 19                	je     f0104878 <debuginfo_eip+0x286>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010485f:	80 fa 64             	cmp    $0x64,%dl
f0104862:	75 e1                	jne    f0104845 <debuginfo_eip+0x253>
f0104864:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0104868:	74 db                	je     f0104845 <debuginfo_eip+0x253>
f010486a:	80 7d c7 00          	cmpb   $0x0,-0x39(%ebp)
f010486e:	74 0e                	je     f010487e <debuginfo_eip+0x28c>
f0104870:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104873:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104876:	eb 06                	jmp    f010487e <debuginfo_eip+0x28c>
f0104878:	80 7d c7 00          	cmpb   $0x0,-0x39(%ebp)
f010487c:	75 44                	jne    f01048c2 <debuginfo_eip+0x2d0>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010487e:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0104881:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104884:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104887:	8b 45 b8             	mov    -0x48(%ebp),%eax
f010488a:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f010488d:	29 f8                	sub    %edi,%eax
f010488f:	39 c2                	cmp    %eax,%edx
f0104891:	73 09                	jae    f010489c <debuginfo_eip+0x2aa>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104893:	89 f8                	mov    %edi,%eax
f0104895:	01 d0                	add    %edx,%eax
f0104897:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010489a:	89 07                	mov    %eax,(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010489c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010489f:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01048a2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f01048a7:	39 da                	cmp    %ebx,%edx
f01048a9:	7d 68                	jge    f0104913 <debuginfo_eip+0x321>
		for (lline = lfun + 1;
f01048ab:	83 c2 01             	add    $0x1,%edx
f01048ae:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01048b1:	89 d0                	mov    %edx,%eax
f01048b3:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01048b6:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01048b9:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01048bd:	8b 75 0c             	mov    0xc(%ebp),%esi
f01048c0:	eb 09                	jmp    f01048cb <debuginfo_eip+0x2d9>
f01048c2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01048c5:	eb b7                	jmp    f010487e <debuginfo_eip+0x28c>
			info->eip_fn_narg++;
f01048c7:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f01048cb:	39 c3                	cmp    %eax,%ebx
f01048cd:	7e 4c                	jle    f010491b <debuginfo_eip+0x329>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01048cf:	0f b6 0a             	movzbl (%edx),%ecx
f01048d2:	83 c0 01             	add    $0x1,%eax
f01048d5:	83 c2 0c             	add    $0xc,%edx
f01048d8:	80 f9 a0             	cmp    $0xa0,%cl
f01048db:	74 ea                	je     f01048c7 <debuginfo_eip+0x2d5>
	return 0;
f01048dd:	b8 00 00 00 00       	mov    $0x0,%eax
f01048e2:	eb 2f                	jmp    f0104913 <debuginfo_eip+0x321>
			return -1;
f01048e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01048e9:	eb 28                	jmp    f0104913 <debuginfo_eip+0x321>
			return -1;
f01048eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01048f0:	eb 21                	jmp    f0104913 <debuginfo_eip+0x321>
		return -1;
f01048f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01048f7:	eb 1a                	jmp    f0104913 <debuginfo_eip+0x321>
f01048f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01048fe:	eb 13                	jmp    f0104913 <debuginfo_eip+0x321>
		return -1;
f0104900:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104905:	eb 0c                	jmp    f0104913 <debuginfo_eip+0x321>
		return -1;
f0104907:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010490c:	eb 05                	jmp    f0104913 <debuginfo_eip+0x321>
			return -1;
f010490e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0104913:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104916:	5b                   	pop    %ebx
f0104917:	5e                   	pop    %esi
f0104918:	5f                   	pop    %edi
f0104919:	5d                   	pop    %ebp
f010491a:	c3                   	ret    
	return 0;
f010491b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104920:	eb f1                	jmp    f0104913 <debuginfo_eip+0x321>

f0104922 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104922:	55                   	push   %ebp
f0104923:	89 e5                	mov    %esp,%ebp
f0104925:	57                   	push   %edi
f0104926:	56                   	push   %esi
f0104927:	53                   	push   %ebx
f0104928:	83 ec 2c             	sub    $0x2c,%esp
f010492b:	e8 9c e9 ff ff       	call   f01032cc <__x86.get_pc_thunk.cx>
f0104930:	81 c1 f0 c6 07 00    	add    $0x7c6f0,%ecx
f0104936:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0104939:	89 c7                	mov    %eax,%edi
f010493b:	89 d6                	mov    %edx,%esi
f010493d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104940:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104943:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104946:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104949:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010494c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104951:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0104954:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0104957:	39 d3                	cmp    %edx,%ebx
f0104959:	72 09                	jb     f0104964 <printnum+0x42>
f010495b:	39 45 10             	cmp    %eax,0x10(%ebp)
f010495e:	0f 87 83 00 00 00    	ja     f01049e7 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104964:	83 ec 0c             	sub    $0xc,%esp
f0104967:	ff 75 18             	pushl  0x18(%ebp)
f010496a:	8b 45 14             	mov    0x14(%ebp),%eax
f010496d:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104970:	53                   	push   %ebx
f0104971:	ff 75 10             	pushl  0x10(%ebp)
f0104974:	83 ec 08             	sub    $0x8,%esp
f0104977:	ff 75 dc             	pushl  -0x24(%ebp)
f010497a:	ff 75 d8             	pushl  -0x28(%ebp)
f010497d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104980:	ff 75 d0             	pushl  -0x30(%ebp)
f0104983:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104986:	e8 e5 09 00 00       	call   f0105370 <__udivdi3>
f010498b:	83 c4 18             	add    $0x18,%esp
f010498e:	52                   	push   %edx
f010498f:	50                   	push   %eax
f0104990:	89 f2                	mov    %esi,%edx
f0104992:	89 f8                	mov    %edi,%eax
f0104994:	e8 89 ff ff ff       	call   f0104922 <printnum>
f0104999:	83 c4 20             	add    $0x20,%esp
f010499c:	eb 13                	jmp    f01049b1 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010499e:	83 ec 08             	sub    $0x8,%esp
f01049a1:	56                   	push   %esi
f01049a2:	ff 75 18             	pushl  0x18(%ebp)
f01049a5:	ff d7                	call   *%edi
f01049a7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f01049aa:	83 eb 01             	sub    $0x1,%ebx
f01049ad:	85 db                	test   %ebx,%ebx
f01049af:	7f ed                	jg     f010499e <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01049b1:	83 ec 08             	sub    $0x8,%esp
f01049b4:	56                   	push   %esi
f01049b5:	83 ec 04             	sub    $0x4,%esp
f01049b8:	ff 75 dc             	pushl  -0x24(%ebp)
f01049bb:	ff 75 d8             	pushl  -0x28(%ebp)
f01049be:	ff 75 d4             	pushl  -0x2c(%ebp)
f01049c1:	ff 75 d0             	pushl  -0x30(%ebp)
f01049c4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01049c7:	89 f3                	mov    %esi,%ebx
f01049c9:	e8 c2 0a 00 00       	call   f0105490 <__umoddi3>
f01049ce:	83 c4 14             	add    $0x14,%esp
f01049d1:	0f be 84 06 12 5a f8 	movsbl -0x7a5ee(%esi,%eax,1),%eax
f01049d8:	ff 
f01049d9:	50                   	push   %eax
f01049da:	ff d7                	call   *%edi
}
f01049dc:	83 c4 10             	add    $0x10,%esp
f01049df:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01049e2:	5b                   	pop    %ebx
f01049e3:	5e                   	pop    %esi
f01049e4:	5f                   	pop    %edi
f01049e5:	5d                   	pop    %ebp
f01049e6:	c3                   	ret    
f01049e7:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01049ea:	eb be                	jmp    f01049aa <printnum+0x88>

f01049ec <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01049ec:	55                   	push   %ebp
f01049ed:	89 e5                	mov    %esp,%ebp
f01049ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01049f2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01049f6:	8b 10                	mov    (%eax),%edx
f01049f8:	3b 50 04             	cmp    0x4(%eax),%edx
f01049fb:	73 0a                	jae    f0104a07 <sprintputch+0x1b>
		*b->buf++ = ch;
f01049fd:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104a00:	89 08                	mov    %ecx,(%eax)
f0104a02:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a05:	88 02                	mov    %al,(%edx)
}
f0104a07:	5d                   	pop    %ebp
f0104a08:	c3                   	ret    

f0104a09 <printfmt>:
{
f0104a09:	55                   	push   %ebp
f0104a0a:	89 e5                	mov    %esp,%ebp
f0104a0c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104a0f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104a12:	50                   	push   %eax
f0104a13:	ff 75 10             	pushl  0x10(%ebp)
f0104a16:	ff 75 0c             	pushl  0xc(%ebp)
f0104a19:	ff 75 08             	pushl  0x8(%ebp)
f0104a1c:	e8 05 00 00 00       	call   f0104a26 <vprintfmt>
}
f0104a21:	83 c4 10             	add    $0x10,%esp
f0104a24:	c9                   	leave  
f0104a25:	c3                   	ret    

f0104a26 <vprintfmt>:
{
f0104a26:	55                   	push   %ebp
f0104a27:	89 e5                	mov    %esp,%ebp
f0104a29:	57                   	push   %edi
f0104a2a:	56                   	push   %esi
f0104a2b:	53                   	push   %ebx
f0104a2c:	83 ec 2c             	sub    $0x2c,%esp
f0104a2f:	e8 33 b7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104a34:	81 c3 ec c5 07 00    	add    $0x7c5ec,%ebx
f0104a3a:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104a3d:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104a40:	e9 8e 03 00 00       	jmp    f0104dd3 <.L35+0x48>
		padc = ' ';
f0104a45:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0104a49:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0104a50:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0104a57:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0104a5e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104a63:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104a66:	8d 47 01             	lea    0x1(%edi),%eax
f0104a69:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104a6c:	0f b6 17             	movzbl (%edi),%edx
f0104a6f:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104a72:	3c 55                	cmp    $0x55,%al
f0104a74:	0f 87 e1 03 00 00    	ja     f0104e5b <.L22>
f0104a7a:	0f b6 c0             	movzbl %al,%eax
f0104a7d:	89 d9                	mov    %ebx,%ecx
f0104a7f:	03 8c 83 9c 5a f8 ff 	add    -0x7a564(%ebx,%eax,4),%ecx
f0104a86:	ff e1                	jmp    *%ecx

f0104a88 <.L67>:
f0104a88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0104a8b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0104a8f:	eb d5                	jmp    f0104a66 <vprintfmt+0x40>

f0104a91 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f0104a91:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0104a94:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104a98:	eb cc                	jmp    f0104a66 <vprintfmt+0x40>

f0104a9a <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f0104a9a:	0f b6 d2             	movzbl %dl,%edx
f0104a9d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0104aa0:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f0104aa5:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104aa8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104aac:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104aaf:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104ab2:	83 f9 09             	cmp    $0x9,%ecx
f0104ab5:	77 55                	ja     f0104b0c <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f0104ab7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0104aba:	eb e9                	jmp    f0104aa5 <.L29+0xb>

f0104abc <.L26>:
			precision = va_arg(ap, int);
f0104abc:	8b 45 14             	mov    0x14(%ebp),%eax
f0104abf:	8b 00                	mov    (%eax),%eax
f0104ac1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104ac4:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ac7:	8d 40 04             	lea    0x4(%eax),%eax
f0104aca:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104acd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0104ad0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104ad4:	79 90                	jns    f0104a66 <vprintfmt+0x40>
				width = precision, precision = -1;
f0104ad6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104ad9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104adc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104ae3:	eb 81                	jmp    f0104a66 <vprintfmt+0x40>

f0104ae5 <.L27>:
f0104ae5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ae8:	85 c0                	test   %eax,%eax
f0104aea:	ba 00 00 00 00       	mov    $0x0,%edx
f0104aef:	0f 49 d0             	cmovns %eax,%edx
f0104af2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104af5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104af8:	e9 69 ff ff ff       	jmp    f0104a66 <vprintfmt+0x40>

f0104afd <.L23>:
f0104afd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0104b00:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104b07:	e9 5a ff ff ff       	jmp    f0104a66 <vprintfmt+0x40>
f0104b0c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104b0f:	eb bf                	jmp    f0104ad0 <.L26+0x14>

f0104b11 <.L33>:
			lflag++;
f0104b11:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104b15:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0104b18:	e9 49 ff ff ff       	jmp    f0104a66 <vprintfmt+0x40>

f0104b1d <.L30>:
			putch(va_arg(ap, int), putdat);
f0104b1d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b20:	8d 78 04             	lea    0x4(%eax),%edi
f0104b23:	83 ec 08             	sub    $0x8,%esp
f0104b26:	56                   	push   %esi
f0104b27:	ff 30                	pushl  (%eax)
f0104b29:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104b2c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0104b2f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0104b32:	e9 99 02 00 00       	jmp    f0104dd0 <.L35+0x45>

f0104b37 <.L32>:
			err = va_arg(ap, int);
f0104b37:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b3a:	8d 78 04             	lea    0x4(%eax),%edi
f0104b3d:	8b 00                	mov    (%eax),%eax
f0104b3f:	99                   	cltd   
f0104b40:	31 d0                	xor    %edx,%eax
f0104b42:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104b44:	83 f8 06             	cmp    $0x6,%eax
f0104b47:	7f 27                	jg     f0104b70 <.L32+0x39>
f0104b49:	8b 94 83 b0 20 00 00 	mov    0x20b0(%ebx,%eax,4),%edx
f0104b50:	85 d2                	test   %edx,%edx
f0104b52:	74 1c                	je     f0104b70 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f0104b54:	52                   	push   %edx
f0104b55:	8d 83 e5 52 f8 ff    	lea    -0x7ad1b(%ebx),%eax
f0104b5b:	50                   	push   %eax
f0104b5c:	56                   	push   %esi
f0104b5d:	ff 75 08             	pushl  0x8(%ebp)
f0104b60:	e8 a4 fe ff ff       	call   f0104a09 <printfmt>
f0104b65:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104b68:	89 7d 14             	mov    %edi,0x14(%ebp)
f0104b6b:	e9 60 02 00 00       	jmp    f0104dd0 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f0104b70:	50                   	push   %eax
f0104b71:	8d 83 2a 5a f8 ff    	lea    -0x7a5d6(%ebx),%eax
f0104b77:	50                   	push   %eax
f0104b78:	56                   	push   %esi
f0104b79:	ff 75 08             	pushl  0x8(%ebp)
f0104b7c:	e8 88 fe ff ff       	call   f0104a09 <printfmt>
f0104b81:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104b84:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104b87:	e9 44 02 00 00       	jmp    f0104dd0 <.L35+0x45>

f0104b8c <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f0104b8c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b8f:	83 c0 04             	add    $0x4,%eax
f0104b92:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104b95:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b98:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104b9a:	85 ff                	test   %edi,%edi
f0104b9c:	8d 83 23 5a f8 ff    	lea    -0x7a5dd(%ebx),%eax
f0104ba2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104ba5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104ba9:	0f 8e b5 00 00 00    	jle    f0104c64 <.L36+0xd8>
f0104baf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104bb3:	75 08                	jne    f0104bbd <.L36+0x31>
f0104bb5:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104bb8:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104bbb:	eb 6d                	jmp    f0104c2a <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104bbd:	83 ec 08             	sub    $0x8,%esp
f0104bc0:	ff 75 d0             	pushl  -0x30(%ebp)
f0104bc3:	57                   	push   %edi
f0104bc4:	e8 49 04 00 00       	call   f0105012 <strnlen>
f0104bc9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104bcc:	29 c2                	sub    %eax,%edx
f0104bce:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0104bd1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104bd4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104bd8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104bdb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104bde:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104be0:	eb 10                	jmp    f0104bf2 <.L36+0x66>
					putch(padc, putdat);
f0104be2:	83 ec 08             	sub    $0x8,%esp
f0104be5:	56                   	push   %esi
f0104be6:	ff 75 e0             	pushl  -0x20(%ebp)
f0104be9:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104bec:	83 ef 01             	sub    $0x1,%edi
f0104bef:	83 c4 10             	add    $0x10,%esp
f0104bf2:	85 ff                	test   %edi,%edi
f0104bf4:	7f ec                	jg     f0104be2 <.L36+0x56>
f0104bf6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104bf9:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0104bfc:	85 d2                	test   %edx,%edx
f0104bfe:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c03:	0f 49 c2             	cmovns %edx,%eax
f0104c06:	29 c2                	sub    %eax,%edx
f0104c08:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0104c0b:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104c0e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104c11:	eb 17                	jmp    f0104c2a <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f0104c13:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104c17:	75 30                	jne    f0104c49 <.L36+0xbd>
					putch(ch, putdat);
f0104c19:	83 ec 08             	sub    $0x8,%esp
f0104c1c:	ff 75 0c             	pushl  0xc(%ebp)
f0104c1f:	50                   	push   %eax
f0104c20:	ff 55 08             	call   *0x8(%ebp)
f0104c23:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104c26:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f0104c2a:	83 c7 01             	add    $0x1,%edi
f0104c2d:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0104c31:	0f be c2             	movsbl %dl,%eax
f0104c34:	85 c0                	test   %eax,%eax
f0104c36:	74 52                	je     f0104c8a <.L36+0xfe>
f0104c38:	85 f6                	test   %esi,%esi
f0104c3a:	78 d7                	js     f0104c13 <.L36+0x87>
f0104c3c:	83 ee 01             	sub    $0x1,%esi
f0104c3f:	79 d2                	jns    f0104c13 <.L36+0x87>
f0104c41:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104c44:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104c47:	eb 32                	jmp    f0104c7b <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f0104c49:	0f be d2             	movsbl %dl,%edx
f0104c4c:	83 ea 20             	sub    $0x20,%edx
f0104c4f:	83 fa 5e             	cmp    $0x5e,%edx
f0104c52:	76 c5                	jbe    f0104c19 <.L36+0x8d>
					putch('?', putdat);
f0104c54:	83 ec 08             	sub    $0x8,%esp
f0104c57:	ff 75 0c             	pushl  0xc(%ebp)
f0104c5a:	6a 3f                	push   $0x3f
f0104c5c:	ff 55 08             	call   *0x8(%ebp)
f0104c5f:	83 c4 10             	add    $0x10,%esp
f0104c62:	eb c2                	jmp    f0104c26 <.L36+0x9a>
f0104c64:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104c67:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104c6a:	eb be                	jmp    f0104c2a <.L36+0x9e>
				putch(' ', putdat);
f0104c6c:	83 ec 08             	sub    $0x8,%esp
f0104c6f:	56                   	push   %esi
f0104c70:	6a 20                	push   $0x20
f0104c72:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f0104c75:	83 ef 01             	sub    $0x1,%edi
f0104c78:	83 c4 10             	add    $0x10,%esp
f0104c7b:	85 ff                	test   %edi,%edi
f0104c7d:	7f ed                	jg     f0104c6c <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f0104c7f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104c82:	89 45 14             	mov    %eax,0x14(%ebp)
f0104c85:	e9 46 01 00 00       	jmp    f0104dd0 <.L35+0x45>
f0104c8a:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104c8d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104c90:	eb e9                	jmp    f0104c7b <.L36+0xef>

f0104c92 <.L31>:
f0104c92:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
f0104c95:	83 f9 01             	cmp    $0x1,%ecx
f0104c98:	7e 40                	jle    f0104cda <.L31+0x48>
		return va_arg(*ap, long long);
f0104c9a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c9d:	8b 50 04             	mov    0x4(%eax),%edx
f0104ca0:	8b 00                	mov    (%eax),%eax
f0104ca2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ca5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104ca8:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cab:	8d 40 08             	lea    0x8(%eax),%eax
f0104cae:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104cb1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104cb5:	79 55                	jns    f0104d0c <.L31+0x7a>
				putch('-', putdat);
f0104cb7:	83 ec 08             	sub    $0x8,%esp
f0104cba:	56                   	push   %esi
f0104cbb:	6a 2d                	push   $0x2d
f0104cbd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104cc0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104cc3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104cc6:	f7 da                	neg    %edx
f0104cc8:	83 d1 00             	adc    $0x0,%ecx
f0104ccb:	f7 d9                	neg    %ecx
f0104ccd:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104cd0:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104cd5:	e9 db 00 00 00       	jmp    f0104db5 <.L35+0x2a>
	else if (lflag)
f0104cda:	85 c9                	test   %ecx,%ecx
f0104cdc:	75 17                	jne    f0104cf5 <.L31+0x63>
		return va_arg(*ap, int);
f0104cde:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ce1:	8b 00                	mov    (%eax),%eax
f0104ce3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ce6:	99                   	cltd   
f0104ce7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104cea:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ced:	8d 40 04             	lea    0x4(%eax),%eax
f0104cf0:	89 45 14             	mov    %eax,0x14(%ebp)
f0104cf3:	eb bc                	jmp    f0104cb1 <.L31+0x1f>
		return va_arg(*ap, long);
f0104cf5:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cf8:	8b 00                	mov    (%eax),%eax
f0104cfa:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104cfd:	99                   	cltd   
f0104cfe:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104d01:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d04:	8d 40 04             	lea    0x4(%eax),%eax
f0104d07:	89 45 14             	mov    %eax,0x14(%ebp)
f0104d0a:	eb a5                	jmp    f0104cb1 <.L31+0x1f>
			num = getint(&ap, lflag);
f0104d0c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104d0f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0104d12:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104d17:	e9 99 00 00 00       	jmp    f0104db5 <.L35+0x2a>

f0104d1c <.L37>:
f0104d1c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
f0104d1f:	83 f9 01             	cmp    $0x1,%ecx
f0104d22:	7e 15                	jle    f0104d39 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
f0104d24:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d27:	8b 10                	mov    (%eax),%edx
f0104d29:	8b 48 04             	mov    0x4(%eax),%ecx
f0104d2c:	8d 40 08             	lea    0x8(%eax),%eax
f0104d2f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104d32:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104d37:	eb 7c                	jmp    f0104db5 <.L35+0x2a>
	else if (lflag)
f0104d39:	85 c9                	test   %ecx,%ecx
f0104d3b:	75 17                	jne    f0104d54 <.L37+0x38>
		return va_arg(*ap, unsigned int);
f0104d3d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d40:	8b 10                	mov    (%eax),%edx
f0104d42:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d47:	8d 40 04             	lea    0x4(%eax),%eax
f0104d4a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104d4d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104d52:	eb 61                	jmp    f0104db5 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0104d54:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d57:	8b 10                	mov    (%eax),%edx
f0104d59:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d5e:	8d 40 04             	lea    0x4(%eax),%eax
f0104d61:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104d64:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104d69:	eb 4a                	jmp    f0104db5 <.L35+0x2a>

f0104d6b <.L34>:
			putch('X', putdat);
f0104d6b:	83 ec 08             	sub    $0x8,%esp
f0104d6e:	56                   	push   %esi
f0104d6f:	6a 58                	push   $0x58
f0104d71:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f0104d74:	83 c4 08             	add    $0x8,%esp
f0104d77:	56                   	push   %esi
f0104d78:	6a 58                	push   $0x58
f0104d7a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f0104d7d:	83 c4 08             	add    $0x8,%esp
f0104d80:	56                   	push   %esi
f0104d81:	6a 58                	push   $0x58
f0104d83:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104d86:	83 c4 10             	add    $0x10,%esp
f0104d89:	eb 45                	jmp    f0104dd0 <.L35+0x45>

f0104d8b <.L35>:
			putch('0', putdat);
f0104d8b:	83 ec 08             	sub    $0x8,%esp
f0104d8e:	56                   	push   %esi
f0104d8f:	6a 30                	push   $0x30
f0104d91:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104d94:	83 c4 08             	add    $0x8,%esp
f0104d97:	56                   	push   %esi
f0104d98:	6a 78                	push   $0x78
f0104d9a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0104d9d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104da0:	8b 10                	mov    (%eax),%edx
f0104da2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0104da7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104daa:	8d 40 04             	lea    0x4(%eax),%eax
f0104dad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104db0:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0104db5:	83 ec 0c             	sub    $0xc,%esp
f0104db8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0104dbc:	57                   	push   %edi
f0104dbd:	ff 75 e0             	pushl  -0x20(%ebp)
f0104dc0:	50                   	push   %eax
f0104dc1:	51                   	push   %ecx
f0104dc2:	52                   	push   %edx
f0104dc3:	89 f2                	mov    %esi,%edx
f0104dc5:	8b 45 08             	mov    0x8(%ebp),%eax
f0104dc8:	e8 55 fb ff ff       	call   f0104922 <printnum>
			break;
f0104dcd:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0104dd0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104dd3:	83 c7 01             	add    $0x1,%edi
f0104dd6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104dda:	83 f8 25             	cmp    $0x25,%eax
f0104ddd:	0f 84 62 fc ff ff    	je     f0104a45 <vprintfmt+0x1f>
			if (ch == '\0')
f0104de3:	85 c0                	test   %eax,%eax
f0104de5:	0f 84 91 00 00 00    	je     f0104e7c <.L22+0x21>
			putch(ch, putdat);
f0104deb:	83 ec 08             	sub    $0x8,%esp
f0104dee:	56                   	push   %esi
f0104def:	50                   	push   %eax
f0104df0:	ff 55 08             	call   *0x8(%ebp)
f0104df3:	83 c4 10             	add    $0x10,%esp
f0104df6:	eb db                	jmp    f0104dd3 <.L35+0x48>

f0104df8 <.L38>:
f0104df8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
f0104dfb:	83 f9 01             	cmp    $0x1,%ecx
f0104dfe:	7e 15                	jle    f0104e15 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f0104e00:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e03:	8b 10                	mov    (%eax),%edx
f0104e05:	8b 48 04             	mov    0x4(%eax),%ecx
f0104e08:	8d 40 08             	lea    0x8(%eax),%eax
f0104e0b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104e0e:	b8 10 00 00 00       	mov    $0x10,%eax
f0104e13:	eb a0                	jmp    f0104db5 <.L35+0x2a>
	else if (lflag)
f0104e15:	85 c9                	test   %ecx,%ecx
f0104e17:	75 17                	jne    f0104e30 <.L38+0x38>
		return va_arg(*ap, unsigned int);
f0104e19:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e1c:	8b 10                	mov    (%eax),%edx
f0104e1e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104e23:	8d 40 04             	lea    0x4(%eax),%eax
f0104e26:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104e29:	b8 10 00 00 00       	mov    $0x10,%eax
f0104e2e:	eb 85                	jmp    f0104db5 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0104e30:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e33:	8b 10                	mov    (%eax),%edx
f0104e35:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104e3a:	8d 40 04             	lea    0x4(%eax),%eax
f0104e3d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104e40:	b8 10 00 00 00       	mov    $0x10,%eax
f0104e45:	e9 6b ff ff ff       	jmp    f0104db5 <.L35+0x2a>

f0104e4a <.L25>:
			putch(ch, putdat);
f0104e4a:	83 ec 08             	sub    $0x8,%esp
f0104e4d:	56                   	push   %esi
f0104e4e:	6a 25                	push   $0x25
f0104e50:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104e53:	83 c4 10             	add    $0x10,%esp
f0104e56:	e9 75 ff ff ff       	jmp    f0104dd0 <.L35+0x45>

f0104e5b <.L22>:
			putch('%', putdat);
f0104e5b:	83 ec 08             	sub    $0x8,%esp
f0104e5e:	56                   	push   %esi
f0104e5f:	6a 25                	push   $0x25
f0104e61:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104e64:	83 c4 10             	add    $0x10,%esp
f0104e67:	89 f8                	mov    %edi,%eax
f0104e69:	eb 03                	jmp    f0104e6e <.L22+0x13>
f0104e6b:	83 e8 01             	sub    $0x1,%eax
f0104e6e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104e72:	75 f7                	jne    f0104e6b <.L22+0x10>
f0104e74:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104e77:	e9 54 ff ff ff       	jmp    f0104dd0 <.L35+0x45>
}
f0104e7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e7f:	5b                   	pop    %ebx
f0104e80:	5e                   	pop    %esi
f0104e81:	5f                   	pop    %edi
f0104e82:	5d                   	pop    %ebp
f0104e83:	c3                   	ret    

f0104e84 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104e84:	55                   	push   %ebp
f0104e85:	89 e5                	mov    %esp,%ebp
f0104e87:	53                   	push   %ebx
f0104e88:	83 ec 14             	sub    $0x14,%esp
f0104e8b:	e8 d7 b2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104e90:	81 c3 90 c1 07 00    	add    $0x7c190,%ebx
f0104e96:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e99:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104e9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104e9f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104ea3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104ea6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104ead:	85 c0                	test   %eax,%eax
f0104eaf:	74 2b                	je     f0104edc <vsnprintf+0x58>
f0104eb1:	85 d2                	test   %edx,%edx
f0104eb3:	7e 27                	jle    f0104edc <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104eb5:	ff 75 14             	pushl  0x14(%ebp)
f0104eb8:	ff 75 10             	pushl  0x10(%ebp)
f0104ebb:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104ebe:	50                   	push   %eax
f0104ebf:	8d 83 cc 39 f8 ff    	lea    -0x7c634(%ebx),%eax
f0104ec5:	50                   	push   %eax
f0104ec6:	e8 5b fb ff ff       	call   f0104a26 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104ecb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104ece:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ed4:	83 c4 10             	add    $0x10,%esp
}
f0104ed7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104eda:	c9                   	leave  
f0104edb:	c3                   	ret    
		return -E_INVAL;
f0104edc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ee1:	eb f4                	jmp    f0104ed7 <vsnprintf+0x53>

f0104ee3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104ee3:	55                   	push   %ebp
f0104ee4:	89 e5                	mov    %esp,%ebp
f0104ee6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104ee9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104eec:	50                   	push   %eax
f0104eed:	ff 75 10             	pushl  0x10(%ebp)
f0104ef0:	ff 75 0c             	pushl  0xc(%ebp)
f0104ef3:	ff 75 08             	pushl  0x8(%ebp)
f0104ef6:	e8 89 ff ff ff       	call   f0104e84 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104efb:	c9                   	leave  
f0104efc:	c3                   	ret    

f0104efd <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104efd:	55                   	push   %ebp
f0104efe:	89 e5                	mov    %esp,%ebp
f0104f00:	57                   	push   %edi
f0104f01:	56                   	push   %esi
f0104f02:	53                   	push   %ebx
f0104f03:	83 ec 1c             	sub    $0x1c,%esp
f0104f06:	e8 5c b2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104f0b:	81 c3 15 c1 07 00    	add    $0x7c115,%ebx
f0104f11:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104f14:	85 c0                	test   %eax,%eax
f0104f16:	74 13                	je     f0104f2b <readline+0x2e>
		cprintf("%s", prompt);
f0104f18:	83 ec 08             	sub    $0x8,%esp
f0104f1b:	50                   	push   %eax
f0104f1c:	8d 83 e5 52 f8 ff    	lea    -0x7ad1b(%ebx),%eax
f0104f22:	50                   	push   %eax
f0104f23:	e8 d0 eb ff ff       	call   f0103af8 <cprintf>
f0104f28:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104f2b:	83 ec 0c             	sub    $0xc,%esp
f0104f2e:	6a 00                	push   $0x0
f0104f30:	e8 ca b7 ff ff       	call   f01006ff <iscons>
f0104f35:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104f38:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104f3b:	bf 00 00 00 00       	mov    $0x0,%edi
f0104f40:	eb 46                	jmp    f0104f88 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0104f42:	83 ec 08             	sub    $0x8,%esp
f0104f45:	50                   	push   %eax
f0104f46:	8d 83 f4 5b f8 ff    	lea    -0x7a40c(%ebx),%eax
f0104f4c:	50                   	push   %eax
f0104f4d:	e8 a6 eb ff ff       	call   f0103af8 <cprintf>
			return NULL;
f0104f52:	83 c4 10             	add    $0x10,%esp
f0104f55:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104f5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f5d:	5b                   	pop    %ebx
f0104f5e:	5e                   	pop    %esi
f0104f5f:	5f                   	pop    %edi
f0104f60:	5d                   	pop    %ebp
f0104f61:	c3                   	ret    
			if (echoing)
f0104f62:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104f66:	75 05                	jne    f0104f6d <readline+0x70>
			i--;
f0104f68:	83 ef 01             	sub    $0x1,%edi
f0104f6b:	eb 1b                	jmp    f0104f88 <readline+0x8b>
				cputchar('\b');
f0104f6d:	83 ec 0c             	sub    $0xc,%esp
f0104f70:	6a 08                	push   $0x8
f0104f72:	e8 67 b7 ff ff       	call   f01006de <cputchar>
f0104f77:	83 c4 10             	add    $0x10,%esp
f0104f7a:	eb ec                	jmp    f0104f68 <readline+0x6b>
			buf[i++] = c;
f0104f7c:	89 f0                	mov    %esi,%eax
f0104f7e:	88 84 3b e0 2b 00 00 	mov    %al,0x2be0(%ebx,%edi,1)
f0104f85:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0104f88:	e8 61 b7 ff ff       	call   f01006ee <getchar>
f0104f8d:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0104f8f:	85 c0                	test   %eax,%eax
f0104f91:	78 af                	js     f0104f42 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104f93:	83 f8 08             	cmp    $0x8,%eax
f0104f96:	0f 94 c2             	sete   %dl
f0104f99:	83 f8 7f             	cmp    $0x7f,%eax
f0104f9c:	0f 94 c0             	sete   %al
f0104f9f:	08 c2                	or     %al,%dl
f0104fa1:	74 04                	je     f0104fa7 <readline+0xaa>
f0104fa3:	85 ff                	test   %edi,%edi
f0104fa5:	7f bb                	jg     f0104f62 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104fa7:	83 fe 1f             	cmp    $0x1f,%esi
f0104faa:	7e 1c                	jle    f0104fc8 <readline+0xcb>
f0104fac:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0104fb2:	7f 14                	jg     f0104fc8 <readline+0xcb>
			if (echoing)
f0104fb4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104fb8:	74 c2                	je     f0104f7c <readline+0x7f>
				cputchar(c);
f0104fba:	83 ec 0c             	sub    $0xc,%esp
f0104fbd:	56                   	push   %esi
f0104fbe:	e8 1b b7 ff ff       	call   f01006de <cputchar>
f0104fc3:	83 c4 10             	add    $0x10,%esp
f0104fc6:	eb b4                	jmp    f0104f7c <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0104fc8:	83 fe 0a             	cmp    $0xa,%esi
f0104fcb:	74 05                	je     f0104fd2 <readline+0xd5>
f0104fcd:	83 fe 0d             	cmp    $0xd,%esi
f0104fd0:	75 b6                	jne    f0104f88 <readline+0x8b>
			if (echoing)
f0104fd2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104fd6:	75 13                	jne    f0104feb <readline+0xee>
			buf[i] = 0;
f0104fd8:	c6 84 3b e0 2b 00 00 	movb   $0x0,0x2be0(%ebx,%edi,1)
f0104fdf:	00 
			return buf;
f0104fe0:	8d 83 e0 2b 00 00    	lea    0x2be0(%ebx),%eax
f0104fe6:	e9 6f ff ff ff       	jmp    f0104f5a <readline+0x5d>
				cputchar('\n');
f0104feb:	83 ec 0c             	sub    $0xc,%esp
f0104fee:	6a 0a                	push   $0xa
f0104ff0:	e8 e9 b6 ff ff       	call   f01006de <cputchar>
f0104ff5:	83 c4 10             	add    $0x10,%esp
f0104ff8:	eb de                	jmp    f0104fd8 <readline+0xdb>

f0104ffa <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104ffa:	55                   	push   %ebp
f0104ffb:	89 e5                	mov    %esp,%ebp
f0104ffd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105000:	b8 00 00 00 00       	mov    $0x0,%eax
f0105005:	eb 03                	jmp    f010500a <strlen+0x10>
		n++;
f0105007:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f010500a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010500e:	75 f7                	jne    f0105007 <strlen+0xd>
	return n;
}
f0105010:	5d                   	pop    %ebp
f0105011:	c3                   	ret    

f0105012 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105012:	55                   	push   %ebp
f0105013:	89 e5                	mov    %esp,%ebp
f0105015:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105018:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010501b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105020:	eb 03                	jmp    f0105025 <strnlen+0x13>
		n++;
f0105022:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105025:	39 d0                	cmp    %edx,%eax
f0105027:	74 06                	je     f010502f <strnlen+0x1d>
f0105029:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010502d:	75 f3                	jne    f0105022 <strnlen+0x10>
	return n;
}
f010502f:	5d                   	pop    %ebp
f0105030:	c3                   	ret    

f0105031 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105031:	55                   	push   %ebp
f0105032:	89 e5                	mov    %esp,%ebp
f0105034:	53                   	push   %ebx
f0105035:	8b 45 08             	mov    0x8(%ebp),%eax
f0105038:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010503b:	89 c2                	mov    %eax,%edx
f010503d:	83 c1 01             	add    $0x1,%ecx
f0105040:	83 c2 01             	add    $0x1,%edx
f0105043:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105047:	88 5a ff             	mov    %bl,-0x1(%edx)
f010504a:	84 db                	test   %bl,%bl
f010504c:	75 ef                	jne    f010503d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010504e:	5b                   	pop    %ebx
f010504f:	5d                   	pop    %ebp
f0105050:	c3                   	ret    

f0105051 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105051:	55                   	push   %ebp
f0105052:	89 e5                	mov    %esp,%ebp
f0105054:	53                   	push   %ebx
f0105055:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105058:	53                   	push   %ebx
f0105059:	e8 9c ff ff ff       	call   f0104ffa <strlen>
f010505e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105061:	ff 75 0c             	pushl  0xc(%ebp)
f0105064:	01 d8                	add    %ebx,%eax
f0105066:	50                   	push   %eax
f0105067:	e8 c5 ff ff ff       	call   f0105031 <strcpy>
	return dst;
}
f010506c:	89 d8                	mov    %ebx,%eax
f010506e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105071:	c9                   	leave  
f0105072:	c3                   	ret    

f0105073 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105073:	55                   	push   %ebp
f0105074:	89 e5                	mov    %esp,%ebp
f0105076:	56                   	push   %esi
f0105077:	53                   	push   %ebx
f0105078:	8b 75 08             	mov    0x8(%ebp),%esi
f010507b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010507e:	89 f3                	mov    %esi,%ebx
f0105080:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105083:	89 f2                	mov    %esi,%edx
f0105085:	eb 0f                	jmp    f0105096 <strncpy+0x23>
		*dst++ = *src;
f0105087:	83 c2 01             	add    $0x1,%edx
f010508a:	0f b6 01             	movzbl (%ecx),%eax
f010508d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105090:	80 39 01             	cmpb   $0x1,(%ecx)
f0105093:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0105096:	39 da                	cmp    %ebx,%edx
f0105098:	75 ed                	jne    f0105087 <strncpy+0x14>
	}
	return ret;
}
f010509a:	89 f0                	mov    %esi,%eax
f010509c:	5b                   	pop    %ebx
f010509d:	5e                   	pop    %esi
f010509e:	5d                   	pop    %ebp
f010509f:	c3                   	ret    

f01050a0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01050a0:	55                   	push   %ebp
f01050a1:	89 e5                	mov    %esp,%ebp
f01050a3:	56                   	push   %esi
f01050a4:	53                   	push   %ebx
f01050a5:	8b 75 08             	mov    0x8(%ebp),%esi
f01050a8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01050ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01050ae:	89 f0                	mov    %esi,%eax
f01050b0:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01050b4:	85 c9                	test   %ecx,%ecx
f01050b6:	75 0b                	jne    f01050c3 <strlcpy+0x23>
f01050b8:	eb 17                	jmp    f01050d1 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01050ba:	83 c2 01             	add    $0x1,%edx
f01050bd:	83 c0 01             	add    $0x1,%eax
f01050c0:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f01050c3:	39 d8                	cmp    %ebx,%eax
f01050c5:	74 07                	je     f01050ce <strlcpy+0x2e>
f01050c7:	0f b6 0a             	movzbl (%edx),%ecx
f01050ca:	84 c9                	test   %cl,%cl
f01050cc:	75 ec                	jne    f01050ba <strlcpy+0x1a>
		*dst = '\0';
f01050ce:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01050d1:	29 f0                	sub    %esi,%eax
}
f01050d3:	5b                   	pop    %ebx
f01050d4:	5e                   	pop    %esi
f01050d5:	5d                   	pop    %ebp
f01050d6:	c3                   	ret    

f01050d7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01050d7:	55                   	push   %ebp
f01050d8:	89 e5                	mov    %esp,%ebp
f01050da:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01050dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01050e0:	eb 06                	jmp    f01050e8 <strcmp+0x11>
		p++, q++;
f01050e2:	83 c1 01             	add    $0x1,%ecx
f01050e5:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01050e8:	0f b6 01             	movzbl (%ecx),%eax
f01050eb:	84 c0                	test   %al,%al
f01050ed:	74 04                	je     f01050f3 <strcmp+0x1c>
f01050ef:	3a 02                	cmp    (%edx),%al
f01050f1:	74 ef                	je     f01050e2 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01050f3:	0f b6 c0             	movzbl %al,%eax
f01050f6:	0f b6 12             	movzbl (%edx),%edx
f01050f9:	29 d0                	sub    %edx,%eax
}
f01050fb:	5d                   	pop    %ebp
f01050fc:	c3                   	ret    

f01050fd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01050fd:	55                   	push   %ebp
f01050fe:	89 e5                	mov    %esp,%ebp
f0105100:	53                   	push   %ebx
f0105101:	8b 45 08             	mov    0x8(%ebp),%eax
f0105104:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105107:	89 c3                	mov    %eax,%ebx
f0105109:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010510c:	eb 06                	jmp    f0105114 <strncmp+0x17>
		n--, p++, q++;
f010510e:	83 c0 01             	add    $0x1,%eax
f0105111:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105114:	39 d8                	cmp    %ebx,%eax
f0105116:	74 16                	je     f010512e <strncmp+0x31>
f0105118:	0f b6 08             	movzbl (%eax),%ecx
f010511b:	84 c9                	test   %cl,%cl
f010511d:	74 04                	je     f0105123 <strncmp+0x26>
f010511f:	3a 0a                	cmp    (%edx),%cl
f0105121:	74 eb                	je     f010510e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105123:	0f b6 00             	movzbl (%eax),%eax
f0105126:	0f b6 12             	movzbl (%edx),%edx
f0105129:	29 d0                	sub    %edx,%eax
}
f010512b:	5b                   	pop    %ebx
f010512c:	5d                   	pop    %ebp
f010512d:	c3                   	ret    
		return 0;
f010512e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105133:	eb f6                	jmp    f010512b <strncmp+0x2e>

f0105135 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105135:	55                   	push   %ebp
f0105136:	89 e5                	mov    %esp,%ebp
f0105138:	8b 45 08             	mov    0x8(%ebp),%eax
f010513b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010513f:	0f b6 10             	movzbl (%eax),%edx
f0105142:	84 d2                	test   %dl,%dl
f0105144:	74 09                	je     f010514f <strchr+0x1a>
		if (*s == c)
f0105146:	38 ca                	cmp    %cl,%dl
f0105148:	74 0a                	je     f0105154 <strchr+0x1f>
	for (; *s; s++)
f010514a:	83 c0 01             	add    $0x1,%eax
f010514d:	eb f0                	jmp    f010513f <strchr+0xa>
			return (char *) s;
	return 0;
f010514f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105154:	5d                   	pop    %ebp
f0105155:	c3                   	ret    

f0105156 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105156:	55                   	push   %ebp
f0105157:	89 e5                	mov    %esp,%ebp
f0105159:	8b 45 08             	mov    0x8(%ebp),%eax
f010515c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105160:	eb 03                	jmp    f0105165 <strfind+0xf>
f0105162:	83 c0 01             	add    $0x1,%eax
f0105165:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105168:	38 ca                	cmp    %cl,%dl
f010516a:	74 04                	je     f0105170 <strfind+0x1a>
f010516c:	84 d2                	test   %dl,%dl
f010516e:	75 f2                	jne    f0105162 <strfind+0xc>
			break;
	return (char *) s;
}
f0105170:	5d                   	pop    %ebp
f0105171:	c3                   	ret    

f0105172 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105172:	55                   	push   %ebp
f0105173:	89 e5                	mov    %esp,%ebp
f0105175:	57                   	push   %edi
f0105176:	56                   	push   %esi
f0105177:	53                   	push   %ebx
f0105178:	8b 7d 08             	mov    0x8(%ebp),%edi
f010517b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010517e:	85 c9                	test   %ecx,%ecx
f0105180:	74 13                	je     f0105195 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105182:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105188:	75 05                	jne    f010518f <memset+0x1d>
f010518a:	f6 c1 03             	test   $0x3,%cl
f010518d:	74 0d                	je     f010519c <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010518f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105192:	fc                   	cld    
f0105193:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105195:	89 f8                	mov    %edi,%eax
f0105197:	5b                   	pop    %ebx
f0105198:	5e                   	pop    %esi
f0105199:	5f                   	pop    %edi
f010519a:	5d                   	pop    %ebp
f010519b:	c3                   	ret    
		c &= 0xFF;
f010519c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01051a0:	89 d3                	mov    %edx,%ebx
f01051a2:	c1 e3 08             	shl    $0x8,%ebx
f01051a5:	89 d0                	mov    %edx,%eax
f01051a7:	c1 e0 18             	shl    $0x18,%eax
f01051aa:	89 d6                	mov    %edx,%esi
f01051ac:	c1 e6 10             	shl    $0x10,%esi
f01051af:	09 f0                	or     %esi,%eax
f01051b1:	09 c2                	or     %eax,%edx
f01051b3:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f01051b5:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01051b8:	89 d0                	mov    %edx,%eax
f01051ba:	fc                   	cld    
f01051bb:	f3 ab                	rep stos %eax,%es:(%edi)
f01051bd:	eb d6                	jmp    f0105195 <memset+0x23>

f01051bf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01051bf:	55                   	push   %ebp
f01051c0:	89 e5                	mov    %esp,%ebp
f01051c2:	57                   	push   %edi
f01051c3:	56                   	push   %esi
f01051c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01051c7:	8b 75 0c             	mov    0xc(%ebp),%esi
f01051ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01051cd:	39 c6                	cmp    %eax,%esi
f01051cf:	73 35                	jae    f0105206 <memmove+0x47>
f01051d1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01051d4:	39 c2                	cmp    %eax,%edx
f01051d6:	76 2e                	jbe    f0105206 <memmove+0x47>
		s += n;
		d += n;
f01051d8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01051db:	89 d6                	mov    %edx,%esi
f01051dd:	09 fe                	or     %edi,%esi
f01051df:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01051e5:	74 0c                	je     f01051f3 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01051e7:	83 ef 01             	sub    $0x1,%edi
f01051ea:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01051ed:	fd                   	std    
f01051ee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01051f0:	fc                   	cld    
f01051f1:	eb 21                	jmp    f0105214 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01051f3:	f6 c1 03             	test   $0x3,%cl
f01051f6:	75 ef                	jne    f01051e7 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01051f8:	83 ef 04             	sub    $0x4,%edi
f01051fb:	8d 72 fc             	lea    -0x4(%edx),%esi
f01051fe:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105201:	fd                   	std    
f0105202:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105204:	eb ea                	jmp    f01051f0 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105206:	89 f2                	mov    %esi,%edx
f0105208:	09 c2                	or     %eax,%edx
f010520a:	f6 c2 03             	test   $0x3,%dl
f010520d:	74 09                	je     f0105218 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010520f:	89 c7                	mov    %eax,%edi
f0105211:	fc                   	cld    
f0105212:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105214:	5e                   	pop    %esi
f0105215:	5f                   	pop    %edi
f0105216:	5d                   	pop    %ebp
f0105217:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105218:	f6 c1 03             	test   $0x3,%cl
f010521b:	75 f2                	jne    f010520f <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010521d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105220:	89 c7                	mov    %eax,%edi
f0105222:	fc                   	cld    
f0105223:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105225:	eb ed                	jmp    f0105214 <memmove+0x55>

f0105227 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105227:	55                   	push   %ebp
f0105228:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010522a:	ff 75 10             	pushl  0x10(%ebp)
f010522d:	ff 75 0c             	pushl  0xc(%ebp)
f0105230:	ff 75 08             	pushl  0x8(%ebp)
f0105233:	e8 87 ff ff ff       	call   f01051bf <memmove>
}
f0105238:	c9                   	leave  
f0105239:	c3                   	ret    

f010523a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010523a:	55                   	push   %ebp
f010523b:	89 e5                	mov    %esp,%ebp
f010523d:	56                   	push   %esi
f010523e:	53                   	push   %ebx
f010523f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105242:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105245:	89 c6                	mov    %eax,%esi
f0105247:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010524a:	39 f0                	cmp    %esi,%eax
f010524c:	74 1c                	je     f010526a <memcmp+0x30>
		if (*s1 != *s2)
f010524e:	0f b6 08             	movzbl (%eax),%ecx
f0105251:	0f b6 1a             	movzbl (%edx),%ebx
f0105254:	38 d9                	cmp    %bl,%cl
f0105256:	75 08                	jne    f0105260 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105258:	83 c0 01             	add    $0x1,%eax
f010525b:	83 c2 01             	add    $0x1,%edx
f010525e:	eb ea                	jmp    f010524a <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0105260:	0f b6 c1             	movzbl %cl,%eax
f0105263:	0f b6 db             	movzbl %bl,%ebx
f0105266:	29 d8                	sub    %ebx,%eax
f0105268:	eb 05                	jmp    f010526f <memcmp+0x35>
	}

	return 0;
f010526a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010526f:	5b                   	pop    %ebx
f0105270:	5e                   	pop    %esi
f0105271:	5d                   	pop    %ebp
f0105272:	c3                   	ret    

f0105273 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105273:	55                   	push   %ebp
f0105274:	89 e5                	mov    %esp,%ebp
f0105276:	8b 45 08             	mov    0x8(%ebp),%eax
f0105279:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010527c:	89 c2                	mov    %eax,%edx
f010527e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105281:	39 d0                	cmp    %edx,%eax
f0105283:	73 09                	jae    f010528e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105285:	38 08                	cmp    %cl,(%eax)
f0105287:	74 05                	je     f010528e <memfind+0x1b>
	for (; s < ends; s++)
f0105289:	83 c0 01             	add    $0x1,%eax
f010528c:	eb f3                	jmp    f0105281 <memfind+0xe>
			break;
	return (void *) s;
}
f010528e:	5d                   	pop    %ebp
f010528f:	c3                   	ret    

f0105290 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105290:	55                   	push   %ebp
f0105291:	89 e5                	mov    %esp,%ebp
f0105293:	57                   	push   %edi
f0105294:	56                   	push   %esi
f0105295:	53                   	push   %ebx
f0105296:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105299:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010529c:	eb 03                	jmp    f01052a1 <strtol+0x11>
		s++;
f010529e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01052a1:	0f b6 01             	movzbl (%ecx),%eax
f01052a4:	3c 20                	cmp    $0x20,%al
f01052a6:	74 f6                	je     f010529e <strtol+0xe>
f01052a8:	3c 09                	cmp    $0x9,%al
f01052aa:	74 f2                	je     f010529e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01052ac:	3c 2b                	cmp    $0x2b,%al
f01052ae:	74 2e                	je     f01052de <strtol+0x4e>
	int neg = 0;
f01052b0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01052b5:	3c 2d                	cmp    $0x2d,%al
f01052b7:	74 2f                	je     f01052e8 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01052b9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01052bf:	75 05                	jne    f01052c6 <strtol+0x36>
f01052c1:	80 39 30             	cmpb   $0x30,(%ecx)
f01052c4:	74 2c                	je     f01052f2 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01052c6:	85 db                	test   %ebx,%ebx
f01052c8:	75 0a                	jne    f01052d4 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01052ca:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f01052cf:	80 39 30             	cmpb   $0x30,(%ecx)
f01052d2:	74 28                	je     f01052fc <strtol+0x6c>
		base = 10;
f01052d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01052d9:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01052dc:	eb 50                	jmp    f010532e <strtol+0x9e>
		s++;
f01052de:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01052e1:	bf 00 00 00 00       	mov    $0x0,%edi
f01052e6:	eb d1                	jmp    f01052b9 <strtol+0x29>
		s++, neg = 1;
f01052e8:	83 c1 01             	add    $0x1,%ecx
f01052eb:	bf 01 00 00 00       	mov    $0x1,%edi
f01052f0:	eb c7                	jmp    f01052b9 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01052f2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01052f6:	74 0e                	je     f0105306 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01052f8:	85 db                	test   %ebx,%ebx
f01052fa:	75 d8                	jne    f01052d4 <strtol+0x44>
		s++, base = 8;
f01052fc:	83 c1 01             	add    $0x1,%ecx
f01052ff:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105304:	eb ce                	jmp    f01052d4 <strtol+0x44>
		s += 2, base = 16;
f0105306:	83 c1 02             	add    $0x2,%ecx
f0105309:	bb 10 00 00 00       	mov    $0x10,%ebx
f010530e:	eb c4                	jmp    f01052d4 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0105310:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105313:	89 f3                	mov    %esi,%ebx
f0105315:	80 fb 19             	cmp    $0x19,%bl
f0105318:	77 29                	ja     f0105343 <strtol+0xb3>
			dig = *s - 'a' + 10;
f010531a:	0f be d2             	movsbl %dl,%edx
f010531d:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105320:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105323:	7d 30                	jge    f0105355 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0105325:	83 c1 01             	add    $0x1,%ecx
f0105328:	0f af 45 10          	imul   0x10(%ebp),%eax
f010532c:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010532e:	0f b6 11             	movzbl (%ecx),%edx
f0105331:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105334:	89 f3                	mov    %esi,%ebx
f0105336:	80 fb 09             	cmp    $0x9,%bl
f0105339:	77 d5                	ja     f0105310 <strtol+0x80>
			dig = *s - '0';
f010533b:	0f be d2             	movsbl %dl,%edx
f010533e:	83 ea 30             	sub    $0x30,%edx
f0105341:	eb dd                	jmp    f0105320 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0105343:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105346:	89 f3                	mov    %esi,%ebx
f0105348:	80 fb 19             	cmp    $0x19,%bl
f010534b:	77 08                	ja     f0105355 <strtol+0xc5>
			dig = *s - 'A' + 10;
f010534d:	0f be d2             	movsbl %dl,%edx
f0105350:	83 ea 37             	sub    $0x37,%edx
f0105353:	eb cb                	jmp    f0105320 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105355:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105359:	74 05                	je     f0105360 <strtol+0xd0>
		*endptr = (char *) s;
f010535b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010535e:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105360:	89 c2                	mov    %eax,%edx
f0105362:	f7 da                	neg    %edx
f0105364:	85 ff                	test   %edi,%edi
f0105366:	0f 45 c2             	cmovne %edx,%eax
}
f0105369:	5b                   	pop    %ebx
f010536a:	5e                   	pop    %esi
f010536b:	5f                   	pop    %edi
f010536c:	5d                   	pop    %ebp
f010536d:	c3                   	ret    
f010536e:	66 90                	xchg   %ax,%ax

f0105370 <__udivdi3>:
f0105370:	55                   	push   %ebp
f0105371:	57                   	push   %edi
f0105372:	56                   	push   %esi
f0105373:	53                   	push   %ebx
f0105374:	83 ec 1c             	sub    $0x1c,%esp
f0105377:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010537b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010537f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105383:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0105387:	85 d2                	test   %edx,%edx
f0105389:	75 35                	jne    f01053c0 <__udivdi3+0x50>
f010538b:	39 f3                	cmp    %esi,%ebx
f010538d:	0f 87 bd 00 00 00    	ja     f0105450 <__udivdi3+0xe0>
f0105393:	85 db                	test   %ebx,%ebx
f0105395:	89 d9                	mov    %ebx,%ecx
f0105397:	75 0b                	jne    f01053a4 <__udivdi3+0x34>
f0105399:	b8 01 00 00 00       	mov    $0x1,%eax
f010539e:	31 d2                	xor    %edx,%edx
f01053a0:	f7 f3                	div    %ebx
f01053a2:	89 c1                	mov    %eax,%ecx
f01053a4:	31 d2                	xor    %edx,%edx
f01053a6:	89 f0                	mov    %esi,%eax
f01053a8:	f7 f1                	div    %ecx
f01053aa:	89 c6                	mov    %eax,%esi
f01053ac:	89 e8                	mov    %ebp,%eax
f01053ae:	89 f7                	mov    %esi,%edi
f01053b0:	f7 f1                	div    %ecx
f01053b2:	89 fa                	mov    %edi,%edx
f01053b4:	83 c4 1c             	add    $0x1c,%esp
f01053b7:	5b                   	pop    %ebx
f01053b8:	5e                   	pop    %esi
f01053b9:	5f                   	pop    %edi
f01053ba:	5d                   	pop    %ebp
f01053bb:	c3                   	ret    
f01053bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01053c0:	39 f2                	cmp    %esi,%edx
f01053c2:	77 7c                	ja     f0105440 <__udivdi3+0xd0>
f01053c4:	0f bd fa             	bsr    %edx,%edi
f01053c7:	83 f7 1f             	xor    $0x1f,%edi
f01053ca:	0f 84 98 00 00 00    	je     f0105468 <__udivdi3+0xf8>
f01053d0:	89 f9                	mov    %edi,%ecx
f01053d2:	b8 20 00 00 00       	mov    $0x20,%eax
f01053d7:	29 f8                	sub    %edi,%eax
f01053d9:	d3 e2                	shl    %cl,%edx
f01053db:	89 54 24 08          	mov    %edx,0x8(%esp)
f01053df:	89 c1                	mov    %eax,%ecx
f01053e1:	89 da                	mov    %ebx,%edx
f01053e3:	d3 ea                	shr    %cl,%edx
f01053e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01053e9:	09 d1                	or     %edx,%ecx
f01053eb:	89 f2                	mov    %esi,%edx
f01053ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01053f1:	89 f9                	mov    %edi,%ecx
f01053f3:	d3 e3                	shl    %cl,%ebx
f01053f5:	89 c1                	mov    %eax,%ecx
f01053f7:	d3 ea                	shr    %cl,%edx
f01053f9:	89 f9                	mov    %edi,%ecx
f01053fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01053ff:	d3 e6                	shl    %cl,%esi
f0105401:	89 eb                	mov    %ebp,%ebx
f0105403:	89 c1                	mov    %eax,%ecx
f0105405:	d3 eb                	shr    %cl,%ebx
f0105407:	09 de                	or     %ebx,%esi
f0105409:	89 f0                	mov    %esi,%eax
f010540b:	f7 74 24 08          	divl   0x8(%esp)
f010540f:	89 d6                	mov    %edx,%esi
f0105411:	89 c3                	mov    %eax,%ebx
f0105413:	f7 64 24 0c          	mull   0xc(%esp)
f0105417:	39 d6                	cmp    %edx,%esi
f0105419:	72 0c                	jb     f0105427 <__udivdi3+0xb7>
f010541b:	89 f9                	mov    %edi,%ecx
f010541d:	d3 e5                	shl    %cl,%ebp
f010541f:	39 c5                	cmp    %eax,%ebp
f0105421:	73 5d                	jae    f0105480 <__udivdi3+0x110>
f0105423:	39 d6                	cmp    %edx,%esi
f0105425:	75 59                	jne    f0105480 <__udivdi3+0x110>
f0105427:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010542a:	31 ff                	xor    %edi,%edi
f010542c:	89 fa                	mov    %edi,%edx
f010542e:	83 c4 1c             	add    $0x1c,%esp
f0105431:	5b                   	pop    %ebx
f0105432:	5e                   	pop    %esi
f0105433:	5f                   	pop    %edi
f0105434:	5d                   	pop    %ebp
f0105435:	c3                   	ret    
f0105436:	8d 76 00             	lea    0x0(%esi),%esi
f0105439:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0105440:	31 ff                	xor    %edi,%edi
f0105442:	31 c0                	xor    %eax,%eax
f0105444:	89 fa                	mov    %edi,%edx
f0105446:	83 c4 1c             	add    $0x1c,%esp
f0105449:	5b                   	pop    %ebx
f010544a:	5e                   	pop    %esi
f010544b:	5f                   	pop    %edi
f010544c:	5d                   	pop    %ebp
f010544d:	c3                   	ret    
f010544e:	66 90                	xchg   %ax,%ax
f0105450:	31 ff                	xor    %edi,%edi
f0105452:	89 e8                	mov    %ebp,%eax
f0105454:	89 f2                	mov    %esi,%edx
f0105456:	f7 f3                	div    %ebx
f0105458:	89 fa                	mov    %edi,%edx
f010545a:	83 c4 1c             	add    $0x1c,%esp
f010545d:	5b                   	pop    %ebx
f010545e:	5e                   	pop    %esi
f010545f:	5f                   	pop    %edi
f0105460:	5d                   	pop    %ebp
f0105461:	c3                   	ret    
f0105462:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105468:	39 f2                	cmp    %esi,%edx
f010546a:	72 06                	jb     f0105472 <__udivdi3+0x102>
f010546c:	31 c0                	xor    %eax,%eax
f010546e:	39 eb                	cmp    %ebp,%ebx
f0105470:	77 d2                	ja     f0105444 <__udivdi3+0xd4>
f0105472:	b8 01 00 00 00       	mov    $0x1,%eax
f0105477:	eb cb                	jmp    f0105444 <__udivdi3+0xd4>
f0105479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105480:	89 d8                	mov    %ebx,%eax
f0105482:	31 ff                	xor    %edi,%edi
f0105484:	eb be                	jmp    f0105444 <__udivdi3+0xd4>
f0105486:	66 90                	xchg   %ax,%ax
f0105488:	66 90                	xchg   %ax,%ax
f010548a:	66 90                	xchg   %ax,%ax
f010548c:	66 90                	xchg   %ax,%ax
f010548e:	66 90                	xchg   %ax,%ax

f0105490 <__umoddi3>:
f0105490:	55                   	push   %ebp
f0105491:	57                   	push   %edi
f0105492:	56                   	push   %esi
f0105493:	53                   	push   %ebx
f0105494:	83 ec 1c             	sub    $0x1c,%esp
f0105497:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f010549b:	8b 74 24 30          	mov    0x30(%esp),%esi
f010549f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01054a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01054a7:	85 ed                	test   %ebp,%ebp
f01054a9:	89 f0                	mov    %esi,%eax
f01054ab:	89 da                	mov    %ebx,%edx
f01054ad:	75 19                	jne    f01054c8 <__umoddi3+0x38>
f01054af:	39 df                	cmp    %ebx,%edi
f01054b1:	0f 86 b1 00 00 00    	jbe    f0105568 <__umoddi3+0xd8>
f01054b7:	f7 f7                	div    %edi
f01054b9:	89 d0                	mov    %edx,%eax
f01054bb:	31 d2                	xor    %edx,%edx
f01054bd:	83 c4 1c             	add    $0x1c,%esp
f01054c0:	5b                   	pop    %ebx
f01054c1:	5e                   	pop    %esi
f01054c2:	5f                   	pop    %edi
f01054c3:	5d                   	pop    %ebp
f01054c4:	c3                   	ret    
f01054c5:	8d 76 00             	lea    0x0(%esi),%esi
f01054c8:	39 dd                	cmp    %ebx,%ebp
f01054ca:	77 f1                	ja     f01054bd <__umoddi3+0x2d>
f01054cc:	0f bd cd             	bsr    %ebp,%ecx
f01054cf:	83 f1 1f             	xor    $0x1f,%ecx
f01054d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01054d6:	0f 84 b4 00 00 00    	je     f0105590 <__umoddi3+0x100>
f01054dc:	b8 20 00 00 00       	mov    $0x20,%eax
f01054e1:	89 c2                	mov    %eax,%edx
f01054e3:	8b 44 24 04          	mov    0x4(%esp),%eax
f01054e7:	29 c2                	sub    %eax,%edx
f01054e9:	89 c1                	mov    %eax,%ecx
f01054eb:	89 f8                	mov    %edi,%eax
f01054ed:	d3 e5                	shl    %cl,%ebp
f01054ef:	89 d1                	mov    %edx,%ecx
f01054f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01054f5:	d3 e8                	shr    %cl,%eax
f01054f7:	09 c5                	or     %eax,%ebp
f01054f9:	8b 44 24 04          	mov    0x4(%esp),%eax
f01054fd:	89 c1                	mov    %eax,%ecx
f01054ff:	d3 e7                	shl    %cl,%edi
f0105501:	89 d1                	mov    %edx,%ecx
f0105503:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105507:	89 df                	mov    %ebx,%edi
f0105509:	d3 ef                	shr    %cl,%edi
f010550b:	89 c1                	mov    %eax,%ecx
f010550d:	89 f0                	mov    %esi,%eax
f010550f:	d3 e3                	shl    %cl,%ebx
f0105511:	89 d1                	mov    %edx,%ecx
f0105513:	89 fa                	mov    %edi,%edx
f0105515:	d3 e8                	shr    %cl,%eax
f0105517:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010551c:	09 d8                	or     %ebx,%eax
f010551e:	f7 f5                	div    %ebp
f0105520:	d3 e6                	shl    %cl,%esi
f0105522:	89 d1                	mov    %edx,%ecx
f0105524:	f7 64 24 08          	mull   0x8(%esp)
f0105528:	39 d1                	cmp    %edx,%ecx
f010552a:	89 c3                	mov    %eax,%ebx
f010552c:	89 d7                	mov    %edx,%edi
f010552e:	72 06                	jb     f0105536 <__umoddi3+0xa6>
f0105530:	75 0e                	jne    f0105540 <__umoddi3+0xb0>
f0105532:	39 c6                	cmp    %eax,%esi
f0105534:	73 0a                	jae    f0105540 <__umoddi3+0xb0>
f0105536:	2b 44 24 08          	sub    0x8(%esp),%eax
f010553a:	19 ea                	sbb    %ebp,%edx
f010553c:	89 d7                	mov    %edx,%edi
f010553e:	89 c3                	mov    %eax,%ebx
f0105540:	89 ca                	mov    %ecx,%edx
f0105542:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0105547:	29 de                	sub    %ebx,%esi
f0105549:	19 fa                	sbb    %edi,%edx
f010554b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010554f:	89 d0                	mov    %edx,%eax
f0105551:	d3 e0                	shl    %cl,%eax
f0105553:	89 d9                	mov    %ebx,%ecx
f0105555:	d3 ee                	shr    %cl,%esi
f0105557:	d3 ea                	shr    %cl,%edx
f0105559:	09 f0                	or     %esi,%eax
f010555b:	83 c4 1c             	add    $0x1c,%esp
f010555e:	5b                   	pop    %ebx
f010555f:	5e                   	pop    %esi
f0105560:	5f                   	pop    %edi
f0105561:	5d                   	pop    %ebp
f0105562:	c3                   	ret    
f0105563:	90                   	nop
f0105564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105568:	85 ff                	test   %edi,%edi
f010556a:	89 f9                	mov    %edi,%ecx
f010556c:	75 0b                	jne    f0105579 <__umoddi3+0xe9>
f010556e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105573:	31 d2                	xor    %edx,%edx
f0105575:	f7 f7                	div    %edi
f0105577:	89 c1                	mov    %eax,%ecx
f0105579:	89 d8                	mov    %ebx,%eax
f010557b:	31 d2                	xor    %edx,%edx
f010557d:	f7 f1                	div    %ecx
f010557f:	89 f0                	mov    %esi,%eax
f0105581:	f7 f1                	div    %ecx
f0105583:	e9 31 ff ff ff       	jmp    f01054b9 <__umoddi3+0x29>
f0105588:	90                   	nop
f0105589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105590:	39 dd                	cmp    %ebx,%ebp
f0105592:	72 08                	jb     f010559c <__umoddi3+0x10c>
f0105594:	39 f7                	cmp    %esi,%edi
f0105596:	0f 87 21 ff ff ff    	ja     f01054bd <__umoddi3+0x2d>
f010559c:	89 da                	mov    %ebx,%edx
f010559e:	89 f0                	mov    %esi,%eax
f01055a0:	29 f8                	sub    %edi,%eax
f01055a2:	19 ea                	sbb    %ebp,%edx
f01055a4:	e9 14 ff ff ff       	jmp    f01054bd <__umoddi3+0x2d>
