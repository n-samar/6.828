
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	57                   	push   %edi
  800042:	56                   	push   %esi
  800043:	53                   	push   %ebx
  800044:	83 ec 0c             	sub    $0xc,%esp
  800047:	e8 50 00 00 00       	call   80009c <__x86.get_pc_thunk.bx>
  80004c:	81 c3 b4 1f 00 00    	add    $0x1fb4,%ebx
  800052:	8b 75 08             	mov    0x8(%ebp),%esi
  800055:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

	thisenv = envs+ENVX(sys_getenvid());
  800058:	e8 f6 00 00 00       	call   800153 <sys_getenvid>
  80005d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800062:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800065:	c1 e0 05             	shl    $0x5,%eax
  800068:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80006e:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  800074:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 f6                	test   %esi,%esi
  800078:	7e 08                	jle    800082 <libmain+0x44>
		binaryname = argv[0];
  80007a:	8b 07                	mov    (%edi),%eax
  80007c:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	57                   	push   %edi
  800086:	56                   	push   %esi
  800087:	e8 a7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008c:	e8 0f 00 00 00       	call   8000a0 <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800097:	5b                   	pop    %ebx
  800098:	5e                   	pop    %esi
  800099:	5f                   	pop    %edi
  80009a:	5d                   	pop    %ebp
  80009b:	c3                   	ret    

0080009c <__x86.get_pc_thunk.bx>:
  80009c:	8b 1c 24             	mov    (%esp),%ebx
  80009f:	c3                   	ret    

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	53                   	push   %ebx
  8000a4:	83 ec 10             	sub    $0x10,%esp
  8000a7:	e8 f0 ff ff ff       	call   80009c <__x86.get_pc_thunk.bx>
  8000ac:	81 c3 54 1f 00 00    	add    $0x1f54,%ebx
	sys_env_destroy(0);
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 45 00 00 00       	call   8000fe <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    

008000c1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	57                   	push   %edi
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d2:	89 c3                	mov    %eax,%ebx
  8000d4:	89 c7                	mov    %eax,%edi
  8000d6:	89 c6                	mov    %eax,%esi
  8000d8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_cgetc>:

int
sys_cgetc(void)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ef:	89 d1                	mov    %edx,%ecx
  8000f1:	89 d3                	mov    %edx,%ebx
  8000f3:	89 d7                	mov    %edx,%edi
  8000f5:	89 d6                	mov    %edx,%esi
  8000f7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	57                   	push   %edi
  800102:	56                   	push   %esi
  800103:	53                   	push   %ebx
  800104:	83 ec 1c             	sub    $0x1c,%esp
  800107:	e8 66 00 00 00       	call   800172 <__x86.get_pc_thunk.ax>
  80010c:	05 f4 1e 00 00       	add    $0x1ef4,%eax
  800111:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800114:	b9 00 00 00 00       	mov    $0x0,%ecx
  800119:	8b 55 08             	mov    0x8(%ebp),%edx
  80011c:	b8 03 00 00 00       	mov    $0x3,%eax
  800121:	89 cb                	mov    %ecx,%ebx
  800123:	89 cf                	mov    %ecx,%edi
  800125:	89 ce                	mov    %ecx,%esi
  800127:	cd 30                	int    $0x30
	if(check && ret > 0)
  800129:	85 c0                	test   %eax,%eax
  80012b:	7f 08                	jg     800135 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5f                   	pop    %edi
  800133:	5d                   	pop    %ebp
  800134:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	50                   	push   %eax
  800139:	6a 03                	push   $0x3
  80013b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80013e:	8d 83 36 ee ff ff    	lea    -0x11ca(%ebx),%eax
  800144:	50                   	push   %eax
  800145:	6a 23                	push   $0x23
  800147:	8d 83 53 ee ff ff    	lea    -0x11ad(%ebx),%eax
  80014d:	50                   	push   %eax
  80014e:	e8 23 00 00 00       	call   800176 <_panic>

