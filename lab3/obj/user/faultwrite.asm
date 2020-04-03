
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	57                   	push   %edi
  800046:	56                   	push   %esi
  800047:	53                   	push   %ebx
  800048:	83 ec 0c             	sub    $0xc,%esp
  80004b:	e8 50 00 00 00       	call   8000a0 <__x86.get_pc_thunk.bx>
  800050:	81 c3 b0 1f 00 00    	add    $0x1fb0,%ebx
  800056:	8b 75 08             	mov    0x8(%ebp),%esi
  800059:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

	thisenv = envs+ENVX(sys_getenvid());
  80005c:	e8 f6 00 00 00       	call   800157 <sys_getenvid>
  800061:	25 ff 03 00 00       	and    $0x3ff,%eax
  800066:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800069:	c1 e0 05             	shl    $0x5,%eax
  80006c:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800072:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  800078:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 f6                	test   %esi,%esi
  80007c:	7e 08                	jle    800086 <libmain+0x44>
		binaryname = argv[0];
  80007e:	8b 07                	mov    (%edi),%eax
  800080:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800086:	83 ec 08             	sub    $0x8,%esp
  800089:	57                   	push   %edi
  80008a:	56                   	push   %esi
  80008b:	e8 a3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800090:	e8 0f 00 00 00       	call   8000a4 <exit>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	5f                   	pop    %edi
  80009e:	5d                   	pop    %ebp
  80009f:	c3                   	ret    

