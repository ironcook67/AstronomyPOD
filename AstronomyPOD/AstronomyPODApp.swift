//
//  AstronomyPODApp.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import SwiftUI

@main
struct AstronomyPODApp: App {
	@StateObject var apodManager: APODManager

	init() {
		let apodManager = APODManager()
		_apodManager = StateObject(wrappedValue: apodManager)
	}

	var body: some Scene {
		WindowGroup {
			APODView(apodManager: apodManager)
				.environmentObject(apodManager)
		}
	}
}
