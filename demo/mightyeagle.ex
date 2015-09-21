#!/usr/bin/env eui
include mightyeagle/mightyeagle.e
include std/filesys.e
include std/map.e
include fakedb.e

with trace

-- We'll use this callback when in the orders context

function order_cb(mighty_eagle_t me, sequence tag, sequence template, map:map context)
	sequence retval = ""
	sequence record = {}
	sequence name = map:get(context, "name", "")
	sequence table = select_all_from_orders_where_customer(name) -- comes from our fakedb.e
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

-- We'll use this callback when in the customer context.

function customer_cb(mighty_eagle_t me, sequence tag, sequence template, map:map context)
	sequence retval = ""
	sequence record = {}
	sequence table = select_all_from_customers() -- comes from our fakedb.e
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
<style>
	td {border:1px solid}
	table {border:1px solid}
	.center {text-align:center}
	.right_align {text-align:right}
</style>
<body>
<table>
{@customer_cb
  <tr>
    <th colspan='3'>
      {=name :}<br />
      {=address :}<br />
      {=phone :}<br />
      {=email :}<br />
    </th>
  </tr>
  <tr>
      <th>Product</th>
      <th>Quantity</th>
      <th>Cost</th>
    </th>
  </tr>
{@order_cb
  <tr>
    <td class='center'>{=prod :}</td>
    <td class='right_align'>{=qty :}</td>
    <td class='right_align'>{=cost :}</td>
  </tr>
:}:}
</table>
</body>
</html>
"""

mighty_eagle:mighty_eagle_t me = mighty_eagle:new()
mighty_eagle:add_action_cb(me, "customer_cb", routine_id("customer_cb"))
mighty_eagle:add_action_cb(me, "order_cb", routine_id("order_cb"))
sequence html = mighty_eagle:parse(me, template, map:new())
printf(1, html, {})










