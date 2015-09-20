namespace mighty_eagle
include std/map.e
include std/eumem.e
include std/sequence.e
with trace
-- Private 
-- enum used for managing state in the parser

enum
	SKIP,
	ECHO,
	TAG_OPENING,
	TAG_OPEN,
	READ_TAG_DATA,
	LEVEL_UP,
	TAG_CLOSING,
	TAG_CLOSED,
	ERROR

-- Private
-- enum used for keeping track of what type of tag the parser is working on

enum
	NONE,
	SUBSITUTION,
	ACTION

-- Private
-- This is the structure of a mighty_eagle

enum 
	__TYPE__,
	ACTION_CB,
	TAG_CB,
	__MYSIZE__

-- Private
-- An id for the Mighty Eagle and it's size
constant MIGHTY_EAGLE_ID="MIGHTYEAGLE$8i7u64y5t3qrawesdyjukm"	
constant SIZEOF_MIGHTY_EAGLE = __MYSIZE__
constant OK = 0

--**
--enum for error codes

public enum 
	INVALID_TAG,
	MISSING_CLOSING_CURLY,
	MISSING_CLOSING_COLON,
	TAG_CALLBACK_ERROR,
	UNREACHABLE_NOT_TRUE

-- Private
-- TODO Document me
function run_tag_cb(mighty_eagle_t self, sequence tag, map:map context)
	object retval = OK
	map:map cb_seq = eumem:ram_space[self][TAG_CB]
	atom func = map:get(cb_seq, tag, -1)
	if (func > -1) then
		sequence tag_value = map:get(context, tag, "")
		retval = call_func(func, {self, tag, tag_value, context})
	end if
	return retval
end function

-- Private
-- TODO Document me
function run_action_cb(mighty_eagle_t self, sequence tag, sequence sub_template , map:map context)
	object retval = OK
	map:map cb_seq = eumem:ram_space[self][ACTION_CB]
	atom func = get(cb_seq, tag, -1)
	if (func > -1) then
		retval = call_func(func, {self, tag, sub_template, context})
	end if
	return retval
end function

--**
-- Defines the mighty_eagle_t as identified by the MIGHTY_EAGLE_ID

public type mighty_eagle_t (atom ptr)
	if eumem:valid(ptr, __MYSIZE__) then
		if equal(eumem:ram_space[ptr][__TYPE__], MIGHTY_EAGLE_ID) then 
			return 1
		end if
	end if
	return 0
end type

--**
-- Adds a callback added to the mighty_eagle_t to be fired when the parser finds action tags.
-- Parameters:
-- # ##action_tag## The action tag associated with the a function 
-- # ##function_id## A routine_id to run when the specifice action_tag is found during parsing
-- Returns:
-- 0

public function add_action_cb(mighty_eagle_t self, sequence action_tag, atom function_id)
	map:map m = eumem:ram_space[self][ACTION_CB]
	map:put(m, action_tag, function_id)
	eumem:ram_space[self][ACTION_CB] = m
	return 0
end function 

--**
-- Adds a callback added to the mighty_eagle_t to be fired when the parser finds tags.
-- Parameters:
-- # ##action_tag## The action tag associated with the a function 
-- # ##function_id## A routine_id to run when the specifice action_tag is found during parsing
-- Returns:
-- 0

public function add_tag_cb(mighty_eagle_t self, sequence tag, atom function_id)
	map:map m = eumem:ram_space[self][TAG_CB]
	map:put(m, tag, function_id)
	eumem:ram_space[self][TAG_CB] = m
	return 0
end function

--**
-- Function creates a new Mighty Eagle

public function new(object opts = 0)
	return eumem:malloc( {MIGHTY_EAGLE_ID, map:new(), map:new(), SIZEOF_MIGHTY_EAGLE} )  
end function

--**
-- Function looks for tags and actions in a template
-- then calls the appropreite callback to handle replacing
-- tags with actual data.  
-- Parameters:
-- # ##template_str## : This is the template or sub template to parse
-- # ##data## : A map of data to use to replace tags with values.
-- Returns: 
-- ##retval## : string representaion of the template or 
-- sub template with all tags replace by values
-- Comments:
-- If a tag can not be found in either the callbacks or data, the 
-- function will insert the tag back into the return value.
-- Parsing rules:
-- Opening a tag:
-- { opens a tag
-- = identifies that a tag is for subsitution
-- @ identifies that a tag is for action callbacks
-- Example: ## {= ##
-- Spaces are allowed before and after tag name.
-- :} closes a tag
-- Action tags can contain tags or other action tags.

