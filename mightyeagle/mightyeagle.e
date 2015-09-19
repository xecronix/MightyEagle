namespace mighty_eagle
include std/map.e
include std/eumem.e

-- Private 
-- enum used for managing state in the parser

enum
    ECHO,
    TAG_OPENING,
    TAG_OPEN,
    READ_TAG_DATA,
    LEVEL_UP,
    TAG_CLOSING,
    TAG_CLOSED

-- Private
-- enum used for keeping track of what type of tag the parser is working on
    
enum
    NONE,
    TAG,
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
    map:map m = self[ACTION_CB]
    map:put(m, action_tag, function_id)
    self[ACTION_CB] = m
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
    map:map m = self[TAG_CB]
    map:put(m, tag, function_id)
    self[TAG_CB] = m
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

public function parse(mighty_eagle_t self, sequence template_str, map:map data)
    sequence retval = template_str
    sequence current_tag = ""
    integer state = PARSE
    integer tag_type = NONE
    integer level = 0
    sequence valid_tag_chars = "._abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    for i = 1 to length(template_str) do
    end for

    return retval
end function
