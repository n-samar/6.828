
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 32 00 00 00       	call   800063 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 20 00 00 00       	call   80005f <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800045:	ff 35 00 00 00 00    	pushl  0x0
  80004b:	8d 83 4c ee ff ff    	lea    -0x11b4(%ebx),%eax
  800051:	50                   	push   %eax
  800052:	e8 3c 01 00 00       	call   800193 <cprintf>
}
  800057:	83 c4 10             	add    $0x10,%esp
  80005a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <__x86.get_pc_thunk.bx>:
  80005f:	8b 1c 24             	mov    (%esp),%ebx
  800062:	c3                   	ret    

00800063 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800063:	55                   	push   %ebp
  800064:	89 e5                	mov    %esp,%ebp
  800066:	57                   	push   %edi
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	83 ec 0c             	sub    $0xc,%esp
  80006c:	e8 ee ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800071:	81 c3 8f 1f 00 00    	add    $0x1f8f,%ebx
  800077:	8b 75 08             	mov    0x8(%ebp),%esi
  80007a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

	thisenv = envs+ENVX(sys_getenvid());
  80007d:	e8 0a 0b 00 00       	call   800b8c <sys_getenvid>
  800082:	25 ff 03 00 00       	and    $0x3ff,%eax
  800087:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80008a:	c1 e0 05             	shl    $0x5,%eax
  80008d:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800093:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  800099:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009b:	85 f6                	test   %esi,%esi
  80009d:	7e 08                	jle    8000a7 <libmain+0x44>
		binaryname = argv[0];
  80009f:	8b 07                	mov    (%edi),%eax
  8000a1:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a7:	83 ec 08             	sub    $0x8,%esp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	e8 82 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b1:	e8 0b 00 00 00       	call   8000c1 <exit>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5e                   	pop    %esi
  8000be:	5f                   	pop    %edi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	53                   	push   %ebx
  8000c5:	83 ec 10             	sub    $0x10,%esp
  8000c8:	e8 92 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000cd:	81 c3 33 1f 00 00    	add    $0x1f33,%ebx
	sys_env_destroy(0);
  8000d3:	6a 00                	push   $0x0
  8000d5:	e8 5d 0a 00 00       	call   800b37 <sys_env_destroy>
}
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e0:	c9                   	leave  
  8000e1:	c3                   	ret    

008000e2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 73 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000ec:	81 c3 14 1f 00 00    	add    $0x1f14,%ebx
  8000f2:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000f5:	8b 16                	mov    (%esi),%edx
  8000f7:	8d 42 01             	lea    0x1(%edx),%eax
  8000fa:	89 06                	mov    %eax,(%esi)
  8000fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ff:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800103:	3d ff 00 00 00       	cmp    $0xff,%eax
  800108:	74 0b                	je     800115 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80010a:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80010e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5d                   	pop    %ebp
  800114:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800115:	83 ec 08             	sub    $0x8,%esp
  800118:	68 ff 00 00 00       	push   $0xff
  80011d:	8d 46 08             	lea    0x8(%esi),%eax
  800120:	50                   	push   %eax
  800121:	e8 d4 09 00 00       	call   800afa <sys_cputs>
		b->idx = 0;
  800126:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	eb d9                	jmp    80010a <putch+0x28>

00800131 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	53                   	push   %ebx
  800135:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80013b:	e8 1f ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800140:	81 c3 c0 1e 00 00    	add    $0x1ec0,%ebx
	struct printbuf b;

	b.idx = 0;
  800146:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014d:	00 00 00 
	b.cnt = 0;
  800150:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800157:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015a:	ff 75 0c             	pushl  0xc(%ebp)
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800166:	50                   	push   %eax
  800167:	8d 83 e2 e0 ff ff    	lea    -0x1f1e(%ebx),%eax
  80016d:	50                   	push   %eax
  80016e:	e8 38 01 00 00       	call   8002ab <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800173:	83 c4 08             	add    $0x8,%esp
  800176:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800182:	50                   	push   %eax
  800183:	e8 72 09 00 00       	call   800afa <sys_cputs>

	return b.cnt;
}
  800188:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800199:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019c:	50                   	push   %eax
  80019d:	ff 75 08             	pushl  0x8(%ebp)
  8001a0:	e8 8c ff ff ff       	call   800131 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	57                   	push   %edi
  8001ab:	56                   	push   %esi
  8001ac:	53                   	push   %ebx
  8001ad:	83 ec 2c             	sub    $0x2c,%esp
  8001b0:	e8 cd 05 00 00       	call   800782 <__x86.get_pc_thunk.cx>
  8001b5:	81 c1 4b 1e 00 00    	add    $0x1e4b,%ecx
  8001bb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001be:	89 c7                	mov    %eax,%edi
  8001c0:	89 d6                	mov    %edx,%esi
  8001c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001cb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001d9:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001dc:	39 d3                	cmp    %edx,%ebx
  8001de:	72 09                	jb     8001e9 <printnum+0x42>
  8001e0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e3:	0f 87 83 00 00 00    	ja     80026c <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	ff 75 18             	pushl  0x18(%ebp)
  8001ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f5:	53                   	push   %ebx
  8001f6:	ff 75 10             	pushl  0x10(%ebp)
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ff:	ff 75 d8             	pushl  -0x28(%ebp)
  800202:	ff 75 d4             	pushl  -0x2c(%ebp)
  800205:	ff 75 d0             	pushl  -0x30(%ebp)
  800208:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80020b:	e8 00 0a 00 00       	call   800c10 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 89 ff ff ff       	call   8001a7 <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 13                	jmp    800236 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80022f:	83 eb 01             	sub    $0x1,%ebx
  800232:	85 db                	test   %ebx,%ebx
  800234:	7f ed                	jg     800223 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800236:	83 ec 08             	sub    $0x8,%esp
  800239:	56                   	push   %esi
  80023a:	83 ec 04             	sub    $0x4,%esp
  80023d:	ff 75 dc             	pushl  -0x24(%ebp)
  800240:	ff 75 d8             	pushl  -0x28(%ebp)
  800243:	ff 75 d4             	pushl  -0x2c(%ebp)
  800246:	ff 75 d0             	pushl  -0x30(%ebp)
  800249:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80024c:	89 f3                	mov    %esi,%ebx
  80024e:	e8 dd 0a 00 00       	call   800d30 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 84 06 74 ee ff 	movsbl -0x118c(%esi,%eax,1),%eax
  80025d:	ff 
  80025e:	50                   	push   %eax
  80025f:	ff d7                	call   *%edi
}
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    
  80026c:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80026f:	eb be                	jmp    80022f <printnum+0x88>

00800271 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800277:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027b:	8b 10                	mov    (%eax),%edx
  80027d:	3b 50 04             	cmp    0x4(%eax),%edx
  800280:	73 0a                	jae    80028c <sprintputch+0x1b>
		*b->buf++ = ch;
  800282:	8d 4a 01             	lea    0x1(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 45 08             	mov    0x8(%ebp),%eax
  80028a:	88 02                	mov    %al,(%edx)
}
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    

