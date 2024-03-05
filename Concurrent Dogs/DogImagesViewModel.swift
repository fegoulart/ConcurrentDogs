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
    @TaskLocal static var url: String?

    lazy var dogsSequence: DogsSequence = {
        return DogsSequence(fetchDogsUseCase: FetchDogsUseCase(repository: repository))
    }()

    init(repository: DogsRepository) {
        self.repository = repository
    }

    func fetchImages() async throws -> [UIImage] {
        try await withThrowingTaskGroup(of: UIImage.self, returning: [UIImage].self) { [repository, dogsSequence] group in
            var urls: [String] = []
            for try await dogs in dogsSequence {
                for dog in dogs {
                    urls.append(dog.image)
                }
            }
            let maxDownloadTasks = min(10, urls.count) // limiting to 10 tasks at a time
            for urlIndex in 0..<maxDownloadTasks {
                if let url = URL(string: urls[urlIndex]) {
                    group.addTask {
                        try Task.checkCancellation()

                        // Testing @TaskLocal usage
                        return try await DogImages.$url.withValue(url.absoluteString) {
                            try await repository.fetchImage(url: url)
                        }
                    }
                }
            }

            var images: [UIImage] = []
            var nextIndex = maxDownloadTasks
            let expectedSize = CGSize(width: 100, height: 100)
            for try await result in group {
                if nextIndex < urls.count {
                    if let url = URL(string: urls[nextIndex]) {
                        group.addTask {
                            try Task.checkCancellation()

                            // Testing @TaskLocal usage
                            return try await DogImages.$url.withValue(url.absoluteString) {
                                try await repository.fetchImage(url: url)
                            }
                        }
                    }
                }
                nextIndex += 1
                try Task.checkCancellation()
                let image = try await imageResize(image: result, imageSize: expectedSize)
                images.append(image)
            }
            return images
        }
    }

    private func imageResize(image: UIImage,imageSize: CGSize) async throws -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        image .draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            // TODO: Create a new error type
            throw DogsError.invalidImageData
        }
        UIGraphicsEndImageContext()
        return newImage
    }
}
