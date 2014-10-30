// Playground - noun: a place where people can play

import Foundation
import EonilSQLite3

///	Create new mutable database in memory.
let	db1	=	Database(location: Database.Location.Memory, editable: true)
func tx1() {
	
	///	Create a new table.
	db1.schema().create(table: "T1", column: ["c1"])
	
	///	Make a single table accessor object.
	let	t1	=	db1.table(name: "T1")
	
	///	Insert a new row.
	t1.insert(rowWith: ["c1":"V1"])
	
	///	Verify by selecting all current rows.
	let	rs1	=	t1.select()
	assert(rs1.count == 1)
	assert(rs1[0]["c1"]! as String == "V1")
	
	///	Update the row.
	t1.update(rowsWithAllOf: ["c1":"V1"], bySetting: ["c1":"W2"])
	
	///	Verify!
	let	rs2	=	t1.select()
	assert(rs2.count == 1)
	assert(rs2[0]["c1"]! as String == "W2")
	
	///	Delete the row.
	t1.delete(rowsWithAllOf: ["c1":"W2"])
	
	///	Verify!
	let	rs3	=	t1.select()
	assert(rs3.count == 0)
}

///	Perform a transaction with multiple commands.
db1.apply(tx1)

