.section .data
buffer:
        .fill 256, 1, 0
filename:
        .asciz "testFile.txt"
filecontent:
        .asciz "This is a test file\n"
newline: 
        .asciz "\n"

.section .text
.global _start

_start:
        // Task 1: get current working directory
        ldr x0, =buffer // load buffer address
        mov x1, #256 // buffer size
        mov x8, #17 // getcwd syscall number
        svc #0

        // Task 2: print the directory
        mov x0, #1 // stdout
        ldr x1, =buffer // buffer with directory path
        mov x2, #256 // Maximum length to print
        mov x8, #64 // write syscall
        svc #0

        // print newline
        mov x0, #1
        ldr x1, =newline
        mov x2, #1
        mov x8, #64
        svc #0

        // Task 3: file operations
        // create/open file
        mov x0, #-100
        ldr x1, =filename
        mov x2, #66 // O_CREAT|O_RDWR
        mov x3, #438 // 0666 - rw-rw-rw-
        mov x8, #56 // openat syscall
        svc #0
        mov x19, x0 // save file descriptor

        // write to file
        ldr x1, =filecontent
        mov x2, #19 // Length of content
        mov x8, #64 // write syscall
        svc #0

        // close file
        mov x0, x19
        mov x8, #57 // close syscall
        svc #0

        // change file permissions (chmod)
        ldr x0, =filename
        mov x1, #511 // 0777 - rwxrwxrwx
        mov x8, #52 // chmod syscall
        svc #0

        // reopen file for reading
        ldr x0, =filename
        mov x1, #0
        mov x8, #56 // open syscall
        svc #0
        mov x19, x0 // save file descriptor

        // read from file
        ldr x1, =buffer
        mov x2, #256
        mov x8, #63 // read syscall
        svc #0

        // print file contents
        mov x2, x0 // number of bytes read
        mov x0, #1 // stdout
        ldr x1, =buffer
        mov x8, #64 // write syscall
        svc #0

        // close file
        mov x0, x19
        mov x8, #57 // close syscall
        svc #0

        // Task 4: exit with status 1
        mov x0, #1 // Return code 1
        mov x8, #93 // exit syscall
        svc #0
