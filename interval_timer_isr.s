.include    "address_map_arm.s" 
.include    "defines.s" 
/* externally defined variables */
.extern     PATTERN 

.global     TIMER_ISR 
TIMER_ISR:                      
        PUSH    {R4-R7}         // push values in registers to stack to avoid losing
        LDR     R1, =TIMER_BASE // interval timer base address
        MOV	    R0, #0          
        STR     R0, [R1]        // clear the interrupt

        LDR     R1, =LED_BASE   // LED base address
        LDR     R2, =PATTERN    // set up a pointer to the pattern for LED displays
		
        LDR     R6, [R2]        // load pattern for LED displays
        STR     R6, [R1]        // store to LEDs
		
SHIFT:
		MOV		R5, #8			// shift amount
		ROR		R6, R5			// rotate to turn on or off
		
END_TIMER_ISR:                  
        STR     R6, [R2]        // store LED display pattern
        POP     {R4-R7}         // pop from stack to regain previous values
        BX      LR              

.end         

