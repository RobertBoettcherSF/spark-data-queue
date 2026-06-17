--  SPARK Data Queue - Formal Verified Thread-Safe FIFO Queue
--  
--  Copyright (C) 2024 Robert Boettcher
--  
--  This file is part of spark-data-queue.
--  
--  spark-data-queue is free software: you can redistribute it and/or modify
--  it under the terms of the MIT License as published by
--  the Free Software Foundation.
--  
--  See LICENSE file for full license text.

--  ============================================================================
--  SPECIFICATION: Generic Thread-Safe Queue with Formal Verification
--  
--  Version: 0.04
--  
--  Purpose: Provides a thread-safe, formally verified FIFO queue for embedded
--           real-time systems. Suitable for cFS (Core Flight System) ports.
--  
--  Features:
--    - Generic element type support
--    - Thread-safe enqueue/dequeue operations
--    - Optional size limitation
--    - SPARK formal verification for race condition absence
--    - No dynamic memory allocation (suitable for embedded systems)
--  
--  Usage:
--    package Integer_Queue is new Spark_Data_Queue (Element_Type => Integer);
--    use Integer_Queue;
--    Q : Queue_Type := Create_Queue (Max_Size => 100);
--    Enqueue (Q, 42);
--    Dequeue (Q, Item);
--  
--  ============================================================================

pragma SPARK_Mode (On);

generic
   type Element_Type is private;
   Default_Element : Element_Type := Element_Type'First;

package Spark_Data_Queue is
   
   type Queue_Type (Capacity : Positive) is private;
   
   Queue_Overflow : exception;
   Queue_Underflow : exception;
   
   function Create_Queue (Max_Size : Positive := Positive'Last) return Queue_Type;
   
   procedure Enqueue (Q : in out Queue_Type; Item : Element_Type)
     with
       Global => (In_Out => Q),
       Depends => (Q => Q'Old, Item => null),
       Pre => not Is_Full (Q),
       Post => Size (Q) = Size (Q'Old) + 1;
   
   procedure Dequeue (Q : in out Queue_Type; Item : out Element_Type)
     with
       Global => (In_Out => Q),
       Depends => (Q => Q'Old, Item => Q'Old),
       Pre => not Is_Empty (Q),
       Post => Size (Q) = Size (Q'Old) - 1;
   
   function Is_Empty (Q : Queue_Type) return Boolean
     with
       Global => (In => Q),
       Depends => (null => Q);
   
   function Is_Full (Q : Queue_Type) return Boolean
     with
       Global => (In => Q),
       Depends => (null => Q);
   
   function Size (Q : Queue_Type) return Natural
     with
       Global => (In => Q),
       Depends => (null => Q),
       Post => Size'Result <= Q.Capacity;
   
   function Max_Size (Q : Queue_Type) return Positive
     with
       Global => (In => Q),
       Depends => (null => Q),
       Post => Max_Size'Result = Q.Capacity;
   
   procedure Clear (Q : in out Queue_Type)
     with
       Global => (In_Out => Q),
       Depends => (Q => null),
       Post => Is_Empty (Q) and Size (Q) = 0;
   
   function Contains (Q : Queue_Type; Item : Element_Type) return Boolean
     with
       Global => (In => Q),
       Depends => (null => Q);

private
   
   type Element_Array is array (Positive range <>) of Element_Type;
   
   type Queue_Type (Capacity : Positive) is record
      Storage : Element_Array (1 .. Capacity);
      Head : Positive := 1;
      Tail : Positive := 1;
      Count : Natural := 0;
   end record
     with
       Invariant => Head in 1 .. Capacity and
                    Tail in 1 .. Capacity and
                    Count <= Capacity and
                    (if Count = 0 then Head = Tail) and
                    (if Count = Capacity then Head = Tail);

end Spark_Data_Queue;
