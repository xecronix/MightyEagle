--****
-- == helper 
-- Common functions for testing the Mighty Eagle Template Solution
--
-- <<LEVELTOC level=2 depth=4>>
--
include std/map.e
include std/filesys.e
include std/sequence.e

--** 
--For referencing a sequence of test data 

public enum TEMPLATE, EXPECTED_RESULT, DATA


--** 
-- Function opens a text file, reads and returns the contents,
-- Parameters: 
-- ##file_path##: the full path to the file to read
-- Returns: 
-- ##retval##: The contents of the text file

function load_text_file(sequence file_path)
	sequence retval = {}
	integer fp = open(file_path, "r")
	object line
	
	if equal(fp, -1) then 
		printf(2, "could not open file %s for reading", {file_path})
		return fp -- error out here
	end if
	
	while 1 do
		line = gets(fp)
		if atom(line) then
			exit --eof
		end if
		retval = sprintf("%s%s", {retval, line})  
	end while  
	close(fp)
	return retval
end function

--** 
-- Function loads a template from the data directory
-- Parameters:
-- ##file_name## The name of the template to load.
-- Returns:
-- ##retval## A sequence of the file contents

public function load_template(sequence file_name)
	object retval
	sequence init_path = current_dir()
	sequence file_path = join_path({init_path, "data",  file_name})
	
	retval = load_text_file(file_path)
	if atom(retval) then
		printf(2, "Loading template failed.")
		abort(retval)
	end if
	return retval
end function 

--** 
-- Function loads expected result from data directory
-- Parameters:
-- ##file_name## The name of the file that contains the 
-- data for what the expected result should look like.
-- Returns:
-- ##retval## A sequence of the file contents

public function load_expected_result(sequence file_name)
	object retval
	sequence init_path = current_dir()
	sequence file_path = join_path({init_path, "data",  file_name})
	
	retval = load_text_file(file_path)
	if atom(retval) then
		printf(2, "Loading expected result failed.")
		abort(retval)
	end if
	return retval
end function 

--** 
-- Function loads a map of delimited data.  The file
-- format is expected to be key||value one line per record
-- Parameters:
-- ##file_name## is the file that contains the dat
-- Returns:
-- retval: A map of the data.

public function load_data(sequence file_name)
	map retval = map:new()
	sequence init_path = current_dir()
	sequence file_path = join_path({init_path, "data",  file_name})
	object txt = load_text_file(file_path)
	sequence lines = {}
	if atom(txt) then
		printf(2, "Loading test data failed.")
		abort(txt)
	end if
	
	lines = split(txt, "\n")
	for i = 1 to length(lines) do
		sequence line = lines[i]
		if length(line) then			-- skip blank lines
			sequence keyval = split(line, "||")
			map:put(retval, keyval[1], keyval[2])
		end if
	end for
	return retval
end function 

--** 
-- Loads data related to a test from the data directory
-- Parameters:
-- ##test_name## : The name of the test
-- Returns:
-- ##retval## : Sequence of data needed to run a test.
-- Comments:
-- This functions assumes that all test data 
-- is stored in the data directory relative to the text_*.ex
-- This also assumes that for each template test there will be 
-- 3 files of data named according to convention.
-- The convention is: 
-- * test_name.tpl for template files
-- * test_name.res for expected results
-- * test_name.dat for || delimited data files
-- The function returns a sequence using the following enum:
-- * retval[TEMPLATE] - template data
-- * retval[EXPECTED_RESULT] - expected result data
-- * retval[DATA] - data file returned as a map

public function init_template_test(sequence test_name)
	sequence retval = {{},{},{}}
	retval[TEMPLATE] = load_template(sprintf("%s.tpl", {test_name}))
	retval[EXPECTED_RESULT] = load_expected_result(sprintf("%s.res", {test_name}))
	retval[DATA] = load_data(sprintf("%s.dat", {test_name}))
	return retval
end function 

--** 
-- Function takes a keyval pair map and returns a flat string.
-- Parameters: 
-- ##data## : The map to convert to a string
-- Returns:
-- ##retval## : A string value that represents what the map data.  
-- This should look like the text file the data was loaded from.
-- Comment:
-- This function is not meant to return pretty string values for 
-- complex maps.

public function map_to_string(map:map data)
	sequence retval = ""
	sequence mapkeys = keys(data)
	for i = 1 to length(mapkeys) do
		sequence key = mapkeys[i]
		retval = sprintf("%s%s||%s\n", {retval, key, map:get(data, key)})
	end for
	return retval
end function 
