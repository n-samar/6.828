
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	57                   	push   %edi
  80003e:	56                   	push   %esi
  80003f:	53                   	push   %ebx
  800040:	83 ec 0c             	sub    $0xc,%esp
  800043:	e8 50 00 00 00       	call   800098 <__x86.get_pc_thunk.bx>
  800048:	81 c3 b8 1f 00 00    	add    $0x1fb8,%ebx
  80004e:	8b 75 08             	mov    0x8(%ebp),%esi
  800051:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

	thisenv = envs+ENVX(sys_getenvid());
  800054:	e8 f6 00 00 00       	call   80014f <sys_getenvid>
  800059:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005e:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800061:	c1 e0 05             	shl    $0x5,%eax
  800064:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80006a:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  800070:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800072:	85 f6                	test   %esi,%esi
  800074:	7e 08                	jle    80007e <libmain+0x44>
		binaryname = argv[0];
  800076:	8b 07                	mov    (%edi),%eax
  800078:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	e8 ab ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800088:	e8 0f 00 00 00       	call   80009c <exit>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5f                   	pop    %edi
  800096:	5d                   	pop    %ebp
  800097:	c3                   	ret    

00800098 <__x86.get_pc_thunk.bx>:
  800098:	8b 1c 24             	mov    (%esp),%ebx
  80009b:	c3                   	ret    

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	53                   	push   %ebx
  8000a0:	83 ec 10             	sub    $0x10,%esp
  8000a3:	e8 f0 ff ff ff       	call   800098 <__x86.get_pc_thunk.bx>
  8000a8:	81 c3 58 1f 00 00    	add    $0x1f58,%ebx
	sys_env_destroy(0);
  8000ae:	6a 00                	push   $0x0
  8000b0:	e8 45 00 00 00       	call   8000fa <sys_env_destroy>
}
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ce:	89 c3                	mov    %eax,%ebx
  8000d0:	89 c7                	mov    %eax,%edi
  8000d2:	89 c6                	mov    %eax,%esi
  8000d4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_cgetc>:

int
sys_cgetc(void)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000eb:	89 d1                	mov    %edx,%ecx
  8000ed:	89 d3                	mov    %edx,%ebx
  8000ef:	89 d7                	mov    %edx,%edi
  8000f1:	89 d6                	mov    %edx,%esi
  8000f3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	57                   	push   %edi
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	83 ec 1c             	sub    $0x1c,%esp
  800103:	e8 66 00 00 00       	call   80016e <__x86.get_pc_thunk.ax>
  800108:	05 f8 1e 00 00       	add    $0x1ef8,%eax
  80010d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800110:	b9 00 00 00 00       	mov    $0x0,%ecx
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	b8 03 00 00 00       	mov    $0x3,%eax
  80011d:	89 cb                	mov    %ecx,%ebx
  80011f:	89 cf                	mov    %ecx,%edi
  800121:	89 ce                	mov    %ecx,%esi
  800123:	cd 30                	int    $0x30
	if(check && ret > 0)
  800125:	85 c0                	test   %eax,%eax
  800127:	7f 08                	jg     800131 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800129:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012c:	5b                   	pop    %ebx
  80012d:	5e                   	pop    %esi
  80012e:	5f                   	pop    %edi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800131:	83 ec 0c             	sub    $0xc,%esp
  800134:	50                   	push   %eax
  800135:	6a 03                	push   $0x3
  800137:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80013a:	8d 83 36 ee ff ff    	lea    -0x11ca(%ebx),%eax
  800140:	50                   	push   %eax
  800141:	6a 23                	push   $0x23
  800143:	8d 83 53 ee ff ff    	lea    -0x11ad(%ebx),%eax
  800149:	50                   	push   %eax
  80014a:	e8 23 00 00 00       	call   800172 <_panic>

0080014f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	asm volatile("int %1\n"
  800155:	ba 00 00 00 00       	mov    $0x0,%edx
  80015a:	b8 02 00 00 00       	mov    $0x2,%eax
  80015f:	89 d1                	mov    %edx,%ecx
  800161:	89 d3                	mov    %edx,%ebx
  800163:	89 d7                	mov    %edx,%edi
  800165:	89 d6                	mov    %edx,%esi
  800167:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800169:	5b                   	pop    %ebx
  80016a:	5e                   	pop    %esi
  80016b:	5f                   	pop    %edi
  80016c:	5d                   	pop    %ebp
  80016d:	c3                   	ret    

0080016e <__x86.get_pc_thunk.ax>:
  80016e:	8b 04 24             	mov    (%esp),%eax
  800171:	c3                   	ret    

00800172 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
  800178:	83 ec 0c             	sub    $0xc,%esp
  80017b:	e8 18 ff ff ff       	call   800098 <__x86.get_pc_thunk.bx>
  800180:	81 c3 80 1e 00 00    	add    $0x1e80,%ebx
	va_list ap;

	va_start(ap, fmt);
  800186:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800189:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  80018f:	8b 38                	mov    (%eax),%edi
  800191:	e8 b9 ff ff ff       	call   80014f <sys_getenvid>
  800196:	83 ec 0c             	sub    $0xc,%esp
  800199:	ff 75 0c             	pushl  0xc(%ebp)
  80019c:	ff 75 08             	pushl  0x8(%ebp)
  80019f:	57                   	push   %edi
  8001a0:	50                   	push   %eax
  8001a1:	8d 83 64 ee ff ff    	lea    -0x119c(%ebx),%eax
  8001a7:	50                   	push   %eax
  8001a8:	e8 d1 00 00 00       	call   80027e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ad:	83 c4 18             	add    $0x18,%esp
  8001b0:	56                   	push   %esi
  8001b1:	ff 75 10             	pushl  0x10(%ebp)
  8001b4:	e8 63 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001b9:	8d 83 88 ee ff ff    	lea    -0x1178(%ebx),%eax
  8001bf:	89 04 24             	mov    %eax,(%esp)
  8001c2:	e8 b7 00 00 00       	call   80027e <cprintf>
  8001c7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ca:	cc                   	int3   
  8001cb:	eb fd                	jmp    8001ca <_panic+0x58>

008001cd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	e8 c1 fe ff ff       	call   800098 <__x86.get_pc_thunk.bx>
  8001d7:	81 c3 29 1e 00 00    	add    $0x1e29,%ebx
  8001dd:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001e0:	8b 16                	mov    (%esi),%edx
  8001e2:	8d 42 01             	lea    0x1(%edx),%eax
  8001e5:	89 06                	mov    %eax,(%esi)
  8001e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ea:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f3:	74 0b                	je     800200 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f5:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fc:	5b                   	pop    %ebx
  8001fd:	5e                   	pop    %esi
  8001fe:	5d                   	pop    %ebp
  8001ff:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	68 ff 00 00 00       	push   $0xff
  800208:	8d 46 08             	lea    0x8(%esi),%eax
  80020b:	50                   	push   %eax
  80020c:	e8 ac fe ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  800211:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb d9                	jmp    8001f5 <putch+0x28>

0080021c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	53                   	push   %ebx
  800220:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800226:	e8 6d fe ff ff       	call   800098 <__x86.get_pc_thunk.bx>
  80022b:	81 c3 d5 1d 00 00    	add    $0x1dd5,%ebx
	struct printbuf b;

	b.idx = 0;
  800231:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800238:	00 00 00 
	b.cnt = 0;
  80023b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800242:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800245:	ff 75 0c             	pushl  0xc(%ebp)
  800248:	ff 75 08             	pushl  0x8(%ebp)
  80024b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800251:	50                   	push   %eax
  800252:	8d 83 cd e1 ff ff    	lea    -0x1e33(%ebx),%eax
  800258:	50                   	push   %eax
  800259:	e8 38 01 00 00       	call   800396 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025e:	83 c4 08             	add    $0x8,%esp
  800261:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800267:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026d:	50                   	push   %eax
  80026e:	e8 4a fe ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  800273:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800279:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    

0080027e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800284:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800287:	50                   	push   %eax
  800288:	ff 75 08             	pushl  0x8(%ebp)
  80028b:	e8 8c ff ff ff       	call   80021c <vcprintf>
	va_end(ap);

	return cnt;
}
  800290:	c9                   	leave  
  800291:	c3                   	ret    

