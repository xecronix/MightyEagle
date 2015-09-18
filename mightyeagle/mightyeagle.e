namespace mightyeagle
include std/map.e


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
  return retval
end function
