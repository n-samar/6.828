
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 30 00 00 00       	call   800061 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 1e 00 00 00       	call   80005d <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	sys_cputs(hello, 1024*1024);
  800045:	68 00 00 10 00       	push   $0x100000
  80004a:	ff b3 0c 00 00 00    	pushl  0xc(%ebx)
  800050:	e8 8b 00 00 00       	call   8000e0 <sys_cputs>
}
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    

0080005d <__x86.get_pc_thunk.bx>:
  80005d:	8b 1c 24             	mov    (%esp),%ebx
  800060:	c3                   	ret    

00800061 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	57                   	push   %edi
  800065:	56                   	push   %esi
  800066:	53                   	push   %ebx
  800067:	83 ec 0c             	sub    $0xc,%esp
  80006a:	e8 ee ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80006f:	81 c3 91 1f 00 00    	add    $0x1f91,%ebx
  800075:	8b 75 08             	mov    0x8(%ebp),%esi
  800078:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

	thisenv = envs+ENVX(sys_getenvid());
  80007b:	e8 f2 00 00 00       	call   800172 <sys_getenvid>
  800080:	25 ff 03 00 00       	and    $0x3ff,%eax
  800085:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800088:	c1 e0 05             	shl    $0x5,%eax
  80008b:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800091:	c7 c2 30 20 80 00    	mov    $0x802030,%edx
  800097:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800099:	85 f6                	test   %esi,%esi
  80009b:	7e 08                	jle    8000a5 <libmain+0x44>
		binaryname = argv[0];
  80009d:	8b 07                	mov    (%edi),%eax
  80009f:	89 83 10 00 00 00    	mov    %eax,0x10(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	57                   	push   %edi
  8000a9:	56                   	push   %esi
  8000aa:	e8 84 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000af:	e8 0b 00 00 00       	call   8000bf <exit>
}
  8000b4:	83 c4 10             	add    $0x10,%esp
  8000b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ba:	5b                   	pop    %ebx
  8000bb:	5e                   	pop    %esi
  8000bc:	5f                   	pop    %edi
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	53                   	push   %ebx
  8000c3:	83 ec 10             	sub    $0x10,%esp
  8000c6:	e8 92 ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8000cb:	81 c3 35 1f 00 00    	add    $0x1f35,%ebx
	sys_env_destroy(0);
  8000d1:	6a 00                	push   $0x0
  8000d3:	e8 45 00 00 00       	call   80011d <sys_env_destroy>
}
  8000d8:	83 c4 10             	add    $0x10,%esp
  8000db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f1:	89 c3                	mov    %eax,%ebx
  8000f3:	89 c7                	mov    %eax,%edi
  8000f5:	89 c6                	mov    %eax,%esi
  8000f7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <sys_cgetc>:

