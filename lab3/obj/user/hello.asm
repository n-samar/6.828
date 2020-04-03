
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
  80003a:	e8 35 00 00 00       	call   800074 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	cprintf("hello, world\n");
  800045:	8d 83 5c ee ff ff    	lea    -0x11a4(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 57 01 00 00       	call   8001a8 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800051:	c7 c0 2c 20 80 00    	mov    $0x80202c,%eax
  800057:	8b 00                	mov    (%eax),%eax
  800059:	8b 40 48             	mov    0x48(%eax),%eax
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	50                   	push   %eax
  800060:	8d 83 6a ee ff ff    	lea    -0x1196(%ebx),%eax
  800066:	50                   	push   %eax
  800067:	e8 3c 01 00 00       	call   8001a8 <cprintf>
}
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <__x86.get_pc_thunk.bx>:
  800074:	8b 1c 24             	mov    (%esp),%ebx
  800077:	c3                   	ret    

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	57                   	push   %edi
  80007c:	56                   	push   %esi
  80007d:	53                   	push   %ebx
  80007e:	83 ec 0c             	sub    $0xc,%esp
  800081:	e8 ee ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800086:	81 c3 7a 1f 00 00    	add    $0x1f7a,%ebx
  80008c:	8b 75 08             	mov    0x8(%ebp),%esi
  80008f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

	thisenv = envs+ENVX(sys_getenvid());
  800092:	e8 0a 0b 00 00       	call   800ba1 <sys_getenvid>
  800097:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80009f:	c1 e0 05             	shl    $0x5,%eax
  8000a2:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  8000a8:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  8000ae:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b0:	85 f6                	test   %esi,%esi
  8000b2:	7e 08                	jle    8000bc <libmain+0x44>
		binaryname = argv[0];
  8000b4:	8b 07                	mov    (%edi),%eax
  8000b6:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000bc:	83 ec 08             	sub    $0x8,%esp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	e8 6d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c6:	e8 0b 00 00 00       	call   8000d6 <exit>
}
  8000cb:	83 c4 10             	add    $0x10,%esp
  8000ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	53                   	push   %ebx
  8000da:	83 ec 10             	sub    $0x10,%esp
  8000dd:	e8 92 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8000e2:	81 c3 1e 1f 00 00    	add    $0x1f1e,%ebx
	sys_env_destroy(0);
  8000e8:	6a 00                	push   $0x0
  8000ea:	e8 5d 0a 00 00       	call   800b4c <sys_env_destroy>
}
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f5:	c9                   	leave  
  8000f6:	c3                   	ret    

008000f7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 73 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800101:	81 c3 ff 1e 00 00    	add    $0x1eff,%ebx
  800107:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  80010a:	8b 16                	mov    (%esi),%edx
  80010c:	8d 42 01             	lea    0x1(%edx),%eax
  80010f:	89 06                	mov    %eax,(%esi)
  800111:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800114:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800118:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011d:	74 0b                	je     80012a <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80011f:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800123:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80012a:	83 ec 08             	sub    $0x8,%esp
  80012d:	68 ff 00 00 00       	push   $0xff
  800132:	8d 46 08             	lea    0x8(%esi),%eax
  800135:	50                   	push   %eax
  800136:	e8 d4 09 00 00       	call   800b0f <sys_cputs>
		b->idx = 0;
  80013b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800141:	83 c4 10             	add    $0x10,%esp
  800144:	eb d9                	jmp    80011f <putch+0x28>

00800146 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	53                   	push   %ebx
  80014a:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800150:	e8 1f ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800155:	81 c3 ab 1e 00 00    	add    $0x1eab,%ebx
	struct printbuf b;

	b.idx = 0;
  80015b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800162:	00 00 00 
	b.cnt = 0;
  800165:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016f:	ff 75 0c             	pushl  0xc(%ebp)
  800172:	ff 75 08             	pushl  0x8(%ebp)
  800175:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017b:	50                   	push   %eax
  80017c:	8d 83 f7 e0 ff ff    	lea    -0x1f09(%ebx),%eax
  800182:	50                   	push   %eax
  800183:	e8 38 01 00 00       	call   8002c0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800188:	83 c4 08             	add    $0x8,%esp
  80018b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800191:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800197:	50                   	push   %eax
  800198:	e8 72 09 00 00       	call   800b0f <sys_cputs>

	return b.cnt;
}
  80019d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 8c ff ff ff       	call   800146 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 2c             	sub    $0x2c,%esp
  8001c5:	e8 cd 05 00 00       	call   800797 <__x86.get_pc_thunk.cx>
  8001ca:	81 c1 36 1e 00 00    	add    $0x1e36,%ecx
  8001d0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001d3:	89 c7                	mov    %eax,%edi
  8001d5:	89 d6                	mov    %edx,%esi
  8001d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001e0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001eb:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001ee:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001f1:	39 d3                	cmp    %edx,%ebx
  8001f3:	72 09                	jb     8001fe <printnum+0x42>
  8001f5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f8:	0f 87 83 00 00 00    	ja     800281 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	ff 75 18             	pushl  0x18(%ebp)
  800204:	8b 45 14             	mov    0x14(%ebp),%eax
  800207:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80020a:	53                   	push   %ebx
  80020b:	ff 75 10             	pushl  0x10(%ebp)
  80020e:	83 ec 08             	sub    $0x8,%esp
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	ff 75 d4             	pushl  -0x2c(%ebp)
  80021a:	ff 75 d0             	pushl  -0x30(%ebp)
  80021d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800220:	e8 fb 09 00 00       	call   800c20 <__udivdi3>
  800225:	83 c4 18             	add    $0x18,%esp
  800228:	52                   	push   %edx
  800229:	50                   	push   %eax
  80022a:	89 f2                	mov    %esi,%edx
  80022c:	89 f8                	mov    %edi,%eax
  80022e:	e8 89 ff ff ff       	call   8001bc <printnum>
  800233:	83 c4 20             	add    $0x20,%esp
  800236:	eb 13                	jmp    80024b <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800238:	83 ec 08             	sub    $0x8,%esp
  80023b:	56                   	push   %esi
  80023c:	ff 75 18             	pushl  0x18(%ebp)
  80023f:	ff d7                	call   *%edi
  800241:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800244:	83 eb 01             	sub    $0x1,%ebx
  800247:	85 db                	test   %ebx,%ebx
  800249:	7f ed                	jg     800238 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024b:	83 ec 08             	sub    $0x8,%esp
  80024e:	56                   	push   %esi
  80024f:	83 ec 04             	sub    $0x4,%esp
  800252:	ff 75 dc             	pushl  -0x24(%ebp)
  800255:	ff 75 d8             	pushl  -0x28(%ebp)
  800258:	ff 75 d4             	pushl  -0x2c(%ebp)
  80025b:	ff 75 d0             	pushl  -0x30(%ebp)
  80025e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800261:	89 f3                	mov    %esi,%ebx
  800263:	e8 d8 0a 00 00       	call   800d40 <__umoddi3>
  800268:	83 c4 14             	add    $0x14,%esp
  80026b:	0f be 84 06 8b ee ff 	movsbl -0x1175(%esi,%eax,1),%eax
  800272:	ff 
  800273:	50                   	push   %eax
  800274:	ff d7                	call   *%edi
}
  800276:	83 c4 10             	add    $0x10,%esp
  800279:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027c:	5b                   	pop    %ebx
  80027d:	5e                   	pop    %esi
  80027e:	5f                   	pop    %edi
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    
  800281:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800284:	eb be                	jmp    800244 <printnum+0x88>

