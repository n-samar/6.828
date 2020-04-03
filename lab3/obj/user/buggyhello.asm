
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 29 00 00 00       	call   80005a <libmain>
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
  80003a:	e8 17 00 00 00       	call   800056 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	sys_cputs((char*)1, 1);
  800045:	6a 01                	push   $0x1
  800047:	6a 01                	push   $0x1
  800049:	e8 8b 00 00 00       	call   8000d9 <sys_cputs>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800054:	c9                   	leave  
  800055:	c3                   	ret    

00800056 <__x86.get_pc_thunk.bx>:
  800056:	8b 1c 24             	mov    (%esp),%ebx
  800059:	c3                   	ret    

0080005a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005a:	55                   	push   %ebp
  80005b:	89 e5                	mov    %esp,%ebp
  80005d:	57                   	push   %edi
  80005e:	56                   	push   %esi
  80005f:	53                   	push   %ebx
  800060:	83 ec 0c             	sub    $0xc,%esp
  800063:	e8 ee ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800068:	81 c3 98 1f 00 00    	add    $0x1f98,%ebx
  80006e:	8b 75 08             	mov    0x8(%ebp),%esi
  800071:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

	thisenv = envs+ENVX(sys_getenvid());
  800074:	e8 f2 00 00 00       	call   80016b <sys_getenvid>
  800079:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007e:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800081:	c1 e0 05             	shl    $0x5,%eax
  800084:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80008a:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  800090:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800092:	85 f6                	test   %esi,%esi
  800094:	7e 08                	jle    80009e <libmain+0x44>
		binaryname = argv[0];
  800096:	8b 07                	mov    (%edi),%eax
  800098:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80009e:	83 ec 08             	sub    $0x8,%esp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	e8 8b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 0b 00 00 00       	call   8000b8 <exit>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 10             	sub    $0x10,%esp
  8000bf:	e8 92 ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8000c4:	81 c3 3c 1f 00 00    	add    $0x1f3c,%ebx
	sys_env_destroy(0);
  8000ca:	6a 00                	push   $0x0
  8000cc:	e8 45 00 00 00       	call   800116 <sys_env_destroy>
}
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d7:	c9                   	leave  
  8000d8:	c3                   	ret    

008000d9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	57                   	push   %edi
  8000dd:	56                   	push   %esi
  8000de:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000df:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ea:	89 c3                	mov    %eax,%ebx
  8000ec:	89 c7                	mov    %eax,%edi
  8000ee:	89 c6                	mov    %eax,%esi
  8000f0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f2:	5b                   	pop    %ebx
  8000f3:	5e                   	pop    %esi
  8000f4:	5f                   	pop    %edi
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	57                   	push   %edi
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800102:	b8 01 00 00 00       	mov    $0x1,%eax
  800107:	89 d1                	mov    %edx,%ecx
  800109:	89 d3                	mov    %edx,%ebx
  80010b:	89 d7                	mov    %edx,%edi
  80010d:	89 d6                	mov    %edx,%esi
  80010f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5f                   	pop    %edi
  800114:	5d                   	pop    %ebp
  800115:	c3                   	ret    

00800116 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	57                   	push   %edi
  80011a:	56                   	push   %esi
  80011b:	53                   	push   %ebx
  80011c:	83 ec 1c             	sub    $0x1c,%esp
  80011f:	e8 66 00 00 00       	call   80018a <__x86.get_pc_thunk.ax>
  800124:	05 dc 1e 00 00       	add    $0x1edc,%eax
  800129:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80012c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800131:	8b 55 08             	mov    0x8(%ebp),%edx
  800134:	b8 03 00 00 00       	mov    $0x3,%eax
  800139:	89 cb                	mov    %ecx,%ebx
  80013b:	89 cf                	mov    %ecx,%edi
  80013d:	89 ce                	mov    %ecx,%esi
  80013f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800141:	85 c0                	test   %eax,%eax
  800143:	7f 08                	jg     80014d <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800145:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5f                   	pop    %edi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80014d:	83 ec 0c             	sub    $0xc,%esp
  800150:	50                   	push   %eax
  800151:	6a 03                	push   $0x3
  800153:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800156:	8d 83 56 ee ff ff    	lea    -0x11aa(%ebx),%eax
  80015c:	50                   	push   %eax
  80015d:	6a 23                	push   $0x23
  80015f:	8d 83 73 ee ff ff    	lea    -0x118d(%ebx),%eax
  800165:	50                   	push   %eax
  800166:	e8 23 00 00 00       	call   80018e <_panic>

