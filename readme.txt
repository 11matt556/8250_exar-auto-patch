This script DOES NOT apply to kernel versions below.

o	5.8.x and higher
o	5.7.9 and higher
o	5.4.54 and higher (excluding 5.5 - 5.6)
o	4.19.135 and higher (excluding 4.20 - 5.3)
o	4.14.190 and higher (excluding 4.15 – 4.18)
o	3.7.0-rc6 – 4.10.x

Do not run it on these kernel versions.

----------------------------------------------

Run ./patcher.sh --help for optional arguments

The process is essentially 3 steps.
0) Run chmod +x patcher.sh to make sure it is executable
1) Run ./patcher.sh from the terminal. 
2) Apply the patch to your kernel using insmod, modprobe etc as you would with any other kernel module. Make sure to unload the old module before loading the new one. There are extra steps required to load the new driver on boot, but the exact steps can vary by distribution and so are not documented here.

If the script fails or you prefer to run the commands yourself please follow the steps below to compile the patch. If you perform the steps manually, make sure the "drivers" folder from your kernel is in the "kernel_to_mod" folder. e.g. kernel_to_mod/drivers/...

--- Script performs the steps below ---
0) Detects and downloads the correct kernel source [Optional if you downloaded the source manually]
1) Copies the drivers folder to kernel_to_patch
2) Applies the appropriate patch file for your kernel
    a) If you have kernel version 4.11.x or 4.12.x:
        Runs "patch -u kernel_to_patch/drivers/tty/serial/8250/8250_exar.c -i 8250_exar_4.11-4.12.patch"
    b) If you have kernel version 4.13 or higher**:
        Runs "patch -u kernel_to_patch/drivers/tty/serial/8250/8250_exar.c -i 8250_exar_4.13+.patch"
        ** Note that 5.8 and higher does not require this patch
3) Runs "patch -u kernel_to_patch/drivers/tty/serial/8250/ -i Makefile.patch"
4) Runs "cd kernel_to_patch/drivers/tty/serial/8250_exar/ && make"
5) Copies the compiled kernel module (.ko) file to the directory this readme is in for easy access
6) The module is now compiled and ready to be loaded with insmod, modprobe, etc as any other module would be.Make sure to unload the old module before loading the new one. There are extra steps required to load the new driver on boot, but the exact steps can vary by distribution and so are not documented here.

Contact support at 864-843-4343 or support@sealevel.com if you have any issues or questions.

Written by Matthew Howell


