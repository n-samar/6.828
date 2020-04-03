
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 d7 00 00 00       	call   800108 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
  80003a:	e8 c5 00 00 00       	call   800104 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	int i;

	cprintf("Making sure bss works right...\n");
  800045:	8d 83 ec ee ff ff    	lea    -0x1114(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 42 02 00 00       	call   800293 <cprintf>
  800051:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800054:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  800059:	c7 c2 40 20 80 00    	mov    $0x802040,%edx
  80005f:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  800063:	75 73                	jne    8000d8 <umain+0xa5>
	for (i = 0; i < ARRAYSIZE; i++)
  800065:	83 c0 01             	add    $0x1,%eax
  800068:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006d:	75 f0                	jne    80005f <umain+0x2c>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80006f:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800074:	c7 c2 40 20 80 00    	mov    $0x802040,%edx
  80007a:	89 04 82             	mov    %eax,(%edx,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 f3                	jne    80007a <umain+0x47>
	for (i = 0; i < ARRAYSIZE; i++)
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80008c:	c7 c2 40 20 80 00    	mov    $0x802040,%edx
  800092:	39 04 82             	cmp    %eax,(%edx,%eax,4)
  800095:	75 57                	jne    8000ee <umain+0xbb>
	for (i = 0; i < ARRAYSIZE; i++)
  800097:	83 c0 01             	add    $0x1,%eax
  80009a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80009f:	75 f1                	jne    800092 <umain+0x5f>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000a1:	83 ec 0c             	sub    $0xc,%esp
  8000a4:	8d 83 34 ef ff ff    	lea    -0x10cc(%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	e8 e3 01 00 00       	call   800293 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000b0:	c7 c0 40 20 80 00    	mov    $0x802040,%eax
  8000b6:	c7 80 00 10 40 00 00 	movl   $0x0,0x401000(%eax)
  8000bd:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c0:	83 c4 0c             	add    $0xc,%esp
  8000c3:	8d 83 93 ef ff ff    	lea    -0x106d(%ebx),%eax
  8000c9:	50                   	push   %eax
  8000ca:	6a 1a                	push   $0x1a
  8000cc:	8d 83 84 ef ff ff    	lea    -0x107c(%ebx),%eax
  8000d2:	50                   	push   %eax
  8000d3:	e8 af 00 00 00       	call   800187 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000d8:	50                   	push   %eax
  8000d9:	8d 83 67 ef ff ff    	lea    -0x1099(%ebx),%eax
  8000df:	50                   	push   %eax
  8000e0:	6a 11                	push   $0x11
  8000e2:	8d 83 84 ef ff ff    	lea    -0x107c(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 99 00 00 00       	call   800187 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ee:	50                   	push   %eax
  8000ef:	8d 83 0c ef ff ff    	lea    -0x10f4(%ebx),%eax
  8000f5:	50                   	push   %eax
  8000f6:	6a 16                	push   $0x16
  8000f8:	8d 83 84 ef ff ff    	lea    -0x107c(%ebx),%eax
  8000fe:	50                   	push   %eax
  8000ff:	e8 83 00 00 00       	call   800187 <_panic>

00800104 <__x86.get_pc_thunk.bx>:
  800104:	8b 1c 24             	mov    (%esp),%ebx
  800107:	c3                   	ret    

00800108 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	57                   	push   %edi
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	e8 ee ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800116:	81 c3 ea 1e 00 00    	add    $0x1eea,%ebx
  80011c:	8b 75 08             	mov    0x8(%ebp),%esi
  80011f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

	thisenv = envs+ENVX(sys_getenvid());
  800122:	e8 65 0b 00 00       	call   800c8c <sys_getenvid>
  800127:	25 ff 03 00 00       	and    $0x3ff,%eax
  80012c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80012f:	c1 e0 05             	shl    $0x5,%eax
  800132:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800138:	c7 c2 40 20 c0 00    	mov    $0xc02040,%edx
  80013e:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800140:	85 f6                	test   %esi,%esi
  800142:	7e 08                	jle    80014c <libmain+0x44>
		binaryname = argv[0];
  800144:	8b 07                	mov    (%edi),%eax
  800146:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80014c:	83 ec 08             	sub    $0x8,%esp
  80014f:	57                   	push   %edi
  800150:	56                   	push   %esi
  800151:	e8 dd fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800156:	e8 0b 00 00 00       	call   800166 <exit>
}
  80015b:	83 c4 10             	add    $0x10,%esp
  80015e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	53                   	push   %ebx
  80016a:	83 ec 10             	sub    $0x10,%esp
  80016d:	e8 92 ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800172:	81 c3 8e 1e 00 00    	add    $0x1e8e,%ebx
	sys_env_destroy(0);
  800178:	6a 00                	push   $0x0
  80017a:	e8 b8 0a 00 00       	call   800c37 <sys_env_destroy>
}
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 0c             	sub    $0xc,%esp
  800190:	e8 6f ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800195:	81 c3 6b 1e 00 00    	add    $0x1e6b,%ebx
	va_list ap;

	va_start(ap, fmt);
  80019b:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019e:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  8001a4:	8b 38                	mov    (%eax),%edi
  8001a6:	e8 e1 0a 00 00       	call   800c8c <sys_getenvid>
  8001ab:	83 ec 0c             	sub    $0xc,%esp
  8001ae:	ff 75 0c             	pushl  0xc(%ebp)
  8001b1:	ff 75 08             	pushl  0x8(%ebp)
  8001b4:	57                   	push   %edi
  8001b5:	50                   	push   %eax
  8001b6:	8d 83 b4 ef ff ff    	lea    -0x104c(%ebx),%eax
  8001bc:	50                   	push   %eax
  8001bd:	e8 d1 00 00 00       	call   800293 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c2:	83 c4 18             	add    $0x18,%esp
  8001c5:	56                   	push   %esi
  8001c6:	ff 75 10             	pushl  0x10(%ebp)
  8001c9:	e8 63 00 00 00       	call   800231 <vcprintf>
	cprintf("\n");
  8001ce:	8d 83 82 ef ff ff    	lea    -0x107e(%ebx),%eax
  8001d4:	89 04 24             	mov    %eax,(%esp)
  8001d7:	e8 b7 00 00 00       	call   800293 <cprintf>
  8001dc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001df:	cc                   	int3   
  8001e0:	eb fd                	jmp    8001df <_panic+0x58>

008001e2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	e8 18 ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  8001ec:	81 c3 14 1e 00 00    	add    $0x1e14,%ebx
  8001f2:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001f5:	8b 16                	mov    (%esi),%edx
  8001f7:	8d 42 01             	lea    0x1(%edx),%eax
  8001fa:	89 06                	mov    %eax,(%esi)
  8001fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ff:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800203:	3d ff 00 00 00       	cmp    $0xff,%eax
  800208:	74 0b                	je     800215 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80020a:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80020e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5d                   	pop    %ebp
  800214:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800215:	83 ec 08             	sub    $0x8,%esp
  800218:	68 ff 00 00 00       	push   $0xff
  80021d:	8d 46 08             	lea    0x8(%esi),%eax
  800220:	50                   	push   %eax
  800221:	e8 d4 09 00 00       	call   800bfa <sys_cputs>
		b->idx = 0;
  800226:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb d9                	jmp    80020a <putch+0x28>

00800231 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	53                   	push   %ebx
  800235:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80023b:	e8 c4 fe ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800240:	81 c3 c0 1d 00 00    	add    $0x1dc0,%ebx
	struct printbuf b;

	b.idx = 0;
  800246:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024d:	00 00 00 
	b.cnt = 0;
  800250:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800257:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800266:	50                   	push   %eax
  800267:	8d 83 e2 e1 ff ff    	lea    -0x1e1e(%ebx),%eax
  80026d:	50                   	push   %eax
  80026e:	e8 38 01 00 00       	call   8003ab <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800273:	83 c4 08             	add    $0x8,%esp
  800276:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80027c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800282:	50                   	push   %eax
  800283:	e8 72 09 00 00       	call   800bfa <sys_cputs>

	return b.cnt;
}
  800288:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800291:	c9                   	leave  
  800292:	c3                   	ret    

00800293 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800299:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80029c:	50                   	push   %eax
  80029d:	ff 75 08             	pushl  0x8(%ebp)
  8002a0:	e8 8c ff ff ff       	call   800231 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a5:	c9                   	leave  
  8002a6:	c3                   	ret    

008002a7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	57                   	push   %edi
  8002ab:	56                   	push   %esi
  8002ac:	53                   	push   %ebx
  8002ad:	83 ec 2c             	sub    $0x2c,%esp
  8002b0:	e8 cd 05 00 00       	call   800882 <__x86.get_pc_thunk.cx>
  8002b5:	81 c1 4b 1d 00 00    	add    $0x1d4b,%ecx
  8002bb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002be:	89 c7                	mov    %eax,%edi
  8002c0:	89 d6                	mov    %edx,%esi
  8002c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002cb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002d9:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002dc:	39 d3                	cmp    %edx,%ebx
  8002de:	72 09                	jb     8002e9 <printnum+0x42>
  8002e0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002e3:	0f 87 83 00 00 00    	ja     80036c <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e9:	83 ec 0c             	sub    $0xc,%esp
  8002ec:	ff 75 18             	pushl  0x18(%ebp)
  8002ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002f5:	53                   	push   %ebx
  8002f6:	ff 75 10             	pushl  0x10(%ebp)
  8002f9:	83 ec 08             	sub    $0x8,%esp
  8002fc:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ff:	ff 75 d8             	pushl  -0x28(%ebp)
  800302:	ff 75 d4             	pushl  -0x2c(%ebp)
  800305:	ff 75 d0             	pushl  -0x30(%ebp)
  800308:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80030b:	e8 a0 09 00 00       	call   800cb0 <__udivdi3>
  800310:	83 c4 18             	add    $0x18,%esp
  800313:	52                   	push   %edx
  800314:	50                   	push   %eax
  800315:	89 f2                	mov    %esi,%edx
  800317:	89 f8                	mov    %edi,%eax
  800319:	e8 89 ff ff ff       	call   8002a7 <printnum>
  80031e:	83 c4 20             	add    $0x20,%esp
  800321:	eb 13                	jmp    800336 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800323:	83 ec 08             	sub    $0x8,%esp
  800326:	56                   	push   %esi
  800327:	ff 75 18             	pushl  0x18(%ebp)
  80032a:	ff d7                	call   *%edi
  80032c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80032f:	83 eb 01             	sub    $0x1,%ebx
  800332:	85 db                	test   %ebx,%ebx
  800334:	7f ed                	jg     800323 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800336:	83 ec 08             	sub    $0x8,%esp
  800339:	56                   	push   %esi
  80033a:	83 ec 04             	sub    $0x4,%esp
  80033d:	ff 75 dc             	pushl  -0x24(%ebp)
  800340:	ff 75 d8             	pushl  -0x28(%ebp)
  800343:	ff 75 d4             	pushl  -0x2c(%ebp)
  800346:	ff 75 d0             	pushl  -0x30(%ebp)
  800349:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80034c:	89 f3                	mov    %esi,%ebx
  80034e:	e8 7d 0a 00 00       	call   800dd0 <__umoddi3>
  800353:	83 c4 14             	add    $0x14,%esp
  800356:	0f be 84 06 d8 ef ff 	movsbl -0x1028(%esi,%eax,1),%eax
  80035d:	ff 
  80035e:	50                   	push   %eax
  80035f:	ff d7                	call   *%edi
}
  800361:	83 c4 10             	add    $0x10,%esp
  800364:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800367:	5b                   	pop    %ebx
  800368:	5e                   	pop    %esi
  800369:	5f                   	pop    %edi
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    
  80036c:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80036f:	eb be                	jmp    80032f <printnum+0x88>

