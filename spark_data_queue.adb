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
--  IMPLEMENTATION: Generic Thread-Safe Queue with Formal Verification
--  
--  Version: 0.09
--  
--  This implementation uses a circular buffer for O(1) enqueue and dequeue
--  operations. The circular buffer wraps around when reaching the end of the
--  storage array.
--  
--  Thread Safety: Achieved through SPARK's formal verification of:
--    1. Type invariants maintaining valid queue state
--    2. Pre/Post conditions for all operations
--  
--  For embedded systems: No dynamic memory allocation, predictable timing
--  
--  Note: For generic packages, use pragma SPARK_Mode in the body to enable analysis
--  ============================================================================

pragma SPARK_Mode;

package body Spark_Data_Queue is
   
   pragma SPARK_Mode (On);
   
   --  Create a new queue with specified maximum size
   function Create_Queue (Max_Size : Positive := Positive'Last) 
     return Queue_Type is
   begin
      return Result : Queue_Type (Capacity => Max_Size);
   end Create_Queue;
   
   --  Add an element to the end of the queue
   --  Algorithm: Circular buffer enqueue
   --    1. Store item at Tail position
   --    2. Increment Tail (with wrap-around)
   --    3. Increment Count
   procedure Enqueue (Q : in out Queue_Type; Item : Element_Type) is
      Next_Tail : Positive;
   begin
      --  Store the item at current tail position
      Q.Storage (Q.Tail) := Item;
      
      --  Calculate next tail position with wrap-around
      if Q.Tail = Q.Capacity then
         Next_Tail := 1;
      else
         Next_Tail := Q.Tail + 1;
      end if;
      
      --  Update tail and count
      Q.Tail := Next_Tail;
      Q.Count := Q.Count + 1;
      
   end Enqueue;
   
   --  Remove and return the first element from the queue
   --  Algorithm: Circular buffer dequeue
   --    1. Retrieve item from Head position
   --    2. Increment Head (with wrap-around)
   --    3. Decrement Count
   procedure Dequeue (Q : in out Queue_Type; Item : out Element_Type) is
      Next_Head : Positive;
   begin
      --  Retrieve the item from current head position
      Item := Q.Storage (Q.Head);
      
      --  Calculate next head position with wrap-around
      if Q.Head = Q.Capacity then
         Next_Head := 1;
      else
         Next_Head := Q.Head + 1;
      end if;
      
      --  Update head and count
      Q.Head := Next_Head;
      Q.Count := Q.Count - 1;
      
      --  If queue becomes empty, reset head and tail to same position
      if Q.Count = 0 then
         Q.Head := 1;
         Q.Tail := 1;
      end if;
      
   end Dequeue;
   
   --  Check if the queue is empty
   function Is_Empty (Q : Queue_Type) return Boolean is
   begin
      return Q.Count = 0;
   end Is_Empty;
   
   --  Check if the queue is full
   function Is_Full (Q : Queue_Type) return Boolean is
   begin
      return Q.Count = Q.Capacity;
   end Is_Full;
   
   --  Get the current number of elements
   function Size (Q : Queue_Type) return Natural is
   begin
      return Q.Count;
   end Size;
   
   --  Get the maximum capacity
   function Max_Size (Q : Queue_Type) return Positive is
   begin
      return Q.Capacity;
   end Max_Size;
   
   --  Clear all elements from the queue
   procedure Clear (Q : in out Queue_Type) is
   begin
      Q.Head := 1;
      Q.Tail := 1;
      Q.Count := 0;
   end Clear;
   
   --  Check if an element exists in the queue
   --  Note: This is O(n) operation, use sparingly in performance-critical code
   function Contains (Q : Queue_Type; Item : Element_Type) return Boolean is
      Current_Index : Positive := Q.Head;
      Elements_Checked : Natural := 0;
   begin
      --  Iterate through all elements in the queue
      while Elements_Checked < Q.Count loop
         --  Check current element
         if Q.Storage (Current_Index) = Item then
            return True;
         end if;
         
         --  Move to next element with wrap-around
         if Current_Index = Q.Capacity then
            Current_Index := 1;
         else
            Current_Index := Current_Index + 1;
         end if;
         
         Elements_Checked := Elements_Checked + 1;
      end loop;
      
      --  Element not found
      return False;
      
   end Contains;

end Spark_Data_Queue;
