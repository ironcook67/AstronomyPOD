//
//  APODViewModel.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import Foundation

extension APODView {
	class ViewModel: ObservableObject {
		let apodManager: APODManager

		@Published var isLoading = false
		@Published var showAlert = false
		@Published var errorMessage: String?

		init(apodManager: APODManager) {
			self.apodManager = apodManager
		}

		var apods: [APOD] {
			apodManager.apods
		}

		var apod: APOD {
			if (apodManager.apods.count == 0) {
				return MockData.apod
			} else {
				return apodManager.apods[0]
			}
		}

		@MainActor
		func fetchAPODs() async {
			isLoading = true

			defer {
				isLoading = false
			}

			do {
				let apods = try await apodManager.fetchAPODs()
				apodManager.apods = apods
			} catch {
				showAlert = true
				errorMessage = error.localizedDescription
			}
		}
	}
}
