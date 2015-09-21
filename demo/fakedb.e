-- This data could have come from a database but for this demo
-- well just create the tables as sequences.

public function select_all_from_customers()
	sequence customers_tbl = {
		{"xecronix", "nospam_xecronix@sogetthis.com", "407-555-1212", "123 Main Street"},
		{"jsmith", "greatday88@sogetthis.com", "407-555-1212", "999 Other Street"}
	}
	return customers_tbl
end function

-- Meh... It's a demo.  Maybe I'll update the demo to use a DB one day.

public function select_all_from_orders_where_customer(sequence customer)
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