008000a0 <__x86.get_pc_thunk.bx>:
  8000a0:	8b 1c 24             	mov    (%esp),%ebx
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	53                   	push   %ebx
  8000a8:	83 ec 10             	sub    $0x10,%esp
  8000ab:	e8 f0 ff ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  8000b0:	81 c3 50 1f 00 00    	add    $0x1f50,%ebx
	sys_env_destroy(0);
  8000b6:	6a 00                	push   $0x0
  8000b8:	e8 45 00 00 00       	call   800102 <sys_env_destroy>
}
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 1c             	sub    $0x1c,%esp
  80010b:	e8 66 00 00 00       	call   800176 <__x86.get_pc_thunk.ax>
  800110:	05 f0 1e 00 00       	add    $0x1ef0,%eax
  800115:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800118:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011d:	8b 55 08             	mov    0x8(%ebp),%edx
  800120:	b8 03 00 00 00       	mov    $0x3,%eax
  800125:	89 cb                	mov    %ecx,%ebx
  800127:	89 cf                	mov    %ecx,%edi
  800129:	89 ce                	mov    %ecx,%esi
  80012b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80012d:	85 c0                	test   %eax,%eax
  80012f:	7f 08                	jg     800139 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800131:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800134:	5b                   	pop    %ebx
  800135:	5e                   	pop    %esi
  800136:	5f                   	pop    %edi
  800137:	5d                   	pop    %ebp
  800138:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800139:	83 ec 0c             	sub    $0xc,%esp
  80013c:	50                   	push   %eax
  80013d:	6a 03                	push   $0x3
  80013f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800142:	8d 83 36 ee ff ff    	lea    -0x11ca(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	6a 23                	push   $0x23
  80014b:	8d 83 53 ee ff ff    	lea    -0x11ad(%ebx),%eax
  800151:	50                   	push   %eax
  800152:	e8 23 00 00 00       	call   80017a <_panic>

00800157 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	57                   	push   %edi
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015d:	ba 00 00 00 00       	mov    $0x0,%edx
  800162:	b8 02 00 00 00       	mov    $0x2,%eax
  800167:	89 d1                	mov    %edx,%ecx
  800169:	89 d3                	mov    %edx,%ebx
  80016b:	89 d7                	mov    %edx,%edi
  80016d:	89 d6                	mov    %edx,%esi
  80016f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800171:	5b                   	pop    %ebx
  800172:	5e                   	pop    %esi
  800173:	5f                   	pop    %edi
  800174:	5d                   	pop    %ebp
  800175:	c3                   	ret    

00800176 <__x86.get_pc_thunk.ax>:
  800176:	8b 04 24             	mov    (%esp),%eax
  800179:	c3                   	ret    

0080017a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	57                   	push   %edi
  80017e:	56                   	push   %esi
  80017f:	53                   	push   %ebx
  800180:	83 ec 0c             	sub    $0xc,%esp
  800183:	e8 18 ff ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  800188:	81 c3 78 1e 00 00    	add    $0x1e78,%ebx
	va_list ap;

	va_start(ap, fmt);
  80018e:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800191:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800197:	8b 38                	mov    (%eax),%edi
  800199:	e8 b9 ff ff ff       	call   800157 <sys_getenvid>
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	ff 75 0c             	pushl  0xc(%ebp)
  8001a4:	ff 75 08             	pushl  0x8(%ebp)
  8001a7:	57                   	push   %edi
  8001a8:	50                   	push   %eax
  8001a9:	8d 83 64 ee ff ff    	lea    -0x119c(%ebx),%eax
  8001af:	50                   	push   %eax
  8001b0:	e8 d1 00 00 00       	call   800286 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b5:	83 c4 18             	add    $0x18,%esp
  8001b8:	56                   	push   %esi
  8001b9:	ff 75 10             	pushl  0x10(%ebp)
  8001bc:	e8 63 00 00 00       	call   800224 <vcprintf>
	cprintf("\n");
  8001c1:	8d 83 88 ee ff ff    	lea    -0x1178(%ebx),%eax
  8001c7:	89 04 24             	mov    %eax,(%esp)
  8001ca:	e8 b7 00 00 00       	call   800286 <cprintf>
  8001cf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d2:	cc                   	int3   
  8001d3:	eb fd                	jmp    8001d2 <_panic+0x58>

008001d5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	56                   	push   %esi
  8001d9:	53                   	push   %ebx
  8001da:	e8 c1 fe ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  8001df:	81 c3 21 1e 00 00    	add    $0x1e21,%ebx
  8001e5:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001e8:	8b 16                	mov    (%esi),%edx
  8001ea:	8d 42 01             	lea    0x1(%edx),%eax
  8001ed:	89 06                	mov    %eax,(%esi)
  8001ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f2:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001fb:	74 0b                	je     800208 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001fd:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800201:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5d                   	pop    %ebp
  800207:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	68 ff 00 00 00       	push   $0xff
  800210:	8d 46 08             	lea    0x8(%esi),%eax
  800213:	50                   	push   %eax
  800214:	e8 ac fe ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  800219:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80021f:	83 c4 10             	add    $0x10,%esp
  800222:	eb d9                	jmp    8001fd <putch+0x28>

00800224 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	53                   	push   %ebx
  800228:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80022e:	e8 6d fe ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  800233:	81 c3 cd 1d 00 00    	add    $0x1dcd,%ebx
	struct printbuf b;

	b.idx = 0;
  800239:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800240:	00 00 00 
	b.cnt = 0;
  800243:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024d:	ff 75 0c             	pushl  0xc(%ebp)
  800250:	ff 75 08             	pushl  0x8(%ebp)
  800253:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800259:	50                   	push   %eax
  80025a:	8d 83 d5 e1 ff ff    	lea    -0x1e2b(%ebx),%eax
  800260:	50                   	push   %eax
  800261:	e8 38 01 00 00       	call   80039e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800266:	83 c4 08             	add    $0x8,%esp
  800269:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80026f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800275:	50                   	push   %eax
  800276:	e8 4a fe ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  80027b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800281:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800284:	c9                   	leave  
  800285:	c3                   	ret    

00800286 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028f:	50                   	push   %eax
  800290:	ff 75 08             	pushl  0x8(%ebp)
  800293:	e8 8c ff ff ff       	call   800224 <vcprintf>
	va_end(ap);

	return cnt;
}
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	57                   	push   %edi
  80029e:	56                   	push   %esi
  80029f:	53                   	push   %ebx
  8002a0:	83 ec 2c             	sub    $0x2c,%esp
  8002a3:	e8 cd 05 00 00       	call   800875 <__x86.get_pc_thunk.cx>
  8002a8:	81 c1 58 1d 00 00    	add    $0x1d58,%ecx
  8002ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002b1:	89 c7                	mov    %eax,%edi
  8002b3:	89 d6                	mov    %edx,%esi
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002be:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002cc:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002cf:	39 d3                	cmp    %edx,%ebx
  8002d1:	72 09                	jb     8002dc <printnum+0x42>
  8002d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d6:	0f 87 83 00 00 00    	ja     80035f <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002dc:	83 ec 0c             	sub    $0xc,%esp
  8002df:	ff 75 18             	pushl  0x18(%ebp)
  8002e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e8:	53                   	push   %ebx
  8002e9:	ff 75 10             	pushl  0x10(%ebp)
  8002ec:	83 ec 08             	sub    $0x8,%esp
  8002ef:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002f8:	ff 75 d0             	pushl  -0x30(%ebp)
  8002fb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002fe:	e8 ed 08 00 00       	call   800bf0 <__udivdi3>
  800303:	83 c4 18             	add    $0x18,%esp
  800306:	52                   	push   %edx
  800307:	50                   	push   %eax
  800308:	89 f2                	mov    %esi,%edx
  80030a:	89 f8                	mov    %edi,%eax
  80030c:	e8 89 ff ff ff       	call   80029a <printnum>
  800311:	83 c4 20             	add    $0x20,%esp
  800314:	eb 13                	jmp    800329 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800316:	83 ec 08             	sub    $0x8,%esp
  800319:	56                   	push   %esi
  80031a:	ff 75 18             	pushl  0x18(%ebp)
  80031d:	ff d7                	call   *%edi
  80031f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800322:	83 eb 01             	sub    $0x1,%ebx
  800325:	85 db                	test   %ebx,%ebx
  800327:	7f ed                	jg     800316 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800329:	83 ec 08             	sub    $0x8,%esp
  80032c:	56                   	push   %esi
  80032d:	83 ec 04             	sub    $0x4,%esp
  800330:	ff 75 dc             	pushl  -0x24(%ebp)
  800333:	ff 75 d8             	pushl  -0x28(%ebp)
  800336:	ff 75 d4             	pushl  -0x2c(%ebp)
  800339:	ff 75 d0             	pushl  -0x30(%ebp)
  80033c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80033f:	89 f3                	mov    %esi,%ebx
  800341:	e8 ca 09 00 00       	call   800d10 <__umoddi3>
  800346:	83 c4 14             	add    $0x14,%esp
  800349:	0f be 84 06 8a ee ff 	movsbl -0x1176(%esi,%eax,1),%eax
  800350:	ff 
  800351:	50                   	push   %eax
  800352:	ff d7                	call   *%edi
}
  800354:	83 c4 10             	add    $0x10,%esp
  800357:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035a:	5b                   	pop    %ebx
  80035b:	5e                   	pop    %esi
  80035c:	5f                   	pop    %edi
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    
  80035f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800362:	eb be                	jmp    800322 <printnum+0x88>

