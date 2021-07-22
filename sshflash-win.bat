@echo off

rem We use a public\private keypair to authenticate.
rem Surgeon uses the 169.254.8.X subnet to differentiate itself from a fully booted system for safety purposes.
SET SSH=ssh -i keys\id_rsa root@169.254.8.1
rem Fix the permissions on the "private key" , so ssh does not complain.
rem Not required on Windows so is commented out here.
rem chmod 700 keys\id_rsa

EXIT /B %ERRORLEVEL%

:show_warning
echo "Leapster flash utility - installs a custom OS on your leapster!"
echo -n
echo "WARNING! This utility will ERASE the stock leapster OS and any other"
echo "data on the device. The device can be restored to stock settings using"
echo "the LeapFrog Connect app. Note that flashing your device will likely"
echo "VOID YOUR WARRANTY! Proceed at your own risk."
echo -n
echo "Please power off your leapster, hold the L + R shoulder buttons (LeapsterGS), "
echo "or right arrow + home buttons (LeapPad2), and then press power."
echo "You should see a screen with a green background."
pause
EXIT /B 0

:show_machinelist
echo ----------------------------------------------------------------
echo "What type of system would you like to flash?"
echo -n
echo "1. LF1000-Didj (Didj with EmeraldBoot)"
echo "2. LF1000 (Leapster Explorer)"
echo "3. LF2000 (Leapster GS, LeapPad 2, LeapPad Ultra XDI)"
echo "4. LF3000 (LeapPad 3, LeapPad Platinum)"
EXIT /B 0

:boot_surgeon
SET surgeon_path=%~1
SET memloc=%~2
echo "Booting the Surgeon environment..."
make_cbf.exe %memloc% %surgeon_path% surgeon_tmp.cbf
boot_surgeon.exe surgeon_tmp.cbf
echo -n "Done! Waiting for Surgeon to come up..."
DEL  surgeon_tmp.cbf
sleep 15
echo Done!
EXIT /B 0

:nand_part_detect
rem Probe for filesystem partition locations, they can vary based on kernel version + presence of NOR flash drivers.
rem TODO- Make the escaping less yucky...
SET KP=awk -e "\$4 ~ /"Kernel"/ {print "\dev\" substr(\$1, 1, length(\$1)-1)}" \proc\mtd
FOR \f %%i in %SSH% %KP% do set KERNEL_PARTITION=%%i
SET RP=awk -e "\$4 ~ /"RFS"/ {print "\dev\" substr(\$1, 1, length(\$1)-1)}" \proc\mtd
FOR \f %%i in %SSH% %RP% do set RFS_PARTITION=%%i
echo "Detected Kernel partition=%KERNEL_PARTITION% RFS Partition=%RFS_PARTITION%"
EXIT /B 0
