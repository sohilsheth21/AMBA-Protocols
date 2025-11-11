# AMBA-Protocols

This repository contains Verilog RTL and testbench implementations of **AMBA (Advanced Microcontroller Bus Architecture)** protocols — starting with the **APB (Advanced Peripheral Bus)**.  
Each module is built with clean synthesizable RTL, self-checking testbenches, and detailed comments for learning and verification purposes.

---

## 📘 Overview

The AMBA family of protocols (APB, AHB, AXI) are widely used for **on-chip communication** in SoCs.  
This repository aims to provide Verilog models for these protocols, starting with **APB** and expanding toward **AHB** and **AXI** later.

### Current Progress
| Protocol | Implementation | Features Covered | Status |
|-----------|----------------|------------------|---------|
| **APB** | Master + Slave + Testbench | Basic handshake, Wait states, Error signaling | ✅ Complete |
| **AHB** | — | Planned | ⏳ Upcoming |
| **AXI** | — | Basic Handshkae protocol for AXI Stream | ⏳ Stream IPs, AXI Lite, AXI Full |

---

## 🧠 APB Protocol Summary

**APB (Advanced Peripheral Bus)** is a simple, low-power bus interface used for connecting peripherals.  
It uses a **two-phase transfer**: Setup and Access, with optional **wait states** for slow slaves.

### 🔁 APB Handshake
| Signal | Description |
|--------|-------------|
| `PADDR` | Address bus |
| `PWRITE` | Write enable (1 = write, 0 = read) |
| `PSEL` | Slave select |
| `PENABLE` | Indicates Access phase |
| `PREADY` | Slave ready (insert wait states if low) |
| `PRDATA` / `PWDATA` | Read/Write data |
| `PSLVERR` | Indicates error on access |

---

## ⚙️ Implementation Details

### 🧱 Basic APB
- Implements **standard APB two-phase transfer**
- Supports **read/write** operations
- Clean **finite state machine (FSM)** for master and slave

### ⚙️ Advanced APB (Wait + Error)
- Adds **S-WAIT** signal to handle wait states
- Adds **PSLVERR** signal for error responses
