<div align="right">

[中文](README.md) | [English](README_EN.md)

</div>

# CCIC Robotarm

This repository contains the robotic-arm control part of a 2025 China Integrated Circuit Innovation Competition FPGA application-track project. The vision-recognition part is maintained in a separate repository.

## Project Overview

The design runs on an Intel Cyclone IV E (`EP4CE6F17C8`) platform with Quartus Prime Lite 23.1. After a trigger event, the top-level state machine completes one automatic handling cycle:

1. Calculate the robotic-arm posture from the target `(x, y)` coordinate.
2. Send five servo poses over UART.
3. Control the air pump to pick and release objects.
4. Query target bin coordinates and direction from the warehouse number.
5. Place the object and return to the initial position.

## Notes

If the IP-core version does not match your Quartus version, update the version field in the `.qip` file to match your installed Quartus release.
