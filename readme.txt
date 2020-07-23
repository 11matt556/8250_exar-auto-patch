Run ./patcher.sh --help for optional arguments

The process is essentially 3 steps.
0) Run chmod +x patcher.sh to make sure it is executable
1) Run ./patcher.sh from the terminal. 
2) Apply the patch to your kernel using insmod, modprobe etc as you would with any other kernel module. Make sure you unload the old module before loading the new one. There are extra steps required to get the kernel to use the new driver on boot, but that can vary by distribution.

You can use the scripts in the utilities folder to verify the device is working. See the readme in that folder for more details.

If the script fails or you prefer to run the commands yourself you can follow the steps below to compile the patch. If you perform the steps manually, make sure the "drivers" folder from your kernel is in the "kernel_to_mod" folder.



--- Script performs the steps below ---
0) Detects and downloads the correct kernel source [Optional]
1) Copies the drivers folder to kernel_to_patch
2) Applies the appropriate patch file for your kernel
    a) If you have kernel version 4.11.x or 4.12.x:
        Runs "patch -u kernel_to_patch/drivers/tty/serial/8250/8250_exar.c -i 8250_exar_4.11-4.12.patch"
    b) If you have kernel version 4.13 or higher:
        Runs "patch -u kernel_to_patch/drivers/tty/serial/8250/8250_exar.c -i 8250_exar_4.13+.patch"
3) Runs "patch -u kernel_to_patch/drivers/tty/serial/8250/ -i Makefile.patch"
4) Runs "cd kernel_to_patch/drivers/tty/serial/8250_exar/ && make"
5) Copies the compiled kernel module (.ko) file to the directory this readme is in for easy access
6) The module is now compiled and ready to be loaded with insmod, modprobe, etc as any other module would be. Make sure you unload the old module before loading the new one. There are extra steps required to get the kernel to use the new driver on boot, but that can vary by distribution.

Contact support at 864-843-4343 or support@sealevel.com if you have any issues or questions.

Written by Matthew Howell