00800153 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	57                   	push   %edi
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	asm volatile("int %1\n"
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	b8 02 00 00 00       	mov    $0x2,%eax
  800163:	89 d1                	mov    %edx,%ecx
  800165:	89 d3                	mov    %edx,%ebx
  800167:	89 d7                	mov    %edx,%edi
  800169:	89 d6                	mov    %edx,%esi
  80016b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016d:	5b                   	pop    %ebx
  80016e:	5e                   	pop    %esi
  80016f:	5f                   	pop    %edi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    

00800172 <__x86.get_pc_thunk.ax>:
  800172:	8b 04 24             	mov    (%esp),%eax
  800175:	c3                   	ret    

00800176 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	57                   	push   %edi
  80017a:	56                   	push   %esi
  80017b:	53                   	push   %ebx
  80017c:	83 ec 0c             	sub    $0xc,%esp
  80017f:	e8 18 ff ff ff       	call   80009c <__x86.get_pc_thunk.bx>
  800184:	81 c3 7c 1e 00 00    	add    $0x1e7c,%ebx
	va_list ap;

	va_start(ap, fmt);
  80018a:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018d:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800193:	8b 38                	mov    (%eax),%edi
  800195:	e8 b9 ff ff ff       	call   800153 <sys_getenvid>
  80019a:	83 ec 0c             	sub    $0xc,%esp
  80019d:	ff 75 0c             	pushl  0xc(%ebp)
  8001a0:	ff 75 08             	pushl  0x8(%ebp)
  8001a3:	57                   	push   %edi
  8001a4:	50                   	push   %eax
  8001a5:	8d 83 64 ee ff ff    	lea    -0x119c(%ebx),%eax
  8001ab:	50                   	push   %eax
  8001ac:	e8 d1 00 00 00       	call   800282 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b1:	83 c4 18             	add    $0x18,%esp
  8001b4:	56                   	push   %esi
  8001b5:	ff 75 10             	pushl  0x10(%ebp)
  8001b8:	e8 63 00 00 00       	call   800220 <vcprintf>
	cprintf("\n");
  8001bd:	8d 83 88 ee ff ff    	lea    -0x1178(%ebx),%eax
  8001c3:	89 04 24             	mov    %eax,(%esp)
  8001c6:	e8 b7 00 00 00       	call   800282 <cprintf>
  8001cb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ce:	cc                   	int3   
  8001cf:	eb fd                	jmp    8001ce <_panic+0x58>

008001d1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	e8 c1 fe ff ff       	call   80009c <__x86.get_pc_thunk.bx>
  8001db:	81 c3 25 1e 00 00    	add    $0x1e25,%ebx
  8001e1:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001e4:	8b 16                	mov    (%esi),%edx
  8001e6:	8d 42 01             	lea    0x1(%edx),%eax
  8001e9:	89 06                	mov    %eax,(%esi)
  8001eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ee:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	74 0b                	je     800204 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f9:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800200:	5b                   	pop    %ebx
  800201:	5e                   	pop    %esi
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800204:	83 ec 08             	sub    $0x8,%esp
  800207:	68 ff 00 00 00       	push   $0xff
  80020c:	8d 46 08             	lea    0x8(%esi),%eax
  80020f:	50                   	push   %eax
  800210:	e8 ac fe ff ff       	call   8000c1 <sys_cputs>
		b->idx = 0;
  800215:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80021b:	83 c4 10             	add    $0x10,%esp
  80021e:	eb d9                	jmp    8001f9 <putch+0x28>

00800220 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	53                   	push   %ebx
  800224:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80022a:	e8 6d fe ff ff       	call   80009c <__x86.get_pc_thunk.bx>
  80022f:	81 c3 d1 1d 00 00    	add    $0x1dd1,%ebx
	struct printbuf b;

	b.idx = 0;
  800235:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023c:	00 00 00 
	b.cnt = 0;
  80023f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800246:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800249:	ff 75 0c             	pushl  0xc(%ebp)
  80024c:	ff 75 08             	pushl  0x8(%ebp)
  80024f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800255:	50                   	push   %eax
  800256:	8d 83 d1 e1 ff ff    	lea    -0x1e2f(%ebx),%eax
  80025c:	50                   	push   %eax
  80025d:	e8 38 01 00 00       	call   80039a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800262:	83 c4 08             	add    $0x8,%esp
  800265:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80026b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800271:	50                   	push   %eax
  800272:	e8 4a fe ff ff       	call   8000c1 <sys_cputs>

	return b.cnt;
}
  800277:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800280:	c9                   	leave  
  800281:	c3                   	ret    

00800282 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800288:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028b:	50                   	push   %eax
  80028c:	ff 75 08             	pushl  0x8(%ebp)
  80028f:	e8 8c ff ff ff       	call   800220 <vcprintf>
	va_end(ap);

	return cnt;
}
  800294:	c9                   	leave  
  800295:	c3                   	ret    

00800296 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	57                   	push   %edi
  80029a:	56                   	push   %esi
  80029b:	53                   	push   %ebx
  80029c:	83 ec 2c             	sub    $0x2c,%esp
  80029f:	e8 cd 05 00 00       	call   800871 <__x86.get_pc_thunk.cx>
  8002a4:	81 c1 5c 1d 00 00    	add    $0x1d5c,%ecx
  8002aa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002ad:	89 c7                	mov    %eax,%edi
  8002af:	89 d6                	mov    %edx,%esi
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002ba:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c5:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002c8:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002cb:	39 d3                	cmp    %edx,%ebx
  8002cd:	72 09                	jb     8002d8 <printnum+0x42>
  8002cf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d2:	0f 87 83 00 00 00    	ja     80035b <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	ff 75 18             	pushl  0x18(%ebp)
  8002de:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e4:	53                   	push   %ebx
  8002e5:	ff 75 10             	pushl  0x10(%ebp)
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002f4:	ff 75 d0             	pushl  -0x30(%ebp)
  8002f7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002fa:	e8 f1 08 00 00       	call   800bf0 <__udivdi3>
  8002ff:	83 c4 18             	add    $0x18,%esp
  800302:	52                   	push   %edx
  800303:	50                   	push   %eax
  800304:	89 f2                	mov    %esi,%edx
  800306:	89 f8                	mov    %edi,%eax
  800308:	e8 89 ff ff ff       	call   800296 <printnum>
  80030d:	83 c4 20             	add    $0x20,%esp
  800310:	eb 13                	jmp    800325 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	56                   	push   %esi
  800316:	ff 75 18             	pushl  0x18(%ebp)
  800319:	ff d7                	call   *%edi
  80031b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80031e:	83 eb 01             	sub    $0x1,%ebx
  800321:	85 db                	test   %ebx,%ebx
  800323:	7f ed                	jg     800312 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800325:	83 ec 08             	sub    $0x8,%esp
  800328:	56                   	push   %esi
  800329:	83 ec 04             	sub    $0x4,%esp
  80032c:	ff 75 dc             	pushl  -0x24(%ebp)
  80032f:	ff 75 d8             	pushl  -0x28(%ebp)
  800332:	ff 75 d4             	pushl  -0x2c(%ebp)
  800335:	ff 75 d0             	pushl  -0x30(%ebp)
  800338:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80033b:	89 f3                	mov    %esi,%ebx
  80033d:	e8 ce 09 00 00       	call   800d10 <__umoddi3>
  800342:	83 c4 14             	add    $0x14,%esp
  800345:	0f be 84 06 8a ee ff 	movsbl -0x1176(%esi,%eax,1),%eax
  80034c:	ff 
  80034d:	50                   	push   %eax
  80034e:	ff d7                	call   *%edi
}
  800350:	83 c4 10             	add    $0x10,%esp
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    
  80035b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80035e:	eb be                	jmp    80031e <printnum+0x88>