0080028e <printfmt>:
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800294:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800297:	50                   	push   %eax
  800298:	ff 75 10             	pushl  0x10(%ebp)
  80029b:	ff 75 0c             	pushl  0xc(%ebp)
  80029e:	ff 75 08             	pushl  0x8(%ebp)
  8002a1:	e8 05 00 00 00       	call   8002ab <vprintfmt>
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	c9                   	leave  
  8002aa:	c3                   	ret    

008002ab <vprintfmt>:
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	57                   	push   %edi
  8002af:	56                   	push   %esi
  8002b0:	53                   	push   %ebx
  8002b1:	83 ec 2c             	sub    $0x2c,%esp
  8002b4:	e8 a6 fd ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8002b9:	81 c3 47 1d 00 00    	add    $0x1d47,%ebx
  8002bf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002c2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c5:	e9 8e 03 00 00       	jmp    800658 <.L35+0x48>
		padc = ' ';
  8002ca:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002eb:	8d 47 01             	lea    0x1(%edi),%eax
  8002ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f1:	0f b6 17             	movzbl (%edi),%edx
  8002f4:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002f7:	3c 55                	cmp    $0x55,%al
  8002f9:	0f 87 e1 03 00 00    	ja     8006e0 <.L22>
  8002ff:	0f b6 c0             	movzbl %al,%eax
  800302:	89 d9                	mov    %ebx,%ecx
  800304:	03 8c 83 04 ef ff ff 	add    -0x10fc(%ebx,%eax,4),%ecx
  80030b:	ff e1                	jmp    *%ecx

0080030d <.L67>:
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800310:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800314:	eb d5                	jmp    8002eb <vprintfmt+0x40>

00800316 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800316:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800319:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80031d:	eb cc                	jmp    8002eb <vprintfmt+0x40>

0080031f <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	0f b6 d2             	movzbl %dl,%edx
  800322:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800325:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80032a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80032d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800331:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800334:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800337:	83 f9 09             	cmp    $0x9,%ecx
  80033a:	77 55                	ja     800391 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  80033c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80033f:	eb e9                	jmp    80032a <.L29+0xb>

00800341 <.L26>:
			precision = va_arg(ap, int);
  800341:	8b 45 14             	mov    0x14(%ebp),%eax
  800344:	8b 00                	mov    (%eax),%eax
  800346:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800349:	8b 45 14             	mov    0x14(%ebp),%eax
  80034c:	8d 40 04             	lea    0x4(%eax),%eax
  80034f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800355:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800359:	79 90                	jns    8002eb <vprintfmt+0x40>
				width = precision, precision = -1;
  80035b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80035e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800361:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800368:	eb 81                	jmp    8002eb <vprintfmt+0x40>

0080036a <.L27>:
  80036a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036d:	85 c0                	test   %eax,%eax
  80036f:	ba 00 00 00 00       	mov    $0x0,%edx
  800374:	0f 49 d0             	cmovns %eax,%edx
  800377:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037d:	e9 69 ff ff ff       	jmp    8002eb <vprintfmt+0x40>

00800382 <.L23>:
  800382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800385:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80038c:	e9 5a ff ff ff       	jmp    8002eb <vprintfmt+0x40>
  800391:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800394:	eb bf                	jmp    800355 <.L26+0x14>

00800396 <.L33>:
			lflag++;
  800396:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80039d:	e9 49 ff ff ff       	jmp    8002eb <vprintfmt+0x40>

008003a2 <.L30>:
			putch(va_arg(ap, int), putdat);
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	8d 78 04             	lea    0x4(%eax),%edi
  8003a8:	83 ec 08             	sub    $0x8,%esp
  8003ab:	56                   	push   %esi
  8003ac:	ff 30                	pushl  (%eax)
  8003ae:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003b1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003b4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003b7:	e9 99 02 00 00       	jmp    800655 <.L35+0x45>

008003bc <.L32>:
			err = va_arg(ap, int);
  8003bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bf:	8d 78 04             	lea    0x4(%eax),%edi
  8003c2:	8b 00                	mov    (%eax),%eax
  8003c4:	99                   	cltd   
  8003c5:	31 d0                	xor    %edx,%eax
  8003c7:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c9:	83 f8 06             	cmp    $0x6,%eax
  8003cc:	7f 27                	jg     8003f5 <.L32+0x39>
  8003ce:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8003d5:	85 d2                	test   %edx,%edx
  8003d7:	74 1c                	je     8003f5 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8003d9:	52                   	push   %edx
  8003da:	8d 83 95 ee ff ff    	lea    -0x116b(%ebx),%eax
  8003e0:	50                   	push   %eax
  8003e1:	56                   	push   %esi
  8003e2:	ff 75 08             	pushl  0x8(%ebp)
  8003e5:	e8 a4 fe ff ff       	call   80028e <printfmt>
  8003ea:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ed:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003f0:	e9 60 02 00 00       	jmp    800655 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8003f5:	50                   	push   %eax
  8003f6:	8d 83 8c ee ff ff    	lea    -0x1174(%ebx),%eax
  8003fc:	50                   	push   %eax
  8003fd:	56                   	push   %esi
  8003fe:	ff 75 08             	pushl  0x8(%ebp)
  800401:	e8 88 fe ff ff       	call   80028e <printfmt>
  800406:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800409:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80040c:	e9 44 02 00 00       	jmp    800655 <.L35+0x45>