00800286 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800290:	8b 10                	mov    (%eax),%edx
  800292:	3b 50 04             	cmp    0x4(%eax),%edx
  800295:	73 0a                	jae    8002a1 <sprintputch+0x1b>
		*b->buf++ = ch;
  800297:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	88 02                	mov    %al,(%edx)
}
  8002a1:	5d                   	pop    %ebp
  8002a2:	c3                   	ret    

008002a3 <printfmt>:
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002a9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ac:	50                   	push   %eax
  8002ad:	ff 75 10             	pushl  0x10(%ebp)
  8002b0:	ff 75 0c             	pushl  0xc(%ebp)
  8002b3:	ff 75 08             	pushl  0x8(%ebp)
  8002b6:	e8 05 00 00 00       	call   8002c0 <vprintfmt>
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    

008002c0 <vprintfmt>:
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 2c             	sub    $0x2c,%esp
  8002c9:	e8 a6 fd ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8002ce:	81 c3 32 1d 00 00    	add    $0x1d32,%ebx
  8002d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002d7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002da:	e9 8e 03 00 00       	jmp    80066d <.L35+0x48>
		padc = ' ';
  8002df:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002e3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002ea:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002f1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800300:	8d 47 01             	lea    0x1(%edi),%eax
  800303:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800306:	0f b6 17             	movzbl (%edi),%edx
  800309:	8d 42 dd             	lea    -0x23(%edx),%eax
  80030c:	3c 55                	cmp    $0x55,%al
  80030e:	0f 87 e1 03 00 00    	ja     8006f5 <.L22>
  800314:	0f b6 c0             	movzbl %al,%eax
  800317:	89 d9                	mov    %ebx,%ecx
  800319:	03 8c 83 18 ef ff ff 	add    -0x10e8(%ebx,%eax,4),%ecx
  800320:	ff e1                	jmp    *%ecx

00800322 <.L67>:
  800322:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800325:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800329:	eb d5                	jmp    800300 <vprintfmt+0x40>

0080032b <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  80032b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80032e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800332:	eb cc                	jmp    800300 <vprintfmt+0x40>

00800334 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800334:	0f b6 d2             	movzbl %dl,%edx
  800337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80033a:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80033f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800342:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800346:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800349:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80034c:	83 f9 09             	cmp    $0x9,%ecx
  80034f:	77 55                	ja     8003a6 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  800351:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800354:	eb e9                	jmp    80033f <.L29+0xb>

00800356 <.L26>:
			precision = va_arg(ap, int);
  800356:	8b 45 14             	mov    0x14(%ebp),%eax
  800359:	8b 00                	mov    (%eax),%eax
  80035b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 40 04             	lea    0x4(%eax),%eax
  800364:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80036a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036e:	79 90                	jns    800300 <vprintfmt+0x40>
				width = precision, precision = -1;
  800370:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800373:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800376:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037d:	eb 81                	jmp    800300 <vprintfmt+0x40>

0080037f <.L27>:
  80037f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800382:	85 c0                	test   %eax,%eax
  800384:	ba 00 00 00 00       	mov    $0x0,%edx
  800389:	0f 49 d0             	cmovns %eax,%edx
  80038c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800392:	e9 69 ff ff ff       	jmp    800300 <vprintfmt+0x40>

00800397 <.L23>:
  800397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80039a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a1:	e9 5a ff ff ff       	jmp    800300 <vprintfmt+0x40>
  8003a6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003a9:	eb bf                	jmp    80036a <.L26+0x14>

008003ab <.L33>:
			lflag++;
  8003ab:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b2:	e9 49 ff ff ff       	jmp    800300 <vprintfmt+0x40>

008003b7 <.L30>:
			putch(va_arg(ap, int), putdat);
  8003b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ba:	8d 78 04             	lea    0x4(%eax),%edi
  8003bd:	83 ec 08             	sub    $0x8,%esp
  8003c0:	56                   	push   %esi
  8003c1:	ff 30                	pushl  (%eax)
  8003c3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003c6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003c9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003cc:	e9 99 02 00 00       	jmp    80066a <.L35+0x45>

008003d1 <.L32>:
			err = va_arg(ap, int);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 78 04             	lea    0x4(%eax),%edi
  8003d7:	8b 00                	mov    (%eax),%eax
  8003d9:	99                   	cltd   
  8003da:	31 d0                	xor    %edx,%eax
  8003dc:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003de:	83 f8 06             	cmp    $0x6,%eax
  8003e1:	7f 27                	jg     80040a <.L32+0x39>
  8003e3:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8003ea:	85 d2                	test   %edx,%edx
  8003ec:	74 1c                	je     80040a <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8003ee:	52                   	push   %edx
  8003ef:	8d 83 ac ee ff ff    	lea    -0x1154(%ebx),%eax
  8003f5:	50                   	push   %eax
  8003f6:	56                   	push   %esi
  8003f7:	ff 75 08             	pushl  0x8(%ebp)
  8003fa:	e8 a4 fe ff ff       	call   8002a3 <printfmt>
  8003ff:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800402:	89 7d 14             	mov    %edi,0x14(%ebp)
  800405:	e9 60 02 00 00       	jmp    80066a <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  80040a:	50                   	push   %eax
  80040b:	8d 83 a3 ee ff ff    	lea    -0x115d(%ebx),%eax
  800411:	50                   	push   %eax
  800412:	56                   	push   %esi
  800413:	ff 75 08             	pushl  0x8(%ebp)
  800416:	e8 88 fe ff ff       	call   8002a3 <printfmt>
  80041b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800421:	e9 44 02 00 00       	jmp    80066a <.L35+0x45>

