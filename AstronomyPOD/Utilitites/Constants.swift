//
//  Constants.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import SwiftUI

enum Theme {
	static let background = Color("background")
	static let detailBackground = Color("detail-background")
	static let text = Color("text")
	static let accent = Color("AccentColor")
}

enum PlaceholderImage {
	static let square = UIImage(named: "default-nasa")!
}

enum ImageCacheConstants {
	static let nestedFolderName = "ImageCache"
}

// MARK: - Networking Constants
enum NetworkError: Error {
	case invalidAPODURL
	case invalidResponse
	case invalidAPODData
}