00800292 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	57                   	push   %edi
  800296:	56                   	push   %esi
  800297:	53                   	push   %ebx
  800298:	83 ec 2c             	sub    $0x2c,%esp
  80029b:	e8 cd 05 00 00       	call   80086d <__x86.get_pc_thunk.cx>
  8002a0:	81 c1 60 1d 00 00    	add    $0x1d60,%ecx
  8002a6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002a9:	89 c7                	mov    %eax,%edi
  8002ab:	89 d6                	mov    %edx,%esi
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002b6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002c4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002c7:	39 d3                	cmp    %edx,%ebx
  8002c9:	72 09                	jb     8002d4 <printnum+0x42>
  8002cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ce:	0f 87 83 00 00 00    	ja     800357 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	ff 75 18             	pushl  0x18(%ebp)
  8002da:	8b 45 14             	mov    0x14(%ebp),%eax
  8002dd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e0:	53                   	push   %ebx
  8002e1:	ff 75 10             	pushl  0x10(%ebp)
  8002e4:	83 ec 08             	sub    $0x8,%esp
  8002e7:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ea:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ed:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002f0:	ff 75 d0             	pushl  -0x30(%ebp)
  8002f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002f6:	e8 f5 08 00 00       	call   800bf0 <__udivdi3>
  8002fb:	83 c4 18             	add    $0x18,%esp
  8002fe:	52                   	push   %edx
  8002ff:	50                   	push   %eax
  800300:	89 f2                	mov    %esi,%edx
  800302:	89 f8                	mov    %edi,%eax
  800304:	e8 89 ff ff ff       	call   800292 <printnum>
  800309:	83 c4 20             	add    $0x20,%esp
  80030c:	eb 13                	jmp    800321 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030e:	83 ec 08             	sub    $0x8,%esp
  800311:	56                   	push   %esi
  800312:	ff 75 18             	pushl  0x18(%ebp)
  800315:	ff d7                	call   *%edi
  800317:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80031a:	83 eb 01             	sub    $0x1,%ebx
  80031d:	85 db                	test   %ebx,%ebx
  80031f:	7f ed                	jg     80030e <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800321:	83 ec 08             	sub    $0x8,%esp
  800324:	56                   	push   %esi
  800325:	83 ec 04             	sub    $0x4,%esp
  800328:	ff 75 dc             	pushl  -0x24(%ebp)
  80032b:	ff 75 d8             	pushl  -0x28(%ebp)
  80032e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800331:	ff 75 d0             	pushl  -0x30(%ebp)
  800334:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800337:	89 f3                	mov    %esi,%ebx
  800339:	e8 d2 09 00 00       	call   800d10 <__umoddi3>
  80033e:	83 c4 14             	add    $0x14,%esp
  800341:	0f be 84 06 8a ee ff 	movsbl -0x1176(%esi,%eax,1),%eax
  800348:	ff 
  800349:	50                   	push   %eax
  80034a:	ff d7                	call   *%edi
}
  80034c:	83 c4 10             	add    $0x10,%esp
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    
  800357:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80035a:	eb be                	jmp    80031a <printnum+0x88>

0080035c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800362:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800366:	8b 10                	mov    (%eax),%edx
  800368:	3b 50 04             	cmp    0x4(%eax),%edx
  80036b:	73 0a                	jae    800377 <sprintputch+0x1b>
		*b->buf++ = ch;
  80036d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800370:	89 08                	mov    %ecx,(%eax)
  800372:	8b 45 08             	mov    0x8(%ebp),%eax
  800375:	88 02                	mov    %al,(%edx)
}
  800377:	5d                   	pop    %ebp
  800378:	c3                   	ret    

00800379 <printfmt>:
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80037f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800382:	50                   	push   %eax
  800383:	ff 75 10             	pushl  0x10(%ebp)
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	ff 75 08             	pushl  0x8(%ebp)
  80038c:	e8 05 00 00 00       	call   800396 <vprintfmt>
}
  800391:	83 c4 10             	add    $0x10,%esp
  800394:	c9                   	leave  
  800395:	c3                   	ret    

00800396 <vprintfmt>:
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	57                   	push   %edi
  80039a:	56                   	push   %esi
  80039b:	53                   	push   %ebx
  80039c:	83 ec 2c             	sub    $0x2c,%esp
  80039f:	e8 f4 fc ff ff       	call   800098 <__x86.get_pc_thunk.bx>
  8003a4:	81 c3 5c 1c 00 00    	add    $0x1c5c,%ebx
  8003aa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003ad:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b0:	e9 8e 03 00 00       	jmp    800743 <.L35+0x48>
		padc = ' ';
  8003b5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003b9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003c0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003c7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8d 47 01             	lea    0x1(%edi),%eax
  8003d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003dc:	0f b6 17             	movzbl (%edi),%edx
  8003df:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003e2:	3c 55                	cmp    $0x55,%al
  8003e4:	0f 87 e1 03 00 00    	ja     8007cb <.L22>
  8003ea:	0f b6 c0             	movzbl %al,%eax
  8003ed:	89 d9                	mov    %ebx,%ecx
  8003ef:	03 8c 83 18 ef ff ff 	add    -0x10e8(%ebx,%eax,4),%ecx
  8003f6:	ff e1                	jmp    *%ecx

008003f8 <.L67>:
  8003f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003fb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003ff:	eb d5                	jmp    8003d6 <vprintfmt+0x40>

00800401 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800404:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800408:	eb cc                	jmp    8003d6 <vprintfmt+0x40>

0080040a <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	0f b6 d2             	movzbl %dl,%edx
  80040d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800410:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800415:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800418:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80041c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80041f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800422:	83 f9 09             	cmp    $0x9,%ecx
  800425:	77 55                	ja     80047c <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  800427:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80042a:	eb e9                	jmp    800415 <.L29+0xb>

