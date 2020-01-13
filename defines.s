; Standard definitions of Mode bits and Interrupt (I & F) flags in PSRs

Mode_USR        EQU     0x10
Mode_FIQ        EQU     0x11
Mode_IRQ        EQU     0x12
Mode_SVC        EQU     0x13
Mode_ABT        EQU     0x17
Mode_UND        EQU     0x1B
Mode_SYS        EQU     0x1F

I_Bit           EQU     0x80            ; when I bit is set, IRQ is disabled
F_Bit           EQU     0x40            ; when F bit is set, FIQ is disabled

; Internal Memory Base Addresses
FLASH_BASE      EQU     0x00100000   
RAM_BASE        EQU     0x00200000

UND_Stack_Size  EQU     0x00000000
SVC_Stack_Size  EQU     0x00000008
ABT_Stack_Size  EQU     0x00000000
FIQ_Stack_Size  EQU     0x00000000
IRQ_Stack_Size  EQU     0x00000080
USR_Stack_Size  EQU     0x00000400
    
ISR_Stack_Size  EQU     (UND_Stack_Size + SVC_Stack_Size + ABT_Stack_Size + \
                         FIQ_Stack_Size + IRQ_Stack_Size)
					
Heap_Size       EQU     0x00000000
    
	
	
; Reset Controller (RSTC) definitions
RSTC_BASE       EQU     0xFFFFFD00      ; RSTC Base Address
RSTC_MR         EQU     0x08            ; RSTC_MR Offset
	

RSTC_SETUP      EQU     1
RSTC_MR_Val     EQU     0xA5000401


; Embedded Flash Controller (EFC) definitions
EFC_BASE        EQU     0xFFFFFF00      ; EFC Base Address
EFC0_FMR        EQU     0x60            ; EFC0_FMR Offset
EFC1_FMR        EQU     0x70            ; EFC1_FMR Offset
	
EFC0_SETUP      EQU     1
EFC0_FMR_Val    EQU     0x00320100
	
EFC1_SETUP      EQU     0
EFC1_FMR_Val    EQU     0x00320100


; Watchdog Timer (WDT) definitions
WDT_BASE        EQU     0xFFFFFD40      ; WDT Base Address
WDT_MR          EQU     0x04            ; WDT_MR Offset
WDT_SETUP       EQU     1
WDT_MR_Val      EQU     0x00008000

; Power Mangement Controller (PMC) definitions
PMC_BASE        EQU     0xFFFFFC00      ; PMC Base Address
PMC_PCER		EQU		0x10
PMC_MOR         EQU     0x20            ; PMC_MOR Offset
PMC_MCFR        EQU     0x24            ; PMC_MCFR Offset
PMC_PLLR        EQU     0x2C            ; PMC_PLLR Offset
PMC_MCKR        EQU     0x30            ; PMC_MCKR Offset
PMC_SR          EQU     0x68            ; PMC_SR Offset
PMC_MOSCEN      EQU     (1<<0)          ; Main Oscillator Enable
PMC_OSCBYPASS   EQU     (1<<1)          ; Main Oscillator Bypass
PMC_OSCOUNT     EQU     (0xFF<<8)       ; Main OScillator Start-up Time
PMC_DIV         EQU     (0xFF<<0)       ; PLL Divider
PMC_PLLCOUNT    EQU     (0x3F<<8)       ; PLL Lock Counter
PMC_OUT         EQU     (0x03<<14)      ; PLL Clock Frequency Range
PMC_MUL         EQU     (0x7FF<<16)     ; PLL Multiplier
PMC_USBDIV      EQU     (0x03<<28)      ; USB Clock Divider
PMC_CSS         EQU     (3<<0)          ; Clock Source Selection
PMC_PRES        EQU     (7<<2)          ; Prescaler Selection
PMC_MOSCS       EQU     (1<<0)          ; Main Oscillator Stable
PMC_LOCK        EQU     (1<<2)          ; PLL Lock Status
PMC_MCKRDY      EQU     (1<<3)          ; Master Clock Status
PMC_SETUP       EQU     1
PMC_MOR_Val     EQU     0x00000601
PMC_PLLR_Val    EQU     0x00191C05
PMC_MCKR_Val    EQU     0x00000007
	

; Адреса периферийных устройств
PIOA_BASE		EQU		0xFFFFF400 ; Порт "А"
PIOB_BASE		EQU		0xFFFFF600 ; Порт "В"
DBGU_BASE		EQU		0xFFFFF200 ; Отладочный UART

; Смещения регистров периферийных устройств

; Порты ввода-выводы
PIO_PDR			EQU		0x0004
PIO_OER			EQU     0x0010
PIO_ODR			EQU		0x0014
PIO_IFDR		EQU		0x0024
PIO_SODR	    EQU 	0x0030
PIO_CODR		EQU		0x0034
PIO_ASR			EQU		0x0070
PIO_BSR			EQU		0x0074
	
; Отладочный UART

DBGU_CR			EQU		0x00000000
DBGU_MR			EQU		0x00000004
DBGU_CSR		EQU		0x00000014
DBGU_THR		EQU		0x0000001C
DBGU_IDR		EQU		0x0000000C
DBGU_BRGR		EQU		0x00000020
	
; DMA для отладочного UART'a

DBGU_PDC_BASE	EQU		0xFFFFF300
DBGU_PDC_PTCR	EQU		0x00000020
	
; USART0

USART0_BASE 	EQU		0xFFFC0000
USART_CR		EQU		0x0000
USART_MR		EQU		0x0004
USART_CSR		EQU		0x0014
USART_THR		EQU		0x001C
USART_BRGR		EQU		0x0020
USART_IDR		EQU		0x000C
    
; AIC

AIC_BASE        EQU     0xFFFFF000
AIC_SMR1        EQU     0x0004
AIC_SVR1        EQU     0x0084
AIC_IMR         EQU     0x0110
AIC_IECR        EQU     0x0120
AIC_ICCR        EQU     0x0128
AIC_EOICR       EQU     0x0130
    
; PIT
PIT_BASE        EQU     0xFFFFFD30
PIT_MR          EQU     0x00    
PIT_SR          EQU     0x04
PIT_PIVR        EQU     0x08
PIT_PIIR        EQU     0x0C


						 
				END