int
sys_cgetc(void)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	57                   	push   %edi
  800102:	56                   	push   %esi
  800103:	53                   	push   %ebx
	asm volatile("int %1\n"
  800104:	ba 00 00 00 00       	mov    $0x0,%edx
  800109:	b8 01 00 00 00       	mov    $0x1,%eax
  80010e:	89 d1                	mov    %edx,%ecx
  800110:	89 d3                	mov    %edx,%ebx
  800112:	89 d7                	mov    %edx,%edi
  800114:	89 d6                	mov    %edx,%esi
  800116:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5f                   	pop    %edi
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    

0080011d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	57                   	push   %edi
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
  800123:	83 ec 1c             	sub    $0x1c,%esp
  800126:	e8 66 00 00 00       	call   800191 <__x86.get_pc_thunk.ax>
  80012b:	05 d5 1e 00 00       	add    $0x1ed5,%eax
  800130:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800133:	b9 00 00 00 00       	mov    $0x0,%ecx
  800138:	8b 55 08             	mov    0x8(%ebp),%edx
  80013b:	b8 03 00 00 00       	mov    $0x3,%eax
  800140:	89 cb                	mov    %ecx,%ebx
  800142:	89 cf                	mov    %ecx,%edi
  800144:	89 ce                	mov    %ecx,%esi
  800146:	cd 30                	int    $0x30
	if(check && ret > 0)
  800148:	85 c0                	test   %eax,%eax
  80014a:	7f 08                	jg     800154 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5f                   	pop    %edi
  800152:	5d                   	pop    %ebp
  800153:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800154:	83 ec 0c             	sub    $0xc,%esp
  800157:	50                   	push   %eax
  800158:	6a 03                	push   $0x3
  80015a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80015d:	8d 83 64 ee ff ff    	lea    -0x119c(%ebx),%eax
  800163:	50                   	push   %eax
  800164:	6a 23                	push   $0x23
  800166:	8d 83 81 ee ff ff    	lea    -0x117f(%ebx),%eax
  80016c:	50                   	push   %eax
  80016d:	e8 23 00 00 00       	call   800195 <_panic>

00800172 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
	asm volatile("int %1\n"
  800178:	ba 00 00 00 00       	mov    $0x0,%edx
  80017d:	b8 02 00 00 00       	mov    $0x2,%eax
  800182:	89 d1                	mov    %edx,%ecx
  800184:	89 d3                	mov    %edx,%ebx
  800186:	89 d7                	mov    %edx,%edi
  800188:	89 d6                	mov    %edx,%esi
  80018a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5f                   	pop    %edi
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <__x86.get_pc_thunk.ax>:
  800191:	8b 04 24             	mov    (%esp),%eax
  800194:	c3                   	ret    

00800195 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	57                   	push   %edi
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	e8 ba fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8001a3:	81 c3 5d 1e 00 00    	add    $0x1e5d,%ebx
	va_list ap;

	va_start(ap, fmt);
  8001a9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ac:	c7 c0 10 20 80 00    	mov    $0x802010,%eax
  8001b2:	8b 38                	mov    (%eax),%edi
  8001b4:	e8 b9 ff ff ff       	call   800172 <sys_getenvid>
  8001b9:	83 ec 0c             	sub    $0xc,%esp
  8001bc:	ff 75 0c             	pushl  0xc(%ebp)
  8001bf:	ff 75 08             	pushl  0x8(%ebp)
  8001c2:	57                   	push   %edi
  8001c3:	50                   	push   %eax
  8001c4:	8d 83 90 ee ff ff    	lea    -0x1170(%ebx),%eax
  8001ca:	50                   	push   %eax
  8001cb:	e8 d1 00 00 00       	call   8002a1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d0:	83 c4 18             	add    $0x18,%esp
  8001d3:	56                   	push   %esi
  8001d4:	ff 75 10             	pushl  0x10(%ebp)
  8001d7:	e8 63 00 00 00       	call   80023f <vcprintf>
	cprintf("\n");
  8001dc:	8d 83 58 ee ff ff    	lea    -0x11a8(%ebx),%eax
  8001e2:	89 04 24             	mov    %eax,(%esp)
  8001e5:	e8 b7 00 00 00       	call   8002a1 <cprintf>
  8001ea:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ed:	cc                   	int3   
  8001ee:	eb fd                	jmp    8001ed <_panic+0x58>

008001f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	e8 63 fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8001fa:	81 c3 06 1e 00 00    	add    $0x1e06,%ebx
  800200:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800203:	8b 16                	mov    (%esi),%edx
  800205:	8d 42 01             	lea    0x1(%edx),%eax
  800208:	89 06                	mov    %eax,(%esi)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800211:	3d ff 00 00 00       	cmp    $0xff,%eax
  800216:	74 0b                	je     800223 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800218:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80021c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021f:	5b                   	pop    %ebx
  800220:	5e                   	pop    %esi
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	68 ff 00 00 00       	push   $0xff
  80022b:	8d 46 08             	lea    0x8(%esi),%eax
  80022e:	50                   	push   %eax
  80022f:	e8 ac fe ff ff       	call   8000e0 <sys_cputs>
		b->idx = 0;
  800234:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80023a:	83 c4 10             	add    $0x10,%esp
  80023d:	eb d9                	jmp    800218 <putch+0x28>

0080023f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	53                   	push   %ebx
  800243:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800249:	e8 0f fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80024e:	81 c3 b2 1d 00 00    	add    $0x1db2,%ebx
	struct printbuf b;

	b.idx = 0;
  800254:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80025b:	00 00 00 
	b.cnt = 0;
  80025e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800265:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800268:	ff 75 0c             	pushl  0xc(%ebp)
  80026b:	ff 75 08             	pushl  0x8(%ebp)
  80026e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800274:	50                   	push   %eax
  800275:	8d 83 f0 e1 ff ff    	lea    -0x1e10(%ebx),%eax
  80027b:	50                   	push   %eax
  80027c:	e8 38 01 00 00       	call   8003b9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800281:	83 c4 08             	add    $0x8,%esp
  800284:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80028a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800290:	50                   	push   %eax
  800291:	e8 4a fe ff ff       	call   8000e0 <sys_cputs>

	return b.cnt;
}
  800296:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80029c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    

008002a1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002aa:	50                   	push   %eax
  8002ab:	ff 75 08             	pushl  0x8(%ebp)
  8002ae:	e8 8c ff ff ff       	call   80023f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002b3:	c9                   	leave  
  8002b4:	c3                   	ret    

008002b5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 2c             	sub    $0x2c,%esp
  8002be:	e8 cd 05 00 00       	call   800890 <__x86.get_pc_thunk.cx>
  8002c3:	81 c1 3d 1d 00 00    	add    $0x1d3d,%ecx
  8002c9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002cc:	89 c7                	mov    %eax,%edi
  8002ce:	89 d6                	mov    %edx,%esi
  8002d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002d9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002e7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002ea:	39 d3                	cmp    %edx,%ebx
  8002ec:	72 09                	jb     8002f7 <printnum+0x42>
  8002ee:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f1:	0f 87 83 00 00 00    	ja     80037a <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f7:	83 ec 0c             	sub    $0xc,%esp
  8002fa:	ff 75 18             	pushl  0x18(%ebp)
  8002fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800300:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800303:	53                   	push   %ebx
  800304:	ff 75 10             	pushl  0x10(%ebp)
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	ff 75 dc             	pushl  -0x24(%ebp)
  80030d:	ff 75 d8             	pushl  -0x28(%ebp)
  800310:	ff 75 d4             	pushl  -0x2c(%ebp)
  800313:	ff 75 d0             	pushl  -0x30(%ebp)
  800316:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800319:	e8 f2 08 00 00       	call   800c10 <__udivdi3>
  80031e:	83 c4 18             	add    $0x18,%esp
  800321:	52                   	push   %edx
  800322:	50                   	push   %eax
  800323:	89 f2                	mov    %esi,%edx
  800325:	89 f8                	mov    %edi,%eax
  800327:	e8 89 ff ff ff       	call   8002b5 <printnum>
  80032c:	83 c4 20             	add    $0x20,%esp
  80032f:	eb 13                	jmp    800344 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	56                   	push   %esi
  800335:	ff 75 18             	pushl  0x18(%ebp)
  800338:	ff d7                	call   *%edi
  80033a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f ed                	jg     800331 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	56                   	push   %esi
  800348:	83 ec 04             	sub    $0x4,%esp
  80034b:	ff 75 dc             	pushl  -0x24(%ebp)
  80034e:	ff 75 d8             	pushl  -0x28(%ebp)
  800351:	ff 75 d4             	pushl  -0x2c(%ebp)
  800354:	ff 75 d0             	pushl  -0x30(%ebp)
  800357:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80035a:	89 f3                	mov    %esi,%ebx
  80035c:	e8 cf 09 00 00       	call   800d30 <__umoddi3>
  800361:	83 c4 14             	add    $0x14,%esp
  800364:	0f be 84 06 b4 ee ff 	movsbl -0x114c(%esi,%eax,1),%eax
  80036b:	ff 
  80036c:	50                   	push   %eax
  80036d:	ff d7                	call   *%edi
}
  80036f:	83 c4 10             	add    $0x10,%esp
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80037d:	eb be                	jmp    80033d <printnum+0x88>

