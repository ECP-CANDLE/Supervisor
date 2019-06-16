
/**
   CONTROLLER H
*/

#pragma once

/**
   comm: The communicator to run on
   code: The Python code (the Horovod program)
   return: Success=1 , Failure=0
*/
int controller(MPI_Comm comm, char* code);
