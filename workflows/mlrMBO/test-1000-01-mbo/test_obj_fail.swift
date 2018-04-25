
/*
  TEST OBJ FAIL SWIFT
  Test the user ability to change obj().
  This will fail: an intentional assertion failure.
    -> This indicates that the user was able to use a
       non-CANDLE objective function
*/

(string obj_result) obj(string params,
                        string run_id)
{
  // This will always fail:
  assert(params == "", "test-obj-fail.swift was successfully invoked!");
  obj_result = "100.0"; // dummy value
}
