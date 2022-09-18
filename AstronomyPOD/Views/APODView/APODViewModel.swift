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

		var unwrappedAPOD: APOD {
			if apod == nil {
				return APOD(date: "2022-08-12",
							explanation: "What does a black hole look like?",
							title: "First Horizon-Scale Image of a Black Hole",
							url: "https://apod.nasa.gov/apod/image/2205/M87bh_EHT_960.jpg",
							mediaType: "NASA")
			} else {
				return apod!
			}
		}

		@MainActor
		func fetchAPODs() async {
			isLoading = true

			defer {
				isLoading = false
			}

			do {
				let apiService = APIService(urlString: NASAURLBuilder.urlString())
				apod = try await apiService.getJSON()
				if apod == nil {
					throw APIError.corruptData
				}

				let imageManager = APIService(urlString: apod!.url)
				let imageData = try await imageManager.downloadImageData()
				apod!.imageData = imageData
			} catch {
				showAlert = true
				errorMessage = error.localizedDescription
			}
		}
	}
}
