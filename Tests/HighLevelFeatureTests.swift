//
//  EonilSQLite3___OSX___Tests.swift
//  EonilSQLite3 - OSX - Tests
//
//  Created by Hoon H. on 11/3/14.
//
//

import Foundation
import XCTest
import EonilSQLite3





func collect(var t:Table) -> [[String:Value]] {
	var	g1	=	t.dictionaryView.generate()
	var	a1	=	[] as [[String:Value]]
	
	while let e = g1.next() {
		a1.append(e)
	}
	return	a1
}



class HighLevelFeatureTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	
	
	
	
	func testBasicsHighLevelFeaturesWithTransaction() {
		
		///	Create new mutable database in memory.
		let	db1	=	Database(location: Connection.Location.Memory, editable: true)
		func tx1() {
			///	Create a new table.
			db1.schema.create(tableName: "T1", keyColumnNames: ["k1"], dataColumnNames: ["v1", "v2", "v3"])
			
			///	Make a single table accessor object.
			let	t1	=	db1.tables["T1"]
			
			///	Insert a new row.
			t1[111]	=	[42, "Here be dragons.", nil]
			
			///	Verify by selecting all current rows.
			let	rs1	=	collect(t1)

			XCTAssert(rs1.count == 1)
			XCTAssert(rs1[0]["v1"]!.integer! == 42)
			XCTAssert(rs1[0]["v2"]!.text! == "Here be dragons.")
			
			///	Update the row.
			t1[111]	=	[108, "Crouching tiger.", nil]
			
			///	Verify!
			let	rs2	=	collect(t1)
			XCTAssert(rs2.count == 1)
			XCTAssert(rs2[0]["v2"]!.text! == "Crouching tiger.")
			
			///	Delete the row.
			t1[111]	=	nil
			
			///	Verify!
			let	rs3	=	collect(t1)
			XCTAssert(rs3.count == 0)
		}
		
		///	Perform a transaction with multiple commands.
		db1.apply(tx1)
	}
	
	
	func testBasicHighLevelFeaturesWithNestedTransactions() {
		let	db1	=	Database(location: Connection.Location.Memory, editable: true)
		
		///	Out-most transaction.
		func tx1() {
			db1.schema.create(tableName: "T1", keyColumnNames: ["k1"], dataColumnNames: ["v1", "v2", "v3"])
			let	t1	=	db1.tables["T1"]
			
			///	Outer transaction.
			func tx2() -> Bool {
				///	Insert a new row.
				t1[111]	=	[42, "Here be dragons.", nil]
				
				///	Inner transaction.
				func tx3() -> Bool {
					///	Update the row.
					t1[111]	=	[108, "Crouching tiger.", nil]
					
					///	Verify the update.
					let	rs2	=	collect(t1)
					XCTAssert(rs2.count == 1)
					XCTAssert(rs2[0]["v2"]!.text! == "Crouching tiger.")
					
					///	And rollback.
					return	false
				}
				db1.applyConditionally(tx3)
				
				///	Verify inner rollback.
				let	rs2	=	collect(t1)
				XCTAssert(rs2.count == 1)
				XCTAssert(rs2[0]["v1"]!.integer! == 42)
				XCTAssert(rs2[0]["v2"]!.text! == "Here be dragons.")
				
				return	false
			}
			
			///	Verify outer rollback.
			let	rs2	=	collect(t1)
			XCTAssert(rs2.count == 0)
		}
		db1.apply(tx1)
	}
}





























