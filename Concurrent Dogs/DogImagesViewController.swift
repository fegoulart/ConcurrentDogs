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

    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    let cellsPerRow = 3

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
        dogsCollectionView?.contentInsetAdjustmentBehavior = .always
        
        collectionViewFlowLayout?.minimumInteritemSpacing = 10
        collectionViewFlowLayout?.minimumLineSpacing = 10
        collectionViewFlowLayout?.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionViewFlowLayout?.itemSize = CGSize(width: 50, height: 50)
        collectionViewFlowLayout?.estimatedItemSize = CGSize(width: 110, height: 110)
        dogsCollectionView.collectionViewLayout = collectionViewFlowLayout
        dogsCollectionView.register(DogImageCell.self, forCellWithReuseIdentifier: "dogImageCell")
        dogsCollectionView.setNeedsLayout()
    
        Task {
            try await viewModel.fetchImages()
            self.dogsCollectionView.reloadData()
        }
    }

    override func viewWillLayoutSubviews() {
        collectionViewFlowLayout?.itemSize = CGSize(width: 110, height: 110)
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

extension DogImagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 110, height: 110)
    }
}
