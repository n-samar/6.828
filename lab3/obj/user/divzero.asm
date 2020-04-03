
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 46 00 00 00       	call   800077 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 34 00 00 00       	call   800073 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	zero = 0;
  800045:	c7 c0 2c 20 80 00    	mov    $0x80202c,%eax
  80004b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	cprintf("1/0 is %08x!\n", 1/zero);
  800051:	b8 01 00 00 00       	mov    $0x1,%eax
  800056:	b9 00 00 00 00       	mov    $0x0,%ecx
  80005b:	99                   	cltd   
  80005c:	f7 f9                	idiv   %ecx
  80005e:	50                   	push   %eax
  80005f:	8d 83 5c ee ff ff    	lea    -0x11a4(%ebx),%eax
  800065:	50                   	push   %eax
  800066:	e8 3c 01 00 00       	call   8001a7 <cprintf>
}
  80006b:	83 c4 10             	add    $0x10,%esp
  80006e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800071:	c9                   	leave  
  800072:	c3                   	ret    

00800073 <__x86.get_pc_thunk.bx>:
  800073:	8b 1c 24             	mov    (%esp),%ebx
  800076:	c3                   	ret    

00800077 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800077:	55                   	push   %ebp
  800078:	89 e5                	mov    %esp,%ebp
  80007a:	57                   	push   %edi
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	83 ec 0c             	sub    $0xc,%esp
  800080:	e8 ee ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800085:	81 c3 7b 1f 00 00    	add    $0x1f7b,%ebx
  80008b:	8b 75 08             	mov    0x8(%ebp),%esi
  80008e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

	thisenv = envs+ENVX(sys_getenvid());
  800091:	e8 0a 0b 00 00       	call   800ba0 <sys_getenvid>
  800096:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009b:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80009e:	c1 e0 05             	shl    $0x5,%eax
  8000a1:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  8000a7:	c7 c2 30 20 80 00    	mov    $0x802030,%edx
  8000ad:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000af:	85 f6                	test   %esi,%esi
  8000b1:	7e 08                	jle    8000bb <libmain+0x44>
		binaryname = argv[0];
  8000b3:	8b 07                	mov    (%edi),%eax
  8000b5:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	57                   	push   %edi
  8000bf:	56                   	push   %esi
  8000c0:	e8 6e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c5:	e8 0b 00 00 00       	call   8000d5 <exit>
}
  8000ca:	83 c4 10             	add    $0x10,%esp
  8000cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d0:	5b                   	pop    %ebx
  8000d1:	5e                   	pop    %esi
  8000d2:	5f                   	pop    %edi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    

008000d5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 10             	sub    $0x10,%esp
  8000dc:	e8 92 ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8000e1:	81 c3 1f 1f 00 00    	add    $0x1f1f,%ebx
	sys_env_destroy(0);
  8000e7:	6a 00                	push   $0x0
  8000e9:	e8 5d 0a 00 00       	call   800b4b <sys_env_destroy>
}
  8000ee:	83 c4 10             	add    $0x10,%esp
  8000f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f4:	c9                   	leave  
  8000f5:	c3                   	ret    

008000f6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
  8000fb:	e8 73 ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800100:	81 c3 00 1f 00 00    	add    $0x1f00,%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800109:	8b 16                	mov    (%esi),%edx
  80010b:	8d 42 01             	lea    0x1(%edx),%eax
  80010e:	89 06                	mov    %eax,(%esi)
  800110:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800113:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800117:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011c:	74 0b                	je     800129 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80011e:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	68 ff 00 00 00       	push   $0xff
  800131:	8d 46 08             	lea    0x8(%esi),%eax
  800134:	50                   	push   %eax
  800135:	e8 d4 09 00 00       	call   800b0e <sys_cputs>
		b->idx = 0;
  80013a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	eb d9                	jmp    80011e <putch+0x28>