00800364 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036e:	8b 10                	mov    (%eax),%edx
  800370:	3b 50 04             	cmp    0x4(%eax),%edx
  800373:	73 0a                	jae    80037f <sprintputch+0x1b>
		*b->buf++ = ch;
  800375:	8d 4a 01             	lea    0x1(%edx),%ecx
  800378:	89 08                	mov    %ecx,(%eax)
  80037a:	8b 45 08             	mov    0x8(%ebp),%eax
  80037d:	88 02                	mov    %al,(%edx)
}
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <printfmt>:
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800387:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038a:	50                   	push   %eax
  80038b:	ff 75 10             	pushl  0x10(%ebp)
  80038e:	ff 75 0c             	pushl  0xc(%ebp)
  800391:	ff 75 08             	pushl  0x8(%ebp)
  800394:	e8 05 00 00 00       	call   80039e <vprintfmt>
}
  800399:	83 c4 10             	add    $0x10,%esp
  80039c:	c9                   	leave  
  80039d:	c3                   	ret    

0080039e <vprintfmt>:
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	57                   	push   %edi
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	83 ec 2c             	sub    $0x2c,%esp
  8003a7:	e8 f4 fc ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  8003ac:	81 c3 54 1c 00 00    	add    $0x1c54,%ebx
  8003b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003b5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b8:	e9 8e 03 00 00       	jmp    80074b <.L35+0x48>
		padc = ' ';
  8003bd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003c1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003c8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003cf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003db:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8d 47 01             	lea    0x1(%edi),%eax
  8003e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e4:	0f b6 17             	movzbl (%edi),%edx
  8003e7:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003ea:	3c 55                	cmp    $0x55,%al
  8003ec:	0f 87 e1 03 00 00    	ja     8007d3 <.L22>
  8003f2:	0f b6 c0             	movzbl %al,%eax
  8003f5:	89 d9                	mov    %ebx,%ecx
  8003f7:	03 8c 83 18 ef ff ff 	add    -0x10e8(%ebx,%eax,4),%ecx
  8003fe:	ff e1                	jmp    *%ecx

00800400 <.L67>:
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800403:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800407:	eb d5                	jmp    8003de <vprintfmt+0x40>

00800409 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80040c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800410:	eb cc                	jmp    8003de <vprintfmt+0x40>

00800412 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	0f b6 d2             	movzbl %dl,%edx
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800418:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80041d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800420:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800424:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800427:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80042a:	83 f9 09             	cmp    $0x9,%ecx
  80042d:	77 55                	ja     800484 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  80042f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800432:	eb e9                	jmp    80041d <.L29+0xb>

00800434 <.L26>:
			precision = va_arg(ap, int);
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8b 00                	mov    (%eax),%eax
  800439:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80043c:	8b 45 14             	mov    0x14(%ebp),%eax
  80043f:	8d 40 04             	lea    0x4(%eax),%eax
  800442:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800445:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800448:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044c:	79 90                	jns    8003de <vprintfmt+0x40>
				width = precision, precision = -1;
  80044e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800451:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800454:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045b:	eb 81                	jmp    8003de <vprintfmt+0x40>

0080045d <.L27>:
  80045d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800460:	85 c0                	test   %eax,%eax
  800462:	ba 00 00 00 00       	mov    $0x0,%edx
  800467:	0f 49 d0             	cmovns %eax,%edx
  80046a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800470:	e9 69 ff ff ff       	jmp    8003de <vprintfmt+0x40>

00800475 <.L23>:
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800478:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047f:	e9 5a ff ff ff       	jmp    8003de <vprintfmt+0x40>
  800484:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800487:	eb bf                	jmp    800448 <.L26+0x14>

00800489 <.L33>:
			lflag++;
  800489:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800490:	e9 49 ff ff ff       	jmp    8003de <vprintfmt+0x40>

00800495 <.L30>:
			putch(va_arg(ap, int), putdat);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 78 04             	lea    0x4(%eax),%edi
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	56                   	push   %esi
  80049f:	ff 30                	pushl  (%eax)
  8004a1:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004a4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004a7:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004aa:	e9 99 02 00 00       	jmp    800748 <.L35+0x45>

008004af <.L32>:
			err = va_arg(ap, int);
  8004af:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b2:	8d 78 04             	lea    0x4(%eax),%edi
  8004b5:	8b 00                	mov    (%eax),%eax
  8004b7:	99                   	cltd   
  8004b8:	31 d0                	xor    %edx,%eax
  8004ba:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004bc:	83 f8 06             	cmp    $0x6,%eax
  8004bf:	7f 27                	jg     8004e8 <.L32+0x39>
  8004c1:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004c8:	85 d2                	test   %edx,%edx
  8004ca:	74 1c                	je     8004e8 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004cc:	52                   	push   %edx
  8004cd:	8d 83 ab ee ff ff    	lea    -0x1155(%ebx),%eax
  8004d3:	50                   	push   %eax
  8004d4:	56                   	push   %esi
  8004d5:	ff 75 08             	pushl  0x8(%ebp)
  8004d8:	e8 a4 fe ff ff       	call   800381 <printfmt>
  8004dd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004e0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004e3:	e9 60 02 00 00       	jmp    800748 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004e8:	50                   	push   %eax
  8004e9:	8d 83 a2 ee ff ff    	lea    -0x115e(%ebx),%eax
  8004ef:	50                   	push   %eax
  8004f0:	56                   	push   %esi
  8004f1:	ff 75 08             	pushl  0x8(%ebp)
  8004f4:	e8 88 fe ff ff       	call   800381 <printfmt>
  8004f9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004fc:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004ff:	e9 44 02 00 00       	jmp    800748 <.L35+0x45>

