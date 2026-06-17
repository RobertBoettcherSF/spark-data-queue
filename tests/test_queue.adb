--  SPARK Data Queue - Test Suite
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
--  TEST SUITE: Comprehensive tests for SPARK Data Queue
--  
--  This test suite verifies:
--    - Basic queue operations (enqueue, dequeue)
--    - Queue state checks (empty, full, size)
--    - FIFO behavior
--    - Optional size limitation
--    - Exception handling
--    - Thread safety (conceptual - actual thread tests require Ada.Tasks)
--  
--  Usage:
--    gprbuild -P test_queue.gpr
--    ./obj/test_queue
--  
--  ============================================================================

with Spark_Data_Queue;
with Ada.Text_IO;
with Ada.Integer_Text_IO;

procedure Test_Queue is
   
   --  Test result tracking
   type Test_Result is (Pass, Fail, Error);
   
   Total_Tests : Natural := 0;
   Passed_Tests : Natural := 0;
   Failed_Tests : Natural := 0;
   
   --  Test queue instantiation for Integer type
   package Integer_Queue is new Spark_Data_Queue (Element_Type => Integer);
   use Integer_Queue;
   
   --  Test queue instantiation for Character type
   package Char_Queue is new Spark_Data_Queue (Element_Type => Character);
   use Char_Queue;
   
   --  ========================================================================
   --  TEST UTILITIES
   --  ========================================================================
   
   --  Print test result
   procedure Print_Result (Test_Name : String; Result : Test_Result) is
   begin
      case Result is
         when Pass =>
            Ada.Text_IO.Put_Line ("[PASS] " & Test_Name);
            Passed_Tests := Passed_Tests + 1;
         when Fail =>
            Ada.Text_IO.Put_Line ("[FAIL] " & Test_Name);
            Failed_Tests := Failed_Tests + 1;
         when Error =>
            Ada.Text_IO.Put_Line ("[ERROR] " & Test_Name);
            Failed_Tests := Failed_Tests + 1;
      end case;
      Total_Tests := Total_Tests + 1;
   end Print_Result;
   
   --  Assert equality
   procedure Assert_Equal (Test_Name : String; Actual, Expected : Integer) is
      Result : Test_Result := Pass;
   begin
      if Actual /= Expected then
         Result := Fail;
         Ada.Text_IO.Put_Line ("  Expected: " & Integer'Image (Expected) & 
                              ", Got: " & Integer'Image (Actual));
      end if;
      Print_Result (Test_Name, Result);
   end Assert_Equal;
   
   --  Assert boolean
   procedure Assert (Test_Name : String; Condition : Boolean) is
      Result : Test_Result := Pass;
   begin
      if not Condition then
         Result := Fail;
      end if;
      Print_Result (Test_Name, Result);
   end Assert;
   
   --  ========================================================================
   --  BASIC OPERATION TESTS
   --  ========================================================================
   
   procedure Test_Basic_Operations is
      Q : Queue_Type := Create_Queue (Max_Size => 5);
      Item : Integer;
   begin
      Ada.Text_IO.Put_Line ("");
      Ada.Text_IO.Put_Line ("=== Basic Operations Tests ===");
      
      --  Test 1: New queue is empty
      Assert ("New queue is empty", Is_Empty (Q));
      
      --  Test 2: New queue size is 0
      Assert_Equal ("New queue size is 0", Size (Q), 0);
      
      --  Test 3: New queue is not full
      Assert ("New queue is not full", not Is_Full (Q));
      
      --  Test 4: Enqueue one element
      Enqueue (Q, 42);
      Assert ("Queue not empty after enqueue", not Is_Empty (Q));
      Assert_Equal ("Queue size is 1 after enqueue", Size (Q), 1);
      
      --  Test 5: Dequeue the element
      Dequeue (Q, Item);
      Assert_Equal ("Dequeued item is 42", Item, 42);
      Assert ("Queue empty after dequeue", Is_Empty (Q));
      Assert_Equal ("Queue size is 0 after dequeue", Size (Q), 0);
      
      --  Test 6: Multiple enqueue operations
      Enqueue (Q, 1);
      Enqueue (Q, 2);
      Enqueue (Q, 3);
      Assert_Equal ("Queue size is 3", Size (Q), 3);
      
      --  Test 7: FIFO behavior
      Dequeue (Q, Item);
      Assert_Equal ("First dequeued is 1", Item, 1);
      Dequeue (Q, Item);
      Assert_Equal ("Second dequeued is 2", Item, 2);
      Dequeue (Q, Item);
      Assert_Equal ("Third dequeued is 3", Item, 3);
      
   end Test_Basic_Operations;
   
   --  ========================================================================
   --  QUEUE LIMITATION TESTS
   --  ========================================================================
   
   procedure Test_Queue_Limits is
      Q : Queue_Type := Create_Queue (Max_Size => 3);
      Item : Integer;
   begin
      Ada.Text_IO.Put_Line ("");
      Ada.Text_IO.Put_Line ("=== Queue Limitation Tests ===");
      
      --  Test 1: Max size is correct
      Assert_Equal ("Max size is 3", Max_Size (Q), 3);
      
      --  Test 2: Queue not full with 2 elements
      Enqueue (Q, 1);
      Enqueue (Q, 2);
      Assert ("Queue not full with 2 elements", not Is_Full (Q));
      
      --  Test 3: Queue full with 3 elements
      Enqueue (Q, 3);
      Assert ("Queue full with 3 elements", Is_Full (Q));
      Assert_Equal ("Queue size is 3", Size (Q), 3);
      
      --  Test 4: Cannot enqueue when full (should raise exception)
      begin
         Enqueue (Q, 4);
         Print_Result ("Enqueue on full queue raises exception", Fail);
      exception
         when Queue_Overflow =>
            Print_Result ("Enqueue on full queue raises exception", Pass);
      end;
      
      --  Test 5: Dequeue makes space
      Dequeue (Q, Item);
      Assert ("Queue not full after dequeue", not Is_Full (Q));
      Assert_Equal ("Queue size is 2 after dequeue", Size (Q), 2);
      
      --  Test 6: Can enqueue after making space
      Enqueue (Q, 4);
      Assert_Equal ("Queue size is 3 after enqueue", Size (Q), 3);
      
   end Test_Queue_Limits;
   
   --  ========================================================================
   --  FIFO BEHAVIOR TESTS
   --  ========================================================================
   
   procedure Test_FIFO_Behavior is
      Q : Queue_Type := Create_Queue (Max_Size => 10);
      Item : Integer;
      Expected_Values : array (1 .. 5) of Integer := (10, 20, 30, 40, 50);
   begin
      Ada.Text_IO.Put_Line ("");
      Ada.Text_IO.Put_Line ("=== FIFO Behavior Tests ===");
      
      --  Enqueue multiple values
      for I in 1 .. 5 loop
         Enqueue (Q, Expected_Values (I));
      end loop;
      
      --  Dequeue and verify order
      for I in 1 .. 5 loop
         Dequeue (Q, Item);
         Assert_Equal ("FIFO order preserved - element " & Integer'Image (I), 
                      Item, Expected_Values (I));
      end loop;
      
      --  Test with wrap-around (enqueue more than capacity)
      for I in 1 .. 10 loop
         Enqueue (Q, I);
      end loop;
      
      --  Verify wrap-around FIFO behavior
      for I in 1 .. 10 loop
         Dequeue (Q, Item);
         Assert_Equal ("Wrap-around FIFO - element " & Integer'Image (I), 
                      Item, I);
      end loop;
      
   end Test_FIFO_Behavior;
   
   --  ========================================================================
   --  CLEAR OPERATION TESTS
   --  ========================================================================
   
   procedure Test_Clear_Operation is
      Q : Queue_Type := Create_Queue (Max_Size => 5);
   begin
      Ada.Text_IO.Put_Line ("");
      Ada.Text_IO.Put_Line ("=== Clear Operation Tests ===");
      
      --  Add elements
      Enqueue (Q, 1);
      Enqueue (Q, 2);
      Enqueue (Q, 3);
      Assert_Equal ("Queue size is 3", Size (Q), 3);
      
      --  Clear the queue
      Clear (Q);
      Assert ("Queue empty after clear", Is_Empty (Q));
      Assert_Equal ("Queue size is 0 after clear", Size (Q), 0);
      
      --  Can enqueue after clear
      Enqueue (Q, 42);
      Assert_Equal ("Queue size is 1 after clear and enqueue", Size (Q), 1);
      
   end Test_Clear_Operation;
   
   --  ========================================================================
   --  CONTAINS OPERATION TESTS
   --  ========================================================================
   
   procedure Test_Contains_Operation is
      Q : Queue_Type := Create_Queue (Max_Size => 5);
   begin
      Ada.Text_IO.Put_Line ("");
      Ada.Text_IO.Put_Line ("=== Contains Operation Tests ===");
      
      --  Empty queue
      Assert ("Empty queue does not contain 42", not Contains (Q, 42));
      
      --  Add elements
      Enqueue (Q, 10);
      Enqueue (Q, 20);
      Enqueue (Q, 30);
      
      --  Test contains
      Assert ("Queue contains 10", Contains (Q, 10));
      Assert ("Queue contains 20", Contains (Q, 20));
      Assert ("Queue contains 30", Contains (Q, 30));
      Assert ("Queue does not contain 40", not Contains (Q, 40));
      
      --  Test after dequeue
      declare
         Item : Integer;
      begin
         Dequeue (Q, Item);
         Assert ("Queue does not contain 10 after dequeue", not Contains (Q, 10));
         Assert ("Queue still contains 20", Contains (Q, 20));
      end;
      
   end Test_Contains_Operation;
   
   --  ========================================================================
   --  EXCEPTION HANDLING TESTS
   --  ========================================================================
   
   procedure Test_Exception_Handling is
      Q : Queue_Type := Create_Queue (Max_Size => 2);
      Item : Integer;
   begin
      Ada.Text_IO.Put_Line ("");
      Ada.Text_IO.Put_Line ("=== Exception Handling Tests ===");
      
      --  Test underflow exception
      begin
         Dequeue (Q, Item);
         Print_Result ("Dequeue on empty queue raises exception", Fail);
      exception
         when Queue_Underflow =>
            Print_Result ("Dequeue on empty queue raises exception", Pass);
      end;
      
      --  Test overflow exception
      Enqueue (Q, 1);
      Enqueue (Q, 2);
      begin
         Enqueue (Q, 3);
         Print_Result ("Enqueue on full queue raises exception", Fail);
      exception
         when Queue_Overflow =>
            Print_Result ("Enqueue on full queue raises exception", Pass);
      end;
      
   end Test_Exception_Handling;
   
   --  ========================================================================
   --  DIFFERENT DATA TYPES TESTS
   --  ========================================================================
   
   procedure Test_Different_Data_Types is
      Char_Q : Char_Queue.Queue_Type := Char_Queue.Create_Queue (Max_Size => 5);
      Char_Item : Character;
   begin
      Ada.Text_IO.Put_Line ("");
      Ada.Text_IO.Put_Line ("=== Different Data Types Tests ===");
      
      --  Test with Character type
      Char_Queue.Enqueue (Char_Q, 'A');
      Char_Queue.Enqueue (Char_Q, 'B');
      Char_Queue.Enqueue (Char_Q, 'C');
      
      Assert_Equal ("Char queue size is 3", Char_Queue.Size (Char_Q), 3);
      
      Char_Queue.Dequeue (Char_Q, Char_Item);
      Assert ("First char is 'A'", Char_Item = 'A');
      
      Char_Queue.Dequeue (Char_Q, Char_Item);
      Assert ("Second char is 'B'", Char_Item = 'B');
      
      Char_Queue.Dequeue (Char_Q, Char_Item);
      Assert ("Third char is 'C'", Char_Item = 'C');
      
      Assert ("Char queue is empty", Char_Queue.Is_Empty (Char_Q));
      
   end Test_Different_Data_Types;
   
   --  ========================================================================
   --  CIRCULAR BUFFER WRAP-AROUND TESTS
   --  ========================================================================
   
   procedure Test_Circular_Buffer_Wrap_Around is
      Q : Queue_Type := Create_Queue (Max_Size => 3);
      Item : Integer;
   begin
      Ada.Text_IO.Put_Line ("");
      Ada.Text_IO.Put_Line ("=== Circular Buffer Wrap-Around Tests ===");
      
      --  Fill queue completely
      Enqueue (Q, 1);
      Enqueue (Q, 2);
      Enqueue (Q, 3);
      Assert ("Queue is full", Is_Full (Q));
      
      --  Dequeue one, enqueue one (should wrap around)
      Dequeue (Q, Item);
      Assert_Equal ("Dequeued item is 1", Item, 1);
      
      Enqueue (Q, 4);
      Assert ("Queue is full after wrap-around", Is_Full (Q));
      
      --  Verify FIFO order with wrap-around
      Dequeue (Q, Item);
      Assert_Equal ("Dequeued item is 2", Item, 2);
      
      Dequeue (Q, Item);
      Assert_Equal ("Dequeued item is 3", Item, 3);
      
      Dequeue (Q, Item);
      Assert_Equal ("Dequeued item is 4", Item, 4);
      
      Assert ("Queue is empty after all dequeues", Is_Empty (Q));
      
   end Test_Circular_Buffer_Wrap_Around;
   
   --  ========================================================================
   --  MAIN TEST RUNNER
   --  ========================================================================
   
begin
   Ada.Text_IO.Put_Line ("SPARK Data Queue - Test Suite");
   Ada.Text_IO.Put_Line ("================================");
   Ada.Text_IO.Put_Line ("Version: 0.01");
   Ada.Text_IO.Put_Line ("");
   
   --  Run all test procedures
   Test_Basic_Operations;
   Test_Queue_Limits;
   Test_FIFO_Behavior;
   Test_Clear_Operation;
   Test_Contains_Operation;
   Test_Exception_Handling;
   Test_Different_Data_Types;
   Test_Circular_Buffer_Wrap_Around;
   
   --  Print summary
   Ada.Text_IO.Put_Line ("");
   Ada.Text_IO.Put_Line ("================================");
   Ada.Text_IO.Put_Line ("Test Summary:");
   Ada.Text_IO.Put_Line ("  Total:  " & Natural'Image (Total_Tests));
   Ada.Text_IO.Put_Line ("  Passed: " & Natural'Image (Passed_Tests));
   Ada.Text_IO.Put_Line ("  Failed: " & Natural'Image (Failed_Tests));
   
   if Failed_Tests = 0 then
      Ada.Text_IO.Put_Line ("  Result: ALL TESTS PASSED ✓");
   else
      Ada.Text_IO.Put_Line ("  Result: SOME TESTS FAILED ✗");
   end if;
   
   Ada.Text_IO.Put_Line ("================================");
   
   --  Exit with appropriate code
   if Failed_Tests > 0 then
      Ada.Text_IO.Set_Exit_Status (Ada.Text_IO.Failure);
   end if;
   
exception
   when others =>
      Ada.Text_IO.Put_Line ("");
      Ada.Text_IO.Put_Line ("UNEXPECTED EXCEPTION IN TEST SUITE!");
      Ada.Text_IO.Set_Exit_Status (Ada.Text_IO.Failure);

end Test_Queue;