00800145 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	53                   	push   %ebx
  800149:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80014f:	e8 1f ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800154:	81 c3 ac 1e 00 00    	add    $0x1eac,%ebx
	struct printbuf b;

	b.idx = 0;
  80015a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800161:	00 00 00 
	b.cnt = 0;
  800164:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017a:	50                   	push   %eax
  80017b:	8d 83 f6 e0 ff ff    	lea    -0x1f0a(%ebx),%eax
  800181:	50                   	push   %eax
  800182:	e8 38 01 00 00       	call   8002bf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800187:	83 c4 08             	add    $0x8,%esp
  80018a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800190:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800196:	50                   	push   %eax
  800197:	e8 72 09 00 00       	call   800b0e <sys_cputs>

	return b.cnt;
}
  80019c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ad:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b0:	50                   	push   %eax
  8001b1:	ff 75 08             	pushl  0x8(%ebp)
  8001b4:	e8 8c ff ff ff       	call   800145 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	57                   	push   %edi
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 2c             	sub    $0x2c,%esp
  8001c4:	e8 cd 05 00 00       	call   800796 <__x86.get_pc_thunk.cx>
  8001c9:	81 c1 37 1e 00 00    	add    $0x1e37,%ecx
  8001cf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001d2:	89 c7                	mov    %eax,%edi
  8001d4:	89 d6                	mov    %edx,%esi
  8001d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001df:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ea:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001ed:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001f0:	39 d3                	cmp    %edx,%ebx
  8001f2:	72 09                	jb     8001fd <printnum+0x42>
  8001f4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f7:	0f 87 83 00 00 00    	ja     800280 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	ff 75 18             	pushl  0x18(%ebp)
  800203:	8b 45 14             	mov    0x14(%ebp),%eax
  800206:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800209:	53                   	push   %ebx
  80020a:	ff 75 10             	pushl  0x10(%ebp)
  80020d:	83 ec 08             	sub    $0x8,%esp
  800210:	ff 75 dc             	pushl  -0x24(%ebp)
  800213:	ff 75 d8             	pushl  -0x28(%ebp)
  800216:	ff 75 d4             	pushl  -0x2c(%ebp)
  800219:	ff 75 d0             	pushl  -0x30(%ebp)
  80021c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80021f:	e8 fc 09 00 00       	call   800c20 <__udivdi3>
  800224:	83 c4 18             	add    $0x18,%esp
  800227:	52                   	push   %edx
  800228:	50                   	push   %eax
  800229:	89 f2                	mov    %esi,%edx
  80022b:	89 f8                	mov    %edi,%eax
  80022d:	e8 89 ff ff ff       	call   8001bb <printnum>
  800232:	83 c4 20             	add    $0x20,%esp
  800235:	eb 13                	jmp    80024a <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800237:	83 ec 08             	sub    $0x8,%esp
  80023a:	56                   	push   %esi
  80023b:	ff 75 18             	pushl  0x18(%ebp)
  80023e:	ff d7                	call   *%edi
  800240:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800243:	83 eb 01             	sub    $0x1,%ebx
  800246:	85 db                	test   %ebx,%ebx
  800248:	7f ed                	jg     800237 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	56                   	push   %esi
  80024e:	83 ec 04             	sub    $0x4,%esp
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	ff 75 d4             	pushl  -0x2c(%ebp)
  80025a:	ff 75 d0             	pushl  -0x30(%ebp)
  80025d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800260:	89 f3                	mov    %esi,%ebx
  800262:	e8 d9 0a 00 00       	call   800d40 <__umoddi3>
  800267:	83 c4 14             	add    $0x14,%esp
  80026a:	0f be 84 06 74 ee ff 	movsbl -0x118c(%esi,%eax,1),%eax
  800271:	ff 
  800272:	50                   	push   %eax
  800273:	ff d7                	call   *%edi
}
  800275:	83 c4 10             	add    $0x10,%esp
  800278:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027b:	5b                   	pop    %ebx
  80027c:	5e                   	pop    %esi
  80027d:	5f                   	pop    %edi
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    
  800280:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800283:	eb be                	jmp    800243 <printnum+0x88>

00800285 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	3b 50 04             	cmp    0x4(%eax),%edx
  800294:	73 0a                	jae    8002a0 <sprintputch+0x1b>
		*b->buf++ = ch;
  800296:	8d 4a 01             	lea    0x1(%edx),%ecx
  800299:	89 08                	mov    %ecx,(%eax)
  80029b:	8b 45 08             	mov    0x8(%ebp),%eax
  80029e:	88 02                	mov    %al,(%edx)
}
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    

008002a2 <printfmt>:
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ab:	50                   	push   %eax
  8002ac:	ff 75 10             	pushl  0x10(%ebp)
  8002af:	ff 75 0c             	pushl  0xc(%ebp)
  8002b2:	ff 75 08             	pushl  0x8(%ebp)
  8002b5:	e8 05 00 00 00       	call   8002bf <vprintfmt>
}
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	c9                   	leave  
  8002be:	c3                   	ret    

008002bf <vprintfmt>:
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	57                   	push   %edi
  8002c3:	56                   	push   %esi
  8002c4:	53                   	push   %ebx
  8002c5:	83 ec 2c             	sub    $0x2c,%esp
  8002c8:	e8 a6 fd ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8002cd:	81 c3 33 1d 00 00    	add    $0x1d33,%ebx
  8002d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002d6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d9:	e9 8e 03 00 00       	jmp    80066c <.L35+0x48>
		padc = ' ';
  8002de:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002e2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002e9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002f0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fc:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002ff:	8d 47 01             	lea    0x1(%edi),%eax
  800302:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800305:	0f b6 17             	movzbl (%edi),%edx
  800308:	8d 42 dd             	lea    -0x23(%edx),%eax
  80030b:	3c 55                	cmp    $0x55,%al
  80030d:	0f 87 e1 03 00 00    	ja     8006f4 <.L22>
  800313:	0f b6 c0             	movzbl %al,%eax
  800316:	89 d9                	mov    %ebx,%ecx
  800318:	03 8c 83 04 ef ff ff 	add    -0x10fc(%ebx,%eax,4),%ecx
  80031f:	ff e1                	jmp    *%ecx

00800321 <.L67>:
  800321:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800324:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800328:	eb d5                	jmp    8002ff <vprintfmt+0x40>

0080032a <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80032d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800331:	eb cc                	jmp    8002ff <vprintfmt+0x40>

00800333 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800333:	0f b6 d2             	movzbl %dl,%edx
  800336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800339:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80033e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800341:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800345:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800348:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80034b:	83 f9 09             	cmp    $0x9,%ecx
  80034e:	77 55                	ja     8003a5 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  800350:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800353:	eb e9                	jmp    80033e <.L29+0xb>

00800355 <.L26>:
			precision = va_arg(ap, int);
  800355:	8b 45 14             	mov    0x14(%ebp),%eax
  800358:	8b 00                	mov    (%eax),%eax
  80035a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80035d:	8b 45 14             	mov    0x14(%ebp),%eax
  800360:	8d 40 04             	lea    0x4(%eax),%eax
  800363:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800369:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036d:	79 90                	jns    8002ff <vprintfmt+0x40>
				width = precision, precision = -1;
  80036f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800372:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800375:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037c:	eb 81                	jmp    8002ff <vprintfmt+0x40>

0080037e <.L27>:
  80037e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800381:	85 c0                	test   %eax,%eax
  800383:	ba 00 00 00 00       	mov    $0x0,%edx
  800388:	0f 49 d0             	cmovns %eax,%edx
  80038b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800391:	e9 69 ff ff ff       	jmp    8002ff <vprintfmt+0x40>