00800411 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	83 c0 04             	add    $0x4,%eax
  800417:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80041f:	85 ff                	test   %edi,%edi
  800421:	8d 83 85 ee ff ff    	lea    -0x117b(%ebx),%eax
  800427:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80042a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042e:	0f 8e b5 00 00 00    	jle    8004e9 <.L36+0xd8>
  800434:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800438:	75 08                	jne    800442 <.L36+0x31>
  80043a:	89 75 0c             	mov    %esi,0xc(%ebp)
  80043d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800440:	eb 6d                	jmp    8004af <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	ff 75 d0             	pushl  -0x30(%ebp)
  800448:	57                   	push   %edi
  800449:	e8 50 03 00 00       	call   80079e <strnlen>
  80044e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800451:	29 c2                	sub    %eax,%edx
  800453:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800456:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800459:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80045d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800460:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800463:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800465:	eb 10                	jmp    800477 <.L36+0x66>
					putch(padc, putdat);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	56                   	push   %esi
  80046b:	ff 75 e0             	pushl  -0x20(%ebp)
  80046e:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800471:	83 ef 01             	sub    $0x1,%edi
  800474:	83 c4 10             	add    $0x10,%esp
  800477:	85 ff                	test   %edi,%edi
  800479:	7f ec                	jg     800467 <.L36+0x56>
  80047b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80047e:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800481:	85 d2                	test   %edx,%edx
  800483:	b8 00 00 00 00       	mov    $0x0,%eax
  800488:	0f 49 c2             	cmovns %edx,%eax
  80048b:	29 c2                	sub    %eax,%edx
  80048d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800490:	89 75 0c             	mov    %esi,0xc(%ebp)
  800493:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800496:	eb 17                	jmp    8004af <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800498:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049c:	75 30                	jne    8004ce <.L36+0xbd>
					putch(ch, putdat);
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	ff 75 0c             	pushl  0xc(%ebp)
  8004a4:	50                   	push   %eax
  8004a5:	ff 55 08             	call   *0x8(%ebp)
  8004a8:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ab:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004af:	83 c7 01             	add    $0x1,%edi
  8004b2:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004b6:	0f be c2             	movsbl %dl,%eax
  8004b9:	85 c0                	test   %eax,%eax
  8004bb:	74 52                	je     80050f <.L36+0xfe>
  8004bd:	85 f6                	test   %esi,%esi
  8004bf:	78 d7                	js     800498 <.L36+0x87>
  8004c1:	83 ee 01             	sub    $0x1,%esi
  8004c4:	79 d2                	jns    800498 <.L36+0x87>
  8004c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004c9:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004cc:	eb 32                	jmp    800500 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ce:	0f be d2             	movsbl %dl,%edx
  8004d1:	83 ea 20             	sub    $0x20,%edx
  8004d4:	83 fa 5e             	cmp    $0x5e,%edx
  8004d7:	76 c5                	jbe    80049e <.L36+0x8d>
					putch('?', putdat);
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	ff 75 0c             	pushl  0xc(%ebp)
  8004df:	6a 3f                	push   $0x3f
  8004e1:	ff 55 08             	call   *0x8(%ebp)
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	eb c2                	jmp    8004ab <.L36+0x9a>
  8004e9:	89 75 0c             	mov    %esi,0xc(%ebp)
  8004ec:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ef:	eb be                	jmp    8004af <.L36+0x9e>
				putch(' ', putdat);
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	56                   	push   %esi
  8004f5:	6a 20                	push   $0x20
  8004f7:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8004fa:	83 ef 01             	sub    $0x1,%edi
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	85 ff                	test   %edi,%edi
  800502:	7f ed                	jg     8004f1 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800504:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800507:	89 45 14             	mov    %eax,0x14(%ebp)
  80050a:	e9 46 01 00 00       	jmp    800655 <.L35+0x45>
  80050f:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800512:	8b 75 0c             	mov    0xc(%ebp),%esi
  800515:	eb e9                	jmp    800500 <.L36+0xef>

00800517 <.L31>:
  800517:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  80051a:	83 f9 01             	cmp    $0x1,%ecx
  80051d:	7e 40                	jle    80055f <.L31+0x48>
		return va_arg(*ap, long long);
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8b 50 04             	mov    0x4(%eax),%edx
  800525:	8b 00                	mov    (%eax),%eax
  800527:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 40 08             	lea    0x8(%eax),%eax
  800533:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800536:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80053a:	79 55                	jns    800591 <.L31+0x7a>
				putch('-', putdat);
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	56                   	push   %esi
  800540:	6a 2d                	push   $0x2d
  800542:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800545:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800548:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80054b:	f7 da                	neg    %edx
  80054d:	83 d1 00             	adc    $0x0,%ecx
  800550:	f7 d9                	neg    %ecx
  800552:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800555:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055a:	e9 db 00 00 00       	jmp    80063a <.L35+0x2a>
	else if (lflag)
  80055f:	85 c9                	test   %ecx,%ecx
  800561:	75 17                	jne    80057a <.L31+0x63>
		return va_arg(*ap, int);
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8b 00                	mov    (%eax),%eax
  800568:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056b:	99                   	cltd   
  80056c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8d 40 04             	lea    0x4(%eax),%eax
  800575:	89 45 14             	mov    %eax,0x14(%ebp)
  800578:	eb bc                	jmp    800536 <.L31+0x1f>
		return va_arg(*ap, long);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800582:	99                   	cltd   
  800583:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 40 04             	lea    0x4(%eax),%eax
  80058c:	89 45 14             	mov    %eax,0x14(%ebp)
  80058f:	eb a5                	jmp    800536 <.L31+0x1f>
			num = getint(&ap, lflag);
  800591:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800594:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800597:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059c:	e9 99 00 00 00       	jmp    80063a <.L35+0x2a>

008005a1 <.L37>:
  8005a1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  8005a4:	83 f9 01             	cmp    $0x1,%ecx
  8005a7:	7e 15                	jle    8005be <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 10                	mov    (%eax),%edx
  8005ae:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b1:	8d 40 08             	lea    0x8(%eax),%eax
  8005b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bc:	eb 7c                	jmp    80063a <.L35+0x2a>
	else if (lflag)
  8005be:	85 c9                	test   %ecx,%ecx
  8005c0:	75 17                	jne    8005d9 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cc:	8d 40 04             	lea    0x4(%eax),%eax
  8005cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d7:	eb 61                	jmp    80063a <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8b 10                	mov    (%eax),%edx
  8005de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e3:	8d 40 04             	lea    0x4(%eax),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ee:	eb 4a                	jmp    80063a <.L35+0x2a>