0080037f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800385:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	3b 50 04             	cmp    0x4(%eax),%edx
  80038e:	73 0a                	jae    80039a <sprintputch+0x1b>
		*b->buf++ = ch;
  800390:	8d 4a 01             	lea    0x1(%edx),%ecx
  800393:	89 08                	mov    %ecx,(%eax)
  800395:	8b 45 08             	mov    0x8(%ebp),%eax
  800398:	88 02                	mov    %al,(%edx)
}
  80039a:	5d                   	pop    %ebp
  80039b:	c3                   	ret    

0080039c <printfmt>:
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a5:	50                   	push   %eax
  8003a6:	ff 75 10             	pushl  0x10(%ebp)
  8003a9:	ff 75 0c             	pushl  0xc(%ebp)
  8003ac:	ff 75 08             	pushl  0x8(%ebp)
  8003af:	e8 05 00 00 00       	call   8003b9 <vprintfmt>
}
  8003b4:	83 c4 10             	add    $0x10,%esp
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    

008003b9 <vprintfmt>:
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	56                   	push   %esi
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 2c             	sub    $0x2c,%esp
  8003c2:	e8 96 fc ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8003c7:	81 c3 39 1c 00 00    	add    $0x1c39,%ebx
  8003cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003d0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d3:	e9 8e 03 00 00       	jmp    800766 <.L35+0x48>
		padc = ' ';
  8003d8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003dc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003ea:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8d 47 01             	lea    0x1(%edi),%eax
  8003fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ff:	0f b6 17             	movzbl (%edi),%edx
  800402:	8d 42 dd             	lea    -0x23(%edx),%eax
  800405:	3c 55                	cmp    $0x55,%al
  800407:	0f 87 e1 03 00 00    	ja     8007ee <.L22>
  80040d:	0f b6 c0             	movzbl %al,%eax
  800410:	89 d9                	mov    %ebx,%ecx
  800412:	03 8c 83 44 ef ff ff 	add    -0x10bc(%ebx,%eax,4),%ecx
  800419:	ff e1                	jmp    *%ecx

0080041b <.L67>:
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80041e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800422:	eb d5                	jmp    8003f9 <vprintfmt+0x40>

00800424 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800427:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80042b:	eb cc                	jmp    8003f9 <vprintfmt+0x40>

0080042d <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	0f b6 d2             	movzbl %dl,%edx
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800433:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800438:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80043f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800442:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800445:	83 f9 09             	cmp    $0x9,%ecx
  800448:	77 55                	ja     80049f <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  80044a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80044d:	eb e9                	jmp    800438 <.L29+0xb>

0080044f <.L26>:
			precision = va_arg(ap, int);
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	8b 00                	mov    (%eax),%eax
  800454:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800457:	8b 45 14             	mov    0x14(%ebp),%eax
  80045a:	8d 40 04             	lea    0x4(%eax),%eax
  80045d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800463:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800467:	79 90                	jns    8003f9 <vprintfmt+0x40>
				width = precision, precision = -1;
  800469:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80046c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800476:	eb 81                	jmp    8003f9 <vprintfmt+0x40>

00800478 <.L27>:
  800478:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047b:	85 c0                	test   %eax,%eax
  80047d:	ba 00 00 00 00       	mov    $0x0,%edx
  800482:	0f 49 d0             	cmovns %eax,%edx
  800485:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800488:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048b:	e9 69 ff ff ff       	jmp    8003f9 <vprintfmt+0x40>

00800490 <.L23>:
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800493:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049a:	e9 5a ff ff ff       	jmp    8003f9 <vprintfmt+0x40>
  80049f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004a2:	eb bf                	jmp    800463 <.L26+0x14>

008004a4 <.L33>:
			lflag++;
  8004a4:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004ab:	e9 49 ff ff ff       	jmp    8003f9 <vprintfmt+0x40>

008004b0 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8d 78 04             	lea    0x4(%eax),%edi
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	56                   	push   %esi
  8004ba:	ff 30                	pushl  (%eax)
  8004bc:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004bf:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004c2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004c5:	e9 99 02 00 00       	jmp    800763 <.L35+0x45>

008004ca <.L32>:
			err = va_arg(ap, int);
  8004ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cd:	8d 78 04             	lea    0x4(%eax),%edi
  8004d0:	8b 00                	mov    (%eax),%eax
  8004d2:	99                   	cltd   
  8004d3:	31 d0                	xor    %edx,%eax
  8004d5:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d7:	83 f8 06             	cmp    $0x6,%eax
  8004da:	7f 27                	jg     800503 <.L32+0x39>
  8004dc:	8b 94 83 14 00 00 00 	mov    0x14(%ebx,%eax,4),%edx
  8004e3:	85 d2                	test   %edx,%edx
  8004e5:	74 1c                	je     800503 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004e7:	52                   	push   %edx
  8004e8:	8d 83 d5 ee ff ff    	lea    -0x112b(%ebx),%eax
  8004ee:	50                   	push   %eax
  8004ef:	56                   	push   %esi
  8004f0:	ff 75 08             	pushl  0x8(%ebp)
  8004f3:	e8 a4 fe ff ff       	call   80039c <printfmt>
  8004f8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004fb:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004fe:	e9 60 02 00 00       	jmp    800763 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  800503:	50                   	push   %eax
  800504:	8d 83 cc ee ff ff    	lea    -0x1134(%ebx),%eax
  80050a:	50                   	push   %eax
  80050b:	56                   	push   %esi
  80050c:	ff 75 08             	pushl  0x8(%ebp)
  80050f:	e8 88 fe ff ff       	call   80039c <printfmt>
  800514:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800517:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80051a:	e9 44 02 00 00       	jmp    800763 <.L35+0x45>