00800371 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800377:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80037b:	8b 10                	mov    (%eax),%edx
  80037d:	3b 50 04             	cmp    0x4(%eax),%edx
  800380:	73 0a                	jae    80038c <sprintputch+0x1b>
		*b->buf++ = ch;
  800382:	8d 4a 01             	lea    0x1(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 45 08             	mov    0x8(%ebp),%eax
  80038a:	88 02                	mov    %al,(%edx)
}
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <printfmt>:
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800394:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800397:	50                   	push   %eax
  800398:	ff 75 10             	pushl  0x10(%ebp)
  80039b:	ff 75 0c             	pushl  0xc(%ebp)
  80039e:	ff 75 08             	pushl  0x8(%ebp)
  8003a1:	e8 05 00 00 00       	call   8003ab <vprintfmt>
}
  8003a6:	83 c4 10             	add    $0x10,%esp
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    

008003ab <vprintfmt>:
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	57                   	push   %edi
  8003af:	56                   	push   %esi
  8003b0:	53                   	push   %ebx
  8003b1:	83 ec 2c             	sub    $0x2c,%esp
  8003b4:	e8 4b fd ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  8003b9:	81 c3 47 1c 00 00    	add    $0x1c47,%ebx
  8003bf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003c2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003c5:	e9 8e 03 00 00       	jmp    800758 <.L35+0x48>
		padc = ' ';
  8003ca:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8d 47 01             	lea    0x1(%edi),%eax
  8003ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f1:	0f b6 17             	movzbl (%edi),%edx
  8003f4:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f7:	3c 55                	cmp    $0x55,%al
  8003f9:	0f 87 e1 03 00 00    	ja     8007e0 <.L22>
  8003ff:	0f b6 c0             	movzbl %al,%eax
  800402:	89 d9                	mov    %ebx,%ecx
  800404:	03 8c 83 68 f0 ff ff 	add    -0xf98(%ebx,%eax,4),%ecx
  80040b:	ff e1                	jmp    *%ecx

0080040d <.L67>:
  80040d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800410:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800414:	eb d5                	jmp    8003eb <vprintfmt+0x40>

00800416 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800419:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80041d:	eb cc                	jmp    8003eb <vprintfmt+0x40>

0080041f <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	0f b6 d2             	movzbl %dl,%edx
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800425:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80042a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800431:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800434:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800437:	83 f9 09             	cmp    $0x9,%ecx
  80043a:	77 55                	ja     800491 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  80043c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80043f:	eb e9                	jmp    80042a <.L29+0xb>

00800441 <.L26>:
			precision = va_arg(ap, int);
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8b 00                	mov    (%eax),%eax
  800446:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 40 04             	lea    0x4(%eax),%eax
  80044f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800455:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800459:	79 90                	jns    8003eb <vprintfmt+0x40>
				width = precision, precision = -1;
  80045b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80045e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800461:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800468:	eb 81                	jmp    8003eb <vprintfmt+0x40>