0080042c <.L26>:
			precision = va_arg(ap, int);
  80042c:	8b 45 14             	mov    0x14(%ebp),%eax
  80042f:	8b 00                	mov    (%eax),%eax
  800431:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 40 04             	lea    0x4(%eax),%eax
  80043a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800440:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800444:	79 90                	jns    8003d6 <vprintfmt+0x40>
				width = precision, precision = -1;
  800446:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800449:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800453:	eb 81                	jmp    8003d6 <vprintfmt+0x40>

00800455 <.L27>:
  800455:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800458:	85 c0                	test   %eax,%eax
  80045a:	ba 00 00 00 00       	mov    $0x0,%edx
  80045f:	0f 49 d0             	cmovns %eax,%edx
  800462:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800468:	e9 69 ff ff ff       	jmp    8003d6 <vprintfmt+0x40>

0080046d <.L23>:
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800470:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800477:	e9 5a ff ff ff       	jmp    8003d6 <vprintfmt+0x40>
  80047c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80047f:	eb bf                	jmp    800440 <.L26+0x14>

00800481 <.L33>:
			lflag++;
  800481:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800488:	e9 49 ff ff ff       	jmp    8003d6 <vprintfmt+0x40>

0080048d <.L30>:
			putch(va_arg(ap, int), putdat);
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8d 78 04             	lea    0x4(%eax),%edi
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	56                   	push   %esi
  800497:	ff 30                	pushl  (%eax)
  800499:	ff 55 08             	call   *0x8(%ebp)
			break;
  80049c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80049f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004a2:	e9 99 02 00 00       	jmp    800740 <.L35+0x45>

008004a7 <.L32>:
			err = va_arg(ap, int);
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8d 78 04             	lea    0x4(%eax),%edi
  8004ad:	8b 00                	mov    (%eax),%eax
  8004af:	99                   	cltd   
  8004b0:	31 d0                	xor    %edx,%eax
  8004b2:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b4:	83 f8 06             	cmp    $0x6,%eax
  8004b7:	7f 27                	jg     8004e0 <.L32+0x39>
  8004b9:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004c0:	85 d2                	test   %edx,%edx
  8004c2:	74 1c                	je     8004e0 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004c4:	52                   	push   %edx
  8004c5:	8d 83 ab ee ff ff    	lea    -0x1155(%ebx),%eax
  8004cb:	50                   	push   %eax
  8004cc:	56                   	push   %esi
  8004cd:	ff 75 08             	pushl  0x8(%ebp)
  8004d0:	e8 a4 fe ff ff       	call   800379 <printfmt>
  8004d5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004d8:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004db:	e9 60 02 00 00       	jmp    800740 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004e0:	50                   	push   %eax
  8004e1:	8d 83 a2 ee ff ff    	lea    -0x115e(%ebx),%eax
  8004e7:	50                   	push   %eax
  8004e8:	56                   	push   %esi
  8004e9:	ff 75 08             	pushl  0x8(%ebp)
  8004ec:	e8 88 fe ff ff       	call   800379 <printfmt>
  8004f1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f4:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004f7:	e9 44 02 00 00       	jmp    800740 <.L35+0x45>

