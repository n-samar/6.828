
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	57                   	push   %edi
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	83 ec 0c             	sub    $0xc,%esp
  800042:	e8 50 00 00 00       	call   800097 <__x86.get_pc_thunk.bx>
  800047:	81 c3 b9 1f 00 00    	add    $0x1fb9,%ebx
  80004d:	8b 75 08             	mov    0x8(%ebp),%esi
  800050:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

	thisenv = envs+ENVX(sys_getenvid());
  800053:	e8 f6 00 00 00       	call   80014e <sys_getenvid>
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800060:	c1 e0 05             	shl    $0x5,%eax
  800063:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800069:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  80006f:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800071:	85 f6                	test   %esi,%esi
  800073:	7e 08                	jle    80007d <libmain+0x44>
		binaryname = argv[0];
  800075:	8b 07                	mov    (%edi),%eax
  800077:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80007d:	83 ec 08             	sub    $0x8,%esp
  800080:	57                   	push   %edi
  800081:	56                   	push   %esi
  800082:	e8 ac ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800087:	e8 0f 00 00 00       	call   80009b <exit>
}
  80008c:	83 c4 10             	add    $0x10,%esp
  80008f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	5f                   	pop    %edi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <__x86.get_pc_thunk.bx>:
  800097:	8b 1c 24             	mov    (%esp),%ebx
  80009a:	c3                   	ret    

0080009b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009b:	55                   	push   %ebp
  80009c:	89 e5                	mov    %esp,%ebp
  80009e:	53                   	push   %ebx
  80009f:	83 ec 10             	sub    $0x10,%esp
  8000a2:	e8 f0 ff ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  8000a7:	81 c3 59 1f 00 00    	add    $0x1f59,%ebx
	sys_env_destroy(0);
  8000ad:	6a 00                	push   $0x0
  8000af:	e8 45 00 00 00       	call   8000f9 <sys_env_destroy>
}
  8000b4:	83 c4 10             	add    $0x10,%esp
  8000b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

008000bc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cd:	89 c3                	mov    %eax,%ebx
  8000cf:	89 c7                	mov    %eax,%edi
  8000d1:	89 c6                	mov    %eax,%esi
  8000d3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <sys_cgetc>:

int
sys_cgetc(void)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	57                   	push   %edi
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ea:	89 d1                	mov    %edx,%ecx
  8000ec:	89 d3                	mov    %edx,%ebx
  8000ee:	89 d7                	mov    %edx,%edi
  8000f0:	89 d6                	mov    %edx,%esi
  8000f2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    