00800426 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	83 c0 04             	add    $0x4,%eax
  80042c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800434:	85 ff                	test   %edi,%edi
  800436:	8d 83 9c ee ff ff    	lea    -0x1164(%ebx),%eax
  80043c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80043f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800443:	0f 8e b5 00 00 00    	jle    8004fe <.L36+0xd8>
  800449:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80044d:	75 08                	jne    800457 <.L36+0x31>
  80044f:	89 75 0c             	mov    %esi,0xc(%ebp)
  800452:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800455:	eb 6d                	jmp    8004c4 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	ff 75 d0             	pushl  -0x30(%ebp)
  80045d:	57                   	push   %edi
  80045e:	e8 50 03 00 00       	call   8007b3 <strnlen>
  800463:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800466:	29 c2                	sub    %eax,%edx
  800468:	89 55 c8             	mov    %edx,-0x38(%ebp)
  80046b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800472:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800475:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800478:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	eb 10                	jmp    80048c <.L36+0x66>
					putch(padc, putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	56                   	push   %esi
  800480:	ff 75 e0             	pushl  -0x20(%ebp)
  800483:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ef 01             	sub    $0x1,%edi
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	85 ff                	test   %edi,%edi
  80048e:	7f ec                	jg     80047c <.L36+0x56>
  800490:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800493:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800496:	85 d2                	test   %edx,%edx
  800498:	b8 00 00 00 00       	mov    $0x0,%eax
  80049d:	0f 49 c2             	cmovns %edx,%eax
  8004a0:	29 c2                	sub    %eax,%edx
  8004a2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a5:	89 75 0c             	mov    %esi,0xc(%ebp)
  8004a8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ab:	eb 17                	jmp    8004c4 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b1:	75 30                	jne    8004e3 <.L36+0xbd>
					putch(ch, putdat);
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	ff 75 0c             	pushl  0xc(%ebp)
  8004b9:	50                   	push   %eax
  8004ba:	ff 55 08             	call   *0x8(%ebp)
  8004bd:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c0:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004c4:	83 c7 01             	add    $0x1,%edi
  8004c7:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004cb:	0f be c2             	movsbl %dl,%eax
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	74 52                	je     800524 <.L36+0xfe>
  8004d2:	85 f6                	test   %esi,%esi
  8004d4:	78 d7                	js     8004ad <.L36+0x87>
  8004d6:	83 ee 01             	sub    $0x1,%esi
  8004d9:	79 d2                	jns    8004ad <.L36+0x87>
  8004db:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004de:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004e1:	eb 32                	jmp    800515 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e3:	0f be d2             	movsbl %dl,%edx
  8004e6:	83 ea 20             	sub    $0x20,%edx
  8004e9:	83 fa 5e             	cmp    $0x5e,%edx
  8004ec:	76 c5                	jbe    8004b3 <.L36+0x8d>
					putch('?', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	ff 75 0c             	pushl  0xc(%ebp)
  8004f4:	6a 3f                	push   $0x3f
  8004f6:	ff 55 08             	call   *0x8(%ebp)
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb c2                	jmp    8004c0 <.L36+0x9a>
  8004fe:	89 75 0c             	mov    %esi,0xc(%ebp)
  800501:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800504:	eb be                	jmp    8004c4 <.L36+0x9e>
				putch(' ', putdat);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	56                   	push   %esi
  80050a:	6a 20                	push   $0x20
  80050c:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80050f:	83 ef 01             	sub    $0x1,%edi
  800512:	83 c4 10             	add    $0x10,%esp
  800515:	85 ff                	test   %edi,%edi
  800517:	7f ed                	jg     800506 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800519:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80051c:	89 45 14             	mov    %eax,0x14(%ebp)
  80051f:	e9 46 01 00 00       	jmp    80066a <.L35+0x45>
  800524:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800527:	8b 75 0c             	mov    0xc(%ebp),%esi
  80052a:	eb e9                	jmp    800515 <.L36+0xef>

0080052c <.L31>:
  80052c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  80052f:	83 f9 01             	cmp    $0x1,%ecx
  800532:	7e 40                	jle    800574 <.L31+0x48>
		return va_arg(*ap, long long);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8b 50 04             	mov    0x4(%eax),%edx
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 40 08             	lea    0x8(%eax),%eax
  800548:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80054b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80054f:	79 55                	jns    8005a6 <.L31+0x7a>
				putch('-', putdat);
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	56                   	push   %esi
  800555:	6a 2d                	push   $0x2d
  800557:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80055a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800560:	f7 da                	neg    %edx
  800562:	83 d1 00             	adc    $0x0,%ecx
  800565:	f7 d9                	neg    %ecx
  800567:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80056a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056f:	e9 db 00 00 00       	jmp    80064f <.L35+0x2a>
	else if (lflag)
  800574:	85 c9                	test   %ecx,%ecx
  800576:	75 17                	jne    80058f <.L31+0x63>
		return va_arg(*ap, int);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800580:	99                   	cltd   
  800581:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8d 40 04             	lea    0x4(%eax),%eax
  80058a:	89 45 14             	mov    %eax,0x14(%ebp)
  80058d:	eb bc                	jmp    80054b <.L31+0x1f>
		return va_arg(*ap, long);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8b 00                	mov    (%eax),%eax
  800594:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800597:	99                   	cltd   
  800598:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8d 40 04             	lea    0x4(%eax),%eax
  8005a1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a4:	eb a5                	jmp    80054b <.L31+0x1f>
			num = getint(&ap, lflag);
  8005a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ac:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b1:	e9 99 00 00 00       	jmp    80064f <.L35+0x2a>

008005b6 <.L37>:
  8005b6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  8005b9:	83 f9 01             	cmp    $0x1,%ecx
  8005bc:	7e 15                	jle    8005d3 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 10                	mov    (%eax),%edx
  8005c3:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c6:	8d 40 08             	lea    0x8(%eax),%eax
  8005c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d1:	eb 7c                	jmp    80064f <.L35+0x2a>
	else if (lflag)
  8005d3:	85 c9                	test   %ecx,%ecx
  8005d5:	75 17                	jne    8005ee <.L37+0x38>
		return va_arg(*ap, unsigned int);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8b 10                	mov    (%eax),%edx
  8005dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e1:	8d 40 04             	lea    0x4(%eax),%eax
  8005e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ec:	eb 61                	jmp    80064f <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8b 10                	mov    (%eax),%edx
  8005f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f8:	8d 40 04             	lea    0x4(%eax),%eax
  8005fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800603:	eb 4a                	jmp    80064f <.L35+0x2a>

00800605 <.L34>:
			putch('X', putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	56                   	push   %esi
  800609:	6a 58                	push   $0x58
  80060b:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80060e:	83 c4 08             	add    $0x8,%esp
  800611:	56                   	push   %esi
  800612:	6a 58                	push   $0x58
  800614:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800617:	83 c4 08             	add    $0x8,%esp
  80061a:	56                   	push   %esi
  80061b:	6a 58                	push   $0x58
  80061d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800620:	83 c4 10             	add    $0x10,%esp
  800623:	eb 45                	jmp    80066a <.L35+0x45>

00800625 <.L35>:
			putch('0', putdat);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	56                   	push   %esi
  800629:	6a 30                	push   $0x30
  80062b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80062e:	83 c4 08             	add    $0x8,%esp
  800631:	56                   	push   %esi
  800632:	6a 78                	push   $0x78
  800634:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8b 10                	mov    (%eax),%edx
  80063c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800641:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800644:	8d 40 04             	lea    0x4(%eax),%eax
  800647:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064a:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80064f:	83 ec 0c             	sub    $0xc,%esp
  800652:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800656:	57                   	push   %edi
  800657:	ff 75 e0             	pushl  -0x20(%ebp)
  80065a:	50                   	push   %eax
  80065b:	51                   	push   %ecx
  80065c:	52                   	push   %edx
  80065d:	89 f2                	mov    %esi,%edx
  80065f:	8b 45 08             	mov    0x8(%ebp),%eax
  800662:	e8 55 fb ff ff       	call   8001bc <printnum>
			break;
  800667:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80066a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80066d:	83 c7 01             	add    $0x1,%edi
  800670:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800674:	83 f8 25             	cmp    $0x25,%eax
  800677:	0f 84 62 fc ff ff    	je     8002df <vprintfmt+0x1f>
			if (ch == '\0')
  80067d:	85 c0                	test   %eax,%eax
  80067f:	0f 84 91 00 00 00    	je     800716 <.L22+0x21>
			putch(ch, putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	56                   	push   %esi
  800689:	50                   	push   %eax
  80068a:	ff 55 08             	call   *0x8(%ebp)
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	eb db                	jmp    80066d <.L35+0x48>

00800692 <.L38>:
  800692:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  800695:	83 f9 01             	cmp    $0x1,%ecx
  800698:	7e 15                	jle    8006af <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8b 10                	mov    (%eax),%edx
  80069f:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a2:	8d 40 08             	lea    0x8(%eax),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a8:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ad:	eb a0                	jmp    80064f <.L35+0x2a>
	else if (lflag)
  8006af:	85 c9                	test   %ecx,%ecx
  8006b1:	75 17                	jne    8006ca <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bd:	8d 40 04             	lea    0x4(%eax),%eax
  8006c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c8:	eb 85                	jmp    80064f <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8b 10                	mov    (%eax),%edx
  8006cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d4:	8d 40 04             	lea    0x4(%eax),%eax
  8006d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006da:	b8 10 00 00 00       	mov    $0x10,%eax
  8006df:	e9 6b ff ff ff       	jmp    80064f <.L35+0x2a>

008006e4 <.L25>:
			putch(ch, putdat);
  8006e4:	83 ec 08             	sub    $0x8,%esp
  8006e7:	56                   	push   %esi
  8006e8:	6a 25                	push   $0x25
  8006ea:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006ed:	83 c4 10             	add    $0x10,%esp
  8006f0:	e9 75 ff ff ff       	jmp    80066a <.L35+0x45>

008006f5 <.L22>:
			putch('%', putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	56                   	push   %esi
  8006f9:	6a 25                	push   $0x25
  8006fb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	89 f8                	mov    %edi,%eax
  800703:	eb 03                	jmp    800708 <.L22+0x13>
  800705:	83 e8 01             	sub    $0x1,%eax
  800708:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80070c:	75 f7                	jne    800705 <.L22+0x10>
  80070e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800711:	e9 54 ff ff ff       	jmp    80066a <.L35+0x45>
}
  800716:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800719:	5b                   	pop    %ebx
  80071a:	5e                   	pop    %esi
  80071b:	5f                   	pop    %edi
  80071c:	5d                   	pop    %ebp
  80071d:	c3                   	ret    

0080071e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	53                   	push   %ebx
  800722:	83 ec 14             	sub    $0x14,%esp
  800725:	e8 4a f9 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  80072a:	81 c3 d6 18 00 00    	add    $0x18d6,%ebx
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800736:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800739:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800740:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800747:	85 c0                	test   %eax,%eax
  800749:	74 2b                	je     800776 <vsnprintf+0x58>
  80074b:	85 d2                	test   %edx,%edx
  80074d:	7e 27                	jle    800776 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074f:	ff 75 14             	pushl  0x14(%ebp)
  800752:	ff 75 10             	pushl  0x10(%ebp)
  800755:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800758:	50                   	push   %eax
  800759:	8d 83 86 e2 ff ff    	lea    -0x1d7a(%ebx),%eax
  80075f:	50                   	push   %eax
  800760:	e8 5b fb ff ff       	call   8002c0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800765:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800768:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076e:	83 c4 10             	add    $0x10,%esp
}
  800771:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800774:	c9                   	leave  
  800775:	c3                   	ret    
		return -E_INVAL;
  800776:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077b:	eb f4                	jmp    800771 <vsnprintf+0x53>

0080077d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800783:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800786:	50                   	push   %eax
  800787:	ff 75 10             	pushl  0x10(%ebp)
  80078a:	ff 75 0c             	pushl  0xc(%ebp)
  80078d:	ff 75 08             	pushl  0x8(%ebp)
  800790:	e8 89 ff ff ff       	call   80071e <vsnprintf>
	va_end(ap);

	return rc;
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    

00800797 <__x86.get_pc_thunk.cx>:
  800797:	8b 0c 24             	mov    (%esp),%ecx
  80079a:	c3                   	ret    

0080079b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a6:	eb 03                	jmp    8007ab <strlen+0x10>
		n++;
  8007a8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007ab:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007af:	75 f7                	jne    8007a8 <strlen+0xd>
	return n;
}
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c1:	eb 03                	jmp    8007c6 <strnlen+0x13>
		n++;
  8007c3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c6:	39 d0                	cmp    %edx,%eax
  8007c8:	74 06                	je     8007d0 <strnlen+0x1d>
  8007ca:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ce:	75 f3                	jne    8007c3 <strnlen+0x10>
	return n;
}
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007dc:	89 c2                	mov    %eax,%edx
  8007de:	83 c1 01             	add    $0x1,%ecx
  8007e1:	83 c2 01             	add    $0x1,%edx
  8007e4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007e8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007eb:	84 db                	test   %bl,%bl
  8007ed:	75 ef                	jne    8007de <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ef:	5b                   	pop    %ebx
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f9:	53                   	push   %ebx
  8007fa:	e8 9c ff ff ff       	call   80079b <strlen>
  8007ff:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800802:	ff 75 0c             	pushl  0xc(%ebp)
  800805:	01 d8                	add    %ebx,%eax
  800807:	50                   	push   %eax
  800808:	e8 c5 ff ff ff       	call   8007d2 <strcpy>
	return dst;
}
  80080d:	89 d8                	mov    %ebx,%eax
  80080f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800812:	c9                   	leave  
  800813:	c3                   	ret    

