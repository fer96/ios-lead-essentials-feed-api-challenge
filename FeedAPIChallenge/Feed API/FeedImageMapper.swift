//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Fernando De La Rosa on 08/09/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImageMapper {
	private struct Root: Decodable {
		private let items: [Image]

		internal var feedImages: [FeedImage] {
			return items.compactMap { $0.item }
		}
	}

	private struct Image: Decodable {
		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: URL

		internal var item: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}
	}

	internal static func resolves(_ data: Data, with httpResponse: HTTPURLResponse) -> FeedLoader.Result {
		let failureResult = FeedLoader.Result.failure(RemoteFeedLoader.Error.invalidData)
		guard httpResponse.statusCode == 200,
		      let feedImages = map(data) else { return failureResult }

		return .success(feedImages)
	}

	private static func map(_ data: Data) -> [FeedImage]? {
		guard let root = try? JSONDecoder().decode(Root.self, from: data) else { return nil }
		return root.feedImages
	}
}