008000f9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	57                   	push   %edi
  8000fd:	56                   	push   %esi
  8000fe:	53                   	push   %ebx
  8000ff:	83 ec 1c             	sub    $0x1c,%esp
  800102:	e8 66 00 00 00       	call   80016d <__x86.get_pc_thunk.ax>
  800107:	05 f9 1e 00 00       	add    $0x1ef9,%eax
  80010c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80010f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800114:	8b 55 08             	mov    0x8(%ebp),%edx
  800117:	b8 03 00 00 00       	mov    $0x3,%eax
  80011c:	89 cb                	mov    %ecx,%ebx
  80011e:	89 cf                	mov    %ecx,%edi
  800120:	89 ce                	mov    %ecx,%esi
  800122:	cd 30                	int    $0x30
	if(check && ret > 0)
  800124:	85 c0                	test   %eax,%eax
  800126:	7f 08                	jg     800130 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800128:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012b:	5b                   	pop    %ebx
  80012c:	5e                   	pop    %esi
  80012d:	5f                   	pop    %edi
  80012e:	5d                   	pop    %ebp
  80012f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800130:	83 ec 0c             	sub    $0xc,%esp
  800133:	50                   	push   %eax
  800134:	6a 03                	push   $0x3
  800136:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800139:	8d 83 36 ee ff ff    	lea    -0x11ca(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	6a 23                	push   $0x23
  800142:	8d 83 53 ee ff ff    	lea    -0x11ad(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 23 00 00 00       	call   800171 <_panic>

0080014e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
	asm volatile("int %1\n"
  800154:	ba 00 00 00 00       	mov    $0x0,%edx
  800159:	b8 02 00 00 00       	mov    $0x2,%eax
  80015e:	89 d1                	mov    %edx,%ecx
  800160:	89 d3                	mov    %edx,%ebx
  800162:	89 d7                	mov    %edx,%edi
  800164:	89 d6                	mov    %edx,%esi
  800166:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800168:	5b                   	pop    %ebx
  800169:	5e                   	pop    %esi
  80016a:	5f                   	pop    %edi
  80016b:	5d                   	pop    %ebp
  80016c:	c3                   	ret    

0080016d <__x86.get_pc_thunk.ax>:
  80016d:	8b 04 24             	mov    (%esp),%eax
  800170:	c3                   	ret    

00800171 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	57                   	push   %edi
  800175:	56                   	push   %esi
  800176:	53                   	push   %ebx
  800177:	83 ec 0c             	sub    $0xc,%esp
  80017a:	e8 18 ff ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  80017f:	81 c3 81 1e 00 00    	add    $0x1e81,%ebx
	va_list ap;

	va_start(ap, fmt);
  800185:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800188:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  80018e:	8b 38                	mov    (%eax),%edi
  800190:	e8 b9 ff ff ff       	call   80014e <sys_getenvid>
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	ff 75 0c             	pushl  0xc(%ebp)
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	57                   	push   %edi
  80019f:	50                   	push   %eax
  8001a0:	8d 83 64 ee ff ff    	lea    -0x119c(%ebx),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 d1 00 00 00       	call   80027d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ac:	83 c4 18             	add    $0x18,%esp
  8001af:	56                   	push   %esi
  8001b0:	ff 75 10             	pushl  0x10(%ebp)
  8001b3:	e8 63 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001b8:	8d 83 88 ee ff ff    	lea    -0x1178(%ebx),%eax
  8001be:	89 04 24             	mov    %eax,(%esp)
  8001c1:	e8 b7 00 00 00       	call   80027d <cprintf>
  8001c6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c9:	cc                   	int3   
  8001ca:	eb fd                	jmp    8001c9 <_panic+0x58>

008001cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	e8 c1 fe ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  8001d6:	81 c3 2a 1e 00 00    	add    $0x1e2a,%ebx
  8001dc:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001df:	8b 16                	mov    (%esi),%edx
  8001e1:	8d 42 01             	lea    0x1(%edx),%eax
  8001e4:	89 06                	mov    %eax,(%esi)
  8001e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e9:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001ed:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f2:	74 0b                	je     8001ff <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f4:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fb:	5b                   	pop    %ebx
  8001fc:	5e                   	pop    %esi
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ff:	83 ec 08             	sub    $0x8,%esp
  800202:	68 ff 00 00 00       	push   $0xff
  800207:	8d 46 08             	lea    0x8(%esi),%eax
  80020a:	50                   	push   %eax
  80020b:	e8 ac fe ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  800210:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800216:	83 c4 10             	add    $0x10,%esp
  800219:	eb d9                	jmp    8001f4 <putch+0x28>

0080021b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	53                   	push   %ebx
  80021f:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800225:	e8 6d fe ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  80022a:	81 c3 d6 1d 00 00    	add    $0x1dd6,%ebx
	struct printbuf b;

	b.idx = 0;
  800230:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800237:	00 00 00 
	b.cnt = 0;
  80023a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800241:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800244:	ff 75 0c             	pushl  0xc(%ebp)
  800247:	ff 75 08             	pushl  0x8(%ebp)
  80024a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800250:	50                   	push   %eax
  800251:	8d 83 cc e1 ff ff    	lea    -0x1e34(%ebx),%eax
  800257:	50                   	push   %eax
  800258:	e8 38 01 00 00       	call   800395 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025d:	83 c4 08             	add    $0x8,%esp
  800260:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800266:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026c:	50                   	push   %eax
  80026d:	e8 4a fe ff ff       	call   8000bc <sys_cputs>

	return b.cnt;
}
  800272:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800278:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80027b:	c9                   	leave  
  80027c:	c3                   	ret    

0080027d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800283:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800286:	50                   	push   %eax
  800287:	ff 75 08             	pushl  0x8(%ebp)
  80028a:	e8 8c ff ff ff       	call   80021b <vcprintf>
	va_end(ap);

	return cnt;
}
  80028f:	c9                   	leave  
  800290:	c3                   	ret    

00800291 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	57                   	push   %edi
  800295:	56                   	push   %esi
  800296:	53                   	push   %ebx
  800297:	83 ec 2c             	sub    $0x2c,%esp
  80029a:	e8 cd 05 00 00       	call   80086c <__x86.get_pc_thunk.cx>
  80029f:	81 c1 61 1d 00 00    	add    $0x1d61,%ecx
  8002a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002a8:	89 c7                	mov    %eax,%edi
  8002aa:	89 d6                	mov    %edx,%esi
  8002ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8002af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002b5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002c3:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002c6:	39 d3                	cmp    %edx,%ebx
  8002c8:	72 09                	jb     8002d3 <printnum+0x42>
  8002ca:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002cd:	0f 87 83 00 00 00    	ja     800356 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d3:	83 ec 0c             	sub    $0xc,%esp
  8002d6:	ff 75 18             	pushl  0x18(%ebp)
  8002d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8002dc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002df:	53                   	push   %ebx
  8002e0:	ff 75 10             	pushl  0x10(%ebp)
  8002e3:	83 ec 08             	sub    $0x8,%esp
  8002e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ec:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ef:	ff 75 d0             	pushl  -0x30(%ebp)
  8002f2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002f5:	e8 f6 08 00 00       	call   800bf0 <__udivdi3>
  8002fa:	83 c4 18             	add    $0x18,%esp
  8002fd:	52                   	push   %edx
  8002fe:	50                   	push   %eax
  8002ff:	89 f2                	mov    %esi,%edx
  800301:	89 f8                	mov    %edi,%eax
  800303:	e8 89 ff ff ff       	call   800291 <printnum>
  800308:	83 c4 20             	add    $0x20,%esp
  80030b:	eb 13                	jmp    800320 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	56                   	push   %esi
  800311:	ff 75 18             	pushl  0x18(%ebp)
  800314:	ff d7                	call   *%edi
  800316:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800319:	83 eb 01             	sub    $0x1,%ebx
  80031c:	85 db                	test   %ebx,%ebx
  80031e:	7f ed                	jg     80030d <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800320:	83 ec 08             	sub    $0x8,%esp
  800323:	56                   	push   %esi
  800324:	83 ec 04             	sub    $0x4,%esp
  800327:	ff 75 dc             	pushl  -0x24(%ebp)
  80032a:	ff 75 d8             	pushl  -0x28(%ebp)
  80032d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800330:	ff 75 d0             	pushl  -0x30(%ebp)
  800333:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800336:	89 f3                	mov    %esi,%ebx
  800338:	e8 d3 09 00 00       	call   800d10 <__umoddi3>
  80033d:	83 c4 14             	add    $0x14,%esp
  800340:	0f be 84 06 8a ee ff 	movsbl -0x1176(%esi,%eax,1),%eax
  800347:	ff 
  800348:	50                   	push   %eax
  800349:	ff d7                	call   *%edi
}
  80034b:	83 c4 10             	add    $0x10,%esp
  80034e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800351:	5b                   	pop    %ebx
  800352:	5e                   	pop    %esi
  800353:	5f                   	pop    %edi
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    
  800356:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800359:	eb be                	jmp    800319 <printnum+0x88>

