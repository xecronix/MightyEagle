#!/usr/bin/env eui
include helper.e

sequence test_params = init_template_test("parse_no_tags")
printf(1, "%s", {test_params[TEMPLATE]})
printf(1, "%s", {test_params[EXPECTED_RESULT]})
printf(1, "%s", {map_to_string(test_params[DATA])})
