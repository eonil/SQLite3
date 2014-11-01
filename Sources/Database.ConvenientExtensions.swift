//
//  Database.ConvenientExtensions.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 11/1/14.
//
//

import Foundation

extension Database {
	
	///	Executes a single query.
	///	You always need a valid transaction context to call this method.
	public func run(query:Query.Expression) -> [[String:Value]] {
		return	run(query.code, parameters: query.parameters.map {$0()})
	}
	
	///	Executes a single query.
	///	You always need a valid transaction context to call this method.
	public func run(query:QueryExpressible) -> [[String:Value]] {
		return	run(query.express())
	}
	
	///	Executes a single query.
	///	You always need a valid transaction context to call this method.
	public func run(query:String) -> [[String:Value]] {
		return	run(query, parameters: [])
	}
	
	///	Executes a single query.
	///	You always need a valid transaction context to call this method.
	public func run(query:String, parameters:[Value]) -> [[String:Value]] {
		precondition(hasExplicitTransaction == true)
		return	runWithoutExplicitTransactionCheck(query, parameters: parameters)
	}
	
	///	Executes a single query.
	func runWithoutExplicitTransactionCheck(query:String, parameters:[Value]) -> [[String:Value]] {
		let	s	=	compile(query)
		let	x	=	s.execute(parameters)
		return	x.allRowsAsDictionaries()
	}
	
}







extension Database {
	
	public struct Default {
		public struct Generator {
			///	Maximum resolution is `1/(Int.max-1)` per a second.
			///	That's the hard limit of this algorithm. If you need something
			///	better, you have to make and specify your own generator on initializer
			///	of `Database` class.
			public static func uniqueAtomicUnitName() -> String {
				struct deduplicator {
					var	lastSeed			=	0
					var	duplicationCount	=	0
					
					mutating func stepOne() -> String {
						let	t1	=	Int(NSDate().timeIntervalSince1970)
						if t1 == lastSeed {
							precondition(duplicationCount < Int.max)
							duplicationCount	+=	1
						} else {
							lastSeed			=	t1
							duplicationCount	=	0
						}
						return	"eonil__sqlite3__\(lastSeed)__\(duplicationCount)"
					}
					
					static var	defaultInstance	=	deduplicator()
				}
				
				return	deduplicator.defaultInstance.stepOne()
			}
		}
	}
}














extension Database {
	
	///	Get schema informations.
	public func schema() -> Database.Schema {
		return	Schema(database: self)
	}
	///	Get table object which provides table access features.
	public func table(name n:String) -> Table {
		return	Table(database: self, name: n)
	}
	
}