public function parse(mighty_eagle_t self, sequence template_str, map:map data)
	object retval = ""
	sequence current_tag = ""
	sequence sub_template = ""
	integer state = ECHO
	integer tag_type = NONE
	integer level = 0
	sequence valid_tag_chars = "._abcdefghijk?lmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	sequence current_char = {}
	integer begin_open_position = 1
	integer end_open_position = 1
	integer skip_count = 0
	
	for i = 1 to length(template_str) do
		if state = ERROR then
			return retval -- bail on errors
		end if
		current_char = slice(template_str, i, i)
		if state = SKIP then
			skip_count -= 1
			if skip_count = 0 then
				state = ECHO
			end if
		elsif state = ECHO then
			if equal(current_char, "{") then
				state = TAG_OPENING
			else
				retval = sprintf("%s%s", {retval, current_char})
			end if
		elsif state = TAG_OPENING then
			current_tag = ""
			if equal(current_char, "=") then
				tag_type = SUBSITUTION
				state = TAG_OPEN
				begin_open_position = i - 1
			elsif equal(current_char, "@") then
				tag_type = ACTION
				state = TAG_OPEN
				begin_open_position = i - 1
			else
				tag_type = NONE
				state = ECHO
				retval = sprintf("%s{%s", {retval, current_char})
			end if
		elsif state = TAG_OPEN then
			if length(current_tag) = 0 and equal(current_char, " ") then
				-- NOOP Ignore leading spaces
				state = TAG_OPEN
			else
				if tag_type = SUBSITUTION then
					if equal(current_char, " ") then
						-- NOOP Ignore trailing spaces
						tag_type = SUBSITUTION
					elsif equal(current_char, ":") then
						state = TAG_CLOSING
					elsif equal(current_char, "}") then -- case for common mistake 
						state = ERROR
						retval = MISSING_CLOSING_COLON
					elsif find(current_char[1], valid_tag_chars) > 0 then
						current_tag = sprintf("%s%s", {current_tag, current_char})
					else
						state = ERROR
					end if
				elsif tag_type = ACTION then
					if find(current_char[1], valid_tag_chars) > 0 then
						current_tag = sprintf("%s%s", {current_tag, current_char})
					else
						if length(current_tag) = 0 then
							retval = INVALID_TAG
							state = ERROR
						else
							state = TAG_CLOSING
							level = 1
						end if
					end if
				else
					state = ERROR
					retval = UNREACHABLE_NOT_TRUE
				end if
			end if
		elsif state = TAG_CLOSING then
			if (tag_type = SUBSITUTION) then
				if equal(current_char, "}") then
					end_open_position = i
					sequence val = {}
					object cb_result = run_tag_cb(self, current_tag, data)
					if atom(cb_result) then
						if cb_result = OK then
							-- we didn't find a callback for this tag
							-- so look in the data for a value for the tag or
							-- simply return the tag.
							val = map:get(data, current_tag, 
									slice(template_str, begin_open_position, end_open_position))
						else
							state = ERROR
							retval = cb_result
						end if
					else
						-- this tag had an error free callback.  
						-- so spew out whatever the result was.
						val = cb_result
					end if
					
					if state != ERROR then
						retval = sprintf("%s%s", {retval, val})
						state = ECHO
						current_tag = ""
					end if
				else
					state = ERROR
					retval = MISSING_CLOSING_CURLY
				end if
			elsif (tag_type = ACTION) then
				if equal(current_char, "{") then
					sequence next_char = slice(template_str, i+1, i+1)
					if equal(next_char, "@") or equal(next_char, "=")then
						level += 1
					end if
				elsif equal(current_char, ":") then
					sequence next_char = slice(template_str, i+1, i+1)
					if equal(next_char, "}") then
						level -= 1
					end if
				end if
				
				if (level != 0) then
					sub_template = sprintf("%s%s", {sub_template, current_char})
				else
					object cb_result = run_action_cb(self, current_tag, sub_template, data)
					if atom(cb_result) then
						if cb_result = OK then
							-- we don't have a callback for this action.  
							-- In this case just add the sub_template to the retval.
							retval = sprintf("%s%s%s", {retval, sub_template, current_char})
							state = ECHO
							sub_template = ""
							current_tag = ""
						else
							-- we called the callback and it returned and error.
							state = ERROR
							retval = cb_result
						end if
					else
						-- we called the callback and it returned a sequence.
						-- add the sequence to the retval
						retval = sprintf("%s%s", {retval, cb_result})
						state = SKIP
						skip_count = 1
						sub_template = ""
						current_tag = ""
					end if
				end if
			else
				state = ERROR
				retval = UNREACHABLE_NOT_TRUE
			end if
		end if
	end for
	if length(current_tag) then
		retval = sprintf("%s%s", {retval,slice(template_str, begin_open_position)})
	end if 
	return retval
end function
