#!/usr/bin/env eui
include helper.e
include std/unittest.e
include std/map.e
include mightyeagle/mightyeagle.e
include std/sequence.e
with trace
function action_cb(mighty_eagle_t me, sequence tag, sequence template, map:map context)
	map:map data = map:new()
	object retval = ""
	for i = 1 to 2 do
		map:put(data, "cnt", sprintf("%d", {i}))
		retval = sprintf("%s%s", {retval, mighty_eagle:parse(me, template, data)})
	end for
	return retval
end function 

function tag_cb(mighty_eagle_t me, sequence tag, sequence tag_value, map:map context)
	object retval = 999
	if equal(tag_value, "1970-09-28") then
		sequence date_parts = split(tag_value, "-")
		retval = sprintf("%s/%s/%s", {date_parts[2],date_parts[3],date_parts[1]})
	end if
	return retval
end function 

function invalid_return_action_cb(mighty_eagle_t me, sequence template, map:map context)
	return 999
end function 

function invalid_return_tag_cb(mighty_eagle_t me, sequence tag, sequence tag_value, map:map context)
	return 999
end function

sequence test_params
mighty_eagle_t me

-- Template with no tags should parse.
test_params = init_template_test("parse_no_tags")
me = mighty_eagle:new()
test_equal("parse_no_tags", test_params[EXPECTED_RESULT], mighty_eagle:parse(me, test_params[TEMPLATE], test_params[DATA]))

-- Parser should subsitute tags for values.
test_params = init_template_test("parse_tags")
me = mighty_eagle:new()
test_equal("parse_tags", test_params[EXPECTED_RESULT], mighty_eagle:parse(me, test_params[TEMPLATE], test_params[DATA]))

-- Parser should run callback function for subsitution tags.
test_params = init_template_test("parse_tag_cb")
me = mighty_eagle:new()
mighty_eagle:add_tag_cb(me, "birthday", routine_id("tag_cb"))
test_equal("parse_tag_cb", test_params[EXPECTED_RESULT], mighty_eagle:parse(me, test_params[TEMPLATE], test_params[DATA]))

-- Parser return the error code if a callback returns an atom instead of a sequence. 
test_params = init_template_test("parse_tag_cb")
me = mighty_eagle:new()
mighty_eagle:add_tag_cb(me, "birthday", routine_id("invalid_return_tag_cb"))
test_equal("invalid_return_tag_cb", 999, mighty_eagle:parse(me, test_params[TEMPLATE], test_params[DATA]))

-- Parser should return {=the_tag:} when data is missing.  "the_tag" is any well formed tag.  Not the constant "the_tag"
test_params = init_template_test("parse_missing_tag_data")
me = mighty_eagle:new()
test_equal("parse_missing_tag_data", test_params[EXPECTED_RESULT], mighty_eagle:parse(me, test_params[TEMPLATE], test_params[DATA]))

-- Parser should return MISSING_CLOSING_COLON error code if : is missing from tag closing.
test_params = init_template_test("parse_invalid_subsitution_tag")
me = mighty_eagle:new()
test_equal("parse_invalid_subsitution_tag", mighty_eagle:MISSING_CLOSING_COLON, mighty_eagle:parse(me, test_params[TEMPLATE], test_params[DATA]))

-- Parser should return  MISSING_CLOSING_CURLY error code if } is missing from tag closing.
test_params = init_template_test("parse_missing_closing_subsitution_curly")
me = mighty_eagle:new()
test_equal("parse_missing_closing_subsitution_curly", mighty_eagle:MISSING_CLOSING_CURLY, mighty_eagle:parse(me, test_params[TEMPLATE], test_params[DATA]))

-- Parser should run an action callback that performs a loop.
test_params = init_template_test("parse_action_cb")
me = mighty_eagle:new()
mighty_eagle:add_action_cb(me, "sayit2x", routine_id("action_cb"))
test_equal("parse_action_cb", test_params[EXPECTED_RESULT], mighty_eagle:parse(me, test_params[TEMPLATE], test_params[DATA]))

-- Parser should echo all data starting from the beginning of the unclosed tag.
test_params = init_template_test("parse_missing_action_tag_close")
me = mighty_eagle:new()
mighty_eagle:add_action_cb(me, "sayit2x", routine_id("action_cb"))
test_equal("parse_missing_action_tag_close", test_params[EXPECTED_RESULT], mighty_eagle:parse(me, test_params[TEMPLATE], test_params[DATA]))

test_report()


