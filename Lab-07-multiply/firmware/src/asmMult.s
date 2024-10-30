/*** asmMult.s   ***/
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */
/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Robert Nelson"  

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global a_Multiplicand,b_Multiplier,rng_Error,a_Sign,b_Sign,prod_Is_Neg,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0  
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0  
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

    
/********************************************************************
function name: asmMult
function description:
     output = asmMult ()
     
where:
     output: 
     
     function description: The C call ..........
     
     notes:
        None
          
********************************************************************/    
.global asmMult
.type asmMult,%function
asmMult:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
 
.if 0
    /* profs test code. */
    mov r0,r0
.endif
    
    /** note to profs: asmMult.s solution is in Canvas at:
     *    Canvas Files->
     *        Lab Files and Coding Examples->
     *            Lab 8 Multiply
     * Use it to test the C test code */
    
    /*** STUDENTS: Place your code BELOW this line!!! **************/
    
    /* START initialize to zero */
    ldr r2, =a_Multiplicand
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =b_Multiplier
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =rng_Error
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =a_Sign
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =b_Sign
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =prod_Is_Neg
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =a_Abs
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =b_Abs
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =init_Product
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =final_Product
    ldr r3, =0
    str r3, [r2]
    /* END initialize to zero */
    
    /* Copy r0 and r1 into multiplicand and multiplier */
    ldr r2, =a_Multiplicand
    str r0, [r2]
    
    ldr r2, =b_Multiplier
    str r1, [r2]
    
    /* Check range of args to fit within 16b signed int */
    ldr r2, =32767
    cmp r0, r2
    bgt error
    
    ldr r2, =-32768
    cmp r0, r2
    blt error
    
    ldr r2, =32767
    cmp r1, r2
    bgt error
    
    ldr r2, =-32768
    cmp r1, r2
    blt error
    
    /***
     * Get sign bit of both arguments
     * Do this by performing a logical shift
     * We want to fill with leading zeros to get only 1 or 0
    ***/
    mov r3, r0
    lsr r3, 31
    ldr r2, =a_Sign
    str r3, [r2]
    
    mov r3, r1
    lsr r3, 31
    ldr r2, =b_Sign
    str r3, [r2]
    
    ldr r2, =a_Sign
    ldr r3, =b_Sign
    ldr r2, [r2]
    ldr r3, [r3]
    
    /***
     * If the signs are equal, result will be positive
     * If not equal, result will be negative
     * Compare signs to one another, then check if one argument is zero
     * Zero is considered positive, so a zero result will override negative
    ***/
    cmp r2, r3
    
    mov r5, 1
    ldr r4, =prod_Is_Neg
    moveq r5, 0
    
    cmp r0, 0
    moveq r5, 0
    
    cmp r1, 0
    moveq r5, 0
    
    str r5, [r4]
    
    /***
     * Get the absolute value of our arguments
     * This is done by performing a negation (pseudo-instruction for RSB)
     * If either argument is zero, that means they are already its abs
     * Take this value and store it into its respective *_Abs
    ***/
    mov r3, r0
    cmp r3, 0
    bge a_absolute
    neg r3, r3
    
    a_absolute:
    ldr r4, =a_Abs
    str r3, [r4]
    
    mov r3, r1
    cmp r3, 0
    bge b_absolute
    neg r3, r3
    
    b_absolute:
    ldr r4, =b_Abs
    str r3, [r4]
    
    ldr r2, =a_Abs
    ldr r2, [r2]
    ldr r3, =b_Abs
    ldr r3, [r3]
    
    /***
     * Check if multiplier or multiplicand is zero
     * If so, go straight to setting the product to zero
     * Load in the initial product for manipulation in our multiplication
    ***/
    cmp r2, 0
    beq zero
    cmp r3, 0
    beq zero
    
    ldr r5, =init_Product
    ldr r5, [r5]
    
    /***
     * Check if our LSB is 1 using AND in order to mask other bits
     * This makes comparison easy, just compare against zero
     * If the LSB is 1, then add the multiplicand to the initial product
     * Shift multiplicand left one bit, multiplier right by 1
    ***/
    multiply:
    and r4, r3, 1
    cmp r4, 0
    addne r5, r5, r2
    lsl r2, r2, 1
    lsr r3, r3, 1
    
    /***
     * If the multiplier has not yet been reduced to zero, we are not done
     * Loop back to the beginning of our operation
    ***/
    cmp r3, 0
    bne multiply
    
    /***
     * Load in our previous determination of whether our product is negative
     * If it is, negate our current initial product, then store that into final
    ***/
    ldr r6, =init_Product
    str r5, [r6]
    
    ldr r7, =prod_Is_Neg
    ldr r7, [r7]
    
    cmp r7, 1
    negeq r5, r5
    
    ldr r6, =final_Product
    str r5, [r6]
    
    ldr r0, =final_Product
    ldr r0, [r0]
    
    b done
    
    /* Pretty simple here, just return zero. Final product is already zero */
    zero:
    mov r0, 0
    
    b done
    
    /* We have an error! The args were out of range, and the product is zero */
    error:
    ldr r2, =rng_Error
    ldr r3, =1
    str r3, [r2]
    
    mov r0, 0
    
    b done
    
    /*** STUDENTS: Place your code ABOVE this line!!! **************/

done:    
    /* restore the caller's registers, as required by the 
     * ARM calling convention 
     */
    mov r0,r0 /* these are do-nothing lines to deal with IDE mem display bug */
    mov r0,r0 

screen_shot:    pop {r4-r11,LR}

    mov pc, lr	 /* asmMult return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




