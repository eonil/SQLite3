EonilSQLite3
============
Hoon H., 2014/09/16



**CURRENTLY UNDER DEVELOPMENT. API IS SUBJECT TO CHANGE**



This provides SQLite3 database access on Swift.





Getting Started
---------------
Embed the project as a subproject of your project, and link iOS dynamic
framewor target. If you need to target iOS 7, then you have to copy the
source files manually into your project. Because Swift is not currently
supporting static library target. (Xcode 6.0.1)







How to Use
----------
Schematic illustration.

	import EonilSQLite3


	///	Create new mutable database in memory.
	let	db1	=	Database(location: Database.Location.Memory, mutable: true)

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




What about multi-table operations?
----------------------------------
Seriously looking for JOIN stuffs on SQLite?
Well, those stuffs are not provided as formalized method, and
you need to execute your own custom query.











Objective-C
-----------
Good old Objective-C version library still exists in `ObjectiveC` folder.
Anyway, it's completely separated version, and nothing related to Swift 
version. Swift version is pure Swift based, and interfaces to SQLite3 C 
API directly.





License
-------
MIT license.
