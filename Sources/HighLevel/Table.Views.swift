//
//  Table.Views.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 11/2/14.
//
//

import Foundation

extension Table {

	public struct DictionaryView: SequenceType {
		typealias	Generator	=	GeneratorOf<[String:Value]>
		
		unowned let	table:Table
		

		
		public subscript(identity:Identity) -> [String:Value]? {
			get {
				if let vs = table[identity] {
					return	table.info.convertTupleToDictionary([identity], vs)
				}
				return	nil
			}
			set(v) {
				if let v2 = v {
					let	(k,v)	=	table.info.convertDictionaryToKeyAndValueTuples(v2)
					table[k[0]]	=	v
				}
				table[identity]	=	nil
			}
		}
		
		public func generate() -> GeneratorOf<[String:Value]> {
			var	g1	=	table.generate()
			func next() -> [String:Value]? {
				if let (id1, con1) = g1.next() {
					let	d1	=	table.info.convertTupleToDictionary([id1], con1)
					return	d1
				}
				return	nil
			}
			return	GeneratorOf(next)
		}
	}
	
	
	

}








///	MARK:
///	MARK:	CollectionType (or something else )support.

extension Table.DictionaryView {
//		typealias	Index		=	RowIdentityIndex
//		var startIndex:Index {
//			get {
//				return	Index(table: table, identity: startIdentity(table)!)
//			}
//		}
//
//		///	This identity value is max PK number + 1.
//		///	If the max PK number of Int64.max, then this becomes `-1` for a marker value.
//		var endIndex:Index {
//			get {
//				return	Index(table: table, identity: endIdentity(table)!)
//			}
//		}

//		subscript(index:Index) -> Generator.Element {
//			get {
//				return	self[index.identity]!
//			}
//		}

}










///	MARK:
///	MARK:	View Indexings
extension Table {

//	struct RowIdentityIndex: ForwardIndexType {
//		typealias	Identity	=	Table.Identity
//		
//		let	table:Table
//		let	identity:Identity
//		
//		func successor() -> RowIdentityIndex {
//			return	RowIdentityIndex(table: table, identity: nextIdentity(identity, table)!)
//		}
//	}
	
}

//
//func == (left:Table.RowIdentityIndex, right:Table.RowIdentityIndex) -> Bool {
//	return	left.identity == right.identity
//}















//private func startIdentity(table:Table) -> Table.Identity? {
//	
//}
//
/////	This identity value is max PK number + 1.
/////	If the max PK number of Int64.max, then this becomes `-1` for a marker value.
//private func endIdentity(table:Table) -> Table.Identity? {
//	
//}
//
//private func nextIdentity(ofIdentity:Table.Identity, table:Table) -> Table.Identity? {
//	
//}
//







