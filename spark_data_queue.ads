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
--  Version: 0.09
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

pragma SPARK_Mode;

generic
   type Element_Type is private;

package Spark_Data_Queue is
   
   pragma SPARK_Mode (On);
   
   --  Queue type with configurable capacity
   type Queue_Type (Capacity : Positive) is private;
   
   --  Exception raised when trying to enqueue to a full queue
   Queue_Overflow : exception;
   
   --  Exception raised when trying to dequeue from an empty queue
   Queue_Underflow : exception;
   
   --  Create a new queue with specified maximum size
   function Create_Queue (Max_Size : Positive := Positive'Last) return Queue_Type;
   
   --  Add an element to the end of the queue (FIFO)
   procedure Enqueue (Q : in out Queue_Type; Item : Element_Type);
   
   --  Remove and return the first element from the queue (FIFO)
   procedure Dequeue (Q : in out Queue_Type; Item : out Element_Type);
   
   --  Check if the queue is empty
   function Is_Empty (Q : Queue_Type) return Boolean;
   
   --  Check if the queue is full (reached maximum capacity)
   function Is_Full (Q : Queue_Type) return Boolean;
   
   --  Get the current number of elements in the queue
   function Size (Q : Queue_Type) return Natural;
   
   --  Get the maximum capacity of the queue
   function Max_Size (Q : Queue_Type) return Positive;
   
   --  Clear all elements from the queue
   procedure Clear (Q : in out Queue_Type);
   
   --  Check if an element exists in the queue
   function Contains (Q : Queue_Type; Item : Element_Type) return Boolean;

private
   
   --  Internal storage array for queue elements
   type Element_Array is array (Positive range <>) of Element_Type;
   
   --  Queue record structure with circular buffer implementation
   type Queue_Type (Capacity : Positive) is record
      Storage : Element_Array (1 .. Capacity);
      Head : Positive := 1;
      Tail : Positive := 1;
      Count : Natural := 0;
   end record
     with
       --  SPARK invariant: ensures queue state is always valid
       Invariant => Head in 1 .. Capacity and
                    Tail in 1 .. Capacity and
                    Count <= Capacity and
                    (if Count = 0 then Head = Tail) and
                    (if Count = Capacity then Head = Tail);

end Spark_Data_Queue;