0080016b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	57                   	push   %edi
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
	asm volatile("int %1\n"
  800171:	ba 00 00 00 00       	mov    $0x0,%edx
  800176:	b8 02 00 00 00       	mov    $0x2,%eax
  80017b:	89 d1                	mov    %edx,%ecx
  80017d:	89 d3                	mov    %edx,%ebx
  80017f:	89 d7                	mov    %edx,%edi
  800181:	89 d6                	mov    %edx,%esi
  800183:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    

0080018a <__x86.get_pc_thunk.ax>:
  80018a:	8b 04 24             	mov    (%esp),%eax
  80018d:	c3                   	ret    

0080018e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	57                   	push   %edi
  800192:	56                   	push   %esi
  800193:	53                   	push   %ebx
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	e8 ba fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  80019c:	81 c3 64 1e 00 00    	add    $0x1e64,%ebx
	va_list ap;

	va_start(ap, fmt);
  8001a2:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a5:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  8001ab:	8b 38                	mov    (%eax),%edi
  8001ad:	e8 b9 ff ff ff       	call   80016b <sys_getenvid>
  8001b2:	83 ec 0c             	sub    $0xc,%esp
  8001b5:	ff 75 0c             	pushl  0xc(%ebp)
  8001b8:	ff 75 08             	pushl  0x8(%ebp)
  8001bb:	57                   	push   %edi
  8001bc:	50                   	push   %eax
  8001bd:	8d 83 84 ee ff ff    	lea    -0x117c(%ebx),%eax
  8001c3:	50                   	push   %eax
  8001c4:	e8 d1 00 00 00       	call   80029a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c9:	83 c4 18             	add    $0x18,%esp
  8001cc:	56                   	push   %esi
  8001cd:	ff 75 10             	pushl  0x10(%ebp)
  8001d0:	e8 63 00 00 00       	call   800238 <vcprintf>
	cprintf("\n");
  8001d5:	8d 83 a8 ee ff ff    	lea    -0x1158(%ebx),%eax
  8001db:	89 04 24             	mov    %eax,(%esp)
  8001de:	e8 b7 00 00 00       	call   80029a <cprintf>
  8001e3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e6:	cc                   	int3   
  8001e7:	eb fd                	jmp    8001e6 <_panic+0x58>

008001e9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	e8 63 fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8001f3:	81 c3 0d 1e 00 00    	add    $0x1e0d,%ebx
  8001f9:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001fc:	8b 16                	mov    (%esi),%edx
  8001fe:	8d 42 01             	lea    0x1(%edx),%eax
  800201:	89 06                	mov    %eax,(%esi)
  800203:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800206:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  80020a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020f:	74 0b                	je     80021c <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800211:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80021c:	83 ec 08             	sub    $0x8,%esp
  80021f:	68 ff 00 00 00       	push   $0xff
  800224:	8d 46 08             	lea    0x8(%esi),%eax
  800227:	50                   	push   %eax
  800228:	e8 ac fe ff ff       	call   8000d9 <sys_cputs>
		b->idx = 0;
  80022d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800233:	83 c4 10             	add    $0x10,%esp
  800236:	eb d9                	jmp    800211 <putch+0x28>

00800238 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	53                   	push   %ebx
  80023c:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800242:	e8 0f fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800247:	81 c3 b9 1d 00 00    	add    $0x1db9,%ebx
	struct printbuf b;

	b.idx = 0;
  80024d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800254:	00 00 00 
	b.cnt = 0;
  800257:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800261:	ff 75 0c             	pushl  0xc(%ebp)
  800264:	ff 75 08             	pushl  0x8(%ebp)
  800267:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026d:	50                   	push   %eax
  80026e:	8d 83 e9 e1 ff ff    	lea    -0x1e17(%ebx),%eax
  800274:	50                   	push   %eax
  800275:	e8 38 01 00 00       	call   8003b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80027a:	83 c4 08             	add    $0x8,%esp
  80027d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800283:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800289:	50                   	push   %eax
  80028a:	e8 4a fe ff ff       	call   8000d9 <sys_cputs>

	return b.cnt;
}
  80028f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800295:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002a3:	50                   	push   %eax
  8002a4:	ff 75 08             	pushl  0x8(%ebp)
  8002a7:	e8 8c ff ff ff       	call   800238 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    

008002ae <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 2c             	sub    $0x2c,%esp
  8002b7:	e8 cd 05 00 00       	call   800889 <__x86.get_pc_thunk.cx>
  8002bc:	81 c1 44 1d 00 00    	add    $0x1d44,%ecx
  8002c2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002c5:	89 c7                	mov    %eax,%edi
  8002c7:	89 d6                	mov    %edx,%esi
  8002c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002d2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002dd:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002e0:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002e3:	39 d3                	cmp    %edx,%ebx
  8002e5:	72 09                	jb     8002f0 <printnum+0x42>
  8002e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ea:	0f 87 83 00 00 00    	ja     800373 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f0:	83 ec 0c             	sub    $0xc,%esp
  8002f3:	ff 75 18             	pushl  0x18(%ebp)
  8002f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002fc:	53                   	push   %ebx
  8002fd:	ff 75 10             	pushl  0x10(%ebp)
  800300:	83 ec 08             	sub    $0x8,%esp
  800303:	ff 75 dc             	pushl  -0x24(%ebp)
  800306:	ff 75 d8             	pushl  -0x28(%ebp)
  800309:	ff 75 d4             	pushl  -0x2c(%ebp)
  80030c:	ff 75 d0             	pushl  -0x30(%ebp)
  80030f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800312:	e8 f9 08 00 00       	call   800c10 <__udivdi3>
  800317:	83 c4 18             	add    $0x18,%esp
  80031a:	52                   	push   %edx
  80031b:	50                   	push   %eax
  80031c:	89 f2                	mov    %esi,%edx
  80031e:	89 f8                	mov    %edi,%eax
  800320:	e8 89 ff ff ff       	call   8002ae <printnum>
  800325:	83 c4 20             	add    $0x20,%esp
  800328:	eb 13                	jmp    80033d <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032a:	83 ec 08             	sub    $0x8,%esp
  80032d:	56                   	push   %esi
  80032e:	ff 75 18             	pushl  0x18(%ebp)
  800331:	ff d7                	call   *%edi
  800333:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800336:	83 eb 01             	sub    $0x1,%ebx
  800339:	85 db                	test   %ebx,%ebx
  80033b:	7f ed                	jg     80032a <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80033d:	83 ec 08             	sub    $0x8,%esp
  800340:	56                   	push   %esi
  800341:	83 ec 04             	sub    $0x4,%esp
  800344:	ff 75 dc             	pushl  -0x24(%ebp)
  800347:	ff 75 d8             	pushl  -0x28(%ebp)
  80034a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80034d:	ff 75 d0             	pushl  -0x30(%ebp)
  800350:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800353:	89 f3                	mov    %esi,%ebx
  800355:	e8 d6 09 00 00       	call   800d30 <__umoddi3>
  80035a:	83 c4 14             	add    $0x14,%esp
  80035d:	0f be 84 06 aa ee ff 	movsbl -0x1156(%esi,%eax,1),%eax
  800364:	ff 
  800365:	50                   	push   %eax
  800366:	ff d7                	call   *%edi
}
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    
  800373:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800376:	eb be                	jmp    800336 <printnum+0x88>