00800504 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	83 c0 04             	add    $0x4,%eax
  80050a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800512:	85 ff                	test   %edi,%edi
  800514:	8d 83 9b ee ff ff    	lea    -0x1165(%ebx),%eax
  80051a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80051d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800521:	0f 8e b5 00 00 00    	jle    8005dc <.L36+0xd8>
  800527:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80052b:	75 08                	jne    800535 <.L36+0x31>
  80052d:	89 75 0c             	mov    %esi,0xc(%ebp)
  800530:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800533:	eb 6d                	jmp    8005a2 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	ff 75 d0             	pushl  -0x30(%ebp)
  80053b:	57                   	push   %edi
  80053c:	e8 50 03 00 00       	call   800891 <strnlen>
  800541:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800544:	29 c2                	sub    %eax,%edx
  800546:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800549:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80054c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800550:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800553:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800556:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800558:	eb 10                	jmp    80056a <.L36+0x66>
					putch(padc, putdat);
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	56                   	push   %esi
  80055e:	ff 75 e0             	pushl  -0x20(%ebp)
  800561:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800564:	83 ef 01             	sub    $0x1,%edi
  800567:	83 c4 10             	add    $0x10,%esp
  80056a:	85 ff                	test   %edi,%edi
  80056c:	7f ec                	jg     80055a <.L36+0x56>
  80056e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800571:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800574:	85 d2                	test   %edx,%edx
  800576:	b8 00 00 00 00       	mov    $0x0,%eax
  80057b:	0f 49 c2             	cmovns %edx,%eax
  80057e:	29 c2                	sub    %eax,%edx
  800580:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800583:	89 75 0c             	mov    %esi,0xc(%ebp)
  800586:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800589:	eb 17                	jmp    8005a2 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  80058b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058f:	75 30                	jne    8005c1 <.L36+0xbd>
					putch(ch, putdat);
  800591:	83 ec 08             	sub    $0x8,%esp
  800594:	ff 75 0c             	pushl  0xc(%ebp)
  800597:	50                   	push   %eax
  800598:	ff 55 08             	call   *0x8(%ebp)
  80059b:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059e:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005a2:	83 c7 01             	add    $0x1,%edi
  8005a5:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005a9:	0f be c2             	movsbl %dl,%eax
  8005ac:	85 c0                	test   %eax,%eax
  8005ae:	74 52                	je     800602 <.L36+0xfe>
  8005b0:	85 f6                	test   %esi,%esi
  8005b2:	78 d7                	js     80058b <.L36+0x87>
  8005b4:	83 ee 01             	sub    $0x1,%esi
  8005b7:	79 d2                	jns    80058b <.L36+0x87>
  8005b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005bf:	eb 32                	jmp    8005f3 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005c1:	0f be d2             	movsbl %dl,%edx
  8005c4:	83 ea 20             	sub    $0x20,%edx
  8005c7:	83 fa 5e             	cmp    $0x5e,%edx
  8005ca:	76 c5                	jbe    800591 <.L36+0x8d>
					putch('?', putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	ff 75 0c             	pushl  0xc(%ebp)
  8005d2:	6a 3f                	push   $0x3f
  8005d4:	ff 55 08             	call   *0x8(%ebp)
  8005d7:	83 c4 10             	add    $0x10,%esp
  8005da:	eb c2                	jmp    80059e <.L36+0x9a>
  8005dc:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e2:	eb be                	jmp    8005a2 <.L36+0x9e>
				putch(' ', putdat);
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	56                   	push   %esi
  8005e8:	6a 20                	push   $0x20
  8005ea:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005ed:	83 ef 01             	sub    $0x1,%edi
  8005f0:	83 c4 10             	add    $0x10,%esp
  8005f3:	85 ff                	test   %edi,%edi
  8005f5:	7f ed                	jg     8005e4 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8005f7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005fa:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fd:	e9 46 01 00 00       	jmp    800748 <.L35+0x45>
  800602:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800605:	8b 75 0c             	mov    0xc(%ebp),%esi
  800608:	eb e9                	jmp    8005f3 <.L36+0xef>

0080060a <.L31>:
  80060a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  80060d:	83 f9 01             	cmp    $0x1,%ecx
  800610:	7e 40                	jle    800652 <.L31+0x48>
		return va_arg(*ap, long long);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8b 50 04             	mov    0x4(%eax),%edx
  800618:	8b 00                	mov    (%eax),%eax
  80061a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 40 08             	lea    0x8(%eax),%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800629:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062d:	79 55                	jns    800684 <.L31+0x7a>
				putch('-', putdat);
  80062f:	83 ec 08             	sub    $0x8,%esp
  800632:	56                   	push   %esi
  800633:	6a 2d                	push   $0x2d
  800635:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800638:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80063b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80063e:	f7 da                	neg    %edx
  800640:	83 d1 00             	adc    $0x0,%ecx
  800643:	f7 d9                	neg    %ecx
  800645:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800648:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064d:	e9 db 00 00 00       	jmp    80072d <.L35+0x2a>
	else if (lflag)
  800652:	85 c9                	test   %ecx,%ecx
  800654:	75 17                	jne    80066d <.L31+0x63>
		return va_arg(*ap, int);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 00                	mov    (%eax),%eax
  80065b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065e:	99                   	cltd   
  80065f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 40 04             	lea    0x4(%eax),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)
  80066b:	eb bc                	jmp    800629 <.L31+0x1f>
		return va_arg(*ap, long);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8b 00                	mov    (%eax),%eax
  800672:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800675:	99                   	cltd   
  800676:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8d 40 04             	lea    0x4(%eax),%eax
  80067f:	89 45 14             	mov    %eax,0x14(%ebp)
  800682:	eb a5                	jmp    800629 <.L31+0x1f>
			num = getint(&ap, lflag);
  800684:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800687:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80068a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068f:	e9 99 00 00 00       	jmp    80072d <.L35+0x2a>

