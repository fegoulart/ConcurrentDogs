//
//  DogsRepositoryTests.swift
//  
//
//  Created by Fernando Goulart on 2/28/24.
//

import XCTest
import NetworkingImp
import NetworkingInterface
import Alamofire

final class DogsRepositoryTests: XCTestCase {

    func testExample() async throws {
        let sut = makeSUT(
            dogs: [
                DogDTO(
                    id: 1,
                    name: "Beagle",
                    image: DogImageDTO(
                        id: "lalala",
                        url: "https://hahaha.com"
                    )
                ),
                DogDTO(
                    id: 2,
                    name: "Doberman",
                    image: DogImageDTO(
                        id: "lelele",
                        url: "https://hehehehe.com"
                        )
                )

        ], 
            image: Data()
        )
        do {
            let dogs: [Dog] = try await sut.fetchDogs(limit: 20, page: 0)
            XCTAssertEqual(dogs, [Dog(breed: "Beagle", image: "https://hahaha.com"), Dog(breed: "Doberman", image: "https://hehehehe.com")])
        } catch {
            XCTFail("should not fail")
        }

    }

    private func makeSUT(
        dogs: [DogDTO],
        image: Data,
        file: StaticString = #file,
        line: UInt = #line
    ) -> DogsRepository {
        let decodableTestTask = TestTask<[DogDTO]>(mockResult: dogs)
        let decodableTask = NetworkRequestTask<[DogDTO]>(dataTask: decodableTestTask)
        let dataTestTask = TestTask<Data>(mockResult: Data.make(withColor: .orange))
        let dataTask = NetworkRequestTask(dataTask: dataTestTask)
        let factory = TestTaskFactory(decodableTask: decodableTask, dataTask: dataTask)
        let dogsRepository = DogsRepository(taskFactory: factory)
        return dogsRepository
    }
}

final class TestTask<Value>: DogTask {
    let mockResult: Value
    var cancelCount = 0

    var response: Alamofire.DataResponse<Value, Alamofire.AFError> {
        get async {
            return DataResponse.init(
                request: nil,
                response: nil,
                data: nil,
                metrics: nil,
                serializationDuration: .zero,
                result: .success(mockResult))
        }
    }

    typealias T = Value

    init(mockResult: Value) {
        self.mockResult = mockResult
    }

    func cancel() {
        cancelCount += 1
    }

}

final class TestTaskFactory: DataTaskAbstractFactory {
    typealias T = [DogDTO]
    
    private var decodableTask: NetworkRequestTask<[DogDTO]>
    private var dataTask: NetworkRequestTask<Data>

    init(decodableTask: NetworkRequestTask<[DogDTO]>, dataTask: NetworkRequestTask<Data>) {
        self.decodableTask = decodableTask
        self.dataTask = dataTask
    }

    func makeDataTask(url: String, limit: Int, page: Int) -> NetworkRequestTask<T> {
        return decodableTask as NetworkRequestTask<T>
    }
    
    func makeImageDataTask(url: URL) -> NetworkRequestTask<Data> {
        return dataTask
    }
}