00800814 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	56                   	push   %esi
  800818:	53                   	push   %ebx
  800819:	8b 75 08             	mov    0x8(%ebp),%esi
  80081c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081f:	89 f3                	mov    %esi,%ebx
  800821:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800824:	89 f2                	mov    %esi,%edx
  800826:	eb 0f                	jmp    800837 <strncpy+0x23>
		*dst++ = *src;
  800828:	83 c2 01             	add    $0x1,%edx
  80082b:	0f b6 01             	movzbl (%ecx),%eax
  80082e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800831:	80 39 01             	cmpb   $0x1,(%ecx)
  800834:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800837:	39 da                	cmp    %ebx,%edx
  800839:	75 ed                	jne    800828 <strncpy+0x14>
	}
	return ret;
}
  80083b:	89 f0                	mov    %esi,%eax
  80083d:	5b                   	pop    %ebx
  80083e:	5e                   	pop    %esi
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	56                   	push   %esi
  800845:	53                   	push   %ebx
  800846:	8b 75 08             	mov    0x8(%ebp),%esi
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80084f:	89 f0                	mov    %esi,%eax
  800851:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800855:	85 c9                	test   %ecx,%ecx
  800857:	75 0b                	jne    800864 <strlcpy+0x23>
  800859:	eb 17                	jmp    800872 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085b:	83 c2 01             	add    $0x1,%edx
  80085e:	83 c0 01             	add    $0x1,%eax
  800861:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800864:	39 d8                	cmp    %ebx,%eax
  800866:	74 07                	je     80086f <strlcpy+0x2e>
  800868:	0f b6 0a             	movzbl (%edx),%ecx
  80086b:	84 c9                	test   %cl,%cl
  80086d:	75 ec                	jne    80085b <strlcpy+0x1a>
		*dst = '\0';
  80086f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800872:	29 f0                	sub    %esi,%eax
}
  800874:	5b                   	pop    %ebx
  800875:	5e                   	pop    %esi
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800881:	eb 06                	jmp    800889 <strcmp+0x11>
		p++, q++;
  800883:	83 c1 01             	add    $0x1,%ecx
  800886:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800889:	0f b6 01             	movzbl (%ecx),%eax
  80088c:	84 c0                	test   %al,%al
  80088e:	74 04                	je     800894 <strcmp+0x1c>
  800890:	3a 02                	cmp    (%edx),%al
  800892:	74 ef                	je     800883 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800894:	0f b6 c0             	movzbl %al,%eax
  800897:	0f b6 12             	movzbl (%edx),%edx
  80089a:	29 d0                	sub    %edx,%eax
}
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	53                   	push   %ebx
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a8:	89 c3                	mov    %eax,%ebx
  8008aa:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ad:	eb 06                	jmp    8008b5 <strncmp+0x17>
		n--, p++, q++;
  8008af:	83 c0 01             	add    $0x1,%eax
  8008b2:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b5:	39 d8                	cmp    %ebx,%eax
  8008b7:	74 16                	je     8008cf <strncmp+0x31>
  8008b9:	0f b6 08             	movzbl (%eax),%ecx
  8008bc:	84 c9                	test   %cl,%cl
  8008be:	74 04                	je     8008c4 <strncmp+0x26>
  8008c0:	3a 0a                	cmp    (%edx),%cl
  8008c2:	74 eb                	je     8008af <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c4:	0f b6 00             	movzbl (%eax),%eax
  8008c7:	0f b6 12             	movzbl (%edx),%edx
  8008ca:	29 d0                	sub    %edx,%eax
}
  8008cc:	5b                   	pop    %ebx
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    
		return 0;
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	eb f6                	jmp    8008cc <strncmp+0x2e>