0080035b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800361:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800365:	8b 10                	mov    (%eax),%edx
  800367:	3b 50 04             	cmp    0x4(%eax),%edx
  80036a:	73 0a                	jae    800376 <sprintputch+0x1b>
		*b->buf++ = ch;
  80036c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80036f:	89 08                	mov    %ecx,(%eax)
  800371:	8b 45 08             	mov    0x8(%ebp),%eax
  800374:	88 02                	mov    %al,(%edx)
}
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <printfmt>:
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80037e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800381:	50                   	push   %eax
  800382:	ff 75 10             	pushl  0x10(%ebp)
  800385:	ff 75 0c             	pushl  0xc(%ebp)
  800388:	ff 75 08             	pushl  0x8(%ebp)
  80038b:	e8 05 00 00 00       	call   800395 <vprintfmt>
}
  800390:	83 c4 10             	add    $0x10,%esp
  800393:	c9                   	leave  
  800394:	c3                   	ret    

00800395 <vprintfmt>:
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	57                   	push   %edi
  800399:	56                   	push   %esi
  80039a:	53                   	push   %ebx
  80039b:	83 ec 2c             	sub    $0x2c,%esp
  80039e:	e8 f4 fc ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  8003a3:	81 c3 5d 1c 00 00    	add    $0x1c5d,%ebx
  8003a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003ac:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003af:	e9 8e 03 00 00       	jmp    800742 <.L35+0x48>
		padc = ' ';
  8003b4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003b8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003bf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003c6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8d 47 01             	lea    0x1(%edi),%eax
  8003d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003db:	0f b6 17             	movzbl (%edi),%edx
  8003de:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003e1:	3c 55                	cmp    $0x55,%al
  8003e3:	0f 87 e1 03 00 00    	ja     8007ca <.L22>
  8003e9:	0f b6 c0             	movzbl %al,%eax
  8003ec:	89 d9                	mov    %ebx,%ecx
  8003ee:	03 8c 83 18 ef ff ff 	add    -0x10e8(%ebx,%eax,4),%ecx
  8003f5:	ff e1                	jmp    *%ecx

008003f7 <.L67>:
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003fa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003fe:	eb d5                	jmp    8003d5 <vprintfmt+0x40>

00800400 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800403:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800407:	eb cc                	jmp    8003d5 <vprintfmt+0x40>

00800409 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	0f b6 d2             	movzbl %dl,%edx
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80040f:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800414:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800417:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80041b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80041e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800421:	83 f9 09             	cmp    $0x9,%ecx
  800424:	77 55                	ja     80047b <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  800426:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800429:	eb e9                	jmp    800414 <.L29+0xb>

0080042b <.L26>:
			precision = va_arg(ap, int);
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800433:	8b 45 14             	mov    0x14(%ebp),%eax
  800436:	8d 40 04             	lea    0x4(%eax),%eax
  800439:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80043f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800443:	79 90                	jns    8003d5 <vprintfmt+0x40>
				width = precision, precision = -1;
  800445:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800448:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800452:	eb 81                	jmp    8003d5 <vprintfmt+0x40>

00800454 <.L27>:
  800454:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800457:	85 c0                	test   %eax,%eax
  800459:	ba 00 00 00 00       	mov    $0x0,%edx
  80045e:	0f 49 d0             	cmovns %eax,%edx
  800461:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800467:	e9 69 ff ff ff       	jmp    8003d5 <vprintfmt+0x40>

0080046c <.L23>:
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80046f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800476:	e9 5a ff ff ff       	jmp    8003d5 <vprintfmt+0x40>
  80047b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80047e:	eb bf                	jmp    80043f <.L26+0x14>

00800480 <.L33>:
			lflag++;
  800480:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800487:	e9 49 ff ff ff       	jmp    8003d5 <vprintfmt+0x40>

0080048c <.L30>:
			putch(va_arg(ap, int), putdat);
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8d 78 04             	lea    0x4(%eax),%edi
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	56                   	push   %esi
  800496:	ff 30                	pushl  (%eax)
  800498:	ff 55 08             	call   *0x8(%ebp)
			break;
  80049b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80049e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004a1:	e9 99 02 00 00       	jmp    80073f <.L35+0x45>

008004a6 <.L32>:
			err = va_arg(ap, int);
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8d 78 04             	lea    0x4(%eax),%edi
  8004ac:	8b 00                	mov    (%eax),%eax
  8004ae:	99                   	cltd   
  8004af:	31 d0                	xor    %edx,%eax
  8004b1:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b3:	83 f8 06             	cmp    $0x6,%eax
  8004b6:	7f 27                	jg     8004df <.L32+0x39>
  8004b8:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004bf:	85 d2                	test   %edx,%edx
  8004c1:	74 1c                	je     8004df <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004c3:	52                   	push   %edx
  8004c4:	8d 83 ab ee ff ff    	lea    -0x1155(%ebx),%eax
  8004ca:	50                   	push   %eax
  8004cb:	56                   	push   %esi
  8004cc:	ff 75 08             	pushl  0x8(%ebp)
  8004cf:	e8 a4 fe ff ff       	call   800378 <printfmt>
  8004d4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004d7:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004da:	e9 60 02 00 00       	jmp    80073f <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004df:	50                   	push   %eax
  8004e0:	8d 83 a2 ee ff ff    	lea    -0x115e(%ebx),%eax
  8004e6:	50                   	push   %eax
  8004e7:	56                   	push   %esi
  8004e8:	ff 75 08             	pushl  0x8(%ebp)
  8004eb:	e8 88 fe ff ff       	call   800378 <printfmt>
  8004f0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f3:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004f6:	e9 44 02 00 00       	jmp    80073f <.L35+0x45>