0080051f <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	83 c0 04             	add    $0x4,%eax
  800525:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80052d:	85 ff                	test   %edi,%edi
  80052f:	8d 83 c5 ee ff ff    	lea    -0x113b(%ebx),%eax
  800535:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800538:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80053c:	0f 8e b5 00 00 00    	jle    8005f7 <.L36+0xd8>
  800542:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800546:	75 08                	jne    800550 <.L36+0x31>
  800548:	89 75 0c             	mov    %esi,0xc(%ebp)
  80054b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054e:	eb 6d                	jmp    8005bd <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	ff 75 d0             	pushl  -0x30(%ebp)
  800556:	57                   	push   %edi
  800557:	e8 50 03 00 00       	call   8008ac <strnlen>
  80055c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80055f:	29 c2                	sub    %eax,%edx
  800561:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800564:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800567:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80056b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800571:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800573:	eb 10                	jmp    800585 <.L36+0x66>
					putch(padc, putdat);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	56                   	push   %esi
  800579:	ff 75 e0             	pushl  -0x20(%ebp)
  80057c:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80057f:	83 ef 01             	sub    $0x1,%edi
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	85 ff                	test   %edi,%edi
  800587:	7f ec                	jg     800575 <.L36+0x56>
  800589:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80058c:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80058f:	85 d2                	test   %edx,%edx
  800591:	b8 00 00 00 00       	mov    $0x0,%eax
  800596:	0f 49 c2             	cmovns %edx,%eax
  800599:	29 c2                	sub    %eax,%edx
  80059b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80059e:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005a1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a4:	eb 17                	jmp    8005bd <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005a6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005aa:	75 30                	jne    8005dc <.L36+0xbd>
					putch(ch, putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	ff 75 0c             	pushl  0xc(%ebp)
  8005b2:	50                   	push   %eax
  8005b3:	ff 55 08             	call   *0x8(%ebp)
  8005b6:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b9:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005bd:	83 c7 01             	add    $0x1,%edi
  8005c0:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005c4:	0f be c2             	movsbl %dl,%eax
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	74 52                	je     80061d <.L36+0xfe>
  8005cb:	85 f6                	test   %esi,%esi
  8005cd:	78 d7                	js     8005a6 <.L36+0x87>
  8005cf:	83 ee 01             	sub    $0x1,%esi
  8005d2:	79 d2                	jns    8005a6 <.L36+0x87>
  8005d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005d7:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005da:	eb 32                	jmp    80060e <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005dc:	0f be d2             	movsbl %dl,%edx
  8005df:	83 ea 20             	sub    $0x20,%edx
  8005e2:	83 fa 5e             	cmp    $0x5e,%edx
  8005e5:	76 c5                	jbe    8005ac <.L36+0x8d>
					putch('?', putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	ff 75 0c             	pushl  0xc(%ebp)
  8005ed:	6a 3f                	push   $0x3f
  8005ef:	ff 55 08             	call   *0x8(%ebp)
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	eb c2                	jmp    8005b9 <.L36+0x9a>
  8005f7:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005fa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005fd:	eb be                	jmp    8005bd <.L36+0x9e>
				putch(' ', putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	56                   	push   %esi
  800603:	6a 20                	push   $0x20
  800605:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800608:	83 ef 01             	sub    $0x1,%edi
  80060b:	83 c4 10             	add    $0x10,%esp
  80060e:	85 ff                	test   %edi,%edi
  800610:	7f ed                	jg     8005ff <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800612:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800615:	89 45 14             	mov    %eax,0x14(%ebp)
  800618:	e9 46 01 00 00       	jmp    800763 <.L35+0x45>
  80061d:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800620:	8b 75 0c             	mov    0xc(%ebp),%esi
  800623:	eb e9                	jmp    80060e <.L36+0xef>

00800625 <.L31>:
  800625:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  800628:	83 f9 01             	cmp    $0x1,%ecx
  80062b:	7e 40                	jle    80066d <.L31+0x48>
		return va_arg(*ap, long long);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8b 50 04             	mov    0x4(%eax),%edx
  800633:	8b 00                	mov    (%eax),%eax
  800635:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800638:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8d 40 08             	lea    0x8(%eax),%eax
  800641:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800644:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800648:	79 55                	jns    80069f <.L31+0x7a>
				putch('-', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	56                   	push   %esi
  80064e:	6a 2d                	push   $0x2d
  800650:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800653:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800656:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800659:	f7 da                	neg    %edx
  80065b:	83 d1 00             	adc    $0x0,%ecx
  80065e:	f7 d9                	neg    %ecx
  800660:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800663:	b8 0a 00 00 00       	mov    $0xa,%eax
  800668:	e9 db 00 00 00       	jmp    800748 <.L35+0x2a>
	else if (lflag)
  80066d:	85 c9                	test   %ecx,%ecx
  80066f:	75 17                	jne    800688 <.L31+0x63>
		return va_arg(*ap, int);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8b 00                	mov    (%eax),%eax
  800676:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800679:	99                   	cltd   
  80067a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8d 40 04             	lea    0x4(%eax),%eax
  800683:	89 45 14             	mov    %eax,0x14(%ebp)
  800686:	eb bc                	jmp    800644 <.L31+0x1f>
		return va_arg(*ap, long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 00                	mov    (%eax),%eax
  80068d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800690:	99                   	cltd   
  800691:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 40 04             	lea    0x4(%eax),%eax
  80069a:	89 45 14             	mov    %eax,0x14(%ebp)
  80069d:	eb a5                	jmp    800644 <.L31+0x1f>
			num = getint(&ap, lflag);
  80069f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006a2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006aa:	e9 99 00 00 00       	jmp    800748 <.L35+0x2a>

008006af <.L37>:
  8006af:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  8006b2:	83 f9 01             	cmp    $0x1,%ecx
  8006b5:	7e 15                	jle    8006cc <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8b 10                	mov    (%eax),%edx
  8006bc:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bf:	8d 40 08             	lea    0x8(%eax),%eax
  8006c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ca:	eb 7c                	jmp    800748 <.L35+0x2a>
	else if (lflag)
  8006cc:	85 c9                	test   %ecx,%ecx
  8006ce:	75 17                	jne    8006e7 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8b 10                	mov    (%eax),%edx
  8006d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006da:	8d 40 04             	lea    0x4(%eax),%eax
  8006dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e5:	eb 61                	jmp    800748 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f1:	8d 40 04             	lea    0x4(%eax),%eax
  8006f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fc:	eb 4a                	jmp    800748 <.L35+0x2a>

008006fe <.L34>:
			putch('X', putdat);
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	56                   	push   %esi
  800702:	6a 58                	push   $0x58
  800704:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800707:	83 c4 08             	add    $0x8,%esp
  80070a:	56                   	push   %esi
  80070b:	6a 58                	push   $0x58
  80070d:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	56                   	push   %esi
  800714:	6a 58                	push   $0x58
  800716:	ff 55 08             	call   *0x8(%ebp)
			break;
  800719:	83 c4 10             	add    $0x10,%esp
  80071c:	eb 45                	jmp    800763 <.L35+0x45>

0080071e <.L35>:
			putch('0', putdat);
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	56                   	push   %esi
  800722:	6a 30                	push   $0x30
  800724:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800727:	83 c4 08             	add    $0x8,%esp
  80072a:	56                   	push   %esi
  80072b:	6a 78                	push   $0x78
  80072d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8b 10                	mov    (%eax),%edx
  800735:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80073a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80073d:	8d 40 04             	lea    0x4(%eax),%eax
  800740:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800743:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800748:	83 ec 0c             	sub    $0xc,%esp
  80074b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80074f:	57                   	push   %edi
  800750:	ff 75 e0             	pushl  -0x20(%ebp)
  800753:	50                   	push   %eax
  800754:	51                   	push   %ecx
  800755:	52                   	push   %edx
  800756:	89 f2                	mov    %esi,%edx
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	e8 55 fb ff ff       	call   8002b5 <printnum>
			break;
  800760:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800763:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800766:	83 c7 01             	add    $0x1,%edi
  800769:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80076d:	83 f8 25             	cmp    $0x25,%eax
  800770:	0f 84 62 fc ff ff    	je     8003d8 <vprintfmt+0x1f>
			if (ch == '\0')
  800776:	85 c0                	test   %eax,%eax
  800778:	0f 84 91 00 00 00    	je     80080f <.L22+0x21>
			putch(ch, putdat);
  80077e:	83 ec 08             	sub    $0x8,%esp
  800781:	56                   	push   %esi
  800782:	50                   	push   %eax
  800783:	ff 55 08             	call   *0x8(%ebp)
  800786:	83 c4 10             	add    $0x10,%esp
  800789:	eb db                	jmp    800766 <.L35+0x48>

0080078b <.L38>:
  80078b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  80078e:	83 f9 01             	cmp    $0x1,%ecx
  800791:	7e 15                	jle    8007a8 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8b 10                	mov    (%eax),%edx
  800798:	8b 48 04             	mov    0x4(%eax),%ecx
  80079b:	8d 40 08             	lea    0x8(%eax),%eax
  80079e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a1:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a6:	eb a0                	jmp    800748 <.L35+0x2a>
	else if (lflag)
  8007a8:	85 c9                	test   %ecx,%ecx
  8007aa:	75 17                	jne    8007c3 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8007af:	8b 10                	mov    (%eax),%edx
  8007b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b6:	8d 40 04             	lea    0x4(%eax),%eax
  8007b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007bc:	b8 10 00 00 00       	mov    $0x10,%eax
  8007c1:	eb 85                	jmp    800748 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8b 10                	mov    (%eax),%edx
  8007c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007cd:	8d 40 04             	lea    0x4(%eax),%eax
  8007d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d3:	b8 10 00 00 00       	mov    $0x10,%eax
  8007d8:	e9 6b ff ff ff       	jmp    800748 <.L35+0x2a>

008007dd <.L25>:
			putch(ch, putdat);
  8007dd:	83 ec 08             	sub    $0x8,%esp
  8007e0:	56                   	push   %esi
  8007e1:	6a 25                	push   $0x25
  8007e3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007e6:	83 c4 10             	add    $0x10,%esp
  8007e9:	e9 75 ff ff ff       	jmp    800763 <.L35+0x45>

008007ee <.L22>:
			putch('%', putdat);
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	56                   	push   %esi
  8007f2:	6a 25                	push   $0x25
  8007f4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f7:	83 c4 10             	add    $0x10,%esp
  8007fa:	89 f8                	mov    %edi,%eax
  8007fc:	eb 03                	jmp    800801 <.L22+0x13>
  8007fe:	83 e8 01             	sub    $0x1,%eax
  800801:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800805:	75 f7                	jne    8007fe <.L22+0x10>
  800807:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80080a:	e9 54 ff ff ff       	jmp    800763 <.L35+0x45>
}
  80080f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800812:	5b                   	pop    %ebx
  800813:	5e                   	pop    %esi
  800814:	5f                   	pop    %edi
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	83 ec 14             	sub    $0x14,%esp
  80081e:	e8 3a f8 ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  800823:	81 c3 dd 17 00 00    	add    $0x17dd,%ebx
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800832:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800836:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800839:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800840:	85 c0                	test   %eax,%eax
  800842:	74 2b                	je     80086f <vsnprintf+0x58>
  800844:	85 d2                	test   %edx,%edx
  800846:	7e 27                	jle    80086f <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800848:	ff 75 14             	pushl  0x14(%ebp)
  80084b:	ff 75 10             	pushl  0x10(%ebp)
  80084e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800851:	50                   	push   %eax
  800852:	8d 83 7f e3 ff ff    	lea    -0x1c81(%ebx),%eax
  800858:	50                   	push   %eax
  800859:	e8 5b fb ff ff       	call   8003b9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800861:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800864:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800867:	83 c4 10             	add    $0x10,%esp
}
  80086a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086d:	c9                   	leave  
  80086e:	c3                   	ret    
		return -E_INVAL;
  80086f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800874:	eb f4                	jmp    80086a <vsnprintf+0x53>

00800876 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80087f:	50                   	push   %eax
  800880:	ff 75 10             	pushl  0x10(%ebp)
  800883:	ff 75 0c             	pushl  0xc(%ebp)
  800886:	ff 75 08             	pushl  0x8(%ebp)
  800889:	e8 89 ff ff ff       	call   800817 <vsnprintf>
	va_end(ap);

	return rc;
}
  80088e:	c9                   	leave  
  80088f:	c3                   	ret    

00800890 <__x86.get_pc_thunk.cx>:
  800890:	8b 0c 24             	mov    (%esp),%ecx
  800893:	c3                   	ret    

00800894 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
  80089f:	eb 03                	jmp    8008a4 <strlen+0x10>
		n++;
  8008a1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008a4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a8:	75 f7                	jne    8008a1 <strlen+0xd>
	return n;
}
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ba:	eb 03                	jmp    8008bf <strnlen+0x13>
		n++;
  8008bc:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bf:	39 d0                	cmp    %edx,%eax
  8008c1:	74 06                	je     8008c9 <strnlen+0x1d>
  8008c3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008c7:	75 f3                	jne    8008bc <strnlen+0x10>
	return n;
}
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d5:	89 c2                	mov    %eax,%edx
  8008d7:	83 c1 01             	add    $0x1,%ecx
  8008da:	83 c2 01             	add    $0x1,%edx
  8008dd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008e1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008e4:	84 db                	test   %bl,%bl
  8008e6:	75 ef                	jne    8008d7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008e8:	5b                   	pop    %ebx
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	53                   	push   %ebx
  8008ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f2:	53                   	push   %ebx
  8008f3:	e8 9c ff ff ff       	call   800894 <strlen>
  8008f8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008fb:	ff 75 0c             	pushl  0xc(%ebp)
  8008fe:	01 d8                	add    %ebx,%eax
  800900:	50                   	push   %eax
  800901:	e8 c5 ff ff ff       	call   8008cb <strcpy>
	return dst;
}
  800906:	89 d8                	mov    %ebx,%eax
  800908:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090b:	c9                   	leave  
  80090c:	c3                   	ret    