00800360 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800366:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036a:	8b 10                	mov    (%eax),%edx
  80036c:	3b 50 04             	cmp    0x4(%eax),%edx
  80036f:	73 0a                	jae    80037b <sprintputch+0x1b>
		*b->buf++ = ch;
  800371:	8d 4a 01             	lea    0x1(%edx),%ecx
  800374:	89 08                	mov    %ecx,(%eax)
  800376:	8b 45 08             	mov    0x8(%ebp),%eax
  800379:	88 02                	mov    %al,(%edx)
}
  80037b:	5d                   	pop    %ebp
  80037c:	c3                   	ret    

0080037d <printfmt>:
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800383:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800386:	50                   	push   %eax
  800387:	ff 75 10             	pushl  0x10(%ebp)
  80038a:	ff 75 0c             	pushl  0xc(%ebp)
  80038d:	ff 75 08             	pushl  0x8(%ebp)
  800390:	e8 05 00 00 00       	call   80039a <vprintfmt>
}
  800395:	83 c4 10             	add    $0x10,%esp
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vprintfmt>:
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	57                   	push   %edi
  80039e:	56                   	push   %esi
  80039f:	53                   	push   %ebx
  8003a0:	83 ec 2c             	sub    $0x2c,%esp
  8003a3:	e8 f4 fc ff ff       	call   80009c <__x86.get_pc_thunk.bx>
  8003a8:	81 c3 58 1c 00 00    	add    $0x1c58,%ebx
  8003ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003b1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b4:	e9 8e 03 00 00       	jmp    800747 <.L35+0x48>
		padc = ' ';
  8003b9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003bd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003c4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003cb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8d 47 01             	lea    0x1(%edi),%eax
  8003dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e0:	0f b6 17             	movzbl (%edi),%edx
  8003e3:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003e6:	3c 55                	cmp    $0x55,%al
  8003e8:	0f 87 e1 03 00 00    	ja     8007cf <.L22>
  8003ee:	0f b6 c0             	movzbl %al,%eax
  8003f1:	89 d9                	mov    %ebx,%ecx
  8003f3:	03 8c 83 18 ef ff ff 	add    -0x10e8(%ebx,%eax,4),%ecx
  8003fa:	ff e1                	jmp    *%ecx

008003fc <.L67>:
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003ff:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800403:	eb d5                	jmp    8003da <vprintfmt+0x40>

00800405 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800408:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80040c:	eb cc                	jmp    8003da <vprintfmt+0x40>

0080040e <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	0f b6 d2             	movzbl %dl,%edx
  800411:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800414:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800419:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80041c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800420:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800423:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800426:	83 f9 09             	cmp    $0x9,%ecx
  800429:	77 55                	ja     800480 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  80042b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80042e:	eb e9                	jmp    800419 <.L29+0xb>

00800430 <.L26>:
			precision = va_arg(ap, int);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8b 00                	mov    (%eax),%eax
  800435:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 40 04             	lea    0x4(%eax),%eax
  80043e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800444:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800448:	79 90                	jns    8003da <vprintfmt+0x40>
				width = precision, precision = -1;
  80044a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80044d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800450:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800457:	eb 81                	jmp    8003da <vprintfmt+0x40>

00800459 <.L27>:
  800459:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045c:	85 c0                	test   %eax,%eax
  80045e:	ba 00 00 00 00       	mov    $0x0,%edx
  800463:	0f 49 d0             	cmovns %eax,%edx
  800466:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046c:	e9 69 ff ff ff       	jmp    8003da <vprintfmt+0x40>

00800471 <.L23>:
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800474:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047b:	e9 5a ff ff ff       	jmp    8003da <vprintfmt+0x40>
  800480:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800483:	eb bf                	jmp    800444 <.L26+0x14>

00800485 <.L33>:
			lflag++;
  800485:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80048c:	e9 49 ff ff ff       	jmp    8003da <vprintfmt+0x40>

00800491 <.L30>:
			putch(va_arg(ap, int), putdat);
  800491:	8b 45 14             	mov    0x14(%ebp),%eax
  800494:	8d 78 04             	lea    0x4(%eax),%edi
  800497:	83 ec 08             	sub    $0x8,%esp
  80049a:	56                   	push   %esi
  80049b:	ff 30                	pushl  (%eax)
  80049d:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004a0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004a3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004a6:	e9 99 02 00 00       	jmp    800744 <.L35+0x45>

008004ab <.L32>:
			err = va_arg(ap, int);
  8004ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ae:	8d 78 04             	lea    0x4(%eax),%edi
  8004b1:	8b 00                	mov    (%eax),%eax
  8004b3:	99                   	cltd   
  8004b4:	31 d0                	xor    %edx,%eax
  8004b6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b8:	83 f8 06             	cmp    $0x6,%eax
  8004bb:	7f 27                	jg     8004e4 <.L32+0x39>
  8004bd:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004c4:	85 d2                	test   %edx,%edx
  8004c6:	74 1c                	je     8004e4 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004c8:	52                   	push   %edx
  8004c9:	8d 83 ab ee ff ff    	lea    -0x1155(%ebx),%eax
  8004cf:	50                   	push   %eax
  8004d0:	56                   	push   %esi
  8004d1:	ff 75 08             	pushl  0x8(%ebp)
  8004d4:	e8 a4 fe ff ff       	call   80037d <printfmt>
  8004d9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004dc:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004df:	e9 60 02 00 00       	jmp    800744 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004e4:	50                   	push   %eax
  8004e5:	8d 83 a2 ee ff ff    	lea    -0x115e(%ebx),%eax
  8004eb:	50                   	push   %eax
  8004ec:	56                   	push   %esi
  8004ed:	ff 75 08             	pushl  0x8(%ebp)
  8004f0:	e8 88 fe ff ff       	call   80037d <printfmt>
  8004f5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f8:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004fb:	e9 44 02 00 00       	jmp    800744 <.L35+0x45>