00800694 <.L37>:
  800694:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  800697:	83 f9 01             	cmp    $0x1,%ecx
  80069a:	7e 15                	jle    8006b1 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8b 10                	mov    (%eax),%edx
  8006a1:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a4:	8d 40 08             	lea    0x8(%eax),%eax
  8006a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006aa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006af:	eb 7c                	jmp    80072d <.L35+0x2a>
	else if (lflag)
  8006b1:	85 c9                	test   %ecx,%ecx
  8006b3:	75 17                	jne    8006cc <.L37+0x38>
		return va_arg(*ap, unsigned int);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8b 10                	mov    (%eax),%edx
  8006ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bf:	8d 40 04             	lea    0x4(%eax),%eax
  8006c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ca:	eb 61                	jmp    80072d <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8b 10                	mov    (%eax),%edx
  8006d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d6:	8d 40 04             	lea    0x4(%eax),%eax
  8006d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e1:	eb 4a                	jmp    80072d <.L35+0x2a>

008006e3 <.L34>:
			putch('X', putdat);
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	56                   	push   %esi
  8006e7:	6a 58                	push   $0x58
  8006e9:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006ec:	83 c4 08             	add    $0x8,%esp
  8006ef:	56                   	push   %esi
  8006f0:	6a 58                	push   $0x58
  8006f2:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006f5:	83 c4 08             	add    $0x8,%esp
  8006f8:	56                   	push   %esi
  8006f9:	6a 58                	push   $0x58
  8006fb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	eb 45                	jmp    800748 <.L35+0x45>

00800703 <.L35>:
			putch('0', putdat);
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	56                   	push   %esi
  800707:	6a 30                	push   $0x30
  800709:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80070c:	83 c4 08             	add    $0x8,%esp
  80070f:	56                   	push   %esi
  800710:	6a 78                	push   $0x78
  800712:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8b 10                	mov    (%eax),%edx
  80071a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80071f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800722:	8d 40 04             	lea    0x4(%eax),%eax
  800725:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800728:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80072d:	83 ec 0c             	sub    $0xc,%esp
  800730:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800734:	57                   	push   %edi
  800735:	ff 75 e0             	pushl  -0x20(%ebp)
  800738:	50                   	push   %eax
  800739:	51                   	push   %ecx
  80073a:	52                   	push   %edx
  80073b:	89 f2                	mov    %esi,%edx
  80073d:	8b 45 08             	mov    0x8(%ebp),%eax
  800740:	e8 55 fb ff ff       	call   80029a <printnum>
			break;
  800745:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800748:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80074b:	83 c7 01             	add    $0x1,%edi
  80074e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800752:	83 f8 25             	cmp    $0x25,%eax
  800755:	0f 84 62 fc ff ff    	je     8003bd <vprintfmt+0x1f>
			if (ch == '\0')
  80075b:	85 c0                	test   %eax,%eax
  80075d:	0f 84 91 00 00 00    	je     8007f4 <.L22+0x21>
			putch(ch, putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	56                   	push   %esi
  800767:	50                   	push   %eax
  800768:	ff 55 08             	call   *0x8(%ebp)
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	eb db                	jmp    80074b <.L35+0x48>

00800770 <.L38>:
  800770:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  800773:	83 f9 01             	cmp    $0x1,%ecx
  800776:	7e 15                	jle    80078d <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8b 10                	mov    (%eax),%edx
  80077d:	8b 48 04             	mov    0x4(%eax),%ecx
  800780:	8d 40 08             	lea    0x8(%eax),%eax
  800783:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800786:	b8 10 00 00 00       	mov    $0x10,%eax
  80078b:	eb a0                	jmp    80072d <.L35+0x2a>
	else if (lflag)
  80078d:	85 c9                	test   %ecx,%ecx
  80078f:	75 17                	jne    8007a8 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8b 10                	mov    (%eax),%edx
  800796:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079b:	8d 40 04             	lea    0x4(%eax),%eax
  80079e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a1:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a6:	eb 85                	jmp    80072d <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ab:	8b 10                	mov    (%eax),%edx
  8007ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b2:	8d 40 04             	lea    0x4(%eax),%eax
  8007b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b8:	b8 10 00 00 00       	mov    $0x10,%eax
  8007bd:	e9 6b ff ff ff       	jmp    80072d <.L35+0x2a>

008007c2 <.L25>:
			putch(ch, putdat);
  8007c2:	83 ec 08             	sub    $0x8,%esp
  8007c5:	56                   	push   %esi
  8007c6:	6a 25                	push   $0x25
  8007c8:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007cb:	83 c4 10             	add    $0x10,%esp
  8007ce:	e9 75 ff ff ff       	jmp    800748 <.L35+0x45>

008007d3 <.L22>:
			putch('%', putdat);
  8007d3:	83 ec 08             	sub    $0x8,%esp
  8007d6:	56                   	push   %esi
  8007d7:	6a 25                	push   $0x25
  8007d9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007dc:	83 c4 10             	add    $0x10,%esp
  8007df:	89 f8                	mov    %edi,%eax
  8007e1:	eb 03                	jmp    8007e6 <.L22+0x13>
  8007e3:	83 e8 01             	sub    $0x1,%eax
  8007e6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007ea:	75 f7                	jne    8007e3 <.L22+0x10>
  8007ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007ef:	e9 54 ff ff ff       	jmp    800748 <.L35+0x45>
}
  8007f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f7:	5b                   	pop    %ebx
  8007f8:	5e                   	pop    %esi
  8007f9:	5f                   	pop    %edi
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	53                   	push   %ebx
  800800:	83 ec 14             	sub    $0x14,%esp
  800803:	e8 98 f8 ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  800808:	81 c3 f8 17 00 00    	add    $0x17f8,%ebx
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800814:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800817:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80081b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80081e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800825:	85 c0                	test   %eax,%eax
  800827:	74 2b                	je     800854 <vsnprintf+0x58>
  800829:	85 d2                	test   %edx,%edx
  80082b:	7e 27                	jle    800854 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80082d:	ff 75 14             	pushl  0x14(%ebp)
  800830:	ff 75 10             	pushl  0x10(%ebp)
  800833:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800836:	50                   	push   %eax
  800837:	8d 83 64 e3 ff ff    	lea    -0x1c9c(%ebx),%eax
  80083d:	50                   	push   %eax
  80083e:	e8 5b fb ff ff       	call   80039e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800843:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800846:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800849:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084c:	83 c4 10             	add    $0x10,%esp
}
  80084f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800852:	c9                   	leave  
  800853:	c3                   	ret    
		return -E_INVAL;
  800854:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800859:	eb f4                	jmp    80084f <vsnprintf+0x53>