00800378 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800382:	8b 10                	mov    (%eax),%edx
  800384:	3b 50 04             	cmp    0x4(%eax),%edx
  800387:	73 0a                	jae    800393 <sprintputch+0x1b>
		*b->buf++ = ch;
  800389:	8d 4a 01             	lea    0x1(%edx),%ecx
  80038c:	89 08                	mov    %ecx,(%eax)
  80038e:	8b 45 08             	mov    0x8(%ebp),%eax
  800391:	88 02                	mov    %al,(%edx)
}
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <printfmt>:
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80039b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039e:	50                   	push   %eax
  80039f:	ff 75 10             	pushl  0x10(%ebp)
  8003a2:	ff 75 0c             	pushl  0xc(%ebp)
  8003a5:	ff 75 08             	pushl  0x8(%ebp)
  8003a8:	e8 05 00 00 00       	call   8003b2 <vprintfmt>
}
  8003ad:	83 c4 10             	add    $0x10,%esp
  8003b0:	c9                   	leave  
  8003b1:	c3                   	ret    

008003b2 <vprintfmt>:
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	57                   	push   %edi
  8003b6:	56                   	push   %esi
  8003b7:	53                   	push   %ebx
  8003b8:	83 ec 2c             	sub    $0x2c,%esp
  8003bb:	e8 96 fc ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8003c0:	81 c3 40 1c 00 00    	add    $0x1c40,%ebx
  8003c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003c9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003cc:	e9 8e 03 00 00       	jmp    80075f <.L35+0x48>
		padc = ' ';
  8003d1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003d5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003dc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003e3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ef:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8d 47 01             	lea    0x1(%edi),%eax
  8003f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f8:	0f b6 17             	movzbl (%edi),%edx
  8003fb:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003fe:	3c 55                	cmp    $0x55,%al
  800400:	0f 87 e1 03 00 00    	ja     8007e7 <.L22>
  800406:	0f b6 c0             	movzbl %al,%eax
  800409:	89 d9                	mov    %ebx,%ecx
  80040b:	03 8c 83 38 ef ff ff 	add    -0x10c8(%ebx,%eax,4),%ecx
  800412:	ff e1                	jmp    *%ecx

00800414 <.L67>:
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800417:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80041b:	eb d5                	jmp    8003f2 <vprintfmt+0x40>

0080041d <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800420:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800424:	eb cc                	jmp    8003f2 <vprintfmt+0x40>

00800426 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	0f b6 d2             	movzbl %dl,%edx
  800429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80042c:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800431:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800434:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800438:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80043b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80043e:	83 f9 09             	cmp    $0x9,%ecx
  800441:	77 55                	ja     800498 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  800443:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800446:	eb e9                	jmp    800431 <.L29+0xb>

00800448 <.L26>:
			precision = va_arg(ap, int);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8b 00                	mov    (%eax),%eax
  80044d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 40 04             	lea    0x4(%eax),%eax
  800456:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80045c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800460:	79 90                	jns    8003f2 <vprintfmt+0x40>
				width = precision, precision = -1;
  800462:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800465:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800468:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80046f:	eb 81                	jmp    8003f2 <vprintfmt+0x40>

00800471 <.L27>:
  800471:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800474:	85 c0                	test   %eax,%eax
  800476:	ba 00 00 00 00       	mov    $0x0,%edx
  80047b:	0f 49 d0             	cmovns %eax,%edx
  80047e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800484:	e9 69 ff ff ff       	jmp    8003f2 <vprintfmt+0x40>

00800489 <.L23>:
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80048c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800493:	e9 5a ff ff ff       	jmp    8003f2 <vprintfmt+0x40>
  800498:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80049b:	eb bf                	jmp    80045c <.L26+0x14>

0080049d <.L33>:
			lflag++;
  80049d:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004a4:	e9 49 ff ff ff       	jmp    8003f2 <vprintfmt+0x40>

008004a9 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 78 04             	lea    0x4(%eax),%edi
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	56                   	push   %esi
  8004b3:	ff 30                	pushl  (%eax)
  8004b5:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004b8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004bb:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004be:	e9 99 02 00 00       	jmp    80075c <.L35+0x45>

008004c3 <.L32>:
			err = va_arg(ap, int);
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8d 78 04             	lea    0x4(%eax),%edi
  8004c9:	8b 00                	mov    (%eax),%eax
  8004cb:	99                   	cltd   
  8004cc:	31 d0                	xor    %edx,%eax
  8004ce:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d0:	83 f8 06             	cmp    $0x6,%eax
  8004d3:	7f 27                	jg     8004fc <.L32+0x39>
  8004d5:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004dc:	85 d2                	test   %edx,%edx
  8004de:	74 1c                	je     8004fc <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004e0:	52                   	push   %edx
  8004e1:	8d 83 cb ee ff ff    	lea    -0x1135(%ebx),%eax
  8004e7:	50                   	push   %eax
  8004e8:	56                   	push   %esi
  8004e9:	ff 75 08             	pushl  0x8(%ebp)
  8004ec:	e8 a4 fe ff ff       	call   800395 <printfmt>
  8004f1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f4:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004f7:	e9 60 02 00 00       	jmp    80075c <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004fc:	50                   	push   %eax
  8004fd:	8d 83 c2 ee ff ff    	lea    -0x113e(%ebx),%eax
  800503:	50                   	push   %eax
  800504:	56                   	push   %esi
  800505:	ff 75 08             	pushl  0x8(%ebp)
  800508:	e8 88 fe ff ff       	call   800395 <printfmt>
  80050d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800510:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800513:	e9 44 02 00 00       	jmp    80075c <.L35+0x45>

