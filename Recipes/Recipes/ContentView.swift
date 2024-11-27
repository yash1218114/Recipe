//
//  ContentView.swift
//  Recipes
//
//  Created by  yash on 11/27/24.
//

import SwiftUI

struct Recipe: Identifiable, Codable {
    let id: String// Use `uuid` from the JSON as the unique identifier
       let cuisine: String
       let name: String
       let photoURLLarge: String
       let photoURLSmall: String
       let sourceURL: String?
       let youtubeURL: String?

       enum CodingKeys: String, CodingKey {
           case id = "uuid"
           case cuisine
           case name
           case photoURLLarge = "photo_url_large"
           case photoURLSmall = "photo_url_small"
           case sourceURL = "source_url"
           case youtubeURL = "youtube_url"
       }}
struct RecipeResponse: Codable {
    let recipes: [Recipe]
}

class RecipeViewModel: ObservableObject  {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    let apiURL = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json" // Replace with actual API URL
    
    func fetchRecipes() {
        guard let url = URL(string: apiURL) else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Failed to load recipes: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
                    self.recipes = decodedResponse.recipes
                } catch {
                  //  self.errorMessage = "Failed to parse data: \(error.localizedDescription)"
                    print(error)
                }
            }
        }.resume()
    }
}

struct ContentView: View {
    @StateObject private var viewModel = RecipeViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(2)
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(viewModel.recipes) { recipe in
                        RecipeRow(recipe: recipe)
                    }
                    .refreshable {
                        viewModel.fetchRecipes()
                    }
                }
            }
            .navigationTitle("Recipes")
            .onAppear {
                viewModel.fetchRecipes()
            }
        }
    }
}

struct RecipeRow: View {
    let recipe: Recipe
    @State private var image: UIImage? = nil
    
    var body: some View {
        HStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onAppear {
                        fetchImage()
                    }
            }
            
            VStack(alignment: .leading) {
                Text(recipe.name)
                    .font(.headline)
                Text(recipe.cuisine)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    func fetchImage() {
        guard let url = URL(string: recipe.photoURLLarge) else { return }
        let cache = URLCache.shared
        let request = URLRequest(url: url)
        
        if let cachedResponse = cache.cachedResponse(for: request) {
            self.image = UIImage(data: cachedResponse.data)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let data = data, let response = response, let image = UIImage(data: data) else { return }
            let cachedData = CachedURLResponse(response: response, data: data)
            cache.storeCachedResponse(cachedData, for: request)
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
#Preview {
    ContentView()
}
