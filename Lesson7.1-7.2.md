# Practical Lesson 7.1-7.2: System Calls and Processes

[TOC]

## **Lesson Goals**
In this lesson, you will:
- Learn AArch64 assembly syntax and system call usage in Linux.
- Explore the `/proc` filesystem to monitor processes and file descriptors.
- Work with KaguOS, using C++ version of emulation.

---

## **Grading & Task Description**
### **Grading Criteria**
Use https://classroom.github.com/a/eSMyzghN to submit result files.

| Task                                  | Points |
|--------------------------------------|--------|
| Attendance                           | 1      |
| AArch64 Assembly Task                | 1      |
| Procfs & File Descriptor Task        | 0.5    |
| KaguOS New Bootloader & File comparison task            | 0.5    |
| Bonus Task (Aarch64 bitmap line to color)            | 1      |


---

## Task 1. AArch64 Assembly for Linux GAS

### **Knowledge Base**
#### **1.1 Installation Instructions**
Run a virtual machine and open a shell inside it.
Detect your CPU architecture using:
```bash
uname -m
```
- If the command returns `aarch64`, install the following:
  ```bash
  sudo apt update && sudo apt upgrade -y && sudo apt install -y gcc
  ```
- If the command returns `x86_64`, install:
  ```bash
  sudo apt update && sudo apt upgrade -y && sudo apt install -y gcc-aarch64-linux-gnu qemu-user-static
  ```

#### **1.2 Core Syntax and Sections**
`section` is a special block to mark how the data below should be interpreted:
- `.text`: Contains executable instructions (code section). Execution typically starts at `_start`.
- `.data`: Holds initialized, read/write data.
- `.rodata`: Contains read-only constants and strings.
- `.bss`: Stores uninitialized data, zeroed out at runtime. No data is allocated in binary only size to be allocated at program start.

- Assembly Directives:
  - `.section` to define sections.
  - `.global` to make symbols externally visible.
  - `.equ` and `.set` for defining constants.
  - `.fill` for initializing memory buffers. For example:
  ```
  buffer:
     .fill 8, 2, 15
  ```
will allocate 16 bytes (8 parts of 2 bytes each, initialized with 15 for every 2bytes value)

#### **1.3 Declaring Variables in Assembly**
You can declare variable with any size in bytes via some of the following instruction or their sequence:
- `.ascii`: Defines a string without a null terminator.
- `.asciz`: Defines a null-terminated string (like a C string).
- `.byte`: Stores a single byte (8-bit integer).
- `.2byte`: Stores a 16-bit integer.
- `.4byte`: Stores a 32-bit integer.
- `.8byte`: Stores a 64-bit integer.
- `.float`: Defines a single-precision floating-point number.
- `.double`: Defines a double-precision floating-point number.
For example:
``` assembler
.section .data
  some_var:
     .ascii "Test"
     .byte 0
  other_var:
     .4byte 0xFFFFFFFF
     .byte 12
```
For `some_var` 5 bytes will be allocated and initialized them as Test\0 sequence e.g. null terminated string.
For other_var we will also have 5 bytes; first 4 bytes will store the value provided and the last will represent a number 12 in binary form.

#### **1.4 Mapping Between Assembly and C Syntax**
| C Equivalent | Assembly Equivalent |
|-------------|--------------------|
| `char str[] = "Hello";` | `.asciz "Hello"` |
| `char str[] = {'H', 'e', 'l', 'l', 'o', 0};` | `.ascii "Hello" \n .byte 0` |
| `int x = 42;` | `.4byte 42` |
| `short s = 1000;` | `.2byte 1000` |
| `long l = 123456789;` | `.8byte 123456789` |
| `float f = 3.14;` | `.float 3.14` |
| `double d = 3.1415926535;` | `.double 3.1415926535` |

#### **1.5 Registers and Instructions**
- General-purpose registers: `x0-x30` (64-bit), `w0-w30` (lower 32 bits of `x` registers).
- Special registers: `sp` (Stack Pointer), `x30` (Link Register for function calls).
- Instructions:
  - **Data Movement:** `mov`, `ldr`, `str`, `ldp`, `stp`.
  - **Arithmetic:** `add`, `sub`, `mul`, `smull`, `umull`.
  - **Logical Operations:** `and`, `orr`, `eor`, `lsl`, `lsr`.
  - **Branching and Loops:** `b`, `bl`, `cbz`, `cbnz`, `cmp`, `b.eq`, `b.ne`. (note that branch in arm64 assembly is an equivalent of jumps from x86_64 Kagu Asm)

**Note 1**: We can use mov instruction between register (`mov x0,x10` which means `x0=x10`), also we can use immediate constants with #.
For example, if we want to set register x5 to 42 then we should use `mov x5, #42`.
**Note 2**: If you need to reference some variable, you can load it's address to the register
`ldr x0, =some_var`. You can load data from that address with `[]` syntax and `ldrb`, `ldrh` or `ldr` instruction: `ldr x1, [x0]` will load 8 bytes from that address to `x1` register.

**Note 3**: To store the data to the variable use store instruction str:
```assembler
    ldr x0, =value  // Load the address of 'value' into X0
    mov x1, #42     // Move 42 into X1
    str x1, [x0]    // Store X1 (42) into memory at 'value'
```

