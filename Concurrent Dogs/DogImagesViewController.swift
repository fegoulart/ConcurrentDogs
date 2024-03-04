//
//  DogImagesViewController.swift
//  Concurrent Dogs
//
//  Created by Fernando Goulart on 3/4/24.
//

import Foundation
import UIKit
import NetworkingInterface
import NetworkingImp
import Alamofire

final class DogImagesViewController: UIViewController {

    @IBOutlet weak var dogsCollectionView: UICollectionView!

    lazy var interceptor: Interceptor = {
        Interceptor(adapter: MyAdapter(), retrier: MyRetrier())
    }()

    lazy var repository: DogsRepository = {
        DogsRepository(
            httpClient: AFNetworkService(
                dataService: AFDataNetworkService(
                    interceptor: interceptor
                ),
                decodableService: AFDecodableNetworkService<[DogDTO]>(
                    interceptor: interceptor
                )
            )
        )
    }()

    lazy var viewModel: DogImagesViewModel = {
        DogImagesViewModel(dogImages: DogImages(repository: repository))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        dogsCollectionView.dataSource = self
        dogsCollectionView.delegate = self
        Task {
            try await viewModel.fetchImages()
        }
    }

}

extension DogImagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: DogImageCell = dogsCollectionView.dequeueReusableCell(withReuseIdentifier: "dogImageCell" , for: indexPath) as? DogImageCell else {
            return UICollectionViewCell()
        }
        cell.setImage(viewModel.images[indexPath.row])
        return cell
    }
}

extension DogImagesViewController: UICollectionViewDelegate {

}
