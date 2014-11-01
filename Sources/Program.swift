//
//  Program.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 11/1/14.
//
//

import Foundation


///	MARK:
///	Set to `class` to prevent copying because this must be a sole owner of an execution.
public final class Program {
	
	
	internal let	items				=	[] as [Statement]
	private var		currentExecution	=	nil as Execution?	//	Only one execution can be instanced at once.
	
	////
	
	init(_ items:[Statement]) {
		self.items	=	items
	}
	deinit {
	}
	
	////
}

extension Program {
	
	public func execute(parameters ps:[Value]) -> Execution {
		precondition(currentExecution == nil || currentExecution!.processingLock == false, "Previous execution of this statement-list is not finished. You cannot re-execute this statement-list until it once fully finished.")
		Debug.log("EonilSQLte3 executes: \(items), parameters: \(ps)")
		
		for s1 in items {
			s1.reset()
			s1.bind2(parameters: ps)
		}
		
		currentExecution	=	Execution(items)
		return	currentExecution!
	}
	
	///	Set to `class` to prevent copying.
	public final class Execution: GeneratorType {
		private var	m1:Statement
		private var	g1:GeneratorOf<Statement>
		private var	g2:GeneratorOf<Row>?
		private var	v2:Row?
		
		private var	processingLock	=	false
		
		private init(_ items:[Statement]) {
			m1	=	items[0]
			g1			=	GeneratorOf<Statement>(items.generate())
		}
		
		public func next() -> Row? {
			processingLock	=	true
			//			precondition(processingLock == true, "This execution is not valid anymore.")
			
			let	v1	=	g1.next()
			if g2 == nil { g2 = v1 == nil ? nil : GeneratorOf<Row>(v1!) }
			v2	=	g2?.next()
			
			if v2 == nil { processingLock = false }		//	It's finished if it's `nil` twice.
			return	v2
		}
		
		
		///	Returns snapshot of all remaining rows at once.
		private func rest() -> [[String:Value]] {
			var	m1	=	[] as [[String:Value]]
			while let r1 = next() {
				m1	+=	[snapshotRow(r1)]
			}
			return	m1
			//			return	map(enumerate(self), { snapshot($1) })
		}
		///	Returns snapshot of all rows at once. You can call this only on fresh new `Execution`.
		///	Once started and unfinished execution cannot be used.
		///	If you want to avoid collecting of all rows, then you have to iterate this
		///	manually yourself.
		public func all() -> [[String:Value]] {
			precondition(processingLock == false, "You cannot call this method on once started execution.")
			return	rest()
		}
	}
}


















private func snapshotRow(row:Row) -> [String:Value] {
	var	m	=	[:] as [String:Value]
	let	c	=	row.numberOfFields
	for i in 0..<c {
		if	row.isNullField(atIndex: i) == false {
			let	n:String	=	row.columnNameOfField(atIndex: i)
			let	v:Value		=	row[i]
			
			m[n]	=	v
		}
	}
	return	m
}

