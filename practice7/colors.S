.section .data
prompt:
        .asciz "Enter color codes (up to 16, B,r,g,b,y,w,c,m): "
input:
        .fill 17, 1, 0
color_esc:
        .asciz "\033["
reset_esc:
        .asciz "\033[0m"
newline:
        .asciz "\n"
block:
        .asciz "  "  // Block representation

// Color escape codes
black:      .asciz  "40m"
red:        .asciz  "41m"
green:      .asciz  "42m"
blue:       .asciz  "44m"
yellow:     .asciz  "43m"
white:      .asciz  "47m"
cyan:       .asciz  "46m"
magenta:    .asciz  "45m"

.section .text
.global _start

_start:
    // Print prompt
    mov x0, #1 // stdout
    ldr x1, =prompt
    mov x2, #47 // length of prompt
    mov x8, #64 // write syscall
    svc #0

    // Read input
    mov x0, #0 // stdin
    ldr x1, =input
    mov x2, #17 // read up to 16 chars + null
    mov x8, #63 // read syscall
    svc #0

    // Process each character
    ldr x19, =input // pointer to input buffer
    mov x20, #0 // character counter

process_char:
    ldrb w21, [x19, x20] // load current character
    cbz w21, done_processing // if null terminator, exit

    // skip newline characters
    cmp w21, #'\n'
    b.eq next_char

    // check for valid color codes
    cmp w21, #'B'
    b.eq black_color
    cmp w21, #'r'
    b.eq red_color
    cmp w21, #'g'
    b.eq green_color
    cmp w21, #'b'
    b.eq blue_color
    cmp w21, #'y'
    b.eq yellow_color
    cmp w21, #'w'
    b.eq white_color
    cmp w21, #'c'
    b.eq cyan_color
    cmp w21, #'m'
    b.eq magenta_color
    
    // if invalid, skip
    b next_char

black_color:
    ldr x22, =black
    b print_color
red_color:
    ldr x22, =red
    b print_color
green_color:
    ldr x22, =green
    b print_color
blue_color:
    ldr x22, =blue
    b print_color
yellow_color:
    ldr x22, =yellow
    b print_color
white_color:
    ldr x22, =white
    b print_color
cyan_color:
    ldr x22, =cyan
    b print_color
magenta_color:
    ldr x22, =magenta

print_color:
    // Print color escape sequence
    mov x0, #1
    ldr x1, =color_esc
    mov x2, #2 // length of "\033["
    mov x8, #64 // write syscall
    svc #0

    // Print the specific color code
    mov x0, #1
    mov x1, x22
    mov x2, #3 // length of color code
    mov x8, #64
    svc #0

    // Print colored block (two spaces)
    mov x0, #1
    ldr x1, =block
    mov x2, #2
    mov x8, #64
    svc #0

next_char:
    add x20, x20, #1 // increment counter
    cmp x20, #16 // max 16 characters
    b.lt process_char

done_processing:
    // Print reset escape sequence
    mov x0, #1
    ldr x1, =reset_esc
    mov x2, #4 // length of "\033[0m"
    mov x8, #64
    svc #0

    // Print newline
    mov x0, #1
    ldr x1, =newline
    mov x2, #1
    mov x8, #64
    svc #0

exit:
    // Exit program
    mov x0, #0
    mov x8, #93 // exit syscall
    svc #0