00800518 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	83 c0 04             	add    $0x4,%eax
  80051e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800526:	85 ff                	test   %edi,%edi
  800528:	8d 83 bb ee ff ff    	lea    -0x1145(%ebx),%eax
  80052e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800531:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800535:	0f 8e b5 00 00 00    	jle    8005f0 <.L36+0xd8>
  80053b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80053f:	75 08                	jne    800549 <.L36+0x31>
  800541:	89 75 0c             	mov    %esi,0xc(%ebp)
  800544:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800547:	eb 6d                	jmp    8005b6 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	ff 75 d0             	pushl  -0x30(%ebp)
  80054f:	57                   	push   %edi
  800550:	e8 50 03 00 00       	call   8008a5 <strnlen>
  800555:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800558:	29 c2                	sub    %eax,%edx
  80055a:	89 55 c8             	mov    %edx,-0x38(%ebp)
  80055d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800560:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800564:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800567:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80056a:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80056c:	eb 10                	jmp    80057e <.L36+0x66>
					putch(padc, putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	56                   	push   %esi
  800572:	ff 75 e0             	pushl  -0x20(%ebp)
  800575:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800578:	83 ef 01             	sub    $0x1,%edi
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	85 ff                	test   %edi,%edi
  800580:	7f ec                	jg     80056e <.L36+0x56>
  800582:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800585:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800588:	85 d2                	test   %edx,%edx
  80058a:	b8 00 00 00 00       	mov    $0x0,%eax
  80058f:	0f 49 c2             	cmovns %edx,%eax
  800592:	29 c2                	sub    %eax,%edx
  800594:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800597:	89 75 0c             	mov    %esi,0xc(%ebp)
  80059a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80059d:	eb 17                	jmp    8005b6 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  80059f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a3:	75 30                	jne    8005d5 <.L36+0xbd>
					putch(ch, putdat);
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	ff 75 0c             	pushl  0xc(%ebp)
  8005ab:	50                   	push   %eax
  8005ac:	ff 55 08             	call   *0x8(%ebp)
  8005af:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b2:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005b6:	83 c7 01             	add    $0x1,%edi
  8005b9:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005bd:	0f be c2             	movsbl %dl,%eax
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	74 52                	je     800616 <.L36+0xfe>
  8005c4:	85 f6                	test   %esi,%esi
  8005c6:	78 d7                	js     80059f <.L36+0x87>
  8005c8:	83 ee 01             	sub    $0x1,%esi
  8005cb:	79 d2                	jns    80059f <.L36+0x87>
  8005cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005d0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005d3:	eb 32                	jmp    800607 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d5:	0f be d2             	movsbl %dl,%edx
  8005d8:	83 ea 20             	sub    $0x20,%edx
  8005db:	83 fa 5e             	cmp    $0x5e,%edx
  8005de:	76 c5                	jbe    8005a5 <.L36+0x8d>
					putch('?', putdat);
  8005e0:	83 ec 08             	sub    $0x8,%esp
  8005e3:	ff 75 0c             	pushl  0xc(%ebp)
  8005e6:	6a 3f                	push   $0x3f
  8005e8:	ff 55 08             	call   *0x8(%ebp)
  8005eb:	83 c4 10             	add    $0x10,%esp
  8005ee:	eb c2                	jmp    8005b2 <.L36+0x9a>
  8005f0:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f6:	eb be                	jmp    8005b6 <.L36+0x9e>
				putch(' ', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	56                   	push   %esi
  8005fc:	6a 20                	push   $0x20
  8005fe:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800601:	83 ef 01             	sub    $0x1,%edi
  800604:	83 c4 10             	add    $0x10,%esp
  800607:	85 ff                	test   %edi,%edi
  800609:	7f ed                	jg     8005f8 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  80060b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80060e:	89 45 14             	mov    %eax,0x14(%ebp)
  800611:	e9 46 01 00 00       	jmp    80075c <.L35+0x45>
  800616:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800619:	8b 75 0c             	mov    0xc(%ebp),%esi
  80061c:	eb e9                	jmp    800607 <.L36+0xef>

0080061e <.L31>:
  80061e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  800621:	83 f9 01             	cmp    $0x1,%ecx
  800624:	7e 40                	jle    800666 <.L31+0x48>
		return va_arg(*ap, long long);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8b 50 04             	mov    0x4(%eax),%edx
  80062c:	8b 00                	mov    (%eax),%eax
  80062e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800631:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 40 08             	lea    0x8(%eax),%eax
  80063a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80063d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800641:	79 55                	jns    800698 <.L31+0x7a>
				putch('-', putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	56                   	push   %esi
  800647:	6a 2d                	push   $0x2d
  800649:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80064c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80064f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800652:	f7 da                	neg    %edx
  800654:	83 d1 00             	adc    $0x0,%ecx
  800657:	f7 d9                	neg    %ecx
  800659:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80065c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800661:	e9 db 00 00 00       	jmp    800741 <.L35+0x2a>
	else if (lflag)
  800666:	85 c9                	test   %ecx,%ecx
  800668:	75 17                	jne    800681 <.L31+0x63>
		return va_arg(*ap, int);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800672:	99                   	cltd   
  800673:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8d 40 04             	lea    0x4(%eax),%eax
  80067c:	89 45 14             	mov    %eax,0x14(%ebp)
  80067f:	eb bc                	jmp    80063d <.L31+0x1f>
		return va_arg(*ap, long);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 00                	mov    (%eax),%eax
  800686:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800689:	99                   	cltd   
  80068a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8d 40 04             	lea    0x4(%eax),%eax
  800693:	89 45 14             	mov    %eax,0x14(%ebp)
  800696:	eb a5                	jmp    80063d <.L31+0x1f>
			num = getint(&ap, lflag);
  800698:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80069b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80069e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a3:	e9 99 00 00 00       	jmp    800741 <.L35+0x2a>

008006a8 <.L37>:
  8006a8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  8006ab:	83 f9 01             	cmp    $0x1,%ecx
  8006ae:	7e 15                	jle    8006c5 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8b 10                	mov    (%eax),%edx
  8006b5:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b8:	8d 40 08             	lea    0x8(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c3:	eb 7c                	jmp    800741 <.L35+0x2a>
	else if (lflag)
  8006c5:	85 c9                	test   %ecx,%ecx
  8006c7:	75 17                	jne    8006e0 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8b 10                	mov    (%eax),%edx
  8006ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d3:	8d 40 04             	lea    0x4(%eax),%eax
  8006d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006de:	eb 61                	jmp    800741 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8b 10                	mov    (%eax),%edx
  8006e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ea:	8d 40 04             	lea    0x4(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f5:	eb 4a                	jmp    800741 <.L35+0x2a>

008006f7 <.L34>:
			putch('X', putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	56                   	push   %esi
  8006fb:	6a 58                	push   $0x58
  8006fd:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800700:	83 c4 08             	add    $0x8,%esp
  800703:	56                   	push   %esi
  800704:	6a 58                	push   $0x58
  800706:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800709:	83 c4 08             	add    $0x8,%esp
  80070c:	56                   	push   %esi
  80070d:	6a 58                	push   $0x58
  80070f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	eb 45                	jmp    80075c <.L35+0x45>

00800717 <.L35>:
			putch('0', putdat);
  800717:	83 ec 08             	sub    $0x8,%esp
  80071a:	56                   	push   %esi
  80071b:	6a 30                	push   $0x30
  80071d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800720:	83 c4 08             	add    $0x8,%esp
  800723:	56                   	push   %esi
  800724:	6a 78                	push   $0x78
  800726:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800729:	8b 45 14             	mov    0x14(%ebp),%eax
  80072c:	8b 10                	mov    (%eax),%edx
  80072e:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800733:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800736:	8d 40 04             	lea    0x4(%eax),%eax
  800739:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073c:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800741:	83 ec 0c             	sub    $0xc,%esp
  800744:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800748:	57                   	push   %edi
  800749:	ff 75 e0             	pushl  -0x20(%ebp)
  80074c:	50                   	push   %eax
  80074d:	51                   	push   %ecx
  80074e:	52                   	push   %edx
  80074f:	89 f2                	mov    %esi,%edx
  800751:	8b 45 08             	mov    0x8(%ebp),%eax
  800754:	e8 55 fb ff ff       	call   8002ae <printnum>
			break;
  800759:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80075c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80075f:	83 c7 01             	add    $0x1,%edi
  800762:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800766:	83 f8 25             	cmp    $0x25,%eax
  800769:	0f 84 62 fc ff ff    	je     8003d1 <vprintfmt+0x1f>
			if (ch == '\0')
  80076f:	85 c0                	test   %eax,%eax
  800771:	0f 84 91 00 00 00    	je     800808 <.L22+0x21>
			putch(ch, putdat);
  800777:	83 ec 08             	sub    $0x8,%esp
  80077a:	56                   	push   %esi
  80077b:	50                   	push   %eax
  80077c:	ff 55 08             	call   *0x8(%ebp)
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	eb db                	jmp    80075f <.L35+0x48>

00800784 <.L38>:
  800784:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
  800787:	83 f9 01             	cmp    $0x1,%ecx
  80078a:	7e 15                	jle    8007a1 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	8b 10                	mov    (%eax),%edx
  800791:	8b 48 04             	mov    0x4(%eax),%ecx
  800794:	8d 40 08             	lea    0x8(%eax),%eax
  800797:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80079a:	b8 10 00 00 00       	mov    $0x10,%eax
  80079f:	eb a0                	jmp    800741 <.L35+0x2a>
	else if (lflag)
  8007a1:	85 c9                	test   %ecx,%ecx
  8007a3:	75 17                	jne    8007bc <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	8b 10                	mov    (%eax),%edx
  8007aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007af:	8d 40 04             	lea    0x4(%eax),%eax
  8007b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b5:	b8 10 00 00 00       	mov    $0x10,%eax
  8007ba:	eb 85                	jmp    800741 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bf:	8b 10                	mov    (%eax),%edx
  8007c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c6:	8d 40 04             	lea    0x4(%eax),%eax
  8007c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007cc:	b8 10 00 00 00       	mov    $0x10,%eax
  8007d1:	e9 6b ff ff ff       	jmp    800741 <.L35+0x2a>

008007d6 <.L25>:
			putch(ch, putdat);
  8007d6:	83 ec 08             	sub    $0x8,%esp
  8007d9:	56                   	push   %esi
  8007da:	6a 25                	push   $0x25
  8007dc:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007df:	83 c4 10             	add    $0x10,%esp
  8007e2:	e9 75 ff ff ff       	jmp    80075c <.L35+0x45>

008007e7 <.L22>:
			putch('%', putdat);
  8007e7:	83 ec 08             	sub    $0x8,%esp
  8007ea:	56                   	push   %esi
  8007eb:	6a 25                	push   $0x25
  8007ed:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	89 f8                	mov    %edi,%eax
  8007f5:	eb 03                	jmp    8007fa <.L22+0x13>
  8007f7:	83 e8 01             	sub    $0x1,%eax
  8007fa:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007fe:	75 f7                	jne    8007f7 <.L22+0x10>
  800800:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800803:	e9 54 ff ff ff       	jmp    80075c <.L35+0x45>
}
  800808:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80080b:	5b                   	pop    %ebx
  80080c:	5e                   	pop    %esi
  80080d:	5f                   	pop    %edi
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	53                   	push   %ebx
  800814:	83 ec 14             	sub    $0x14,%esp
  800817:	e8 3a f8 ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  80081c:	81 c3 e4 17 00 00    	add    $0x17e4,%ebx
  800822:	8b 45 08             	mov    0x8(%ebp),%eax
  800825:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800828:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80082f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800832:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800839:	85 c0                	test   %eax,%eax
  80083b:	74 2b                	je     800868 <vsnprintf+0x58>
  80083d:	85 d2                	test   %edx,%edx
  80083f:	7e 27                	jle    800868 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800841:	ff 75 14             	pushl  0x14(%ebp)
  800844:	ff 75 10             	pushl  0x10(%ebp)
  800847:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084a:	50                   	push   %eax
  80084b:	8d 83 78 e3 ff ff    	lea    -0x1c88(%ebx),%eax
  800851:	50                   	push   %eax
  800852:	e8 5b fb ff ff       	call   8003b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800857:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800860:	83 c4 10             	add    $0x10,%esp
}
  800863:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800866:	c9                   	leave  
  800867:	c3                   	ret    
		return -E_INVAL;
  800868:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80086d:	eb f4                	jmp    800863 <vsnprintf+0x53>

0080086f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800875:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800878:	50                   	push   %eax
  800879:	ff 75 10             	pushl  0x10(%ebp)
  80087c:	ff 75 0c             	pushl  0xc(%ebp)
  80087f:	ff 75 08             	pushl  0x8(%ebp)
  800882:	e8 89 ff ff ff       	call   800810 <vsnprintf>
	va_end(ap);

	return rc;
}
  800887:	c9                   	leave  
  800888:	c3                   	ret    

00800889 <__x86.get_pc_thunk.cx>:
  800889:	8b 0c 24             	mov    (%esp),%ecx
  80088c:	c3                   	ret    

0080088d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800893:	b8 00 00 00 00       	mov    $0x0,%eax
  800898:	eb 03                	jmp    80089d <strlen+0x10>
		n++;
  80089a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80089d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a1:	75 f7                	jne    80089a <strlen+0xd>
	return n;
}
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b3:	eb 03                	jmp    8008b8 <strnlen+0x13>
		n++;
  8008b5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b8:	39 d0                	cmp    %edx,%eax
  8008ba:	74 06                	je     8008c2 <strnlen+0x1d>
  8008bc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008c0:	75 f3                	jne    8008b5 <strnlen+0x10>
	return n;
}
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	53                   	push   %ebx
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ce:	89 c2                	mov    %eax,%edx
  8008d0:	83 c1 01             	add    $0x1,%ecx
  8008d3:	83 c2 01             	add    $0x1,%edx
  8008d6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008da:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008dd:	84 db                	test   %bl,%bl
  8008df:	75 ef                	jne    8008d0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008e1:	5b                   	pop    %ebx
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	53                   	push   %ebx
  8008e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008eb:	53                   	push   %ebx
  8008ec:	e8 9c ff ff ff       	call   80088d <strlen>
  8008f1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008f4:	ff 75 0c             	pushl  0xc(%ebp)
  8008f7:	01 d8                	add    %ebx,%eax
  8008f9:	50                   	push   %eax
  8008fa:	e8 c5 ff ff ff       	call   8008c4 <strcpy>
	return dst;
}
  8008ff:	89 d8                	mov    %ebx,%eax
  800901:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800904:	c9                   	leave  
  800905:	c3                   	ret    