008005f0 <.L34>:
			putch('X', putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	56                   	push   %esi
  8005f4:	6a 58                	push   $0x58
  8005f6:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005f9:	83 c4 08             	add    $0x8,%esp
  8005fc:	56                   	push   %esi
  8005fd:	6a 58                	push   $0x58
  8005ff:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800602:	83 c4 08             	add    $0x8,%esp
  800605:	56                   	push   %esi
  800606:	6a 58                	push   $0x58
  800608:	ff 55 08             	call   *0x8(%ebp)
			break;
  80060b:	83 c4 10             	add    $0x10,%esp
  80060e:	eb 45                	jmp    800655 <.L35+0x45>

00800610 <.L35>:
			putch('0', putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	56                   	push   %esi
  800614:	6a 30                	push   $0x30
  800616:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	56                   	push   %esi
  80061d:	6a 78                	push   $0x78
  80061f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8b 10                	mov    (%eax),%edx
  800627:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80062c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80062f:	8d 40 04             	lea    0x4(%eax),%eax
  800632:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800635:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80063a:	83 ec 0c             	sub    $0xc,%esp
  80063d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800641:	57                   	push   %edi
  800642:	ff 75 e0             	pushl  -0x20(%ebp)
  800645:	50                   	push   %eax
  800646:	51                   	push   %ecx
  800647:	52                   	push   %edx
  800648:	89 f2                	mov    %esi,%edx
  80064a:	8b 45 08             	mov    0x8(%ebp),%eax
  80064d:	e8 55 fb ff ff       	call   8001a7 <printnum>
			break;
  800652:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800655:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800658:	83 c7 01             	add    $0x1,%edi
  80065b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80065f:	83 f8 25             	cmp    $0x25,%eax
  800662:	0f 84 62 fc ff ff    	je     8002ca <vprintfmt+0x1f>
			if (ch == '\0')
  800668:	85 c0                	test   %eax,%eax
  80066a:	0f 84 91 00 00 00    	je     800701 <.L22+0x21>
			putch(ch, putdat);
  800670:	83 ec 08             	sub    $0x8,%esp
  800673:	56                   	push   %esi
  800674:	50                   	push   %eax
  800675:	ff 55 08             	call   *0x8(%ebp)
  800678:	83 c4 10             	add    $0x10,%esp
  80067b:	eb db                	jmp    800658 <.L35+0x48>

0080067d <.L38>:
  80067d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  800680:	83 f9 01             	cmp    $0x1,%ecx
  800683:	7e 15                	jle    80069a <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	8b 48 04             	mov    0x4(%eax),%ecx
  80068d:	8d 40 08             	lea    0x8(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800693:	b8 10 00 00 00       	mov    $0x10,%eax
  800698:	eb a0                	jmp    80063a <.L35+0x2a>
	else if (lflag)
  80069a:	85 c9                	test   %ecx,%ecx
  80069c:	75 17                	jne    8006b5 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8b 10                	mov    (%eax),%edx
  8006a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a8:	8d 40 04             	lea    0x4(%eax),%eax
  8006ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ae:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b3:	eb 85                	jmp    80063a <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8b 10                	mov    (%eax),%edx
  8006ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bf:	8d 40 04             	lea    0x4(%eax),%eax
  8006c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c5:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ca:	e9 6b ff ff ff       	jmp    80063a <.L35+0x2a>

008006cf <.L25>:
			putch(ch, putdat);
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	56                   	push   %esi
  8006d3:	6a 25                	push   $0x25
  8006d5:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	e9 75 ff ff ff       	jmp    800655 <.L35+0x45>

008006e0 <.L22>:
			putch('%', putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	56                   	push   %esi
  8006e4:	6a 25                	push   $0x25
  8006e6:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	89 f8                	mov    %edi,%eax
  8006ee:	eb 03                	jmp    8006f3 <.L22+0x13>
  8006f0:	83 e8 01             	sub    $0x1,%eax
  8006f3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006f7:	75 f7                	jne    8006f0 <.L22+0x10>
  8006f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006fc:	e9 54 ff ff ff       	jmp    800655 <.L35+0x45>
}
  800701:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800704:	5b                   	pop    %ebx
  800705:	5e                   	pop    %esi
  800706:	5f                   	pop    %edi
  800707:	5d                   	pop    %ebp
  800708:	c3                   	ret    

00800709 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	53                   	push   %ebx
  80070d:	83 ec 14             	sub    $0x14,%esp
  800710:	e8 4a f9 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800715:	81 c3 eb 18 00 00    	add    $0x18eb,%ebx
  80071b:	8b 45 08             	mov    0x8(%ebp),%eax
  80071e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800721:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800724:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800728:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800732:	85 c0                	test   %eax,%eax
  800734:	74 2b                	je     800761 <vsnprintf+0x58>
  800736:	85 d2                	test   %edx,%edx
  800738:	7e 27                	jle    800761 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073a:	ff 75 14             	pushl  0x14(%ebp)
  80073d:	ff 75 10             	pushl  0x10(%ebp)
  800740:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800743:	50                   	push   %eax
  800744:	8d 83 71 e2 ff ff    	lea    -0x1d8f(%ebx),%eax
  80074a:	50                   	push   %eax
  80074b:	e8 5b fb ff ff       	call   8002ab <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800753:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800756:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800759:	83 c4 10             	add    $0x10,%esp
}
  80075c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075f:	c9                   	leave  
  800760:	c3                   	ret    
		return -E_INVAL;
  800761:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800766:	eb f4                	jmp    80075c <vsnprintf+0x53>

00800768 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800771:	50                   	push   %eax
  800772:	ff 75 10             	pushl  0x10(%ebp)
  800775:	ff 75 0c             	pushl  0xc(%ebp)
  800778:	ff 75 08             	pushl  0x8(%ebp)
  80077b:	e8 89 ff ff ff       	call   800709 <vsnprintf>
	va_end(ap);

	return rc;
}
  800780:	c9                   	leave  
  800781:	c3                   	ret    

00800782 <__x86.get_pc_thunk.cx>:
  800782:	8b 0c 24             	mov    (%esp),%ecx
  800785:	c3                   	ret    

00800786 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078c:	b8 00 00 00 00       	mov    $0x0,%eax
  800791:	eb 03                	jmp    800796 <strlen+0x10>
		n++;
  800793:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800796:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079a:	75 f7                	jne    800793 <strlen+0xd>
	return n;
}
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ac:	eb 03                	jmp    8007b1 <strnlen+0x13>
		n++;
  8007ae:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b1:	39 d0                	cmp    %edx,%eax
  8007b3:	74 06                	je     8007bb <strnlen+0x1d>
  8007b5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b9:	75 f3                	jne    8007ae <strnlen+0x10>
	return n;
}
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	53                   	push   %ebx
  8007c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c7:	89 c2                	mov    %eax,%edx
  8007c9:	83 c1 01             	add    $0x1,%ecx
  8007cc:	83 c2 01             	add    $0x1,%edx
  8007cf:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d6:	84 db                	test   %bl,%bl
  8007d8:	75 ef                	jne    8007c9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007da:	5b                   	pop    %ebx
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e4:	53                   	push   %ebx
  8007e5:	e8 9c ff ff ff       	call   800786 <strlen>
  8007ea:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ed:	ff 75 0c             	pushl  0xc(%ebp)
  8007f0:	01 d8                	add    %ebx,%eax
  8007f2:	50                   	push   %eax
  8007f3:	e8 c5 ff ff ff       	call   8007bd <strcpy>
	return dst;
}
  8007f8:	89 d8                	mov    %ebx,%eax
  8007fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	56                   	push   %esi
  800803:	53                   	push   %ebx
  800804:	8b 75 08             	mov    0x8(%ebp),%esi
  800807:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080a:	89 f3                	mov    %esi,%ebx
  80080c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080f:	89 f2                	mov    %esi,%edx
  800811:	eb 0f                	jmp    800822 <strncpy+0x23>
		*dst++ = *src;
  800813:	83 c2 01             	add    $0x1,%edx
  800816:	0f b6 01             	movzbl (%ecx),%eax
  800819:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081c:	80 39 01             	cmpb   $0x1,(%ecx)
  80081f:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800822:	39 da                	cmp    %ebx,%edx
  800824:	75 ed                	jne    800813 <strncpy+0x14>
	}
	return ret;
}
  800826:	89 f0                	mov    %esi,%eax
  800828:	5b                   	pop    %ebx
  800829:	5e                   	pop    %esi
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	56                   	push   %esi
  800830:	53                   	push   %ebx
  800831:	8b 75 08             	mov    0x8(%ebp),%esi
  800834:	8b 55 0c             	mov    0xc(%ebp),%edx
  800837:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80083a:	89 f0                	mov    %esi,%eax
  80083c:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800840:	85 c9                	test   %ecx,%ecx
  800842:	75 0b                	jne    80084f <strlcpy+0x23>
  800844:	eb 17                	jmp    80085d <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800846:	83 c2 01             	add    $0x1,%edx
  800849:	83 c0 01             	add    $0x1,%eax
  80084c:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80084f:	39 d8                	cmp    %ebx,%eax
  800851:	74 07                	je     80085a <strlcpy+0x2e>
  800853:	0f b6 0a             	movzbl (%edx),%ecx
  800856:	84 c9                	test   %cl,%cl
  800858:	75 ec                	jne    800846 <strlcpy+0x1a>
		*dst = '\0';
  80085a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085d:	29 f0                	sub    %esi,%eax
}
  80085f:	5b                   	pop    %ebx
  800860:	5e                   	pop    %esi
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086c:	eb 06                	jmp    800874 <strcmp+0x11>
		p++, q++;
  80086e:	83 c1 01             	add    $0x1,%ecx
  800871:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800874:	0f b6 01             	movzbl (%ecx),%eax
  800877:	84 c0                	test   %al,%al
  800879:	74 04                	je     80087f <strcmp+0x1c>
  80087b:	3a 02                	cmp    (%edx),%al
  80087d:	74 ef                	je     80086e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087f:	0f b6 c0             	movzbl %al,%eax
  800882:	0f b6 12             	movzbl (%edx),%edx
  800885:	29 d0                	sub    %edx,%eax
}
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	53                   	push   %ebx
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
  800893:	89 c3                	mov    %eax,%ebx
  800895:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800898:	eb 06                	jmp    8008a0 <strncmp+0x17>
		n--, p++, q++;
  80089a:	83 c0 01             	add    $0x1,%eax
  80089d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008a0:	39 d8                	cmp    %ebx,%eax
  8008a2:	74 16                	je     8008ba <strncmp+0x31>
  8008a4:	0f b6 08             	movzbl (%eax),%ecx
  8008a7:	84 c9                	test   %cl,%cl
  8008a9:	74 04                	je     8008af <strncmp+0x26>
  8008ab:	3a 0a                	cmp    (%edx),%cl
  8008ad:	74 eb                	je     80089a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008af:	0f b6 00             	movzbl (%eax),%eax
  8008b2:	0f b6 12             	movzbl (%edx),%edx
  8008b5:	29 d0                	sub    %edx,%eax
}
  8008b7:	5b                   	pop    %ebx
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    
		return 0;
  8008ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bf:	eb f6                	jmp    8008b7 <strncmp+0x2e>