00800396 <.L23>:
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800399:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a0:	e9 5a ff ff ff       	jmp    8002ff <vprintfmt+0x40>
  8003a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003a8:	eb bf                	jmp    800369 <.L26+0x14>

008003aa <.L33>:
			lflag++;
  8003aa:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b1:	e9 49 ff ff ff       	jmp    8002ff <vprintfmt+0x40>

008003b6 <.L30>:
			putch(va_arg(ap, int), putdat);
  8003b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b9:	8d 78 04             	lea    0x4(%eax),%edi
  8003bc:	83 ec 08             	sub    $0x8,%esp
  8003bf:	56                   	push   %esi
  8003c0:	ff 30                	pushl  (%eax)
  8003c2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003c5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003c8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003cb:	e9 99 02 00 00       	jmp    800669 <.L35+0x45>

008003d0 <.L32>:
			err = va_arg(ap, int);
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 78 04             	lea    0x4(%eax),%edi
  8003d6:	8b 00                	mov    (%eax),%eax
  8003d8:	99                   	cltd   
  8003d9:	31 d0                	xor    %edx,%eax
  8003db:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003dd:	83 f8 06             	cmp    $0x6,%eax
  8003e0:	7f 27                	jg     800409 <.L32+0x39>
  8003e2:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8003e9:	85 d2                	test   %edx,%edx
  8003eb:	74 1c                	je     800409 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8003ed:	52                   	push   %edx
  8003ee:	8d 83 95 ee ff ff    	lea    -0x116b(%ebx),%eax
  8003f4:	50                   	push   %eax
  8003f5:	56                   	push   %esi
  8003f6:	ff 75 08             	pushl  0x8(%ebp)
  8003f9:	e8 a4 fe ff ff       	call   8002a2 <printfmt>
  8003fe:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800401:	89 7d 14             	mov    %edi,0x14(%ebp)
  800404:	e9 60 02 00 00       	jmp    800669 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  800409:	50                   	push   %eax
  80040a:	8d 83 8c ee ff ff    	lea    -0x1174(%ebx),%eax
  800410:	50                   	push   %eax
  800411:	56                   	push   %esi
  800412:	ff 75 08             	pushl  0x8(%ebp)
  800415:	e8 88 fe ff ff       	call   8002a2 <printfmt>
  80041a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800420:	e9 44 02 00 00       	jmp    800669 <.L35+0x45>