008004fb <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	83 c0 04             	add    $0x4,%eax
  800501:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800509:	85 ff                	test   %edi,%edi
  80050b:	8d 83 9b ee ff ff    	lea    -0x1165(%ebx),%eax
  800511:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800514:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800518:	0f 8e b5 00 00 00    	jle    8005d3 <.L36+0xd8>
  80051e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800522:	75 08                	jne    80052c <.L36+0x31>
  800524:	89 75 0c             	mov    %esi,0xc(%ebp)
  800527:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052a:	eb 6d                	jmp    800599 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	ff 75 d0             	pushl  -0x30(%ebp)
  800532:	57                   	push   %edi
  800533:	e8 50 03 00 00       	call   800888 <strnlen>
  800538:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80053b:	29 c2                	sub    %eax,%edx
  80053d:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800540:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800543:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800547:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80054d:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80054f:	eb 10                	jmp    800561 <.L36+0x66>
					putch(padc, putdat);
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	56                   	push   %esi
  800555:	ff 75 e0             	pushl  -0x20(%ebp)
  800558:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80055b:	83 ef 01             	sub    $0x1,%edi
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	85 ff                	test   %edi,%edi
  800563:	7f ec                	jg     800551 <.L36+0x56>
  800565:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800568:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80056b:	85 d2                	test   %edx,%edx
  80056d:	b8 00 00 00 00       	mov    $0x0,%eax
  800572:	0f 49 c2             	cmovns %edx,%eax
  800575:	29 c2                	sub    %eax,%edx
  800577:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80057a:	89 75 0c             	mov    %esi,0xc(%ebp)
  80057d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800580:	eb 17                	jmp    800599 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800582:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800586:	75 30                	jne    8005b8 <.L36+0xbd>
					putch(ch, putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	ff 75 0c             	pushl  0xc(%ebp)
  80058e:	50                   	push   %eax
  80058f:	ff 55 08             	call   *0x8(%ebp)
  800592:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800595:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800599:	83 c7 01             	add    $0x1,%edi
  80059c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005a0:	0f be c2             	movsbl %dl,%eax
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	74 52                	je     8005f9 <.L36+0xfe>
  8005a7:	85 f6                	test   %esi,%esi
  8005a9:	78 d7                	js     800582 <.L36+0x87>
  8005ab:	83 ee 01             	sub    $0x1,%esi
  8005ae:	79 d2                	jns    800582 <.L36+0x87>
  8005b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005b3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005b6:	eb 32                	jmp    8005ea <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005b8:	0f be d2             	movsbl %dl,%edx
  8005bb:	83 ea 20             	sub    $0x20,%edx
  8005be:	83 fa 5e             	cmp    $0x5e,%edx
  8005c1:	76 c5                	jbe    800588 <.L36+0x8d>
					putch('?', putdat);
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	ff 75 0c             	pushl  0xc(%ebp)
  8005c9:	6a 3f                	push   $0x3f
  8005cb:	ff 55 08             	call   *0x8(%ebp)
  8005ce:	83 c4 10             	add    $0x10,%esp
  8005d1:	eb c2                	jmp    800595 <.L36+0x9a>
  8005d3:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005d6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d9:	eb be                	jmp    800599 <.L36+0x9e>
				putch(' ', putdat);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	56                   	push   %esi
  8005df:	6a 20                	push   $0x20
  8005e1:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005e4:	83 ef 01             	sub    $0x1,%edi
  8005e7:	83 c4 10             	add    $0x10,%esp
  8005ea:	85 ff                	test   %edi,%edi
  8005ec:	7f ed                	jg     8005db <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8005ee:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005f1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f4:	e9 46 01 00 00       	jmp    80073f <.L35+0x45>
  8005f9:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005ff:	eb e9                	jmp    8005ea <.L36+0xef>

00800601 <.L31>:
  800601:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  800604:	83 f9 01             	cmp    $0x1,%ecx
  800607:	7e 40                	jle    800649 <.L31+0x48>
		return va_arg(*ap, long long);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8b 50 04             	mov    0x4(%eax),%edx
  80060f:	8b 00                	mov    (%eax),%eax
  800611:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800614:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 40 08             	lea    0x8(%eax),%eax
  80061d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800620:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800624:	79 55                	jns    80067b <.L31+0x7a>
				putch('-', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	56                   	push   %esi
  80062a:	6a 2d                	push   $0x2d
  80062c:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80062f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800632:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800635:	f7 da                	neg    %edx
  800637:	83 d1 00             	adc    $0x0,%ecx
  80063a:	f7 d9                	neg    %ecx
  80063c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80063f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800644:	e9 db 00 00 00       	jmp    800724 <.L35+0x2a>
	else if (lflag)
  800649:	85 c9                	test   %ecx,%ecx
  80064b:	75 17                	jne    800664 <.L31+0x63>
		return va_arg(*ap, int);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8b 00                	mov    (%eax),%eax
  800652:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800655:	99                   	cltd   
  800656:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8d 40 04             	lea    0x4(%eax),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
  800662:	eb bc                	jmp    800620 <.L31+0x1f>
		return va_arg(*ap, long);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8b 00                	mov    (%eax),%eax
  800669:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066c:	99                   	cltd   
  80066d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8d 40 04             	lea    0x4(%eax),%eax
  800676:	89 45 14             	mov    %eax,0x14(%ebp)
  800679:	eb a5                	jmp    800620 <.L31+0x1f>
			num = getint(&ap, lflag);
  80067b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80067e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800681:	b8 0a 00 00 00       	mov    $0xa,%eax
  800686:	e9 99 00 00 00       	jmp    800724 <.L35+0x2a>

0080068b <.L37>:
  80068b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  80068e:	83 f9 01             	cmp    $0x1,%ecx
  800691:	7e 15                	jle    8006a8 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8b 10                	mov    (%eax),%edx
  800698:	8b 48 04             	mov    0x4(%eax),%ecx
  80069b:	8d 40 08             	lea    0x8(%eax),%eax
  80069e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a6:	eb 7c                	jmp    800724 <.L35+0x2a>
	else if (lflag)
  8006a8:	85 c9                	test   %ecx,%ecx
  8006aa:	75 17                	jne    8006c3 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 10                	mov    (%eax),%edx
  8006b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b6:	8d 40 04             	lea    0x4(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c1:	eb 61                	jmp    800724 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8b 10                	mov    (%eax),%edx
  8006c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cd:	8d 40 04             	lea    0x4(%eax),%eax
  8006d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d8:	eb 4a                	jmp    800724 <.L35+0x2a>

008006da <.L34>:
			putch('X', putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	56                   	push   %esi
  8006de:	6a 58                	push   $0x58
  8006e0:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006e3:	83 c4 08             	add    $0x8,%esp
  8006e6:	56                   	push   %esi
  8006e7:	6a 58                	push   $0x58
  8006e9:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006ec:	83 c4 08             	add    $0x8,%esp
  8006ef:	56                   	push   %esi
  8006f0:	6a 58                	push   $0x58
  8006f2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	eb 45                	jmp    80073f <.L35+0x45>

008006fa <.L35>:
			putch('0', putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	56                   	push   %esi
  8006fe:	6a 30                	push   $0x30
  800700:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800703:	83 c4 08             	add    $0x8,%esp
  800706:	56                   	push   %esi
  800707:	6a 78                	push   $0x78
  800709:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8b 10                	mov    (%eax),%edx
  800711:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800716:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800719:	8d 40 04             	lea    0x4(%eax),%eax
  80071c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800724:	83 ec 0c             	sub    $0xc,%esp
  800727:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80072b:	57                   	push   %edi
  80072c:	ff 75 e0             	pushl  -0x20(%ebp)
  80072f:	50                   	push   %eax
  800730:	51                   	push   %ecx
  800731:	52                   	push   %edx
  800732:	89 f2                	mov    %esi,%edx
  800734:	8b 45 08             	mov    0x8(%ebp),%eax
  800737:	e8 55 fb ff ff       	call   800291 <printnum>
			break;
  80073c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80073f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800742:	83 c7 01             	add    $0x1,%edi
  800745:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800749:	83 f8 25             	cmp    $0x25,%eax
  80074c:	0f 84 62 fc ff ff    	je     8003b4 <vprintfmt+0x1f>
			if (ch == '\0')
  800752:	85 c0                	test   %eax,%eax
  800754:	0f 84 91 00 00 00    	je     8007eb <.L22+0x21>
			putch(ch, putdat);
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	56                   	push   %esi
  80075e:	50                   	push   %eax
  80075f:	ff 55 08             	call   *0x8(%ebp)
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	eb db                	jmp    800742 <.L35+0x48>

00800767 <.L38>:
  800767:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  80076a:	83 f9 01             	cmp    $0x1,%ecx
  80076d:	7e 15                	jle    800784 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8b 10                	mov    (%eax),%edx
  800774:	8b 48 04             	mov    0x4(%eax),%ecx
  800777:	8d 40 08             	lea    0x8(%eax),%eax
  80077a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80077d:	b8 10 00 00 00       	mov    $0x10,%eax
  800782:	eb a0                	jmp    800724 <.L35+0x2a>
	else if (lflag)
  800784:	85 c9                	test   %ecx,%ecx
  800786:	75 17                	jne    80079f <.L38+0x38>
		return va_arg(*ap, unsigned int);
  800788:	8b 45 14             	mov    0x14(%ebp),%eax
  80078b:	8b 10                	mov    (%eax),%edx
  80078d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800792:	8d 40 04             	lea    0x4(%eax),%eax
  800795:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800798:	b8 10 00 00 00       	mov    $0x10,%eax
  80079d:	eb 85                	jmp    800724 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8b 10                	mov    (%eax),%edx
  8007a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a9:	8d 40 04             	lea    0x4(%eax),%eax
  8007ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007af:	b8 10 00 00 00       	mov    $0x10,%eax
  8007b4:	e9 6b ff ff ff       	jmp    800724 <.L35+0x2a>

008007b9 <.L25>:
			putch(ch, putdat);
  8007b9:	83 ec 08             	sub    $0x8,%esp
  8007bc:	56                   	push   %esi
  8007bd:	6a 25                	push   $0x25
  8007bf:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007c2:	83 c4 10             	add    $0x10,%esp
  8007c5:	e9 75 ff ff ff       	jmp    80073f <.L35+0x45>

008007ca <.L22>:
			putch('%', putdat);
  8007ca:	83 ec 08             	sub    $0x8,%esp
  8007cd:	56                   	push   %esi
  8007ce:	6a 25                	push   $0x25
  8007d0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d3:	83 c4 10             	add    $0x10,%esp
  8007d6:	89 f8                	mov    %edi,%eax
  8007d8:	eb 03                	jmp    8007dd <.L22+0x13>
  8007da:	83 e8 01             	sub    $0x1,%eax
  8007dd:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007e1:	75 f7                	jne    8007da <.L22+0x10>
  8007e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007e6:	e9 54 ff ff ff       	jmp    80073f <.L35+0x45>
}
  8007eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5f                   	pop    %edi
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	83 ec 14             	sub    $0x14,%esp
  8007fa:	e8 98 f8 ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  8007ff:	81 c3 01 18 00 00    	add    $0x1801,%ebx
  800805:	8b 45 08             	mov    0x8(%ebp),%eax
  800808:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800812:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800815:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081c:	85 c0                	test   %eax,%eax
  80081e:	74 2b                	je     80084b <vsnprintf+0x58>
  800820:	85 d2                	test   %edx,%edx
  800822:	7e 27                	jle    80084b <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800824:	ff 75 14             	pushl  0x14(%ebp)
  800827:	ff 75 10             	pushl  0x10(%ebp)
  80082a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082d:	50                   	push   %eax
  80082e:	8d 83 5b e3 ff ff    	lea    -0x1ca5(%ebx),%eax
  800834:	50                   	push   %eax
  800835:	e8 5b fb ff ff       	call   800395 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800840:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800843:	83 c4 10             	add    $0x10,%esp
}
  800846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    
		return -E_INVAL;
  80084b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800850:	eb f4                	jmp    800846 <vsnprintf+0x53>

00800852 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800858:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80085b:	50                   	push   %eax
  80085c:	ff 75 10             	pushl  0x10(%ebp)
  80085f:	ff 75 0c             	pushl  0xc(%ebp)
  800862:	ff 75 08             	pushl  0x8(%ebp)
  800865:	e8 89 ff ff ff       	call   8007f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  80086a:	c9                   	leave  
  80086b:	c3                   	ret    

0080086c <__x86.get_pc_thunk.cx>:
  80086c:	8b 0c 24             	mov    (%esp),%ecx
  80086f:	c3                   	ret    

00800870 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
  80087b:	eb 03                	jmp    800880 <strlen+0x10>
		n++;
  80087d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800880:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800884:	75 f7                	jne    80087d <strlen+0xd>
	return n;
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
  800896:	eb 03                	jmp    80089b <strnlen+0x13>
		n++;
  800898:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089b:	39 d0                	cmp    %edx,%eax
  80089d:	74 06                	je     8008a5 <strnlen+0x1d>
  80089f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a3:	75 f3                	jne    800898 <strnlen+0x10>
	return n;
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b1:	89 c2                	mov    %eax,%edx
  8008b3:	83 c1 01             	add    $0x1,%ecx
  8008b6:	83 c2 01             	add    $0x1,%edx
  8008b9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008bd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008c0:	84 db                	test   %bl,%bl
  8008c2:	75 ef                	jne    8008b3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008c4:	5b                   	pop    %ebx
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	53                   	push   %ebx
  8008cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008ce:	53                   	push   %ebx
  8008cf:	e8 9c ff ff ff       	call   800870 <strlen>
  8008d4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008d7:	ff 75 0c             	pushl  0xc(%ebp)
  8008da:	01 d8                	add    %ebx,%eax
  8008dc:	50                   	push   %eax
  8008dd:	e8 c5 ff ff ff       	call   8008a7 <strcpy>
	return dst;
}
  8008e2:	89 d8                	mov    %ebx,%eax
  8008e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e7:	c9                   	leave  
  8008e8:	c3                   	ret    

008008e9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	56                   	push   %esi
  8008ed:	53                   	push   %ebx
  8008ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f4:	89 f3                	mov    %esi,%ebx
  8008f6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f9:	89 f2                	mov    %esi,%edx
  8008fb:	eb 0f                	jmp    80090c <strncpy+0x23>
		*dst++ = *src;
  8008fd:	83 c2 01             	add    $0x1,%edx
  800900:	0f b6 01             	movzbl (%ecx),%eax
  800903:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800906:	80 39 01             	cmpb   $0x1,(%ecx)
  800909:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80090c:	39 da                	cmp    %ebx,%edx
  80090e:	75 ed                	jne    8008fd <strncpy+0x14>
	}
	return ret;
}
  800910:	89 f0                	mov    %esi,%eax
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	8b 75 08             	mov    0x8(%ebp),%esi
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800921:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800924:	89 f0                	mov    %esi,%eax
  800926:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80092a:	85 c9                	test   %ecx,%ecx
  80092c:	75 0b                	jne    800939 <strlcpy+0x23>
  80092e:	eb 17                	jmp    800947 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800930:	83 c2 01             	add    $0x1,%edx
  800933:	83 c0 01             	add    $0x1,%eax
  800936:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800939:	39 d8                	cmp    %ebx,%eax
  80093b:	74 07                	je     800944 <strlcpy+0x2e>
  80093d:	0f b6 0a             	movzbl (%edx),%ecx
  800940:	84 c9                	test   %cl,%cl
  800942:	75 ec                	jne    800930 <strlcpy+0x1a>
		*dst = '\0';
  800944:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800947:	29 f0                	sub    %esi,%eax
}
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800953:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800956:	eb 06                	jmp    80095e <strcmp+0x11>
		p++, q++;
  800958:	83 c1 01             	add    $0x1,%ecx
  80095b:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80095e:	0f b6 01             	movzbl (%ecx),%eax
  800961:	84 c0                	test   %al,%al
  800963:	74 04                	je     800969 <strcmp+0x1c>
  800965:	3a 02                	cmp    (%edx),%al
  800967:	74 ef                	je     800958 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800969:	0f b6 c0             	movzbl %al,%eax
  80096c:	0f b6 12             	movzbl (%edx),%edx
  80096f:	29 d0                	sub    %edx,%eax
}
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	53                   	push   %ebx
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
  80097a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097d:	89 c3                	mov    %eax,%ebx
  80097f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800982:	eb 06                	jmp    80098a <strncmp+0x17>
		n--, p++, q++;
  800984:	83 c0 01             	add    $0x1,%eax
  800987:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80098a:	39 d8                	cmp    %ebx,%eax
  80098c:	74 16                	je     8009a4 <strncmp+0x31>
  80098e:	0f b6 08             	movzbl (%eax),%ecx
  800991:	84 c9                	test   %cl,%cl
  800993:	74 04                	je     800999 <strncmp+0x26>
  800995:	3a 0a                	cmp    (%edx),%cl
  800997:	74 eb                	je     800984 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800999:	0f b6 00             	movzbl (%eax),%eax
  80099c:	0f b6 12             	movzbl (%edx),%edx
  80099f:	29 d0                	sub    %edx,%eax
}
  8009a1:	5b                   	pop    %ebx
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    
		return 0;
  8009a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a9:	eb f6                	jmp    8009a1 <strncmp+0x2e>