008008c1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cb:	0f b6 10             	movzbl (%eax),%edx
  8008ce:	84 d2                	test   %dl,%dl
  8008d0:	74 09                	je     8008db <strchr+0x1a>
		if (*s == c)
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	74 0a                	je     8008e0 <strchr+0x1f>
	for (; *s; s++)
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	eb f0                	jmp    8008cb <strchr+0xa>
			return (char *) s;
	return 0;
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ec:	eb 03                	jmp    8008f1 <strfind+0xf>
  8008ee:	83 c0 01             	add    $0x1,%eax
  8008f1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f4:	38 ca                	cmp    %cl,%dl
  8008f6:	74 04                	je     8008fc <strfind+0x1a>
  8008f8:	84 d2                	test   %dl,%dl
  8008fa:	75 f2                	jne    8008ee <strfind+0xc>
			break;
	return (char *) s;
}
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	57                   	push   %edi
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 7d 08             	mov    0x8(%ebp),%edi
  800907:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090a:	85 c9                	test   %ecx,%ecx
  80090c:	74 13                	je     800921 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800914:	75 05                	jne    80091b <memset+0x1d>
  800916:	f6 c1 03             	test   $0x3,%cl
  800919:	74 0d                	je     800928 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091e:	fc                   	cld    
  80091f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800921:	89 f8                	mov    %edi,%eax
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5f                   	pop    %edi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    
		c &= 0xFF;
  800928:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092c:	89 d3                	mov    %edx,%ebx
  80092e:	c1 e3 08             	shl    $0x8,%ebx
  800931:	89 d0                	mov    %edx,%eax
  800933:	c1 e0 18             	shl    $0x18,%eax
  800936:	89 d6                	mov    %edx,%esi
  800938:	c1 e6 10             	shl    $0x10,%esi
  80093b:	09 f0                	or     %esi,%eax
  80093d:	09 c2                	or     %eax,%edx
  80093f:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800941:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800944:	89 d0                	mov    %edx,%eax
  800946:	fc                   	cld    
  800947:	f3 ab                	rep stos %eax,%es:(%edi)
  800949:	eb d6                	jmp    800921 <memset+0x23>

0080094b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	57                   	push   %edi
  80094f:	56                   	push   %esi
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 75 0c             	mov    0xc(%ebp),%esi
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800959:	39 c6                	cmp    %eax,%esi
  80095b:	73 35                	jae    800992 <memmove+0x47>
  80095d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800960:	39 c2                	cmp    %eax,%edx
  800962:	76 2e                	jbe    800992 <memmove+0x47>
		s += n;
		d += n;
  800964:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800967:	89 d6                	mov    %edx,%esi
  800969:	09 fe                	or     %edi,%esi
  80096b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800971:	74 0c                	je     80097f <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800973:	83 ef 01             	sub    $0x1,%edi
  800976:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800979:	fd                   	std    
  80097a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80097c:	fc                   	cld    
  80097d:	eb 21                	jmp    8009a0 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097f:	f6 c1 03             	test   $0x3,%cl
  800982:	75 ef                	jne    800973 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800984:	83 ef 04             	sub    $0x4,%edi
  800987:	8d 72 fc             	lea    -0x4(%edx),%esi
  80098a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80098d:	fd                   	std    
  80098e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800990:	eb ea                	jmp    80097c <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800992:	89 f2                	mov    %esi,%edx
  800994:	09 c2                	or     %eax,%edx
  800996:	f6 c2 03             	test   $0x3,%dl
  800999:	74 09                	je     8009a4 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099b:	89 c7                	mov    %eax,%edi
  80099d:	fc                   	cld    
  80099e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a0:	5e                   	pop    %esi
  8009a1:	5f                   	pop    %edi
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	f6 c1 03             	test   $0x3,%cl
  8009a7:	75 f2                	jne    80099b <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009ac:	89 c7                	mov    %eax,%edi
  8009ae:	fc                   	cld    
  8009af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b1:	eb ed                	jmp    8009a0 <memmove+0x55>

008009b3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b6:	ff 75 10             	pushl  0x10(%ebp)
  8009b9:	ff 75 0c             	pushl  0xc(%ebp)
  8009bc:	ff 75 08             	pushl  0x8(%ebp)
  8009bf:	e8 87 ff ff ff       	call   80094b <memmove>
}
  8009c4:	c9                   	leave  
  8009c5:	c3                   	ret    

