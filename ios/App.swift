//
//  momoApp.swift
//  momo
//
//  Created by Andrew Tan on 2023-03-30.
//

import SwiftUI

func makeCString(from str: String) -> UnsafeMutablePointer<Int8> {
	let count = str.utf8.count + 1
	let result = UnsafeMutablePointer<Int8>.allocate(capacity: count)
	str.withCString { (baseAddress) in
		result.initialize(from: baseAddress, count: count)
	}
	return result
}

func getDocumentsDirectory() -> String {
	let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	return paths[0].path
}

@main
struct momoApp: App {
	
	
		var start_ret_code = start(
			makeCString(from: getDocumentsDirectory()),
			makeCString(from: Bundle.main.resourcePath!)
		)
	
    var body: some Scene {
        WindowGroup {
					ContentView().onAppear(){
						lua_do_string(makeCString(from: "print('---- Hello World -------')"))
						lua_do_string(makeCString(from: "print(package.cpath)"))
						lua_do_string(makeCString(from: "package.path = package.path .. ';" +
																			Bundle.main.resourcePath! + "/lua-src/?.lua'"))
						lua_do_string(makeCString(from: "print(package.path)"))
						lua_do_file(makeCString(from: Bundle.main.resourcePath! + "/hello.lua"))
					}
        }
			
    }
}