0080085b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800861:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800864:	50                   	push   %eax
  800865:	ff 75 10             	pushl  0x10(%ebp)
  800868:	ff 75 0c             	pushl  0xc(%ebp)
  80086b:	ff 75 08             	pushl  0x8(%ebp)
  80086e:	e8 89 ff ff ff       	call   8007fc <vsnprintf>
	va_end(ap);

	return rc;
}
  800873:	c9                   	leave  
  800874:	c3                   	ret    

00800875 <__x86.get_pc_thunk.cx>:
  800875:	8b 0c 24             	mov    (%esp),%ecx
  800878:	c3                   	ret    

00800879 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
  800884:	eb 03                	jmp    800889 <strlen+0x10>
		n++;
  800886:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800889:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80088d:	75 f7                	jne    800886 <strlen+0xd>
	return n;
}
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800897:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
  80089f:	eb 03                	jmp    8008a4 <strnlen+0x13>
		n++;
  8008a1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a4:	39 d0                	cmp    %edx,%eax
  8008a6:	74 06                	je     8008ae <strnlen+0x1d>
  8008a8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008ac:	75 f3                	jne    8008a1 <strnlen+0x10>
	return n;
}
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	53                   	push   %ebx
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ba:	89 c2                	mov    %eax,%edx
  8008bc:	83 c1 01             	add    $0x1,%ecx
  8008bf:	83 c2 01             	add    $0x1,%edx
  8008c2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008c6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008c9:	84 db                	test   %bl,%bl
  8008cb:	75 ef                	jne    8008bc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008cd:	5b                   	pop    %ebx
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	53                   	push   %ebx
  8008d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d7:	53                   	push   %ebx
  8008d8:	e8 9c ff ff ff       	call   800879 <strlen>
  8008dd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008e0:	ff 75 0c             	pushl  0xc(%ebp)
  8008e3:	01 d8                	add    %ebx,%eax
  8008e5:	50                   	push   %eax
  8008e6:	e8 c5 ff ff ff       	call   8008b0 <strcpy>
	return dst;
}
  8008eb:	89 d8                	mov    %ebx,%eax
  8008ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fd:	89 f3                	mov    %esi,%ebx
  8008ff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800902:	89 f2                	mov    %esi,%edx
  800904:	eb 0f                	jmp    800915 <strncpy+0x23>
		*dst++ = *src;
  800906:	83 c2 01             	add    $0x1,%edx
  800909:	0f b6 01             	movzbl (%ecx),%eax
  80090c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80090f:	80 39 01             	cmpb   $0x1,(%ecx)
  800912:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800915:	39 da                	cmp    %ebx,%edx
  800917:	75 ed                	jne    800906 <strncpy+0x14>
	}
	return ret;
}
  800919:	89 f0                	mov    %esi,%eax
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 75 08             	mov    0x8(%ebp),%esi
  800927:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80092d:	89 f0                	mov    %esi,%eax
  80092f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800933:	85 c9                	test   %ecx,%ecx
  800935:	75 0b                	jne    800942 <strlcpy+0x23>
  800937:	eb 17                	jmp    800950 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800939:	83 c2 01             	add    $0x1,%edx
  80093c:	83 c0 01             	add    $0x1,%eax
  80093f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800942:	39 d8                	cmp    %ebx,%eax
  800944:	74 07                	je     80094d <strlcpy+0x2e>
  800946:	0f b6 0a             	movzbl (%edx),%ecx
  800949:	84 c9                	test   %cl,%cl
  80094b:	75 ec                	jne    800939 <strlcpy+0x1a>
		*dst = '\0';
  80094d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800950:	29 f0                	sub    %esi,%eax
}
  800952:	5b                   	pop    %ebx
  800953:	5e                   	pop    %esi
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095f:	eb 06                	jmp    800967 <strcmp+0x11>
		p++, q++;
  800961:	83 c1 01             	add    $0x1,%ecx
  800964:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800967:	0f b6 01             	movzbl (%ecx),%eax
  80096a:	84 c0                	test   %al,%al
  80096c:	74 04                	je     800972 <strcmp+0x1c>
  80096e:	3a 02                	cmp    (%edx),%al
  800970:	74 ef                	je     800961 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800972:	0f b6 c0             	movzbl %al,%eax
  800975:	0f b6 12             	movzbl (%edx),%edx
  800978:	29 d0                	sub    %edx,%eax
}
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	53                   	push   %ebx
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 55 0c             	mov    0xc(%ebp),%edx
  800986:	89 c3                	mov    %eax,%ebx
  800988:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80098b:	eb 06                	jmp    800993 <strncmp+0x17>
		n--, p++, q++;
  80098d:	83 c0 01             	add    $0x1,%eax
  800990:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800993:	39 d8                	cmp    %ebx,%eax
  800995:	74 16                	je     8009ad <strncmp+0x31>
  800997:	0f b6 08             	movzbl (%eax),%ecx
  80099a:	84 c9                	test   %cl,%cl
  80099c:	74 04                	je     8009a2 <strncmp+0x26>
  80099e:	3a 0a                	cmp    (%edx),%cl
  8009a0:	74 eb                	je     80098d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a2:	0f b6 00             	movzbl (%eax),%eax
  8009a5:	0f b6 12             	movzbl (%edx),%edx
  8009a8:	29 d0                	sub    %edx,%eax
}
  8009aa:	5b                   	pop    %ebx
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    
		return 0;
  8009ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b2:	eb f6                	jmp    8009aa <strncmp+0x2e>