008009c6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	56                   	push   %esi
  8009ca:	53                   	push   %ebx
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d1:	89 c6                	mov    %eax,%esi
  8009d3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d6:	39 f0                	cmp    %esi,%eax
  8009d8:	74 1c                	je     8009f6 <memcmp+0x30>
		if (*s1 != *s2)
  8009da:	0f b6 08             	movzbl (%eax),%ecx
  8009dd:	0f b6 1a             	movzbl (%edx),%ebx
  8009e0:	38 d9                	cmp    %bl,%cl
  8009e2:	75 08                	jne    8009ec <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	83 c2 01             	add    $0x1,%edx
  8009ea:	eb ea                	jmp    8009d6 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009ec:	0f b6 c1             	movzbl %cl,%eax
  8009ef:	0f b6 db             	movzbl %bl,%ebx
  8009f2:	29 d8                	sub    %ebx,%eax
  8009f4:	eb 05                	jmp    8009fb <memcmp+0x35>
	}

	return 0;
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a08:	89 c2                	mov    %eax,%edx
  800a0a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a0d:	39 d0                	cmp    %edx,%eax
  800a0f:	73 09                	jae    800a1a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a11:	38 08                	cmp    %cl,(%eax)
  800a13:	74 05                	je     800a1a <memfind+0x1b>
	for (; s < ends; s++)
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	eb f3                	jmp    800a0d <memfind+0xe>
			break;
	return (void *) s;
}
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
  800a22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a28:	eb 03                	jmp    800a2d <strtol+0x11>
		s++;
  800a2a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a2d:	0f b6 01             	movzbl (%ecx),%eax
  800a30:	3c 20                	cmp    $0x20,%al
  800a32:	74 f6                	je     800a2a <strtol+0xe>
  800a34:	3c 09                	cmp    $0x9,%al
  800a36:	74 f2                	je     800a2a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a38:	3c 2b                	cmp    $0x2b,%al
  800a3a:	74 2e                	je     800a6a <strtol+0x4e>
	int neg = 0;
  800a3c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a41:	3c 2d                	cmp    $0x2d,%al
  800a43:	74 2f                	je     800a74 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a45:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a4b:	75 05                	jne    800a52 <strtol+0x36>
  800a4d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a50:	74 2c                	je     800a7e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a52:	85 db                	test   %ebx,%ebx
  800a54:	75 0a                	jne    800a60 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a56:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a5b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5e:	74 28                	je     800a88 <strtol+0x6c>
		base = 10;
  800a60:	b8 00 00 00 00       	mov    $0x0,%eax
  800a65:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a68:	eb 50                	jmp    800aba <strtol+0x9e>
		s++;
  800a6a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a6d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a72:	eb d1                	jmp    800a45 <strtol+0x29>
		s++, neg = 1;
  800a74:	83 c1 01             	add    $0x1,%ecx
  800a77:	bf 01 00 00 00       	mov    $0x1,%edi
  800a7c:	eb c7                	jmp    800a45 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a82:	74 0e                	je     800a92 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a84:	85 db                	test   %ebx,%ebx
  800a86:	75 d8                	jne    800a60 <strtol+0x44>
		s++, base = 8;
  800a88:	83 c1 01             	add    $0x1,%ecx
  800a8b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a90:	eb ce                	jmp    800a60 <strtol+0x44>
		s += 2, base = 16;
  800a92:	83 c1 02             	add    $0x2,%ecx
  800a95:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9a:	eb c4                	jmp    800a60 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a9c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9f:	89 f3                	mov    %esi,%ebx
  800aa1:	80 fb 19             	cmp    $0x19,%bl
  800aa4:	77 29                	ja     800acf <strtol+0xb3>
			dig = *s - 'a' + 10;
  800aa6:	0f be d2             	movsbl %dl,%edx
  800aa9:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aac:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aaf:	7d 30                	jge    800ae1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ab1:	83 c1 01             	add    $0x1,%ecx
  800ab4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab8:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aba:	0f b6 11             	movzbl (%ecx),%edx
  800abd:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac0:	89 f3                	mov    %esi,%ebx
  800ac2:	80 fb 09             	cmp    $0x9,%bl
  800ac5:	77 d5                	ja     800a9c <strtol+0x80>
			dig = *s - '0';
  800ac7:	0f be d2             	movsbl %dl,%edx
  800aca:	83 ea 30             	sub    $0x30,%edx
  800acd:	eb dd                	jmp    800aac <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800acf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ad2:	89 f3                	mov    %esi,%ebx
  800ad4:	80 fb 19             	cmp    $0x19,%bl
  800ad7:	77 08                	ja     800ae1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ad9:	0f be d2             	movsbl %dl,%edx
  800adc:	83 ea 37             	sub    $0x37,%edx
  800adf:	eb cb                	jmp    800aac <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ae1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae5:	74 05                	je     800aec <strtol+0xd0>
		*endptr = (char *) s;
  800ae7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aea:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aec:	89 c2                	mov    %eax,%edx
  800aee:	f7 da                	neg    %edx
  800af0:	85 ff                	test   %edi,%edi
  800af2:	0f 45 c2             	cmovne %edx,%eax
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b00:	b8 00 00 00 00       	mov    $0x0,%eax
  800b05:	8b 55 08             	mov    0x8(%ebp),%edx
  800b08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0b:	89 c3                	mov    %eax,%ebx
  800b0d:	89 c7                	mov    %eax,%edi
  800b0f:	89 c6                	mov    %eax,%esi
  800b11:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5f                   	pop    %edi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b23:	b8 01 00 00 00       	mov    $0x1,%eax
  800b28:	89 d1                	mov    %edx,%ecx
  800b2a:	89 d3                	mov    %edx,%ebx
  800b2c:	89 d7                	mov    %edx,%edi
  800b2e:	89 d6                	mov    %edx,%esi
  800b30:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	83 ec 1c             	sub    $0x1c,%esp
  800b40:	e8 66 00 00 00       	call   800bab <__x86.get_pc_thunk.ax>
  800b45:	05 bb 14 00 00       	add    $0x14bb,%eax
  800b4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	b8 03 00 00 00       	mov    $0x3,%eax
  800b5a:	89 cb                	mov    %ecx,%ebx
  800b5c:	89 cf                	mov    %ecx,%edi
  800b5e:	89 ce                	mov    %ecx,%esi
  800b60:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b62:	85 c0                	test   %eax,%eax
  800b64:	7f 08                	jg     800b6e <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6e:	83 ec 0c             	sub    $0xc,%esp
  800b71:	50                   	push   %eax
  800b72:	6a 03                	push   $0x3
  800b74:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800b77:	8d 83 5c f0 ff ff    	lea    -0xfa4(%ebx),%eax
  800b7d:	50                   	push   %eax
  800b7e:	6a 23                	push   $0x23
  800b80:	8d 83 79 f0 ff ff    	lea    -0xf87(%ebx),%eax
  800b86:	50                   	push   %eax
  800b87:	e8 23 00 00 00       	call   800baf <_panic>