008004fc <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  8004fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ff:	83 c0 04             	add    $0x4,%eax
  800502:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80050a:	85 ff                	test   %edi,%edi
  80050c:	8d 83 9b ee ff ff    	lea    -0x1165(%ebx),%eax
  800512:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800515:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800519:	0f 8e b5 00 00 00    	jle    8005d4 <.L36+0xd8>
  80051f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800523:	75 08                	jne    80052d <.L36+0x31>
  800525:	89 75 0c             	mov    %esi,0xc(%ebp)
  800528:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052b:	eb 6d                	jmp    80059a <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	ff 75 d0             	pushl  -0x30(%ebp)
  800533:	57                   	push   %edi
  800534:	e8 50 03 00 00       	call   800889 <strnlen>
  800539:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80053c:	29 c2                	sub    %eax,%edx
  80053e:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800541:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800544:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800548:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80054e:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800550:	eb 10                	jmp    800562 <.L36+0x66>
					putch(padc, putdat);
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	56                   	push   %esi
  800556:	ff 75 e0             	pushl  -0x20(%ebp)
  800559:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80055c:	83 ef 01             	sub    $0x1,%edi
  80055f:	83 c4 10             	add    $0x10,%esp
  800562:	85 ff                	test   %edi,%edi
  800564:	7f ec                	jg     800552 <.L36+0x56>
  800566:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800569:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80056c:	85 d2                	test   %edx,%edx
  80056e:	b8 00 00 00 00       	mov    $0x0,%eax
  800573:	0f 49 c2             	cmovns %edx,%eax
  800576:	29 c2                	sub    %eax,%edx
  800578:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80057b:	89 75 0c             	mov    %esi,0xc(%ebp)
  80057e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800581:	eb 17                	jmp    80059a <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800583:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800587:	75 30                	jne    8005b9 <.L36+0xbd>
					putch(ch, putdat);
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	ff 75 0c             	pushl  0xc(%ebp)
  80058f:	50                   	push   %eax
  800590:	ff 55 08             	call   *0x8(%ebp)
  800593:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800596:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80059a:	83 c7 01             	add    $0x1,%edi
  80059d:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005a1:	0f be c2             	movsbl %dl,%eax
  8005a4:	85 c0                	test   %eax,%eax
  8005a6:	74 52                	je     8005fa <.L36+0xfe>
  8005a8:	85 f6                	test   %esi,%esi
  8005aa:	78 d7                	js     800583 <.L36+0x87>
  8005ac:	83 ee 01             	sub    $0x1,%esi
  8005af:	79 d2                	jns    800583 <.L36+0x87>
  8005b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005b4:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005b7:	eb 32                	jmp    8005eb <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005b9:	0f be d2             	movsbl %dl,%edx
  8005bc:	83 ea 20             	sub    $0x20,%edx
  8005bf:	83 fa 5e             	cmp    $0x5e,%edx
  8005c2:	76 c5                	jbe    800589 <.L36+0x8d>
					putch('?', putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	ff 75 0c             	pushl  0xc(%ebp)
  8005ca:	6a 3f                	push   $0x3f
  8005cc:	ff 55 08             	call   *0x8(%ebp)
  8005cf:	83 c4 10             	add    $0x10,%esp
  8005d2:	eb c2                	jmp    800596 <.L36+0x9a>
  8005d4:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005d7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005da:	eb be                	jmp    80059a <.L36+0x9e>
				putch(' ', putdat);
  8005dc:	83 ec 08             	sub    $0x8,%esp
  8005df:	56                   	push   %esi
  8005e0:	6a 20                	push   $0x20
  8005e2:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005e5:	83 ef 01             	sub    $0x1,%edi
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	85 ff                	test   %edi,%edi
  8005ed:	7f ed                	jg     8005dc <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8005ef:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005f2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f5:	e9 46 01 00 00       	jmp    800740 <.L35+0x45>
  8005fa:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800600:	eb e9                	jmp    8005eb <.L36+0xef>

00800602 <.L31>:
  800602:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  800605:	83 f9 01             	cmp    $0x1,%ecx
  800608:	7e 40                	jle    80064a <.L31+0x48>
		return va_arg(*ap, long long);
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8b 50 04             	mov    0x4(%eax),%edx
  800610:	8b 00                	mov    (%eax),%eax
  800612:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800615:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 40 08             	lea    0x8(%eax),%eax
  80061e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800621:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800625:	79 55                	jns    80067c <.L31+0x7a>
				putch('-', putdat);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	56                   	push   %esi
  80062b:	6a 2d                	push   $0x2d
  80062d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800630:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800633:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800636:	f7 da                	neg    %edx
  800638:	83 d1 00             	adc    $0x0,%ecx
  80063b:	f7 d9                	neg    %ecx
  80063d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800640:	b8 0a 00 00 00       	mov    $0xa,%eax
  800645:	e9 db 00 00 00       	jmp    800725 <.L35+0x2a>
	else if (lflag)
  80064a:	85 c9                	test   %ecx,%ecx
  80064c:	75 17                	jne    800665 <.L31+0x63>
		return va_arg(*ap, int);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8b 00                	mov    (%eax),%eax
  800653:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800656:	99                   	cltd   
  800657:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8d 40 04             	lea    0x4(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
  800663:	eb bc                	jmp    800621 <.L31+0x1f>
		return va_arg(*ap, long);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8b 00                	mov    (%eax),%eax
  80066a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066d:	99                   	cltd   
  80066e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8d 40 04             	lea    0x4(%eax),%eax
  800677:	89 45 14             	mov    %eax,0x14(%ebp)
  80067a:	eb a5                	jmp    800621 <.L31+0x1f>
			num = getint(&ap, lflag);
  80067c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80067f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800682:	b8 0a 00 00 00       	mov    $0xa,%eax
  800687:	e9 99 00 00 00       	jmp    800725 <.L35+0x2a>

0080068c <.L37>:
  80068c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  80068f:	83 f9 01             	cmp    $0x1,%ecx
  800692:	7e 15                	jle    8006a9 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 10                	mov    (%eax),%edx
  800699:	8b 48 04             	mov    0x4(%eax),%ecx
  80069c:	8d 40 08             	lea    0x8(%eax),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a7:	eb 7c                	jmp    800725 <.L35+0x2a>
	else if (lflag)
  8006a9:	85 c9                	test   %ecx,%ecx
  8006ab:	75 17                	jne    8006c4 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8b 10                	mov    (%eax),%edx
  8006b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006bd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c2:	eb 61                	jmp    800725 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 10                	mov    (%eax),%edx
  8006c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ce:	8d 40 04             	lea    0x4(%eax),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d9:	eb 4a                	jmp    800725 <.L35+0x2a>

008006db <.L34>:
			putch('X', putdat);
  8006db:	83 ec 08             	sub    $0x8,%esp
  8006de:	56                   	push   %esi
  8006df:	6a 58                	push   $0x58
  8006e1:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006e4:	83 c4 08             	add    $0x8,%esp
  8006e7:	56                   	push   %esi
  8006e8:	6a 58                	push   $0x58
  8006ea:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006ed:	83 c4 08             	add    $0x8,%esp
  8006f0:	56                   	push   %esi
  8006f1:	6a 58                	push   $0x58
  8006f3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	eb 45                	jmp    800740 <.L35+0x45>

008006fb <.L35>:
			putch('0', putdat);
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	56                   	push   %esi
  8006ff:	6a 30                	push   $0x30
  800701:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800704:	83 c4 08             	add    $0x8,%esp
  800707:	56                   	push   %esi
  800708:	6a 78                	push   $0x78
  80070a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8b 10                	mov    (%eax),%edx
  800712:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800717:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80071a:	8d 40 04             	lea    0x4(%eax),%eax
  80071d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800720:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800725:	83 ec 0c             	sub    $0xc,%esp
  800728:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80072c:	57                   	push   %edi
  80072d:	ff 75 e0             	pushl  -0x20(%ebp)
  800730:	50                   	push   %eax
  800731:	51                   	push   %ecx
  800732:	52                   	push   %edx
  800733:	89 f2                	mov    %esi,%edx
  800735:	8b 45 08             	mov    0x8(%ebp),%eax
  800738:	e8 55 fb ff ff       	call   800292 <printnum>
			break;
  80073d:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800740:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800743:	83 c7 01             	add    $0x1,%edi
  800746:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80074a:	83 f8 25             	cmp    $0x25,%eax
  80074d:	0f 84 62 fc ff ff    	je     8003b5 <vprintfmt+0x1f>
			if (ch == '\0')
  800753:	85 c0                	test   %eax,%eax
  800755:	0f 84 91 00 00 00    	je     8007ec <.L22+0x21>
			putch(ch, putdat);
  80075b:	83 ec 08             	sub    $0x8,%esp
  80075e:	56                   	push   %esi
  80075f:	50                   	push   %eax
  800760:	ff 55 08             	call   *0x8(%ebp)
  800763:	83 c4 10             	add    $0x10,%esp
  800766:	eb db                	jmp    800743 <.L35+0x48>

00800768 <.L38>:
  800768:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  80076b:	83 f9 01             	cmp    $0x1,%ecx
  80076e:	7e 15                	jle    800785 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  800770:	8b 45 14             	mov    0x14(%ebp),%eax
  800773:	8b 10                	mov    (%eax),%edx
  800775:	8b 48 04             	mov    0x4(%eax),%ecx
  800778:	8d 40 08             	lea    0x8(%eax),%eax
  80077b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80077e:	b8 10 00 00 00       	mov    $0x10,%eax
  800783:	eb a0                	jmp    800725 <.L35+0x2a>
	else if (lflag)
  800785:	85 c9                	test   %ecx,%ecx
  800787:	75 17                	jne    8007a0 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  800789:	8b 45 14             	mov    0x14(%ebp),%eax
  80078c:	8b 10                	mov    (%eax),%edx
  80078e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800793:	8d 40 04             	lea    0x4(%eax),%eax
  800796:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800799:	b8 10 00 00 00       	mov    $0x10,%eax
  80079e:	eb 85                	jmp    800725 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8b 10                	mov    (%eax),%edx
  8007a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007aa:	8d 40 04             	lea    0x4(%eax),%eax
  8007ad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b0:	b8 10 00 00 00       	mov    $0x10,%eax
  8007b5:	e9 6b ff ff ff       	jmp    800725 <.L35+0x2a>

008007ba <.L25>:
			putch(ch, putdat);
  8007ba:	83 ec 08             	sub    $0x8,%esp
  8007bd:	56                   	push   %esi
  8007be:	6a 25                	push   $0x25
  8007c0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007c3:	83 c4 10             	add    $0x10,%esp
  8007c6:	e9 75 ff ff ff       	jmp    800740 <.L35+0x45>

008007cb <.L22>:
			putch('%', putdat);
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	56                   	push   %esi
  8007cf:	6a 25                	push   $0x25
  8007d1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d4:	83 c4 10             	add    $0x10,%esp
  8007d7:	89 f8                	mov    %edi,%eax
  8007d9:	eb 03                	jmp    8007de <.L22+0x13>
  8007db:	83 e8 01             	sub    $0x1,%eax
  8007de:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007e2:	75 f7                	jne    8007db <.L22+0x10>
  8007e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007e7:	e9 54 ff ff ff       	jmp    800740 <.L35+0x45>
}
  8007ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ef:	5b                   	pop    %ebx
  8007f0:	5e                   	pop    %esi
  8007f1:	5f                   	pop    %edi
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	53                   	push   %ebx
  8007f8:	83 ec 14             	sub    $0x14,%esp
  8007fb:	e8 98 f8 ff ff       	call   800098 <__x86.get_pc_thunk.bx>
  800800:	81 c3 00 18 00 00    	add    $0x1800,%ebx
  800806:	8b 45 08             	mov    0x8(%ebp),%eax
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800813:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800816:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081d:	85 c0                	test   %eax,%eax
  80081f:	74 2b                	je     80084c <vsnprintf+0x58>
  800821:	85 d2                	test   %edx,%edx
  800823:	7e 27                	jle    80084c <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800825:	ff 75 14             	pushl  0x14(%ebp)
  800828:	ff 75 10             	pushl  0x10(%ebp)
  80082b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082e:	50                   	push   %eax
  80082f:	8d 83 5c e3 ff ff    	lea    -0x1ca4(%ebx),%eax
  800835:	50                   	push   %eax
  800836:	e8 5b fb ff ff       	call   800396 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800841:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800844:	83 c4 10             	add    $0x10,%esp
}
  800847:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084a:	c9                   	leave  
  80084b:	c3                   	ret    
		return -E_INVAL;
  80084c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800851:	eb f4                	jmp    800847 <vsnprintf+0x53>

