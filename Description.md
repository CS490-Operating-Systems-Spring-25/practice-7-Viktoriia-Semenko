## Task 1 AArch64 Assembly for Linux GAS
(all files are located in directory `practice7`)
### How I tested:
1. create new file on VM `nano file.S`
2. aasemble `aarch64-linux-gnu-as -o file.o file.S`
3. link `aarch64-linux-gnu-ld -o file file.o`
4. run the program`./file`, it will print directory
5. check exit status `echo $?`, it will output `1`
6. Task 5:
    - File creation/opening (Syscall 56 - openat)
    - File writing (Syscall 64 - write)
    - Permission modification (Syscall 52 - chmod)
    - File reading (Syscall 63 - read)
    - File сlosing (Syscall 57 - close)
    - check file creating `ls -l testFile.txt`
    ![alt text](<Screenshot 2025-03-25 at 12.02.05.png>)
    - content verification `cat testFile.txt`
    ![alt text](<Screenshot 2025-03-25 at 12.02.54.png>)
    - check permision `stat testFile.txt`, it should output `0777/-rwxrwxrwx`
    ![alt text](<Screenshot 2025-03-25 at 12.03.28.png>)

---

## Task 2 Procfs Monitoring and File Descriptor Limits

### Subtask 1: Writing `main.cpp`
### How I tested:
1. create file `main.cpp`
2. compilation `g++ main.cpp -o main` 
3. execution `./main &` - to run in the background
4. PID of program - `pidof main`, output
    - ![alt text](<Screenshot 2025-03-29 at 12.46.29.png>)
5. Investigating `/proc/<pid>`: 

    - environ: `cat /proc/349513/environ | tr '\0' '\n'`:
    ![alt text](<Screenshot 2025-03-29 at 12.48.56.png>)

    - limits: `cat /proc/349513/limits`
    ![alt text](<Screenshot 2025-03-29 at 12.51.45.png>)

    - stat: `cat /proc/349513/stat`
    ![alt text](<Screenshot 2025-03-29 at 12.52.29.png>)

    - stack: `sudo cat /proc/349513/stack`
    ![alt text](<Screenshot 2025-03-29 at 12.52.49.png>)

    - cmdline: `cat /proc/349513/cmdline`
    ![alt text](<Screenshot 2025-03-29 at 12.53.29.png>)

---

### Subtask 2: Writing `files.cpp`
### How I tested:
1. create file `files.cpp`
2. compile and run  `g++ files.cpp -o files` -> `./files` + PID of process
![alt text](<Screenshot 2025-03-29 at 13.13.37.png>)

3. Monitor open file descriptors: `ls -l /proc/350155/fd`
![alt text](<Screenshot 2025-03-29 at 13.13.27.png>)

---

#### Subtask 3: Writing `file_limit.cpp`
### How I tested:
1. create file `file_limit.cpp`
2. compile and run  `g++ file_limit.cpp -o file_limit` -> `./file_limit`
3. Current file descriptor limit `/proc/sys/fs/file-max`. It is `9223372036854775807`
4. I have addjusted it to `65,535`. Output:
- ![alt text](<Screenshot 2025-03-29 at 13.43.31.png>)
- ![alt text](<Screenshot 2025-03-29 at 13.43.38.png>)

5. In another terminal
- Watching system-wide file descriptor usage `watch -n 1 'echo "Used/Free/Max: $(cat /proc/sys/fs/file-nr)"'`
![alt text](<Screenshot 2025-03-29 at 13.48.27.png>)
- Monitoring process-specific FD count `watch -n 1 'ls /proc/$(pidof file_limit)/fd | wc -l'`
![alt text](<Screenshot 2025-03-29 at 13.48.38.png>)
- System FD exhaustion: `cat /proc/sys/fs/file-nr`
![alt text](<Screenshot 2025-03-29 at 13.49.49.png>)

---

## **Task 3: Bootloader for KaguOS**
### How I tested:
1. create file `check_file.kga`
2. run `./asm.sh src/01_stack.kga src/02_fs.kga practice7/check_file.kga`
3. `./bootloader build/kernel.disk 1500`
4. then enter filenames (then i have some problem...)
---

## **Bonus Task: Render Colored Line with AArch64 Assembly**
### How I tested:
1. create new file on VM `nano colors.S`
2. aasemble `aarch64-linux-gnu-as -o colors.o colors.S`
3. link `aarch64-linux-gnu-ld -o colors colors.o`
3. run `./colors` 
4. input valid letters and check magic