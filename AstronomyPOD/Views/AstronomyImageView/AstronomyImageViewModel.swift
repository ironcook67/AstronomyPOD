//
//  AstronomyImageViewModel.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import Foundation
import UIKit

extension AstronomyImageView {
	class ViewModel: ObservableObject {
		@Published var apod: APOD
		@Published var isLoading = false

		init(apod: APOD) {
			self.apod = apod
		}

		var imageData: Data {
			apod.imageData ?? Data()
		}

		func imagePath(_ apod: APOD) -> String {
			return ""
		}

		@MainActor
		func fetchImage() async {
			isLoading = true
			defer { isLoading = false }

			do {
				// See if there is a cached image
				var imageCache = ImageCache(apod: apod)
				let image = try imageCache.getCachedImage()
				if let image = image {
					imageCache.image = image
					apod.imageData = image.jpegData(compressionQuality: 0.80) ?? Data()
				} else {
					// Cache and Render
					let imageManager = APIService(urlString: apod.url)
					let imageData = try await imageManager.downloadImageData()
					apod.imageData = imageData
					imageCache.image = UIImage(data: imageData)
					try imageCache.cacheImage()
				}
			} catch {
				print(error.localizedDescription)
			}
		}
	}
}
