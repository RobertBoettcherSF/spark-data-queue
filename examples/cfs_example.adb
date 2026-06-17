--  SPARK Data Queue - cFS-like Example
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
--  EXAMPLE: cFS-like Message Queue for Embedded Systems
--  
--  This example demonstrates how the SPARK Data Queue can be used in a
--  cFS (Core Flight System) like environment for inter-task communication.
--  
--  Features demonstrated:
--    - Fixed-size message queue (suitable for embedded systems)
--    - Thread-safe message passing (conceptual)
--    - Bounded queue to prevent memory exhaustion
--    - Simple message structure
--  
--  Note: This is a conceptual example. Actual cFS integration would require
--        additional adaptation for the cFS environment.
--  
--  Compile and run:
--    gprbuild -P cfs_example.gpr
--    ./obj/cfs_example
--  
--  ============================================================================

with Spark_Data_Queue;
with Ada.Text_IO;
with Ada.Integer_Text_IO;

procedure CFS_Example is
   
   --  Define a simple message type for cFS-like communication
   --  In real cFS, this would be more complex with message IDs, etc.
   type Message_Type is record
      Message_ID : Integer range 1 .. 100;
      Data_1     : Integer;
      Data_2     : Integer;
      Timestamp  : Natural;
   end record;
   
   --  Default message for initialization
   Default_Message : constant Message_Type := 
     (Message_ID => 1, Data_1 => 0, Data_2 => 0, Timestamp => 0);
   
   --  Instantiate the queue for Message_Type
   package Message_Queue is new Spark_Data_Queue (
      Element_Type => Message_Type,
      Default_Element => Default_Message
   );
   use Message_Queue;
   
   --  Create a queue with fixed size (typical for embedded systems)
   --  In cFS, queue sizes are often limited to prevent memory issues
   Message_Queue_Size : constant Positive := 10;
   Msg_Q : Queue_Type := Create_Queue (Max_Size => Message_Queue_Size);
   
   --  Variables for message handling
   Msg : Message_Type;
   
