//
//  DogImagesViewModel.swift
//  Concurrent Dogs
//
//  Created by Fernando Goulart on 3/4/24.
//

import Foundation
import UIKit
import NetworkingImp
import NetworkingInterface

@MainActor
final class DogImagesViewModel {
    var images: [UIImage] = []
    let dogImages: DogImages

    public init(dogImages: DogImages) {
        self.dogImages = dogImages
    }

    func fetchImages() async throws  {
        self.images = try await dogImages.fetchImages()
    }
}

actor DogImages {

    let repository: DogsRepository

    lazy var dogsSequence: DogsSequence = {
        return DogsSequence(fetchDogsUseCase: FetchDogsUseCase(repository: repository))
    }()

    init(repository: DogsRepository) {
        self.repository = repository
    }

    func fetchImages() async throws -> [UIImage] {
        try await withThrowingTaskGroup(of: UIImage.self, returning: [UIImage].self) { [repository, dogsSequence] group in
            for try await dogs in dogsSequence {
                for dog in dogs {
                    group.addTask {
                        guard let url = URL(string: dog.image) else {
                            // FIXME
                            throw DogsError.invalidImageData
                        }
                        try Task.checkCancellation()
                        return try await repository.fetchImage(url: url)
                    }
                }
            }
            var images: [UIImage] = []
            for try await result in group {
                images.append(result)
            }
            return images
        }
    }
}
