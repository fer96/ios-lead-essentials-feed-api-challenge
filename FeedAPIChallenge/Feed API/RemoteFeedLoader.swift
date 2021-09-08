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
		client.get(from: url) { [weak self] response in
			switch response {
			case let .success((data, httpResponse)):
				let items = self?.map(data)
				if httpResponse.statusCode != 200 || items == nil {
					completion(.failure(RemoteFeedLoader.Error.invalidData))
				} else {
					completion(.failure(RemoteFeedLoader.Error.connectivity))
				}
			case .failure:
				completion(.failure(RemoteFeedLoader.Error.connectivity))
			}
		}
	}
}

extension RemoteFeedLoader {
	private func map(_ data: Data) -> [FeedImage]? {
		return nil
	}
}