0080090d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	56                   	push   %esi
  800911:	53                   	push   %ebx
  800912:	8b 75 08             	mov    0x8(%ebp),%esi
  800915:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800918:	89 f3                	mov    %esi,%ebx
  80091a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091d:	89 f2                	mov    %esi,%edx
  80091f:	eb 0f                	jmp    800930 <strncpy+0x23>
		*dst++ = *src;
  800921:	83 c2 01             	add    $0x1,%edx
  800924:	0f b6 01             	movzbl (%ecx),%eax
  800927:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80092a:	80 39 01             	cmpb   $0x1,(%ecx)
  80092d:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800930:	39 da                	cmp    %ebx,%edx
  800932:	75 ed                	jne    800921 <strncpy+0x14>
	}
	return ret;
}
  800934:	89 f0                	mov    %esi,%eax
  800936:	5b                   	pop    %ebx
  800937:	5e                   	pop    %esi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 75 08             	mov    0x8(%ebp),%esi
  800942:	8b 55 0c             	mov    0xc(%ebp),%edx
  800945:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800948:	89 f0                	mov    %esi,%eax
  80094a:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80094e:	85 c9                	test   %ecx,%ecx
  800950:	75 0b                	jne    80095d <strlcpy+0x23>
  800952:	eb 17                	jmp    80096b <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800954:	83 c2 01             	add    $0x1,%edx
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80095d:	39 d8                	cmp    %ebx,%eax
  80095f:	74 07                	je     800968 <strlcpy+0x2e>
  800961:	0f b6 0a             	movzbl (%edx),%ecx
  800964:	84 c9                	test   %cl,%cl
  800966:	75 ec                	jne    800954 <strlcpy+0x1a>
		*dst = '\0';
  800968:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80096b:	29 f0                	sub    %esi,%eax
}
  80096d:	5b                   	pop    %ebx
  80096e:	5e                   	pop    %esi
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800977:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80097a:	eb 06                	jmp    800982 <strcmp+0x11>
		p++, q++;
  80097c:	83 c1 01             	add    $0x1,%ecx
  80097f:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800982:	0f b6 01             	movzbl (%ecx),%eax
  800985:	84 c0                	test   %al,%al
  800987:	74 04                	je     80098d <strcmp+0x1c>
  800989:	3a 02                	cmp    (%edx),%al
  80098b:	74 ef                	je     80097c <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80098d:	0f b6 c0             	movzbl %al,%eax
  800990:	0f b6 12             	movzbl (%edx),%edx
  800993:	29 d0                	sub    %edx,%eax
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	53                   	push   %ebx
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a1:	89 c3                	mov    %eax,%ebx
  8009a3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009a6:	eb 06                	jmp    8009ae <strncmp+0x17>
		n--, p++, q++;
  8009a8:	83 c0 01             	add    $0x1,%eax
  8009ab:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009ae:	39 d8                	cmp    %ebx,%eax
  8009b0:	74 16                	je     8009c8 <strncmp+0x31>
  8009b2:	0f b6 08             	movzbl (%eax),%ecx
  8009b5:	84 c9                	test   %cl,%cl
  8009b7:	74 04                	je     8009bd <strncmp+0x26>
  8009b9:	3a 0a                	cmp    (%edx),%cl
  8009bb:	74 eb                	je     8009a8 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bd:	0f b6 00             	movzbl (%eax),%eax
  8009c0:	0f b6 12             	movzbl (%edx),%edx
  8009c3:	29 d0                	sub    %edx,%eax
}
  8009c5:	5b                   	pop    %ebx
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    
		return 0;
  8009c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cd:	eb f6                	jmp    8009c5 <strncmp+0x2e>

