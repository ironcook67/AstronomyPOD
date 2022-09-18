//
//  APODManager.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import Foundation
import UIKit

final class APODManager: ObservableObject {
	@Published private(set) var dates: ClosedRange<Date>
	@Published var apods: [APOD] = []
	private var calendar = Calendar.current

	init() {
		let startDate = Date.dateFromThisDate(date: .now, days: -5)
		let dateRange = startDate...Date.now
		_dates = Published(initialValue: dateRange)
	}

	func fetchAPODs() async throws -> [APOD] {
		// Check against Cache

		// Download if needed.

		let urlString = NASAURLBuilder.urlString(start: dates.lowerBound, end: dates.upperBound)
		let apiService = APIService(urlString: urlString)

		return try await apiService.getJSON()
	}

	// Verify that the most current page is loaded in Cache
	func refreshCurrent() async throws {
		// The first possible entry might be tomorrow's date, depending on the
		// location.


		do {
			try await updateLatestCache()
		} catch {
			throw ImageCacheError.PathError
		}
	}

	func refreshRange(start: Date, end: Date) async throws {
		if start < dates.lowerBound {

		}

		if end > dates.upperBound {

		}
	}

	private func updateLatestCache() async throws {
		do {
			let apiService = APIService(urlString: NASAURLBuilder.urlString())
			let apod: APOD = try await apiService.getJSON()
			let imageCache = ImageCache(apod: apod)
			try imageCache.cacheImage()
			dates = dates.lowerBound...(DateFormatter.yyyyMMdd.date(from: apod.date) ?? Date())
		} catch {
			throw ImageCacheError.PathError
		}
	}

	// Returns an APOD for a passed string date. If the string
	// is empty, the most recent APOD is returned.
	func getAPOD(date: String = "") async throws -> APOD {
		let apiService = APIService(urlString: NASAURLBuilder.urlString())

		do {
			var apod: APOD = try await apiService.getJSON()
			let imageManager = APIService(urlString: apod.url)
			apod.imageData = try await imageManager.downloadImageData()
			return apod
		} catch {
			throw error
		}
	}
}