0080046a <.L27>:
  80046a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046d:	85 c0                	test   %eax,%eax
  80046f:	ba 00 00 00 00       	mov    $0x0,%edx
  800474:	0f 49 d0             	cmovns %eax,%edx
  800477:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047d:	e9 69 ff ff ff       	jmp    8003eb <vprintfmt+0x40>

00800482 <.L23>:
  800482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800485:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80048c:	e9 5a ff ff ff       	jmp    8003eb <vprintfmt+0x40>
  800491:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800494:	eb bf                	jmp    800455 <.L26+0x14>

00800496 <.L33>:
			lflag++;
  800496:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80049d:	e9 49 ff ff ff       	jmp    8003eb <vprintfmt+0x40>

008004a2 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a5:	8d 78 04             	lea    0x4(%eax),%edi
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	56                   	push   %esi
  8004ac:	ff 30                	pushl  (%eax)
  8004ae:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004b1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004b4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004b7:	e9 99 02 00 00       	jmp    800755 <.L35+0x45>

008004bc <.L32>:
			err = va_arg(ap, int);
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 78 04             	lea    0x4(%eax),%edi
  8004c2:	8b 00                	mov    (%eax),%eax
  8004c4:	99                   	cltd   
  8004c5:	31 d0                	xor    %edx,%eax
  8004c7:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c9:	83 f8 06             	cmp    $0x6,%eax
  8004cc:	7f 27                	jg     8004f5 <.L32+0x39>
  8004ce:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	74 1c                	je     8004f5 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004d9:	52                   	push   %edx
  8004da:	8d 83 f9 ef ff ff    	lea    -0x1007(%ebx),%eax
  8004e0:	50                   	push   %eax
  8004e1:	56                   	push   %esi
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 a4 fe ff ff       	call   80038e <printfmt>
  8004ea:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004ed:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004f0:	e9 60 02 00 00       	jmp    800755 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004f5:	50                   	push   %eax
  8004f6:	8d 83 f0 ef ff ff    	lea    -0x1010(%ebx),%eax
  8004fc:	50                   	push   %eax
  8004fd:	56                   	push   %esi
  8004fe:	ff 75 08             	pushl  0x8(%ebp)
  800501:	e8 88 fe ff ff       	call   80038e <printfmt>
  800506:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800509:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80050c:	e9 44 02 00 00       	jmp    800755 <.L35+0x45>

