; BYE3 vKPM (revised 03/14/84)
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;:: Micro Cornucopia Magazine                                       DmC  ::
;:: PO Box 223			Special thanks to Robert Aprato          ::
;:: Bend Oregon 97709		        who sent us the source code      ::
;::				Configuration for Kaypro Earl F. Weener  ::
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;				
;		REMOTE CONSOLE PROGRAM FOR CP/M AND MODEM
;
;=======================================================================
;
; System equates
;
YES:	 EQU	0FFH	;for conditional assembly
NO:	 EQU	0
;
;
CR:	 EQU	0DH	;ASCII carriage return
LF:	 EQU	0AH	;ASCII line feed
MINUTES: EQU	20*60	;constant for 1 minute time delay
;
IOBYTE:	 EQU	0003H	;location of CP/M iobyte
FCB:	 EQU	005CH
FCBRNO:	 EQU	FCB+32
;
;
; BDOS equates
;
BDOS:	 EQU	0005H
CI:	 EQU	1
WRCON:	 EQU	2
DRECTIO: EQU	6
PRINTF:	 EQU	9
CSTS:	 EQU	11
OPEN:	 EQU	15
READ:	 EQU	20
STDMA:	 EQU	26
;
;
; You will likely also want to change the password, located below at
; label 'PASSWD', and the messages printed at label 'WELCOME' and just
; above label 'HANGUP'.  The names of the welcome and .com files are at
; labels 'WELFIN' and 'COMFCB' respectively. (This stuff is near the
; end of this file.)
;
;***********************************************************************
;
;		     OPTION CONFIGURATION SECTION
;
;***********************************************************************
;
;
;-------------------------- general options ----------------------------
;
;*** If you don't know how to do this keep BYELOW=YES *********************
BYELOW:	 EQU	YES	;yes, running BYE3 below CCP; no for above BIOS
RAMTOP:	 EQU	0FFFFH	;last available RAM if BYELOW is 'NO'
;
;**************************************************************************
;*** We only support smart modem with this program if you want to change **
;*** this you will have to write your own drivers ************************* 
SMODEM:	 EQU	YES	;yes, for Smartmodem, no for other types
;
IOVAL:	 EQU	0	;initial value for IOBYTE (only if MINICK 'YES')
MINICK:	 EQU	NO	;yes, running MINICBBS
OXGATE:	 EQU	NO	;yes, running OXGATE RCPM-BBS system
RBBSCK:	 EQU	YES 	;yes, running RBBS - sets/resets 'WRTLOC' flag
;-----------------------------------------------------------------------
;
;*** If yes, make sure all these devices are supported by your bios or ****
;*** a remote user could hang your system *********************************
ALLDEV:	 EQU	NO	;yes, retain PUN: RDR: and LST: devices
;
BOOTMSG: EQU	YES 	;yes, print "please wait..." message
;
;*** CallBack is a way for the computer and people to share the same phone*
;*** line. If callback is enabled, to get the computer you call, let the **
;*** phone ring only once then call back. To get people you let the     ***
;*** phone ring more than once. *******************************************
CALLBAK: EQU	NO 	;yes, allow callback feature
;
COMFILE: EQU	NO	;yes, chain a .COM file upon carrier reception
			;.....next time BYE3 answers the phone.
DECIMAL: EQU	YES	;yes, decimal value for userlog
;
;*** Dual I/O works very nicely on the kaypro. Typeing at the keyboard is *
;*** is the same as typeing form a remote system. *************************
DUAL$IO: EQU	YES	;yes, console/modem linked together
;
EXFILE:	 EQU	NO	;yes, chain a .COM file upon loss of carrier
;
;*** See the FKEYS section of this file to see what the keys are defined as
; 
FKEYS:	 EQU	YES	;yes, local console has special function keys

HARDLOG: EQU	NO	;yes, echo remote input to printer
HOLD:	 EQU	YES	;yes, allows caller to CTL-S the welcome file
LGONMSG: EQU	NO 	;yes, print message before "how many nulls" msg
PRINTER: EQU	NO	;yes, retain list device
PRNTGB:	 EQU	YES	;yes, print "Goodbye..." message
PRNTWB:	 EQU	NO 	;yes, print a string each time system warm boots
PWRQD:	 EQU	NO	;yes, password needed to login
;
;*** See RKEYS section to see what the RKEYs are. *************************
RKEYS:	 EQU	NO	;yes, remote console has special function keys
;
;*** If set to yes, if no input from user for TOVALUE minutes this system *
;*** disconnects the user. ************************************************ 
TIMEOUT: EQU	YES	;yes, auto logout for sleepy callers
TOVALUE: EQU	5	;minutes to auto logout
;
;*** If yes the number of users is tallied. A control-C on the keyboard ***
;*** displays this number to the sysop. Run BYE by entering BYE /R to   ***
;*** reset the counters. ************************************************** 
USRLOG:	 EQU	YES	;yes, count number of users
;
;*** The function must be written by you **********************************
WBRTN:	 EQU	NO	;yes, do function each time system warm boots
;
;
;---------- system and hardware dependent options --------------
;