008009ab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b5:	0f b6 10             	movzbl (%eax),%edx
  8009b8:	84 d2                	test   %dl,%dl
  8009ba:	74 09                	je     8009c5 <strchr+0x1a>
		if (*s == c)
  8009bc:	38 ca                	cmp    %cl,%dl
  8009be:	74 0a                	je     8009ca <strchr+0x1f>
	for (; *s; s++)
  8009c0:	83 c0 01             	add    $0x1,%eax
  8009c3:	eb f0                	jmp    8009b5 <strchr+0xa>
			return (char *) s;
	return 0;
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d6:	eb 03                	jmp    8009db <strfind+0xf>
  8009d8:	83 c0 01             	add    $0x1,%eax
  8009db:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009de:	38 ca                	cmp    %cl,%dl
  8009e0:	74 04                	je     8009e6 <strfind+0x1a>
  8009e2:	84 d2                	test   %dl,%dl
  8009e4:	75 f2                	jne    8009d8 <strfind+0xc>
			break;
	return (char *) s;
}
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	57                   	push   %edi
  8009ec:	56                   	push   %esi
  8009ed:	53                   	push   %ebx
  8009ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f4:	85 c9                	test   %ecx,%ecx
  8009f6:	74 13                	je     800a0b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fe:	75 05                	jne    800a05 <memset+0x1d>
  800a00:	f6 c1 03             	test   $0x3,%cl
  800a03:	74 0d                	je     800a12 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a08:	fc                   	cld    
  800a09:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0b:	89 f8                	mov    %edi,%eax
  800a0d:	5b                   	pop    %ebx
  800a0e:	5e                   	pop    %esi
  800a0f:	5f                   	pop    %edi
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    
		c &= 0xFF;
  800a12:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a16:	89 d3                	mov    %edx,%ebx
  800a18:	c1 e3 08             	shl    $0x8,%ebx
  800a1b:	89 d0                	mov    %edx,%eax
  800a1d:	c1 e0 18             	shl    $0x18,%eax
  800a20:	89 d6                	mov    %edx,%esi
  800a22:	c1 e6 10             	shl    $0x10,%esi
  800a25:	09 f0                	or     %esi,%eax
  800a27:	09 c2                	or     %eax,%edx
  800a29:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a2b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a2e:	89 d0                	mov    %edx,%eax
  800a30:	fc                   	cld    
  800a31:	f3 ab                	rep stos %eax,%es:(%edi)
  800a33:	eb d6                	jmp    800a0b <memset+0x23>