00800b8c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	57                   	push   %edi
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b92:	ba 00 00 00 00       	mov    $0x0,%edx
  800b97:	b8 02 00 00 00       	mov    $0x2,%eax
  800b9c:	89 d1                	mov    %edx,%ecx
  800b9e:	89 d3                	mov    %edx,%ebx
  800ba0:	89 d7                	mov    %edx,%edi
  800ba2:	89 d6                	mov    %edx,%esi
  800ba4:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5f                   	pop    %edi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <__x86.get_pc_thunk.ax>:
  800bab:	8b 04 24             	mov    (%esp),%eax
  800bae:	c3                   	ret    

00800baf <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 0c             	sub    $0xc,%esp
  800bb8:	e8 a2 f4 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800bbd:	81 c3 43 14 00 00    	add    $0x1443,%ebx
	va_list ap;

	va_start(ap, fmt);
  800bc3:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bc6:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800bcc:	8b 38                	mov    (%eax),%edi
  800bce:	e8 b9 ff ff ff       	call   800b8c <sys_getenvid>
  800bd3:	83 ec 0c             	sub    $0xc,%esp
  800bd6:	ff 75 0c             	pushl  0xc(%ebp)
  800bd9:	ff 75 08             	pushl  0x8(%ebp)
  800bdc:	57                   	push   %edi
  800bdd:	50                   	push   %eax
  800bde:	8d 83 88 f0 ff ff    	lea    -0xf78(%ebx),%eax
  800be4:	50                   	push   %eax
  800be5:	e8 a9 f5 ff ff       	call   800193 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bea:	83 c4 18             	add    $0x18,%esp
  800bed:	56                   	push   %esi
  800bee:	ff 75 10             	pushl  0x10(%ebp)
  800bf1:	e8 3b f5 ff ff       	call   800131 <vcprintf>
	cprintf("\n");
  800bf6:	8d 83 68 ee ff ff    	lea    -0x1198(%ebx),%eax
  800bfc:	89 04 24             	mov    %eax,(%esp)
  800bff:	e8 8f f5 ff ff       	call   800193 <cprintf>
  800c04:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c07:	cc                   	int3   
  800c08:	eb fd                	jmp    800c07 <_panic+0x58>
  800c0a:	66 90                	xchg   %ax,%ax
  800c0c:	66 90                	xchg   %ax,%ax
  800c0e:	66 90                	xchg   %ax,%ax

00800c10 <__udivdi3>:
  800c10:	55                   	push   %ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	83 ec 1c             	sub    $0x1c,%esp
  800c17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c1b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c23:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c27:	85 d2                	test   %edx,%edx
  800c29:	75 35                	jne    800c60 <__udivdi3+0x50>
  800c2b:	39 f3                	cmp    %esi,%ebx
  800c2d:	0f 87 bd 00 00 00    	ja     800cf0 <__udivdi3+0xe0>
  800c33:	85 db                	test   %ebx,%ebx
  800c35:	89 d9                	mov    %ebx,%ecx
  800c37:	75 0b                	jne    800c44 <__udivdi3+0x34>
  800c39:	b8 01 00 00 00       	mov    $0x1,%eax
  800c3e:	31 d2                	xor    %edx,%edx
  800c40:	f7 f3                	div    %ebx
  800c42:	89 c1                	mov    %eax,%ecx
  800c44:	31 d2                	xor    %edx,%edx
  800c46:	89 f0                	mov    %esi,%eax
  800c48:	f7 f1                	div    %ecx
  800c4a:	89 c6                	mov    %eax,%esi
  800c4c:	89 e8                	mov    %ebp,%eax
  800c4e:	89 f7                	mov    %esi,%edi
  800c50:	f7 f1                	div    %ecx
  800c52:	89 fa                	mov    %edi,%edx
  800c54:	83 c4 1c             	add    $0x1c,%esp
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    
  800c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c60:	39 f2                	cmp    %esi,%edx
  800c62:	77 7c                	ja     800ce0 <__udivdi3+0xd0>
  800c64:	0f bd fa             	bsr    %edx,%edi
  800c67:	83 f7 1f             	xor    $0x1f,%edi
  800c6a:	0f 84 98 00 00 00    	je     800d08 <__udivdi3+0xf8>
  800c70:	89 f9                	mov    %edi,%ecx
  800c72:	b8 20 00 00 00       	mov    $0x20,%eax
  800c77:	29 f8                	sub    %edi,%eax
  800c79:	d3 e2                	shl    %cl,%edx
  800c7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c7f:	89 c1                	mov    %eax,%ecx
  800c81:	89 da                	mov    %ebx,%edx
  800c83:	d3 ea                	shr    %cl,%edx
  800c85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c89:	09 d1                	or     %edx,%ecx
  800c8b:	89 f2                	mov    %esi,%edx
  800c8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c91:	89 f9                	mov    %edi,%ecx
  800c93:	d3 e3                	shl    %cl,%ebx
  800c95:	89 c1                	mov    %eax,%ecx
  800c97:	d3 ea                	shr    %cl,%edx
  800c99:	89 f9                	mov    %edi,%ecx
  800c9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800c9f:	d3 e6                	shl    %cl,%esi
  800ca1:	89 eb                	mov    %ebp,%ebx
  800ca3:	89 c1                	mov    %eax,%ecx
  800ca5:	d3 eb                	shr    %cl,%ebx
  800ca7:	09 de                	or     %ebx,%esi
  800ca9:	89 f0                	mov    %esi,%eax
  800cab:	f7 74 24 08          	divl   0x8(%esp)
  800caf:	89 d6                	mov    %edx,%esi
  800cb1:	89 c3                	mov    %eax,%ebx
  800cb3:	f7 64 24 0c          	mull   0xc(%esp)
  800cb7:	39 d6                	cmp    %edx,%esi
  800cb9:	72 0c                	jb     800cc7 <__udivdi3+0xb7>
  800cbb:	89 f9                	mov    %edi,%ecx
  800cbd:	d3 e5                	shl    %cl,%ebp
  800cbf:	39 c5                	cmp    %eax,%ebp
  800cc1:	73 5d                	jae    800d20 <__udivdi3+0x110>
  800cc3:	39 d6                	cmp    %edx,%esi
  800cc5:	75 59                	jne    800d20 <__udivdi3+0x110>
  800cc7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cca:	31 ff                	xor    %edi,%edi
  800ccc:	89 fa                	mov    %edi,%edx
  800cce:	83 c4 1c             	add    $0x1c,%esp
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    
  800cd6:	8d 76 00             	lea    0x0(%esi),%esi
  800cd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ce0:	31 ff                	xor    %edi,%edi
  800ce2:	31 c0                	xor    %eax,%eax
  800ce4:	89 fa                	mov    %edi,%edx
  800ce6:	83 c4 1c             	add    $0x1c,%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    
  800cee:	66 90                	xchg   %ax,%ax
  800cf0:	31 ff                	xor    %edi,%edi
  800cf2:	89 e8                	mov    %ebp,%eax
  800cf4:	89 f2                	mov    %esi,%edx
  800cf6:	f7 f3                	div    %ebx
  800cf8:	89 fa                	mov    %edi,%edx
  800cfa:	83 c4 1c             	add    $0x1c,%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    
  800d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d08:	39 f2                	cmp    %esi,%edx
  800d0a:	72 06                	jb     800d12 <__udivdi3+0x102>
  800d0c:	31 c0                	xor    %eax,%eax
  800d0e:	39 eb                	cmp    %ebp,%ebx
  800d10:	77 d2                	ja     800ce4 <__udivdi3+0xd4>
  800d12:	b8 01 00 00 00       	mov    $0x1,%eax
  800d17:	eb cb                	jmp    800ce4 <__udivdi3+0xd4>
  800d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d20:	89 d8                	mov    %ebx,%eax
  800d22:	31 ff                	xor    %edi,%edi
  800d24:	eb be                	jmp    800ce4 <__udivdi3+0xd4>
  800d26:	66 90                	xchg   %ax,%ax
  800d28:	66 90                	xchg   %ax,%ax
  800d2a:	66 90                	xchg   %ax,%ax
  800d2c:	66 90                	xchg   %ax,%ax
  800d2e:	66 90                	xchg   %ax,%ax

