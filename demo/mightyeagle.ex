#!/usr/bin/env eui
include std/eds.e
include mightyeagle/mightyeagle.e
include std/filesys.e
include std/map.e
with trace
-- This data could have come from a database but for this demo
-- well just create the tables as sequences.



function select_all_from_customers()
	sequence customers_tbl = {
		{"xecronix", "nospam_xecronix@sogetthis.com", "407-555-1212", "123 Main Street"},
		{"jsmith", "greatday88@sogetthis.com", "407-555-1212", "999 Other Street"}
	}
	return customers_tbl
end function

function select_all_from_orders_where_customer(sequence customer)
	sequence orders_tbl = {
		{"xecronix", "Laser Pointer", 3, 1.25},
		{"jsmith", "Spiral Notebook", 12, 6.87},
		{"jsmith", "Computer Mouse", 1, 9.86},
		{"jsmith", "Mouse Pad", 1, 3.49}
	}
	
	sequence results = {}
	for i = 1 to length(orders_tbl) do
		sequence record = orders_tbl[i]
		if equal(record[1], customer) then
			results = append(results, record)
		end if
	end for
	
	return results
end function

function order_cb(mighty_eagle_t me, sequence tag, sequence template, map:map context)
	sequence retval = ""
	sequence record = {}
	sequence name = map:get(context, "name", "")
	sequence table = select_all_from_orders_where_customer(name)
	map:map tags = map:new()
	for i = 1 to length(table) do
		record = table[i]
		map:put(tags, "prod", record[2])
		map:put(tags, "qty", sprintf("%d", {record[3]}))
		map:put(tags, "cost", sprintf("%.2f", {record[4]}))
		retval = sprintf("%s%s", {retval, mighty_eagle:parse(me, template, tags)})
	end for
	return retval
end function 

function customer_cb(mighty_eagle_t me, sequence tag, sequence template, map:map context)
	sequence retval = ""
	sequence record = {}
	sequence table = select_all_from_customers()
	map:map tags = map:new()
	for i = 1 to length(table) do
		record = table[i]
		map:put(tags, "name", record[1])
		map:put(tags, "email", record[2])
		map:put(tags, "phone", record[3])
		map:put(tags, "address", record[4])
		retval = sprintf("%s%s", {retval, mighty_eagle:parse(me, template, tags)})
	end for
	return retval
end function 

-- cool now we have some data and a couple of callbacks
-- lets make a template
sequence template = """
<html>
<body>
<table>
{@customer_cb
  <tr>
    <th colspan='3'>
      {=name :}
    </th>
  </tr>
{@order_cb
  <tr>
    <td>{=prod :}</td>
    <td>{=qty :}</td>
    <td>{=cost :}</td>
  </tr>
:}
:}
</table>
</body>
</html>
"""

mighty_eagle:mighty_eagle_t me = mighty_eagle:new()
mighty_eagle:add_action_cb(me, "customer_cb", routine_id("customer_cb"))
mighty_eagle:add_action_cb(me, "order_cb", routine_id("order_cb"))
db_close()  
db_open("demo")  
sequence html = mighty_eagle:parse(me, template, map:new())
printf(1, html, {})