00800906 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	8b 75 08             	mov    0x8(%ebp),%esi
  80090e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800911:	89 f3                	mov    %esi,%ebx
  800913:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800916:	89 f2                	mov    %esi,%edx
  800918:	eb 0f                	jmp    800929 <strncpy+0x23>
		*dst++ = *src;
  80091a:	83 c2 01             	add    $0x1,%edx
  80091d:	0f b6 01             	movzbl (%ecx),%eax
  800920:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800923:	80 39 01             	cmpb   $0x1,(%ecx)
  800926:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800929:	39 da                	cmp    %ebx,%edx
  80092b:	75 ed                	jne    80091a <strncpy+0x14>
	}
	return ret;
}
  80092d:	89 f0                	mov    %esi,%eax
  80092f:	5b                   	pop    %ebx
  800930:	5e                   	pop    %esi
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	56                   	push   %esi
  800937:	53                   	push   %ebx
  800938:	8b 75 08             	mov    0x8(%ebp),%esi
  80093b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800941:	89 f0                	mov    %esi,%eax
  800943:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800947:	85 c9                	test   %ecx,%ecx
  800949:	75 0b                	jne    800956 <strlcpy+0x23>
  80094b:	eb 17                	jmp    800964 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094d:	83 c2 01             	add    $0x1,%edx
  800950:	83 c0 01             	add    $0x1,%eax
  800953:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800956:	39 d8                	cmp    %ebx,%eax
  800958:	74 07                	je     800961 <strlcpy+0x2e>
  80095a:	0f b6 0a             	movzbl (%edx),%ecx
  80095d:	84 c9                	test   %cl,%cl
  80095f:	75 ec                	jne    80094d <strlcpy+0x1a>
		*dst = '\0';
  800961:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800964:	29 f0                	sub    %esi,%eax
}
  800966:	5b                   	pop    %ebx
  800967:	5e                   	pop    %esi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800973:	eb 06                	jmp    80097b <strcmp+0x11>
		p++, q++;
  800975:	83 c1 01             	add    $0x1,%ecx
  800978:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80097b:	0f b6 01             	movzbl (%ecx),%eax
  80097e:	84 c0                	test   %al,%al
  800980:	74 04                	je     800986 <strcmp+0x1c>
  800982:	3a 02                	cmp    (%edx),%al
  800984:	74 ef                	je     800975 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800986:	0f b6 c0             	movzbl %al,%eax
  800989:	0f b6 12             	movzbl (%edx),%edx
  80098c:	29 d0                	sub    %edx,%eax
}
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	53                   	push   %ebx
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099a:	89 c3                	mov    %eax,%ebx
  80099c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80099f:	eb 06                	jmp    8009a7 <strncmp+0x17>
		n--, p++, q++;
  8009a1:	83 c0 01             	add    $0x1,%eax
  8009a4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009a7:	39 d8                	cmp    %ebx,%eax
  8009a9:	74 16                	je     8009c1 <strncmp+0x31>
  8009ab:	0f b6 08             	movzbl (%eax),%ecx
  8009ae:	84 c9                	test   %cl,%cl
  8009b0:	74 04                	je     8009b6 <strncmp+0x26>
  8009b2:	3a 0a                	cmp    (%edx),%cl
  8009b4:	74 eb                	je     8009a1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b6:	0f b6 00             	movzbl (%eax),%eax
  8009b9:	0f b6 12             	movzbl (%edx),%edx
  8009bc:	29 d0                	sub    %edx,%eax
}
  8009be:	5b                   	pop    %ebx
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    
		return 0;
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c6:	eb f6                	jmp    8009be <strncmp+0x2e>

