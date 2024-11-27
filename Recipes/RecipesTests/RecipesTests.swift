//
//  RecipesTests.swift
//  RecipesTests
//
//  Created by yash on 11/27/24.
//

import Testing
@testable import Recipes

import XCTest
@testable import Recipes

class RecipeAppTests: XCTestCase {
    func testRecipeDecoding() throws {
        let json = """
        {
            "recipes": [
                {
                    "cuisine": "Malaysian",
                    "name": "Apam Balik",
                    "photo_url_large": "https://example.com/large.jpg",
                    "photo_url_small": "https://example.com/small.jpg",
                    "source_url": "https://example.com/source",
                    "uuid": "12345",
                    "youtube_url": "https://youtube.com/video"
                }
            ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let response = try decoder.decode(RecipeResponse.self, from: json)

        XCTAssertEqual(response.recipes.count, 1)
        XCTAssertEqual(response.recipes[0].name, "Apam Balik")
        XCTAssertEqual(response.recipes[0].cuisine, "Malaysian")
    }

    func testFetchRecipes() throws {
        // Mock ViewModel Testing
        let viewModel = RecipeViewModel()
        let expectation = self.expectation(description: "Fetching recipes")

        viewModel.fetchRecipes()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertFalse(viewModel.recipes.isEmpty)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
}
