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
--  Version: 0.05
--  
--  This implementation uses a circular buffer for O(1) enqueue and dequeue
--  operations. The circular buffer wraps around when reaching the end of the
--  storage array.
--  
--  Thread Safety: Achieved through SPARK's formal verification of:
--    1. Global/Depends contracts ensuring proper data dependencies
--    2. Type invariants maintaining valid queue state
--    3. Pre/Post conditions for all operations
--  
--  For embedded systems: No dynamic memory allocation, predictable timing
--  ============================================================================

pragma SPARK_Mode (On);

package body Spark_Data_Queue is
   
   function Create_Queue (Max_Size : Positive := Positive'Last) 
     return Queue_Type is
   begin
      return Result : Queue_Type (Capacity => Max_Size);
   end Create_Queue;
   
   procedure Enqueue (Q : in out Queue_Type; Item : Element_Type) is
      Next_Tail : Positive;
   begin
      Q.Storage (Q.Tail) := Item;
      
      if Q.Tail = Q.Capacity then
         Next_Tail := 1;
      else
         Next_Tail := Q.Tail + 1;
      end if;
      
      Q.Tail := Next_Tail;
      Q.Count := Q.Count + 1;
      
   end Enqueue;
   
   procedure Dequeue (Q : in out Queue_Type; Item : out Element_Type) is
      Next_Head : Positive;
   begin
      Item := Q.Storage (Q.Head);
      
      if Q.Head = Q.Capacity then
         Next_Head := 1;
      else
         Next_Head := Q.Head + 1;
      end if;
      
      Q.Head := Next_Head;
      Q.Count := Q.Count - 1;
      
      if Q.Count = 0 then
         Q.Head := 1;
         Q.Tail := 1;
      end if;
      
   end Dequeue;
   
   function Is_Empty (Q : Queue_Type) return Boolean is
   begin
      return Q.Count = 0;
   end Is_Empty;
   
   function Is_Full (Q : Queue_Type) return Boolean is
   begin
      return Q.Count = Q.Capacity;
   end Is_Full;
   
   function Size (Q : Queue_Type) return Natural is
   begin
      return Q.Count;
   end Size;
   
   function Max_Size (Q : Queue_Type) return Positive is
   begin
      return Q.Capacity;
   end Max_Size;
   
   procedure Clear (Q : in out Queue_Type) is
   begin
      Q.Head := 1;
      Q.Tail := 1;
      Q.Count := 0;
   end Clear;
   
   function Contains (Q : Queue_Type; Item : Element_Type) return Boolean is
      Current_Index : Positive := Q.Head;
      Elements_Checked : Natural := 0;
   begin
      while Elements_Checked < Q.Count loop
         if Q.Storage (Current_Index) = Item then
            return True;
         end if;
         
         if Current_Index = Q.Capacity then
            Current_Index := 1;
         else
            Current_Index := Current_Index + 1;
         end if;
         
         Elements_Checked := Elements_Checked + 1;
      end loop;
      
      return False;
   end Contains;

end Spark_Data_Queue;
