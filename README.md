EonilSQLite3
============
Hoon H., 2014/09/16






This provides SQLite3 database access on Swift.

-	Simple table access like a dictionary. You can iterate rows using
	tuples or dictionaries. 

-	Auto-completion friendly query methods. No manual query command 
	composition for basic CRUD and DDL operations. (currently stutter
	due to slow compiler...)

-	Array and dictionary based input/output access manner. Dictionary 
	like direct table access.

-	Automatically supports nested transactions.

-	Forces safety statically and dynamically. Does not allow you 
	to do funny stuffs. Crashes on any illegal operations.




Getting Started
---------------
Embed the project as a subproject of your project, and link iOS dynamic
framewor target. If you need to target iOS 7, then you have to copy the
source files manually into your project. 







How to Use
----------
Schematic illustration.

````Swift

	import EonilSQLite3

	///	Create new mutable database in memory.
	let	db1	=	Connection(location: Connection.Location.Memory, editable: true)

	///	Create a new table.
	db1.schema().create(tableName: "T1", keyColumnNames: ["k1"], dataColumnNames: ["v1", "v2", "v3"])

	///	Make a single table accessor object.
	let	t1	=	db1.tables["T1"]

	///	Insert a new row.
	t1[111]	=	[42, "Here be dragons.", nil]

	///	Verify by selecting all current rows.
	let	rs1	=	collect(t1)
	assert(rs1.count == 1)
	assert(rs1[0]["v1"]!.integer! == 42)
	assert(rs1[0]["v2"]!.text! == "Here be dragons.")

	///	Update the row.
	t1[111]	=	[108, "Crouching tiger.", nil]

	///	Verify!
	let	rs2	=	collect(t1)
	assert(rs2.count == 1)
	assert(rs2[0]["v2"]!.text! == "Crouching tiger.")

	///	Delete the row.
	t1[111]	=	nil

	///	Verify!
	let	rs3	=	collect(t1)
	assert(rs3.count == 0)

````

You need to perform any operations always in an explicit transaction. It's 
not allowed to run operations without transaction. 

Nested transaction is also supported. (using implicitly generated savepoint 
names which you can customize)

````Swift

	let	db1	=	Connection(location: Connection.Location.Memory, editable: true)
	
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






Execute Custom SQL If You Want More
-----------------------------------
This library aims very simple, quick way to manipulate SQLite3.
For the other things, you need to write your own query yourself
manually. For example, this library does not provide type-safe
way to `JOIN` or autoincement PK value.


````Swift

	let	db1	=	Connection(location: Connection.Location.Memory, editable: true)
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














Errors
------
Valid input produces valid output.
Invalid input causes state corruption, and program shouldn't continue.
In this case, there're two options. 

-	Abort the program.
-	Return error instead of result.

This library just crashes by default to simplify everything. You're responsible
to provide valid inputs. Check current state id required. 

Of course with a few of exceptions. If it's unacceptable expensive or impossible
to check validity of input without actually executing it, then it will return
`Evaluation<V>` to determine error or result. In this case the feature guarantees
*strong exception safety* (C++ term). Which means program state will be fully 
consistent even when the feature returns an error.




















License
-------
MIT license.
