BLKOUT:	 EQU	YES	;turn off remote send (so that what you enter at
			;keyboard is not seen by remote user. 
BLNKKEY: EQU	'B'-40H	;^B keycode to "blank out" remote terminal (as above)
CCSDISK: EQU	NO	;yes, CCS disk controller
CLOSS:	 EQU	5	;if carrier dies, wait 5 secs. before hanging up

COMUSR:	 EQU	15	;user # of .COM file to be called after answer
			; (if COMFILE=YES)
CPM2:	 EQU	YES	;yes, using CP/M 2.2
CTRLC:	 EQU	'K'-40H	;map ^C to this if 0000H<>C3H (nb: ^O=15 decimal)
CWAIT:	 EQU	20	;wait up to 20 seconds for carrier at first
EXUSR:	 EQU	00	;user # of .COM file to be called upon exit
			; (if EXFILE=YES) 
IMSAI:	 EQU	NO	;yes, if using IMSAI computer with front panel
INULLS:	 EQU	01	;initial number of nulls
LOSER:	 EQU	NO	;yes, warm boot overwrites part of the BIOS
			;NO for Kaypro
LXID:	 EQU	11H	;define byte of LXI D,nnnn to fake loader
LXIH:	 EQU	21H	;define byte of LXI H,nnnn to fake loader

MHZ:	 EQU	5	;processor clock in MHz
			; 3 for standard Kaypro
			; 4 or 5 for High Speed Kaypro
MSGKEY:	 EQU	'Q'-40H	;(^Q) keycode to print "Message from SYSOP: "
MSPEED:	 EQU	003CH	;baud rate pointer
NORING:	 EQU	YES	;yes, UART ring indicator NOT available
NZCPR:	 EQU	NO 	;yes, if running NEWZCPR under secure mode
			; We are talking about ZCPR-II here.
	
SELPASS: EQU	NO	;require a password
			; Password is kept near the end of this file
SENSE:	 EQU	0FFH	;sense switch port number
SMAXDRV: EQU	16	;number of drives available to SYSOP
SMAXUSR: EQU	16	;number of user areas available to SYSOP
SYSDKEY: EQU	'O'-40H	;(^O) keycode to print "System going down in 5 min.."
TWITKEY: EQU	'N'-40H	;(^N) keycode to hangup modem manually
WELFILE: EQU	YES 	;yes, to send a WELCOME file
WELUSR:	 EQU	15	;user # of WELCOME file
WHEEL:	 EQU	003EH	;location of NZCPR's wheel flag
ZILOG:	 EQU	YES	;yes, using a Z-80 or Z-800
;
;
; If USEZCPR is YES, it automatically sets MAXDRIV and USERMAX from the
; ZCPR locations.  Otherwise it uses the vaules you insert for MAXDRV
; and MAXUSR.
;
USEZCPR: EQU	NO 	;yes, if using ZCPR to set max drive and user #
MAXDRIV: EQU	003DH	;ZCPR location of MAXDRIV byte
MAXUSER: EQU	003FH	;ZCPR location of MAXUSR byte
;
;*** These limit how deep into your system a remote user can penetrate.
MAXDRV:	 EQU	2	;highest drive supported (2=B:)
MAXUSR:	 EQU	15	;highest user area (set to 0 for CP.M 1.4)
;
;-----------------------------------------------------------------------
;
BP110:	 EQU	0	;110 bps - baud rate pointers for MSPEED
BP300:	 EQU	1	;300 bps
BP450:	 EQU	2	;450 bps
BP600:	 EQU	3	;600 bps
BP710:	 EQU	4	;710 bps
BP1200:	 EQU	5	;1200 bps
BP9600:	 EQU	8	;9600 bps
BP19200: EQU	9	;19200 bps
;
;-----------------------------------------------------------------------
;
	  IF	CCSDISK
DISK:	 EQU	034H	;disk control port
DISKON:	 EQU	071H	;motors on, select disk A:
DISKOFF: EQU	051H	;motors off, select disk A:
	  ENDIF		;CCSDISK
;
;
; Assignment of front-panel options to switches:
;
	  IF	IMSAI
BLACKSW: EQU	04H	;turn on to black out remote end
ENABLF:	 EQU	08H	;turn on to enable special function keys
LOGSW:	 EQU	01H	;turn on for hardcopy
PWDSW:	 EQU	02H	;turn on for 'password' mode
	  ENDIF		;IMSAI
;
;
; There are some cases where warm boot overwrites the initial bios jump
; table.  This problem was solved for the Superbrain 3.0 bios by find-
; ing a warmboot call to HIGH in the BIOS.  This call is then patched by
; BYE.	The form of the call is:     WBCALL   CALL  WMSTRT
;
	 IF	LOSER
WBCALL:	EQU	0DE48H		;check this in your BIOS
;
;
; The following location is called
;
WMSTRT:	EQU	EE48H		;check this in your BIOS
	 ENDIF			;LOSER
;
;
;***********************************************************************
;
;	     END OF OPTION CONFIGURATION SECTION FOR BYE3
;
;***********************************************************************
;
;
	ORG	100H
;
;
;----------------------- Special Loader Routine ------------------------
;
START:	LXI	SP,ISTACK	;set stack for initialization routine
;
	 IF	BYELOW
	CALL	MDCARCK		;check to see if BYE3 is already loaded
	LHLD	BDOS+1		;load BDOS vector
	JZ	STARTA		;no carrier, go relocate code
	INX	H		;compute start of BYE3
	INX	H
	INX	H
	PCHL			;go execute already loaded code
;
STARTA:	LXI	D,-(2048+256)	;2k btyes in CCP plus 1 sector
	DAD	D		;make room for the CCP
	 ENDIF			;BYELOW
;
	 IF	NOT BYELOW
	LXI	H,RAMTOP-(OBJEND-PEND)
	ENDIF			;NOT BYELOW
;
;
; HL now contains the destination address of BYE3
;
	LXI	D,PEND-1	;set up the source pointer
	LXI	B,PEND-BEGOBJ	;set up byte counter
;
;
; This is the long version for 8080s and 8085s
;
	 IF	NOT ZILOG
BLOCK:	LDAX	D		;get program byte
	MOV	M,A		;move program byte
	MOV	A,B		;get byte count
	ORA	C		;finished block transfer?
	JZ	UPDATE		;yes, check on the opcode values
	DCX	D		;no, set source pointer
	DCX	H		;set destination pointer
	DCX	B		;set byte counter
	JMP	BLOCK		;continue block transfer until finished
	 ENDIF			;NOT ZILOG
;
;
; The following is for the Zilog Z-80 or Z-800.
;
	 IF	ZILOG
	XCHG			;reverse source and destination for lddr
	DB	0EDH,0B8H	;these are the codes for lddr
	XCHG			;restore regs to original order
	 ENDIF			;ZILOG
;
UPDATE:	XCHG			;move the source addrress into 'HL'
	CALL	NEGHL		;prepare value for subtraction
	DAD	D		;form the program offset
	SHLD	OFFSET		;save the program offset
	XCHG			;set up the offset register
	LXI	H,ENDOBJ	;get  the ending addr of the prgm code
	DAD	D		;form new ending addr (new location)
	SHLD	ENDRNG		;save the ending addr of the prgm code
	LXI	H,BEGOBJ	;get  the start addr of the program code
	DAD	D		;form new beginning addr (new location)
;
;
; The following code determines whether or not an address is within the
; BYE prgm and sets it to the new address if it is - otherwise it will
; not disturb the code...
;
	DCX	H		;set up the sourc pointer for the modi-
				;..fication routine entry
MODIFY:	INX	H		;point to the next (hopefully) instr.
	DB	LXID		;get the address of the end of BYE3
;
ENDRNG:	DW	0
	MOV	A,E
	SUB	L
	MOV	A,D
	SBB	H		;have we finished moving this block?
	JC	BEGIN		;yes, we can begin now.
;
;
; Here is where we test for the 3-byte opcodes
;
	MVI	B,INST3E-INST3	;get the number of elements in the table
	LXI	D,INST3		;set up the 3-byte opcodes table pointer
;
THRBYT:	LDAX	D		;get opcode byte from table
	CMP	M		;is this byte a 3-byte opcode?
	JZ	CHANGE		;change the 2nd and 3rd bytes if needed
	INX	D		;no, advance table pointer
	DCR	B		;end of 3-byte table?
	JNZ	THRBYT		;no, keep looking
;
;
; Skip all the 2-byte opcodes - this keeps the transfer program from
; trying to figure out what the second byte is.
;
	MVI	B,INST2E-INST2	;get the number of elements in the table
	LXI	D,INST2		;set up the 2-byte-opcodes-table pointer
;
TWOBYT:	LDAX	D		;get opcode byte from table
	CMP	M		;is this byte a 2-byte opcode?
	JZ	SKIP		;yes, skip it and continue
	DCR	B		;no, end of 2-byte table?
	INX	D		;advance table pointer
	JNZ	TWOBYT		;no, keep looking
	JMP	MODIFY		;yes, it's a one-byte opcode, keep going
;
SKIP:	INX	H		;advance object code pointera
	JMP	MODIFY		;continue search
;
CHANGE:	LXI	D,OBJEND	;set up end of range pointer
	LXI	B,BEGOBJ	;set up beginning of range pointer
;
;
; See if the address is above the range
;
	INX	H		;advance pointer to the LSB of the addr
	MOV	A,E
	SUB	M
	INX	H		;advance pointer to the MSB of the addr
	MOV	A,D
	SBB	M
	JC	MODIFY
;
;
; See if the address is below the range
;
	DCX	H		;set back pointer to the LSB of the addr
	MOV	A,M
	SUB	C
	INX	H		;advance pointer to the MSB of the addr
	MOV	A,M
	SBB	B
	JC	MODIFY
;
;
; Update the value of this address by adding the offset to it
;
	DCX	H		;set back pointer to the LSB of the addr
	DB	LXID		;load DE with the offset value
;
OFFSET:	DW	0
	MOV	A,M		;get base address
	ADD	E		;change LSB to new address
	MOV	M,A		;update memory
	INX	H		;advance pointer to the MSB of the addr
	MOV	A,M		;get the MSB of the base addr
	ADC	D		;change LSB to new address
	MOV	M,A		;update memory
	JMP	MODIFY		;take care of the next instruction
;
;
; Small subroutine to negate the contents of HL
;
NEGHL:	MOV	A,H
	CMA
	MOV	H,A		;get the complement of the MSB
	MOV	A,L
	CMA
	MOV	L,A		;get the complement of the LSBb
	INX	H		;make 'HL' totally negative
	RET
;
;
; Prepare to branch to the bye program
;
BEGIN:	EQU	$
;
	 IF	BYELOW
	LHLD	BDOS+1
	PUSH	H
	LXI	D,BEGOBJ
	LHLD	OFFSET		;get prgram offset
	DAD	D		;form address of new BDOS address
	SHLD	BDOS+1		;update BDOS vector
	INX	H
	POP	D
	MOV	M,E
	INX	H
	MOV	M,D
	INX	H
	 ENDIF			;BYELOW
;
	 IF	NOT BYELOW
	LXI	D,BEGOBJ2	;start of BYE3 code
	LHLD	OFFSET
	DAD	D		;'HL' >start of relocated code
	 ENDIF			;NOT BYELOW
;
	PCHL			;jump to relocated BYE3 program
;
;
; The following table defines the 3-byte load instructions used in the
; 8080 instruction set.
;
INST3:	DB	01H
	DB	11H
	DB	21H
	DB	22H
	DB	2AH
	DB	31H
	DB	32H
	DB	3AH
	DB	0C2H
	DB	0C3H
	DB	0C4H
	DB	0CAH
	DB	0CCH
	DB	0CDH
	DB	0D2H
	DB	0D4H
	DB	0DAH
	DB	0DCH
	DB	0E2H
	DB	0E4H
	DB	0EAH
	DB	0ECH
	DB	0F2H
	DB	0F4H
	DB	0FAH
	DB	0FCH
;
INST3E:	EQU	$			;end of 3 byte op codes
;
; The following table is the listing of the 2-byte opcodes used in the
; 8080 instruction code set.
;
INST2:	DB	06H
	DB	0EH
	DB	16H
	DB	1EH
	DB	26H
	DB	2EH
	DB	36H
	DB	3EH
	DB	0C6H
	DB	0CEH
	DB	0D3H
	DB	0D6H
	DB	0DBH
	DB	0DEH
	DB	0E6H
	DB	0EEH
	DB	0F6H
	DB	0FEH
;
INST2E:	EQU	$			;end of 2 byte op codes
;
;
; Set aside space for the stack region
;
	DS	20H
;
ISTACK:	DW	0		;top of stack
;
;
;-----------------------------------------------------------------------
;
;		     THE FOLLOWING CODE GETS MOVED
;		       TO HIGH RAM BY THE LOADER
;		     PROGRAM, WHERE IT IS EXECUTED.
;
;-----------------------------------------------------------------------
;
BEGOBJ:	JMP	0		;filled by begin if BYELOW
BEGOBJ2:JMP	START0		;hop over fixed vectors
;
MCBOOT:	JMP	MBOOT		;off to warm boot
	JMP	PRNLOG		;go print out items of interest
;
; Variables follow in a predefined order that can be manipulated by a
; passworded or other program to give special users different capabili-
; ties.
;
;***********************************************************************
;
; Here is a quickie handy reference table to use so we do not get mixed
; up.  Please it in any future changes.
;
; |mxusr|mxdrv|toval|nulls|ulcsw|lfeeds|wrtloc|hardon|lostflg|covect|
; |1 byt|1 byt|1 byt|1 byt|1 byt|1 byte|1 byte|1 byte|1 byte |2 byes|
;
;***********************************************************************
;
; Runtime maximum user area  (unused under CP/M 1.4)
;
MXUSR:	DB	MAXUSR
;
;
; Runtime maximum drive available
;
MXDRV:	DB	MAXDRV
;
;
; Number of minutes to wait before timeout
;
TOVAL:	DB	TOVALUE
;
;
; Number of nulls to put after a carriage return
;
NULLS:	DB	INULLS
;
;
; Upper-case only switch, 32 for uppercase, 0 for upper/lowercase
;
ULCSW:	DB	0
;
;
; Line-feed masking bit (non-zero= mask line feeds)
;
LFEEDS:	DB	NO
;
;
; Location RBBS pokes so modem does not hang-up during disk writes
;
WRTLOC:	DB	NO
;
; Switch to let SYSOP turn on/off the hard log (so his work remotely
; will not show up on the hardlog and waste all that paper) if HARDLOG
; is set 'NO', s
	LXI	H,NEWUSR	;get last value
	CALL	BOPLOG		;call routine to add one
	 ENDIF			;USRLOG
;
	 IF	IMSAI AND USRLOG
	LDA	NEWUSR		;re-get low order value
	CMA			;invert for lights
	OUT	SENSE		;display on IMSAI front panel
	 ENDIF			;IMSAI AND USRLOG
;
	 IF	BOOTMSG
	LXI	H,PLSMSG	;please wait message
	CALL	ILPRT		;send this message
	 ENDIF			;BOOTMSG
;
	 IF	COMFILE	AND CPM2
	MVI	C,32
	MVI	E,COMUSR	;switch to .COM file user area
	CALL	BDOS
	 ENDIF			;COMFILE AND CPM2
;
	 IF	COMFILE
	MVI	A,20H		;fool the system so that the .COM file
	STA	FCB+1		;  will see a space at FCB+1 for default
	LDA	OPTION		;  purposes.
	CPI	'A'		;SYSOP can bypass .COM file by typing
	JZ	0000H		;  BYE /A
	CPI	'C'		;SYSOP can also go to .COM file loaded
	JNZ	RUNCOM		;  with BYE /C
	LXI	H,LSMSG		;loading System Message
	CALL	ILPRT		;send this message:
	CALL	LODCOM
;
;
; Everyone else gets com file
;
RUNCOM:	CALL	100H
	 ENDIF			;COMFILE
;
	JMP	0000H		;warm boot now for "normal" CP/M use
;
;
; TSTBAUD attempts to read a CR, LF or CTL-C and returns with zero flag
; if the character read is one of these three.
;
TSTBAUD:CALL	MINPUT		;get character from modem
	CPI	CR		;if a CR
	RZ
	CPI	LF		;if a LF
	RZ
	CPI	'C'-40H		;if a CTL-C
	RET			;return with proper flags set
;.....
;
;
; Test to see if carrier is there.  If after CWAIT seconds, no carrier,
; then return, saying so.  This routine is only called just after we as-
; swered the phone.
;
FRSTCR:	CALL	MDCARCK		;carrier there?
	JNZ	CARCK2		;yes, jump to regular routine
	PUSH	B		;save BC
	MVI	B,CWAIT*10	;set for "cwait" seconds
	JMP	CARLP		;from here on, same as other routine
;
;
; Loss of connection test
;
CARCK:	CALL	MDCARCK		;carrier there?
	JNZ	CARCK2		;yep, go onto other checks...
	PUSH	B		;preserve so we can use it
	MVI	B,CLOSS*10	;set for 'CLOSS' seconds
;
CARLP:	CALL	DELAY		;wait .1 seconds
	CALL	MDCARCK		;check for carrier
	MOV	A,B		;get count back in a
	POP	B		;fix stack in case all is ok
	JNZ	CARCK2		;got carrier, contT		;check for character typed
	ORA	A
	JZ	WELTYLP		;no, loop
	CALL	MINPUT		;yes, get character
	 ENDIF			;WELFILE
;
	 IF	HOLD AND WELFILE
	CPI	'S'-40H		;CTL-S to delay listing?
	JNZ	WELTYLP		;no, loop until EOF
;
WAIT:	CALL	MSTAT
	ORA	A		;has another char been typed?
	JZ	WAIT		;no, wait
	CALL	MINPUT		;yes, check character
	 ENDIF			;HOLD AND WELFILE
;
	 IF	WELFILE
	CPI	'C'-40H		;CTL-C to end listing?
	JNZ	WELTYLP		;no, loop until eof
	 ENDIF			;WELFILE
;
;
; Get the password
;
PASSINT:EQU	$		;get the password
;
	 IF	PWRQD AND IMSAI	AND SELPASS
	IN	SENSE		;turn the switch up to require password
	ANI	PWDSW
	JZ	NOPASS
	 ENDIF			;PWRQD AND IMSAI AND SELPASS
;
	 IF	PWRQD
	MVI	D,3		;3 tries at password
;
PASSINP:LXI	H,PWMSG		;password message
	CALL	ILPRT		;send this message
	LXI	H,PASSWD	;point to password
	MVI	E,0		;no missed letters
;
PWMLP:	CALL	MINPUT		;get a character
	CPI	60H		;lower case?
	JC	NOTLC		;no,
	ANI	5FH		;make upper case alpha
;
NOTLC:	 ENDIF			;PWRQD
;
	 IF	DUAL$IO	AND PWRQD
	PUSH	PSW		;save character input
	CPI	20H		;is character a control code?
	JNC	PWDIS		;pass if displayable
	MVI	C,'^'		;if control map to up arrow then display
	CALL	CONOUT
	POP	PSW
	PUSH	PSW
	ADI	40H
;
PWDIS:	MOV	C,A
	CALL	CONOUT		;output character locally
	POP	PSW		;restore 'A' reg.
	 ENDIF			;DUAL$IO AND PWRQD
;
	 IF	PWRQD
	CPI	'U'-40H		;CTL-U?
	JZ	PASSINP		;yes, abort, and retry
	CMP	M		;match password?
	JZ	PWMAT
	MVI	E,1		;no, show miss
	CPI	CR		;CR?
	JNZ	PWMLP		;no, wait for CR
;
;
; Password did not match
;
PWNMAT:	LXI	H,WRGMSG	;wrong password message
	CALL	ILPRT		;send this message
	DCR	D		;more tries?
	JNZ	PASSINP		;yes
	JMP	BADPASS		;no, go hang up
;
;
; Character matched in password
;
PWMAT:	INX	H		;to next character
	CPI	CR		;end?
	JNZ	PWMLP		;no, loop
;
;
; End of password.  Any missed chars?
;
	MOV	A,E		;get flag
	ORA	A
	JNZ	PWNMAT		;not right
	 ENDIF			;PWRQD
;
NOPASS:	EQU	$
;
	 IF	USRLOG		;count number of successful login
	DAA
	ACI	40H
	DAA
	PUSH	B
	MVI	C,02H
	MOV	E,A		;output the number
	CALL	BDOS
	POP	B
	RET
	 ENDIF			;USRLOG
;
;
; Welcome to the system
;
WELCOME:EQU	$		;welcome to the system
;
	 IF	CCSDISK
	CALL	DSKON		;turn on the drives
	 ENDIF			;CCSDISK
;
	 IF	CPM2 AND NOT USEZCPR
	MVI	A,MAXUSR	;reset maximum user area
	STA	MXUSR
	STA	MAXUSER
	 ENDIF			;CPM2 AND NOT USEZCPR
;
	 IF	NOT USEZCPR
	MVI	A,MAXDRV	;reset maximum drive
	STA	MXDRV
	DCR	A
	STA	MAXDRIV
	 ENDIF			;NOT USEZCPR
;
	XRA	A		;make sure line feeds are on again
	STA	LFEEDS
;
	 IF	TIMEOUT
	MVI	A,TOVALUE	;reset timeout count
	STA	TOVAL
	 ENDIF			;TIMEOUT
;
	MVI	A,2		;assume this many nulls in case of error
	STA	NULLS
;
	 IF	LGONMSG
	LXI	H,LOGMSG	;Logon message
	CALL	ILPRT		;send this message
	 ENDIF			;LGONMSG
;
GETNULL:LXI	H,NULMSG	;nulls message
	CALL	ILPRT		;send this message
	CALL	MINPUT		;get value
	MOV	C,A		;to 'C' for output
	CALL	MOUTPUT		;echo character
	MOV	A,C		;restore value
	CPI	'0'
	JC	GETNULL		;bad, retry
	CPI	'9'+1
	JNC	GETNULL		;bad, retry
	SUI	'0'		;make binary
	STA	NULLS		;save count
;
GETULC:	LXI	H,CRMSG		;Carriage Return, Line Feed
	CALL	ILPRT		;send this message
;
;
; Print the welcome file
;
	 IF	WELFILE
	LXI	H,WELFILN	;source
	LXI	D,FCB		;destination
	MVI	B,13		;length
	CALL	MOVE		;move the name
	LXI	D,80H		;set DMA address to 80H
	MVI	C,STDMA
	CALL	BDOS
	ENDIF			;WELFILE
;
	 IF	CPM2 AND WELFILE
	MVI	C,32		;set user number for welcome file
	MVI	E,WELUSR
	CALL	BDOS
	 ENDIF			;CPM2 AND WELFILE
;
;
; Open the welcome file
;
	 IF	WELFILE
	LXI	D,FCB
	MVI	C,OPEN
	CALL	BDOS
;
;
; Did it exist?
;
	INR	A		;A=> 0 means "no"
	JZ	PASSINT		;no welcome file
;
;
; Got a file, type it
;
	XRA	A		;A=0
	STA	FCBRNO		;zero record number
	LXI	H,100H		;get initial buffer pointer
;
;
; Type the welcome file
;
WELTYLP:CALL	RDBYTE		;get a byte
	CPI	1AH		;EOF?
	JZ	PASSINT		;yes, done
	MOV	C,A		;setup for type
	CALL	MOUTPUT		;type the character
	CALL	MSTAo log, null PRNLOG routine
;.....
;
;
USRCHK:	CALL	PRNLOG		;give info
	MVI	C,PRINTF
	LXI	D,RS1MSG
	CALL	BDOS		;prompt to resume waiting for ring
;
PRNREL:	CALL	UCSTS		;get reply
	ORA	A
	JZ	PRNREL		;wait until answered
	STA	OPTION		;save reply for later
	CPI	'T'		;is test requested
	JZ	ANSWERB		;go to setup routine
	CPI	'R'		;is answer "r", for resume?
	JZ	PRNRES		;go do it if so
	CPI	'R'+20H		;take lower case too
	JNZ	EXCPM		;if not "r", warm boot CP/M
;
PRNRES:	MVI	C,PRINTF
	LXI	D,RS2MSG
	JMP	BDOS		;resume via BDOS after message
;
;
; Here to exit to CP/M, first reset the Smartmodem to default status
;
EXCPM: CALL	MDQUIT		;return Smartmodem to default settings
;
	 IF	CCSDISK
	CALL	DSKON		;turn on the drives
	 ENDIF			;CCSDISK
;
	MVI	A,0FFH
	STA	WHEEL		;restore wheel byte for SYSOP
	MVI	A,SMAXUSR
	STA	MAXUSER		;and MAXUSR
	MVI	A,SMAXDRV
	STA	MAXDRIV		;and MAXDRIV
	JMP	0000H		;warm boot CP/M
;
;
; BOPLOG increments the 16 bit counter pointer at by HL.  If the decimal
; option is n use, the number is kept as 4 BCD digits.
;
	 IF	USRLOG
BOPLOG:	MOV	A,M		;get low byte
	INR	A		;increment
	 ENDIF			;USRLOG
;
	 IF	USRLOG AND DECIMAL
	DAA			;decimal adjust
	 ENDIF			;USRLOG AND DECIMAL
;
	 IF	USRLOG
	MOV	M,A		;replace low order byte
	RNC			;if no carry, bop done
	INX	H		;  else carry to high order byte
	MOV	A,M		;get high order byte
	INR	A		;  and bop it
	 ENDIF			;USRLOG
;
	 IF	USRLOG AND DECIMAL
	DAA			;decimal adjust
	 ENDIF			;USRLOG AND DECIMAL
;
	 IF	USRLOG
	MOV	M,A		;replace high order byte
	RET
	 ENDIF			;USRLOG
;.....
;
;
	 IF	USRLOG
HXOUT:	PUSH	H		;save pointer
	CALL	HXHAF		;do high order half of #
	POP	H		;restore pointer
	DCX	H		;point to low, then do low half
;
HXHAF:	MOV	A,M		;get half # in a
	MOV	B,A		;save number
	RAR			;rotate right 4 bits
	RAR			;to make an ASCII digit
	RAR
	RAR
	CALL	ONEOUT		;output MSN to console
	MOV	A,B		;get number back
;
ONEOUT:	ANI	0FH		;get LSN for output
	ADI	90H		;convert to decimal ASCIIinue on
	DCR	A		;count time down
	STC			;in case this is the end of 'time'
	RZ			;return if timed out
	PUSH	B		;preserve 'BC'
	MOV	B,A		;get counter value in 'B'
	JMP	CARLP		;keep checking
;
;
; Now test drive #'s and (if CP/M 2.x) user #'s to insure that maximums
; are not exceeded.
;
CARCK2:	EQU	$
;
	 IF	USEZCPR
	LDA	MAXDRIV
	INR	A
	STA	MXDRV
	LDA	MAXUSER
	STA	MXUSR
	 ENDIF			;USEZCPR
;
	 IF	NOT USEZCPR
	LDA	MXDRV
	DCR	A
	STA	MAXDRIV
	LDA	MXUSR
	STA	MAXUSER
	 ENDIF			;NOT USEZCPR
;
	LDA	0004H		;check disk/user #
	ANI	0FH		;isolate drive
	PUSH	H		;save 'HL'
	LXI	H,MXDRV		;point to allowed # of drives
	CMP	M		;valid drive?
	JC	CARCK3		;yes, skip this junk
	LDA	0004H		;get whole login byte
	ANI	0F0H		;retain user # & force drive to A:
	STA	0004H		;update login byte
	LXI	H,IDMSG		;Incorrect Drive Message
	CALL	ILPRT		;tell user what he did
	JMP	0000H		;warm boot
;.....
;
;
CARCK3:	EQU	$
;
	 IF	CPM2
	LDA	0004H		;get login byte
	ANI	0F0H		;isolate user #
	RRC			;move to low bits
	RRC
	RRC
	RRC
	LXI	H,MXUSR		;point to maximum user number
	CMP	M		;valid user #?
	JC	CARCK4		;yes, don't change
	JZ	CARCK4
	LDA	0004H		;get login byte again
	ANI	0FH		;keep drive, zero user area
	STA	0004H		;update login byte
	LXI	H,IUMSG		;Invalid User message
	CALL	ILPRT		;tell him what happened
	JMP	0		;warm boot
	 ENDIF			;CPM2
;
CARCK4:	POP	H		;restore 'HL'
	ORA	A
	RET
;.....
;
;
; .1 sec delay routine
;
DELAY:	PUSH	B
	LXI	B,4167*MHZ	;timing constant * clock MHz
;
DELAY1:	DCX	B
	MOV	A,B
	ORA	C
	JNZ	DELAY1
	POP	B
	RET
;.....
;
;
; 50 milliseconds delay routine
;
KDELAY:	PUSH	B
	LXI	B,2083*MHZ
	JMP	DELAY1
;
;
; Patch in the new JMP table (saving the old)
;
;
PATCH:	CALL	TBLADDR		;HL= CP/M BIOS jump table
	LXI	D,VCOLDBT	;point to save location
	MVI	B,24		;save all vectors
	CALL	MOVE		;move it
	LHLD	VCONOUT+1	;get the original CONOUT address
	SHLD	COVECT		;store for use with XMODEM programs
;
;
; Now move the new JMP table to CP/M
;
	CAo log, null PRNLOG routine
;.....
;
;
USRCHK:	CALL	PRNLOG		;give info
	MVI	C,PRINTF
	LXI	D,RS1MSG
	CALL	BDOS		;prompt to resume waiting for ring
;
PRNREL:	CALL	UCSTS		;get reply
	ORA	A
	JZ	PRNREL		;wait until answered
	STA	OPTION		;save reply for later
	CPI	'T'		;is test requested
	JZ	ANSWERB		;go to setup routine
	CPI	'R'		;is answer "r", for resume?
	JZ	PRNRES		;go do it if so
	CPI	'R'+20H		;take lower case too
	JNZ	EXCPM		;if not "r", warm boot CP/M
;
PRNRES:	MVI	C,PRINTF
	LXI	D,RS2MSG
	JMP	BDOS		;resume via BDOS after message
;
;
; Here to exit to CP/M, first reset the Smartmodem to default status
;
EXCPM: CALL	MDQUIT		;return Smartmodem to default settings
;
	 IF	CCSDISK
	CALL	DSKON		;turn on the drives
	 ENDIF			;CCSDISK
;
	MVI	A,0FFH
	STA	WHEEL		;restore wheel byte for SYSOP
	MVI	A,SMAXUSR
	STA	MAXUSER		;and MAXUSR
	MVI	A,SMAXDRV
	STA	MAXDRIV		;and MAXDRIV
	JMP	0000H		;warm boot CP/M
;
;
; BOPLOG increments the 16 bit counter pointer at by HL.  If the decimal
; option is n use, the number is kept as 4 BCD digits.
;
	 IF	USRLOG
BOPLOG:	MOV	A,M		;get low byte
	INR	A		;increment
	 ENDIF			;USRLOG
;
	 IF	USRLOG AND DECIMAL
	DAA			;decimal adjust
	 ENDIF			;USRLOG AND DECIMAL
;
	 IF	USRLOG
	MOV	M,A		;replace low order byte
	RNC			;if no carry, bop done
	INX	H		;  else carry to high order byte
	MOV	A,M		;get high order byte
	INR	A		;  and bop it
	 ENDIF			;USRLOG
;
	 IF	USRLOG AND DECIMAL
	DAA			;decimal adjust
	 ENDIF			;USRLOG AND DECIMAL
;
	 IF	USRLOG
	MOV	M,A		;replace high order byte
	RET
	 ENDIF			;USRLOG
;.....
;
;
	 IF	USRLOG
HXOUT:	PUSH	H		;save pointer
	CALL	HXHAF		;do high order half of #
	POP	H		;restore pointer
	DCX	H		;point to low, then do low half
;
HXHAF:	MOV	A,M		;get half # in a
	MOV	B,A		;save number
	RAR			;rotate right 4 bits
	RAR			;to make an ASCII digit
	RAR
	RAR
	CALL	ONEOUT		;output MSN to console
	MOV	A,B		;get number back
;
ONEOUT:	ANI	0FH		;get LSN for output
	ADI	90H		;convert to decimal ASCII
	DAA
	ACI	40H
	DAA
	PUSH	B
	MVI	C,02H
	MOV	E,A		;output the number
	CALL	BDOS
	POP	B
	RET
	 ENDIF			;USRLOG
;
;
; Welcome to the system
;
WELCOME:EQU	$		;welcome to the system
;
	 IF	CCSDISK
	CALL	DSKON		;turn on the drives
	 ENDIF			;CCSDISK
;
	 IF	CPM2 AND NOT USEZCPR
	MVI	A,MAXUSR	;reset maximum user area
	STA	MXUSR
	STA	MAXUSER
	 ENDIF			;CPM2 AND NOT USEZCPR
;
	 IF	NOT USEZCPR
	MVI	A,MAXDRV	;reset maximum drive
	STA	MXDRV
	DCR	A
	STA	MAXDRIV
	 ENDIF			;NOT USEZCPR
;
	XRA	A		;make sure line feeds are on again
	STA	LFEEDS
;
	 IF	TIMEOUT
	MVI	A,TOVALUE	;reset timeout count
	STA	TOVAL
	 ENDIF			;TIMEOUT
;
	MVI	A,2		;assume this many nulls in case of error
	STA	NULLS
;
	 IF	LGONMSG
	LXI	H,LOGMSG	;Logon message
	CALL	ILPRT		;send this message
	 ENDIF			;LGONMSG
;
GETNULL:LXI	H,NULMSG	;nulls message
	CALL	ILPRT		;send this message
	CALL	MINPUT		;get value
	MOV	C,A		;to 'C' for output
	CALL	MOUTPUT		;echo character
	MOV	A,C		;restore value
	CPI	'0'
	JC	GETNULL		;bad, retry
	CPI	'9'+1
	JNC	GETNULL		;bad, retry
	SUI	'0'		;make binary
	STA	NULLS		;save count
;
GETULC:	LXI	H,CRMSG		;Carriage Return, Line Feed
	CALL	ILPRT		;send this message
;
;
; Print the welcome file
;
	 IF	WELFILE
	LXI	H,WELFILN	;source
	LXI	D,FCB		;destination
	MVI	B,13		;length
	CALL	MOVE		;move the name
	LXI	D,80H		;set DMA address to 80H
	MVI	C,STDMA
	CALL	BDOS
	ENDIF			;WELFILE
;
	 IF	CPM2 AND WELFILE
	MVI	C,32		;set user number for welcome file
	MVI	E,WELUSR
	CALL	BDOS
	 ENDIF			;CPM2 AND WELFILE
;
;
; Open the welcome file
;
	 IF	WELFILE
	LXI	D,FCB
	MVI	C,OPEN
	CALL	BDOS
;
;
; Did it exist?
;
	INR	A		;A=> 0 means "no"
	JZ	PASSINT		;no welcome file
;
;
; Got a file, type it
;
	XRA	A		;A=0
	STA	FCBRNO		;zero record number
	LXI	H,100H		;get initial buffer pointer
;
;
; Type the welcome file
;
WELTYLP:CALL	RDBYTE		;get a byte
	CPI	1AH		;EOF?
	JZ	PASSINT		;yes, done
	MOV	C,A		;setup for type
	CALL	MOUTPUT		;type the character
	CALL	MSTAT		;check for character typed
	ORA	A
	JZ	WELTYLP		;no, loop
	CALL	MINPUT		;yes, get character
	 ENDIF			;WELFILE
;
	 IF	HOLD AND WELFILE
	CPI	'S'-40H		;CTL-S to delay listing?
	JNZ	WELTYLP		;no, loop until EOF
;
WAIT:	CALL	MSTAT
	ORA	A		;has another char been typed?
	JZ	WAIT		;no, wait
	CALL	MINPUT		;yes, check character
	 ENDIF			;HOLD AND WELFILE
;
	 IF	WELFILE
	CPI	'C'-40H		;CTL-C to end listing?
	JNZ	WELTYLP		;no, loop until eof
	 ENDIF			;WELFILE
;
;
; Get the password
;
PASSINT:EQU	$		;get the password
;
	 IF	PWRQD AND IMSAI	AND SELPASS
	IN	SENSE		;turn the switch up to require password
	ANI	PWDSW
	JZ	NOPASS
	 ENDIF			;PWRQD AND IMSAI AND SELPASS
;
	 IF	PWRQD
	MVI	D,3		;3 tries at password
;
PASSINP:LXI	H,PWMSG		;password message
	CALL	ILPRT		;send this message
	LXI	H,PASSWD	;point to password
	MVI	E,0		;no missed letters
;
PWMLP:	CALL	MINPUT		;get a character
	CPI	60H		;lower case?
	JC	NOTLC		;no,
	ANI	5FH		;make upper case alpha
;
NOTLC:	 ENDIF			;PWRQD
;
	 IF	DUAL$IO	AND PWRQD
	PUSH	PSW		;save character input
	CPI	20H		;is character a control code?
	JNC	PWDIS		;pass if displayable
	MVI	C,'^'		;if control map to up arrow then display
	CALL	CONOUT
	POP	PSW
	PUSH	PSW
	ADI	40H
;
PWDIS:	MOV	C,A
	CALL	CONOUT		;output character locally
	POP	PSW		;restore 'A' reg.
	 ENDIF			;DUAL$IO AND PWRQD
;
	 IF	PWRQD
	CPI	'U'-40H		;CTL-U?
	JZ	PASSINP		;yes, abort, and retry
	CMP	M		;match password?
	JZ	PWMAT
	MVI	E,1		;no, show miss
	CPI	CR		;CR?
	JNZ	PWMLP		;no, wait for CR
;
;
; Password did not match
;
PWNMAT:	LXI	H,WRGMSG	;wrong password message
	CALL	ILPRT		;send this message
	DCR	D		;more tries?
	JNZ	PASSINP		;yes
	JMP	BADPASS		;no, go hang up
;
;
; Character matched in password
;
PWMAT:	INX	H		;to next character
	CPI	CR		;end?
	JNZ	PWMLP		;no, loop
;
;
; End of password.  Any missed chars?
;
	MOV	A,E		;get flag
	ORA	A
	JNZ	PWNMAT		;not right
	 ENDIF			;PWRQD
;
NOPASS:	EQU	$
;
	 IF	USRLOG		;count number of successful logins
	LXI	H,NEWUSR	;get last value
	CALL	BOPLOG		;call routine to add one
	 ENDIF			;USRLOG
;
	 IF	IMSAI AND USRLOG
	LDA	NEWUSR		;re-get low order value
	CMA			;invert for lights
	OUT	SENSE		;display on IMSAI front panel
	 ENDIF			;IMSAI AND USRLOG
;
	 IF	BOOTMSG
	LXI	H,PLSMSG	;please wait message
	CALL	ILPRT		;send this message
	 ENDIF			;BOOTMSG
;
	 IF	COMFILE	AND CPM2
	MVI	C,32
	MVI	E,COMUSR	;switch to .COM file user area
	CALL	BDOS
	 ENDIF			;COMFILE AND CPM2
;
	 IF	COMFILE
	MVI	A,20H		;fool the system so that the .COM file
	STA	FCB+1		;  will see a space at FCB+1 for default
	LDA	OPTION		;  purposes.
	CPI	'A'		;SYSOP can bypass .COM file by typing
	JZ	0000H		;  BYE /A
	CPI	'C'		;SYSOP can also go to .COM file loaded
	JNZ	RUNCOM		;  with BYE /C
	LXI	H,LSMSG		;loading System Message
	CALL	ILPRT		;send this message:
	CALL	LODCOM
;
;
; Everyone else gets com file
;
RUNCOM:	CALL	100H
	 ENDIF			;COMFILE
;
	JMP	0000H		;warm boot now for "normal" CP/M use
;
;
; TSTBAUD attempts to read a CR, LF or CTL-C and returns with zero flag
; if the character read is one of these three.
;
TSTBAUD:CALL	MINPUT		;get character from modem
	CPI	CR		;if a CR
	RZ
	CPI	LF		;if a LF
	RZ
	CPI	'C'-40H		;if a CTL-C
	RET			;return with proper flags set
;.....
;
;
; Test to see if carrier is there.  If after CWAIT seconds, no carrier,
; then return, saying so.  This routine is only called just after we as-
; swered the phone.
;
FRSTCR:	CALL	MDCARCK		;carrier there?
	JNZ	CARCK2		;yes, jump to regular routine
	PUSH	B		;save BC
	MVI	B,CWAIT*10	;set for "cwait" seconds
	JMP	CARLP		;from here on, same as other routine
;
;
; Loss of connection test
;
CARCK:	CALL	MDCARCK		;carrier there?
	JNZ	CARCK2		;yep, go onto other checks...
	PUSH	B		;preserve so we can use it
	MVI	B,CLOSS*10	;set for 'CLOSS' seconds
;
CARLP:	CALL	DELAY		;wait .1 seconds
	CALL	MDCARCK		;check for carrier
	MOV	A,B		;get count back in a
	POP	B		;fix stack in case all is ok
	JNZ	CARCK2		;got carrier, continue on
	DCR	A		;count time down
	STC			;in case this is the end of 'time'
	RZ			;return if timed out
	PUSH	B		;preserve 'BC'
	MOV	B,A		;get counter value in 'B'
	JMP	CARLP		;keep checking
;
;
; Now test drive #'s and (if CP/M 2.x) user #'s to insure that maximums
; are not exceeded.
;
CARCK2:	EQU	$
;
	 IF	USEZCPR
	LDA	MAXDRIV
	INR	A
	STA	MXDRV
	LDA	MAXUSER
	STA	MXUSR
	 ENDIF			;USEZCPR
;
	 IF	NOT USEZCPR
	LDA	MXDRV
	DCR	A
	STA	MAXDRIV
	LDA	MXUSR
	STA	MAXUSER
	 ENDIF			;NOT USEZCPR
;
	LDA	0004H		;check disk/user #
	ANI	0FH		;isolate drive
	PUSH	H		;save 'HL'
	LXI	H,MXDRV		;point to allowed # of drives
	CMP	M		;valid drive?
	JC	CARCK3		;yes, skip this junk
	LDA	0004H		;get whole login byte
	ANI	0F0H		;retain user # & force drive to A:
	STA	0004H		;update login byte
	LXI	H,IDMSG		;Incorrect Drive Message
	CALL	ILPRT		;tell user what he did
	JMP	0000H		;warm boot
;.....
;
;
CARCK3:	EQU	$
;
	 IF	CPM2
	LDA	0004H		;get login byte
	ANI	0F0H		;isolate user #
	RRC			;move to low bits
	RRC
	RRC
	RRC
	LXI	H,MXUSR		;point to maximum user number
	CMP	M		;valid user #?
	JC	CARCK4		;yes, don't change
	JZ	CARCK4
	LDA	0004H		;get login byte again
	ANI	0FH		;keep drive, zero user area
	STA	0004H		;update login byte
	LXI	H,IUMSG		;Invalid User message
	CALL	ILPRT		;tell him what happened
	JMP	0		;warm boot
	 ENDIF			;CPM2
;
CARCK4:	POP	H		;restore 'HL'
	ORA	A
	RET
;.....
;
;
; .1 sec delay routine
;
DELAY:	PUSH	B
	LXI	B,4167*MHZ	;timing constant * clock MHz
;
DELAY1:	DCX	B
	MOV	A,B
	ORA	C
	JNZ	DELAY1
	POP	B
	RET
;.....
;
;
; 50 milliseconds delay routine
;
KDELAY:	PUSH	B
	LXI	B,2083*MHZ
	JMP	DELAY1
;
;
; Patch in the new JMP table (saving the old)
;
;
PATCH:	CALL	TBLADDR		;HL= CP/M BIOS jump table
	LXI	D,VCOLDBT	;point to save location
	MVI	B,24		;save all vectors
	CALL	MOVE		;move it
	LHLD	VCONOUT+1	;get the original CONOUT address
	SHLD	COVECT		;store for use with XMODEM programs
;
;
; Now move the new JMP table to CP/M
;
	CALL	TBLADDR		;HL= CP/M BIOS jump table
	XCHG			;move it to 'DE'
	LXI	H,NEWJTBL	;point to new jump table
	CALL	MOVE		;move it
	RET
;.....
;
;
UNPATCH:CALL	TBLADDR		;HL= CP/M BIOS jump table
	XCHG			;move to DE
	LXI	H,VCOLDBT	;get saved table
	CALL	MOVE		;move original table back
;
	 IF	LOSER
	LXI	H,WMSTRT	;load old call location
	SHLD	WBCALL+1	;restore old call
	 ENDIF			;LOSER
;
	RET
;.....
;
;
; Calculate HL=CP/M's jump table, B=length
;
TBLADDR:LHLD	1		;get BIOS pointer
	DCX	H		;skip to cold boot
	DCX	H
	DCX	H
;
	 IF	(NOT PRINTER) AND (NOT ALLDEV)
	MVI	B,18		;# of bytes to move
	 ENDIF			;(NOT PRINTER) AND (NOT ALLDEV)
;
	 IF	PRINTER		;retain list device?
	MVI	B,15		;don't move lister jump
	 ENDIF			;PRINTER
;
	 IF	ALLDEV		;this patches all devices to phone
	MVI	B,24		;move all jumps
	 ENDIF			;ALLDEV
;
	RET
;.....
;
;
; Move (HL) to (DE), length in (B)
;
MOVE:	MOV	A,M		;get a byte
	STAX	D		;put at new home
	INX	D		;bump pointers
	INX	H
	DCR	B		;decrement byte count
	JNZ	MOVE		;if more, do it
	RET			;if not, return
;.....
;
;
	 IF	LOSER
NWBCALL:CALL	WMSTRT		;warm boot disk read
	CALL	PATCH		;fix BIOS again after WMSTRT
	RET
	 ENDIF			;LOSER
;.....
;
;
; Common routine to check for carrier lost - called from console out
;
CHECK:	EQU	$		;check for carrier lost
;
	 IF	MINICK
	LDA	IOBYTE		;get IOBYTE
	ANI	80H		;test for disk update
	RET			;busy, wait until done
	 ENDIF			;MINICK
;
	 IF	RBBSCK
	LDA	WRTLOC		;get write in progress flag
	ORA	A
	RNZ			;busy, wait until done
	 ENDIF			;RBBSCK
;
	CALL	CARCK		;see if carrier still on
	RNC			;all ok
;
;
; Carrier is lost.  Type message so local console shows the reason.
; Come come here on bad password.
;
BADPASS:MVI	A,1		;show carrier lost - do not check again
	STA	LOSTFLG
	LXI	SP,STACK	;ensure valid stack
	LXI	H,CLMSG		;carrier lost message
	CALL	ILPRT		;Send this Message
;
DROPCAR:LXI	SP,STACK
	CALL	UNPATCH		;restore original BIOS jump table
	XRA	A		;clear out carrier lost flag
	STA	LOSTFLG
;
	 IF	EXFILE
	MVI	C,32
	MVI	E,EXUSR		;switch to exit .COM file user area
	CALL	BDOS
	CALL	LODEX
	CPI	'*'		;test that file was really loaded
	JNZ	100H		;EXITFIL was't loaded, so run it
	 ENDIF			;EXFILE
;
	CALL	UNPATCH
	JMP	HANGUP
;
;
; Readbyte routine - used to read the welcome file
;
	 IF	WELFILE
RDBYTE:	MOV	A,H		;time to read?
	ORA	A		;if at 100H, no read required
	JZ	NORD
;
;
; Have to read a sector
;
	LXI	D,FCB
	MVI	C,READ
	CALL	BDOS
	ORA	A		;ok?
	MVI	A,1AH		;fake up EOF
	RNZ			;return EOF if bad
	LXI	H,80H
;
NORD:	MOV	A,M		;get character
	INX	H		;point to next byte
	RET
	 ENDIF			;WELFILE
;
;
; Keyboard/modem status test routine
;
MSTAT:	EQU	$
;
	 IF	BYELOW
	CALL	BDCHEK		;if BYELOW, set 6 to safety
	 ENDIF			;BYELOW
;
	CALL	CHECK		;check for carrier lost
;
	 IF	DUAL$IO 	;want local console?
	CALL	CONSTAT 	;get local status
	ORA	A
	RNZ			;return if local character
	 ENDIF			;DUAL$IO
;
	CALL	MDINST		;get modem input status
	RET
;.....
;
;
; Modem input function, checks local console first
;
MINPUT:	EQU	$
;
	IF	BYELOW
	CALL	BDCHEK
	 ENDIF			;BYELOW
;
	 IF	RKEYS
	LDA	BYTEB
	ORA	A
	JNZ	CAP
	 ENDIF			;RKEYS
;
	 IF	TIMEOUT
	LDA	TOVAL		;get # of minutes before timeout
;
MINPUT0:STA	TOCNTM		;set minutes counter
	PUSH	H
	LXI	H,MINUTES 	;init one minute timeout counter
	SHLD	TOCNT
	POP	H
	 ENDIF			;TIMEOUT
;
MINPUT1:LDA	LOSTFLG 	;known loss of carrier?
	ORA	A
	CZ	CHECK		;carrier still on?
	CALL	MSTAT		;anything?
	ORA	A
;
	 IF	NOT TIMEOUT
	JZ	MINPUT		;loop til character received
	 ENDIF			;NOT TIMEOUT
;
	 IF	TIMEOUT
	JNZ	MINPUT2
	CALL	KDELAY		;wait 50 ms
	PUSH	H
	LHLD	TOCNT		;knock down timeout counter
	DCX	H
	SHLD	TOCNT
	MOV	A,H
	ORA	L
	POP	H
	JNZ	MINPUT1 	;still time left, keep trying
	LDA	TOCNTM		;count off last minute
	DCR	A
	JNZ	MINPUT0		;go back if time left
	LXI	H,ITOMSG
	CALL	ILPRT
	JMP	NOSLASH
	 ENDIF			;TIMEOUT
;
MINPUT2: IF	DUAL$IO 	;both local and remote
	CALL	CONSTAT 	;check local console
	ORA	A		;character?
	JNZ	CONIN		;yes, read it & return
	 ENDIF			;DUAL$IO
;
; 
; Local console wasn't ready, so read modem
;
	CALL	MDINP
	ANI	7FH		;delete parity
	JZ	MINPUT		;ignore nulls
;
	 IF	HARDLOG
	PUSH	B
	MOV	B,A		;put a copy of the character in b
	LDA	HARDON		;if HARDON=0 then turn HARDLOG off (so
	ORA	A		;..SYSOP does not waste paper while he
	MOV	A,B		;..playing ZORK from work.)
	POP	B
	JZ	NOLOG
;
	CPI	20H
	JNC	MINPUT3
	CPI	CR
	JNZ	NOLOG
;
MINPUT3:CALL	LISTOUT 	;echo on printer
	CPI	CR
	JNZ	NOLOG		;return needs linefeed
	MVI	A,LF
	CALL	LISTOUT 	;so send it
	MVI	A,CR		;get back CR
	 ENDIF			;HARDLOG
;
NOLOG:	 IF	RKEYS
	PUSH	H
	PUSH	D
	PUSH	B
	PUSH	PSW
	CPI	' '
	JNC	NOLOG2
	MOV	E,A		;save char
	ADD	E		;A*3 (3 bytes per table entry)
	ADD	E
	MOV	E,A
	MVI	D,0
	LXI	H,TABLE
	DAD	D
	INX	H		;increment past dummy jump op code
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG
	MOV	A,H
	ORA	L
	JZ	NOLOG2
	SHLD	BYTEA
	MVI	A,1
	STA	BYTEB
	POP	PSW
	POP	B
	POP	D
	POP	H
;
CAP:	PUSH	H
	PUSH	D
	PUSH	B
	LHLD	BYTEA
	MOV	A,M
	INX	H
	SHLD	BYTEA
	ORA	A
	JNZ	NL2
	XRA	A
	STA	BYTEB
	POP	B
	POP	D
	POP	H
	JMP	MINPUT
;
NL2:	POP	B
	POP	D
	POP	H
	JMP	NL22
;
NOLOG2:	POP	PSW
	POP	B
	POP	D
	POP	H
;
NL22:	 ENDIF			;RKEYS
	CPI	3		;is it ^c?
	RNZ			;no, pass it through
	LDA	0		;see if warm boot disabled
	CPI	0C3H		;jump means warm boot ok
	MVI	A,3		;so return with a ^C
	RZ
	MVI	A,CTRLC		;else convert to different character
	RET
;.....
;
;
; Modem output function
;
MOUTPUT:EQU	$
;
	 IF	BYELOW
	CALL	BDCHEK
	 ENDIF			;BYELOW
;
;
; If we already know carrier is lost, do not check for it again or loop
; trying to output.
;
	LDA	LOSTFLG 	;known loss of carrier?
	ORA	A
	JNZ	SILENT		;avoid loop in case carrier lost
	CALL	CHECK		;carrier still on?
;
MOUTA:	CALL	MDOUTST		;check modem output status
	JZ	MOUTA
	MOV	A,C		;get character
	ANI	7FH		;strip parity bit
;
	 IF	OXGATE
	CPI	60H		;check for lower case
	JC	MOUTP2		;skip if not lower case
	CPI	7FH		;check for rubout
	JZ	MOUTP2
	PUSH	H
	LXI	H,ULCSW 	;subtract either 20H or nothing
	SUB	M
	POP	H
	MOV	C,A		;force on local as well as remote
;
MOUTP2:	CPI	LF		;we have a toggle for line feeds
	JNZ	MOUTP3		;nope, not a LF
	LDA	LFEEDS		;yes, see if we can send it...
	ORA	A		;set flags
	MVI	A,0		;prepare with a null
	JNZ	MOUTP3		;nope, don't (instead, send a null)
	MVI	A,LF		;yes, it's ok to send the line feed
;
MOUTP3:  ENDIF			;OXGATE
;
	CALL	MDOUTP		;output character to modem
;
SILENT:	EQU	$
;
	 IF	DUAL$IO 	;to local console too?
	PUSH	PSW		;save character
	CALL	CONOUT		;send to regualr BIOS
	POP	PSW		;get character again
	 ENDIF			;DUAL$IO
;
;
; Check for nulls
;
	CPI	LF		;time for nulls?
	RNZ			;no, return
;
;
; Send nulls if required
;
	LDA	NULLS		;get count
	ORA	A		;any?
	RZ			;no
	PUSH	B
	MOV	B,A		;save count
	MVI	C,0		;0 is a null
;
NULLP:	CALL	MOUTPUT 	;type a null
	DCR	B		;another?
	JNZ	NULLP		;yes, loop
	POP	B
	MVI	C,LF		;now, send a LF
	RET
;.....
;
;
; Boot trap - becomes disconnect if JMP at 0 has been altered
;
MBOOT:	LDA	0		;look at opcode
	CPI	0C3H		;is it still a jmp?
	JNZ	NOSLASH 	;no, so say bye bye...
;
;
; Special warm-boot routine - print a message or something - even run a
; program if you want to!!!
;
WMBMSGPRT:EQU	$
;
	 IF	WBRTN
	PUSH	B
	PUSH	D
	PUSH	H
;
	 IF	PRNTWB
	LXI	H,WBMSG
	CALL	ILPRT		;print the following message:
	 ENDIF			;PRNTWB
;
	POP	H
	POP	D
	POP	B
	 ENDIF			;WBRTN
;
	JMP	VWARMBT		;go do a warm boot
;.....
;
;
; Inline print routine
;
; The following code has been modified to accomodate the automatic
; loader.  (The loader may modify a constant, so all messages have
; been placed at the end of the program and just moved to high memory.)
;
ILPRT:	PUSH	B		;save BC
;
ILPLP:	MOV	C,M		;get character
	CALL	MOUTPUT		;output it
	INX	H		;point to next character
	MOV	A,M		;test for end of message
	ORA	A
	JNZ	ILPLP
	POP	B		;restore BC
	RET			;return past message
;.....
;
;
; Routine to load the com file
;
LODCOM:	EQU	$		;routine to load the .COM file
;
	 IF	COMFILE
	LXI	H,COMFCB
	SHLD	CURRFCB
	XRA	A		;initialize FCB
	STA	COMFCB
	LXI	H,COMFCB+12
	MVI	B,21
	CALL	ZLOOP
	LXI	D,COMFCB
	CALL	OPENFIL
	JZ	ABORT
	JMP	LOADFIL
	 ENDIF			;COMFILE
;
LODEX:	 IF	EXFILE
	LXI	H,EXFCB
	SHLD	CURRFCB
	LXI	H,EXFCB+12
	MVI	B,21
	CALL	ZLOOP
	LXI	D,EXFCB
	CALL	OPENFIL
	MVI	A,'*'		;do not try to run unloaded file
	RZ			;cannot open file, finish BYE hangup
	 ENDIF			;EXFILE
;
;
; Now load the file
;
	 IF	COMFILE	OR EXFILE
LOADFIL:LHLD	6		;get top of memory
	LXI	D,-80H
	DAD	D
	PUSH	H		;save on stack
	LXI	D,80H		;TPA-80H
	LXI	B,0		;keep a record counter
	PUSH	B		;save counter
	PUSH	D		;and load address
;
GLOOP:	POP	D		;get TPA address
	LXI	H,80H		;point to next address to read to
	DAD	D		;HL has the address
	POP	B		;increment the counter
;
;
; Check for load past top-of-memory
;
	POP	D		;get (top-of-memory)
	PUSH	D		;resave for next time
	MOV	A,E		;subtract: (top) - (address)
	SUB	L
	MOV	A,D		;only the carry needed
	SBB	H
	JNC	SIZEOK		;CY=better MOVCPM
	LXI	D,PTSMSG
	JMP	ERRXIT
;
SIZEOK:	INX	B
	PUSH	B
	PUSH	H		;save TPA address
	XCHG			;align registers
	MVI	C,STDMA		;tell BDOS where to put record
	CALL	BDOS
	LHLD	CURRFCB		;point to aprropriate FCB
	XCHG
	MVI	C,READ
	CALL	BDOS
	ORA	A
	JZ	GLOOP		;a=0 if more to read
	POP	B		;unjunk stack
	POP	B		;this is our counter
	POP	H		;more junk on stack
	MOV	A,B		;check for zero
	ORA	C
	JZ	ABORT		;we should have read something
	LXI	D,80H		;we did, reset DMA to 80H
	MVI	C,STDMA
	CALL	BDOS
	LXI	D,CFLMSG
	LDA	OPTION		;see if this was "BYE /C"
	CPI	'C'		;if yes, do not print message
	RZ
	MVI	C,PRINTF
	CALL	BDOS
	RET
;.....
;
;
ZLOOP:	MVI	M,0
	INX	H
	DCR	B
	JNZ	ZLOOP
	RET
;.....
;
;
OPENFIL:MVI	C,OPEN		;open file pointed to by 'DE'
	CALL	BDOS
	INR	A
	RET
;.....
;
;
ABORT:	LXI	D,CNFMSG
;
ERRXIT:	MVI	C,PRINTF
	CALL	BDOS		;print the abort message
	JMP	EXCPM		;warm boot
	 ENDIF			;COMFILE OR EXFFILE
;
;
; This area is used for vectoring calls to the user's CBIOS, but saving
; the registers first in case they are destroyed.
;
CONSTAT:PUSH	B
	PUSH	D
	PUSH	H
	CALL	VCONSTAT
	POP	H
	POP	D
	POP	B
	RET
;.....
;
;
CONIN:	PUSH	B
	PUSH	D
	PUSH	H
	CALL	VCONIN
;
	 IF	FKEYS
	CALL	CKFUNC
	 ENDIF			;FKEYS
;
	POP	H
	POP	D
	POP	B
	RET
;.....
;
;
CKFUNC:	 IF	FKEYS AND IMSAI
	PUSH	B
	MOV	B,A		;save character
	IN	SENSE		;read the switches (tea leaves?)
	ANI	ENABLF		;check function key enable switch
	MOV	A,B		;get character
	POP	B
	RZ			;no function key if switch off
	 ENDIF			;FKEYS AND IMSAI
;
	 IF	FKEYS
	CPI	BLNKKEY		;turn off caller's output for a moment?
	JZ	BLNKTOG		;(this is a toggle)
	CPI	SYSDKEY
	JZ	SYSDOWN		;tell caller to leave in 5 minutes
	CPI	TWITKEY
	JZ	DROPCAR		;hang up on the twit
	CPI	MSGKEY
	RNZ
	LXI	H,MFSMSG	;SYSOP message
	CALL	ILPRT		;tell caller you want to say something
	MVI	A,' '
	RET
;.....
;
;
SYSDOWN:LXI	H,SGDMSG	;system going down message
	CALL	ILPRT		;send this message
	MVI	A,' '
	RET
;.....
;
;
BLNKTOG:LDA	LOSTFLG
	ORA	A		;if zero, make 0FFH
	MVI	A,0FFH		;(we do not use CMA, because LOSTFLG
	JZ	BLNKT1		;  could equal a different value like 1)
	XRA	A		;if not zero, make it zero
;
BLNKT1:	STA	LOSTFLG
	MVI	A,' '
	RET
;
	 ENDIF			;FKEYS
;.....
;
;
CONOUT:	PUSH	B
	PUSH	D
	PUSH	H
	CALL	VCONOUT
	POP	H
	POP	D
	POP	B
	RET
;.....
;
;
LISTOUT:PUSH	B
	PUSH	D
	PUSH	H
	PUSH	PSW
;
	 IF	BYELOW
	CALL	BDCHEK
	 ENDIF			;BYELOW
;
	MOV	C,A
	CALL	VLISTOUT
	POP	PSW
	POP	H
	POP	D
	POP	B
	RET
;.....
;
;
	 IF	BYELOW
BDCHEK:	PUSH	H		;to make truly universal, (???) this
	DB	LXIH		;  program always re-stores the BDOS
;
BDADDR:	DW	0000H		;  pointer at 6&7 set up location for
	SHLD	6		;  beginning address of CONSOLX CTL
				;  at every chance.  This replaces the
	POP	H		;  WMLOCK & OLDBD as in BYE2 AND BYE3
	RET
	 ENDIF			;BYELOW
;.....
;
;
; This is the jmp table which is copied on top of the one pointed to by
; location 1 in CP/M.
;
NEWJTBL:JMP	MCBOOT		;cold boot
	JMP	MBOOT		;warm boot
	JMP	MSTAT		;modem status test
	JMP	MINPUT		;modem input routine
	JMP	MOUTPUT		;modem output routine
;
	 IF	NOT ALLDEV
	RET			;dummy list device
	NOP
	NOP
	 ENDIF			;NOT ALLDEV
;
	 IF	ALLDEV
	JMP	MOUTPUT		;modem list device
	JMP	MOUTPUT		;modem punch device
	JMP	MINPUT		;modem reader device
	 ENDIF			;ALLDEV
;
	 IF CCSDISK
DSKON:	PUSH	PSW		;save 'A' and flags
	MVI	A,DISKON	;turn on motors
	OUT	DISK
	PUSH	H		;now, wait a long time
	LXI	H,0000K
;
DSKLP:	XTHL
	XTHL
	DCX	H		;count loop
	MOV	A,H		;check if done?
	ORA	L
	JNZ	DSKLP
	POP	H		;restore HL
	POP	PSW		;and 'A' and flags
	RET
;
DSKOFF:	PUSH	PSW		;save 'A' and flags
	MVI	A,DISKOFF	;turn motors off
	OUT	DISK
	POP	PSW
	RET
	 ENDIF			;CCSDISK
;.....
;
;
; The 'JMP' instructions in the remote control keys are necesary for the
; relocation routines to relocate the address.
;
	 IF	RKEYS
TABLE:	JMP	0
	JMP	DIR		;^A
	JMP	DIR2		;^B
	JMP	0
	JMP	0
	JMP	0
	JMP	FIND		;^F
	JMP	GBYE		;^G
	JMP	0
	JMP	0
	JMP	0
	JMP	0
	JMP	LTYPE		;^L
	JMP	0
	JMP	0
	JMP	0
	JMP	0
	JMP	0
	JMP	RBBS		;^R
	JMP	0
	JMP	TYPE		;^T
	JMP	0
	JMP	0
	JMP	NEW		;^W
	JMP	0
	JMP	LCRCK		;^Y
	JMP	CRCK		;^Z
	JMP	XMDM		;^[
	JMP	0
	JMP	LDIR		;^]
	JMP	CHAT		;^^
	JMP	0
	 ENDIF			;RKEYS
;.....
;
;
;***********************************************************************
;
;	    $$$$ Smartmodem insert for BYE3 - 01/01/84 $$$$
;
	IF	SMODEM
;
; SWITCH SETTINGS:			1  2  3  4  5  6  7  8
;
;	HAYES Smartmodem 300/1200  --  UP UP DN UP DN UP UP DN
;	US Robotics Auto-Dial 212  --  UP UP UP UP
;
;
; The following routines are patterned after work originally done by Don
; Brown.
;
; Initialize the Smartmodem.  First, disable the auto-answer to prevent
; any problems if somebody phones while you are resetting the registers.
; Then reset the registers for normal unattended operation.
;
SMINIT:	CALL	SET300		;program commences looking for 300 bps
	CALL	SMSEND		;go send smartmodem reset
	DB	'AT Z',CR,0	;reset modem to standard default
	CALL	SMSEND		;go initialize the modem
	DB	'AT Q1 E0 M0 S2=128 S0=2',CR,0
	CALL	DLP		;delay routine
	RET
;...
;
;
; Actually, the above string can vary somewhat (e.g. you may want to
; leave the speaker on, you may want to inhibit codes/text, etc.  Those
; items are all optional.
;
;
;	E0:  Do not echo characters in command state
;
;	M0:  Do not turn the loud speaker on
;
;	S0:  This is the number of times the phone can ring before
;		the SmartModem answers.  A value of 0 means "do not
;		answer."  Once you are ready to receive, S0=2 will
;		let it answer on the second ring.
;.....
;
;
; Delay about two seconds to let modem get stabilized before or after a
; command string.
;
DLP:	MVI	B,20		;wait about two seconds to "be sure"
;
DLP1:	CALL	DELAY
	DCR	B
	JNZ	DLP1
	RET
;.....
;
;
; (This routine is not needed with the current SMINIT routine.)
;
SMANSW: RET
	CALL	SMSEND		;send following message to modem
	DB	'A',CR,0	;answers the phone
	RET
;.....
;
;
; DE-INITIALIZE THE SMARTMODEM
;
; When the operator uses CTL-C followed by anything but "R", this call
; will drop the 'AA' and return the Smartmodem to default settings.
;
SMQUIT:	CALL	SMSEND		;send following message to modem
	DB	'AT Z',CR,0	;reset modem to standard default
	CALL	DLP		;insure command line is completed
	RET
;.....
;
;
; Send a command string to the Smartmodem (similar to ILPRT)
;
SMSEND:	XTHL			;save HL, get address of message
	CALL	DLP		;allow modem to stabilize
	PUSH	B		;save 'BC' registers
;
SMPLP:	CALL	MDOUTST		;modem ready for character?
	JZ	SMPLP		;no, go check again
	MOV	A,M		;get the character
	OUT	DPORT  		;Send the character
	INX	H		;point to next
	MOV	A,M		;Get next character
	ORA	A		;Has all been sent
	JNZ	SMPLP		;no, go send another character
	POP	B		;restore the BC registers
	XTHL
	RET			;return past end of message
;.....
;
;
	ENDIF			;SMODEM
;
;		       End of Smartmodem insert
;***********************************************************************
;
;	  ++++ INSTALL YOUR MODEM CONTROL PATCHES HERE ++++
;
;***********************************************************************
;
;			Zilog Z80-SIO routines
;		Version 1.6 by Steve Fox & Paul Traina
;
; These routines will allow the easy patching of BYE3 for any type of
; modem/serial port combination.  Certain routines must return status
; flags, so please be careful to set the flags as directed.
;
; This version is for the Zilog SIO chip that is hooked up to an extern-
; al modem.  A Z80-CTC is used as the baud rate generator.
;
;-----------------------------------------------------------------------
;
; 11/27/83  Altered and renamed to work with BYE3	- Irv Hoff
; 08/04/83  Updated for use with ByeII version 1.6	- Paul Traina
; 07/19/83  Improved operation of modem initialization.	- Paul Traina
; 04/18/83  Added option to use 300/1200 Smartmodem.	- Don Brown
; 04/14/83  Added option for alt. CTC baud set format.	- Paul Traina
; 02/21/83  Initial version.				- Steve Fox
;
;-----------------------------------------------------------------------
;
;
; Set base port for SIO & CTC chips
;
BASEP:	EQU	 4H		;Base port for SIO
BASEC:	EQU	18H		;Base port for CTC baud rate generator
;
;
; The following define the port addresses to use.
;
DPORT:	EQU	BASEP		;Data port
SPORT:	EQU	BASEP+2		;Status/Control port
BPORT:	EQU	BASEC		;Baud rate port
;
;
; The following are SPORT commands (output these to SPORT)
;
RESCHN:	EQU	00011000B	;Reset channel
RESSTA:	EQU	00010000B	;Reset ext/status
WRREG1:	EQU	00000000B	;Value to write to register 1
WRREG3:	EQU	11000001B	;8 bits/char, Rx enable
WRREG4:	EQU	01000100B	;16x, 1 stop bit, no parity
DTROFF:	EQU	00000000B	;DTR off, RTS off
DTRON:	EQU	11101010B	;DTR on, 8 bits/char, Tx enable, RTS on
ONINS:	EQU	00110000B	;Error reset
;
;
; The following are SPORT status masks
;
DAV:	EQU	00000001B	;Data available
TBMT:	EQU	00000100B	;Transmit buffer empty
DCD:	EQU	00001000B	;Data carrier detect
PE:	EQU	00010000B	;Parity error
OE:	EQU	00100000B	;Overrun error
FE:	EQU	01000000B	;Framing error
ERR:	EQU	PE+OE+FE	;Parity, overrun and framing error
;
;
; First Byte of CTC Command:
;
BDCMD1:	EQU	00H		;110 baud		(timer mode)
BDCMD2:	EQU	40H		;300, 600 & 1200 baud	(counter mode)
;
;
; The following are baud rates for BPORT -- they will have to be changed
; for your particular CTC.
;
BD300:	EQU	05H		;300 bps
;BD600:	EQU	64		;600 bps  (not supported by Smartmodem)
BD1200:	EQU	07H		;1200 bps
;
;
;***********************************************************************
;
; If any of your routines zap anything other than the Accumulator, then
; you must preserve all other registers.
;
;***********************************************************************
;
; This routine should turn off everything on the modem, hang it up, and
; get it ready to wait for a ring.
;
MDINIT:	MVI	A,RESCHN	;Reset channel
	OUT	SPORT
	MVI	A,4		;Setup to write register 4
	OUT	SPORT
	MVI	A,WRREG4
	OUT	SPORT
	MVI	A,1		;Setup to write register 1
	OUT	SPORT
	MVI	A,WRREG1
	OUT	SPORT
	MVI	A,5		;Setup to write register 5
	OUT	SPORT
	MVI	A,DTROFF	;Clear DTR causing hangup
	OUT	SPORT
	PUSH	B		;Save in case it's being used elsewhere
	MVI	B,20		;2 second delay
;
OFFTI:	CALL	DELAY		;0.1 second delay
	DCR	B
	JNZ	OFFTI		;Keep looping until finished
	POP	B		;Restore BC
	MVI	A,3		;Setup to write register 3
	OUT	SPORT
	MVI	A,WRREG3	;Initialize receive register
	OUT	SPORT
	MVI	A,5		;Setup to write register 5
	OUT	SPORT
	MVI	A,DTRON		;turn on DTR so modem can answer phone
	OUT	SPORT
;
	 IF	SMODEM		;If using Hayes 300/1200 Smartmodem
	CALL	SET300		;make sure we are at 300 baud
	CALL	SMINIT		;go initialize Smartmodem now
	 ENDIF			;SMODEM
;
	RET			;Return
;.....
;
;
; The following routine will turn off DTR and the whole mess.  It will
; also tell the Smartmodem to stop answering calls.
;
MDQUIT:	 IF	SMODEM		;if using a Smartmodem
	CALL	SMQUIT		;tell it to shut down
	 ENDIF			;MDQUIT
;
	MVI	A,5		;Setup to write register 5
	OUT	SPORT
	MVI	A,DTROFF	;Clear DTR causing shutdown
	OUT	SPORT
	RET
;.....
;
;
; The following routine will reset the CTC to 300 baud and allow the
; modem to answer the phone when DTR is set True.
;
MDANSW:	CALL	SET300		;Set 300 baud
	IN	DPORT		;Clear out garbage
	IN	DPORT		;Make sure we're clear
	RET			;Return
;
;
; The following routine checks to make sure we still have carrier.  If
; there is no carrier, it will return with the Zero flag set.
;
MDCARCK:MVI	A,RESSTA	;Reset status
	OUT	SPORT
	IN	SPORT		;Get status
	ANI	DCD		;Check for data carrier
	RET			;Return
;
;
; The following routine determines if there is a character waiting to
; be received.  If no character is waiting, the Zero flag will be set,
; otherwise, 255 will be returned in register A.
;
MDINST:	IN	SPORT		;Get status
	ANI	DAV		;Got a character?
	RZ			;Return if none
	ORI	0FFh		;..Otherwise, set the proper flag
	RET			;...and return
;.....
;
;
; The following is a routine that will input one character from the
; modem port.  If there is nothing there, it will return garbage... so
; use the MDINST routine first.
;
MDINP:	IN	DPORT		;Get character
	ANI	7FH		;Strip parity
	RET			;Return
;.....
;
;
; The following is a routine to determine if the transmit buffer is
; empty.  If it is empty, it will return with the Zero flag clear.  If
; the transmitter is busy, then it will return with the Zero flag set.
;
MDOUTST:IN	SPORT
	ANI	TBMT		;Mask it
	RET			;Return
;.....
;
;
; The following is a routine that will output one character in register
; A to the modem.  REMEMBER, that is register A, not register C.
;
; **** Use MDOUTST first to see if buffer is empty ****
;
MDOUTP:	OUT	DPORT		;Send it
	RET			;Return
;.....
;
;
; These next routines set the proper baud rates for the modem.  If you
; do not support the particular rate, then simply put the label in front
; of the SETINV routine.  If the baud rate change was successful, make
; SURE the Zero flag is set.
;
;
; Set up for 300 bps
;
SET300:	MVI	A,BD300		;Load rate
;	PUSH	PSW		;..store it
;	MVI	A,BDCMD1	;Get first byte of command
	JMP	SETBAUD
;.....
;
;
; Set up for 1200 bps
;
SET1200:MVI	A,BD1200	;Load rate
;	PUSH	PSW		;..save it
;	MVI	A,BDCMD2	;Get first byte of command
	JMP	SETBAUD
;.....
;
;
SETBAUD:OUT	BDCMD1		;Send first byte of command
;	POP	PSW		;Restore the rate
;	OUT	BPORT		;Send rate
 	XRA	A		;Say rate is OK
	RET			;Return
;.....
;
;
; The following routine returns a 255 because we were not able to set to
; the proper baud rate because either the serial port or the modem can't
; handle it.
;
SET110:	DS	0		;110 baud not supported
SET450:	DS	0		;450 baud not supported
SET600:	DS	0		;600 baud not supported
SET710:	DS	0		;710 baud not supported
;
SETINV:	ORI	0FFH		;Make sure zero flag is not set
	RET			;Return
;.....
;
;
; Ok, that's all of the modem dependant routines that BYE3 uses, so if
; you patch this file into your copy of BYE3, then it should work out
; well.
;

;***********************************************************************
;
;
ENDOBJ:	EQU	$
;
	 IF	RKEYS
CHAT:	DB	'CHAT',0
CHEK	DB	'CHEK ',0
DIR:	DB	'DIR',CR,0
DIR2:	DB	'DIR *.* $',0
FILE:	DB	'FILE ',0
GBYE:	DB	'BYE',0
LDIR:	DB	'LDIR ',0
LTYPE:	DB	'LTYPE ',0
NEW:	DB	'WHATSNEW',0
RBBS:	DB	'RBBS',0
TYPE:	DB	'TYPE ',0
XMDM:	DB	'XMODEM ',0
	 ENDIF			;RKEYS
;
;-----------------------------------------------------------------------
;
; Program version number message.
;
VMSG:	DB	CR,LF,'<<<< BYE3 >>>> Micro Cornucopia Magazine',CR,LF,'$'
;
NULMSG:	DB	CR,LF,'Nulls, if needed, (0-9)? ',0
;
CRMSG:	DB	CR,LF,CR,LF,0
;
	 IF	PRNTGB
GBMSG:	DB	CR,LF,'  Good-bye, call again...'
	DB	CR,LF,CR,LF,0
	 ENDIF			;PRNTGB
;
RS1MSG:	DB	CR,LF,'Type "R" to resume, anything else to '
	DB	'warm boot: $'
;
RS2MSG:	DB	1AH,'Resuming...',CR,LF,'$'
;
	 IF	USRLOG AND PWRQD
ATMSG:	DB	CR,LF,'Number of logon attempts: $'
	 ENDIF			;USRLOG AND PWRQD
;
	 IF	USRLOG
SUMSG:	DB	CR,LF,'Number of logons: $'
	 ENDIF			;USRLOG
;
	 IF	USRLOG AND CALLBAK
VCMSG:	DB	CR,LF,'Number of voice calls: $'
	 ENDIF			;USRLOG AND CALLBAK
;
	 IF	LGONMSG
LOGMSG:	DB	'Baudrate determined by your input (300/1200 bps)',CR,LF
	DB	'Send several C/R''s to set baudrate....',CR,LF,0
	 ENDIF			;LGOMSG
;
;
; Access password (ends in carriage return) - keep password here
;
	 IF	PWRQD
PASSWD:	DB	'MICRO C'	;the password itself
	DB	CR		;end of password, CR-only to erase it
;
;
; (Allow room for larger password to be entered)
;
	DB	0,0,0
;
PWMSG:	DB	CR,LF,'Enter Password: ',0
WRGMSG:	DB	'Incorrect password',CR,LF,0
	 ENDIF			;PWRQD
;
	 IF	BOOTMSG
PLSMSG:	DB	CR,LF
	DB	'Please Wait... ' ;boot message goes here
	DB	CR,LF,0
	 ENDIF			;BOOTMSG
;
	 IF	COMFILE
LSMSG:	DB	'Loading system...',CR,LF,0
	 ENDIF			;COMFILE
;
IDMSG:	DB	'++ Invalid drive, returning to A: ++',0
;
	 IF	CPM2
IUMSG:	DB	'++ Invalid user number, returning to 0 ++',0
	 ENDIF			;CPM2
;
CLMSG:	DB	CR,LF,'[Carrier Lost]',CR,LF,0
;
	 IF	TIMEOUT
ITOMSG:	DB	'[Input timed out]',7,0
	 ENDIF			;TIMEOUT
;
	 IF	FKEYS
MFSMSG:	DB	'Message from Sysop:',0
SGDMSG:	DB	'System is going down....'
	DB	'please use BYE to log-off, thank you',0
	 ENDIF			;FKEYS
;
LFMSG:	DB	CR,LF,CR,LF,0
;
	 IF	PRNTWB
WBMSG:	DB	CR,LF,'Booting CP/M...            ',CR,LF
	DB	0
	 ENDIF			;PRNTWB
;
	 IF	COMFILE	OR EXFILE
PTSMSG:	DB	'++ Program area too small! ++',7,'$'
CNFMSG:	DB	CR,LF
	DB	'++ Cannot find .COM file ++',7,'$'
CFLMSG:	DB	CR,LF,'[ COM file loaded ]',CR,LF,'$'
	 ENDIF			;COMFILE OR EXFILE
;
	 IF	WELFILE
WELFILN:DB	0,'WELCOME    '	;welcome file name, must be 11 chars.
	DB	0
	 ENDIF
;
	 IF	COMFILE
COMFCB:	DB	0,'RBBS    COM'	;.COM file name, must be 11 chars.
	DS	21		;rest of .COM FCB
	 ENDIF			;COMFILE
;
	 IF	EXFILE
EXITFCB:DB	1,'        COM'	;exit filename, must be 11 chars.
	DS	21		;rest of exit fcb
	 ENDIF			;EXFILE
;
;
; These areas are not initialized
;
PEND:	EQU	$		;The following area is not initialized
;
	 IF	COMFILE	OR EXFILE
CURRFCB:DS	2
	 ENDIF			;COMFILE OR EXFILE
;
OPTION:	DS	1
TOCNTM:	DS	1
TOCNT:	DS	2
;
;
; Save the CP/M jump table here
;
VCOLDBT: DS	3
VWARMBT: DS	3
VCONSTAT:DS	3
VCONIN:	 DS	3
VCONOUT: DS	3
VLISTOUT:DS	3
VPUNCH:	 DS	3
VREADER: DS	3
;
;
; Since these areas are not initialized, the following counters will not
; be changed by subsequent loads of this program
;
	 IF	USRLOG
OLDUSR:	DS	2
NEWUSR:	DS	2
NONUSR:	DS	2
	 ENDIF			;USRLOG
;
	 IF	RKEYS
BYTEA:	DW	0
BYTEB:	DB	0
	 ENDIF			;RKEYS
;
	DS	60
STACK:	EQU	$		;local stack
OBJEND:	EQU	$
;.....
;
;
	END
