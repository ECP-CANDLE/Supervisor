
/*
  PLANGEN 0 SWIFT
  Disables plangen.  Used by ResNet 50 problem
*/

(string result) plangen_check()
{
  result = "OK";
}

(string result) plangen_prep(string db_file, string plan_json, string runtype)
{
  result = "42";
}

(string result) plangen_start(string node, string plan_id)
{
  result = "0";
}

(string result) plangen_stop(string node, string plan_id)
{
  result = "OK";
}