**Note 4**: For jumps we can use branch instructions and labels:
```
    cbz W0, exit  // If W0 == 0, branch to exit
    b some_label  // unconditional jump to some_label
```
Or with comparison(`w0` is a lower 32 bit part of `x0`, use when you sure that number is small. Depending on cpu some operations may be a bit faster with w version of register).
```assembler
loop:
    sub w0, w0, #2     // Subtract 2 each iteration e.g. w0 = w0 - 2
    cmp w0, #4         // Compare W0 with 4
    beq found          // If W0 == 4, branch to found
    cbnz w0, loop      // If W0 != 0, continue loop
found:
    // some instructions
```


#### **1.6 System Calls and Execution**
- System calls in AArch64 use `svc #0`, with parameters in registers. Use table https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md#arm64-64_bit to find the list of the calls and their arguments, there is man link for every call.
- Common syscalls:
  - `write(64)`, `exit(93)`, `getcwd(17)`, `chmod(52)`, `open(56)`, `read(63)`, `close(57)`.
- Example of writing to stdout and exit:
```assembly
.section .data   // section with initialized variables 
  message:      // variable with null-terminated string(.asciz will add \0 automatically)
    .asciz "Hello!\n"

.section .text
  .global _start

  _start:
    mov x0, #1     // file descriptor for standard output is 1
    ldr x1, =message  // load address of the variable with data to x1
    mov x2, #7    // bytes count to write
    mov x8, #64   // write system call number is 64
    svc #0        // perform a system call

    mov x0, #0    // return status 0
    mov x8, #93   // exit system call is 93
    svc #0        // perform a system call
```
- Compilation and Execution:
  ```bash
  aarch64-linux-gnu-as -o test.o test.S
  aarch64-linux-gnu-ld -o test test.o
  ./test
  ```

#### **Task**
1. Allocate a 256-byte buffer in .data section.
2. Use `getcwd` (syscall 17) to retrieve the current directory.
3. Print the directory using `write` (syscall 64).
4. Modify the program to return code 1 instead of 0.
5. Use syscalls 52-56 to manipulate file permissions and contents. E.g. write and read line for some file. Set exec permission, change owner or group for the file.

---

## **Task 2: Procfs Monitoring and File Descriptor Limits**

### **Knowledge Base**
#### **2.1 Understanding `/proc`**
- `/proc/<pid>` provides information about running processes.
- Some useful files inside `/proc/<pid>/`:
  - `environ` – Environment variables.
  - `limits` – Process resource limits.
  - `stat` – Process status.
  - `stack` – Stack memory usage.
  - `cmdline` – Command-line arguments.

#### **2.2 File Descriptors & Limits**
- `/proc/sys/fs/file-max` – Maximum allowed open file descriptors. Use `cat` command to get the content.
- C++ file handling with `ofstream` objects.
### Task 2: Procfs Monitoring and File Descriptor Limits

#### Subtask 1: Writing `main.cpp`
0. Create c++ program to do the following.
1. Open a file named `test.txt`.
2. Write an indexed line every second, running for 1000 iterations.
3. Use `std::flush` to ensure data is saved immediately.
4. Compile `g++ main.cpp -o main` and run the program. 
5. Find the process ID (PID) of the running program by using `ps -aux | grep main` or `pidof main`.
6. Investigate `/proc/<pid>` and analyze the following files:
   - `environ` – Environment variables.
   - `limits` – Process resource limits.
   - `stat` – Process status.
   - `stack` – Stack memory usage.
   - `cmdline` – Command-line arguments.

---

#### **Subtask 2: Writing `files.cpp`**
0. Write `files.cpp` with the following functionality.
1. Open multiple files dynamically in a loop.
2. Use a `std::vector<std::ofstream>` to keep track of open file descriptors.
3. Compile and run the program as `files` binary e.g. `g++ files.cpp -o files` and `./files`
4. Find the process ID by running `pidof files`.
5. Monitor open file descriptors in `/proc/<pid>/fd` by listing them with `ls -l /proc/<pid>/fd`.

---

#### **Subtask 3: Writing `file_limit.cpp`**
1. Attempt to open 100,000 files within the system's file descriptor limits. For example, use the files.cpp as a base but create nested loops to open 1000 files, then sleep for one second and create 1000 files, and so on.
2. Check the current file descriptor limit by reading `/proc/sys/fs/file-max`.
3. Adjust the limit to 65,535 if needed by writing to `/proc/sys/fs/file-max`. For example use ` sudo bash -c 'echo 65535 > /proc/sys/fs/file-max' `
4. Observe system behavior when limits are exceeded:
   - Check for errors in opening files.
   - Note system slowdowns or failures.
   - Try opening a new terminal to see if the system becomes unresponsive.

---

## **Task 3: Bootloader for KaguOS**

### **Knowledge Base**

#### **3.1 C++ Hardware Emulation**
Use alternative implementation of hardware emulation in `bootloader.cpp`:
- Compile:

`clang++ bootloader.cpp -o bootloader`

- Run:

`./bootloader build/kernel.disk 1500`

- Test:

`CPP_BOOTLOADER=1 tests/test_cpu_emulation.sh`
#### **3.2 Task: File Comparison**
- Prompt user for 2 filenames.
- Check that both files exists and report errors if needed.
- Detect and report the first differing line between the files.
---

## **Bonus Task: Render Colored Line with AArch64 Assembly**

### **Knowledge Base**
Use escape codes for colors (`\033[41m` for red, etc.) to print line of bitmap based on the following convention:
B - black color
r - red
g - green
b - blue
y - yellow
w - white
c - cyan
m - magenta

Therefore you should prompt a line with up to 16 symbols and then print colored representation. For example, yybb should print two yellow cells and two blue cells.