00800425 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	83 c0 04             	add    $0x4,%eax
  80042b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800433:	85 ff                	test   %edi,%edi
  800435:	8d 83 85 ee ff ff    	lea    -0x117b(%ebx),%eax
  80043b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80043e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800442:	0f 8e b5 00 00 00    	jle    8004fd <.L36+0xd8>
  800448:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80044c:	75 08                	jne    800456 <.L36+0x31>
  80044e:	89 75 0c             	mov    %esi,0xc(%ebp)
  800451:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800454:	eb 6d                	jmp    8004c3 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	ff 75 d0             	pushl  -0x30(%ebp)
  80045c:	57                   	push   %edi
  80045d:	e8 50 03 00 00       	call   8007b2 <strnlen>
  800462:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800465:	29 c2                	sub    %eax,%edx
  800467:	89 55 c8             	mov    %edx,-0x38(%ebp)
  80046a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800471:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800474:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800477:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800479:	eb 10                	jmp    80048b <.L36+0x66>
					putch(padc, putdat);
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	56                   	push   %esi
  80047f:	ff 75 e0             	pushl  -0x20(%ebp)
  800482:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800485:	83 ef 01             	sub    $0x1,%edi
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	85 ff                	test   %edi,%edi
  80048d:	7f ec                	jg     80047b <.L36+0x56>
  80048f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800492:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800495:	85 d2                	test   %edx,%edx
  800497:	b8 00 00 00 00       	mov    $0x0,%eax
  80049c:	0f 49 c2             	cmovns %edx,%eax
  80049f:	29 c2                	sub    %eax,%edx
  8004a1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a4:	89 75 0c             	mov    %esi,0xc(%ebp)
  8004a7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004aa:	eb 17                	jmp    8004c3 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b0:	75 30                	jne    8004e2 <.L36+0xbd>
					putch(ch, putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	ff 75 0c             	pushl  0xc(%ebp)
  8004b8:	50                   	push   %eax
  8004b9:	ff 55 08             	call   *0x8(%ebp)
  8004bc:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bf:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004c3:	83 c7 01             	add    $0x1,%edi
  8004c6:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004ca:	0f be c2             	movsbl %dl,%eax
  8004cd:	85 c0                	test   %eax,%eax
  8004cf:	74 52                	je     800523 <.L36+0xfe>
  8004d1:	85 f6                	test   %esi,%esi
  8004d3:	78 d7                	js     8004ac <.L36+0x87>
  8004d5:	83 ee 01             	sub    $0x1,%esi
  8004d8:	79 d2                	jns    8004ac <.L36+0x87>
  8004da:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004dd:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004e0:	eb 32                	jmp    800514 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e2:	0f be d2             	movsbl %dl,%edx
  8004e5:	83 ea 20             	sub    $0x20,%edx
  8004e8:	83 fa 5e             	cmp    $0x5e,%edx
  8004eb:	76 c5                	jbe    8004b2 <.L36+0x8d>
					putch('?', putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	ff 75 0c             	pushl  0xc(%ebp)
  8004f3:	6a 3f                	push   $0x3f
  8004f5:	ff 55 08             	call   *0x8(%ebp)
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	eb c2                	jmp    8004bf <.L36+0x9a>
  8004fd:	89 75 0c             	mov    %esi,0xc(%ebp)
  800500:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800503:	eb be                	jmp    8004c3 <.L36+0x9e>
				putch(' ', putdat);
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	56                   	push   %esi
  800509:	6a 20                	push   $0x20
  80050b:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80050e:	83 ef 01             	sub    $0x1,%edi
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	85 ff                	test   %edi,%edi
  800516:	7f ed                	jg     800505 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800518:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80051b:	89 45 14             	mov    %eax,0x14(%ebp)
  80051e:	e9 46 01 00 00       	jmp    800669 <.L35+0x45>
  800523:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800526:	8b 75 0c             	mov    0xc(%ebp),%esi
  800529:	eb e9                	jmp    800514 <.L36+0xef>

0080052b <.L31>:
  80052b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  80052e:	83 f9 01             	cmp    $0x1,%ecx
  800531:	7e 40                	jle    800573 <.L31+0x48>
		return va_arg(*ap, long long);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8b 50 04             	mov    0x4(%eax),%edx
  800539:	8b 00                	mov    (%eax),%eax
  80053b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8d 40 08             	lea    0x8(%eax),%eax
  800547:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80054a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80054e:	79 55                	jns    8005a5 <.L31+0x7a>
				putch('-', putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	56                   	push   %esi
  800554:	6a 2d                	push   $0x2d
  800556:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800559:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055f:	f7 da                	neg    %edx
  800561:	83 d1 00             	adc    $0x0,%ecx
  800564:	f7 d9                	neg    %ecx
  800566:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800569:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056e:	e9 db 00 00 00       	jmp    80064e <.L35+0x2a>
	else if (lflag)
  800573:	85 c9                	test   %ecx,%ecx
  800575:	75 17                	jne    80058e <.L31+0x63>
		return va_arg(*ap, int);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057f:	99                   	cltd   
  800580:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 40 04             	lea    0x4(%eax),%eax
  800589:	89 45 14             	mov    %eax,0x14(%ebp)
  80058c:	eb bc                	jmp    80054a <.L31+0x1f>
		return va_arg(*ap, long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8b 00                	mov    (%eax),%eax
  800593:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800596:	99                   	cltd   
  800597:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 40 04             	lea    0x4(%eax),%eax
  8005a0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a3:	eb a5                	jmp    80054a <.L31+0x1f>
			num = getint(&ap, lflag);
  8005a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ab:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b0:	e9 99 00 00 00       	jmp    80064e <.L35+0x2a>

008005b5 <.L37>:
  8005b5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  8005b8:	83 f9 01             	cmp    $0x1,%ecx
  8005bb:	7e 15                	jle    8005d2 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8b 10                	mov    (%eax),%edx
  8005c2:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c5:	8d 40 08             	lea    0x8(%eax),%eax
  8005c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d0:	eb 7c                	jmp    80064e <.L35+0x2a>
	else if (lflag)
  8005d2:	85 c9                	test   %ecx,%ecx
  8005d4:	75 17                	jne    8005ed <.L37+0x38>
		return va_arg(*ap, unsigned int);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8b 10                	mov    (%eax),%edx
  8005db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e0:	8d 40 04             	lea    0x4(%eax),%eax
  8005e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005eb:	eb 61                	jmp    80064e <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8b 10                	mov    (%eax),%edx
  8005f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f7:	8d 40 04             	lea    0x4(%eax),%eax
  8005fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800602:	eb 4a                	jmp    80064e <.L35+0x2a>

00800604 <.L34>:
			putch('X', putdat);
  800604:	83 ec 08             	sub    $0x8,%esp
  800607:	56                   	push   %esi
  800608:	6a 58                	push   $0x58
  80060a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	56                   	push   %esi
  800611:	6a 58                	push   $0x58
  800613:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800616:	83 c4 08             	add    $0x8,%esp
  800619:	56                   	push   %esi
  80061a:	6a 58                	push   $0x58
  80061c:	ff 55 08             	call   *0x8(%ebp)
			break;
  80061f:	83 c4 10             	add    $0x10,%esp
  800622:	eb 45                	jmp    800669 <.L35+0x45>

00800624 <.L35>:
			putch('0', putdat);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	56                   	push   %esi
  800628:	6a 30                	push   $0x30
  80062a:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80062d:	83 c4 08             	add    $0x8,%esp
  800630:	56                   	push   %esi
  800631:	6a 78                	push   $0x78
  800633:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8b 10                	mov    (%eax),%edx
  80063b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800640:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800643:	8d 40 04             	lea    0x4(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800649:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80064e:	83 ec 0c             	sub    $0xc,%esp
  800651:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800655:	57                   	push   %edi
  800656:	ff 75 e0             	pushl  -0x20(%ebp)
  800659:	50                   	push   %eax
  80065a:	51                   	push   %ecx
  80065b:	52                   	push   %edx
  80065c:	89 f2                	mov    %esi,%edx
  80065e:	8b 45 08             	mov    0x8(%ebp),%eax
  800661:	e8 55 fb ff ff       	call   8001bb <printnum>
			break;
  800666:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800669:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80066c:	83 c7 01             	add    $0x1,%edi
  80066f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800673:	83 f8 25             	cmp    $0x25,%eax
  800676:	0f 84 62 fc ff ff    	je     8002de <vprintfmt+0x1f>
			if (ch == '\0')
  80067c:	85 c0                	test   %eax,%eax
  80067e:	0f 84 91 00 00 00    	je     800715 <.L22+0x21>
			putch(ch, putdat);
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	56                   	push   %esi
  800688:	50                   	push   %eax
  800689:	ff 55 08             	call   *0x8(%ebp)
  80068c:	83 c4 10             	add    $0x10,%esp
  80068f:	eb db                	jmp    80066c <.L35+0x48>

00800691 <.L38>:
  800691:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  800694:	83 f9 01             	cmp    $0x1,%ecx
  800697:	7e 15                	jle    8006ae <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a1:	8d 40 08             	lea    0x8(%eax),%eax
  8006a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a7:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ac:	eb a0                	jmp    80064e <.L35+0x2a>
	else if (lflag)
  8006ae:	85 c9                	test   %ecx,%ecx
  8006b0:	75 17                	jne    8006c9 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8b 10                	mov    (%eax),%edx
  8006b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bc:	8d 40 04             	lea    0x4(%eax),%eax
  8006bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c2:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c7:	eb 85                	jmp    80064e <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8b 10                	mov    (%eax),%edx
  8006ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d3:	8d 40 04             	lea    0x4(%eax),%eax
  8006d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d9:	b8 10 00 00 00       	mov    $0x10,%eax
  8006de:	e9 6b ff ff ff       	jmp    80064e <.L35+0x2a>

008006e3 <.L25>:
			putch(ch, putdat);
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	56                   	push   %esi
  8006e7:	6a 25                	push   $0x25
  8006e9:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	e9 75 ff ff ff       	jmp    800669 <.L35+0x45>

008006f4 <.L22>:
			putch('%', putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	56                   	push   %esi
  8006f8:	6a 25                	push   $0x25
  8006fa:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	89 f8                	mov    %edi,%eax
  800702:	eb 03                	jmp    800707 <.L22+0x13>
  800704:	83 e8 01             	sub    $0x1,%eax
  800707:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80070b:	75 f7                	jne    800704 <.L22+0x10>
  80070d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800710:	e9 54 ff ff ff       	jmp    800669 <.L35+0x45>
}
  800715:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800718:	5b                   	pop    %ebx
  800719:	5e                   	pop    %esi
  80071a:	5f                   	pop    %edi
  80071b:	5d                   	pop    %ebp
  80071c:	c3                   	ret    

0080071d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	53                   	push   %ebx
  800721:	83 ec 14             	sub    $0x14,%esp
  800724:	e8 4a f9 ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800729:	81 c3 d7 18 00 00    	add    $0x18d7,%ebx
  80072f:	8b 45 08             	mov    0x8(%ebp),%eax
  800732:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800735:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800738:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800746:	85 c0                	test   %eax,%eax
  800748:	74 2b                	je     800775 <vsnprintf+0x58>
  80074a:	85 d2                	test   %edx,%edx
  80074c:	7e 27                	jle    800775 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074e:	ff 75 14             	pushl  0x14(%ebp)
  800751:	ff 75 10             	pushl  0x10(%ebp)
  800754:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800757:	50                   	push   %eax
  800758:	8d 83 85 e2 ff ff    	lea    -0x1d7b(%ebx),%eax
  80075e:	50                   	push   %eax
  80075f:	e8 5b fb ff ff       	call   8002bf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800764:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800767:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076d:	83 c4 10             	add    $0x10,%esp
}
  800770:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800773:	c9                   	leave  
  800774:	c3                   	ret    
		return -E_INVAL;
  800775:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077a:	eb f4                	jmp    800770 <vsnprintf+0x53>

0080077c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800782:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800785:	50                   	push   %eax
  800786:	ff 75 10             	pushl  0x10(%ebp)
  800789:	ff 75 0c             	pushl  0xc(%ebp)
  80078c:	ff 75 08             	pushl  0x8(%ebp)
  80078f:	e8 89 ff ff ff       	call   80071d <vsnprintf>
	va_end(ap);

	return rc;
}
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <__x86.get_pc_thunk.cx>:
  800796:	8b 0c 24             	mov    (%esp),%ecx
  800799:	c3                   	ret    

0080079a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a5:	eb 03                	jmp    8007aa <strlen+0x10>
		n++;
  8007a7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007aa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ae:	75 f7                	jne    8007a7 <strlen+0xd>
	return n;
}
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c0:	eb 03                	jmp    8007c5 <strnlen+0x13>
		n++;
  8007c2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c5:	39 d0                	cmp    %edx,%eax
  8007c7:	74 06                	je     8007cf <strnlen+0x1d>
  8007c9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007cd:	75 f3                	jne    8007c2 <strnlen+0x10>
	return n;
}
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	53                   	push   %ebx
  8007d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007db:	89 c2                	mov    %eax,%edx
  8007dd:	83 c1 01             	add    $0x1,%ecx
  8007e0:	83 c2 01             	add    $0x1,%edx
  8007e3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007e7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ea:	84 db                	test   %bl,%bl
  8007ec:	75 ef                	jne    8007dd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ee:	5b                   	pop    %ebx
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	53                   	push   %ebx
  8007f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f8:	53                   	push   %ebx
  8007f9:	e8 9c ff ff ff       	call   80079a <strlen>
  8007fe:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800801:	ff 75 0c             	pushl  0xc(%ebp)
  800804:	01 d8                	add    %ebx,%eax
  800806:	50                   	push   %eax
  800807:	e8 c5 ff ff ff       	call   8007d1 <strcpy>
	return dst;
}
  80080c:	89 d8                	mov    %ebx,%eax
  80080e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800811:	c9                   	leave  
  800812:	c3                   	ret    

