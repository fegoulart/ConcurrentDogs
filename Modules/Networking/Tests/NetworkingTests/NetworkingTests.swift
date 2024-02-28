import XCTest
import NetworkingImp
import NetworkingInterface
import Alamofire

final class NetworkingTests: XCTestCase {
    func testExample() async throws {
        let factory: NetworkRequest = NetworkRequest()
        let task1: NetworkRequestTask<[DogDTO]> = factory.makeDataTask()
        let response: DataResponse<[DogDTO], AFError> = await task1.getResponse()
        print(response)
        XCTAssert(response.data != nil)
    }

    func testUseCase() async throws {
        let factory: NetworkRequest = NetworkRequest()
        let repository: any DogsRepositoryProtocol = DogsRepository(taskFactory: factory)
        let useCase: FetchDogsUseCase = FetchDogsUseCase(repository: repository)
        let dogs: [Dog] = try await useCase.execute(limit: 20, page: 0)
        XCTAssert(dogs.count == 20)
    }

    func testImage() async throws {
        let factory: NetworkRequest = NetworkRequest()
        let repository: any DogsRepositoryProtocol = DogsRepository(taskFactory: factory)
        let useCase: FetchImageUseCase = FetchImageUseCase(repository: repository)
        let image: UIImage = try await useCase.execute(url: URL(string: "https://cdn2.thedogapi.com/images/Hyq1ge9VQ.jpg")!)
        XCTAssert(image.size.width == 800)
        XCTAssert(image.size.height == 533)
    }
}
