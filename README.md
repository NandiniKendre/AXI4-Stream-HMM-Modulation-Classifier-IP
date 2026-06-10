# AXI4-Stream HMM Modulation Classifier IP

## Overview

This project implements a custom **AXI4-Stream compatible Hidden Markov Model (HMM)-inspired modulation classifier** in Verilog HDL. It accepts an input feature through the AXI4-Stream slave interface, computes likelihood values for different modulation schemes, and outputs the detected modulation ID through the AXI4-Stream master interface.

The design is implemented as a finite state machine (FSM) and packaged as a reusable custom IP for FPGA-based systems.

## Features

* AXI4-Stream compliant interface
* Verilog HDL implementation
* FSM-based processing architecture
* Likelihood-based classification logic
* Supports four modulation schemes:

  * BPSK
  * QPSK
  * QAM
  * FSK
* Vivado IP Packager compatible
* Includes simulation testbench

## Architecture

```
        AXI4-Stream Input
               │
               ▼
      +-------------------+
      |  Feature Register |
      +-------------------+
               │
               ▼
      +-------------------+
      | Likelihood Engine |
      +-------------------+
               │
               ▼
      +-------------------+
      | Decision Logic    |
      +-------------------+
               │
               ▼
       AXI4-Stream Output
```

## Finite State Machine

```
IDLE
  │
  ▼
COMPUTE
  │
  ▼
OUTPUT
  │
  └────────► IDLE
```

## Classification Logic

The classifier assigns likelihood scores based on the input feature range.

| Feature Range | Detected Modulation |
| ------------- | ------------------- |
| 0 – 63        | BPSK                |
| 64 – 127      | QPSK                |
| 128 – 191     | QAM                 |
| 192 – 255     | FSK                 |

The modulation with the highest likelihood is selected as the output.

## Interface

### AXI4-Stream Slave

| Signal          | Description        |
| --------------- | ------------------ |
| `s_axis_tvalid` | Input valid signal |
| `s_axis_tready` | Ready signal       |
| `s_axis_tdata`  | Input feature data |

### AXI4-Stream Master

| Signal          | Description            |
| --------------- | ---------------------- |
| `m_axis_tvalid` | Output valid signal    |
| `m_axis_tready` | Output ready signal    |
| `m_axis_tdata`  | Detected modulation ID |

## Testbench

The included testbench verifies the classifier using sample feature values:

| Input Feature | Expected Output |
| ------------- | --------------- |
| 20            | BPSK (`00`)     |
| 90            | QPSK (`01`)     |
| 150           | QAM (`10`)      |
| 220           | FSK (`11`)      |

## Project Structure

```
rtl/
 └── axis_hmm_classifier.v

tb/
 └── tb_axis_hmm_classifier.v
```

## Tools Used

* Verilog HDL
* Xilinx Vivado
* AXI4-Stream Protocol
* Vivado IP Packager

## Future Enhancements

* Implement true HMM probability calculations
* Support additional modulation schemes
* Add AXI-Lite configuration registers
* Pipeline the likelihood computation for higher throughput

## Author

**Nandini Kendre**

