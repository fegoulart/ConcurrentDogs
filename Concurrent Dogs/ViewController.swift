//
//  ViewController.swift
//  Concurrent Dogs
//
//  Created by Fernando Goulart on 2/28/24.
//

import UIKit
import NetworkingInterface
import Alamofire
import NetworkingImp

@MainActor
class CellController {

    var cell: UITableViewCell?
    var dog: Dog
    let fetchImage: any FetchDogImageUseCaseProtocol
    let cancelImageRequest: any CancelDogImageRequestUseCaseProtocol

    init(
        dog: Dog,
        fetchImage: any FetchDogImageUseCaseProtocol,
        cancelImageRequest: any CancelDogImageRequestUseCaseProtocol
    ) {
        self.dog = dog
        self.fetchImage = fetchImage
        self.cancelImageRequest = cancelImageRequest
    }

    func getCell() -> UITableViewCell {
        guard let cell else {
            let newCell = UITableViewCell(style: .default, reuseIdentifier: "dog")
            var content = newCell.defaultContentConfiguration()
            content.text = dog.breed
            newCell.contentConfiguration = content
            cell = newCell
            Task {
                await loadImage()
            }
            return newCell
        }
        Task {
            await loadImage()
        }
        return cell
    }

    func loadImage() async {
        guard !dog.image.isEmpty, let url = URL(string: dog.image) else { return }
        do {
            if let image = try await fetchImage.execute(url: url) as? UIImage {
                setCellImage(image)
                print("\(dog.breed) image downloaded")
            }
        } catch (let error) {
            if let error: DogsError = error as? DogsError, error == .taskAlreadyExists {
                print("taskAlreadyExists to download image for \(dog.breed)")
                return
            }
            guard let afError: AFError = error as? AFError else {
                assertionFailure(error.localizedDescription)
                return
            }
            switch afError {
            case .explicitlyCancelled: break
            default:
                assertionFailure(error.localizedDescription)
                break
            }
        }
    }

    private func setCellImage(_ image: UIImage) {
        guard let cell else { return }
        var configuration = cell.defaultContentConfiguration()
        configuration.text = dog.breed
        configuration.image = image
        configuration.imageProperties.maximumSize = .init(width: 40, height: 40)
        cell.contentConfiguration = configuration
    }

    func cancel() async {
        do {
            if !dog.image.isEmpty, let url = URL(string: dog.image) {
                try await cancelImageRequest.execute(url: url)
            }
            cell = nil
            print("\(dog.breed) image set to nil")
        } catch (let error) {
            if let dogError: DogsError = error as? DogsError, dogError  == DogsError.couldNotFindTaskToCancel {
                print("could not cancel image task for dog: \(dog.breed)")
            }
        }
    }

    deinit {
        Task {
            await cancel()
        }
    }

}

final class ViewController: UIViewController {

    @IBOutlet weak var dogsTableView: UITableView!

    var viewModel: ViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        let interceptor = Interceptor(adapter: MyAdapter(), retrier: MyRetrier())
        let repository = DogsRepository(
            httpClient: AFNetworkService(
                dataService: AFDataNetworkService(
                    interceptor: interceptor
                ),
                decodableService: AFDecodableNetworkService<[DogDTO]>(
                    interceptor: interceptor
                )
            )
        )
        viewModel = ViewModel(
            fetchDogUseCase: FetchDogsUseCase(
                repository: repository
            ),
            fetchImageUseCase: FetchImageUseCase(
                repository: repository
            ),
            cancelImageUseCase: CancelDogImageRequestUseCase(
                repository: repository
            )
        )
        dogsTableView.delegate = self
        dogsTableView.dataSource = self
        dogsTableView.prefetchDataSource = self
        Task {
            try await viewModel?.fetchNext()
            dogsTableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.dogsCellController.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = viewModel?.dogsCellController[indexPath.row].getCell() else {
            assertionFailure()
            return UITableViewCell()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let currentLastIndex = viewModel?.dogsCellController.count ?? 0
        if indexPath.item == (viewModel?.dogsCellController.count ?? 0) - 1 {
            Task {
                do {
                    try await viewModel?.fetchNext()
                    guard let numberOfRows = viewModel?.dogsCellController.count, numberOfRows > currentLastIndex else {
                        return
                    }
                    print("inserting new rows from: \(currentLastIndex) to \(numberOfRows)")
                    tableView.beginUpdates()
                    for i in currentLastIndex..<numberOfRows {
                        tableView.insertRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
                    }
                    tableView.endUpdates()
                    // dogsTableView.reloadData()
                } catch (let error){
                    print(error.localizedDescription)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard let cellController = viewModel?.dogsCellController[indexPath.row] else {
                assertionFailure("Strange")
                continue
            }
            Task {
                let breed = cellController.dog.breed
                print("prefetching image for \(breed)")
                await cellController.loadImage()
            }
        }
    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard let cellController = viewModel?.dogsCellController[indexPath.row] else {
                assertionFailure("Strange")
                continue
            }
            Task {
                await cellController.cancel()
            }
        }
    }
}

public enum DogsTableViewState {
    case reloadingAllData
    case normal
    case fetchingNextPage
}

@MainActor
public class ViewModel: ObservableObject {

    let fetchDogUseCase: FetchDogsUseCaseProtocol
    let fetchImageUseCase: any FetchDogImageUseCaseProtocol
    let cancelImageUseCase: any CancelDogImageRequestUseCaseProtocol
    var currentPage = -1
    let limitPerPage = 20
    var tableViewState: DogsTableViewState = .normal
    @Published var dogsCellController: [CellController] = []
    @Published var errorMessage: String = ""

    public init(
        fetchDogUseCase: FetchDogsUseCaseProtocol,
        fetchImageUseCase: any FetchDogImageUseCaseProtocol,
        cancelImageUseCase: any CancelDogImageRequestUseCaseProtocol
    ) {
        self.fetchDogUseCase = fetchDogUseCase
        self.fetchImageUseCase = fetchImageUseCase
        self.cancelImageUseCase = cancelImageUseCase
    }

    public func fetchNext() async throws {
        do {
            guard tableViewState == .normal else { throw DogsError.invalidState }
            currentPage += 1
            tableViewState = currentPage == 0 ? .reloadingAllData : .fetchingNextPage
            let newData = try await fetchDogUseCase.execute(limit: limitPerPage, page: currentPage)
            guard !newData.isEmpty else {
                currentPage -= 1
                return
            }
            dogsCellController += newData.map {
                CellController(
                    dog: $0,
                    fetchImage: fetchImageUseCase,
                    cancelImageRequest: cancelImageUseCase
                )
            }
            tableViewState = .normal
        } catch (let error) {
            errorMessage = "deu ruim \(error.localizedDescription)"
            tableViewState = .normal
        }
    }
}
