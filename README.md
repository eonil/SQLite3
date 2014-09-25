EonilSQLite3
============
Hoon H., 2014/09/16



**CURRENTLY UNDER DESIGN & DEVELOPMENT, API IS SUBJECT TO CHANGE.**



This provides SQLite3 database access on Swift.

-	Auto-completion friendly query methods. No manual query command 
	composition for basic CRUD and DDL operations.
-	Array and dictionary based input/output access manner.
-	Automatically supports nested transactions.
-	Dynamically customizable error handlers. Default handler just crashes
	the app. You can provide custom behavior on each of error situations.





Getting Started
---------------
Embed the project as a subproject of your project, and link iOS dynamic
framewor target. If you need to target iOS 7, then you have to copy the
source files manually into your project. Because Swift is not currently
supporting static library target. (Xcode 6.0.1)







How to Use
----------
Schematic illustration.

````Swift

	import EonilSQLite3

	///	Create new mutable database in memory.
	let	db1	=	Database(location: Database.Location.Memory, mutable: true)
	func tx1()
	{
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

````

You need to perform any operations always in an explicit transaction. It's 
not allowed to run operations without transaction. 

Nested transaction is also supported. (using implicitly generated savepoint 
names which you can customize)

````Swift

	let	db1	=	Database(location: Database.Location.Memory, mutable: true)
	
	///	Out-most transaction.
	func tx1()
	{
		db1.schema().create(table: "T1", column: ["c1"])
		let	t1	=	db1.table(name: "T1")
		
		///	Outer transaction.
		func tx2() -> Bool
		{
			t1.insert(rowWith: ["c1":"V1"])
		
			///	Inner transaction.
			func tx3() -> Bool
			{
				///	Update the row.
				t1.update(rowsWithAllOf: ["c1":"V1"], bySetting: ["c1":"W2"])
				
				///	Verify the update.
				let	rs2	=	t1.select()
				assert(rs2.count == 1)
				assert(rs2[0]["c1"]! as String == "W2")
				
				///	And rollback.
				return	false
			}
			db1.applyConditionally(transaction: tx3)
			
			///	Verify inner rollback.
			let	rs2	=	t1.select()
			assert(rs2.count == 1)
			assert(rs2[0]["c1"]! as String == "V1")
			
			return	false
		}
		
		///	Verify outer rollback.
		let	rs2	=	t1.select()
		assert(rs2.count == 0)
	}
	db1.apply(tx1)

````







What about multi-table operations?
----------------------------------
Seriously looking for JOIN stuffs on SQLite?
Well, those stuffs are not provided as formalized methods, 
but you still can do them by executing your own custom SQL query.

````Swift

	let	db1	=	Database(location: Database.Location.Memory, mutable: true)
	db1.schema().create(table: "T1", column: ["c1"])
	
	let	t1	=	db1.table(name: "T1")
	t1.insert(rowWith: ["c1":"V1"])
	
	db1.apply {
		db1.run(query: "SELECT * FROM T1", success: { (data) -> () in
			for row in data
			{
				assert(row[0] as String == "V1")
			}
		}, failure: { (message) -> () in
			
		})
	}

````


















Roadmap
-------

-	Error handling mechanism need to be reviewed. I am not sure that current
	mechanism is the ideal one. It will be replaced if I discover a better approach.




















Objective-C
-----------
Good old Objective-C version library still exists in `ObjectiveC` folder.
Anyway, it's completely separated version, and nothing related to Swift 
version. Swift version is purely Swift based, and interfaces to SQLite3 C 
API directly.



License
-------
MIT license.
