00800813 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	56                   	push   %esi
  800817:	53                   	push   %ebx
  800818:	8b 75 08             	mov    0x8(%ebp),%esi
  80081b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081e:	89 f3                	mov    %esi,%ebx
  800820:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800823:	89 f2                	mov    %esi,%edx
  800825:	eb 0f                	jmp    800836 <strncpy+0x23>
		*dst++ = *src;
  800827:	83 c2 01             	add    $0x1,%edx
  80082a:	0f b6 01             	movzbl (%ecx),%eax
  80082d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800830:	80 39 01             	cmpb   $0x1,(%ecx)
  800833:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800836:	39 da                	cmp    %ebx,%edx
  800838:	75 ed                	jne    800827 <strncpy+0x14>
	}
	return ret;
}
  80083a:	89 f0                	mov    %esi,%eax
  80083c:	5b                   	pop    %ebx
  80083d:	5e                   	pop    %esi
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	56                   	push   %esi
  800844:	53                   	push   %ebx
  800845:	8b 75 08             	mov    0x8(%ebp),%esi
  800848:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80084e:	89 f0                	mov    %esi,%eax
  800850:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800854:	85 c9                	test   %ecx,%ecx
  800856:	75 0b                	jne    800863 <strlcpy+0x23>
  800858:	eb 17                	jmp    800871 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085a:	83 c2 01             	add    $0x1,%edx
  80085d:	83 c0 01             	add    $0x1,%eax
  800860:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800863:	39 d8                	cmp    %ebx,%eax
  800865:	74 07                	je     80086e <strlcpy+0x2e>
  800867:	0f b6 0a             	movzbl (%edx),%ecx
  80086a:	84 c9                	test   %cl,%cl
  80086c:	75 ec                	jne    80085a <strlcpy+0x1a>
		*dst = '\0';
  80086e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800871:	29 f0                	sub    %esi,%eax
}
  800873:	5b                   	pop    %ebx
  800874:	5e                   	pop    %esi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800880:	eb 06                	jmp    800888 <strcmp+0x11>
		p++, q++;
  800882:	83 c1 01             	add    $0x1,%ecx
  800885:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800888:	0f b6 01             	movzbl (%ecx),%eax
  80088b:	84 c0                	test   %al,%al
  80088d:	74 04                	je     800893 <strcmp+0x1c>
  80088f:	3a 02                	cmp    (%edx),%al
  800891:	74 ef                	je     800882 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800893:	0f b6 c0             	movzbl %al,%eax
  800896:	0f b6 12             	movzbl (%edx),%edx
  800899:	29 d0                	sub    %edx,%eax
}
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	53                   	push   %ebx
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a7:	89 c3                	mov    %eax,%ebx
  8008a9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ac:	eb 06                	jmp    8008b4 <strncmp+0x17>
		n--, p++, q++;
  8008ae:	83 c0 01             	add    $0x1,%eax
  8008b1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b4:	39 d8                	cmp    %ebx,%eax
  8008b6:	74 16                	je     8008ce <strncmp+0x31>
  8008b8:	0f b6 08             	movzbl (%eax),%ecx
  8008bb:	84 c9                	test   %cl,%cl
  8008bd:	74 04                	je     8008c3 <strncmp+0x26>
  8008bf:	3a 0a                	cmp    (%edx),%cl
  8008c1:	74 eb                	je     8008ae <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c3:	0f b6 00             	movzbl (%eax),%eax
  8008c6:	0f b6 12             	movzbl (%edx),%edx
  8008c9:	29 d0                	sub    %edx,%eax
}
  8008cb:	5b                   	pop    %ebx
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    
		return 0;
  8008ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d3:	eb f6                	jmp    8008cb <strncmp+0x2e>

