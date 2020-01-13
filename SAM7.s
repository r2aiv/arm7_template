;/*****************************************************************************/
;/* SAM7.S: Startup file for Atmel AT91SAM7 device series                     */
;/*****************************************************************************/
;/* <<< Use Configuration Wizard in Context Menu >>>                          */ 
;/*****************************************************************************/
;/* This file is part of the uVision/ARM development tools.                   */
;/* Copyright (c) 2005-2006 Keil Software. All rights reserved.               */
;/* This software may only be used under the terms of a valid, current,       */
;/* end user licence from KEIL for a compatible version of KEIL software      */
;/* development tools. Nothing else gives you the right to use this software. */
;/*****************************************************************************/


;/*
; *  The SAM7.S code is executed after CPU Reset. This file may be 
; *  translated with the following SET symbols. In uVision these SET 
; *  symbols are entered under Options - ASM - Define.
; *
; *  REMAP: when set the startup code remaps exception vectors from
; *  on-chip RAM to address 0.
; *
; *  RAM_INTVEC: when set the startup code copies exception vectors 
; *  from on-chip Flash to on-chip RAM.
; */

                GET util.s
				
                AREA    STACK, NOINIT, READWRITE, ALIGN=3

Stack_Mem       SPACE   USR_Stack_Size
__initial_sp    SPACE   ISR_Stack_Size
Stack_Top

Task1_Stack_Mem	SPACE	0x00000100
Tasl1_Stack_Top

Task2_Stack_Mem	SPACE	0x00000100
Tasl2_Stack_Top

Task3_Stack_Mem	SPACE	0x00000100
Tasl3_Stack_Top


                AREA    HEAP, NOINIT, READWRITE, ALIGN=3
__heap_base
Heap_Mem        SPACE   Heap_Size
__heap_limit


                PRESERVE8
                
				
				AREA    DATA, DATA, READONLY, ALIGN=3
                ;AREA    DATA, DATA, READWRITE, ALIGN=3
Msg         DCB     "Hello from program body", 10, 13, 0
IRQMsg		DCB		"Hello from IRQ", 10, 13, 0
CRLF        DCB     10, 13, 0
                PRESERVE8
                    
                AREA    Var, DATA, READWRITE, ALIGN=3
CommonCounter   DCB     0
Task1Counter    DCB     0
Task2Counter    DCB     0
Task3Counter    DCB     0
                PRESERVE8

                ;AREA    DATA, DATA, READWRITE, ALIGN=3
;IRQ_Cnt     DCB     123
;                PRESERVE8


; Area Definition and Entry Point
;  Startup Code must be linked first at Address at which it expects to run.

                AREA    RESET, CODE, READONLY
                ARM


; Exception Vectors
;  Mapped to Address 0.
;  Absolute addressing mode must be used.
;  Dummy Handlers are implemented as infinite loops which can be modified.

Vectors         LDR     PC,Reset_Addr         
                LDR     PC,Undef_Addr
                LDR     PC,SWI_Addr
                LDR     PC,PAbt_Addr
                LDR     PC,DAbt_Addr
                NOP                            ; Reserved Vector