008009c8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d2:	0f b6 10             	movzbl (%eax),%edx
  8009d5:	84 d2                	test   %dl,%dl
  8009d7:	74 09                	je     8009e2 <strchr+0x1a>
		if (*s == c)
  8009d9:	38 ca                	cmp    %cl,%dl
  8009db:	74 0a                	je     8009e7 <strchr+0x1f>
	for (; *s; s++)
  8009dd:	83 c0 01             	add    $0x1,%eax
  8009e0:	eb f0                	jmp    8009d2 <strchr+0xa>
			return (char *) s;
	return 0;
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f3:	eb 03                	jmp    8009f8 <strfind+0xf>
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009fb:	38 ca                	cmp    %cl,%dl
  8009fd:	74 04                	je     800a03 <strfind+0x1a>
  8009ff:	84 d2                	test   %dl,%dl
  800a01:	75 f2                	jne    8009f5 <strfind+0xc>
			break;
	return (char *) s;
}
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	57                   	push   %edi
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a11:	85 c9                	test   %ecx,%ecx
  800a13:	74 13                	je     800a28 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1b:	75 05                	jne    800a22 <memset+0x1d>
  800a1d:	f6 c1 03             	test   $0x3,%cl
  800a20:	74 0d                	je     800a2f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a25:	fc                   	cld    
  800a26:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a28:	89 f8                	mov    %edi,%eax
  800a2a:	5b                   	pop    %ebx
  800a2b:	5e                   	pop    %esi
  800a2c:	5f                   	pop    %edi
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    
		c &= 0xFF;
  800a2f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a33:	89 d3                	mov    %edx,%ebx
  800a35:	c1 e3 08             	shl    $0x8,%ebx
  800a38:	89 d0                	mov    %edx,%eax
  800a3a:	c1 e0 18             	shl    $0x18,%eax
  800a3d:	89 d6                	mov    %edx,%esi
  800a3f:	c1 e6 10             	shl    $0x10,%esi
  800a42:	09 f0                	or     %esi,%eax
  800a44:	09 c2                	or     %eax,%edx
  800a46:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a48:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a4b:	89 d0                	mov    %edx,%eax
  800a4d:	fc                   	cld    
  800a4e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a50:	eb d6                	jmp    800a28 <memset+0x23>

