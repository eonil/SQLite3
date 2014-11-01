////
////  Program.swift
////  EonilSQLite3
////
////  Created by Hoon H. on 11/1/14.
////
////
//
//import Foundation
//
//
/////	MARK:
/////	Set to `class` to prevent copying because this must be a sole owner of an execution.
//public final class Program {
//	
//	
//	internal let	items				=	[] as [Statement]
//	private var		currentExecution	=	nil as Execution?	//	Only one execution can be instanced at once.
//	
//	////
//	
//	init(_ items:[Statement]) {
//		self.items	=	items
//	}
//	deinit {
//	}
//	
//	////
//}
//
//extension Program {
//	
//	public func execute(parameters ps:[Value]) -> Execution {
//		precondition(currentExecution == nil || currentExecution!.processingLock == false, "Previous execution of this statement-list is not finished. You cannot re-execute this statement-list until it once fully finished.")
//		Debug.log("EonilSQLte3 executes: \(items), parameters: \(ps)")
//		
//		for s1 in items {
//			s1.reset()
//			s1.bind(parameters: ps)
//		}
//		
//		currentExecution	=	Execution(items)
//		return	currentExecution!
//	}
//	
//	///	Set to `class` to prevent copying.
//	public final class Execution: GeneratorType {
//		private var	m1:Statement
//		private var	g1:GeneratorOf<Statement>
//		private var	g2:StatementFieldValuesGenerator?
//		private var	v2:[Value]?
//		
//		private var	processingLock	=	false
//		
//		private init(_ items:[Statement]) {
//			m1	=	items[0]
//			g1			=	GeneratorOf<Statement>(items.generate())
//		}
//		
//		///	Available only while the execution is not done yet.
//		public var columns:[String] {
//			get {
//				
//			}
//		}
//		
//		public func next() -> [Value]? {
//			processingLock	=	true
//			//			precondition(processingLock == true, "This execution is not valid anymore.")
//			
//			let	v1	=	g1.next()
//			if g2 == nil { g2 = v1 == nil ? nil : StatementFieldValuesGenerator(v1!) }
//			v2	=	g2?.next()
//			
//			if v2 == nil { processingLock = false }		//	It's finished if it's `nil` twice.
//			return	v2
//		}
//		
//		///	Returns snapshot of all remaining rows at once.
//		private func rest() -> [[Value]] {
//			return	collect(self)
//		}
//		
//		///	Returns snapshot of all rows at once. You can call this only on fresh new `Execution`.
//		///	Once started and unfinished execution cannot be used.
//		///	If you want to avoid collecting of all rows, then you have to iterate this
//		///	manually yourself.
//		public func all() -> [[Value]] {
//			precondition(processingLock == false, "You cannot call this method on once started execution.")
//			return	rest()
//		}
//	}
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//private func snapshotFieldNamesOfRow(r:Statement) -> [String] {
//	let	c	=	r.numberOfFields
//	var	m	=	[] as [String]
//	m.reserveCapacity(c)
//	for i in 0..<c {
//		m.append(r.columnNameAtIndex(i))
//	}
//	return	m
//	
//}
//private func snapshotFieldValuesOfRow(r:Statement) -> [Value] {
//	let	c	=	r.numberOfFields
//	var	m	=	[] as [Value]
//	m.reserveCapacity(c)
//	for i in 0..<c {
//		m.append(r.columnValueAtIndex(i))
//	}
//	return	m
//}
//private func snapshotRowAsDictionary(r:Statement) -> [String:Value] {
//	let	ks	=	snapshotFieldNamesOfRow(r)
//	let	vs	=	snapshotFieldValuesOfRow(r)
//	return	combine(ks, vs)
//}
//
//
//private struct StatementFieldValuesGenerator: GeneratorType {
//	let	s:Statement
//
//	init(_ s:Statement) {
//		self.s	=	s
//	}
//	
//	func next() -> [Value]? {
//		if s.step() {
//			return	snapshotFieldValuesOfRow(s)
//		} else {
//			return	nil
//		}
//	}
//}
//
//
//
//