00800511 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	83 c0 04             	add    $0x4,%eax
  800517:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80051f:	85 ff                	test   %edi,%edi
  800521:	8d 83 e9 ef ff ff    	lea    -0x1017(%ebx),%eax
  800527:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80052a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052e:	0f 8e b5 00 00 00    	jle    8005e9 <.L36+0xd8>
  800534:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800538:	75 08                	jne    800542 <.L36+0x31>
  80053a:	89 75 0c             	mov    %esi,0xc(%ebp)
  80053d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800540:	eb 6d                	jmp    8005af <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	ff 75 d0             	pushl  -0x30(%ebp)
  800548:	57                   	push   %edi
  800549:	e8 50 03 00 00       	call   80089e <strnlen>
  80054e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800551:	29 c2                	sub    %eax,%edx
  800553:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800556:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800559:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800560:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800563:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800565:	eb 10                	jmp    800577 <.L36+0x66>
					putch(padc, putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	56                   	push   %esi
  80056b:	ff 75 e0             	pushl  -0x20(%ebp)
  80056e:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800571:	83 ef 01             	sub    $0x1,%edi
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	85 ff                	test   %edi,%edi
  800579:	7f ec                	jg     800567 <.L36+0x56>
  80057b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057e:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800581:	85 d2                	test   %edx,%edx
  800583:	b8 00 00 00 00       	mov    $0x0,%eax
  800588:	0f 49 c2             	cmovns %edx,%eax
  80058b:	29 c2                	sub    %eax,%edx
  80058d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800590:	89 75 0c             	mov    %esi,0xc(%ebp)
  800593:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800596:	eb 17                	jmp    8005af <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800598:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059c:	75 30                	jne    8005ce <.L36+0xbd>
					putch(ch, putdat);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	ff 75 0c             	pushl  0xc(%ebp)
  8005a4:	50                   	push   %eax
  8005a5:	ff 55 08             	call   *0x8(%ebp)
  8005a8:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ab:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005af:	83 c7 01             	add    $0x1,%edi
  8005b2:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005b6:	0f be c2             	movsbl %dl,%eax
  8005b9:	85 c0                	test   %eax,%eax
  8005bb:	74 52                	je     80060f <.L36+0xfe>
  8005bd:	85 f6                	test   %esi,%esi
  8005bf:	78 d7                	js     800598 <.L36+0x87>
  8005c1:	83 ee 01             	sub    $0x1,%esi
  8005c4:	79 d2                	jns    800598 <.L36+0x87>
  8005c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005c9:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005cc:	eb 32                	jmp    800600 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ce:	0f be d2             	movsbl %dl,%edx
  8005d1:	83 ea 20             	sub    $0x20,%edx
  8005d4:	83 fa 5e             	cmp    $0x5e,%edx
  8005d7:	76 c5                	jbe    80059e <.L36+0x8d>
					putch('?', putdat);
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	ff 75 0c             	pushl  0xc(%ebp)
  8005df:	6a 3f                	push   $0x3f
  8005e1:	ff 55 08             	call   *0x8(%ebp)
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	eb c2                	jmp    8005ab <.L36+0x9a>
  8005e9:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005ec:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ef:	eb be                	jmp    8005af <.L36+0x9e>
				putch(' ', putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	56                   	push   %esi
  8005f5:	6a 20                	push   $0x20
  8005f7:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005fa:	83 ef 01             	sub    $0x1,%edi
  8005fd:	83 c4 10             	add    $0x10,%esp
  800600:	85 ff                	test   %edi,%edi
  800602:	7f ed                	jg     8005f1 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800604:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800607:	89 45 14             	mov    %eax,0x14(%ebp)
  80060a:	e9 46 01 00 00       	jmp    800755 <.L35+0x45>
  80060f:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800612:	8b 75 0c             	mov    0xc(%ebp),%esi
  800615:	eb e9                	jmp    800600 <.L36+0xef>

00800617 <.L31>:
  800617:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  80061a:	83 f9 01             	cmp    $0x1,%ecx
  80061d:	7e 40                	jle    80065f <.L31+0x48>
		return va_arg(*ap, long long);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8b 50 04             	mov    0x4(%eax),%edx
  800625:	8b 00                	mov    (%eax),%eax
  800627:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 40 08             	lea    0x8(%eax),%eax
  800633:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800636:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063a:	79 55                	jns    800691 <.L31+0x7a>
				putch('-', putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	56                   	push   %esi
  800640:	6a 2d                	push   $0x2d
  800642:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800645:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800648:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80064b:	f7 da                	neg    %edx
  80064d:	83 d1 00             	adc    $0x0,%ecx
  800650:	f7 d9                	neg    %ecx
  800652:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800655:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065a:	e9 db 00 00 00       	jmp    80073a <.L35+0x2a>
	else if (lflag)
  80065f:	85 c9                	test   %ecx,%ecx
  800661:	75 17                	jne    80067a <.L31+0x63>
		return va_arg(*ap, int);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8b 00                	mov    (%eax),%eax
  800668:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066b:	99                   	cltd   
  80066c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8d 40 04             	lea    0x4(%eax),%eax
  800675:	89 45 14             	mov    %eax,0x14(%ebp)
  800678:	eb bc                	jmp    800636 <.L31+0x1f>
		return va_arg(*ap, long);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800682:	99                   	cltd   
  800683:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 40 04             	lea    0x4(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
  80068f:	eb a5                	jmp    800636 <.L31+0x1f>
			num = getint(&ap, lflag);
  800691:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800694:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800697:	b8 0a 00 00 00       	mov    $0xa,%eax
  80069c:	e9 99 00 00 00       	jmp    80073a <.L35+0x2a>

008006a1 <.L37>:
  8006a1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  8006a4:	83 f9 01             	cmp    $0x1,%ecx
  8006a7:	7e 15                	jle    8006be <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8b 10                	mov    (%eax),%edx
  8006ae:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b1:	8d 40 08             	lea    0x8(%eax),%eax
  8006b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006bc:	eb 7c                	jmp    80073a <.L35+0x2a>
	else if (lflag)
  8006be:	85 c9                	test   %ecx,%ecx
  8006c0:	75 17                	jne    8006d9 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8b 10                	mov    (%eax),%edx
  8006c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cc:	8d 40 04             	lea    0x4(%eax),%eax
  8006cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d7:	eb 61                	jmp    80073a <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8b 10                	mov    (%eax),%edx
  8006de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e3:	8d 40 04             	lea    0x4(%eax),%eax
  8006e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ee:	eb 4a                	jmp    80073a <.L35+0x2a>

008006f0 <.L34>:
			putch('X', putdat);
  8006f0:	83 ec 08             	sub    $0x8,%esp
  8006f3:	56                   	push   %esi
  8006f4:	6a 58                	push   $0x58
  8006f6:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006f9:	83 c4 08             	add    $0x8,%esp
  8006fc:	56                   	push   %esi
  8006fd:	6a 58                	push   $0x58
  8006ff:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800702:	83 c4 08             	add    $0x8,%esp
  800705:	56                   	push   %esi
  800706:	6a 58                	push   $0x58
  800708:	ff 55 08             	call   *0x8(%ebp)
			break;
  80070b:	83 c4 10             	add    $0x10,%esp
  80070e:	eb 45                	jmp    800755 <.L35+0x45>

00800710 <.L35>:
			putch('0', putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	56                   	push   %esi
  800714:	6a 30                	push   $0x30
  800716:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800719:	83 c4 08             	add    $0x8,%esp
  80071c:	56                   	push   %esi
  80071d:	6a 78                	push   $0x78
  80071f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	8b 10                	mov    (%eax),%edx
  800727:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80072c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80072f:	8d 40 04             	lea    0x4(%eax),%eax
  800732:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800735:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80073a:	83 ec 0c             	sub    $0xc,%esp
  80073d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800741:	57                   	push   %edi
  800742:	ff 75 e0             	pushl  -0x20(%ebp)
  800745:	50                   	push   %eax
  800746:	51                   	push   %ecx
  800747:	52                   	push   %edx
  800748:	89 f2                	mov    %esi,%edx
  80074a:	8b 45 08             	mov    0x8(%ebp),%eax
  80074d:	e8 55 fb ff ff       	call   8002a7 <printnum>
			break;
  800752:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800755:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800758:	83 c7 01             	add    $0x1,%edi
  80075b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80075f:	83 f8 25             	cmp    $0x25,%eax
  800762:	0f 84 62 fc ff ff    	je     8003ca <vprintfmt+0x1f>
			if (ch == '\0')
  800768:	85 c0                	test   %eax,%eax
  80076a:	0f 84 91 00 00 00    	je     800801 <.L22+0x21>
			putch(ch, putdat);
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	56                   	push   %esi
  800774:	50                   	push   %eax
  800775:	ff 55 08             	call   *0x8(%ebp)
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb db                	jmp    800758 <.L35+0x48>

0080077d <.L38>:
  80077d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  800780:	83 f9 01             	cmp    $0x1,%ecx
  800783:	7e 15                	jle    80079a <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8b 10                	mov    (%eax),%edx
  80078a:	8b 48 04             	mov    0x4(%eax),%ecx
  80078d:	8d 40 08             	lea    0x8(%eax),%eax
  800790:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800793:	b8 10 00 00 00       	mov    $0x10,%eax
  800798:	eb a0                	jmp    80073a <.L35+0x2a>
	else if (lflag)
  80079a:	85 c9                	test   %ecx,%ecx
  80079c:	75 17                	jne    8007b5 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8b 10                	mov    (%eax),%edx
  8007a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a8:	8d 40 04             	lea    0x4(%eax),%eax
  8007ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ae:	b8 10 00 00 00       	mov    $0x10,%eax
  8007b3:	eb 85                	jmp    80073a <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	8b 10                	mov    (%eax),%edx
  8007ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bf:	8d 40 04             	lea    0x4(%eax),%eax
  8007c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c5:	b8 10 00 00 00       	mov    $0x10,%eax
  8007ca:	e9 6b ff ff ff       	jmp    80073a <.L35+0x2a>

008007cf <.L25>:
			putch(ch, putdat);
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	56                   	push   %esi
  8007d3:	6a 25                	push   $0x25
  8007d5:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	e9 75 ff ff ff       	jmp    800755 <.L35+0x45>

008007e0 <.L22>:
			putch('%', putdat);
  8007e0:	83 ec 08             	sub    $0x8,%esp
  8007e3:	56                   	push   %esi
  8007e4:	6a 25                	push   $0x25
  8007e6:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e9:	83 c4 10             	add    $0x10,%esp
  8007ec:	89 f8                	mov    %edi,%eax
  8007ee:	eb 03                	jmp    8007f3 <.L22+0x13>
  8007f0:	83 e8 01             	sub    $0x1,%eax
  8007f3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007f7:	75 f7                	jne    8007f0 <.L22+0x10>
  8007f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007fc:	e9 54 ff ff ff       	jmp    800755 <.L35+0x45>
}
  800801:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800804:	5b                   	pop    %ebx
  800805:	5e                   	pop    %esi
  800806:	5f                   	pop    %edi
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	83 ec 14             	sub    $0x14,%esp
  800810:	e8 ef f8 ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800815:	81 c3 eb 17 00 00    	add    $0x17eb,%ebx
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800821:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800824:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800828:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800832:	85 c0                	test   %eax,%eax
  800834:	74 2b                	je     800861 <vsnprintf+0x58>
  800836:	85 d2                	test   %edx,%edx
  800838:	7e 27                	jle    800861 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80083a:	ff 75 14             	pushl  0x14(%ebp)
  80083d:	ff 75 10             	pushl  0x10(%ebp)
  800840:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800843:	50                   	push   %eax
  800844:	8d 83 71 e3 ff ff    	lea    -0x1c8f(%ebx),%eax
  80084a:	50                   	push   %eax
  80084b:	e8 5b fb ff ff       	call   8003ab <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800850:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800853:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800856:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800859:	83 c4 10             	add    $0x10,%esp
}
  80085c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085f:	c9                   	leave  
  800860:	c3                   	ret    
		return -E_INVAL;
  800861:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800866:	eb f4                	jmp    80085c <vsnprintf+0x53>

00800868 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80086e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800871:	50                   	push   %eax
  800872:	ff 75 10             	pushl  0x10(%ebp)
  800875:	ff 75 0c             	pushl  0xc(%ebp)
  800878:	ff 75 08             	pushl  0x8(%ebp)
  80087b:	e8 89 ff ff ff       	call   800809 <vsnprintf>
	va_end(ap);

	return rc;
}
  800880:	c9                   	leave  
  800881:	c3                   	ret    

00800882 <__x86.get_pc_thunk.cx>:
  800882:	8b 0c 24             	mov    (%esp),%ecx
  800885:	c3                   	ret    

00800886 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80088c:	b8 00 00 00 00       	mov    $0x0,%eax
  800891:	eb 03                	jmp    800896 <strlen+0x10>
		n++;
  800893:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800896:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80089a:	75 f7                	jne    800893 <strlen+0xd>
	return n;
}
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ac:	eb 03                	jmp    8008b1 <strnlen+0x13>
		n++;
  8008ae:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b1:	39 d0                	cmp    %edx,%eax
  8008b3:	74 06                	je     8008bb <strnlen+0x1d>
  8008b5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008b9:	75 f3                	jne    8008ae <strnlen+0x10>
	return n;
}
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	53                   	push   %ebx
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c7:	89 c2                	mov    %eax,%edx
  8008c9:	83 c1 01             	add    $0x1,%ecx
  8008cc:	83 c2 01             	add    $0x1,%edx
  8008cf:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008d3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d6:	84 db                	test   %bl,%bl
  8008d8:	75 ef                	jne    8008c9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008da:	5b                   	pop    %ebx
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	53                   	push   %ebx
  8008e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e4:	53                   	push   %ebx
  8008e5:	e8 9c ff ff ff       	call   800886 <strlen>
  8008ea:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008ed:	ff 75 0c             	pushl  0xc(%ebp)
  8008f0:	01 d8                	add    %ebx,%eax
  8008f2:	50                   	push   %eax
  8008f3:	e8 c5 ff ff ff       	call   8008bd <strcpy>
	return dst;
}
  8008f8:	89 d8                	mov    %ebx,%eax
  8008fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fd:	c9                   	leave  
  8008fe:	c3                   	ret    

