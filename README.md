# UART Byte Transmitter (Version 2.0)

## 📖 Project Overview
This module is a **Universal Asynchronous Receiver-Transmitter (UART)** designed for FPGA systems. It converts 8-bit parallel data into a serial bitstream to communicate with a PC or another microcontroller at a standard **9600 Baud Rate**.

### Key Evolution: The Handshake Model
Earlier versions used a fixed 1-second timer ("Heartbeat"). This version implements an **Asynchronous Handshake**, meaning it only sends data when requested by an external signal (`Send_Go`) and provides feedback when finished (`Tx_Done`).

---

## ⚙️ Hardware Specifications
* **System Clock:** 50 MHz (20ns period)
* **Baud Rate:** 9600 bps
* **Data Frame:** 10 bits (1 Start bit, 8 Data bits, 1 Stop bit)
* **Parity:** None
* **Bit Order:** LSB (Least Significant Bit) First

### The Math (Baud Generation)
To achieve 9600 Baud on a 50 MHz clock, we calculate the number of clock ticks per bit:
**Ticks = 50,000,000 Hz / 9,600 bps = 5208.33...**

The hardware uses a counter (`MCNT_BAUD`) that counts from **0 to 5207**.

---

## 🔌 Interface Signals

| Signal | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| Clk | Input | Wire | 50MHz System Clock |
| Reset_n | Input | Wire | Active-Low Reset (0 = Reset) |
| Send_Go | Input | Wire | Trigger pulse (1 cycle) to start transmission |
| Data[7:0] | Input | Wire | The 8-bit byte to be sent |
| uart_tx | Output | Reg | The physical serial output wire (Idle = 1) |
| Tx_Done | Output | Reg | High for 1 cycle when transmission finishes |

---

## 🏗️ Internal Architecture

### 1. Data Latching (The Snapshot)
To prevent data corruption, the module captures the `Data` input into an internal register `r_Data` the exact moment `Send_Go` is pulsed. This allows the external system to change the data wires immediately without affecting the ongoing slow serial process.

### 2. The State Metronome
* **Baud Counter:** A 13-bit counter that pulses every 5208 clock cycles.
* **Bit Counter:** A 4-bit counter that tracks the 10-bit frame (0 = Start, 1-8 = Data, 9 = Stop).

### 3. Output Multiplexing
A `case` statement acts as a digital switch, routing the correct bit to the `uart_tx` pin based on the `bit_cnt`.

---

## 🧪 Simulation & Verification

### The `defparam` Technique
Because simulating a 9600 Baud rate takes millions of nanoseconds, the Testbench (`uart_byte_tx_tb.v`) uses `defparam` to override the timing constants for faster simulation:

```verilog
defparam dut.MCNT_BAUD = 5 - 1; // 5 ticks per bit for fast simulation

