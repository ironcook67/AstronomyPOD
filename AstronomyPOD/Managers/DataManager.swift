//
//  DataManager.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 10/14/22.
//

import UIKit

class DataManager: ObservableObject {
	// This is overkill, but is being implemented for future, planned,
	// functionality.
	private var apodCache: Cache<String, APOD>

	static var shared = DataManager()
	private init() {
		self.apodCache = Cache(maximumEntryCount: 2, entryLifetime: 25 * 3600)
	}

	func getAPOD() async throws -> APOD  {
		// Convert local time to UTC.
		let dateString = DateFormatter.NASADate.string(from: Date())

		// Check the cache
		if let cachedAPOD = apodCache.value(forKey: dateString) {
			return cachedAPOD
		}

		// If not in cache, download it and save it to cache.
		do {
			// Get the APOD
			let apiService = APIService(urlString: NASAURLBuilder.urlString())
			var apod: APOD = try await apiService.getJSON()

			// Get the image
			let imageManager = APIService(urlString: apod.url)
			let imageData = try await imageManager.downloadImageData()
			apod.imageData = imageData

			// Cache the apod
			apodCache.insert(apod, forKey: dateString)

			//

			return apod
		} catch {
			throw APIError.corruptData
		}
	}

	func loadCacheFromDisk() async {
		let fileURL = apodCache.getCacheFileURL(name: "apod-cache",
											   fileManager: FileManager.default)

		guard FileManager.default.fileExists(atPath: fileURL.path) else {
			return
		}

		// Read the Cache off of the disk.
		do {
			let data = try Data(contentsOf: fileURL)
			let decoder = JSONDecoder()
			apodCache = try decoder.decode(Cache<String, APOD>.self,
										   from: data)
		} catch {
			print("loadCache \(error.localizedDescription)")
		}
	}
}