008008ff <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 75 08             	mov    0x8(%ebp),%esi
  800907:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090a:	89 f3                	mov    %esi,%ebx
  80090c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80090f:	89 f2                	mov    %esi,%edx
  800911:	eb 0f                	jmp    800922 <strncpy+0x23>
		*dst++ = *src;
  800913:	83 c2 01             	add    $0x1,%edx
  800916:	0f b6 01             	movzbl (%ecx),%eax
  800919:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091c:	80 39 01             	cmpb   $0x1,(%ecx)
  80091f:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800922:	39 da                	cmp    %ebx,%edx
  800924:	75 ed                	jne    800913 <strncpy+0x14>
	}
	return ret;
}
  800926:	89 f0                	mov    %esi,%eax
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	8b 75 08             	mov    0x8(%ebp),%esi
  800934:	8b 55 0c             	mov    0xc(%ebp),%edx
  800937:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80093a:	89 f0                	mov    %esi,%eax
  80093c:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800940:	85 c9                	test   %ecx,%ecx
  800942:	75 0b                	jne    80094f <strlcpy+0x23>
  800944:	eb 17                	jmp    80095d <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800946:	83 c2 01             	add    $0x1,%edx
  800949:	83 c0 01             	add    $0x1,%eax
  80094c:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80094f:	39 d8                	cmp    %ebx,%eax
  800951:	74 07                	je     80095a <strlcpy+0x2e>
  800953:	0f b6 0a             	movzbl (%edx),%ecx
  800956:	84 c9                	test   %cl,%cl
  800958:	75 ec                	jne    800946 <strlcpy+0x1a>
		*dst = '\0';
  80095a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80095d:	29 f0                	sub    %esi,%eax
}
  80095f:	5b                   	pop    %ebx
  800960:	5e                   	pop    %esi
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80096c:	eb 06                	jmp    800974 <strcmp+0x11>
		p++, q++;
  80096e:	83 c1 01             	add    $0x1,%ecx
  800971:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800974:	0f b6 01             	movzbl (%ecx),%eax
  800977:	84 c0                	test   %al,%al
  800979:	74 04                	je     80097f <strcmp+0x1c>
  80097b:	3a 02                	cmp    (%edx),%al
  80097d:	74 ef                	je     80096e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80097f:	0f b6 c0             	movzbl %al,%eax
  800982:	0f b6 12             	movzbl (%edx),%edx
  800985:	29 d0                	sub    %edx,%eax
}
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	53                   	push   %ebx
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 55 0c             	mov    0xc(%ebp),%edx
  800993:	89 c3                	mov    %eax,%ebx
  800995:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800998:	eb 06                	jmp    8009a0 <strncmp+0x17>
		n--, p++, q++;
  80099a:	83 c0 01             	add    $0x1,%eax
  80099d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009a0:	39 d8                	cmp    %ebx,%eax
  8009a2:	74 16                	je     8009ba <strncmp+0x31>
  8009a4:	0f b6 08             	movzbl (%eax),%ecx
  8009a7:	84 c9                	test   %cl,%cl
  8009a9:	74 04                	je     8009af <strncmp+0x26>
  8009ab:	3a 0a                	cmp    (%edx),%cl
  8009ad:	74 eb                	je     80099a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009af:	0f b6 00             	movzbl (%eax),%eax
  8009b2:	0f b6 12             	movzbl (%edx),%edx
  8009b5:	29 d0                	sub    %edx,%eax
}
  8009b7:	5b                   	pop    %ebx
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    
		return 0;
  8009ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8009bf:	eb f6                	jmp    8009b7 <strncmp+0x2e>

008009c1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009cb:	0f b6 10             	movzbl (%eax),%edx
  8009ce:	84 d2                	test   %dl,%dl
  8009d0:	74 09                	je     8009db <strchr+0x1a>
		if (*s == c)
  8009d2:	38 ca                	cmp    %cl,%dl
  8009d4:	74 0a                	je     8009e0 <strchr+0x1f>
	for (; *s; s++)
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	eb f0                	jmp    8009cb <strchr+0xa>
			return (char *) s;
	return 0;
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ec:	eb 03                	jmp    8009f1 <strfind+0xf>
  8009ee:	83 c0 01             	add    $0x1,%eax
  8009f1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009f4:	38 ca                	cmp    %cl,%dl
  8009f6:	74 04                	je     8009fc <strfind+0x1a>
  8009f8:	84 d2                	test   %dl,%dl
  8009fa:	75 f2                	jne    8009ee <strfind+0xc>
			break;
	return (char *) s;
}
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	57                   	push   %edi
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a07:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a0a:	85 c9                	test   %ecx,%ecx
  800a0c:	74 13                	je     800a21 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a14:	75 05                	jne    800a1b <memset+0x1d>
  800a16:	f6 c1 03             	test   $0x3,%cl
  800a19:	74 0d                	je     800a28 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1e:	fc                   	cld    
  800a1f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a21:	89 f8                	mov    %edi,%eax
  800a23:	5b                   	pop    %ebx
  800a24:	5e                   	pop    %esi
  800a25:	5f                   	pop    %edi
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    
		c &= 0xFF;
  800a28:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a2c:	89 d3                	mov    %edx,%ebx
  800a2e:	c1 e3 08             	shl    $0x8,%ebx
  800a31:	89 d0                	mov    %edx,%eax
  800a33:	c1 e0 18             	shl    $0x18,%eax
  800a36:	89 d6                	mov    %edx,%esi
  800a38:	c1 e6 10             	shl    $0x10,%esi
  800a3b:	09 f0                	or     %esi,%eax
  800a3d:	09 c2                	or     %eax,%edx
  800a3f:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a41:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a44:	89 d0                	mov    %edx,%eax
  800a46:	fc                   	cld    
  800a47:	f3 ab                	rep stos %eax,%es:(%edi)
  800a49:	eb d6                	jmp    800a21 <memset+0x23>

