                GET util.s

; ������������� �����
                AREA    STACK, NOINIT, READWRITE, ALIGN=3

Stack_Mem       SPACE   USR_Stack_Size
__initial_sp    SPACE   ISR_Stack_Size
Stack_Top

                PRESERVE8
                
; ������������� ���������� ������ ��� ������				
				AREA    DATA, DATA, READONLY, ALIGN=3                
Msg         	DCB     "Hello from program body", 10, 13, 0
IRQMsg			DCB		"Hello from IRQ", 10, 13, 0
CRLF        	DCB     10, 13, 0

Task1Msg		DCB		"TASK1: ", 0
Task2Msg		DCB		"TASK2: ", 0
Task3Msg		DCB		"TASK3: ", 0
TaskCntrMsg		DCB		"Task own counter: ", 0
CommonCntrMsg	DCB		"Common task counter: ", 0

                PRESERVE8
                    
; ������������� ���������� ��� ������ � ������
                AREA    Var, DATA, READWRITE, ALIGN=3
CommonCounter   DCQ     0
Task1Counter    DCQ     0
Task2Counter    DCQ     0
Task3Counter    DCQ     0
NextTaskNumber	DCQ		1
                PRESERVE8


; ����� ����� � ���������. 

                AREA    RESET, CODE, READONLY
                ARM


; ������� ���������� � ����������
; ���������������� ������� ��������� � ���� ����������� ������

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

; ������ ���������� ���������� �������
IRQ_Handler     B       Timer_IRQ


FIQ_Handler     B       FIQ_Handler


; ������ ���������� �� ������ (�� ���� - ����� ����� � ���������)

                EXPORT  Reset_Handler
Reset_Handler   


; ��������� ������������
                IF      PMC_SETUP != 0
                LDR     R0, =PMC_BASE