00800500 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	83 c0 04             	add    $0x4,%eax
  800506:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80050e:	85 ff                	test   %edi,%edi
  800510:	8d 83 9b ee ff ff    	lea    -0x1165(%ebx),%eax
  800516:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800519:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80051d:	0f 8e b5 00 00 00    	jle    8005d8 <.L36+0xd8>
  800523:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800527:	75 08                	jne    800531 <.L36+0x31>
  800529:	89 75 0c             	mov    %esi,0xc(%ebp)
  80052c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052f:	eb 6d                	jmp    80059e <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	ff 75 d0             	pushl  -0x30(%ebp)
  800537:	57                   	push   %edi
  800538:	e8 50 03 00 00       	call   80088d <strnlen>
  80053d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800540:	29 c2                	sub    %eax,%edx
  800542:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800548:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80054c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800552:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800554:	eb 10                	jmp    800566 <.L36+0x66>
					putch(padc, putdat);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	56                   	push   %esi
  80055a:	ff 75 e0             	pushl  -0x20(%ebp)
  80055d:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800560:	83 ef 01             	sub    $0x1,%edi
  800563:	83 c4 10             	add    $0x10,%esp
  800566:	85 ff                	test   %edi,%edi
  800568:	7f ec                	jg     800556 <.L36+0x56>
  80056a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80056d:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800570:	85 d2                	test   %edx,%edx
  800572:	b8 00 00 00 00       	mov    $0x0,%eax
  800577:	0f 49 c2             	cmovns %edx,%eax
  80057a:	29 c2                	sub    %eax,%edx
  80057c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80057f:	89 75 0c             	mov    %esi,0xc(%ebp)
  800582:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800585:	eb 17                	jmp    80059e <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800587:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058b:	75 30                	jne    8005bd <.L36+0xbd>
					putch(ch, putdat);
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	ff 75 0c             	pushl  0xc(%ebp)
  800593:	50                   	push   %eax
  800594:	ff 55 08             	call   *0x8(%ebp)
  800597:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059a:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80059e:	83 c7 01             	add    $0x1,%edi
  8005a1:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005a5:	0f be c2             	movsbl %dl,%eax
  8005a8:	85 c0                	test   %eax,%eax
  8005aa:	74 52                	je     8005fe <.L36+0xfe>
  8005ac:	85 f6                	test   %esi,%esi
  8005ae:	78 d7                	js     800587 <.L36+0x87>
  8005b0:	83 ee 01             	sub    $0x1,%esi
  8005b3:	79 d2                	jns    800587 <.L36+0x87>
  8005b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005b8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005bb:	eb 32                	jmp    8005ef <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005bd:	0f be d2             	movsbl %dl,%edx
  8005c0:	83 ea 20             	sub    $0x20,%edx
  8005c3:	83 fa 5e             	cmp    $0x5e,%edx
  8005c6:	76 c5                	jbe    80058d <.L36+0x8d>
					putch('?', putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	ff 75 0c             	pushl  0xc(%ebp)
  8005ce:	6a 3f                	push   $0x3f
  8005d0:	ff 55 08             	call   *0x8(%ebp)
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	eb c2                	jmp    80059a <.L36+0x9a>
  8005d8:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005db:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005de:	eb be                	jmp    80059e <.L36+0x9e>
				putch(' ', putdat);
  8005e0:	83 ec 08             	sub    $0x8,%esp
  8005e3:	56                   	push   %esi
  8005e4:	6a 20                	push   $0x20
  8005e6:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005e9:	83 ef 01             	sub    $0x1,%edi
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	85 ff                	test   %edi,%edi
  8005f1:	7f ed                	jg     8005e0 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8005f3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005f6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f9:	e9 46 01 00 00       	jmp    800744 <.L35+0x45>
  8005fe:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800601:	8b 75 0c             	mov    0xc(%ebp),%esi
  800604:	eb e9                	jmp    8005ef <.L36+0xef>

00800606 <.L31>:
  800606:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  800609:	83 f9 01             	cmp    $0x1,%ecx
  80060c:	7e 40                	jle    80064e <.L31+0x48>
		return va_arg(*ap, long long);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8b 50 04             	mov    0x4(%eax),%edx
  800614:	8b 00                	mov    (%eax),%eax
  800616:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800619:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 40 08             	lea    0x8(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800625:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800629:	79 55                	jns    800680 <.L31+0x7a>
				putch('-', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	56                   	push   %esi
  80062f:	6a 2d                	push   $0x2d
  800631:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800634:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800637:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80063a:	f7 da                	neg    %edx
  80063c:	83 d1 00             	adc    $0x0,%ecx
  80063f:	f7 d9                	neg    %ecx
  800641:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800644:	b8 0a 00 00 00       	mov    $0xa,%eax
  800649:	e9 db 00 00 00       	jmp    800729 <.L35+0x2a>
	else if (lflag)
  80064e:	85 c9                	test   %ecx,%ecx
  800650:	75 17                	jne    800669 <.L31+0x63>
		return va_arg(*ap, int);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8b 00                	mov    (%eax),%eax
  800657:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065a:	99                   	cltd   
  80065b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 40 04             	lea    0x4(%eax),%eax
  800664:	89 45 14             	mov    %eax,0x14(%ebp)
  800667:	eb bc                	jmp    800625 <.L31+0x1f>
		return va_arg(*ap, long);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8b 00                	mov    (%eax),%eax
  80066e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800671:	99                   	cltd   
  800672:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 40 04             	lea    0x4(%eax),%eax
  80067b:	89 45 14             	mov    %eax,0x14(%ebp)
  80067e:	eb a5                	jmp    800625 <.L31+0x1f>
			num = getint(&ap, lflag);
  800680:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800683:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800686:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068b:	e9 99 00 00 00       	jmp    800729 <.L35+0x2a>

00800690 <.L37>:
  800690:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  800693:	83 f9 01             	cmp    $0x1,%ecx
  800696:	7e 15                	jle    8006ad <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 10                	mov    (%eax),%edx
  80069d:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a0:	8d 40 08             	lea    0x8(%eax),%eax
  8006a3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ab:	eb 7c                	jmp    800729 <.L35+0x2a>
	else if (lflag)
  8006ad:	85 c9                	test   %ecx,%ecx
  8006af:	75 17                	jne    8006c8 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 10                	mov    (%eax),%edx
  8006b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bb:	8d 40 04             	lea    0x4(%eax),%eax
  8006be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c6:	eb 61                	jmp    800729 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d2:	8d 40 04             	lea    0x4(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006dd:	eb 4a                	jmp    800729 <.L35+0x2a>

008006df <.L34>:
			putch('X', putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	56                   	push   %esi
  8006e3:	6a 58                	push   $0x58
  8006e5:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006e8:	83 c4 08             	add    $0x8,%esp
  8006eb:	56                   	push   %esi
  8006ec:	6a 58                	push   $0x58
  8006ee:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006f1:	83 c4 08             	add    $0x8,%esp
  8006f4:	56                   	push   %esi
  8006f5:	6a 58                	push   $0x58
  8006f7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	eb 45                	jmp    800744 <.L35+0x45>

008006ff <.L35>:
			putch('0', putdat);
  8006ff:	83 ec 08             	sub    $0x8,%esp
  800702:	56                   	push   %esi
  800703:	6a 30                	push   $0x30
  800705:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800708:	83 c4 08             	add    $0x8,%esp
  80070b:	56                   	push   %esi
  80070c:	6a 78                	push   $0x78
  80070e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8b 10                	mov    (%eax),%edx
  800716:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80071b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80071e:	8d 40 04             	lea    0x4(%eax),%eax
  800721:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800724:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800729:	83 ec 0c             	sub    $0xc,%esp
  80072c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800730:	57                   	push   %edi
  800731:	ff 75 e0             	pushl  -0x20(%ebp)
  800734:	50                   	push   %eax
  800735:	51                   	push   %ecx
  800736:	52                   	push   %edx
  800737:	89 f2                	mov    %esi,%edx
  800739:	8b 45 08             	mov    0x8(%ebp),%eax
  80073c:	e8 55 fb ff ff       	call   800296 <printnum>
			break;
  800741:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800744:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800747:	83 c7 01             	add    $0x1,%edi
  80074a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80074e:	83 f8 25             	cmp    $0x25,%eax
  800751:	0f 84 62 fc ff ff    	je     8003b9 <vprintfmt+0x1f>
			if (ch == '\0')
  800757:	85 c0                	test   %eax,%eax
  800759:	0f 84 91 00 00 00    	je     8007f0 <.L22+0x21>
			putch(ch, putdat);
  80075f:	83 ec 08             	sub    $0x8,%esp
  800762:	56                   	push   %esi
  800763:	50                   	push   %eax
  800764:	ff 55 08             	call   *0x8(%ebp)
  800767:	83 c4 10             	add    $0x10,%esp
  80076a:	eb db                	jmp    800747 <.L35+0x48>

0080076c <.L38>:
  80076c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  80076f:	83 f9 01             	cmp    $0x1,%ecx
  800772:	7e 15                	jle    800789 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8b 10                	mov    (%eax),%edx
  800779:	8b 48 04             	mov    0x4(%eax),%ecx
  80077c:	8d 40 08             	lea    0x8(%eax),%eax
  80077f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800782:	b8 10 00 00 00       	mov    $0x10,%eax
  800787:	eb a0                	jmp    800729 <.L35+0x2a>
	else if (lflag)
  800789:	85 c9                	test   %ecx,%ecx
  80078b:	75 17                	jne    8007a4 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	8b 10                	mov    (%eax),%edx
  800792:	b9 00 00 00 00       	mov    $0x0,%ecx
  800797:	8d 40 04             	lea    0x4(%eax),%eax
  80079a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80079d:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a2:	eb 85                	jmp    800729 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8b 10                	mov    (%eax),%edx
  8007a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ae:	8d 40 04             	lea    0x4(%eax),%eax
  8007b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b4:	b8 10 00 00 00       	mov    $0x10,%eax
  8007b9:	e9 6b ff ff ff       	jmp    800729 <.L35+0x2a>

008007be <.L25>:
			putch(ch, putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	56                   	push   %esi
  8007c2:	6a 25                	push   $0x25
  8007c4:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007c7:	83 c4 10             	add    $0x10,%esp
  8007ca:	e9 75 ff ff ff       	jmp    800744 <.L35+0x45>

008007cf <.L22>:
			putch('%', putdat);
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	56                   	push   %esi
  8007d3:	6a 25                	push   $0x25
  8007d5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	89 f8                	mov    %edi,%eax
  8007dd:	eb 03                	jmp    8007e2 <.L22+0x13>
  8007df:	83 e8 01             	sub    $0x1,%eax
  8007e2:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007e6:	75 f7                	jne    8007df <.L22+0x10>
  8007e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007eb:	e9 54 ff ff ff       	jmp    800744 <.L35+0x45>
}
  8007f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f3:	5b                   	pop    %ebx
  8007f4:	5e                   	pop    %esi
  8007f5:	5f                   	pop    %edi
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	83 ec 14             	sub    $0x14,%esp
  8007ff:	e8 98 f8 ff ff       	call   80009c <__x86.get_pc_thunk.bx>
  800804:	81 c3 fc 17 00 00    	add    $0x17fc,%ebx
  80080a:	8b 45 08             	mov    0x8(%ebp),%eax
  80080d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800810:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800813:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800817:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80081a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800821:	85 c0                	test   %eax,%eax
  800823:	74 2b                	je     800850 <vsnprintf+0x58>
  800825:	85 d2                	test   %edx,%edx
  800827:	7e 27                	jle    800850 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800829:	ff 75 14             	pushl  0x14(%ebp)
  80082c:	ff 75 10             	pushl  0x10(%ebp)
  80082f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800832:	50                   	push   %eax
  800833:	8d 83 60 e3 ff ff    	lea    -0x1ca0(%ebx),%eax
  800839:	50                   	push   %eax
  80083a:	e8 5b fb ff ff       	call   80039a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800842:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800845:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800848:	83 c4 10             	add    $0x10,%esp
}
  80084b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084e:	c9                   	leave  
  80084f:	c3                   	ret    
		return -E_INVAL;
  800850:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800855:	eb f4                	jmp    80084b <vsnprintf+0x53>

00800857 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80085d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800860:	50                   	push   %eax
  800861:	ff 75 10             	pushl  0x10(%ebp)
  800864:	ff 75 0c             	pushl  0xc(%ebp)
  800867:	ff 75 08             	pushl  0x8(%ebp)
  80086a:	e8 89 ff ff ff       	call   8007f8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80086f:	c9                   	leave  
  800870:	c3                   	ret    

00800871 <__x86.get_pc_thunk.cx>:
  800871:	8b 0c 24             	mov    (%esp),%ecx
  800874:	c3                   	ret    

00800875 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
  800880:	eb 03                	jmp    800885 <strlen+0x10>
		n++;
  800882:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800885:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800889:	75 f7                	jne    800882 <strlen+0xd>
	return n;
}
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800893:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
  80089b:	eb 03                	jmp    8008a0 <strnlen+0x13>
		n++;
  80089d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a0:	39 d0                	cmp    %edx,%eax
  8008a2:	74 06                	je     8008aa <strnlen+0x1d>
  8008a4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a8:	75 f3                	jne    80089d <strnlen+0x10>
	return n;
}
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	53                   	push   %ebx
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	83 c1 01             	add    $0x1,%ecx
  8008bb:	83 c2 01             	add    $0x1,%edx
  8008be:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008c2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008c5:	84 db                	test   %bl,%bl
  8008c7:	75 ef                	jne    8008b8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008c9:	5b                   	pop    %ebx
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	53                   	push   %ebx
  8008d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d3:	53                   	push   %ebx
  8008d4:	e8 9c ff ff ff       	call   800875 <strlen>
  8008d9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008dc:	ff 75 0c             	pushl  0xc(%ebp)
  8008df:	01 d8                	add    %ebx,%eax
  8008e1:	50                   	push   %eax
  8008e2:	e8 c5 ff ff ff       	call   8008ac <strcpy>
	return dst;
}
  8008e7:	89 d8                	mov    %ebx,%eax
  8008e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ec:	c9                   	leave  
  8008ed:	c3                   	ret    

008008ee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	56                   	push   %esi
  8008f2:	53                   	push   %ebx
  8008f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f9:	89 f3                	mov    %esi,%ebx
  8008fb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fe:	89 f2                	mov    %esi,%edx
  800900:	eb 0f                	jmp    800911 <strncpy+0x23>
		*dst++ = *src;
  800902:	83 c2 01             	add    $0x1,%edx
  800905:	0f b6 01             	movzbl (%ecx),%eax
  800908:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80090b:	80 39 01             	cmpb   $0x1,(%ecx)
  80090e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800911:	39 da                	cmp    %ebx,%edx
  800913:	75 ed                	jne    800902 <strncpy+0x14>
	}
	return ret;
}
  800915:	89 f0                	mov    %esi,%eax
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	56                   	push   %esi
  80091f:	53                   	push   %ebx
  800920:	8b 75 08             	mov    0x8(%ebp),%esi
  800923:	8b 55 0c             	mov    0xc(%ebp),%edx
  800926:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800929:	89 f0                	mov    %esi,%eax
  80092b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80092f:	85 c9                	test   %ecx,%ecx
  800931:	75 0b                	jne    80093e <strlcpy+0x23>
  800933:	eb 17                	jmp    80094c <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800935:	83 c2 01             	add    $0x1,%edx
  800938:	83 c0 01             	add    $0x1,%eax
  80093b:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80093e:	39 d8                	cmp    %ebx,%eax
  800940:	74 07                	je     800949 <strlcpy+0x2e>
  800942:	0f b6 0a             	movzbl (%edx),%ecx
  800945:	84 c9                	test   %cl,%cl
  800947:	75 ec                	jne    800935 <strlcpy+0x1a>
		*dst = '\0';
  800949:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80094c:	29 f0                	sub    %esi,%eax
}
  80094e:	5b                   	pop    %ebx
  80094f:	5e                   	pop    %esi
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800958:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095b:	eb 06                	jmp    800963 <strcmp+0x11>
		p++, q++;
  80095d:	83 c1 01             	add    $0x1,%ecx
  800960:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800963:	0f b6 01             	movzbl (%ecx),%eax
  800966:	84 c0                	test   %al,%al
  800968:	74 04                	je     80096e <strcmp+0x1c>
  80096a:	3a 02                	cmp    (%edx),%al
  80096c:	74 ef                	je     80095d <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80096e:	0f b6 c0             	movzbl %al,%eax
  800971:	0f b6 12             	movzbl (%edx),%edx
  800974:	29 d0                	sub    %edx,%eax
}
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	53                   	push   %ebx
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800982:	89 c3                	mov    %eax,%ebx
  800984:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800987:	eb 06                	jmp    80098f <strncmp+0x17>
		n--, p++, q++;
  800989:	83 c0 01             	add    $0x1,%eax
  80098c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80098f:	39 d8                	cmp    %ebx,%eax
  800991:	74 16                	je     8009a9 <strncmp+0x31>
  800993:	0f b6 08             	movzbl (%eax),%ecx
  800996:	84 c9                	test   %cl,%cl
  800998:	74 04                	je     80099e <strncmp+0x26>
  80099a:	3a 0a                	cmp    (%edx),%cl
  80099c:	74 eb                	je     800989 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80099e:	0f b6 00             	movzbl (%eax),%eax
  8009a1:	0f b6 12             	movzbl (%edx),%edx
  8009a4:	29 d0                	sub    %edx,%eax
}
  8009a6:	5b                   	pop    %ebx
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    
		return 0;
  8009a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ae:	eb f6                	jmp    8009a6 <strncmp+0x2e>