00800a4b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	57                   	push   %edi
  800a4f:	56                   	push   %esi
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a56:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a59:	39 c6                	cmp    %eax,%esi
  800a5b:	73 35                	jae    800a92 <memmove+0x47>
  800a5d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a60:	39 c2                	cmp    %eax,%edx
  800a62:	76 2e                	jbe    800a92 <memmove+0x47>
		s += n;
		d += n;
  800a64:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a67:	89 d6                	mov    %edx,%esi
  800a69:	09 fe                	or     %edi,%esi
  800a6b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a71:	74 0c                	je     800a7f <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a73:	83 ef 01             	sub    $0x1,%edi
  800a76:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a79:	fd                   	std    
  800a7a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a7c:	fc                   	cld    
  800a7d:	eb 21                	jmp    800aa0 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7f:	f6 c1 03             	test   $0x3,%cl
  800a82:	75 ef                	jne    800a73 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a84:	83 ef 04             	sub    $0x4,%edi
  800a87:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a8a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a8d:	fd                   	std    
  800a8e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a90:	eb ea                	jmp    800a7c <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a92:	89 f2                	mov    %esi,%edx
  800a94:	09 c2                	or     %eax,%edx
  800a96:	f6 c2 03             	test   $0x3,%dl
  800a99:	74 09                	je     800aa4 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a9b:	89 c7                	mov    %eax,%edi
  800a9d:	fc                   	cld    
  800a9e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa0:	5e                   	pop    %esi
  800aa1:	5f                   	pop    %edi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa4:	f6 c1 03             	test   $0x3,%cl
  800aa7:	75 f2                	jne    800a9b <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aa9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aac:	89 c7                	mov    %eax,%edi
  800aae:	fc                   	cld    
  800aaf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab1:	eb ed                	jmp    800aa0 <memmove+0x55>

00800ab3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ab6:	ff 75 10             	pushl  0x10(%ebp)
  800ab9:	ff 75 0c             	pushl  0xc(%ebp)
  800abc:	ff 75 08             	pushl  0x8(%ebp)
  800abf:	e8 87 ff ff ff       	call   800a4b <memmove>
}
  800ac4:	c9                   	leave  
  800ac5:	c3                   	ret    

00800ac6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ace:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad1:	89 c6                	mov    %eax,%esi
  800ad3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad6:	39 f0                	cmp    %esi,%eax
  800ad8:	74 1c                	je     800af6 <memcmp+0x30>
		if (*s1 != *s2)
  800ada:	0f b6 08             	movzbl (%eax),%ecx
  800add:	0f b6 1a             	movzbl (%edx),%ebx
  800ae0:	38 d9                	cmp    %bl,%cl
  800ae2:	75 08                	jne    800aec <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ae4:	83 c0 01             	add    $0x1,%eax
  800ae7:	83 c2 01             	add    $0x1,%edx
  800aea:	eb ea                	jmp    800ad6 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800aec:	0f b6 c1             	movzbl %cl,%eax
  800aef:	0f b6 db             	movzbl %bl,%ebx
  800af2:	29 d8                	sub    %ebx,%eax
  800af4:	eb 05                	jmp    800afb <memcmp+0x35>
	}

	return 0;
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	8b 45 08             	mov    0x8(%ebp),%eax
  800b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b08:	89 c2                	mov    %eax,%edx
  800b0a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b0d:	39 d0                	cmp    %edx,%eax
  800b0f:	73 09                	jae    800b1a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b11:	38 08                	cmp    %cl,(%eax)
  800b13:	74 05                	je     800b1a <memfind+0x1b>
	for (; s < ends; s++)
  800b15:	83 c0 01             	add    $0x1,%eax
  800b18:	eb f3                	jmp    800b0d <memfind+0xe>
			break;
	return (void *) s;
}
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b28:	eb 03                	jmp    800b2d <strtol+0x11>
		s++;
  800b2a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b2d:	0f b6 01             	movzbl (%ecx),%eax
  800b30:	3c 20                	cmp    $0x20,%al
  800b32:	74 f6                	je     800b2a <strtol+0xe>
  800b34:	3c 09                	cmp    $0x9,%al
  800b36:	74 f2                	je     800b2a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b38:	3c 2b                	cmp    $0x2b,%al
  800b3a:	74 2e                	je     800b6a <strtol+0x4e>
	int neg = 0;
  800b3c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b41:	3c 2d                	cmp    $0x2d,%al
  800b43:	74 2f                	je     800b74 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b45:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b4b:	75 05                	jne    800b52 <strtol+0x36>
  800b4d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b50:	74 2c                	je     800b7e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b52:	85 db                	test   %ebx,%ebx
  800b54:	75 0a                	jne    800b60 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b56:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b5b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b5e:	74 28                	je     800b88 <strtol+0x6c>
		base = 10;
  800b60:	b8 00 00 00 00       	mov    $0x0,%eax
  800b65:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b68:	eb 50                	jmp    800bba <strtol+0x9e>
		s++;
  800b6a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b6d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b72:	eb d1                	jmp    800b45 <strtol+0x29>
		s++, neg = 1;
  800b74:	83 c1 01             	add    $0x1,%ecx
  800b77:	bf 01 00 00 00       	mov    $0x1,%edi
  800b7c:	eb c7                	jmp    800b45 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b7e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b82:	74 0e                	je     800b92 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b84:	85 db                	test   %ebx,%ebx
  800b86:	75 d8                	jne    800b60 <strtol+0x44>
		s++, base = 8;
  800b88:	83 c1 01             	add    $0x1,%ecx
  800b8b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b90:	eb ce                	jmp    800b60 <strtol+0x44>
		s += 2, base = 16;
  800b92:	83 c1 02             	add    $0x2,%ecx
  800b95:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b9a:	eb c4                	jmp    800b60 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b9c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b9f:	89 f3                	mov    %esi,%ebx
  800ba1:	80 fb 19             	cmp    $0x19,%bl
  800ba4:	77 29                	ja     800bcf <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ba6:	0f be d2             	movsbl %dl,%edx
  800ba9:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bac:	3b 55 10             	cmp    0x10(%ebp),%edx
  800baf:	7d 30                	jge    800be1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bb1:	83 c1 01             	add    $0x1,%ecx
  800bb4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb8:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bba:	0f b6 11             	movzbl (%ecx),%edx
  800bbd:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bc0:	89 f3                	mov    %esi,%ebx
  800bc2:	80 fb 09             	cmp    $0x9,%bl
  800bc5:	77 d5                	ja     800b9c <strtol+0x80>
			dig = *s - '0';
  800bc7:	0f be d2             	movsbl %dl,%edx
  800bca:	83 ea 30             	sub    $0x30,%edx
  800bcd:	eb dd                	jmp    800bac <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bcf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bd2:	89 f3                	mov    %esi,%ebx
  800bd4:	80 fb 19             	cmp    $0x19,%bl
  800bd7:	77 08                	ja     800be1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bd9:	0f be d2             	movsbl %dl,%edx
  800bdc:	83 ea 37             	sub    $0x37,%edx
  800bdf:	eb cb                	jmp    800bac <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800be1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be5:	74 05                	je     800bec <strtol+0xd0>
		*endptr = (char *) s;
  800be7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bea:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bec:	89 c2                	mov    %eax,%edx
  800bee:	f7 da                	neg    %edx
  800bf0:	85 ff                	test   %edi,%edi
  800bf2:	0f 45 c2             	cmovne %edx,%eax
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c00:	b8 00 00 00 00       	mov    $0x0,%eax
  800c05:	8b 55 08             	mov    0x8(%ebp),%edx
  800c08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0b:	89 c3                	mov    %eax,%ebx
  800c0d:	89 c7                	mov    %eax,%edi
  800c0f:	89 c6                	mov    %eax,%esi
  800c11:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c23:	b8 01 00 00 00       	mov    $0x1,%eax
  800c28:	89 d1                	mov    %edx,%ecx
  800c2a:	89 d3                	mov    %edx,%ebx
  800c2c:	89 d7                	mov    %edx,%edi
  800c2e:	89 d6                	mov    %edx,%esi
  800c30:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	83 ec 1c             	sub    $0x1c,%esp
  800c40:	e8 66 00 00 00       	call   800cab <__x86.get_pc_thunk.ax>
  800c45:	05 bb 13 00 00       	add    $0x13bb,%eax
  800c4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800c4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c52:	8b 55 08             	mov    0x8(%ebp),%edx
  800c55:	b8 03 00 00 00       	mov    $0x3,%eax
  800c5a:	89 cb                	mov    %ecx,%ebx
  800c5c:	89 cf                	mov    %ecx,%edi
  800c5e:	89 ce                	mov    %ecx,%esi
  800c60:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7f 08                	jg     800c6e <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6e:	83 ec 0c             	sub    $0xc,%esp
  800c71:	50                   	push   %eax
  800c72:	6a 03                	push   $0x3
  800c74:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c77:	8d 83 c0 f1 ff ff    	lea    -0xe40(%ebx),%eax
  800c7d:	50                   	push   %eax
  800c7e:	6a 23                	push   $0x23
  800c80:	8d 83 dd f1 ff ff    	lea    -0xe23(%ebx),%eax
  800c86:	50                   	push   %eax
  800c87:	e8 fb f4 ff ff       	call   800187 <_panic>

