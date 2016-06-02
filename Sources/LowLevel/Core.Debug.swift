//
//  Core.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/17/14.
//
//

import Foundation

extension Core {
	static func log<T>(@autoclosure object:()->T) {
		if Debug.mode && Debug.useCoreLogging {
			print(object())
		}
	}

	struct LeakDetector {
		
		enum TargetObjectType {
			case db
			case stmt
		}

		static var theDetector	=	LeakDetector()
		
		mutating func registerInstance(inst:COpaquePointer, of type:TargetObjectType) {
			if Debug.mode || Test.mode {
				precondition(inst != COpaquePointer.init())
				precondition(instanceListForType[type]!.indexOf(inst) == nil)
				instanceListForType[type]!.append(inst)
			}
		}
		mutating func unregisterInstance(inst:COpaquePointer, of type:TargetObjectType) {
			if Debug.mode || Test.mode {
				precondition(inst != COpaquePointer.init())
				let	idx	=	instanceListForType[type]!.indexOf(inst)
				
				precondition(idx != nil)
				instanceListForType[type]!.removeAtIndex(idx!)
			}
		}
		var allInstancesByTypes:Dictionary<TargetObjectType,[COpaquePointer]> {
			get {
				return	instanceListForType
			}
		}
		func countAllInstances() -> Int {
			if Debug.mode || Test.mode {
				let	a1	=   instanceListForType.values.map({ (v:[COpaquePointer]) -> (Int) in return v.count })
				let	a2	=	a1.reduce(0, combine: +)
				return	a2
			}
			else {
				Core.Common.crash(message: "Unsupported feature on RELEASE build. Do not try to call this on RELEASE build.")
			}
		}
		
		private var instanceListForType = [
			TargetObjectType.db:	[COpaquePointer](),
			TargetObjectType.stmt:	[COpaquePointer](),
		]
	}
}