00800a52 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	57                   	push   %edi
  800a56:	56                   	push   %esi
  800a57:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a60:	39 c6                	cmp    %eax,%esi
  800a62:	73 35                	jae    800a99 <memmove+0x47>
  800a64:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a67:	39 c2                	cmp    %eax,%edx
  800a69:	76 2e                	jbe    800a99 <memmove+0x47>
		s += n;
		d += n;
  800a6b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6e:	89 d6                	mov    %edx,%esi
  800a70:	09 fe                	or     %edi,%esi
  800a72:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a78:	74 0c                	je     800a86 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a7a:	83 ef 01             	sub    $0x1,%edi
  800a7d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a80:	fd                   	std    
  800a81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a83:	fc                   	cld    
  800a84:	eb 21                	jmp    800aa7 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a86:	f6 c1 03             	test   $0x3,%cl
  800a89:	75 ef                	jne    800a7a <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a8b:	83 ef 04             	sub    $0x4,%edi
  800a8e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a91:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a94:	fd                   	std    
  800a95:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a97:	eb ea                	jmp    800a83 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a99:	89 f2                	mov    %esi,%edx
  800a9b:	09 c2                	or     %eax,%edx
  800a9d:	f6 c2 03             	test   $0x3,%dl
  800aa0:	74 09                	je     800aab <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa2:	89 c7                	mov    %eax,%edi
  800aa4:	fc                   	cld    
  800aa5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa7:	5e                   	pop    %esi
  800aa8:	5f                   	pop    %edi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aab:	f6 c1 03             	test   $0x3,%cl
  800aae:	75 f2                	jne    800aa2 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ab0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ab3:	89 c7                	mov    %eax,%edi
  800ab5:	fc                   	cld    
  800ab6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab8:	eb ed                	jmp    800aa7 <memmove+0x55>

00800aba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800abd:	ff 75 10             	pushl  0x10(%ebp)
  800ac0:	ff 75 0c             	pushl  0xc(%ebp)
  800ac3:	ff 75 08             	pushl  0x8(%ebp)
  800ac6:	e8 87 ff ff ff       	call   800a52 <memmove>
}
  800acb:	c9                   	leave  
  800acc:	c3                   	ret    