begin
   Ada.Text_IO.Put_Line ("SPARK Data Queue - cFS-like Example");
   Ada.Text_IO.Put_Line ("====================================");
   Ada.Text_IO.Put_Line ("");
   
   --  Simulate receiving messages from different sources
   Ada.Text_IO.Put_Line ("Simulating message reception:");
   Ada.Text_IO.Put_Line ("");
   
   --  Receive telemetry message
   Msg := (Message_ID => 1, Data_1 => 42, Data_2 => 100, Timestamp => 1000);
   Enqueue (Msg_Q, Msg);
   Ada.Text_IO.Put_Line ("  Received telemetry message (ID: 1, Data: 42, 100)");
   
   --  Receive command message
   Msg := (Message_ID => 2, Data_1 => 1, Data_2 => 0, Timestamp => 1001);
   Enqueue (Msg_Q, Msg);
   Ada.Text_IO.Put_Line ("  Received command message (ID: 2, Data: 1, 0)");
   
   --  Receive status message
   Msg := (Message_ID => 3, Data_1 => 200, Data_2 => 300, Timestamp => 1002);
   Enqueue (Msg_Q, Msg);
   Ada.Text_IO.Put_Line ("  Received status message (ID: 3, Data: 200, 300)");
   
   Ada.Text_IO.Put_Line ("");
   Ada.Text_IO.Put_Line ("Queue status:");
   Ada.Text_IO.Put_Line ("  Messages in queue: " & Natural'Image (Size (Msg_Q)));
   Ada.Text_IO.Put_Line ("  Queue capacity:    " & Positive'Image (Max_Size (Msg_Q)));
   Ada.Text_IO.Put_Line ("  Queue utilization: " & 
                        Natural'Image (Size (Msg_Q) * 100 / Max_Size (Msg_Q)) & "%");
   Ada.Text_IO.Put_Line ("");
   
   --  Simulate processing messages in FIFO order
   Ada.Text_IO.Put_Line ("Processing messages in FIFO order:");
   Ada.Text_IO.Put_Line ("");
   
   --  Process all messages
   while not Is_Empty (Msg_Q) loop
      Dequeue (Msg_Q, Msg);
      
      Ada.Text_IO.Put ("  Processing message ID: ");
      Ada.Integer_Text_IO.Put (Msg.Message_ID);
      Ada.Text_IO.Put (", Data: ");
      Ada.Integer_Text_IO.Put (Msg.Data_1);
      Ada.Text_IO.Put (", ");
      Ada.Integer_Text_IO.Put (Msg.Data_2);
      Ada.Text_IO.Put (", Timestamp: ");
      Ada.Integer_Text_IO.Put (Msg.Timestamp);
      Ada.Text_IO.New_Line;
      
      --  Simulate message processing based on type
      case Msg.Message_ID is
         when 1 =>
            Ada.Text_IO.Put_Line ("    -> Telemetry: Storing sensor data");
         when 2 =>
            Ada.Text_IO.Put_Line ("    -> Command: Executing command");
         when 3 =>
            Ada.Text_IO.Put_Line ("    -> Status: Updating system status");
         when others =>
            Ada.Text_IO.Put_Line ("    -> Unknown: Discarding message");
      end case;
      
   end loop;
   
   Ada.Text_IO.Put_Line ("");
   Ada.Text_IO.Put_Line ("Queue is now empty: " & Boolean'Image (Is_Empty (Msg_Q)));
   Ada.Text_IO.Put_Line ("");
   
   --  Demonstrate queue full scenario
   Ada.Text_IO.Put_Line ("Demonstrating queue full scenario:");
   Ada.Text_IO.Put_Line ("");
   
   --  Fill the queue to capacity
   for I in 1 .. Message_Queue_Size loop
      Msg := (Message_ID => I, Data_1 => I * 10, Data_2 => I * 20, Timestamp => 2000 + I);
      Enqueue (Msg_Q, Msg);
      Ada.Text_IO.Put_Line ("  Enqueued message " & Integer'Image (I) & 
                           " (Queue size: " & Natural'Image (Size (Msg_Q)) & ")");
   end loop;
   
   Ada.Text_IO.Put_Line ("");
   Ada.Text_IO.Put_Line ("Queue is full: " & Boolean'Image (Is_Full (Msg_Q)));
   
   --  Try to enqueue one more (should raise exception)
   Ada.Text_IO.Put_Line ("");
   Ada.Text_IO.Put_Line ("Attempting to enqueue when queue is full:");
   
   Msg := (Message_ID => 99, Data_1 => 0, Data_2 => 0, Timestamp => 0);
   begin
      Enqueue (Msg_Q, Msg);
      Ada.Text_IO.Put_Line ("  ERROR: Should have raised Queue_Overflow!");
   exception
      when Queue_Overflow =>
         Ada.Text_IO.Put_Line ("  ✓ Queue_Overflow exception raised as expected");
   end;
   
   --  Make space by dequeuing one message
   Ada.Text_IO.Put_Line ("");
   Ada.Text_IO.Put_Line ("Making space by dequeuing one message:");
   Dequeue (Msg_Q, Msg);
   Ada.Text_IO.Put_Line ("  Dequeued message ID: " & Integer'Image (Msg.Message_ID));
   Ada.Text_IO.Put_Line ("  Queue size: " & Natural'Image (Size (Msg_Q)));
   Ada.Text_IO.Put_Line ("  Queue is full: " & Boolean'Image (Is_Full (Msg_Q)));
   
   --  Now we can enqueue again
   Ada.Text_IO.Put_Line ("");
   Ada.Text_IO.Put_Line ("Enqueueing new message:");
   Msg := (Message_ID => 99, Data_1 => 999, Data_2 => 888, Timestamp => 3000);
   Enqueue (Msg_Q, Msg);
   Ada.Text_IO.Put_Line ("  ✓ Successfully enqueued message ID: " & Integer'Image (Msg.Message_ID));
   Ada.Text_IO.Put_Line ("  Queue size: " & Natural'Image (Size (Msg_Q)));
   
   Ada.Text_IO.Put_Line ("");
   Ada.Text_IO.Put_Line ("cFS-like example completed successfully!");
   
exception
   when Queue_Overflow =>
      Ada.Text_IO.Put_Line ("Error: Queue overflow occurred!");
   when Queue_Underflow =>
      Ada.Text_IO.Put_Line ("Error: Queue underflow occurred!");
   when others =>
      Ada.Text_IO.Put_Line ("Unexpected error occurred!");

end CFS_Example;