008009b4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009be:	0f b6 10             	movzbl (%eax),%edx
  8009c1:	84 d2                	test   %dl,%dl
  8009c3:	74 09                	je     8009ce <strchr+0x1a>
		if (*s == c)
  8009c5:	38 ca                	cmp    %cl,%dl
  8009c7:	74 0a                	je     8009d3 <strchr+0x1f>
	for (; *s; s++)
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	eb f0                	jmp    8009be <strchr+0xa>
			return (char *) s;
	return 0;
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009df:	eb 03                	jmp    8009e4 <strfind+0xf>
  8009e1:	83 c0 01             	add    $0x1,%eax
  8009e4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009e7:	38 ca                	cmp    %cl,%dl
  8009e9:	74 04                	je     8009ef <strfind+0x1a>
  8009eb:	84 d2                	test   %dl,%dl
  8009ed:	75 f2                	jne    8009e1 <strfind+0xc>
			break;
	return (char *) s;
}
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	57                   	push   %edi
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009fd:	85 c9                	test   %ecx,%ecx
  8009ff:	74 13                	je     800a14 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a01:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a07:	75 05                	jne    800a0e <memset+0x1d>
  800a09:	f6 c1 03             	test   $0x3,%cl
  800a0c:	74 0d                	je     800a1b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a11:	fc                   	cld    
  800a12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a14:	89 f8                	mov    %edi,%eax
  800a16:	5b                   	pop    %ebx
  800a17:	5e                   	pop    %esi
  800a18:	5f                   	pop    %edi
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    
		c &= 0xFF;
  800a1b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1f:	89 d3                	mov    %edx,%ebx
  800a21:	c1 e3 08             	shl    $0x8,%ebx
  800a24:	89 d0                	mov    %edx,%eax
  800a26:	c1 e0 18             	shl    $0x18,%eax
  800a29:	89 d6                	mov    %edx,%esi
  800a2b:	c1 e6 10             	shl    $0x10,%esi
  800a2e:	09 f0                	or     %esi,%eax
  800a30:	09 c2                	or     %eax,%edx
  800a32:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a34:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a37:	89 d0                	mov    %edx,%eax
  800a39:	fc                   	cld    
  800a3a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a3c:	eb d6                	jmp    800a14 <memset+0x23>

00800a3e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	57                   	push   %edi
  800a42:	56                   	push   %esi
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a49:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a4c:	39 c6                	cmp    %eax,%esi
  800a4e:	73 35                	jae    800a85 <memmove+0x47>
  800a50:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a53:	39 c2                	cmp    %eax,%edx
  800a55:	76 2e                	jbe    800a85 <memmove+0x47>
		s += n;
		d += n;
  800a57:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5a:	89 d6                	mov    %edx,%esi
  800a5c:	09 fe                	or     %edi,%esi
  800a5e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a64:	74 0c                	je     800a72 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a66:	83 ef 01             	sub    $0x1,%edi
  800a69:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a6c:	fd                   	std    
  800a6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6f:	fc                   	cld    
  800a70:	eb 21                	jmp    800a93 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a72:	f6 c1 03             	test   $0x3,%cl
  800a75:	75 ef                	jne    800a66 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a77:	83 ef 04             	sub    $0x4,%edi
  800a7a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a7d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a80:	fd                   	std    
  800a81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a83:	eb ea                	jmp    800a6f <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a85:	89 f2                	mov    %esi,%edx
  800a87:	09 c2                	or     %eax,%edx
  800a89:	f6 c2 03             	test   $0x3,%dl
  800a8c:	74 09                	je     800a97 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a8e:	89 c7                	mov    %eax,%edi
  800a90:	fc                   	cld    
  800a91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a93:	5e                   	pop    %esi
  800a94:	5f                   	pop    %edi
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a97:	f6 c1 03             	test   $0x3,%cl
  800a9a:	75 f2                	jne    800a8e <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a9c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a9f:	89 c7                	mov    %eax,%edi
  800aa1:	fc                   	cld    
  800aa2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa4:	eb ed                	jmp    800a93 <memmove+0x55>

00800aa6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aa9:	ff 75 10             	pushl  0x10(%ebp)
  800aac:	ff 75 0c             	pushl  0xc(%ebp)
  800aaf:	ff 75 08             	pushl  0x8(%ebp)
  800ab2:	e8 87 ff ff ff       	call   800a3e <memmove>
}
  800ab7:	c9                   	leave  
  800ab8:	c3                   	ret    

