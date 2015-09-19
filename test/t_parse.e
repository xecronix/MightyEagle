#!/usr/bin/env eui
include helper.e
include std/unittest.e
include std/map.e
include mightyeagle/mightyeagle.e

function action_cb(mighty_eagle_t me, sequence template, map:map tag_data)
    return {}
end function 

function tag_cb(mighty_eagle_t me, sequence template, map:map tag_data)
    return {}
end function 

function invalid_return_action_cb(mighty_eagle_t me, sequence template, map:map tag_data)
    return 1
end function 

function invalid_return_tag_cb(mighty_eagle_t me, sequence template, map:map tag_data)
    return 1
end function

sequence test_params
mighty_eagle_t me

test_params = init_template_test("parse_no_tags")
me = mighty_eagle:new()
test_equal("parse_no_tags", test_params[EXPECTED_RESULT], mighty_eagle:parse(me, test_params[TEMPLATE], test_params[DATA]))

test_params = init_template_test("parse_tags")
me = mighty_eagle:new()
test_equal("parse_tags", test_params[EXPECTED_RESULT], mighty_eagle:parse(me, test_params[TEMPLATE], test_params[DATA]))

test_params = init_template_test("parse_tag_cb")
me = mighty_eagle:new()
test_equal("parse_tag_cb", test_params[EXPECTED_RESULT], mighty_eagle:parse(me, test_params[TEMPLATE], test_params[DATA]))

test_params = init_template_test("parse_action_cb")
me = mighty_eagle:new()
test_equal("parse_action_cb", test_params[EXPECTED_RESULT], mighty_eagle:parse(me, test_params[TEMPLATE], test_params[DATA]))

test_params = init_template_test("parse_action_and_tag_cb")
me = mighty_eagle:new()
test_equal("parse_action_and_tag_cb", test_params[EXPECTED_RESULT], mighty_eagle:parse(me, test_params[TEMPLATE], test_params[DATA]))

test_report()


