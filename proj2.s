.include    "address_map_arm.s"         
.include    "defines.s"                 
.include    "interrupt_ID.s"            

/*********************************************************************************
 * Initialize the exception vector table
 ********************************************************************************/
.section    .vectors, "ax"              

        B       _start                      // reset vector
        B       SERVICE_UND                 // undefined instruction vector
        B       SERVICE_SVC                 // software interrrupt vector
        B       SERVICE_ABT_INST            // aborted prefetch vector
        B       SERVICE_ABT_DATA            // aborted data vector
.word       0                               // unused vector
        B       SERVICE_IRQ                 // IRQ interrupt vector
        B       SERVICE_FIQ                 // FIQ interrupt vector
		
.text                                   
.global     _start                      
_start:                                     
/* Set up stack pointers for IRQ and SVC processor modes */
        MOV     R1, #INT_DISABLE | IRQ_MODE 
        MSR     CPSR_c, R1                  // change to IRQ mode
        LDR     SP, =A9_ONCHIP_END - 3      // set IRQ stack to top of A9 onchip
                                            // memory

/* Change to SVC (supervisor) mode with interrupts disabled */
        MOV     R1, #INT_DISABLE | SVC_MODE 
        MSR     CPSR_c, R1                  // change to supervisor mode
        LDR     SP, =DDR_END - 3            // set SVC stack to top of DDR3 memory

        BL      CONFIG_GIC                  // configure the ARM generic interrupt
                                            // controller
        BL      CONFIG_INTERVAL_TIMER       // configure the Altera interval timer

/* enable IRQ interrupts in the processor */
        MOV     R1, #INT_ENABLE | SVC_MODE  // IRQ unmasked, MODE = SVC
        MSR     CPSR_c, R1                  

LOOP:
		B		LOOP
		
/* Configure the Altera interval timer to create interrupts at 1-sec intervals */
CONFIG_INTERVAL_TIMER:                      
        LDR     R0, =TIMER_BASE             
/* set the interval timer period for scrolling the LED displays */
        LDR     R1, =100000000                // 1/(100 MHz) x 1x10^8 = 1 sec
        STR     R1, [R0, #0x8]              // store the low half word of counter
                                            // start value
        LSR     R1, R1, #16                 
        STR     R1, [R0, #0xC]              // high half word of counter start value

                                            // start the interval timer, enable its interrupts
        MOV     R1, #0x7                    // START = 1, CONT = 1, ITO = 1
        STR     R1, [R0, #0x4]              
        BX      LR           

/* Global Variable */
.global     PATTERN                     
PATTERN:                                    
.word       0x00FF00FF                  // pattern to show on the LED lights
.end