008009b0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ba:	0f b6 10             	movzbl (%eax),%edx
  8009bd:	84 d2                	test   %dl,%dl
  8009bf:	74 09                	je     8009ca <strchr+0x1a>
		if (*s == c)
  8009c1:	38 ca                	cmp    %cl,%dl
  8009c3:	74 0a                	je     8009cf <strchr+0x1f>
	for (; *s; s++)
  8009c5:	83 c0 01             	add    $0x1,%eax
  8009c8:	eb f0                	jmp    8009ba <strchr+0xa>
			return (char *) s;
	return 0;
  8009ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009db:	eb 03                	jmp    8009e0 <strfind+0xf>
  8009dd:	83 c0 01             	add    $0x1,%eax
  8009e0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009e3:	38 ca                	cmp    %cl,%dl
  8009e5:	74 04                	je     8009eb <strfind+0x1a>
  8009e7:	84 d2                	test   %dl,%dl
  8009e9:	75 f2                	jne    8009dd <strfind+0xc>
			break;
	return (char *) s;
}
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	57                   	push   %edi
  8009f1:	56                   	push   %esi
  8009f2:	53                   	push   %ebx
  8009f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f9:	85 c9                	test   %ecx,%ecx
  8009fb:	74 13                	je     800a10 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a03:	75 05                	jne    800a0a <memset+0x1d>
  800a05:	f6 c1 03             	test   $0x3,%cl
  800a08:	74 0d                	je     800a17 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0d:	fc                   	cld    
  800a0e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a10:	89 f8                	mov    %edi,%eax
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5f                   	pop    %edi
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    
		c &= 0xFF;
  800a17:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1b:	89 d3                	mov    %edx,%ebx
  800a1d:	c1 e3 08             	shl    $0x8,%ebx
  800a20:	89 d0                	mov    %edx,%eax
  800a22:	c1 e0 18             	shl    $0x18,%eax
  800a25:	89 d6                	mov    %edx,%esi
  800a27:	c1 e6 10             	shl    $0x10,%esi
  800a2a:	09 f0                	or     %esi,%eax
  800a2c:	09 c2                	or     %eax,%edx
  800a2e:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a30:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a33:	89 d0                	mov    %edx,%eax
  800a35:	fc                   	cld    
  800a36:	f3 ab                	rep stos %eax,%es:(%edi)
  800a38:	eb d6                	jmp    800a10 <memset+0x23>