00800a35 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	57                   	push   %edi
  800a39:	56                   	push   %esi
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a43:	39 c6                	cmp    %eax,%esi
  800a45:	73 35                	jae    800a7c <memmove+0x47>
  800a47:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a4a:	39 c2                	cmp    %eax,%edx
  800a4c:	76 2e                	jbe    800a7c <memmove+0x47>
		s += n;
		d += n;
  800a4e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a51:	89 d6                	mov    %edx,%esi
  800a53:	09 fe                	or     %edi,%esi
  800a55:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5b:	74 0c                	je     800a69 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a5d:	83 ef 01             	sub    $0x1,%edi
  800a60:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a63:	fd                   	std    
  800a64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a66:	fc                   	cld    
  800a67:	eb 21                	jmp    800a8a <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a69:	f6 c1 03             	test   $0x3,%cl
  800a6c:	75 ef                	jne    800a5d <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a6e:	83 ef 04             	sub    $0x4,%edi
  800a71:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a74:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a77:	fd                   	std    
  800a78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7a:	eb ea                	jmp    800a66 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7c:	89 f2                	mov    %esi,%edx
  800a7e:	09 c2                	or     %eax,%edx
  800a80:	f6 c2 03             	test   $0x3,%dl
  800a83:	74 09                	je     800a8e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a85:	89 c7                	mov    %eax,%edi
  800a87:	fc                   	cld    
  800a88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8e:	f6 c1 03             	test   $0x3,%cl
  800a91:	75 f2                	jne    800a85 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a93:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a96:	89 c7                	mov    %eax,%edi
  800a98:	fc                   	cld    
  800a99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9b:	eb ed                	jmp    800a8a <memmove+0x55>