00800853 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800859:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80085c:	50                   	push   %eax
  80085d:	ff 75 10             	pushl  0x10(%ebp)
  800860:	ff 75 0c             	pushl  0xc(%ebp)
  800863:	ff 75 08             	pushl  0x8(%ebp)
  800866:	e8 89 ff ff ff       	call   8007f4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    

0080086d <__x86.get_pc_thunk.cx>:
  80086d:	8b 0c 24             	mov    (%esp),%ecx
  800870:	c3                   	ret    

00800871 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
  80087c:	eb 03                	jmp    800881 <strlen+0x10>
		n++;
  80087e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800881:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800885:	75 f7                	jne    80087e <strlen+0xd>
	return n;
}
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
  800897:	eb 03                	jmp    80089c <strnlen+0x13>
		n++;
  800899:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089c:	39 d0                	cmp    %edx,%eax
  80089e:	74 06                	je     8008a6 <strnlen+0x1d>
  8008a0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a4:	75 f3                	jne    800899 <strnlen+0x10>
	return n;
}
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	53                   	push   %ebx
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b2:	89 c2                	mov    %eax,%edx
  8008b4:	83 c1 01             	add    $0x1,%ecx
  8008b7:	83 c2 01             	add    $0x1,%edx
  8008ba:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008be:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008c1:	84 db                	test   %bl,%bl
  8008c3:	75 ef                	jne    8008b4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008c5:	5b                   	pop    %ebx
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	53                   	push   %ebx
  8008cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008cf:	53                   	push   %ebx
  8008d0:	e8 9c ff ff ff       	call   800871 <strlen>
  8008d5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008d8:	ff 75 0c             	pushl  0xc(%ebp)
  8008db:	01 d8                	add    %ebx,%eax
  8008dd:	50                   	push   %eax
  8008de:	e8 c5 ff ff ff       	call   8008a8 <strcpy>
	return dst;
}
  8008e3:	89 d8                	mov    %ebx,%eax
  8008e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e8:	c9                   	leave  
  8008e9:	c3                   	ret    

008008ea <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	56                   	push   %esi
  8008ee:	53                   	push   %ebx
  8008ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f5:	89 f3                	mov    %esi,%ebx
  8008f7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fa:	89 f2                	mov    %esi,%edx
  8008fc:	eb 0f                	jmp    80090d <strncpy+0x23>
		*dst++ = *src;
  8008fe:	83 c2 01             	add    $0x1,%edx
  800901:	0f b6 01             	movzbl (%ecx),%eax
  800904:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800907:	80 39 01             	cmpb   $0x1,(%ecx)
  80090a:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80090d:	39 da                	cmp    %ebx,%edx
  80090f:	75 ed                	jne    8008fe <strncpy+0x14>
	}
	return ret;
}
  800911:	89 f0                	mov    %esi,%eax
  800913:	5b                   	pop    %ebx
  800914:	5e                   	pop    %esi
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	56                   	push   %esi
  80091b:	53                   	push   %ebx
  80091c:	8b 75 08             	mov    0x8(%ebp),%esi
  80091f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800922:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800925:	89 f0                	mov    %esi,%eax
  800927:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80092b:	85 c9                	test   %ecx,%ecx
  80092d:	75 0b                	jne    80093a <strlcpy+0x23>
  80092f:	eb 17                	jmp    800948 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800931:	83 c2 01             	add    $0x1,%edx
  800934:	83 c0 01             	add    $0x1,%eax
  800937:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80093a:	39 d8                	cmp    %ebx,%eax
  80093c:	74 07                	je     800945 <strlcpy+0x2e>
  80093e:	0f b6 0a             	movzbl (%edx),%ecx
  800941:	84 c9                	test   %cl,%cl
  800943:	75 ec                	jne    800931 <strlcpy+0x1a>
		*dst = '\0';
  800945:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800948:	29 f0                	sub    %esi,%eax
}
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800954:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800957:	eb 06                	jmp    80095f <strcmp+0x11>
		p++, q++;
  800959:	83 c1 01             	add    $0x1,%ecx
  80095c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80095f:	0f b6 01             	movzbl (%ecx),%eax
  800962:	84 c0                	test   %al,%al
  800964:	74 04                	je     80096a <strcmp+0x1c>
  800966:	3a 02                	cmp    (%edx),%al
  800968:	74 ef                	je     800959 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80096a:	0f b6 c0             	movzbl %al,%eax
  80096d:	0f b6 12             	movzbl (%edx),%edx
  800970:	29 d0                	sub    %edx,%eax
}
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	53                   	push   %ebx
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097e:	89 c3                	mov    %eax,%ebx
  800980:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800983:	eb 06                	jmp    80098b <strncmp+0x17>
		n--, p++, q++;
  800985:	83 c0 01             	add    $0x1,%eax
  800988:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80098b:	39 d8                	cmp    %ebx,%eax
  80098d:	74 16                	je     8009a5 <strncmp+0x31>
  80098f:	0f b6 08             	movzbl (%eax),%ecx
  800992:	84 c9                	test   %cl,%cl
  800994:	74 04                	je     80099a <strncmp+0x26>
  800996:	3a 0a                	cmp    (%edx),%cl
  800998:	74 eb                	je     800985 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80099a:	0f b6 00             	movzbl (%eax),%eax
  80099d:	0f b6 12             	movzbl (%edx),%edx
  8009a0:	29 d0                	sub    %edx,%eax
}
  8009a2:	5b                   	pop    %ebx
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    
		return 0;
  8009a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009aa:	eb f6                	jmp    8009a2 <strncmp+0x2e>