; ��������� ��������� ��������� ����������
                LDR     R1, =PMC_MOR_Val
                STR     R1, [R0, #PMC_MOR]

; ����, ���� �������� ��������� ���������������
                IF      (PMC_MOR_Val:AND:PMC_MOSCEN) != 0
MOSCS_Loop      LDR     R2, [R0, #PMC_SR]
                ANDS    R2, R2, #PMC_MOSCS
                BEQ     MOSCS_Loop
                ENDIF

; ��������� ���� (������� - 95.8464 ���)
                IF      (PMC_PLLR_Val:AND:PMC_MUL) != 0
                LDR     R1, =PMC_PLLR_Val
                STR     R1, [R0, #PMC_PLLR]

; ����, ���� ���� ���������������
PLL_Loop        LDR     R2, [R0, #PMC_SR]
                ANDS    R2, R2, #PMC_LOCK
                BEQ     PLL_Loop
                ENDIF

; ��������� ������������
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


; ����������� ������� ����������/���������� �� ���������� ����

                IF      :DEF:RAM_INTVEC
                ADR     R8, Vectors         ; ��������
                LDR     R9, =RAM_BASE       ; ��������
                LDMIA   R8!, {R0-R7}        ; �������� ��������
                STMIA   R9!, {R0-R7}        ; ���������� ��������
                LDMIA   R8!, {R0-R7}        ; �������� ������������
                STMIA   R9!, {R0-R7}        ; ���������� ������������
                ENDIF


; ���������� ���� ������������ �� ����� 0

MC_BASE EQU     0xFFFFFF00      ; MC Base Address
MC_RCR  EQU     0x00            ; MC_RCR Offset

                IF      :DEF:REMAP
                LDR     R0, =MC_BASE
                MOV     R1, #1
                STR     R1, [R0, #MC_RCR]   ; Remap
                ENDIF


; ��������� ������ ��� ���� ������� ����������

                LDR     R0, =Stack_Top

;  ���� � ����� "������������ ����������" � ��������� ��� ��������� �����
                MSR     CPSR_c, #Mode_UND:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #UND_Stack_Size

;  �� ��, ��� ������ Abort
                MSR     CPSR_c, #Mode_ABT:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #ABT_Stack_Size

;  �� ��, ��� ������ ������ � ���������� FIQ
                MSR     CPSR_c, #Mode_FIQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #FIQ_Stack_Size

;  �� ��, ��� ������ ������ � ���������� IRQ
                MSR     CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #IRQ_Stack_Size

;  �� ��, ��� ������ Supervisor
                MSR     CPSR_c, #Mode_SVC:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #SVC_Stack_Size

;  �� ��, ��� ������ ���������� ��������� ������������
                MSR     CPSR_c, #Mode_USR
                IF      :DEF:__MICROLIB

                EXPORT __initial_sp

                ELSE

                MOV     SP, R0
                SUB     SL, SP, #USR_Stack_Size

                ENDIF


; ----------------------������ �������� ����--------------------------
				
ENTRYPOINT      

; ��������� ������������ PIOA
				LDR		R0, =PMC_BASE
				MOV 	R1, #1
				LSL 	R1, #2
				STR 	R1, [R0, #PMC_PCER]

; ��������� ������������ PIOB
				LDR     R0, =PMC_BASE
                MOV     R1, #1
				LSL		R1, #3
                STR     R1, [R0, #PMC_PCER]

; ��������� ������������������� ������� PIOA.1 ��� ������ � USART0
				LDR 	R0, =PIOA_BASE
				MOV 	R1, #3				
				STR		R1, [R0, #PIO_ASR]
				STR		R1, [R0, #PIO_PDR]
				STR		R1, [R0, #PIO_ODR]
				STR		R1, [R0, #PIO_IFDR]
				STR		R1, [R0, #PIO_CODR]
				
; ��������� PB20 �� ����� (��������� LCD)
				LDR R0, =PIOB_BASE
				MOV R1, #1
				LSL R1, #20
				STR R1, [R0, #PIO_OER]
				
; ��������� ������������ USART0
				LDR     R0, =PMC_BASE
                MOV     R1, #1
				LSL		R1, #6
                STR     R1, [R0, #PMC_PCER]


; ��������� USART0

				; ����� ����������� UART
				LDR		R0, =USART0_BASE
				MOV 	R1, #0xAC 
				STR		R1, [R0, #USART_CR]

				; ���������� ������ ����������
				LDR		R0, =USART0_BASE
				MOV     R1, #0xFFFFFFFF
				STR 	R1, [R0, #USART_IDR]
				
				; ����� ������: 8 ���, 1 �������� ���, ��� ���� ��������
				LDR		R0, =USART0_BASE
				MOV 	R1, #3
				LSL		R1, #6
				MOV		R2, #4
				LSL		R2, #9
				ORR 	R1, R2
				STR		R1, [R0, #USART_MR]
				
				; �������� ������: 115200 ���
				LDR 	R0, =USART0_BASE
				MOV 	R1, #26				
				STR 	R1, [R0, #USART_BRGR]
				
				LDR 	R0, =USART0_BASE
				MOV 	R1, #5
				LSL 	R1, #4
				STR		R1, [R0, #USART_CR]
                
                ; ��������� ���������� �� ���������� ������� PIT
				; ����� AIC-���������� ���������� ������������ �� ����� IRQ ����
				; � ������� ������� ���������� AIC ������������ ����� �����������
				; ���������� �������
				; � AT91SAM7X256 ���������� ������� ��������� ���������
				; � AIC ��� ��������� ���������� ������� ����� 1
				
                LDR     R0, =AIC_BASE
                LDR     R1, =IRQ_Handler
                STR     R1, [R0, #AIC_SVR1] 
                
				; ��������� ������ ������� ����� ����������
				; �� ����������� ������ ������� (��� 5)
                LDR     R0, =AIC_BASE
                MOV     R1, #1
                LSL     R1, #5
                STR     R1, [R0, #AIC_SMR1]
                
				; ���������� ���������� ���������� � AIC
                MOV     R1, #0x02
                STR     R1, [R0, #AIC_IECR]
                
                ; ������������� ������� � ���������� ������ ���������� � AIC
				MOV R1, #3
                LSL R1, #24
                LDR R0, =PIT_BASE
				
                ; �������� ������������ �������: 0x010000 (65536)
				; ����� ������� ������������� ���������� �����: 
				; 95.8464 ���/65536 = 1.762 ���
                MOV R2, #1
                LSL R2, #16				
                ORR R2, R1
                STR R2, [R0, #PIT_MR]
				
				;LDR R0, =NextTaskNumber
				;MOV R1, #1
				;STR R1, [R0]

; ����������� ���� - ������ ������ ���������� LCD � ������� ���������
FOREVER

; ��������� ��������� LCD
				LDR R0, =PIOB_BASE
				MOV R1, #1
				LSL R1, #20
				STR R1, [R0, #PIO_SODR]
												
				BL BLINKDELAY
				
; ���������� ��������� LCD
				LDR R0, =PIOB_BASE
				MOV R1, #1
				LSL R1, #20
				STR R1, [R0, #PIO_CODR]
				
				LDR R0, =Msg
				BL UART_SEND_STR				
				BL BLINKDELAY
				B FOREVER
				
Task1_Proc		PROC
				PUSH {LR}
				PUSH {R0}
				PUSH {R1}
				
				BL DisablePIT
								
				; �������� �������� ��������� � UART
				LDR R0, =Task1Msg
				BL UART_SEND_STR
				
				MOV R2, #' '
				BL UART_SEND_CHR
				
				LDR R0, =CommonCntrMsg
				BL UART_SEND_STR
				
				LDR R0, =CommonCounter
                LDR R1, [R0]
                MOV R2, R1
                BL WRITE_BYTE_HEX
				
				MOV R2, #' '
				BL UART_SEND_CHR
				
				LDR R0, =TaskCntrMsg
				BL UART_SEND_STR
				
				LDR R0, =Task1Counter
                LDR R1, [R0]
                MOV R2, R1
                BL WRITE_BYTE_HEX
                
                LDR R0, =CRLF
				BL UART_SEND_STR

				; ����������� ��������
				LDR R0, =CommonCounter
				LDR R1, [R0]
				ADD R1, #1
				STR R1, [R0]
				
				LDR R0, =Task1Counter
				LDR R1, [R0]
				ADD R1, #1
				STR R1, [R0]
				
				BL EnablePIT
				
				POP {R1}
				POP {R0}
				POP {PC}
				ENDP
					
Task2_Proc		PROC	
	
				PUSH {LR}
				PUSH {R0}
				PUSH {R1}
				
				BL DisablePIT	
				
				LDR R0, =Task2Msg
				BL UART_SEND_STR
				
				MOV R2, #' '
				BL UART_SEND_CHR
				
				LDR R0, =CommonCntrMsg
				BL UART_SEND_STR
				
				LDR R0, =CommonCounter
                LDR R1, [R0]
                MOV R2, R1
                BL WRITE_BYTE_HEX
				
				MOV R2, #' '
				BL UART_SEND_CHR
				
				LDR R0, =TaskCntrMsg
				BL UART_SEND_STR
				
				LDR R0, =Task2Counter
                LDR R1, [R0]
                MOV R2, R1
                BL WRITE_BYTE_HEX
                
                LDR R0, =CRLF
				BL UART_SEND_STR

				LDR R0, =CommonCounter
				LDR R1, [R0]
				ADD R1, #1
				STR R1, [R0]
				
				LDR R0, =Task2Counter
				LDR R1, [R0]
				ADD R1, #1
				STR R1, [R0]				
				BL EnablePIT
				
				POP {R1}
				POP {R0}
				POP {PC}
				
				ENDP					
           
Task3_Proc		PROC	
	
				PUSH {LR}
				PUSH {R0}
				PUSH {R1}
				
				BL DisablePIT
					
				LDR R0, =Task3Msg
				BL UART_SEND_STR
				
				MOV R2, #' '
				BL UART_SEND_CHR
				
				LDR R0, =CommonCntrMsg
				BL UART_SEND_STR
				
				LDR R0, =CommonCounter
                LDR R1, [R0]
                MOV R2, R1
                BL WRITE_BYTE_HEX
				
				MOV R2, #' '
				BL UART_SEND_CHR
				
				LDR R0, =TaskCntrMsg
				BL UART_SEND_STR
				
				LDR R0, =Task3Counter
                LDR R1, [R0]
                MOV R2, R1
                BL WRITE_BYTE_HEX
                
                LDR R0, =CRLF
				BL UART_SEND_STR

				LDR R0, =CommonCounter
				LDR R1, [R0]
				ADD R1, #1
				STR R1, [R0]
				
				LDR R0, =Task3Counter
				LDR R1, [R0]
				ADD R1, #1
				STR R1, [R0]
				
				BL EnablePIT

				POP {R1}
				POP {R0}
				POP {PC}
				ENDP

Timer_IRQ

				; ��������� ������� ��������� � ����
				
				SUB LR, LR, #4
				STMFD SP!, {R0-R12, LR}
				
                ; ������ PIT, ����� ����� ��� ���� ����������
                LDR R0, =PIT_BASE
                LDR R1, [R0, #PIT_PIVR]
                
                ; ����� ���������� � AIC
                LDR R0, =AIC_BASE
                MOV R1, #0x02                
                STR R1, [R0, #AIC_ICCR]
                STR R1, [R0, #AIC_EOICR]
				                
				; �������� � �������������� ����� ��������� ������
				LDR R0, =NextTaskNumber
				LDR R1, [R0]
				CMP R1, #3				
				MOVHI R1, #0
				ADD R1, #1
				STR R1, [R0]
				
				CMP R1, #1
				BLEQ Task1_Proc
				CMP R1, #2;
				BLEQ Task2_Proc
				CMP R1, #3
				BLEQ Task3_Proc
				
				; ��������������� ������ �� ����� � �������� � ����� User
				LDMFD SP!,{R0-R12, PC}^
                
                END
                    