00800a3a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	57                   	push   %edi
  800a3e:	56                   	push   %esi
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a48:	39 c6                	cmp    %eax,%esi
  800a4a:	73 35                	jae    800a81 <memmove+0x47>
  800a4c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a4f:	39 c2                	cmp    %eax,%edx
  800a51:	76 2e                	jbe    800a81 <memmove+0x47>
		s += n;
		d += n;
  800a53:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a56:	89 d6                	mov    %edx,%esi
  800a58:	09 fe                	or     %edi,%esi
  800a5a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a60:	74 0c                	je     800a6e <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a62:	83 ef 01             	sub    $0x1,%edi
  800a65:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a68:	fd                   	std    
  800a69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6b:	fc                   	cld    
  800a6c:	eb 21                	jmp    800a8f <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6e:	f6 c1 03             	test   $0x3,%cl
  800a71:	75 ef                	jne    800a62 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a73:	83 ef 04             	sub    $0x4,%edi
  800a76:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a79:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a7c:	fd                   	std    
  800a7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7f:	eb ea                	jmp    800a6b <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a81:	89 f2                	mov    %esi,%edx
  800a83:	09 c2                	or     %eax,%edx
  800a85:	f6 c2 03             	test   $0x3,%dl
  800a88:	74 09                	je     800a93 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a8a:	89 c7                	mov    %eax,%edi
  800a8c:	fc                   	cld    
  800a8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8f:	5e                   	pop    %esi
  800a90:	5f                   	pop    %edi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a93:	f6 c1 03             	test   $0x3,%cl
  800a96:	75 f2                	jne    800a8a <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a98:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a9b:	89 c7                	mov    %eax,%edi
  800a9d:	fc                   	cld    
  800a9e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa0:	eb ed                	jmp    800a8f <memmove+0x55>