00800c8c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c92:	ba 00 00 00 00       	mov    $0x0,%edx
  800c97:	b8 02 00 00 00       	mov    $0x2,%eax
  800c9c:	89 d1                	mov    %edx,%ecx
  800c9e:	89 d3                	mov    %edx,%ebx
  800ca0:	89 d7                	mov    %edx,%edi
  800ca2:	89 d6                	mov    %edx,%esi
  800ca4:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <__x86.get_pc_thunk.ax>:
  800cab:	8b 04 24             	mov    (%esp),%eax
  800cae:	c3                   	ret    
  800caf:	90                   	nop

00800cb0 <__udivdi3>:
  800cb0:	55                   	push   %ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
  800cb4:	83 ec 1c             	sub    $0x1c,%esp
  800cb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800cbb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800cbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800cc3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800cc7:	85 d2                	test   %edx,%edx
  800cc9:	75 35                	jne    800d00 <__udivdi3+0x50>
  800ccb:	39 f3                	cmp    %esi,%ebx
  800ccd:	0f 87 bd 00 00 00    	ja     800d90 <__udivdi3+0xe0>
  800cd3:	85 db                	test   %ebx,%ebx
  800cd5:	89 d9                	mov    %ebx,%ecx
  800cd7:	75 0b                	jne    800ce4 <__udivdi3+0x34>
  800cd9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cde:	31 d2                	xor    %edx,%edx
  800ce0:	f7 f3                	div    %ebx
  800ce2:	89 c1                	mov    %eax,%ecx
  800ce4:	31 d2                	xor    %edx,%edx
  800ce6:	89 f0                	mov    %esi,%eax
  800ce8:	f7 f1                	div    %ecx
  800cea:	89 c6                	mov    %eax,%esi
  800cec:	89 e8                	mov    %ebp,%eax
  800cee:	89 f7                	mov    %esi,%edi
  800cf0:	f7 f1                	div    %ecx
  800cf2:	89 fa                	mov    %edi,%edx
  800cf4:	83 c4 1c             	add    $0x1c,%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    
  800cfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d00:	39 f2                	cmp    %esi,%edx
  800d02:	77 7c                	ja     800d80 <__udivdi3+0xd0>
  800d04:	0f bd fa             	bsr    %edx,%edi
  800d07:	83 f7 1f             	xor    $0x1f,%edi
  800d0a:	0f 84 98 00 00 00    	je     800da8 <__udivdi3+0xf8>
  800d10:	89 f9                	mov    %edi,%ecx
  800d12:	b8 20 00 00 00       	mov    $0x20,%eax
  800d17:	29 f8                	sub    %edi,%eax
  800d19:	d3 e2                	shl    %cl,%edx
  800d1b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d1f:	89 c1                	mov    %eax,%ecx
  800d21:	89 da                	mov    %ebx,%edx
  800d23:	d3 ea                	shr    %cl,%edx
  800d25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d29:	09 d1                	or     %edx,%ecx
  800d2b:	89 f2                	mov    %esi,%edx
  800d2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d31:	89 f9                	mov    %edi,%ecx
  800d33:	d3 e3                	shl    %cl,%ebx
  800d35:	89 c1                	mov    %eax,%ecx
  800d37:	d3 ea                	shr    %cl,%edx
  800d39:	89 f9                	mov    %edi,%ecx
  800d3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d3f:	d3 e6                	shl    %cl,%esi
  800d41:	89 eb                	mov    %ebp,%ebx
  800d43:	89 c1                	mov    %eax,%ecx
  800d45:	d3 eb                	shr    %cl,%ebx
  800d47:	09 de                	or     %ebx,%esi
  800d49:	89 f0                	mov    %esi,%eax
  800d4b:	f7 74 24 08          	divl   0x8(%esp)
  800d4f:	89 d6                	mov    %edx,%esi
  800d51:	89 c3                	mov    %eax,%ebx
  800d53:	f7 64 24 0c          	mull   0xc(%esp)
  800d57:	39 d6                	cmp    %edx,%esi
  800d59:	72 0c                	jb     800d67 <__udivdi3+0xb7>
  800d5b:	89 f9                	mov    %edi,%ecx
  800d5d:	d3 e5                	shl    %cl,%ebp
  800d5f:	39 c5                	cmp    %eax,%ebp
  800d61:	73 5d                	jae    800dc0 <__udivdi3+0x110>
  800d63:	39 d6                	cmp    %edx,%esi
  800d65:	75 59                	jne    800dc0 <__udivdi3+0x110>
  800d67:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d6a:	31 ff                	xor    %edi,%edi
  800d6c:	89 fa                	mov    %edi,%edx
  800d6e:	83 c4 1c             	add    $0x1c,%esp
  800d71:	5b                   	pop    %ebx
  800d72:	5e                   	pop    %esi
  800d73:	5f                   	pop    %edi
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    
  800d76:	8d 76 00             	lea    0x0(%esi),%esi
  800d79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d80:	31 ff                	xor    %edi,%edi
  800d82:	31 c0                	xor    %eax,%eax
  800d84:	89 fa                	mov    %edi,%edx
  800d86:	83 c4 1c             	add    $0x1c,%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    
  800d8e:	66 90                	xchg   %ax,%ax
  800d90:	31 ff                	xor    %edi,%edi
  800d92:	89 e8                	mov    %ebp,%eax
  800d94:	89 f2                	mov    %esi,%edx
  800d96:	f7 f3                	div    %ebx
  800d98:	89 fa                	mov    %edi,%edx
  800d9a:	83 c4 1c             	add    $0x1c,%esp
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    
  800da2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800da8:	39 f2                	cmp    %esi,%edx
  800daa:	72 06                	jb     800db2 <__udivdi3+0x102>
  800dac:	31 c0                	xor    %eax,%eax
  800dae:	39 eb                	cmp    %ebp,%ebx
  800db0:	77 d2                	ja     800d84 <__udivdi3+0xd4>
  800db2:	b8 01 00 00 00       	mov    $0x1,%eax
  800db7:	eb cb                	jmp    800d84 <__udivdi3+0xd4>
  800db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dc0:	89 d8                	mov    %ebx,%eax
  800dc2:	31 ff                	xor    %edi,%edi
  800dc4:	eb be                	jmp    800d84 <__udivdi3+0xd4>
  800dc6:	66 90                	xchg   %ax,%ax
  800dc8:	66 90                	xchg   %ax,%ax
  800dca:	66 90                	xchg   %ax,%ax
  800dcc:	66 90                	xchg   %ax,%ax
  800dce:	66 90                	xchg   %ax,%ax