008009cf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d9:	0f b6 10             	movzbl (%eax),%edx
  8009dc:	84 d2                	test   %dl,%dl
  8009de:	74 09                	je     8009e9 <strchr+0x1a>
		if (*s == c)
  8009e0:	38 ca                	cmp    %cl,%dl
  8009e2:	74 0a                	je     8009ee <strchr+0x1f>
	for (; *s; s++)
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	eb f0                	jmp    8009d9 <strchr+0xa>
			return (char *) s;
	return 0;
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009fa:	eb 03                	jmp    8009ff <strfind+0xf>
  8009fc:	83 c0 01             	add    $0x1,%eax
  8009ff:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a02:	38 ca                	cmp    %cl,%dl
  800a04:	74 04                	je     800a0a <strfind+0x1a>
  800a06:	84 d2                	test   %dl,%dl
  800a08:	75 f2                	jne    8009fc <strfind+0xc>
			break;
	return (char *) s;
}
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a15:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a18:	85 c9                	test   %ecx,%ecx
  800a1a:	74 13                	je     800a2f <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a1c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a22:	75 05                	jne    800a29 <memset+0x1d>
  800a24:	f6 c1 03             	test   $0x3,%cl
  800a27:	74 0d                	je     800a36 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2c:	fc                   	cld    
  800a2d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2f:	89 f8                	mov    %edi,%eax
  800a31:	5b                   	pop    %ebx
  800a32:	5e                   	pop    %esi
  800a33:	5f                   	pop    %edi
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    
		c &= 0xFF;
  800a36:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a3a:	89 d3                	mov    %edx,%ebx
  800a3c:	c1 e3 08             	shl    $0x8,%ebx
  800a3f:	89 d0                	mov    %edx,%eax
  800a41:	c1 e0 18             	shl    $0x18,%eax
  800a44:	89 d6                	mov    %edx,%esi
  800a46:	c1 e6 10             	shl    $0x10,%esi
  800a49:	09 f0                	or     %esi,%eax
  800a4b:	09 c2                	or     %eax,%edx
  800a4d:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a4f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a52:	89 d0                	mov    %edx,%eax
  800a54:	fc                   	cld    
  800a55:	f3 ab                	rep stos %eax,%es:(%edi)
  800a57:	eb d6                	jmp    800a2f <memset+0x23>

