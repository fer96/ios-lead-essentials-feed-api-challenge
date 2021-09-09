//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { response in
			switch response {
			case let .success((data, httpResponse)):
				completion(FeedImageMapper.resolves(data, with: httpResponse))
			case .failure:
				completion(.failure(RemoteFeedLoader.Error.connectivity))
			}
		}
	}
}

private final class FeedImageMapper {
	private struct Root: Decodable {
		private let images: [Image]

		internal var feedImages: [FeedImage] {
			return images.compactMap { $0.item }
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
		guard httpResponse.statusCode == 200 else { return failureResult }

		let feedImages = map(data)
		return feedImages.isEmpty ? failureResult : .success(feedImages)
	}

	private static func map(_ data: Data) -> [FeedImage] {
		guard let root = try? JSONDecoder().decode(Root.self, from: data) else { return [FeedImage]() }
		return root.feedImages
	}
}