008009ac <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b6:	0f b6 10             	movzbl (%eax),%edx
  8009b9:	84 d2                	test   %dl,%dl
  8009bb:	74 09                	je     8009c6 <strchr+0x1a>
		if (*s == c)
  8009bd:	38 ca                	cmp    %cl,%dl
  8009bf:	74 0a                	je     8009cb <strchr+0x1f>
	for (; *s; s++)
  8009c1:	83 c0 01             	add    $0x1,%eax
  8009c4:	eb f0                	jmp    8009b6 <strchr+0xa>
			return (char *) s;
	return 0;
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d7:	eb 03                	jmp    8009dc <strfind+0xf>
  8009d9:	83 c0 01             	add    $0x1,%eax
  8009dc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009df:	38 ca                	cmp    %cl,%dl
  8009e1:	74 04                	je     8009e7 <strfind+0x1a>
  8009e3:	84 d2                	test   %dl,%dl
  8009e5:	75 f2                	jne    8009d9 <strfind+0xc>
			break;
	return (char *) s;
}
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	57                   	push   %edi
  8009ed:	56                   	push   %esi
  8009ee:	53                   	push   %ebx
  8009ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f5:	85 c9                	test   %ecx,%ecx
  8009f7:	74 13                	je     800a0c <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ff:	75 05                	jne    800a06 <memset+0x1d>
  800a01:	f6 c1 03             	test   $0x3,%cl
  800a04:	74 0d                	je     800a13 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a09:	fc                   	cld    
  800a0a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0c:	89 f8                	mov    %edi,%eax
  800a0e:	5b                   	pop    %ebx
  800a0f:	5e                   	pop    %esi
  800a10:	5f                   	pop    %edi
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    
		c &= 0xFF;
  800a13:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a17:	89 d3                	mov    %edx,%ebx
  800a19:	c1 e3 08             	shl    $0x8,%ebx
  800a1c:	89 d0                	mov    %edx,%eax
  800a1e:	c1 e0 18             	shl    $0x18,%eax
  800a21:	89 d6                	mov    %edx,%esi
  800a23:	c1 e6 10             	shl    $0x10,%esi
  800a26:	09 f0                	or     %esi,%eax
  800a28:	09 c2                	or     %eax,%edx
  800a2a:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a2c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a2f:	89 d0                	mov    %edx,%eax
  800a31:	fc                   	cld    
  800a32:	f3 ab                	rep stos %eax,%es:(%edi)
  800a34:	eb d6                	jmp    800a0c <memset+0x23>

00800a36 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	57                   	push   %edi
  800a3a:	56                   	push   %esi
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a41:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a44:	39 c6                	cmp    %eax,%esi
  800a46:	73 35                	jae    800a7d <memmove+0x47>
  800a48:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a4b:	39 c2                	cmp    %eax,%edx
  800a4d:	76 2e                	jbe    800a7d <memmove+0x47>
		s += n;
		d += n;
  800a4f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a52:	89 d6                	mov    %edx,%esi
  800a54:	09 fe                	or     %edi,%esi
  800a56:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5c:	74 0c                	je     800a6a <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a5e:	83 ef 01             	sub    $0x1,%edi
  800a61:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a64:	fd                   	std    
  800a65:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a67:	fc                   	cld    
  800a68:	eb 21                	jmp    800a8b <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6a:	f6 c1 03             	test   $0x3,%cl
  800a6d:	75 ef                	jne    800a5e <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a6f:	83 ef 04             	sub    $0x4,%edi
  800a72:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a75:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a78:	fd                   	std    
  800a79:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7b:	eb ea                	jmp    800a67 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7d:	89 f2                	mov    %esi,%edx
  800a7f:	09 c2                	or     %eax,%edx
  800a81:	f6 c2 03             	test   $0x3,%dl
  800a84:	74 09                	je     800a8f <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a86:	89 c7                	mov    %eax,%edi
  800a88:	fc                   	cld    
  800a89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8b:	5e                   	pop    %esi
  800a8c:	5f                   	pop    %edi
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8f:	f6 c1 03             	test   $0x3,%cl
  800a92:	75 f2                	jne    800a86 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a94:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a97:	89 c7                	mov    %eax,%edi
  800a99:	fc                   	cld    
  800a9a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9c:	eb ed                	jmp    800a8b <memmove+0x55>

00800a9e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aa1:	ff 75 10             	pushl  0x10(%ebp)
  800aa4:	ff 75 0c             	pushl  0xc(%ebp)
  800aa7:	ff 75 08             	pushl  0x8(%ebp)
  800aaa:	e8 87 ff ff ff       	call   800a36 <memmove>
}
  800aaf:	c9                   	leave  
  800ab0:	c3                   	ret    