008008d5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008df:	0f b6 10             	movzbl (%eax),%edx
  8008e2:	84 d2                	test   %dl,%dl
  8008e4:	74 09                	je     8008ef <strchr+0x1a>
		if (*s == c)
  8008e6:	38 ca                	cmp    %cl,%dl
  8008e8:	74 0a                	je     8008f4 <strchr+0x1f>
	for (; *s; s++)
  8008ea:	83 c0 01             	add    $0x1,%eax
  8008ed:	eb f0                	jmp    8008df <strchr+0xa>
			return (char *) s;
	return 0;
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800900:	eb 03                	jmp    800905 <strfind+0xf>
  800902:	83 c0 01             	add    $0x1,%eax
  800905:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800908:	38 ca                	cmp    %cl,%dl
  80090a:	74 04                	je     800910 <strfind+0x1a>
  80090c:	84 d2                	test   %dl,%dl
  80090e:	75 f2                	jne    800902 <strfind+0xc>
			break;
	return (char *) s;
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	57                   	push   %edi
  800916:	56                   	push   %esi
  800917:	53                   	push   %ebx
  800918:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80091e:	85 c9                	test   %ecx,%ecx
  800920:	74 13                	je     800935 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800922:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800928:	75 05                	jne    80092f <memset+0x1d>
  80092a:	f6 c1 03             	test   $0x3,%cl
  80092d:	74 0d                	je     80093c <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80092f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800932:	fc                   	cld    
  800933:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800935:	89 f8                	mov    %edi,%eax
  800937:	5b                   	pop    %ebx
  800938:	5e                   	pop    %esi
  800939:	5f                   	pop    %edi
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    
		c &= 0xFF;
  80093c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800940:	89 d3                	mov    %edx,%ebx
  800942:	c1 e3 08             	shl    $0x8,%ebx
  800945:	89 d0                	mov    %edx,%eax
  800947:	c1 e0 18             	shl    $0x18,%eax
  80094a:	89 d6                	mov    %edx,%esi
  80094c:	c1 e6 10             	shl    $0x10,%esi
  80094f:	09 f0                	or     %esi,%eax
  800951:	09 c2                	or     %eax,%edx
  800953:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800955:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800958:	89 d0                	mov    %edx,%eax
  80095a:	fc                   	cld    
  80095b:	f3 ab                	rep stos %eax,%es:(%edi)
  80095d:	eb d6                	jmp    800935 <memset+0x23>

