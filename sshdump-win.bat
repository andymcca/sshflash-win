@echo off

rem *** sshdump-win ***
rem A fork of sshflash for Windows, by andymcca. sshflash originally by mac2612 (https://github.com/mac2612/sshdump).
rem Version 0.3 (2023-02-01) 
rem
rem Keys Information -
rem 
rem As of version 0.3, keys are not used to connect via SSH.

SET SSH=ssh root@169.254.8.1

call :show_warning
SET prefix=%~1
call :show_machinelist
echo Enter choice (1 - 4)
SET /P REPLY=
if /I "%REPLY%" == "1" (SET prefix="lf1000_didj_")
if /I "%REPLY%" == "2" (SET prefix="lf1000_")
if /I "%REPLY%" == "3" (SET prefix="lf2000_")
if /I "%REPLY%" == "4" (SET prefix="lf3000_")
timeout /t 2

echo.
echo Choose dump option:
echo 1. Dump Operating System (OS) only
echo 2. Dump Entire Root of Device (Warning: May exceed 1GB)
echo.
SET /P DUMP_OPTION="Enter option (1 or 2): "

IF /I "%prefix%" == "lf3000_" (call :dump_mmc "%prefix%" %DUMP_OPTION%) ELSE (call :dump_nand "%prefix%" %DUMP_OPTION%)
EXIT /B %ERRORLEVEL%


:show_warning
cls
echo sshdump-win ver 0.3 (forked from sshdump by mac2612 - https://github.com/mac2612/sshdump)
echo Dumps the operating system and data from your LeapPad/Leapster!
echo(
echo WARNING! This utility will ERASE the dumped data on the device. 
echo The data can be restored using appropriate tools. 
echo Ensure you have proper backups before proceeding.
echo(
echo WARNING! Dumping the entire root may result in a large file size, potentially exceeding 1GB.
echo(
echo Please power off your device, and do the following -
echo(
echo Leapster Explorer - Hold the L + R shoulder buttons AND the Hint (?) button whilst powering on
echo LeapsterGS - Hold the L + R shoulder buttons whilst powering on 
echo LeapPad2 - Hold the Right arrow + Home buttons whilst powering on.
echo(
echo You should see a screen with a green background and a picture of the device
echo connecting to a computer.
pause
EXIT /B 0

:show_machinelist
echo ----------------------------------------------------------------
echo What type of system would you like to dump?
echo(
echo 1. LF1000-Didj (Didj with EmeraldBoot)
echo 2. LF1000 (Leapster Explorer)
echo 3. LF2000 (Leapster GS, LeapPad 2, LeapPad Ultra XDI)
echo 4. LF3000 (LeapPad 3, LeapPad Platinum)
EXIT /B 0

:boot_surgeon
SET surgeon_path=%~1
SET memloc=%~2
echo Booting the Surgeon environment...
make_cbf.exe %memloc:"=% %surgeon_path:"=% surgeon_tmp.cbf
echo Lines to write (should be a whole number) -
boot_surgeon.exe surgeon_tmp.cbf
echo Done! Waiting for Surgeon to come up...
DEL surgeon_tmp.cbf
timeout /t 15
echo Done!
EXIT /B 0

:nand_part_detect
rem Probe for filesystem partition locations, they can vary based on kernel version + presence of NOR flash drivers.
rem TODO- Make the escaping less yucky...

SET SPACE=" "
SET KP=awk -e '$4 ~ \"Kernel\"  {print \"/dev/\" substr($1, 1, length($1)-1)}' /proc/mtd
rem SET "var=%SSH%%SPACE:"=%%KP%"
rem echo %SSH:"=% "%KP%"
FOR /f %%i in ('%SSH:"=% "%KP%"') do set "KERNEL_PARTITION=%%i"

SET RP=awk -e '$4 ~ \"RFS\"  {print \"/dev/\" substr($1, 1, length($1)-1)}' /proc/mtd
SET "var=%SSH%%SPACE:"=%%RP%"
FOR /f %%i in ('%SSH:"=% "%RP%"') do set "RFS_PARTITION=%%i"

echo "Detected Kernel partition=%KERNEL_PARTITION% RFS Partition=%RFS_PARTITION%"
EXIT /B 0

:nand_dump_os
echo Dumping the Operating System...
%SSH% "dd if=%KERNEL_PARTITION% of=OS_dump.bin bs=1M count=50"
echo Done dumping the Operating System!
EXIT /B 0

:nand_dump_root
echo Dumping the Entire Root of the Device...
%SSH% "tar czvf root_dump.tar.gz /"
echo Done dumping the Entire Root of the Device!
EXIT /B 0

:dump_nand
SET prefix=%~1
SET dump_option=%~2
if /I %prefix:"=% == lf1000_ (set memloc="high") else (set memloc="superhigh")

call :boot_surgeon %prefix:"=%surgeon_zImage %memloc:"=%
rem For the first ssh command, skip hostkey checking to avoid prompting the user.
%SSH% -o "StrictHostKeyChecking no" 'test'
call :nand_part_detect
  
if /I "%dump_option%" == "1" (call :nand_dump_os) else (call :nand_dump_root)

echo Done! Rebooting the host.
%SSH% '/sbin/reboot'
EXIT /B 0

:mmc_dump_os
echo Dumping the Operating System...
%SSH% "dd if=/dev/mmcblk0 of=OS_dump.bin bs=1M count=50"
echo Done dumping the Operating System!
EXIT /B 0

:mmc_dump_root
echo Dumping the Entire Root of the Device...
%SSH% "tar czvf root_dump.tar.gz /"
echo Done dumping the Entire Root of the Device!
EXIT /B 0

:dump_mmc
SET prefix=%~1
SET dump_option=%~2
call :boot_surgeon %prefix%surgeon_zImage superhigh
rem For the first ssh command, skip hostkey checking to avoid prompting the user.
%SSH% -o "StrictHostKeyChecking no" 'test'
if /I "%dump_option%" == "1" (call :mmc_dump_os) else (call :mmc_dump_root)

echo Done! Rebooting the host.
%SSH% '/sbin/reboot'
EXIT /B 0
