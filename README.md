# sshdump-win

sshdump-win is a Windows batch script utility designed for dumping the operating system and other data from LeapPad/Leapster devices using SSH.

## Overview

This utility enables users to dump the operating system and other data from LeapPad/Leapster devices via SSH connection. It is particularly useful for creating backups of the device's data or extracting specific information for analysis.

## Features

- Dump the operating system from LeapPad/Leapster devices.
- Dump other data from the device as required.
- Supports both NAND-based and MMC-based devices.
- Simple and easy-to-use Windows batch script.

## Prerequisites

- Windows operating system.
- SSH client installed (e.g., OpenSSH, PuTTY).
- LeapPad/Leapster device connected to the same network.

## Usage

1. Ensure your LeapPad/Leapster device is powered off.
2. Connect your device to the same network as your computer.
3. Run `sshdump-win.bat` script.
4. Follow the on-screen instructions to select the device type and initiate the dumping process.
5. Once the dumping process is complete, the data will be saved in the specified directory.

## Warning

- The utility will ERASE the dumped data on the device. Ensure you have proper backups before proceeding.
- Use this utility at your own risk. We are not responsible for any data loss or damage to your device.

## Acknowledgements

- This script is a fork of the original sshdump by mac2612. Thanks to mac2612 for the initial work.
- Special thanks to andymcca for adapting sshdump for Windows.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