00800aa2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aa5:	ff 75 10             	pushl  0x10(%ebp)
  800aa8:	ff 75 0c             	pushl  0xc(%ebp)
  800aab:	ff 75 08             	pushl  0x8(%ebp)
  800aae:	e8 87 ff ff ff       	call   800a3a <memmove>
}
  800ab3:	c9                   	leave  
  800ab4:	c3                   	ret    

00800ab5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
  800aba:	8b 45 08             	mov    0x8(%ebp),%eax
  800abd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac0:	89 c6                	mov    %eax,%esi
  800ac2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac5:	39 f0                	cmp    %esi,%eax
  800ac7:	74 1c                	je     800ae5 <memcmp+0x30>
		if (*s1 != *s2)
  800ac9:	0f b6 08             	movzbl (%eax),%ecx
  800acc:	0f b6 1a             	movzbl (%edx),%ebx
  800acf:	38 d9                	cmp    %bl,%cl
  800ad1:	75 08                	jne    800adb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ad3:	83 c0 01             	add    $0x1,%eax
  800ad6:	83 c2 01             	add    $0x1,%edx
  800ad9:	eb ea                	jmp    800ac5 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800adb:	0f b6 c1             	movzbl %cl,%eax
  800ade:	0f b6 db             	movzbl %bl,%ebx
  800ae1:	29 d8                	sub    %ebx,%eax
  800ae3:	eb 05                	jmp    800aea <memcmp+0x35>
	}

	return 0;
  800ae5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	8b 45 08             	mov    0x8(%ebp),%eax
  800af4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800af7:	89 c2                	mov    %eax,%edx
  800af9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800afc:	39 d0                	cmp    %edx,%eax
  800afe:	73 09                	jae    800b09 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b00:	38 08                	cmp    %cl,(%eax)
  800b02:	74 05                	je     800b09 <memfind+0x1b>
	for (; s < ends; s++)
  800b04:	83 c0 01             	add    $0x1,%eax
  800b07:	eb f3                	jmp    800afc <memfind+0xe>
			break;
	return (void *) s;
}
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b17:	eb 03                	jmp    800b1c <strtol+0x11>
		s++;
  800b19:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b1c:	0f b6 01             	movzbl (%ecx),%eax
  800b1f:	3c 20                	cmp    $0x20,%al
  800b21:	74 f6                	je     800b19 <strtol+0xe>
  800b23:	3c 09                	cmp    $0x9,%al
  800b25:	74 f2                	je     800b19 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b27:	3c 2b                	cmp    $0x2b,%al
  800b29:	74 2e                	je     800b59 <strtol+0x4e>
	int neg = 0;
  800b2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b30:	3c 2d                	cmp    $0x2d,%al
  800b32:	74 2f                	je     800b63 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b34:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3a:	75 05                	jne    800b41 <strtol+0x36>
  800b3c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3f:	74 2c                	je     800b6d <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b41:	85 db                	test   %ebx,%ebx
  800b43:	75 0a                	jne    800b4f <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b45:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b4a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b4d:	74 28                	je     800b77 <strtol+0x6c>
		base = 10;
  800b4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b54:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b57:	eb 50                	jmp    800ba9 <strtol+0x9e>
		s++;
  800b59:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b5c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b61:	eb d1                	jmp    800b34 <strtol+0x29>
		s++, neg = 1;
  800b63:	83 c1 01             	add    $0x1,%ecx
  800b66:	bf 01 00 00 00       	mov    $0x1,%edi
  800b6b:	eb c7                	jmp    800b34 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b71:	74 0e                	je     800b81 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b73:	85 db                	test   %ebx,%ebx
  800b75:	75 d8                	jne    800b4f <strtol+0x44>
		s++, base = 8;
  800b77:	83 c1 01             	add    $0x1,%ecx
  800b7a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b7f:	eb ce                	jmp    800b4f <strtol+0x44>
		s += 2, base = 16;
  800b81:	83 c1 02             	add    $0x2,%ecx
  800b84:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b89:	eb c4                	jmp    800b4f <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b8b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8e:	89 f3                	mov    %esi,%ebx
  800b90:	80 fb 19             	cmp    $0x19,%bl
  800b93:	77 29                	ja     800bbe <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b95:	0f be d2             	movsbl %dl,%edx
  800b98:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b9b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b9e:	7d 30                	jge    800bd0 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ba0:	83 c1 01             	add    $0x1,%ecx
  800ba3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ba7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ba9:	0f b6 11             	movzbl (%ecx),%edx
  800bac:	8d 72 d0             	lea    -0x30(%edx),%esi
  800baf:	89 f3                	mov    %esi,%ebx
  800bb1:	80 fb 09             	cmp    $0x9,%bl
  800bb4:	77 d5                	ja     800b8b <strtol+0x80>
			dig = *s - '0';
  800bb6:	0f be d2             	movsbl %dl,%edx
  800bb9:	83 ea 30             	sub    $0x30,%edx
  800bbc:	eb dd                	jmp    800b9b <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bbe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc1:	89 f3                	mov    %esi,%ebx
  800bc3:	80 fb 19             	cmp    $0x19,%bl
  800bc6:	77 08                	ja     800bd0 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bc8:	0f be d2             	movsbl %dl,%edx
  800bcb:	83 ea 37             	sub    $0x37,%edx
  800bce:	eb cb                	jmp    800b9b <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bd0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd4:	74 05                	je     800bdb <strtol+0xd0>
		*endptr = (char *) s;
  800bd6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bdb:	89 c2                	mov    %eax,%edx
  800bdd:	f7 da                	neg    %edx
  800bdf:	85 ff                	test   %edi,%edi
  800be1:	0f 45 c2             	cmovne %edx,%eax
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    
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