00800ab1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
  800ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abc:	89 c6                	mov    %eax,%esi
  800abe:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac1:	39 f0                	cmp    %esi,%eax
  800ac3:	74 1c                	je     800ae1 <memcmp+0x30>
		if (*s1 != *s2)
  800ac5:	0f b6 08             	movzbl (%eax),%ecx
  800ac8:	0f b6 1a             	movzbl (%edx),%ebx
  800acb:	38 d9                	cmp    %bl,%cl
  800acd:	75 08                	jne    800ad7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800acf:	83 c0 01             	add    $0x1,%eax
  800ad2:	83 c2 01             	add    $0x1,%edx
  800ad5:	eb ea                	jmp    800ac1 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800ad7:	0f b6 c1             	movzbl %cl,%eax
  800ada:	0f b6 db             	movzbl %bl,%ebx
  800add:	29 d8                	sub    %ebx,%eax
  800adf:	eb 05                	jmp    800ae6 <memcmp+0x35>
	}

	return 0;
  800ae1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800af3:	89 c2                	mov    %eax,%edx
  800af5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af8:	39 d0                	cmp    %edx,%eax
  800afa:	73 09                	jae    800b05 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800afc:	38 08                	cmp    %cl,(%eax)
  800afe:	74 05                	je     800b05 <memfind+0x1b>
	for (; s < ends; s++)
  800b00:	83 c0 01             	add    $0x1,%eax
  800b03:	eb f3                	jmp    800af8 <memfind+0xe>
			break;
	return (void *) s;
}
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
  800b0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b13:	eb 03                	jmp    800b18 <strtol+0x11>
		s++;
  800b15:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b18:	0f b6 01             	movzbl (%ecx),%eax
  800b1b:	3c 20                	cmp    $0x20,%al
  800b1d:	74 f6                	je     800b15 <strtol+0xe>
  800b1f:	3c 09                	cmp    $0x9,%al
  800b21:	74 f2                	je     800b15 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b23:	3c 2b                	cmp    $0x2b,%al
  800b25:	74 2e                	je     800b55 <strtol+0x4e>
	int neg = 0;
  800b27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b2c:	3c 2d                	cmp    $0x2d,%al
  800b2e:	74 2f                	je     800b5f <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b30:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b36:	75 05                	jne    800b3d <strtol+0x36>
  800b38:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3b:	74 2c                	je     800b69 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b3d:	85 db                	test   %ebx,%ebx
  800b3f:	75 0a                	jne    800b4b <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b41:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b46:	80 39 30             	cmpb   $0x30,(%ecx)
  800b49:	74 28                	je     800b73 <strtol+0x6c>
		base = 10;
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b50:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b53:	eb 50                	jmp    800ba5 <strtol+0x9e>
		s++;
  800b55:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b58:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5d:	eb d1                	jmp    800b30 <strtol+0x29>
		s++, neg = 1;
  800b5f:	83 c1 01             	add    $0x1,%ecx
  800b62:	bf 01 00 00 00       	mov    $0x1,%edi
  800b67:	eb c7                	jmp    800b30 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b69:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b6d:	74 0e                	je     800b7d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b6f:	85 db                	test   %ebx,%ebx
  800b71:	75 d8                	jne    800b4b <strtol+0x44>
		s++, base = 8;
  800b73:	83 c1 01             	add    $0x1,%ecx
  800b76:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b7b:	eb ce                	jmp    800b4b <strtol+0x44>
		s += 2, base = 16;
  800b7d:	83 c1 02             	add    $0x2,%ecx
  800b80:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b85:	eb c4                	jmp    800b4b <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b87:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8a:	89 f3                	mov    %esi,%ebx
  800b8c:	80 fb 19             	cmp    $0x19,%bl
  800b8f:	77 29                	ja     800bba <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b91:	0f be d2             	movsbl %dl,%edx
  800b94:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b97:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b9a:	7d 30                	jge    800bcc <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b9c:	83 c1 01             	add    $0x1,%ecx
  800b9f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ba3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ba5:	0f b6 11             	movzbl (%ecx),%edx
  800ba8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bab:	89 f3                	mov    %esi,%ebx
  800bad:	80 fb 09             	cmp    $0x9,%bl
  800bb0:	77 d5                	ja     800b87 <strtol+0x80>
			dig = *s - '0';
  800bb2:	0f be d2             	movsbl %dl,%edx
  800bb5:	83 ea 30             	sub    $0x30,%edx
  800bb8:	eb dd                	jmp    800b97 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bba:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bbd:	89 f3                	mov    %esi,%ebx
  800bbf:	80 fb 19             	cmp    $0x19,%bl
  800bc2:	77 08                	ja     800bcc <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bc4:	0f be d2             	movsbl %dl,%edx
  800bc7:	83 ea 37             	sub    $0x37,%edx
  800bca:	eb cb                	jmp    800b97 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bcc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd0:	74 05                	je     800bd7 <strtol+0xd0>
		*endptr = (char *) s;
  800bd2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bd7:	89 c2                	mov    %eax,%edx
  800bd9:	f7 da                	neg    %edx
  800bdb:	85 ff                	test   %edi,%edi
  800bdd:	0f 45 c2             	cmovne %edx,%eax
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    
  800be5:	66 90                	xchg   %ax,%ax
  800be7:	66 90                	xchg   %ax,%ax
  800be9:	66 90                	xchg   %ax,%ax
  800beb:	66 90                	xchg   %ax,%ax
  800bed:	66 90                	xchg   %ax,%ax
  800bef:	90                   	nop

00800bf0 <__udivdi3>:
  800bf0:	55                   	push   %ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 1c             	sub    $0x1c,%esp
  800bf7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800bfb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800bff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c03:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c07:	85 d2                	test   %edx,%edx
  800c09:	75 35                	jne    800c40 <__udivdi3+0x50>
  800c0b:	39 f3                	cmp    %esi,%ebx
  800c0d:	0f 87 bd 00 00 00    	ja     800cd0 <__udivdi3+0xe0>
  800c13:	85 db                	test   %ebx,%ebx
  800c15:	89 d9                	mov    %ebx,%ecx
  800c17:	75 0b                	jne    800c24 <__udivdi3+0x34>
  800c19:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1e:	31 d2                	xor    %edx,%edx
  800c20:	f7 f3                	div    %ebx
  800c22:	89 c1                	mov    %eax,%ecx
  800c24:	31 d2                	xor    %edx,%edx
  800c26:	89 f0                	mov    %esi,%eax
  800c28:	f7 f1                	div    %ecx
  800c2a:	89 c6                	mov    %eax,%esi
  800c2c:	89 e8                	mov    %ebp,%eax
  800c2e:	89 f7                	mov    %esi,%edi
  800c30:	f7 f1                	div    %ecx
  800c32:	89 fa                	mov    %edi,%edx
  800c34:	83 c4 1c             	add    $0x1c,%esp
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    
  800c3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c40:	39 f2                	cmp    %esi,%edx
  800c42:	77 7c                	ja     800cc0 <__udivdi3+0xd0>
  800c44:	0f bd fa             	bsr    %edx,%edi
  800c47:	83 f7 1f             	xor    $0x1f,%edi
  800c4a:	0f 84 98 00 00 00    	je     800ce8 <__udivdi3+0xf8>
  800c50:	89 f9                	mov    %edi,%ecx
  800c52:	b8 20 00 00 00       	mov    $0x20,%eax
  800c57:	29 f8                	sub    %edi,%eax
  800c59:	d3 e2                	shl    %cl,%edx
  800c5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c5f:	89 c1                	mov    %eax,%ecx
  800c61:	89 da                	mov    %ebx,%edx
  800c63:	d3 ea                	shr    %cl,%edx
  800c65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c69:	09 d1                	or     %edx,%ecx
  800c6b:	89 f2                	mov    %esi,%edx
  800c6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c71:	89 f9                	mov    %edi,%ecx
  800c73:	d3 e3                	shl    %cl,%ebx
  800c75:	89 c1                	mov    %eax,%ecx
  800c77:	d3 ea                	shr    %cl,%edx
  800c79:	89 f9                	mov    %edi,%ecx
  800c7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800c7f:	d3 e6                	shl    %cl,%esi
  800c81:	89 eb                	mov    %ebp,%ebx
  800c83:	89 c1                	mov    %eax,%ecx
  800c85:	d3 eb                	shr    %cl,%ebx
  800c87:	09 de                	or     %ebx,%esi
  800c89:	89 f0                	mov    %esi,%eax
  800c8b:	f7 74 24 08          	divl   0x8(%esp)
  800c8f:	89 d6                	mov    %edx,%esi
  800c91:	89 c3                	mov    %eax,%ebx
  800c93:	f7 64 24 0c          	mull   0xc(%esp)
  800c97:	39 d6                	cmp    %edx,%esi
  800c99:	72 0c                	jb     800ca7 <__udivdi3+0xb7>
  800c9b:	89 f9                	mov    %edi,%ecx
  800c9d:	d3 e5                	shl    %cl,%ebp
  800c9f:	39 c5                	cmp    %eax,%ebp
  800ca1:	73 5d                	jae    800d00 <__udivdi3+0x110>
  800ca3:	39 d6                	cmp    %edx,%esi
  800ca5:	75 59                	jne    800d00 <__udivdi3+0x110>
  800ca7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800caa:	31 ff                	xor    %edi,%edi
  800cac:	89 fa                	mov    %edi,%edx
  800cae:	83 c4 1c             	add    $0x1c,%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    
  800cb6:	8d 76 00             	lea    0x0(%esi),%esi
  800cb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800cc0:	31 ff                	xor    %edi,%edi
  800cc2:	31 c0                	xor    %eax,%eax
  800cc4:	89 fa                	mov    %edi,%edx
  800cc6:	83 c4 1c             	add    $0x1c,%esp
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    
  800cce:	66 90                	xchg   %ax,%ax
  800cd0:	31 ff                	xor    %edi,%edi
  800cd2:	89 e8                	mov    %ebp,%eax
  800cd4:	89 f2                	mov    %esi,%edx
  800cd6:	f7 f3                	div    %ebx
  800cd8:	89 fa                	mov    %edi,%edx
  800cda:	83 c4 1c             	add    $0x1c,%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    
  800ce2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ce8:	39 f2                	cmp    %esi,%edx
  800cea:	72 06                	jb     800cf2 <__udivdi3+0x102>
  800cec:	31 c0                	xor    %eax,%eax
  800cee:	39 eb                	cmp    %ebp,%ebx
  800cf0:	77 d2                	ja     800cc4 <__udivdi3+0xd4>
  800cf2:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf7:	eb cb                	jmp    800cc4 <__udivdi3+0xd4>
  800cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d00:	89 d8                	mov    %ebx,%eax
  800d02:	31 ff                	xor    %edi,%edi
  800d04:	eb be                	jmp    800cc4 <__udivdi3+0xd4>
  800d06:	66 90                	xchg   %ax,%ax
  800d08:	66 90                	xchg   %ax,%ax
  800d0a:	66 90                	xchg   %ax,%ax
  800d0c:	66 90                	xchg   %ax,%ax
  800d0e:	66 90                	xchg   %ax,%ax