00800acd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad8:	89 c6                	mov    %eax,%esi
  800ada:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800add:	39 f0                	cmp    %esi,%eax
  800adf:	74 1c                	je     800afd <memcmp+0x30>
		if (*s1 != *s2)
  800ae1:	0f b6 08             	movzbl (%eax),%ecx
  800ae4:	0f b6 1a             	movzbl (%edx),%ebx
  800ae7:	38 d9                	cmp    %bl,%cl
  800ae9:	75 08                	jne    800af3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800aeb:	83 c0 01             	add    $0x1,%eax
  800aee:	83 c2 01             	add    $0x1,%edx
  800af1:	eb ea                	jmp    800add <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800af3:	0f b6 c1             	movzbl %cl,%eax
  800af6:	0f b6 db             	movzbl %bl,%ebx
  800af9:	29 d8                	sub    %ebx,%eax
  800afb:	eb 05                	jmp    800b02 <memcmp+0x35>
	}

	return 0;
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b0f:	89 c2                	mov    %eax,%edx
  800b11:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b14:	39 d0                	cmp    %edx,%eax
  800b16:	73 09                	jae    800b21 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b18:	38 08                	cmp    %cl,(%eax)
  800b1a:	74 05                	je     800b21 <memfind+0x1b>
	for (; s < ends; s++)
  800b1c:	83 c0 01             	add    $0x1,%eax
  800b1f:	eb f3                	jmp    800b14 <memfind+0xe>
			break;
	return (void *) s;
}
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2f:	eb 03                	jmp    800b34 <strtol+0x11>
		s++;
  800b31:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b34:	0f b6 01             	movzbl (%ecx),%eax
  800b37:	3c 20                	cmp    $0x20,%al
  800b39:	74 f6                	je     800b31 <strtol+0xe>
  800b3b:	3c 09                	cmp    $0x9,%al
  800b3d:	74 f2                	je     800b31 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b3f:	3c 2b                	cmp    $0x2b,%al
  800b41:	74 2e                	je     800b71 <strtol+0x4e>
	int neg = 0;
  800b43:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b48:	3c 2d                	cmp    $0x2d,%al
  800b4a:	74 2f                	je     800b7b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b4c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b52:	75 05                	jne    800b59 <strtol+0x36>
  800b54:	80 39 30             	cmpb   $0x30,(%ecx)
  800b57:	74 2c                	je     800b85 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b59:	85 db                	test   %ebx,%ebx
  800b5b:	75 0a                	jne    800b67 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b5d:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b62:	80 39 30             	cmpb   $0x30,(%ecx)
  800b65:	74 28                	je     800b8f <strtol+0x6c>
		base = 10;
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b6f:	eb 50                	jmp    800bc1 <strtol+0x9e>
		s++;
  800b71:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b74:	bf 00 00 00 00       	mov    $0x0,%edi
  800b79:	eb d1                	jmp    800b4c <strtol+0x29>
		s++, neg = 1;
  800b7b:	83 c1 01             	add    $0x1,%ecx
  800b7e:	bf 01 00 00 00       	mov    $0x1,%edi
  800b83:	eb c7                	jmp    800b4c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b85:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b89:	74 0e                	je     800b99 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b8b:	85 db                	test   %ebx,%ebx
  800b8d:	75 d8                	jne    800b67 <strtol+0x44>
		s++, base = 8;
  800b8f:	83 c1 01             	add    $0x1,%ecx
  800b92:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b97:	eb ce                	jmp    800b67 <strtol+0x44>
		s += 2, base = 16;
  800b99:	83 c1 02             	add    $0x2,%ecx
  800b9c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ba1:	eb c4                	jmp    800b67 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ba3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ba6:	89 f3                	mov    %esi,%ebx
  800ba8:	80 fb 19             	cmp    $0x19,%bl
  800bab:	77 29                	ja     800bd6 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bad:	0f be d2             	movsbl %dl,%edx
  800bb0:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bb3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bb6:	7d 30                	jge    800be8 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bb8:	83 c1 01             	add    $0x1,%ecx
  800bbb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bbf:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bc1:	0f b6 11             	movzbl (%ecx),%edx
  800bc4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bc7:	89 f3                	mov    %esi,%ebx
  800bc9:	80 fb 09             	cmp    $0x9,%bl
  800bcc:	77 d5                	ja     800ba3 <strtol+0x80>
			dig = *s - '0';
  800bce:	0f be d2             	movsbl %dl,%edx
  800bd1:	83 ea 30             	sub    $0x30,%edx
  800bd4:	eb dd                	jmp    800bb3 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bd6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bd9:	89 f3                	mov    %esi,%ebx
  800bdb:	80 fb 19             	cmp    $0x19,%bl
  800bde:	77 08                	ja     800be8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800be0:	0f be d2             	movsbl %dl,%edx
  800be3:	83 ea 37             	sub    $0x37,%edx
  800be6:	eb cb                	jmp    800bb3 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800be8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bec:	74 05                	je     800bf3 <strtol+0xd0>
		*endptr = (char *) s;
  800bee:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bf3:	89 c2                	mov    %eax,%edx
  800bf5:	f7 da                	neg    %edx
  800bf7:	85 ff                	test   %edi,%edi
  800bf9:	0f 45 c2             	cmovne %edx,%eax
}
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    
  800c01:	66 90                	xchg   %ax,%ax
  800c03:	66 90                	xchg   %ax,%ax
  800c05:	66 90                	xchg   %ax,%ax
  800c07:	66 90                	xchg   %ax,%ax
  800c09:	66 90                	xchg   %ax,%ax
  800c0b:	66 90                	xchg   %ax,%ax
  800c0d:	66 90                	xchg   %ax,%ax
  800c0f:	90                   	nop

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
