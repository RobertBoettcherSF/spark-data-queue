--  SPARK Data Queue - Concrete Instantiation for SPARK Analysis
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
--  CONCRETE INSTANTIATION: For SPARK Analysis
--  
--  Version: 0.08
--  
--  Purpose: SPARK cannot analyze generic package bodies directly.
--           This file creates a concrete instantiation that SPARK can analyze.
--  
--  This instantiation uses Integer as the element type for verification.
--  ============================================================================

pragma SPARK_Mode (On);

with Spark_Data_Queue;

package Spark_Data_Queue_Instantiation is
   
   --  Instantiate the generic queue with Integer type
   package Integer_Queue is new Spark_Data_Queue (Element_Type => Integer);
   
   --  Use the instantiated package
   use Integer_Queue;
   
   --  Create a queue instance for SPARK analysis
   Queue_Example : Queue_Type := Create_Queue (Max_Size => 10);

end Spark_Data_Queue_Instantiation;
