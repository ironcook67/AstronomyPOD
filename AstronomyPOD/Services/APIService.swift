//
//  APIService.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import Foundation
import UIKit

struct APIService {
	let urlString: String

	func getJSON<T: Decodable>(dateDecodingStrategy:
							   JSONDecoder.DateDecodingStrategy = .deferredToDate,
							   keyDecodingStrategy:
							   JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) async throws -> T {

		guard let url = URL(string: urlString) else {
			throw APIError.invalidURL
		}

		do {
			let (data, response) = try await URLSession.shared.data(from: url)

			guard let httpResponse = response as? HTTPURLResponse,
				  httpResponse.statusCode == 200 else {
				throw APIError.invalidResponseStatus
			}

			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = dateDecodingStrategy
			decoder.keyDecodingStrategy = keyDecodingStrategy
			do {
				let decodedData = try decoder.decode(T.self, from: data)
				return decodedData
			} catch {
				throw APIError.decodingError(error.localizedDescription)
			}
		} catch {
			throw APIError.dataTaskError(error.localizedDescription)
		}
	}

	func downloadImageData() async throws -> Data {
		// Check to see if this is a YouTube URL, if so, get the thumbnail and
		// use that for the image.
		var urlToUse = urlString
		var isYouTube = false
		if (urlString.lowercased().contains("youtube")) {
			urlToUse = getYouTubeThumbnailURL()
			isYouTube = true
		}

		guard let url = URL(string: urlToUse) else { throw APIError.invalidURL }

		do {
			var (data, _) = try await URLSession.shared.data(from: url)

			// If YouTube returned a small thumbnail, it is likely the
			// video does not have a maxresdefault.jpg. Retry for 0.jpg
			// A recent check showed the default thumbnail at 1097 bytes.
			if isYouTube && data.count < 2000 {
				guard let url = URL(string: getYouTubeThumbnailURL(useZeroJpg: true)) else
				{ throw APIError.invalidURL }
				(data, _) = try await URLSession.shared.data(from: url)
			}

			return data
		} catch {
			throw APIError.dataTaskError(error.localizedDescription)
		}
	}

	private func getYouTubeThumbnailURL(useZeroJpg: Bool = false) -> String {
		let start = urlString.lastIndex(of: "/")
		let end = urlString.lastIndex(of: "?")

		if let start = start, let end = end {
			let newStart = urlString.index(start, offsetBy: 1)
			let videoID = urlString[newStart..<end]
			let jpgName = useZeroJpg ? "0" : "maxresdefault"
			return "https://img.youtube.com/vi/\(videoID)/\(jpgName).jpg"
		}

		return urlString
	}
}

enum APIError: Error, LocalizedError {
	case invalidURL
	case invalidYouTubeURL
	case invalidResponseStatus
	case dataTaskError(String)
	case corruptData
	case decodingError(String)

	var errorDescription: String? {
		switch self {
		case .invalidURL:
			return NSLocalizedString("The endpoint URL is invalid", comment: "")
		case .invalidYouTubeURL:
			return NSLocalizedString("Could not get the YouTube thumbnail", comment: "")
		case .invalidResponseStatus:
			return NSLocalizedString("The API failed to issue a valid response", comment: "")
		case .dataTaskError(let string):
			return string
		case .corruptData:
			return NSLocalizedString("The data provided appears to be corrupt", comment: "")
		case .decodingError(let string):
			return string
		}
	}
}
