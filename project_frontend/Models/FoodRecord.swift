import Foundation

struct FoodRecordResponse: Codable {
    let code: Int
    let message: String
    let data: [FoodRecord]
}

struct FoodRecord: Codable, Identifiable {
    let record_id: Int
    let date: String
    let description: FoodDescription
    let image_id: Int
    let file_path: String
    
    var id: Int { record_id }
}

struct FoodDescription: Codable {
    let food_name: String
    let fat: Double
    let type: String
    let calories: Double
    let protein: Double
    let carbohydrates: Double
}