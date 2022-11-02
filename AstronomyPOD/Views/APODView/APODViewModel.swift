//
//  APODViewModel.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import Foundation

extension APODView {
	class ViewModel: ObservableObject {
		@Published var apod: APOD?
		@Published var isLoading = false
		@Published var showAlert = false
		@Published var errorMessage: String?
		private var apodStore = APODStore.shared

		var unwrappedAPOD: APOD {
			if apod == nil {
				return MockData.apod
			} else {
				return apod!
			}
		}

		@MainActor
		func fetchAPOD() async {
			isLoading = true

			defer {
				isLoading = false
			}

			do {
				apod = try await apodStore.getAPOD()
				if apod == nil {
					throw APIError.corruptData
				}
			} catch {
				showAlert = true
				errorMessage = error.localizedDescription
			}
		}
	}
}