008008d6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e0:	0f b6 10             	movzbl (%eax),%edx
  8008e3:	84 d2                	test   %dl,%dl
  8008e5:	74 09                	je     8008f0 <strchr+0x1a>
		if (*s == c)
  8008e7:	38 ca                	cmp    %cl,%dl
  8008e9:	74 0a                	je     8008f5 <strchr+0x1f>
	for (; *s; s++)
  8008eb:	83 c0 01             	add    $0x1,%eax
  8008ee:	eb f0                	jmp    8008e0 <strchr+0xa>
			return (char *) s;
	return 0;
  8008f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800901:	eb 03                	jmp    800906 <strfind+0xf>
  800903:	83 c0 01             	add    $0x1,%eax
  800906:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800909:	38 ca                	cmp    %cl,%dl
  80090b:	74 04                	je     800911 <strfind+0x1a>
  80090d:	84 d2                	test   %dl,%dl
  80090f:	75 f2                	jne    800903 <strfind+0xc>
			break;
	return (char *) s;
}
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	57                   	push   %edi
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80091f:	85 c9                	test   %ecx,%ecx
  800921:	74 13                	je     800936 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800923:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800929:	75 05                	jne    800930 <memset+0x1d>
  80092b:	f6 c1 03             	test   $0x3,%cl
  80092e:	74 0d                	je     80093d <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800930:	8b 45 0c             	mov    0xc(%ebp),%eax
  800933:	fc                   	cld    
  800934:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800936:	89 f8                	mov    %edi,%eax
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5f                   	pop    %edi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    
		c &= 0xFF;
  80093d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800941:	89 d3                	mov    %edx,%ebx
  800943:	c1 e3 08             	shl    $0x8,%ebx
  800946:	89 d0                	mov    %edx,%eax
  800948:	c1 e0 18             	shl    $0x18,%eax
  80094b:	89 d6                	mov    %edx,%esi
  80094d:	c1 e6 10             	shl    $0x10,%esi
  800950:	09 f0                	or     %esi,%eax
  800952:	09 c2                	or     %eax,%edx
  800954:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800956:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800959:	89 d0                	mov    %edx,%eax
  80095b:	fc                   	cld    
  80095c:	f3 ab                	rep stos %eax,%es:(%edi)
  80095e:	eb d6                	jmp    800936 <memset+0x23>

00800960 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	57                   	push   %edi
  800964:	56                   	push   %esi
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096e:	39 c6                	cmp    %eax,%esi
  800970:	73 35                	jae    8009a7 <memmove+0x47>
  800972:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800975:	39 c2                	cmp    %eax,%edx
  800977:	76 2e                	jbe    8009a7 <memmove+0x47>
		s += n;
		d += n;
  800979:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097c:	89 d6                	mov    %edx,%esi
  80097e:	09 fe                	or     %edi,%esi
  800980:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800986:	74 0c                	je     800994 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800988:	83 ef 01             	sub    $0x1,%edi
  80098b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80098e:	fd                   	std    
  80098f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800991:	fc                   	cld    
  800992:	eb 21                	jmp    8009b5 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800994:	f6 c1 03             	test   $0x3,%cl
  800997:	75 ef                	jne    800988 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800999:	83 ef 04             	sub    $0x4,%edi
  80099c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009a2:	fd                   	std    
  8009a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a5:	eb ea                	jmp    800991 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a7:	89 f2                	mov    %esi,%edx
  8009a9:	09 c2                	or     %eax,%edx
  8009ab:	f6 c2 03             	test   $0x3,%dl
  8009ae:	74 09                	je     8009b9 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b0:	89 c7                	mov    %eax,%edi
  8009b2:	fc                   	cld    
  8009b3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b5:	5e                   	pop    %esi
  8009b6:	5f                   	pop    %edi
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b9:	f6 c1 03             	test   $0x3,%cl
  8009bc:	75 f2                	jne    8009b0 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009be:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009c1:	89 c7                	mov    %eax,%edi
  8009c3:	fc                   	cld    
  8009c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c6:	eb ed                	jmp    8009b5 <memmove+0x55>