00800d10 <__umoddi3>:
  800d10:	55                   	push   %ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 1c             	sub    $0x1c,%esp
  800d17:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d1b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d1f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d27:	85 ed                	test   %ebp,%ebp
  800d29:	89 f0                	mov    %esi,%eax
  800d2b:	89 da                	mov    %ebx,%edx
  800d2d:	75 19                	jne    800d48 <__umoddi3+0x38>
  800d2f:	39 df                	cmp    %ebx,%edi
  800d31:	0f 86 b1 00 00 00    	jbe    800de8 <__umoddi3+0xd8>
  800d37:	f7 f7                	div    %edi
  800d39:	89 d0                	mov    %edx,%eax
  800d3b:	31 d2                	xor    %edx,%edx
  800d3d:	83 c4 1c             	add    $0x1c,%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    
  800d45:	8d 76 00             	lea    0x0(%esi),%esi
  800d48:	39 dd                	cmp    %ebx,%ebp
  800d4a:	77 f1                	ja     800d3d <__umoddi3+0x2d>
  800d4c:	0f bd cd             	bsr    %ebp,%ecx
  800d4f:	83 f1 1f             	xor    $0x1f,%ecx
  800d52:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d56:	0f 84 b4 00 00 00    	je     800e10 <__umoddi3+0x100>
  800d5c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d61:	89 c2                	mov    %eax,%edx
  800d63:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d67:	29 c2                	sub    %eax,%edx
  800d69:	89 c1                	mov    %eax,%ecx
  800d6b:	89 f8                	mov    %edi,%eax
  800d6d:	d3 e5                	shl    %cl,%ebp
  800d6f:	89 d1                	mov    %edx,%ecx
  800d71:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d75:	d3 e8                	shr    %cl,%eax
  800d77:	09 c5                	or     %eax,%ebp
  800d79:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d7d:	89 c1                	mov    %eax,%ecx
  800d7f:	d3 e7                	shl    %cl,%edi
  800d81:	89 d1                	mov    %edx,%ecx
  800d83:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d87:	89 df                	mov    %ebx,%edi
  800d89:	d3 ef                	shr    %cl,%edi
  800d8b:	89 c1                	mov    %eax,%ecx
  800d8d:	89 f0                	mov    %esi,%eax
  800d8f:	d3 e3                	shl    %cl,%ebx
  800d91:	89 d1                	mov    %edx,%ecx
  800d93:	89 fa                	mov    %edi,%edx
  800d95:	d3 e8                	shr    %cl,%eax
  800d97:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800d9c:	09 d8                	or     %ebx,%eax
  800d9e:	f7 f5                	div    %ebp
  800da0:	d3 e6                	shl    %cl,%esi
  800da2:	89 d1                	mov    %edx,%ecx
  800da4:	f7 64 24 08          	mull   0x8(%esp)
  800da8:	39 d1                	cmp    %edx,%ecx
  800daa:	89 c3                	mov    %eax,%ebx
  800dac:	89 d7                	mov    %edx,%edi
  800dae:	72 06                	jb     800db6 <__umoddi3+0xa6>
  800db0:	75 0e                	jne    800dc0 <__umoddi3+0xb0>
  800db2:	39 c6                	cmp    %eax,%esi
  800db4:	73 0a                	jae    800dc0 <__umoddi3+0xb0>
  800db6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800dba:	19 ea                	sbb    %ebp,%edx
  800dbc:	89 d7                	mov    %edx,%edi
  800dbe:	89 c3                	mov    %eax,%ebx
  800dc0:	89 ca                	mov    %ecx,%edx
  800dc2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800dc7:	29 de                	sub    %ebx,%esi
  800dc9:	19 fa                	sbb    %edi,%edx
  800dcb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800dcf:	89 d0                	mov    %edx,%eax
  800dd1:	d3 e0                	shl    %cl,%eax
  800dd3:	89 d9                	mov    %ebx,%ecx
  800dd5:	d3 ee                	shr    %cl,%esi
  800dd7:	d3 ea                	shr    %cl,%edx
  800dd9:	09 f0                	or     %esi,%eax
  800ddb:	83 c4 1c             	add    $0x1c,%esp
  800dde:	5b                   	pop    %ebx
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    
  800de3:	90                   	nop
  800de4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800de8:	85 ff                	test   %edi,%edi
  800dea:	89 f9                	mov    %edi,%ecx
  800dec:	75 0b                	jne    800df9 <__umoddi3+0xe9>
  800dee:	b8 01 00 00 00       	mov    $0x1,%eax
  800df3:	31 d2                	xor    %edx,%edx
  800df5:	f7 f7                	div    %edi
  800df7:	89 c1                	mov    %eax,%ecx
  800df9:	89 d8                	mov    %ebx,%eax
  800dfb:	31 d2                	xor    %edx,%edx
  800dfd:	f7 f1                	div    %ecx
  800dff:	89 f0                	mov    %esi,%eax
  800e01:	f7 f1                	div    %ecx
  800e03:	e9 31 ff ff ff       	jmp    800d39 <__umoddi3+0x29>
  800e08:	90                   	nop
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	39 dd                	cmp    %ebx,%ebp
  800e12:	72 08                	jb     800e1c <__umoddi3+0x10c>
  800e14:	39 f7                	cmp    %esi,%edi
  800e16:	0f 87 21 ff ff ff    	ja     800d3d <__umoddi3+0x2d>
  800e1c:	89 da                	mov    %ebx,%edx
  800e1e:	89 f0                	mov    %esi,%eax
  800e20:	29 f8                	sub    %edi,%eax
  800e22:	19 ea                	sbb    %ebp,%edx
  800e24:	e9 14 ff ff ff       	jmp    800d3d <__umoddi3+0x2d>
