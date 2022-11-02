//
//  APODStore.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 11/1/22.
//

import Foundation

class APODStore: ObservableObject {
	private var apod: APOD?

	static let shared = APODStore()

	var apodStoreURL: URL = {
		FileManager.default
			.urls(for: .documentDirectory, in: .userDomainMask).first!
			.appendingPathComponent("apods.json")
	}()

	private init() { }

	func getAPOD() async throws -> APOD {
		// Check the existng APOD
		if apod != nil && apod!.isCurrent {
			return apod!
		}

		// Check saved file
		if FileManager.default.fileExists(atPath: apodStoreURL.path) {
			do {
				let data = try Data(contentsOf: apodStoreURL)
				let decoder = JSONDecoder()
				let newAPOD = try decoder.decode(APOD.self, from: data)
				if newAPOD.isCurrent {
					apod = newAPOD
					return newAPOD
				}
			} catch {
				print("❌ Error reading in saved APOD. \(error)")
			}
		}

		// Make the network call and save a new file.
		do {
			// Get the APOD
			let apiService = APIService(urlString: NASAURLBuilder.urlString())
			var newAPOD: APOD = try await apiService.getJSON()

			// Get the image
			let imageManager = APIService(urlString: newAPOD.url)
			let imageData = try await imageManager.downloadImageData()
			newAPOD.imageData = imageData
			apod = newAPOD

			// Save to a file.
			Task {
				await saveAPODToDisk()
			}

			return apod!
		} catch {
			throw APIError.corruptData
		}
	}

	func saveAPODToDisk() async {
		do {
			let encoder = JSONEncoder()
			let data = try encoder.encode(apod)
			try data.write(to: apodStoreURL, options: [.atomic])
		} catch {
			print("❌ Error encoding APOD \(error)")
		}
	}
}