008009c8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009cb:	ff 75 10             	pushl  0x10(%ebp)
  8009ce:	ff 75 0c             	pushl  0xc(%ebp)
  8009d1:	ff 75 08             	pushl  0x8(%ebp)
  8009d4:	e8 87 ff ff ff       	call   800960 <memmove>
}
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    

008009db <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	56                   	push   %esi
  8009df:	53                   	push   %ebx
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e6:	89 c6                	mov    %eax,%esi
  8009e8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009eb:	39 f0                	cmp    %esi,%eax
  8009ed:	74 1c                	je     800a0b <memcmp+0x30>
		if (*s1 != *s2)
  8009ef:	0f b6 08             	movzbl (%eax),%ecx
  8009f2:	0f b6 1a             	movzbl (%edx),%ebx
  8009f5:	38 d9                	cmp    %bl,%cl
  8009f7:	75 08                	jne    800a01 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009f9:	83 c0 01             	add    $0x1,%eax
  8009fc:	83 c2 01             	add    $0x1,%edx
  8009ff:	eb ea                	jmp    8009eb <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a01:	0f b6 c1             	movzbl %cl,%eax
  800a04:	0f b6 db             	movzbl %bl,%ebx
  800a07:	29 d8                	sub    %ebx,%eax
  800a09:	eb 05                	jmp    800a10 <memcmp+0x35>
	}

	return 0;
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a1d:	89 c2                	mov    %eax,%edx
  800a1f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a22:	39 d0                	cmp    %edx,%eax
  800a24:	73 09                	jae    800a2f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a26:	38 08                	cmp    %cl,(%eax)
  800a28:	74 05                	je     800a2f <memfind+0x1b>
	for (; s < ends; s++)
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	eb f3                	jmp    800a22 <memfind+0xe>
			break;
	return (void *) s;
}
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	57                   	push   %edi
  800a35:	56                   	push   %esi
  800a36:	53                   	push   %ebx
  800a37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3d:	eb 03                	jmp    800a42 <strtol+0x11>
		s++;
  800a3f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a42:	0f b6 01             	movzbl (%ecx),%eax
  800a45:	3c 20                	cmp    $0x20,%al
  800a47:	74 f6                	je     800a3f <strtol+0xe>
  800a49:	3c 09                	cmp    $0x9,%al
  800a4b:	74 f2                	je     800a3f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a4d:	3c 2b                	cmp    $0x2b,%al
  800a4f:	74 2e                	je     800a7f <strtol+0x4e>
	int neg = 0;
  800a51:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a56:	3c 2d                	cmp    $0x2d,%al
  800a58:	74 2f                	je     800a89 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a60:	75 05                	jne    800a67 <strtol+0x36>
  800a62:	80 39 30             	cmpb   $0x30,(%ecx)
  800a65:	74 2c                	je     800a93 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a67:	85 db                	test   %ebx,%ebx
  800a69:	75 0a                	jne    800a75 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6b:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a70:	80 39 30             	cmpb   $0x30,(%ecx)
  800a73:	74 28                	je     800a9d <strtol+0x6c>
		base = 10;
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a7d:	eb 50                	jmp    800acf <strtol+0x9e>
		s++;
  800a7f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a82:	bf 00 00 00 00       	mov    $0x0,%edi
  800a87:	eb d1                	jmp    800a5a <strtol+0x29>
		s++, neg = 1;
  800a89:	83 c1 01             	add    $0x1,%ecx
  800a8c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a91:	eb c7                	jmp    800a5a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a93:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a97:	74 0e                	je     800aa7 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a99:	85 db                	test   %ebx,%ebx
  800a9b:	75 d8                	jne    800a75 <strtol+0x44>
		s++, base = 8;
  800a9d:	83 c1 01             	add    $0x1,%ecx
  800aa0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aa5:	eb ce                	jmp    800a75 <strtol+0x44>
		s += 2, base = 16;
  800aa7:	83 c1 02             	add    $0x2,%ecx
  800aaa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aaf:	eb c4                	jmp    800a75 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ab1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	80 fb 19             	cmp    $0x19,%bl
  800ab9:	77 29                	ja     800ae4 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800abb:	0f be d2             	movsbl %dl,%edx
  800abe:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac4:	7d 30                	jge    800af6 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ac6:	83 c1 01             	add    $0x1,%ecx
  800ac9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800acd:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800acf:	0f b6 11             	movzbl (%ecx),%edx
  800ad2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad5:	89 f3                	mov    %esi,%ebx
  800ad7:	80 fb 09             	cmp    $0x9,%bl
  800ada:	77 d5                	ja     800ab1 <strtol+0x80>
			dig = *s - '0';
  800adc:	0f be d2             	movsbl %dl,%edx
  800adf:	83 ea 30             	sub    $0x30,%edx
  800ae2:	eb dd                	jmp    800ac1 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ae4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae7:	89 f3                	mov    %esi,%ebx
  800ae9:	80 fb 19             	cmp    $0x19,%bl
  800aec:	77 08                	ja     800af6 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aee:	0f be d2             	movsbl %dl,%edx
  800af1:	83 ea 37             	sub    $0x37,%edx
  800af4:	eb cb                	jmp    800ac1 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800af6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afa:	74 05                	je     800b01 <strtol+0xd0>
		*endptr = (char *) s;
  800afc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aff:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b01:	89 c2                	mov    %eax,%edx
  800b03:	f7 da                	neg    %edx
  800b05:	85 ff                	test   %edi,%edi
  800b07:	0f 45 c2             	cmovne %edx,%eax
}
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	5f                   	pop    %edi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b15:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b20:	89 c3                	mov    %eax,%ebx
  800b22:	89 c7                	mov    %eax,%edi
  800b24:	89 c6                	mov    %eax,%esi
  800b26:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b33:	ba 00 00 00 00       	mov    $0x0,%edx
  800b38:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3d:	89 d1                	mov    %edx,%ecx
  800b3f:	89 d3                	mov    %edx,%ebx
  800b41:	89 d7                	mov    %edx,%edi
  800b43:	89 d6                	mov    %edx,%esi
  800b45:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b47:	5b                   	pop    %ebx
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	83 ec 1c             	sub    $0x1c,%esp
  800b55:	e8 66 00 00 00       	call   800bc0 <__x86.get_pc_thunk.ax>
  800b5a:	05 a6 14 00 00       	add    $0x14a6,%eax
  800b5f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b67:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6f:	89 cb                	mov    %ecx,%ebx
  800b71:	89 cf                	mov    %ecx,%edi
  800b73:	89 ce                	mov    %ecx,%esi
  800b75:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b77:	85 c0                	test   %eax,%eax
  800b79:	7f 08                	jg     800b83 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	50                   	push   %eax
  800b87:	6a 03                	push   $0x3
  800b89:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800b8c:	8d 83 70 f0 ff ff    	lea    -0xf90(%ebx),%eax
  800b92:	50                   	push   %eax
  800b93:	6a 23                	push   $0x23
  800b95:	8d 83 8d f0 ff ff    	lea    -0xf73(%ebx),%eax
  800b9b:	50                   	push   %eax
  800b9c:	e8 23 00 00 00       	call   800bc4 <_panic>

