@echo off

rem *** sshdump-win ***
rem A fork of sshdump for Windows, by andymcca. sshdump originally by mac2612 (https://github.com/mac2612/sshdump).
rem Version 0.3 (2023-02-01) 
rem
rem Keys Information -
rem 
rem As of version 0.3, keys are no longer used to connect via SSH.
rem This reflects the upcoming change in retroleap to remove key-based access, as the RSA standard is deprecated and this was causing issues with dumping.
SET SSH=ssh root@169.254.8.1

rem Fix the permissions on the "private key", so ssh does not complain.
rem sshdump-win - Not required on Windows so is commented out here.
rem chmod 700 keys\id_rsa

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

IF /I "%prefix%" == "lf3000_" (call :dump_mmc "%prefix%") ELSE (call :dump_nand "%prefix%")
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

:dump_os
  rem Function to dump the operating system.
  rem Add commands here to dump the OS from the device.
  rem Replace the comments with actual commands.
  rem Example:
  rem %SSH% "dump_os_command_here"
  echo Dumping the operating system...
  echo OS dumped successfully!
EXIT /B 0

:dump_other_data
  rem Function to dump other data from the device.
  rem Add commands here to dump specific data.
  rem Replace the comments with actual commands.
  rem Example:
  rem %SSH% "dump_data_command_here"
  echo Dumping other data...
  echo Other data dumped successfully!
EXIT /B 0

:dump_nand
  rem Function to dump data from NAND-based devices.
  SET prefix=%~1
  call :boot_surgeon %prefix:"=%surgeon_zImage superhigh
  rem For the first ssh command, skip hostkey checking to avoid prompting the user.
  %SSH% -o "StrictHostKeyChecking no" 'test'
  call :nand_part_detect
  call :dump_os
  call :dump_other_data
  echo Done! Exiting.
EXIT /B 0

:dump_mmc
  rem Function to dump data from MMC-based devices.
  SET prefix=%~1
  call :boot_surgeon %prefix%surgeon_zImage superhigh
  rem For the first ssh command, skip hostkey checking to avoid prompting the user.
  %SSH% -o "StrictHostKeyChecking no" 'test'
  call :dump_os
  call :dump_other_data
  echo Done! Exiting.
EXIT /B 0
