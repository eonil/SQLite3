//
//  ApplicationController.swift
//  TestToolForOSX
//
//  Created by Hoon H. on 10/29/14.
//
//

import Cocoa
import EonilSQLite3

@NSApplicationMain
class ApplicationController: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!


	func applicationDidFinishLaunching(aNotification: NSNotification) {
		
//		test2()
		test3()
		
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}


}

