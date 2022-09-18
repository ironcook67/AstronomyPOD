//
//  APODModel.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import Foundation

struct APOD: Decodable, Comparable, Hashable, Identifiable {
	let date: String
	let explanation: String
	let title: String
	let url: String
	let mediaType: String

	var hdurl: String?
	var copyright: String?

	var imageData: Data?
	var path: URL?

	var id: String {
		self.date
	}

	static func < (lhs: APOD, rhs: APOD) -> Bool {
		lhs.date > rhs.date
	}

	var isVideo: Bool {
		return mediaType == "video"
	}
}

// Some of the APOD entries might have a hdurl or copyright field.
// Make a custom decoder. 
extension APOD {
	enum CodingKeys: String, CodingKey {
		case date
		case explanation
		case title
		case url
		case media_type
	}

	struct DynamicKey: CodingKey {
		var intValue: Int?
		var stringValue: String

		init?(stringValue: String) {
			self.stringValue = stringValue
		}

		init?(intValue: Int) {
			self.intValue = intValue
			self.stringValue = ""
		}
	}

	init(from decoder: Decoder) throws {
		let dynamicKeysContainer = try decoder.container(keyedBy: DynamicKey.self)
		var hdurlValue: String?
		var copyrightValue: String?
		try dynamicKeysContainer.allKeys.forEach { key in
			switch key.stringValue {
			case "hdurl":
				hdurlValue = try dynamicKeysContainer.decode(String.self, forKey: key)
			case "copyright":
				copyrightValue = try dynamicKeysContainer.decode(String.self, forKey: key)
			default: break
			}
		}

		self.hdurl = hdurlValue
		self.copyright = copyrightValue

		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.mediaType = try container.decode(String.self, forKey: .media_type)
		self.date = try container.decode(String.self, forKey: .date)
		self.explanation = try container.decode(String.self, forKey: .explanation)
		self.title = try container.decode(String.self, forKey: .title)
		self.url = try container.decode(String.self, forKey: .url)
	}
}
