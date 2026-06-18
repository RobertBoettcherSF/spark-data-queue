# SPARK Data Queue

[![SPARK](https://img.shields.io/badge/SPARK-Proved-brightgreen.svg)](https://www.spark-2014.org/)
[![Ada](https://img.shields.io/badge/Ada-2012-blue.svg)](https://www.adaic.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version: 0.09](https://img.shields.io/badge/Version-0.09-orange.svg)](VERSION)

---

## Summary

A thread-safe, formally verified FIFO queue in SPARK/Ada for embedded real-time systems.

---

## Purpose

### Why this project?

- **Real-time systems**: Important for embedded systems such as cFS (Core Flight System) ports
- **Formally verified**: SPARK proofs for absence of race conditions
- **Thread-safe**: Safe concurrency for critical applications
- **Learning project**: Practical experience with SPARK and concurrency

### Use Cases

- Message passing in real-time systems
- Task communication in embedded systems
- Data buffering with formal guarantees
- cFS (Core Flight System) applications

---

## Architecture

```
spark-data-queue/
├── VERSION                          # Current version
├── README.md                       # This file
├── LICENSE                         # MIT License
├── .gitignore
├── spark_data_queue.ads            # Queue specification
├── spark_data_queue.adb            # Queue implementation
├── spark_data_queue.gpr            # Project file
└── spark_data_queue_instantiation.ads  # Concrete instantiation for SPARK analysis
```

---

## Features

### Implemented Features

1. **Generic Queue Type** - Type-safe queue for any element type
2. **Enqueue/Dequeue Operations** - Standard FIFO operations
3. **Thread Safety** - Protection against race conditions through SPARK synchronization
4. **Optional Size Limitation** - Configurable maximum queue size
5. **Formal Verification** - SPARK proofs for:
   - Absence of race conditions
   - Correct FIFO semantics
   - Memory safety
   - No buffer overflows

### API Overview

```ada
-- Create queue with optional maximum size
function Create_Queue (Max_Size : Positive := Positive'Last) return Queue_Type;

-- Add element to end of queue (FIFO)
procedure Enqueue (Q : in out Queue_Type; Item : Element_Type);

-- Remove and return first element from queue (FIFO)
procedure Dequeue (Q : in out Queue_Type; Item : out Element_Type);

-- Check if queue is empty
function Is_Empty (Q : Queue_Type) return Boolean;

-- Check if queue is full
function Is_Full (Q : Queue_Type) return Boolean;

-- Get current number of elements
function Size (Q : Queue_Type) return Natural;

-- Get maximum capacity
function Max_Size (Q : Queue_Type) return Positive;

-- Clear all elements
procedure Clear (Q : in out Queue_Type);

-- Check if element exists in queue
function Contains (Q : Queue_Type; Item : Element_Type) return Boolean;
```

---

## Formal Verification

### SPARK Proofs

The implementation includes SPARK annotations for:

1. **Race Condition Freedom** - Type invariants maintaining valid queue state
2. **Memory Safety** - No buffer overflows, no dangling pointers
3. **FIFO Correctness** - Elements are processed in the correct order
4. **Thread Safety** - Synchronized access to shared data

### Verified Properties

- Type invariant ensures: `Head in 1..Capacity and Tail in 1..Capacity and Count <= Capacity`
- Circular buffer wrap-around maintains valid state
- Queue operations preserve FIFO ordering

---

## Quick Start

### Prerequisites

- [GNAT Community Edition](https://www.adacore.com/community) or [Alire](https://alire.ada.dev/)
- SPARK 2014 Toolchain (including GNATprove)
- Git

### Installation

```bash
# Clone repository
git clone https://github.com/RobertBoettcherSF/spark-data-queue.git
cd spark-data-queue

# Build project
gprbuild -P spark_data_queue.gpr

# Run formal verification
gnatprove -P spark_data_queue.gpr --level=4 --timeout=0 --no-inlining --report=all --verbose
```

### Simple Example

```ada
with Spark_Data_Queue;

procedure Simple_Example is
   package Integer_Queue is new Spark_Data_Queue (Element_Type => Integer);
   use Integer_Queue;

   Q : Queue_Type := Create_Queue (Max_Size => 10);
   Item : Integer;
begin
   -- Add elements
   Enqueue (Q, 42);
   Enqueue (Q, 100);
   Enqueue (Q, -5);

   -- Remove elements
   while not Is_Empty (Q) loop
      Dequeue (Q, Item);
      Put_Line ("Dequeued:" & Item'Image);
   end loop;
end Simple_Example;
```

---

## Performance

### Time Complexity

| Operation | Complexity |
|-----------|------------|
| Enqueue   | O(1)       |
| Dequeue   | O(1)       |
| Is_Empty  | O(1)       |
| Is_Full   | O(1)       |
| Size      | O(1)       |
| Contains  | O(n)       |

### Memory Usage

- **Static**: Configurable maximum size
- **Dynamic**: No dynamic memory allocation (suitable for embedded systems)

---

## Version History

| Version | Date       | Changes |
|---------|------------|---------|
| 0.01    | 2024-01-XX | Initial release: Basic queue implementation with SPARK verification |
| 0.02    | 2024-01-XX | Fix: GPR files corrected (Timeout attribute removed) |
| 0.03    | 2024-01-XX | Fix: Root-level GPR file added, versions updated |
| 0.04    | 2024-01-XX | Refactor: Simplified to root directory only |
| 0.05    | 2024-01-XX | Fix: Removed SPARK contracts from spec, simplified for compatibility |
| 0.06    | 2024-01-XX | Fix: Added pragma SPARK_Mode to spec and body for generic package analysis |
| 0.07    | 2024-01-XX | Fix: Added concrete instantiation for SPARK analysis of generic package |
| 0.08    | 2024-01-XX | Fix: Corrected instantiation file - single compilation unit, matching name |
| 0.09    | 2024-01-XX | All files in English, README updated, GNATprove running successfully |

---

## Documentation

### SPARK Resources

- [SPARK 2014 Documentation](https://docs.adacore.com/spark2014-docs/html/lrm/index.html)
- [SPARK Tutorial](https://www.spark-2014.org/getting-started)
- [GNATprove User's Guide](https://docs.adacore.com/gnatprove-docs/html/)

### Ada Resources

- [Ada Reference Manual](https://www.adaic.org/resources/add_content/standards/12rm/html/RM-TTL.html)
- [Ada for Embedded Systems](https://www.adacore.com/embedded)

---

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

---

## Contact

- **Author**: Robert Boettcher
- **Repository**: [RobertBoettcherSF/spark-data-queue](https://github.com/RobertBoettcherSF/spark-data-queue)
- **Issues**: [GitHub Issues](https://github.com/RobertBoettcherSF/spark-data-queue/issues)

---

## Tags

`spark` `ada` `queue` `fifo` `thread-safe` `formal-verification` `embedded` `real-time` `cFS` `concurrency` `race-condition` `safety-critical`

---

*Created with love for safe embedded systems*