00800ab9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	56                   	push   %esi
  800abd:	53                   	push   %ebx
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac4:	89 c6                	mov    %eax,%esi
  800ac6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac9:	39 f0                	cmp    %esi,%eax
  800acb:	74 1c                	je     800ae9 <memcmp+0x30>
		if (*s1 != *s2)
  800acd:	0f b6 08             	movzbl (%eax),%ecx
  800ad0:	0f b6 1a             	movzbl (%edx),%ebx
  800ad3:	38 d9                	cmp    %bl,%cl
  800ad5:	75 08                	jne    800adf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ad7:	83 c0 01             	add    $0x1,%eax
  800ada:	83 c2 01             	add    $0x1,%edx
  800add:	eb ea                	jmp    800ac9 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800adf:	0f b6 c1             	movzbl %cl,%eax
  800ae2:	0f b6 db             	movzbl %bl,%ebx
  800ae5:	29 d8                	sub    %ebx,%eax
  800ae7:	eb 05                	jmp    800aee <memcmp+0x35>
	}

	return 0;
  800ae9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	8b 45 08             	mov    0x8(%ebp),%eax
  800af8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800afb:	89 c2                	mov    %eax,%edx
  800afd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b00:	39 d0                	cmp    %edx,%eax
  800b02:	73 09                	jae    800b0d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b04:	38 08                	cmp    %cl,(%eax)
  800b06:	74 05                	je     800b0d <memfind+0x1b>
	for (; s < ends; s++)
  800b08:	83 c0 01             	add    $0x1,%eax
  800b0b:	eb f3                	jmp    800b00 <memfind+0xe>
			break;
	return (void *) s;
}
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
  800b15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1b:	eb 03                	jmp    800b20 <strtol+0x11>
		s++;
  800b1d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b20:	0f b6 01             	movzbl (%ecx),%eax
  800b23:	3c 20                	cmp    $0x20,%al
  800b25:	74 f6                	je     800b1d <strtol+0xe>
  800b27:	3c 09                	cmp    $0x9,%al
  800b29:	74 f2                	je     800b1d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b2b:	3c 2b                	cmp    $0x2b,%al
  800b2d:	74 2e                	je     800b5d <strtol+0x4e>
	int neg = 0;
  800b2f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b34:	3c 2d                	cmp    $0x2d,%al
  800b36:	74 2f                	je     800b67 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3e:	75 05                	jne    800b45 <strtol+0x36>
  800b40:	80 39 30             	cmpb   $0x30,(%ecx)
  800b43:	74 2c                	je     800b71 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b45:	85 db                	test   %ebx,%ebx
  800b47:	75 0a                	jne    800b53 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b49:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b4e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b51:	74 28                	je     800b7b <strtol+0x6c>
		base = 10;
  800b53:	b8 00 00 00 00       	mov    $0x0,%eax
  800b58:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b5b:	eb 50                	jmp    800bad <strtol+0x9e>
		s++;
  800b5d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b60:	bf 00 00 00 00       	mov    $0x0,%edi
  800b65:	eb d1                	jmp    800b38 <strtol+0x29>
		s++, neg = 1;
  800b67:	83 c1 01             	add    $0x1,%ecx
  800b6a:	bf 01 00 00 00       	mov    $0x1,%edi
  800b6f:	eb c7                	jmp    800b38 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b71:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b75:	74 0e                	je     800b85 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b77:	85 db                	test   %ebx,%ebx
  800b79:	75 d8                	jne    800b53 <strtol+0x44>
		s++, base = 8;
  800b7b:	83 c1 01             	add    $0x1,%ecx
  800b7e:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b83:	eb ce                	jmp    800b53 <strtol+0x44>
		s += 2, base = 16;
  800b85:	83 c1 02             	add    $0x2,%ecx
  800b88:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b8d:	eb c4                	jmp    800b53 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b8f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b92:	89 f3                	mov    %esi,%ebx
  800b94:	80 fb 19             	cmp    $0x19,%bl
  800b97:	77 29                	ja     800bc2 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b99:	0f be d2             	movsbl %dl,%edx
  800b9c:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b9f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ba2:	7d 30                	jge    800bd4 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ba4:	83 c1 01             	add    $0x1,%ecx
  800ba7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bab:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bad:	0f b6 11             	movzbl (%ecx),%edx
  800bb0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bb3:	89 f3                	mov    %esi,%ebx
  800bb5:	80 fb 09             	cmp    $0x9,%bl
  800bb8:	77 d5                	ja     800b8f <strtol+0x80>
			dig = *s - '0';
  800bba:	0f be d2             	movsbl %dl,%edx
  800bbd:	83 ea 30             	sub    $0x30,%edx
  800bc0:	eb dd                	jmp    800b9f <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bc2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc5:	89 f3                	mov    %esi,%ebx
  800bc7:	80 fb 19             	cmp    $0x19,%bl
  800bca:	77 08                	ja     800bd4 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bcc:	0f be d2             	movsbl %dl,%edx
  800bcf:	83 ea 37             	sub    $0x37,%edx
  800bd2:	eb cb                	jmp    800b9f <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bd4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd8:	74 05                	je     800bdf <strtol+0xd0>
		*endptr = (char *) s;
  800bda:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bdd:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bdf:	89 c2                	mov    %eax,%edx
  800be1:	f7 da                	neg    %edx
  800be3:	85 ff                	test   %edi,%edi
  800be5:	0f 45 c2             	cmovne %edx,%eax
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    
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
