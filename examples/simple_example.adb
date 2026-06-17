--  SPARK Data Queue - Simple Example
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
--  EXAMPLE: Simple usage of SPARK Data Queue
--  
--  This example demonstrates basic queue operations:
--    - Creating a queue
--    - Enqueueing elements
--    - Dequeueing elements
--    - Checking queue state
--  
--  Compile and run:
--    gprbuild -P simple_example.gpr
--    ./obj/simple_example
--  
--  ============================================================================

with Spark_Data_Queue;
with Ada.Text_IO;
with Ada.Integer_Text_IO;

procedure Simple_Example is
   
   --  Instantiate the queue for Integer type
   package Integer_Queue is new Spark_Data_Queue (Element_Type => Integer);
   use Integer_Queue;
   
   --  Create a queue with maximum size of 10
   Q : Queue_Type := Create_Queue (Max_Size => 10);
   
   --  Variables for operations
   Item : Integer;
   
begin
   Ada.Text_IO.Put_Line ("SPARK Data Queue - Simple Example");
   Ada.Text_IO.Put_Line ("================================");
   Ada.Text_IO.Put_Line ("");
   
   --  Check initial state
   Ada.Text_IO.Put_Line ("Initial state:");
   Ada.Text_IO.Put_Line ("  Is Empty: " & Boolean'Image (Is_Empty (Q)));
   Ada.Text_IO.Put_Line ("  Is Full:  " & Boolean'Image (Is_Full (Q)));
   Ada.Text_IO.Put_Line ("  Size:     " & Natural'Image (Size (Q)));
   Ada.Text_IO.Put_Line ("  Max Size: " & Positive'Image (Max_Size (Q)));
   Ada.Text_IO.Put_Line ("");
   
   --  Enqueue some elements
   Ada.Text_IO.Put_Line ("Enqueueing elements: 10, 20, 30, 40, 50");
   Enqueue (Q, 10);
   Enqueue (Q, 20);
   Enqueue (Q, 30);
   Enqueue (Q, 40);
   Enqueue (Q, 50);
   
   Ada.Text_IO.Put_Line ("  Current size: " & Natural'Image (Size (Q)));
   Ada.Text_IO.Put_Line ("  Is Empty: " & Boolean'Image (Is_Empty (Q)));
   Ada.Text_IO.Put_Line ("  Is Full:  " & Boolean'Image (Is_Full (Q)));
   Ada.Text_IO.Put_Line ("");
   
   --  Dequeue elements and display them
   Ada.Text_IO.Put_Line ("Dequeueing all elements:");
   while not Is_Empty (Q) loop
      Dequeue (Q, Item);
      Ada.Text_IO.Put ("  Dequeued: ");
      Ada.Integer_Text_IO.Put (Item);
      Ada.Text_IO.New_Line;
   end loop;
   
   Ada.Text_IO.Put_Line ("");
   Ada.Text_IO.Put_Line ("Final state:");
   Ada.Text_IO.Put_Line ("  Is Empty: " & Boolean'Image (Is_Empty (Q)));
   Ada.Text_IO.Put_Line ("  Size:     " & Natural'Image (Size (Q)));
   
   --  Demonstrate FIFO behavior
   Ada.Text_IO.Put_Line ("");
   Ada.Text_IO.Put_Line ("Demonstrating FIFO behavior:");
   
   --  Enqueue in order: 1, 2, 3
   Enqueue (Q, 1);
   Enqueue (Q, 2);
   Enqueue (Q, 3);
   
   Ada.Text_IO.Put_Line ("  Enqueued: 1, 2, 3");
   Ada.Text_IO.Put ("  Dequeued: ");
   
   --  Dequeue and show order
   for I in 1 .. 3 loop
      Dequeue (Q, Item);
      Ada.Integer_Text_IO.Put (Item);
      if I < 3 then
         Ada.Text_IO.Put (", ");
      end if;
   end loop;
   Ada.Text_IO.New_Line;
   
   Ada.Text_IO.Put_Line ("");
   Ada.Text_IO.Put_Line ("Example completed successfully!");
   
exception
   when Queue_Overflow =>
      Ada.Text_IO.Put_Line ("Error: Queue overflow!");
   when Queue_Underflow =>
      Ada.Text_IO.Put_Line ("Error: Queue underflow!");
   when others =>
      Ada.Text_IO.Put_Line ("Unexpected error occurred!");

end Simple_Example;