00800ba1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bac:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb1:	89 d1                	mov    %edx,%ecx
  800bb3:	89 d3                	mov    %edx,%ebx
  800bb5:	89 d7                	mov    %edx,%edi
  800bb7:	89 d6                	mov    %edx,%esi
  800bb9:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <__x86.get_pc_thunk.ax>:
  800bc0:	8b 04 24             	mov    (%esp),%eax
  800bc3:	c3                   	ret    

00800bc4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	83 ec 0c             	sub    $0xc,%esp
  800bcd:	e8 a2 f4 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800bd2:	81 c3 2e 14 00 00    	add    $0x142e,%ebx
	va_list ap;

	va_start(ap, fmt);
  800bd8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bdb:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800be1:	8b 38                	mov    (%eax),%edi
  800be3:	e8 b9 ff ff ff       	call   800ba1 <sys_getenvid>
  800be8:	83 ec 0c             	sub    $0xc,%esp
  800beb:	ff 75 0c             	pushl  0xc(%ebp)
  800bee:	ff 75 08             	pushl  0x8(%ebp)
  800bf1:	57                   	push   %edi
  800bf2:	50                   	push   %eax
  800bf3:	8d 83 9c f0 ff ff    	lea    -0xf64(%ebx),%eax
  800bf9:	50                   	push   %eax
  800bfa:	e8 a9 f5 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bff:	83 c4 18             	add    $0x18,%esp
  800c02:	56                   	push   %esi
  800c03:	ff 75 10             	pushl  0x10(%ebp)
  800c06:	e8 3b f5 ff ff       	call   800146 <vcprintf>
	cprintf("\n");
  800c0b:	8d 83 68 ee ff ff    	lea    -0x1198(%ebx),%eax
  800c11:	89 04 24             	mov    %eax,(%esp)
  800c14:	e8 8f f5 ff ff       	call   8001a8 <cprintf>
  800c19:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c1c:	cc                   	int3   
  800c1d:	eb fd                	jmp    800c1c <_panic+0x58>
  800c1f:	90                   	nop

00800c20 <__udivdi3>:
  800c20:	55                   	push   %ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 1c             	sub    $0x1c,%esp
  800c27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c2b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c33:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c37:	85 d2                	test   %edx,%edx
  800c39:	75 35                	jne    800c70 <__udivdi3+0x50>
  800c3b:	39 f3                	cmp    %esi,%ebx
  800c3d:	0f 87 bd 00 00 00    	ja     800d00 <__udivdi3+0xe0>
  800c43:	85 db                	test   %ebx,%ebx
  800c45:	89 d9                	mov    %ebx,%ecx
  800c47:	75 0b                	jne    800c54 <__udivdi3+0x34>
  800c49:	b8 01 00 00 00       	mov    $0x1,%eax
  800c4e:	31 d2                	xor    %edx,%edx
  800c50:	f7 f3                	div    %ebx
  800c52:	89 c1                	mov    %eax,%ecx
  800c54:	31 d2                	xor    %edx,%edx
  800c56:	89 f0                	mov    %esi,%eax
  800c58:	f7 f1                	div    %ecx
  800c5a:	89 c6                	mov    %eax,%esi
  800c5c:	89 e8                	mov    %ebp,%eax
  800c5e:	89 f7                	mov    %esi,%edi
  800c60:	f7 f1                	div    %ecx
  800c62:	89 fa                	mov    %edi,%edx
  800c64:	83 c4 1c             	add    $0x1c,%esp
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    
  800c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c70:	39 f2                	cmp    %esi,%edx
  800c72:	77 7c                	ja     800cf0 <__udivdi3+0xd0>
  800c74:	0f bd fa             	bsr    %edx,%edi
  800c77:	83 f7 1f             	xor    $0x1f,%edi
  800c7a:	0f 84 98 00 00 00    	je     800d18 <__udivdi3+0xf8>
  800c80:	89 f9                	mov    %edi,%ecx
  800c82:	b8 20 00 00 00       	mov    $0x20,%eax
  800c87:	29 f8                	sub    %edi,%eax
  800c89:	d3 e2                	shl    %cl,%edx
  800c8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c8f:	89 c1                	mov    %eax,%ecx
  800c91:	89 da                	mov    %ebx,%edx
  800c93:	d3 ea                	shr    %cl,%edx
  800c95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c99:	09 d1                	or     %edx,%ecx
  800c9b:	89 f2                	mov    %esi,%edx
  800c9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ca1:	89 f9                	mov    %edi,%ecx
  800ca3:	d3 e3                	shl    %cl,%ebx
  800ca5:	89 c1                	mov    %eax,%ecx
  800ca7:	d3 ea                	shr    %cl,%edx
  800ca9:	89 f9                	mov    %edi,%ecx
  800cab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800caf:	d3 e6                	shl    %cl,%esi
  800cb1:	89 eb                	mov    %ebp,%ebx
  800cb3:	89 c1                	mov    %eax,%ecx
  800cb5:	d3 eb                	shr    %cl,%ebx
  800cb7:	09 de                	or     %ebx,%esi
  800cb9:	89 f0                	mov    %esi,%eax
  800cbb:	f7 74 24 08          	divl   0x8(%esp)
  800cbf:	89 d6                	mov    %edx,%esi
  800cc1:	89 c3                	mov    %eax,%ebx
  800cc3:	f7 64 24 0c          	mull   0xc(%esp)
  800cc7:	39 d6                	cmp    %edx,%esi
  800cc9:	72 0c                	jb     800cd7 <__udivdi3+0xb7>
  800ccb:	89 f9                	mov    %edi,%ecx
  800ccd:	d3 e5                	shl    %cl,%ebp
  800ccf:	39 c5                	cmp    %eax,%ebp
  800cd1:	73 5d                	jae    800d30 <__udivdi3+0x110>
  800cd3:	39 d6                	cmp    %edx,%esi
  800cd5:	75 59                	jne    800d30 <__udivdi3+0x110>
  800cd7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cda:	31 ff                	xor    %edi,%edi
  800cdc:	89 fa                	mov    %edi,%edx
  800cde:	83 c4 1c             	add    $0x1c,%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    
  800ce6:	8d 76 00             	lea    0x0(%esi),%esi
  800ce9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800cf0:	31 ff                	xor    %edi,%edi
  800cf2:	31 c0                	xor    %eax,%eax
  800cf4:	89 fa                	mov    %edi,%edx
  800cf6:	83 c4 1c             	add    $0x1c,%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    
  800cfe:	66 90                	xchg   %ax,%ax
  800d00:	31 ff                	xor    %edi,%edi
  800d02:	89 e8                	mov    %ebp,%eax
  800d04:	89 f2                	mov    %esi,%edx
  800d06:	f7 f3                	div    %ebx
  800d08:	89 fa                	mov    %edi,%edx
  800d0a:	83 c4 1c             	add    $0x1c,%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    
  800d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d18:	39 f2                	cmp    %esi,%edx
  800d1a:	72 06                	jb     800d22 <__udivdi3+0x102>
  800d1c:	31 c0                	xor    %eax,%eax
  800d1e:	39 eb                	cmp    %ebp,%ebx
  800d20:	77 d2                	ja     800cf4 <__udivdi3+0xd4>
  800d22:	b8 01 00 00 00       	mov    $0x1,%eax
  800d27:	eb cb                	jmp    800cf4 <__udivdi3+0xd4>
  800d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d30:	89 d8                	mov    %ebx,%eax
  800d32:	31 ff                	xor    %edi,%edi
  800d34:	eb be                	jmp    800cf4 <__udivdi3+0xd4>
  800d36:	66 90                	xchg   %ax,%ax
  800d38:	66 90                	xchg   %ax,%ax
  800d3a:	66 90                	xchg   %ax,%ax
  800d3c:	66 90                	xchg   %ax,%ax
  800d3e:	66 90                	xchg   %ax,%ax