00800a59 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	57                   	push   %edi
  800a5d:	56                   	push   %esi
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a64:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a67:	39 c6                	cmp    %eax,%esi
  800a69:	73 35                	jae    800aa0 <memmove+0x47>
  800a6b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a6e:	39 c2                	cmp    %eax,%edx
  800a70:	76 2e                	jbe    800aa0 <memmove+0x47>
		s += n;
		d += n;
  800a72:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a75:	89 d6                	mov    %edx,%esi
  800a77:	09 fe                	or     %edi,%esi
  800a79:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a7f:	74 0c                	je     800a8d <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a81:	83 ef 01             	sub    $0x1,%edi
  800a84:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a87:	fd                   	std    
  800a88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8a:	fc                   	cld    
  800a8b:	eb 21                	jmp    800aae <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8d:	f6 c1 03             	test   $0x3,%cl
  800a90:	75 ef                	jne    800a81 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a92:	83 ef 04             	sub    $0x4,%edi
  800a95:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a98:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a9b:	fd                   	std    
  800a9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9e:	eb ea                	jmp    800a8a <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa0:	89 f2                	mov    %esi,%edx
  800aa2:	09 c2                	or     %eax,%edx
  800aa4:	f6 c2 03             	test   $0x3,%dl
  800aa7:	74 09                	je     800ab2 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa9:	89 c7                	mov    %eax,%edi
  800aab:	fc                   	cld    
  800aac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab2:	f6 c1 03             	test   $0x3,%cl
  800ab5:	75 f2                	jne    800aa9 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ab7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aba:	89 c7                	mov    %eax,%edi
  800abc:	fc                   	cld    
  800abd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abf:	eb ed                	jmp    800aae <memmove+0x55>