00800d30 <__umoddi3>:
  800d30:	55                   	push   %ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 1c             	sub    $0x1c,%esp
  800d37:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d47:	85 ed                	test   %ebp,%ebp
  800d49:	89 f0                	mov    %esi,%eax
  800d4b:	89 da                	mov    %ebx,%edx
  800d4d:	75 19                	jne    800d68 <__umoddi3+0x38>
  800d4f:	39 df                	cmp    %ebx,%edi
  800d51:	0f 86 b1 00 00 00    	jbe    800e08 <__umoddi3+0xd8>
  800d57:	f7 f7                	div    %edi
  800d59:	89 d0                	mov    %edx,%eax
  800d5b:	31 d2                	xor    %edx,%edx
  800d5d:	83 c4 1c             	add    $0x1c,%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    
  800d65:	8d 76 00             	lea    0x0(%esi),%esi
  800d68:	39 dd                	cmp    %ebx,%ebp
  800d6a:	77 f1                	ja     800d5d <__umoddi3+0x2d>
  800d6c:	0f bd cd             	bsr    %ebp,%ecx
  800d6f:	83 f1 1f             	xor    $0x1f,%ecx
  800d72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d76:	0f 84 b4 00 00 00    	je     800e30 <__umoddi3+0x100>
  800d7c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d81:	89 c2                	mov    %eax,%edx
  800d83:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d87:	29 c2                	sub    %eax,%edx
  800d89:	89 c1                	mov    %eax,%ecx
  800d8b:	89 f8                	mov    %edi,%eax
  800d8d:	d3 e5                	shl    %cl,%ebp
  800d8f:	89 d1                	mov    %edx,%ecx
  800d91:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d95:	d3 e8                	shr    %cl,%eax
  800d97:	09 c5                	or     %eax,%ebp
  800d99:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d9d:	89 c1                	mov    %eax,%ecx
  800d9f:	d3 e7                	shl    %cl,%edi
  800da1:	89 d1                	mov    %edx,%ecx
  800da3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800da7:	89 df                	mov    %ebx,%edi
  800da9:	d3 ef                	shr    %cl,%edi
  800dab:	89 c1                	mov    %eax,%ecx
  800dad:	89 f0                	mov    %esi,%eax
  800daf:	d3 e3                	shl    %cl,%ebx
  800db1:	89 d1                	mov    %edx,%ecx
  800db3:	89 fa                	mov    %edi,%edx
  800db5:	d3 e8                	shr    %cl,%eax
  800db7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dbc:	09 d8                	or     %ebx,%eax
  800dbe:	f7 f5                	div    %ebp
  800dc0:	d3 e6                	shl    %cl,%esi
  800dc2:	89 d1                	mov    %edx,%ecx
  800dc4:	f7 64 24 08          	mull   0x8(%esp)
  800dc8:	39 d1                	cmp    %edx,%ecx
  800dca:	89 c3                	mov    %eax,%ebx
  800dcc:	89 d7                	mov    %edx,%edi
  800dce:	72 06                	jb     800dd6 <__umoddi3+0xa6>
  800dd0:	75 0e                	jne    800de0 <__umoddi3+0xb0>
  800dd2:	39 c6                	cmp    %eax,%esi
  800dd4:	73 0a                	jae    800de0 <__umoddi3+0xb0>
  800dd6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800dda:	19 ea                	sbb    %ebp,%edx
  800ddc:	89 d7                	mov    %edx,%edi
  800dde:	89 c3                	mov    %eax,%ebx
  800de0:	89 ca                	mov    %ecx,%edx
  800de2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800de7:	29 de                	sub    %ebx,%esi
  800de9:	19 fa                	sbb    %edi,%edx
  800deb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800def:	89 d0                	mov    %edx,%eax
  800df1:	d3 e0                	shl    %cl,%eax
  800df3:	89 d9                	mov    %ebx,%ecx
  800df5:	d3 ee                	shr    %cl,%esi
  800df7:	d3 ea                	shr    %cl,%edx
  800df9:	09 f0                	or     %esi,%eax
  800dfb:	83 c4 1c             	add    $0x1c,%esp
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    
  800e03:	90                   	nop
  800e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e08:	85 ff                	test   %edi,%edi
  800e0a:	89 f9                	mov    %edi,%ecx
  800e0c:	75 0b                	jne    800e19 <__umoddi3+0xe9>
  800e0e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e13:	31 d2                	xor    %edx,%edx
  800e15:	f7 f7                	div    %edi
  800e17:	89 c1                	mov    %eax,%ecx
  800e19:	89 d8                	mov    %ebx,%eax
  800e1b:	31 d2                	xor    %edx,%edx
  800e1d:	f7 f1                	div    %ecx
  800e1f:	89 f0                	mov    %esi,%eax
  800e21:	f7 f1                	div    %ecx
  800e23:	e9 31 ff ff ff       	jmp    800d59 <__umoddi3+0x29>
  800e28:	90                   	nop
  800e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e30:	39 dd                	cmp    %ebx,%ebp
  800e32:	72 08                	jb     800e3c <__umoddi3+0x10c>
  800e34:	39 f7                	cmp    %esi,%edi
  800e36:	0f 87 21 ff ff ff    	ja     800d5d <__umoddi3+0x2d>
  800e3c:	89 da                	mov    %ebx,%edx
  800e3e:	89 f0                	mov    %esi,%eax
  800e40:	29 f8                	sub    %edi,%eax
  800e42:	19 ea                	sbb    %ebp,%edx
  800e44:	e9 14 ff ff ff       	jmp    800d5d <__umoddi3+0x2d>
