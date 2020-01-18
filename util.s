; ������������, ���������� �� �������� ���������

				GET defines.s
                AREA Util, CODE, READONLY, ALIGN=3
            
; �������� ��� ������� ���������� LCD
; ���� - ������� ��������� ����������
; ����� - ������������ ������ �� ����������
BLINKDELAY		PROC
	
				PUSH {LR}
				PUSH {R0}
				PUSH {R1}				
		
				MOV R0, #50
				LSL R0, #8
DELAY_1				
				SUB R0, #1				
				MOV R1, #50
				
DELAY_2			
				SUB R1, #1
				CMP R1, #0
				BNE DELAY_2
				
				CMP R0,#0
				BNE DELAY_1
				
				POP {R1}
				POP {R0}
				POP {PC}
	
				ENDP
	
; �������� ������� �� UART
; ���� - R2 - ������������ ������
; ����� - ������������ ������ �� ����������
UART_SEND_CHR	PROC
				
				PUSH {LR}
				PUSH {R0}
				PUSH {R1}
				PUSH {R2}
				
				LDR R0, =USART0_BASE
				MOV R1, R2
				STR R1, [R0, #USART_THR]
				
; ���������� ��������� ��������

WAIT_SENT
				EOR R0, R0
				ADD R0, #USART0_BASE
				ADD R0, #USART_CSR
				LDR R1, [R0]
				MOV R2, #1
				LSL R2, #9
				TST R1, R2 ; ��� "�������� ���������"
				BEQ WAIT_SENT
				
				POP {R2}
				POP {R1}
				POP {R0}
				POP {PC}
				
				ENDP
					

; �������� ������ �� UART
; ���� - R0 - ����� ������
; ����� - ������������ ������ �� ����������
UART_SEND_STR	PROC

                PUSH    {LR}
                PUSH    {R0}
                PUSH    {R1}
				PUSH    {R2}
				
				
NEXT_CHR
				LDRB 	R2, [R0]
				CMP 	R2, #0
				BEQ 	STR_END
				BL 		UART_SEND_CHR
				ADD 	R0, #1
				B 		NEXT_CHR						
STR_END
				POP     {R2}
                POP     {R1}
                POP     {R0}
                POP     {PC}
                ENDP 

; �������� ����� ����� � ����������������� ������� � UART
; ���� - R2 - ����� ��� ��������
; ����� - ������������ ������ �� ����������
WRITE_DIGIT_HEX
                PUSH {LR}
                PUSH {R2}
                
                AND R2, #0x0F
                CMP R2, #0x09
                BGT GREATER_THAN9
                ADD R2, #0x30
                BL UART_SEND_CHR
                
                POP {R2}
                POP {PC}                
                
GREATER_THAN9
                ADD R2, #0x37
                BL UART_SEND_CHR
                POP {R2}
                POP {PC}
            
; �������� ����� � ����������������� ��������� � UART			
; ���� - R2 - ���� ��� ��������
; ����� - ������������ ������ �� ����������
WRITE_BYTE_HEX
                PUSH {LR}
                PUSH {R1}
                PUSH {R2}

                EOR R1, R1
                MOV R1, R2
                PUSH {R1}
                PUSH {R2}
                LSR R2, #4
                BL WRITE_DIGIT_HEX
                POP {R2}
                POP {R1}
                MOV R2, R1
                BL WRITE_DIGIT_HEX
                
                POP {R2}
                POP {R1}
                POP {PC}
            
; ������ ���������� ���������� �������
; ���� - ������� ��������� ����������
; ����� - ������������ ������ �� ����������
DisablePIT		PROC
	
				PUSH {LR}	
				PUSH {R0}
				PUSH {R1}
				PUSH {R2}
				
				; Disable timer interrupt				
                LDR R0, =PIT_BASE
				; Clear PITIEN bit
				MOV R1, #1
				LSL R1, #25
				
				; Load to R2 PIT_MR state
				LDR R2, [R0, #PIT_MR]
				BIC R2, R1
				STR R2, [R0, #PIT_MR]
				
				POP {R2}
				POP {R1}
				POP {R0}
				POP {PC}
	
				ENDP
					
; ���������� ���������� ���������� �������
; ���� - ������� ��������� ����������
; ����� - ������������ ������ �� ����������
EnablePIT		PROC
	
				PUSH {LR}	
				PUSH {R0}
				PUSH {R1}
				PUSH {R2}
				
				LDR R0, =PIT_BASE
				; ������� ���� PITIEN
				MOV R1, #1
				LSL R1, #25				
				LDR R2, [R0, #PIT_MR]
				ORR R2, R1
				STR R2, [R0, #PIT_MR]
				
				POP {R2}
				POP {R1}
				POP {R0}
				POP {PC}
	
				ENDP
					
				END
            