00800ac1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ac4:	ff 75 10             	pushl  0x10(%ebp)
  800ac7:	ff 75 0c             	pushl  0xc(%ebp)
  800aca:	ff 75 08             	pushl  0x8(%ebp)
  800acd:	e8 87 ff ff ff       	call   800a59 <memmove>
}
  800ad2:	c9                   	leave  
  800ad3:	c3                   	ret    

00800ad4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800adf:	89 c6                	mov    %eax,%esi
  800ae1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae4:	39 f0                	cmp    %esi,%eax
  800ae6:	74 1c                	je     800b04 <memcmp+0x30>
		if (*s1 != *s2)
  800ae8:	0f b6 08             	movzbl (%eax),%ecx
  800aeb:	0f b6 1a             	movzbl (%edx),%ebx
  800aee:	38 d9                	cmp    %bl,%cl
  800af0:	75 08                	jne    800afa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800af2:	83 c0 01             	add    $0x1,%eax
  800af5:	83 c2 01             	add    $0x1,%edx
  800af8:	eb ea                	jmp    800ae4 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800afa:	0f b6 c1             	movzbl %cl,%eax
  800afd:	0f b6 db             	movzbl %bl,%ebx
  800b00:	29 d8                	sub    %ebx,%eax
  800b02:	eb 05                	jmp    800b09 <memcmp+0x35>
	}

	return 0;
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b16:	89 c2                	mov    %eax,%edx
  800b18:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b1b:	39 d0                	cmp    %edx,%eax
  800b1d:	73 09                	jae    800b28 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b1f:	38 08                	cmp    %cl,(%eax)
  800b21:	74 05                	je     800b28 <memfind+0x1b>
	for (; s < ends; s++)
  800b23:	83 c0 01             	add    $0x1,%eax
  800b26:	eb f3                	jmp    800b1b <memfind+0xe>
			break;
	return (void *) s;
}
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
  800b30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b36:	eb 03                	jmp    800b3b <strtol+0x11>
		s++;
  800b38:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b3b:	0f b6 01             	movzbl (%ecx),%eax
  800b3e:	3c 20                	cmp    $0x20,%al
  800b40:	74 f6                	je     800b38 <strtol+0xe>
  800b42:	3c 09                	cmp    $0x9,%al
  800b44:	74 f2                	je     800b38 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b46:	3c 2b                	cmp    $0x2b,%al
  800b48:	74 2e                	je     800b78 <strtol+0x4e>
	int neg = 0;
  800b4a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b4f:	3c 2d                	cmp    $0x2d,%al
  800b51:	74 2f                	je     800b82 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b53:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b59:	75 05                	jne    800b60 <strtol+0x36>
  800b5b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b5e:	74 2c                	je     800b8c <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b60:	85 db                	test   %ebx,%ebx
  800b62:	75 0a                	jne    800b6e <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b64:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b69:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6c:	74 28                	je     800b96 <strtol+0x6c>
		base = 10;
  800b6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b73:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b76:	eb 50                	jmp    800bc8 <strtol+0x9e>
		s++;
  800b78:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b80:	eb d1                	jmp    800b53 <strtol+0x29>
		s++, neg = 1;
  800b82:	83 c1 01             	add    $0x1,%ecx
  800b85:	bf 01 00 00 00       	mov    $0x1,%edi
  800b8a:	eb c7                	jmp    800b53 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b90:	74 0e                	je     800ba0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b92:	85 db                	test   %ebx,%ebx
  800b94:	75 d8                	jne    800b6e <strtol+0x44>
		s++, base = 8;
  800b96:	83 c1 01             	add    $0x1,%ecx
  800b99:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b9e:	eb ce                	jmp    800b6e <strtol+0x44>
		s += 2, base = 16;
  800ba0:	83 c1 02             	add    $0x2,%ecx
  800ba3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ba8:	eb c4                	jmp    800b6e <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800baa:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bad:	89 f3                	mov    %esi,%ebx
  800baf:	80 fb 19             	cmp    $0x19,%bl
  800bb2:	77 29                	ja     800bdd <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bb4:	0f be d2             	movsbl %dl,%edx
  800bb7:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bba:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bbd:	7d 30                	jge    800bef <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bbf:	83 c1 01             	add    $0x1,%ecx
  800bc2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc6:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bc8:	0f b6 11             	movzbl (%ecx),%edx
  800bcb:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bce:	89 f3                	mov    %esi,%ebx
  800bd0:	80 fb 09             	cmp    $0x9,%bl
  800bd3:	77 d5                	ja     800baa <strtol+0x80>
			dig = *s - '0';
  800bd5:	0f be d2             	movsbl %dl,%edx
  800bd8:	83 ea 30             	sub    $0x30,%edx
  800bdb:	eb dd                	jmp    800bba <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bdd:	8d 72 bf             	lea    -0x41(%edx),%esi
  800be0:	89 f3                	mov    %esi,%ebx
  800be2:	80 fb 19             	cmp    $0x19,%bl
  800be5:	77 08                	ja     800bef <strtol+0xc5>
			dig = *s - 'A' + 10;
  800be7:	0f be d2             	movsbl %dl,%edx
  800bea:	83 ea 37             	sub    $0x37,%edx
  800bed:	eb cb                	jmp    800bba <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf3:	74 05                	je     800bfa <strtol+0xd0>
		*endptr = (char *) s;
  800bf5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf8:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bfa:	89 c2                	mov    %eax,%edx
  800bfc:	f7 da                	neg    %edx
  800bfe:	85 ff                	test   %edi,%edi
  800c00:	0f 45 c2             	cmovne %edx,%eax
}
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    
  800c08:	66 90                	xchg   %ax,%ax
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