0080095f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	57                   	push   %edi
  800963:	56                   	push   %esi
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096d:	39 c6                	cmp    %eax,%esi
  80096f:	73 35                	jae    8009a6 <memmove+0x47>
  800971:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800974:	39 c2                	cmp    %eax,%edx
  800976:	76 2e                	jbe    8009a6 <memmove+0x47>
		s += n;
		d += n;
  800978:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097b:	89 d6                	mov    %edx,%esi
  80097d:	09 fe                	or     %edi,%esi
  80097f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800985:	74 0c                	je     800993 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800987:	83 ef 01             	sub    $0x1,%edi
  80098a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80098d:	fd                   	std    
  80098e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800990:	fc                   	cld    
  800991:	eb 21                	jmp    8009b4 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800993:	f6 c1 03             	test   $0x3,%cl
  800996:	75 ef                	jne    800987 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800998:	83 ef 04             	sub    $0x4,%edi
  80099b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009a1:	fd                   	std    
  8009a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a4:	eb ea                	jmp    800990 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a6:	89 f2                	mov    %esi,%edx
  8009a8:	09 c2                	or     %eax,%edx
  8009aa:	f6 c2 03             	test   $0x3,%dl
  8009ad:	74 09                	je     8009b8 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009af:	89 c7                	mov    %eax,%edi
  8009b1:	fc                   	cld    
  8009b2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b4:	5e                   	pop    %esi
  8009b5:	5f                   	pop    %edi
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b8:	f6 c1 03             	test   $0x3,%cl
  8009bb:	75 f2                	jne    8009af <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009bd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009c0:	89 c7                	mov    %eax,%edi
  8009c2:	fc                   	cld    
  8009c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c5:	eb ed                	jmp    8009b4 <memmove+0x55>

008009c7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ca:	ff 75 10             	pushl  0x10(%ebp)
  8009cd:	ff 75 0c             	pushl  0xc(%ebp)
  8009d0:	ff 75 08             	pushl  0x8(%ebp)
  8009d3:	e8 87 ff ff ff       	call   80095f <memmove>
}
  8009d8:	c9                   	leave  
  8009d9:	c3                   	ret    

