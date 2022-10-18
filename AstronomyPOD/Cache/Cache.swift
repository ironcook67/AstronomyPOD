//
//  Cache.swift
//  ImageCache
//
//  Created by Chon Torres on 10/4/22.
// 	Original version from John Sundell https://www.swiftbysundell.com/articles/caching-in-swift/
//
// 	This is a general, persistent cache with NSCache as a base.

import Foundation

final class Cache<Key: Hashable, Value> {
	private let wrapped = NSCache<WrappedKey, Entry>()
	private let keyTracker = KeyTracker()
	private let dateProvider: () -> Date
	private let entryLifetime: TimeInterval

	init(maximumEntryCount: Int = 50,
		 maximumSize: Int = 50 * 1024 * 1024,
		 dateProvider: @escaping () -> Date = Date.init,
		 entryLifetime: TimeInterval = 24 * 3600) {
		wrapped.countLimit = maximumEntryCount
		wrapped.totalCostLimit = maximumSize
		wrapped.delegate = keyTracker
		self.dateProvider = dateProvider
		self.entryLifetime = entryLifetime
	}

	func insert(_ value: Value, forKey key: Key) {
		let date = dateProvider().addingTimeInterval(entryLifetime)
		let entry = Entry(key: key, value: value, expirationDate: date)
		wrapped.setObject(entry, forKey: WrappedKey(key))
		keyTracker.keys.insert(key)
	}

	func value(forKey key: Key) -> Value? {
		guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
			return nil
		}

		// Discard values that have expired
		guard dateProvider() < entry.expirationDate else {
			removeValue(forKey: key)
			return nil
		}

		return entry.value
	}

	func removeValue(forKey key: Key) {
		wrapped.removeObject(forKey: WrappedKey(key))
	}

	func removeAll() {
		wrapped.removeAllObjects()
	}
}

// MARK: - Supporting classes

private extension Cache {
	final class Entry {
		let key: Key
		let value: Value
		let expirationDate: Date

		init(key: Key, value: Value, expirationDate: Date) {
			self.key = key
			self.value = value
			self.expirationDate = expirationDate
		}
	}

	final class WrappedKey: NSObject {
		let key: Key

		init(_ key: Key) { self.key = key }

		override var hash: Int { return key.hashValue }

		override func isEqual(_ object: Any?) -> Bool {
			guard let value = object as? WrappedKey else {
				return false
			}

			return value.key == key
		}
	}

	final class KeyTracker: NSObject, NSCacheDelegate {
		var keys = Set<Key>()

		func cache(_ cache: NSCache<AnyObject, AnyObject>,
				   willEvictObject object: Any) {

			guard let entry = object as? Entry else {
				return
			}

			keys.remove(entry.key)
		}
	}
}

extension Cache {
	subscript(key: Key) -> Value? {
		get { return value(forKey: key) }
		set {
			guard let value = newValue else {
				// If nil was assigned using our subscript,
				// then we remove any value for that key:
				removeValue(forKey: key)
				return
			}

			insert(value, forKey: key)
		}
	}
}

// MARK: - Codable
extension Cache.Entry: Codable where Key: Codable, Value: Codable {}

private extension Cache {
	func entry(forKey key: Key) -> Entry? {
		guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
			return nil
		}

		guard dateProvider() < entry.expirationDate else {
			removeValue(forKey: key)
			return nil
		}

		return entry
	}

	func insert(_ entry: Entry) {
		wrapped.setObject(entry, forKey: WrappedKey(entry.key))
		keyTracker.keys.insert(entry.key)
	}
}

extension Cache: Codable where Key: Codable, Value: Codable {
	convenience init(from decoder: Decoder) throws {
		self.init()

		let container = try decoder.singleValueContainer()
		let entries = try container.decode([Entry].self)
		entries.forEach(insert)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(keyTracker.keys.compactMap(entry))
	}
}

// Todo: Add functionality to filter expired keys.
extension Cache where Key: Codable, Value: Codable {
	func getCacheFileURL(name: String, fileManager: FileManager) -> URL {
		let folderURLs = fileManager.urls(
			for: .cachesDirectory,
			in: .userDomainMask
		)

		return folderURLs[0].appendingPathComponent(name + ".cache")
	}

	func saveToDisk(
		withName name: String,
		using fileManager: FileManager = .default
	) throws {
		let fileURL = getCacheFileURL(name: name, fileManager: fileManager)
		let encoder = JSONEncoder()
		let data = try encoder.encode(self)
		dump(data)
		try data.write(to: fileURL)
	}
}