00800d40 <__umoddi3>:
  800d40:	55                   	push   %ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 1c             	sub    $0x1c,%esp
  800d47:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d4b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d4f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d57:	85 ed                	test   %ebp,%ebp
  800d59:	89 f0                	mov    %esi,%eax
  800d5b:	89 da                	mov    %ebx,%edx
  800d5d:	75 19                	jne    800d78 <__umoddi3+0x38>
  800d5f:	39 df                	cmp    %ebx,%edi
  800d61:	0f 86 b1 00 00 00    	jbe    800e18 <__umoddi3+0xd8>
  800d67:	f7 f7                	div    %edi
  800d69:	89 d0                	mov    %edx,%eax
  800d6b:	31 d2                	xor    %edx,%edx
  800d6d:	83 c4 1c             	add    $0x1c,%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    
  800d75:	8d 76 00             	lea    0x0(%esi),%esi
  800d78:	39 dd                	cmp    %ebx,%ebp
  800d7a:	77 f1                	ja     800d6d <__umoddi3+0x2d>
  800d7c:	0f bd cd             	bsr    %ebp,%ecx
  800d7f:	83 f1 1f             	xor    $0x1f,%ecx
  800d82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d86:	0f 84 b4 00 00 00    	je     800e40 <__umoddi3+0x100>
  800d8c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d97:	29 c2                	sub    %eax,%edx
  800d99:	89 c1                	mov    %eax,%ecx
  800d9b:	89 f8                	mov    %edi,%eax
  800d9d:	d3 e5                	shl    %cl,%ebp
  800d9f:	89 d1                	mov    %edx,%ecx
  800da1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800da5:	d3 e8                	shr    %cl,%eax
  800da7:	09 c5                	or     %eax,%ebp
  800da9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dad:	89 c1                	mov    %eax,%ecx
  800daf:	d3 e7                	shl    %cl,%edi
  800db1:	89 d1                	mov    %edx,%ecx
  800db3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800db7:	89 df                	mov    %ebx,%edi
  800db9:	d3 ef                	shr    %cl,%edi
  800dbb:	89 c1                	mov    %eax,%ecx
  800dbd:	89 f0                	mov    %esi,%eax
  800dbf:	d3 e3                	shl    %cl,%ebx
  800dc1:	89 d1                	mov    %edx,%ecx
  800dc3:	89 fa                	mov    %edi,%edx
  800dc5:	d3 e8                	shr    %cl,%eax
  800dc7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dcc:	09 d8                	or     %ebx,%eax
  800dce:	f7 f5                	div    %ebp
  800dd0:	d3 e6                	shl    %cl,%esi
  800dd2:	89 d1                	mov    %edx,%ecx
  800dd4:	f7 64 24 08          	mull   0x8(%esp)
  800dd8:	39 d1                	cmp    %edx,%ecx
  800dda:	89 c3                	mov    %eax,%ebx
  800ddc:	89 d7                	mov    %edx,%edi
  800dde:	72 06                	jb     800de6 <__umoddi3+0xa6>
  800de0:	75 0e                	jne    800df0 <__umoddi3+0xb0>
  800de2:	39 c6                	cmp    %eax,%esi
  800de4:	73 0a                	jae    800df0 <__umoddi3+0xb0>
  800de6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800dea:	19 ea                	sbb    %ebp,%edx
  800dec:	89 d7                	mov    %edx,%edi
  800dee:	89 c3                	mov    %eax,%ebx
  800df0:	89 ca                	mov    %ecx,%edx
  800df2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800df7:	29 de                	sub    %ebx,%esi
  800df9:	19 fa                	sbb    %edi,%edx
  800dfb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800dff:	89 d0                	mov    %edx,%eax
  800e01:	d3 e0                	shl    %cl,%eax
  800e03:	89 d9                	mov    %ebx,%ecx
  800e05:	d3 ee                	shr    %cl,%esi
  800e07:	d3 ea                	shr    %cl,%edx
  800e09:	09 f0                	or     %esi,%eax
  800e0b:	83 c4 1c             	add    $0x1c,%esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    
  800e13:	90                   	nop
  800e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e18:	85 ff                	test   %edi,%edi
  800e1a:	89 f9                	mov    %edi,%ecx
  800e1c:	75 0b                	jne    800e29 <__umoddi3+0xe9>
  800e1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e23:	31 d2                	xor    %edx,%edx
  800e25:	f7 f7                	div    %edi
  800e27:	89 c1                	mov    %eax,%ecx
  800e29:	89 d8                	mov    %ebx,%eax
  800e2b:	31 d2                	xor    %edx,%edx
  800e2d:	f7 f1                	div    %ecx
  800e2f:	89 f0                	mov    %esi,%eax
  800e31:	f7 f1                	div    %ecx
  800e33:	e9 31 ff ff ff       	jmp    800d69 <__umoddi3+0x29>
  800e38:	90                   	nop
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	39 dd                	cmp    %ebx,%ebp
  800e42:	72 08                	jb     800e4c <__umoddi3+0x10c>
  800e44:	39 f7                	cmp    %esi,%edi
  800e46:	0f 87 21 ff ff ff    	ja     800d6d <__umoddi3+0x2d>
  800e4c:	89 da                	mov    %ebx,%edx
  800e4e:	89 f0                	mov    %esi,%eax
  800e50:	29 f8                	sub    %edi,%eax
  800e52:	19 ea                	sbb    %ebp,%edx
  800e54:	e9 14 ff ff ff       	jmp    800d6d <__umoddi3+0x2d>