008009da <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	56                   	push   %esi
  8009de:	53                   	push   %ebx
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e5:	89 c6                	mov    %eax,%esi
  8009e7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ea:	39 f0                	cmp    %esi,%eax
  8009ec:	74 1c                	je     800a0a <memcmp+0x30>
		if (*s1 != *s2)
  8009ee:	0f b6 08             	movzbl (%eax),%ecx
  8009f1:	0f b6 1a             	movzbl (%edx),%ebx
  8009f4:	38 d9                	cmp    %bl,%cl
  8009f6:	75 08                	jne    800a00 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009f8:	83 c0 01             	add    $0x1,%eax
  8009fb:	83 c2 01             	add    $0x1,%edx
  8009fe:	eb ea                	jmp    8009ea <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a00:	0f b6 c1             	movzbl %cl,%eax
  800a03:	0f b6 db             	movzbl %bl,%ebx
  800a06:	29 d8                	sub    %ebx,%eax
  800a08:	eb 05                	jmp    800a0f <memcmp+0x35>
	}

	return 0;
  800a0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
  800a19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a1c:	89 c2                	mov    %eax,%edx
  800a1e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a21:	39 d0                	cmp    %edx,%eax
  800a23:	73 09                	jae    800a2e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a25:	38 08                	cmp    %cl,(%eax)
  800a27:	74 05                	je     800a2e <memfind+0x1b>
	for (; s < ends; s++)
  800a29:	83 c0 01             	add    $0x1,%eax
  800a2c:	eb f3                	jmp    800a21 <memfind+0xe>
			break;
	return (void *) s;
}
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	57                   	push   %edi
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
  800a36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3c:	eb 03                	jmp    800a41 <strtol+0x11>
		s++;
  800a3e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a41:	0f b6 01             	movzbl (%ecx),%eax
  800a44:	3c 20                	cmp    $0x20,%al
  800a46:	74 f6                	je     800a3e <strtol+0xe>
  800a48:	3c 09                	cmp    $0x9,%al
  800a4a:	74 f2                	je     800a3e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a4c:	3c 2b                	cmp    $0x2b,%al
  800a4e:	74 2e                	je     800a7e <strtol+0x4e>
	int neg = 0;
  800a50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a55:	3c 2d                	cmp    $0x2d,%al
  800a57:	74 2f                	je     800a88 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a59:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a5f:	75 05                	jne    800a66 <strtol+0x36>
  800a61:	80 39 30             	cmpb   $0x30,(%ecx)
  800a64:	74 2c                	je     800a92 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a66:	85 db                	test   %ebx,%ebx
  800a68:	75 0a                	jne    800a74 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a6f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a72:	74 28                	je     800a9c <strtol+0x6c>
		base = 10;
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
  800a79:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a7c:	eb 50                	jmp    800ace <strtol+0x9e>
		s++;
  800a7e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a81:	bf 00 00 00 00       	mov    $0x0,%edi
  800a86:	eb d1                	jmp    800a59 <strtol+0x29>
		s++, neg = 1;
  800a88:	83 c1 01             	add    $0x1,%ecx
  800a8b:	bf 01 00 00 00       	mov    $0x1,%edi
  800a90:	eb c7                	jmp    800a59 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a92:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a96:	74 0e                	je     800aa6 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a98:	85 db                	test   %ebx,%ebx
  800a9a:	75 d8                	jne    800a74 <strtol+0x44>
		s++, base = 8;
  800a9c:	83 c1 01             	add    $0x1,%ecx
  800a9f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aa4:	eb ce                	jmp    800a74 <strtol+0x44>
		s += 2, base = 16;
  800aa6:	83 c1 02             	add    $0x2,%ecx
  800aa9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aae:	eb c4                	jmp    800a74 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ab0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab3:	89 f3                	mov    %esi,%ebx
  800ab5:	80 fb 19             	cmp    $0x19,%bl
  800ab8:	77 29                	ja     800ae3 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800aba:	0f be d2             	movsbl %dl,%edx
  800abd:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac3:	7d 30                	jge    800af5 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ac5:	83 c1 01             	add    $0x1,%ecx
  800ac8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800acc:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ace:	0f b6 11             	movzbl (%ecx),%edx
  800ad1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad4:	89 f3                	mov    %esi,%ebx
  800ad6:	80 fb 09             	cmp    $0x9,%bl
  800ad9:	77 d5                	ja     800ab0 <strtol+0x80>
			dig = *s - '0';
  800adb:	0f be d2             	movsbl %dl,%edx
  800ade:	83 ea 30             	sub    $0x30,%edx
  800ae1:	eb dd                	jmp    800ac0 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ae3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae6:	89 f3                	mov    %esi,%ebx
  800ae8:	80 fb 19             	cmp    $0x19,%bl
  800aeb:	77 08                	ja     800af5 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aed:	0f be d2             	movsbl %dl,%edx
  800af0:	83 ea 37             	sub    $0x37,%edx
  800af3:	eb cb                	jmp    800ac0 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800af5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af9:	74 05                	je     800b00 <strtol+0xd0>
		*endptr = (char *) s;
  800afb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afe:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b00:	89 c2                	mov    %eax,%edx
  800b02:	f7 da                	neg    %edx
  800b04:	85 ff                	test   %edi,%edi
  800b06:	0f 45 c2             	cmovne %edx,%eax
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	57                   	push   %edi
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b14:	b8 00 00 00 00       	mov    $0x0,%eax
  800b19:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1f:	89 c3                	mov    %eax,%ebx
  800b21:	89 c7                	mov    %eax,%edi
  800b23:	89 c6                	mov    %eax,%esi
  800b25:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5f                   	pop    %edi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b32:	ba 00 00 00 00       	mov    $0x0,%edx
  800b37:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3c:	89 d1                	mov    %edx,%ecx
  800b3e:	89 d3                	mov    %edx,%ebx
  800b40:	89 d7                	mov    %edx,%edi
  800b42:	89 d6                	mov    %edx,%esi
  800b44:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	57                   	push   %edi
  800b4f:	56                   	push   %esi
  800b50:	53                   	push   %ebx
  800b51:	83 ec 1c             	sub    $0x1c,%esp
  800b54:	e8 66 00 00 00       	call   800bbf <__x86.get_pc_thunk.ax>
  800b59:	05 a7 14 00 00       	add    $0x14a7,%eax
  800b5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6e:	89 cb                	mov    %ecx,%ebx
  800b70:	89 cf                	mov    %ecx,%edi
  800b72:	89 ce                	mov    %ecx,%esi
  800b74:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b76:	85 c0                	test   %eax,%eax
  800b78:	7f 08                	jg     800b82 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b82:	83 ec 0c             	sub    $0xc,%esp
  800b85:	50                   	push   %eax
  800b86:	6a 03                	push   $0x3
  800b88:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800b8b:	8d 83 5c f0 ff ff    	lea    -0xfa4(%ebx),%eax
  800b91:	50                   	push   %eax
  800b92:	6a 23                	push   $0x23
  800b94:	8d 83 79 f0 ff ff    	lea    -0xf87(%ebx),%eax
  800b9a:	50                   	push   %eax
  800b9b:	e8 23 00 00 00       	call   800bc3 <_panic>

00800ba0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bab:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb0:	89 d1                	mov    %edx,%ecx
  800bb2:	89 d3                	mov    %edx,%ebx
  800bb4:	89 d7                	mov    %edx,%edi
  800bb6:	89 d6                	mov    %edx,%esi
  800bb8:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <__x86.get_pc_thunk.ax>:
  800bbf:	8b 04 24             	mov    (%esp),%eax
  800bc2:	c3                   	ret    

00800bc3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 0c             	sub    $0xc,%esp
  800bcc:	e8 a2 f4 ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800bd1:	81 c3 2f 14 00 00    	add    $0x142f,%ebx
	va_list ap;

	va_start(ap, fmt);
  800bd7:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bda:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800be0:	8b 38                	mov    (%eax),%edi
  800be2:	e8 b9 ff ff ff       	call   800ba0 <sys_getenvid>
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	ff 75 0c             	pushl  0xc(%ebp)
  800bed:	ff 75 08             	pushl  0x8(%ebp)
  800bf0:	57                   	push   %edi
  800bf1:	50                   	push   %eax
  800bf2:	8d 83 88 f0 ff ff    	lea    -0xf78(%ebx),%eax
  800bf8:	50                   	push   %eax
  800bf9:	e8 a9 f5 ff ff       	call   8001a7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bfe:	83 c4 18             	add    $0x18,%esp
  800c01:	56                   	push   %esi
  800c02:	ff 75 10             	pushl  0x10(%ebp)
  800c05:	e8 3b f5 ff ff       	call   800145 <vcprintf>
	cprintf("\n");
  800c0a:	8d 83 68 ee ff ff    	lea    -0x1198(%ebx),%eax
  800c10:	89 04 24             	mov    %eax,(%esp)
  800c13:	e8 8f f5 ff ff       	call   8001a7 <cprintf>
  800c18:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c1b:	cc                   	int3   
  800c1c:	eb fd                	jmp    800c1b <_panic+0x58>
  800c1e:	66 90                	xchg   %ax,%ax

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