00800a9d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aa0:	ff 75 10             	pushl  0x10(%ebp)
  800aa3:	ff 75 0c             	pushl  0xc(%ebp)
  800aa6:	ff 75 08             	pushl  0x8(%ebp)
  800aa9:	e8 87 ff ff ff       	call   800a35 <memmove>
}
  800aae:	c9                   	leave  
  800aaf:	c3                   	ret    

00800ab0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abb:	89 c6                	mov    %eax,%esi
  800abd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac0:	39 f0                	cmp    %esi,%eax
  800ac2:	74 1c                	je     800ae0 <memcmp+0x30>
		if (*s1 != *s2)
  800ac4:	0f b6 08             	movzbl (%eax),%ecx
  800ac7:	0f b6 1a             	movzbl (%edx),%ebx
  800aca:	38 d9                	cmp    %bl,%cl
  800acc:	75 08                	jne    800ad6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ace:	83 c0 01             	add    $0x1,%eax
  800ad1:	83 c2 01             	add    $0x1,%edx
  800ad4:	eb ea                	jmp    800ac0 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800ad6:	0f b6 c1             	movzbl %cl,%eax
  800ad9:	0f b6 db             	movzbl %bl,%ebx
  800adc:	29 d8                	sub    %ebx,%eax
  800ade:	eb 05                	jmp    800ae5 <memcmp+0x35>
	}

	return 0;
  800ae0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	8b 45 08             	mov    0x8(%ebp),%eax
  800aef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800af2:	89 c2                	mov    %eax,%edx
  800af4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af7:	39 d0                	cmp    %edx,%eax
  800af9:	73 09                	jae    800b04 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800afb:	38 08                	cmp    %cl,(%eax)
  800afd:	74 05                	je     800b04 <memfind+0x1b>
	for (; s < ends; s++)
  800aff:	83 c0 01             	add    $0x1,%eax
  800b02:	eb f3                	jmp    800af7 <memfind+0xe>
			break;
	return (void *) s;
}
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
  800b0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b12:	eb 03                	jmp    800b17 <strtol+0x11>
		s++;
  800b14:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b17:	0f b6 01             	movzbl (%ecx),%eax
  800b1a:	3c 20                	cmp    $0x20,%al
  800b1c:	74 f6                	je     800b14 <strtol+0xe>
  800b1e:	3c 09                	cmp    $0x9,%al
  800b20:	74 f2                	je     800b14 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b22:	3c 2b                	cmp    $0x2b,%al
  800b24:	74 2e                	je     800b54 <strtol+0x4e>
	int neg = 0;
  800b26:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b2b:	3c 2d                	cmp    $0x2d,%al
  800b2d:	74 2f                	je     800b5e <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b35:	75 05                	jne    800b3c <strtol+0x36>
  800b37:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3a:	74 2c                	je     800b68 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b3c:	85 db                	test   %ebx,%ebx
  800b3e:	75 0a                	jne    800b4a <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b40:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b45:	80 39 30             	cmpb   $0x30,(%ecx)
  800b48:	74 28                	je     800b72 <strtol+0x6c>
		base = 10;
  800b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b52:	eb 50                	jmp    800ba4 <strtol+0x9e>
		s++;
  800b54:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b57:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5c:	eb d1                	jmp    800b2f <strtol+0x29>
		s++, neg = 1;
  800b5e:	83 c1 01             	add    $0x1,%ecx
  800b61:	bf 01 00 00 00       	mov    $0x1,%edi
  800b66:	eb c7                	jmp    800b2f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b68:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b6c:	74 0e                	je     800b7c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b6e:	85 db                	test   %ebx,%ebx
  800b70:	75 d8                	jne    800b4a <strtol+0x44>
		s++, base = 8;
  800b72:	83 c1 01             	add    $0x1,%ecx
  800b75:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b7a:	eb ce                	jmp    800b4a <strtol+0x44>
		s += 2, base = 16;
  800b7c:	83 c1 02             	add    $0x2,%ecx
  800b7f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b84:	eb c4                	jmp    800b4a <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b86:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b89:	89 f3                	mov    %esi,%ebx
  800b8b:	80 fb 19             	cmp    $0x19,%bl
  800b8e:	77 29                	ja     800bb9 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b90:	0f be d2             	movsbl %dl,%edx
  800b93:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b96:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b99:	7d 30                	jge    800bcb <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b9b:	83 c1 01             	add    $0x1,%ecx
  800b9e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ba2:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ba4:	0f b6 11             	movzbl (%ecx),%edx
  800ba7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800baa:	89 f3                	mov    %esi,%ebx
  800bac:	80 fb 09             	cmp    $0x9,%bl
  800baf:	77 d5                	ja     800b86 <strtol+0x80>
			dig = *s - '0';
  800bb1:	0f be d2             	movsbl %dl,%edx
  800bb4:	83 ea 30             	sub    $0x30,%edx
  800bb7:	eb dd                	jmp    800b96 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bb9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bbc:	89 f3                	mov    %esi,%ebx
  800bbe:	80 fb 19             	cmp    $0x19,%bl
  800bc1:	77 08                	ja     800bcb <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bc3:	0f be d2             	movsbl %dl,%edx
  800bc6:	83 ea 37             	sub    $0x37,%edx
  800bc9:	eb cb                	jmp    800b96 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bcb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bcf:	74 05                	je     800bd6 <strtol+0xd0>
		*endptr = (char *) s;
  800bd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd4:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bd6:	89 c2                	mov    %eax,%edx
  800bd8:	f7 da                	neg    %edx
  800bda:	85 ff                	test   %edi,%edi
  800bdc:	0f 45 c2             	cmovne %edx,%eax
}
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    
  800be4:	66 90                	xchg   %ax,%ax
  800be6:	66 90                	xchg   %ax,%ax
  800be8:	66 90                	xchg   %ax,%ax
  800bea:	66 90                	xchg   %ax,%ax
  800bec:	66 90                	xchg   %ax,%ax
  800bee:	66 90                	xchg   %ax,%ax

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