00800dd0 <__umoddi3>:
  800dd0:	55                   	push   %ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 1c             	sub    $0x1c,%esp
  800dd7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ddb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ddf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800de3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800de7:	85 ed                	test   %ebp,%ebp
  800de9:	89 f0                	mov    %esi,%eax
  800deb:	89 da                	mov    %ebx,%edx
  800ded:	75 19                	jne    800e08 <__umoddi3+0x38>
  800def:	39 df                	cmp    %ebx,%edi
  800df1:	0f 86 b1 00 00 00    	jbe    800ea8 <__umoddi3+0xd8>
  800df7:	f7 f7                	div    %edi
  800df9:	89 d0                	mov    %edx,%eax
  800dfb:	31 d2                	xor    %edx,%edx
  800dfd:	83 c4 1c             	add    $0x1c,%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    
  800e05:	8d 76 00             	lea    0x0(%esi),%esi
  800e08:	39 dd                	cmp    %ebx,%ebp
  800e0a:	77 f1                	ja     800dfd <__umoddi3+0x2d>
  800e0c:	0f bd cd             	bsr    %ebp,%ecx
  800e0f:	83 f1 1f             	xor    $0x1f,%ecx
  800e12:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e16:	0f 84 b4 00 00 00    	je     800ed0 <__umoddi3+0x100>
  800e1c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e21:	89 c2                	mov    %eax,%edx
  800e23:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e27:	29 c2                	sub    %eax,%edx
  800e29:	89 c1                	mov    %eax,%ecx
  800e2b:	89 f8                	mov    %edi,%eax
  800e2d:	d3 e5                	shl    %cl,%ebp
  800e2f:	89 d1                	mov    %edx,%ecx
  800e31:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e35:	d3 e8                	shr    %cl,%eax
  800e37:	09 c5                	or     %eax,%ebp
  800e39:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e3d:	89 c1                	mov    %eax,%ecx
  800e3f:	d3 e7                	shl    %cl,%edi
  800e41:	89 d1                	mov    %edx,%ecx
  800e43:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e47:	89 df                	mov    %ebx,%edi
  800e49:	d3 ef                	shr    %cl,%edi
  800e4b:	89 c1                	mov    %eax,%ecx
  800e4d:	89 f0                	mov    %esi,%eax
  800e4f:	d3 e3                	shl    %cl,%ebx
  800e51:	89 d1                	mov    %edx,%ecx
  800e53:	89 fa                	mov    %edi,%edx
  800e55:	d3 e8                	shr    %cl,%eax
  800e57:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e5c:	09 d8                	or     %ebx,%eax
  800e5e:	f7 f5                	div    %ebp
  800e60:	d3 e6                	shl    %cl,%esi
  800e62:	89 d1                	mov    %edx,%ecx
  800e64:	f7 64 24 08          	mull   0x8(%esp)
  800e68:	39 d1                	cmp    %edx,%ecx
  800e6a:	89 c3                	mov    %eax,%ebx
  800e6c:	89 d7                	mov    %edx,%edi
  800e6e:	72 06                	jb     800e76 <__umoddi3+0xa6>
  800e70:	75 0e                	jne    800e80 <__umoddi3+0xb0>
  800e72:	39 c6                	cmp    %eax,%esi
  800e74:	73 0a                	jae    800e80 <__umoddi3+0xb0>
  800e76:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e7a:	19 ea                	sbb    %ebp,%edx
  800e7c:	89 d7                	mov    %edx,%edi
  800e7e:	89 c3                	mov    %eax,%ebx
  800e80:	89 ca                	mov    %ecx,%edx
  800e82:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e87:	29 de                	sub    %ebx,%esi
  800e89:	19 fa                	sbb    %edi,%edx
  800e8b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e8f:	89 d0                	mov    %edx,%eax
  800e91:	d3 e0                	shl    %cl,%eax
  800e93:	89 d9                	mov    %ebx,%ecx
  800e95:	d3 ee                	shr    %cl,%esi
  800e97:	d3 ea                	shr    %cl,%edx
  800e99:	09 f0                	or     %esi,%eax
  800e9b:	83 c4 1c             	add    $0x1c,%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    
  800ea3:	90                   	nop
  800ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea8:	85 ff                	test   %edi,%edi
  800eaa:	89 f9                	mov    %edi,%ecx
  800eac:	75 0b                	jne    800eb9 <__umoddi3+0xe9>
  800eae:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb3:	31 d2                	xor    %edx,%edx
  800eb5:	f7 f7                	div    %edi
  800eb7:	89 c1                	mov    %eax,%ecx
  800eb9:	89 d8                	mov    %ebx,%eax
  800ebb:	31 d2                	xor    %edx,%edx
  800ebd:	f7 f1                	div    %ecx
  800ebf:	89 f0                	mov    %esi,%eax
  800ec1:	f7 f1                	div    %ecx
  800ec3:	e9 31 ff ff ff       	jmp    800df9 <__umoddi3+0x29>
  800ec8:	90                   	nop
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	39 dd                	cmp    %ebx,%ebp
  800ed2:	72 08                	jb     800edc <__umoddi3+0x10c>
  800ed4:	39 f7                	cmp    %esi,%edi
  800ed6:	0f 87 21 ff ff ff    	ja     800dfd <__umoddi3+0x2d>
  800edc:	89 da                	mov    %ebx,%edx
  800ede:	89 f0                	mov    %esi,%eax
  800ee0:	29 f8                	sub    %edi,%eax
  800ee2:	19 ea                	sbb    %ebp,%edx
  800ee4:	e9 14 ff ff ff       	jmp    800dfd <__umoddi3+0x2d>
