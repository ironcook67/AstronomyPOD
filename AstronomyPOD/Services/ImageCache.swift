//
//  ImageCache.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import Foundation
import UIKit

struct ImageCache {
	let apod: APOD
	var image: UIImage?

	let manager = FileManager.default

	var imageCacheFilename: String {
		apod.date + ".jpg"
	}

	func getImagePath() throws -> URL {
		do {
			let rootFolderURL = try manager.url(for: .cachesDirectory,
												in: .userDomainMask,
												appropriateFor: nil,
												create: false)

			let nestedFolderURL = rootFolderURL.appendingPathComponent(
				ImageCacheConstants.nestedFolderName)

			do {
				try manager.createDirectory(
					at: nestedFolderURL,
					withIntermediateDirectories: false,
					attributes: nil
				)
			} catch CocoaError.fileWriteFileExists {
				// Folder already existed, ignore. This is safer than
				// checking for the existence of the folder since another
				// thread could create a folder and throw an exception.
			}

			return nestedFolderURL.appendingPathComponent(imageCacheFilename)
		} catch {
			throw ImageCacheError.PathError
		}
	}

	func cacheImage(compressionQuality: Double = 0.5) throws {
		if (image == nil) {
			print("🤖🤖🤖🤖XXXX \(apod.date)")
			return
		}

		guard let jpgData = image?.jpegData(compressionQuality: compressionQuality) else {
			print("🤖🤖🤖🤖 \(apod.date)")
			// throw ImageCacheError.DataError
			return
		}

		do {
			let path = try getImagePath()
			// print("🚗 path: " + path.relativePath)

			try jpgData.write(to: path)
		} catch {
			throw ImageCacheError.WriteError
		}
	}

	func cachedImageExists() throws -> Bool {
		do {
			let path = try getImagePath()
			if let _ = manager.contents(atPath: path.relativePath) {
				return true
			} else {
				return false
			}
		} catch {
			throw ImageCacheError.PathError
		}
	}

	func getCachedImage() throws -> UIImage? {
		do {
			let path = try getImagePath()
			// print("🚙 getCachedImage() path: " + path.relativePath)

			if let fileData = manager.contents(atPath: path.relativePath) {
				print("💥 Cache Hit!!! \(path.relativePath)")
				return UIImage(data: fileData)
			} else {
				print("💣 Cache Miss!!!") // \(path.relativePath)")
				return nil
			}
		} catch {
			throw ImageCacheError.ReadError
		}
	}

	func deleteCachedImage() throws {
		let path = try getImagePath()
		print("😵 path: " + path.relativePath)

		do {
			try manager.removeItem(atPath: path.relativePath)
		} catch {
			throw ImageCacheError.RemoveError
		}
	}
}

enum ImageCacheError: Error {
	case DataError
	case PathError
	case WriteError
	case ReadError
	case RemoveError
}