;               LDR     PC,IRQ_Addr
                LDR     PC,[PC,#-0xF20]        ; Vector From AIC_IVR
;               LDR     PC,FIQ_Addr
                LDR     PC,[PC,#-0xF20]        ; Vector From AIC_FVR

Reset_Addr      DCD     Reset_Handler
Undef_Addr      DCD     Undef_Handler
SWI_Addr        DCD     SWI_Handler
PAbt_Addr       DCD     PAbt_Handler
DAbt_Addr       DCD     DAbt_Handler
                DCD     0                      ; Reserved Address
IRQ_Addr        DCD     IRQ_Handler
FIQ_Addr        DCD     FIQ_Handler

Undef_Handler   B       Undef_Handler
SWI_Handler     B       SWI_Handler
PAbt_Handler    B       PAbt_Handler
DAbt_Handler    B       DAbt_Handler


IRQ_Handler     
                B       Timer_IRQ


FIQ_Handler     B       FIQ_Handler


; Reset Handler

                EXPORT  Reset_Handler
Reset_Handler   


; Setup PMC
                IF      PMC_SETUP != 0
                LDR     R0, =PMC_BASE

;  Setup Main Oscillator
                LDR     R1, =PMC_MOR_Val
                STR     R1, [R0, #PMC_MOR]

;  Wait until Main Oscillator is stablilized
                IF      (PMC_MOR_Val:AND:PMC_MOSCEN) != 0
MOSCS_Loop      LDR     R2, [R0, #PMC_SR]
                ANDS    R2, R2, #PMC_MOSCS
                BEQ     MOSCS_Loop
                ENDIF

;  Setup the PLL
                IF      (PMC_PLLR_Val:AND:PMC_MUL) != 0
                LDR     R1, =PMC_PLLR_Val
                STR     R1, [R0, #PMC_PLLR]

;  Wait until PLL is stabilized
PLL_Loop        LDR     R2, [R0, #PMC_SR]
                ANDS    R2, R2, #PMC_LOCK
                BEQ     PLL_Loop
                ENDIF

;  Select Clock
                IF      (PMC_MCKR_Val:AND:PMC_CSS) == 1     ; Main Clock Selected
                LDR     R1, =PMC_MCKR_Val
                AND     R1, #PMC_CSS
                STR     R1, [R0, #PMC_MCKR]
WAIT_Rdy1       LDR     R2, [R0, #PMC_SR]
                ANDS    R2, R2, #PMC_MCKRDY
                BEQ     WAIT_Rdy1
                LDR     R1, =PMC_MCKR_Val
                STR     R1, [R0, #PMC_MCKR]
WAIT_Rdy2       LDR     R2, [R0, #PMC_SR]
                ANDS    R2, R2, #PMC_MCKRDY
                BEQ     WAIT_Rdy2
                ELIF    (PMC_MCKR_Val:AND:PMC_CSS) == 3     ; PLL  Clock Selected
                LDR     R1, =PMC_MCKR_Val
                AND     R1, #PMC_PRES
                STR     R1, [R0, #PMC_MCKR]
WAIT_Rdy1       LDR     R2, [R0, #PMC_SR]
                ANDS    R2, R2, #PMC_MCKRDY
                BEQ     WAIT_Rdy1
                LDR     R1, =PMC_MCKR_Val
                STR     R1, [R0, #PMC_MCKR]
WAIT_Rdy2       LDR     R2, [R0, #PMC_SR]
                ANDS    R2, R2, #PMC_MCKRDY
                BEQ     WAIT_Rdy2
                ENDIF   ; Select Clock
                ENDIF   ; PMC_SETUP


; Copy Exception Vectors to Internal RAM

                IF      :DEF:RAM_INTVEC
                ADR     R8, Vectors         ; Source
                LDR     R9, =RAM_BASE       ; Destination
                LDMIA   R8!, {R0-R7}        ; Load Vectors 
                STMIA   R9!, {R0-R7}        ; Store Vectors 
                LDMIA   R8!, {R0-R7}        ; Load Handler Addresses 
                STMIA   R9!, {R0-R7}        ; Store Handler Addresses
                ENDIF


; Remap on-chip RAM to address 0

MC_BASE EQU     0xFFFFFF00      ; MC Base Address
MC_RCR  EQU     0x00            ; MC_RCR Offset

                IF      :DEF:REMAP
                LDR     R0, =MC_BASE
                MOV     R1, #1
                STR     R1, [R0, #MC_RCR]   ; Remap
                ENDIF


; Setup Stack for each mode

                LDR     R0, =Stack_Top

;  Enter Undefined Instruction Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_UND:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #UND_Stack_Size

;  Enter Abort Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_ABT:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #ABT_Stack_Size

;  Enter FIQ Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_FIQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #FIQ_Stack_Size

;  Enter IRQ Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #IRQ_Stack_Size

;  Enter Supervisor Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_SVC:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #SVC_Stack_Size

;  Enter User Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_USR
                IF      :DEF:__MICROLIB

                EXPORT __initial_sp

                ELSE

                MOV     SP, R0
                SUB     SL, SP, #USR_Stack_Size

                ENDIF


; ----------------------ТОЧКА ВХОДА ЗДЕСЬ!!!-----------------------
				
ENTRYPOINT      


; Включение тактирования PIOA
				LDR		R0, =PMC_BASE
				MOV 	R1, #1
				LSL 	R1, #2
				STR 	R1, [R0, #PMC_PCER]

; Включение тактирования PIOB
				LDR     R0, =PMC_BASE
                MOV     R1, #1
				LSL		R1, #3
                STR     R1, [R0, #PMC_PCER]

; PA0 - USART0_RX, PA1 - USART0_TX
				LDR 	R0, =PIOA_BASE
				MOV 	R1, #3				
				STR		R1, [R0, #PIO_ASR]
				STR		R1, [R0, #PIO_PDR]
				STR		R1, [R0, #PIO_ODR]
				STR		R1, [R0, #PIO_IFDR]
				STR		R1, [R0, #PIO_CODR]
				
; Включение PB20 на выход
				LDR R0, =PIOB_BASE
				MOV R1, #1
				LSL R1, #20
				STR R1, [R0, #PIO_OER]
				
; Тактирование USART0
				LDR     R0, =PMC_BASE
                MOV     R1, #1
				LSL		R1, #6
                STR     R1, [R0, #PMC_PCER]


; Настройка USART0

				LDR		R0, =USART0_BASE
				MOV 	R1, #0xAC ; Сброс и запрет
				STR		R1, [R0, #USART_CR]

				LDR		R0, =USART0_BASE
				MOV     R1, #0xFFFFFFFF
				STR 	R1, [R0, #USART_IDR]

				LDR		R0, =USART0_BASE
				MOV 	R1, #3
				LSL		R1, #6
				MOV		R2, #4
				LSL		R2, #9
				ORR 	R1, R2
				STR		R1, [R0, #USART_MR]
				
				; 115200
				LDR 	R0, =USART0_BASE
				MOV 	R1, #26				
				STR 	R1, [R0, #USART_BRGR]
				
				LDR 	R0, =USART0_BASE
				MOV 	R1, #5
				LSL 	R1, #4
				STR		R1, [R0, #USART_CR]
                
                ; Timer IRQ setup
                LDR     R0, =AIC_BASE
                LDR     R1, =IRQ_Handler
                STR     R1, [R0, #AIC_SVR1] ; Setup SYS (01) IRQ Vector
                
                LDR     R0, =AIC_BASE
                MOV     R1, #1
                LSL     R1, #5
                STR     R1, [R0, #AIC_SMR1]
                
                MOV     R1, #0x02 ; Setup mask for SYS IRQ
                STR     R1, [R0, #AIC_IECR]
                
                ; Initialize timer and enable timer IRQ
				
				MOV R1, #3
                LSL R1, #24
                LDR R0, =PIT_BASE
                ;LDR R2, [R0, #PIT_MR]
                MOV R2, #1
                LSL R2, #16
                ORR R2, R1
                STR R2, [R0, #PIT_MR]

                
FOREVER

;; Включение подсветки LCD
				LDR R0, =PIOB_BASE
				MOV R1, #1
				LSL R1, #20
				STR R1, [R0, #PIO_SODR]
												
				BL BLINKDELAY
				
;; Выключение подсветки LCD
				LDR R0, =PIOB_BASE
				MOV R1, #1
				LSL R1, #20
				STR R1, [R0, #PIO_CODR]
				
				;MOV R2, #'A'
				;BL UART_SEND_CHR
				LDR R0, =Msg
				BL UART_SEND_STR
				
				BL BLINKDELAY

				B FOREVER
				
                
Timer_IRQ

				; Save Current state to stack
				SUB LR, LR, #4
				STMFD SP!, {R0-R12, LR}
				                
                LDR R0, =CommonCounter
                LDR R1, [R0]
                ADD R1, #1
                STR R1, [R0]
                
                MOV R2, R1
                BL WRITE_BYTE_HEX
                
                LDR R0, =CRLF
				BL UART_SEND_STR
                
                ; Dummy read PIT to clear it's IRQ
                LDR R0, =PIT_BASE
                LDR R1, [R0, #PIT_PIVR]
                
                ; Clear interrupt in AIC
                LDR R0, =AIC_BASE
                MOV R1, #0x02                
                STR R1, [R0, #AIC_ICCR]
                STR R1, [R0, #AIC_EOICR]

				; Restore state from stack and set User mode
				LDMFD SP!,{R0-R12, PC}^
                
                END
                    

