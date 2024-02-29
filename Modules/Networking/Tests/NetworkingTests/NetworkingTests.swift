import XCTest
import NetworkingImp
import NetworkingInterface
import Alamofire

final class NetworkingTests: XCTestCase {
    
    func testUseCase() async throws {
        let interceptor = Interceptor(adapter: MyAdapter(), retrier: MyRetrier())
        let decodableNetworkService = AFDecodableNetworkService<[DogDTO]>(interceptor: interceptor)
        let repository: any DogsRepositoryProtocol = DogsRepository(httpClient: decodableNetworkService)
        let useCase: FetchDogsUseCase = FetchDogsUseCase(repository: repository)
        let dogs: [Dog] = try await useCase.execute(limit: 20, page: 0)
        XCTAssert(dogs.count == 20)
    }

    func testImage() async throws {
        let interceptor = Interceptor(adapter: MyAdapter(), retrier: MyRetrier())
        let dataNetworkService = AFDataNetworkService(interceptor: interceptor)
        let repository: any DogsRepositoryProtocol = DogsRepository(httpClient: dataNetworkService)
        let useCase: FetchImageUseCase = FetchImageUseCase(repository: repository)
        let image: UIImage = try await useCase.execute(url: URL(string: "https://cdn2.thedogapi.com/images/Hyq1ge9VQ.jpg")!)
        XCTAssert(image.size.width == 800)
        XCTAssert(image.size.height == 533)
    }
}
