import Foundation
import UIKit

struct ApiResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T
}

struct LoginResponse: Codable {
    let code: Int
    let message: String
    let data: LoginData
}

struct LoginData: Codable {
    let user_id: Int
    let access_token: String
    let username: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case user_id
        case access_token
        case username
        case email
    }
}

struct ScanData: Codable {
    let brandInfo: BrandInfo?
    let detail: [FoodDetail]
    let dietaryAdvice: String?
    let foodName: String
    let nutritionalInfoPer100g: NutritionalInfo
    let rating: Int
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case brandInfo = "brand_info"
        case detail
        case dietaryAdvice = "dietary_advice"
        case foodName = "food_name"
        case nutritionalInfoPer100g = "nutritional_info_per_100g"
        case rating
        case type
    }
}

struct BrandInfo: Codable {
    let brandName: String?
    let safetyCheck: SafetyCheck?
    
    enum CodingKeys: String, CodingKey {
        case brandName = "brand_name"
        case safetyCheck = "safety_check"
    }
}

struct SafetyCheck: Codable {
    let recentIssues: Bool
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case recentIssues = "recent_issues"
        case message
    }
}

struct NutritionalInfo: Codable {
    let calories: Int
    let carbohydrates: Double
    let fat: Double
    let protein: Double
}

struct FoodDetail: Codable {
    let calories: Int
    let foodName: String
    
    enum CodingKeys: String, CodingKey {
        case calories
        case foodName = "food_name"
    }
}

struct ScanResponse: Codable {
    let message: String
    let data: ScanData
}

struct ImageUploadResponse: Codable {
    let code: Int
    let message: String
    let data: ImageData
    
    struct ImageData: Codable {
        let id: Int
        let filename: String
        let filePath: String
        let uploadTime: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case filename
            case filePath = "file_path"
            case uploadTime = "upload_time"
        }
    }
}

struct ScanResultResponse: Codable {
    let message: String
    let data: ScanData
    let imageId: Int
    
    enum CodingKeys: String, CodingKey {
        case message
        case data
        case imageId = "image_id"
    }
}

struct LogoutResponse: Codable {
    let code: Int
    let message: String
}

struct WeightRecord: Codable, Identifiable {
    let id: Int
    let userId: Int
    let date: String
    let weight: Int
    // let source: String

    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case date
        case weight
    }
}

struct RegisterRequest: Codable {
    let username: String
    let password: String
    let email: String
    let gender: String
    let birthday: String
    let height: Double
    let weight: Double
    let startWeight: Double
    let startDate: String
    let targetWeight: Double
    let targetDate: String
    let medicalConditions: String
    let medication: String
    
    enum CodingKeys: String, CodingKey {
        case username, password, email, gender, birthday, height, weight
        case startWeight = "start_weight"
        case startDate = "start_date"
        case targetWeight = "target_weight"
        case targetDate = "target_date"
        case medicalConditions = "medical_conditions"
        case medication
    }
}

struct DailyFoodRecord: Codable {
    let id: Int?
    let userId: Int
    let foodName: String
    let calories: Int
    let protein: Double
    let fat: Double
    let carbohydrates: Double
    let date: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case foodName = "food_name"
        case calories
        case protein
        case fat
        case carbohydrates
        case date
        case type
    }
}

struct AddFoodItemRequest: Codable {
    let imageId: Int
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case imageId = "image_id"
        case description
    }
}

struct AddFoodItemResponse: Codable {
    let id: Int
    let imageId: Int
    let date: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageId = "image_id"
        case date
        case message
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(statusCode: Int, message: String)
    case invalidData
    case invalidStatusCode(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Data decoding error: \(error.localizedDescription)"
        case .serverError(_, let message):
            return message
        case .invalidData:
            return "Invalid data received"
        case .invalidStatusCode(let code):
            return "Server error with status code: \(code)"
        }
    }
}

struct ErrorResponse: Codable {
    let code: Int
    let message: String
}

// struct UserProfile: Codable {
//     // Add properties for user profile
// }

class APIService {
    static let shared = APIService()
//    static let bURL = "http://127.0.0.1:8000"
    static let bURL = "http://152.32.222.208:1016"
    static let baseURL = bURL + "/api"

    private init() {}
    
    static func getRecommendedFood(userId: Int, personalized: String) async throws -> RecommendResponse {
        print("[APIService] 开始获取推荐食物，参数：userId=\(userId), personalized=\(personalized)")
        let urlString = "\(baseURL)/chat/recommend"
        print("[APIService] 请求URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("[APIService] 错误：无效的URL")
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "userid": userId,
            "personalized": personalized
        ] as [String: Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        print("[APIService] 请求参数：\(parameters)")
        
        print("[APIService] 发送API请求...")
        let (data, response) = try await URLSession.shared.data(for: request)
        print("[APIService] 收到API响应")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("[APIService] 错误：无效的响应格式")
            throw APIError.invalidResponse
        }
        print("[APIService] 响应状态码：\(httpResponse.statusCode)，状态码详情：\(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("[APIService] 响应数据：\(responseString)")
        }
        
        if httpResponse.statusCode == 200 {
            do {
                let decoded = try JSONDecoder().decode(RecommendResponse.self, from: data)
                print("[APIService] 解码成功，返回数据")
                return decoded
            } catch {
                print("[APIService] 解码响应数据失败：\(error)")
                throw APIError.decodingError(error)
            }
        } else {
            print("[APIService] 错误：服务器返回非200状态码 (\(httpResponse.statusCode))")
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Failed to get recommended food")
        }
    }
    
    
    static func login(email: String, password: String) async throws -> LoginResponse {
        var components = URLComponents(string: "\(baseURL)/users/login")
        components?.queryItems = [
            URLQueryItem(name: "username_or_email", value: email),
            URLQueryItem(name: "password", value: password)
        ]
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                return try decoder.decode(LoginResponse.self, from: data)
            }
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Login failed")
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    static func uploadImage(_ image: UIImage, userId: Int) async throws -> (Int, String) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.invalidData
        }
        
        let urlString = "\(baseURL)/images/upload?upload_id=\(userId)"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            let uploadResponse = try JSONDecoder().decode(ImageUploadResponse.self, from: data)
            return (uploadResponse.data.id, uploadResponse.data.filePath)
        } else {
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Image upload failed")
        }
    }
    
    static func scanImage(imageId: Int, userId: Int, filePath: String) async throws -> ScanResultResponse {
        guard let url = URL(string: "\(baseURL)/images/scan") else {
            throw APIError.invalidURL
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "static_path", value: filePath),
            URLQueryItem(name: "image_id", value: String(imageId))
        ]
        
        guard let finalURL = components?.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "POST"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            return try JSONDecoder().decode(ScanResultResponse.self, from: data)
        } else {
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Scan failed")
        }
    }
    
    static func getUserProfile(userId: Int) async throws -> ApiResponse<UserProfile> {
        print("Getting profile for userId: \(userId)")
        let urlString = "\(baseURL)/users/user/\(userId)"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("Received response: \(String(data: data, encoding: .utf8) ?? "")")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                return try decoder.decode(ApiResponse<UserProfile>.self, from: data)
            }
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Get profile failed")
        } catch {
            print("Error getting user profile: \(error)")
            throw APIError.networkError(error)
        }
    }
    
    static func getWeightTrend(userId: Int) async throws -> ApiResponse<[WeightRecord]> {
        print("Getting weight trend for userId: \(userId)")
        let urlString = "\(baseURL)/status/weight/\(userId)"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("Received weight trend response: \(String(data: data, encoding: .utf8) ?? "")")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                return try decoder.decode(ApiResponse<[WeightRecord]>.self, from: data)
            }
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Get weight trend failed")
        } catch {
            print("Error getting weight trend: \(error)")
            throw APIError.networkError(error)
        }
    }
    
    static func getFoodRecords(userId: String, date: String) async throws -> ApiResponse<[FoodRecord]> {
        print("Getting food records for userId: \(userId) on date: \(date)")
        let urlString = "\(baseURL)/records/get?user_id=\(userId)&date=\(date)"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("Received food records response: \(String(data: data, encoding: .utf8) ?? "")")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                return try decoder.decode(ApiResponse<[FoodRecord]>.self, from: data)
            }
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Get food records failed")
        } catch {
            print("Error getting food records: \(error)")
            throw APIError.networkError(error)
        }
    }
    
    static func logout(userId: Int) async throws -> LogoutResponse {
        guard let url = URL(string: "\(baseURL)/users/logout") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 构建JSON参数
        let parameters = ["user_id": userId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        // 打印请求信息
        print("Request URL: \(url)")
        print("Request Method: \(request.httpMethod ?? "")")
        print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let jsonString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
            print("Request Body JSON: \(jsonString)")
        }
        print("User ID: \(userId)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // 打印响应信息
        print("Response Status Code: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response Data: \(responseString)")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.invalidStatusCode(httpResponse.statusCode)
        }
        
        let logoutResponse = try JSONDecoder().decode(LogoutResponse.self, from: data)
        return logoutResponse
    }
    
    static func register(request: RegisterRequest) async throws -> ApiResponse<UserProfile> {
        var urlComponents = URLComponents(string: "\(baseURL)/users/register")!
        
        // 构建 URL 参数
        urlComponents.queryItems = [
            URLQueryItem(name: "username", value: request.username),
            URLQueryItem(name: "password", value: request.password),
            URLQueryItem(name: "email", value: request.email),
            URLQueryItem(name: "gender", value: request.gender),
            URLQueryItem(name: "birthday", value: request.birthday),
            URLQueryItem(name: "height", value: String(request.height)),
            URLQueryItem(name: "weight", value: String(request.weight)),
            URLQueryItem(name: "start_weight", value: String(request.startWeight)),
            URLQueryItem(name: "start_date", value: request.startDate),
            URLQueryItem(name: "target_weight", value: String(request.targetWeight)),
            URLQueryItem(name: "target_date", value: request.targetDate),
            URLQueryItem(name: "medical_conditions", value: request.medicalConditions),
            URLQueryItem(name: "medication", value: request.medication)
        ]
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 打印请求详情
        print("\n=== Register Request ===")
        print("URL: \(url)")
        print("Method: \(urlRequest.httpMethod ?? "Unknown")")
        print("Headers: \(urlRequest.allHTTPHeaderFields ?? [:])")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // 打印响应详情
            print("\n=== Register Response ===")
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                throw APIError.invalidResponse
            }
            
            print("Status Code: \(httpResponse.statusCode)")
            print("Headers: \(httpResponse.allHeaderFields)")
            print("Response Body:")
            if let responseString = String(data: data, encoding: .utf8) {
                print(responseString)
            }
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                return try decoder.decode(ApiResponse<UserProfile>.self, from: data)
            } else {
                // 尝试解析错误响应
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    print("Error Response: \(errorResponse)")
                    throw APIError.serverError(statusCode: httpResponse.statusCode, message: errorResponse.message)
                }
                throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Registration failed with status code \(httpResponse.statusCode)")
            }
        } catch let error as APIError {
            print("API Error: \(error.localizedDescription)")
            throw error
        } catch {
            print("General Error: \(error)")
            throw APIError.networkError(error)
        }
    }
    
    static func sendChatMessage(userId: String, message: String, history: [ChatMessage]) async throws -> [ChatMessage] {
        let url = URL(string: "\(APIService.baseURL)/chat/chat/\(userId)")!
        
        let request = ChatRequest(message: message, history: history)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Send chat message failed")
        }
        
        let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        return chatResponse.history
    }
    
    static func addFoodItem(_ request: AddFoodItemRequest) async throws -> ApiResponse<AddFoodItemResponse> {
        let urlString = "\(baseURL)/records/add"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        if let httpResponse = response as? HTTPURLResponse {
            if !(200...299).contains(httpResponse.statusCode) {
                throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Add food item failed")
            }
        }
        
        let decodedResponse = try JSONDecoder().decode(ApiResponse<AddFoodItemResponse>.self, from: data)
        print(decodedResponse)
        return decodedResponse
    }
}

extension APIService {
    static func deleteRecord(recordId: Int) async throws -> ApiResponse<DeleteResponse> {
        print("Deleting record with ID: \(recordId)")
        let urlString = "\(baseURL)/records/delete?record_id=\(recordId)"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("Received delete response: \(String(data: data, encoding: .utf8) ?? "")")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                return try decoder.decode(ApiResponse<DeleteResponse>.self, from: data)
            }
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Delete record failed")
        } catch {
            print("Error deleting record: \(error)")
            throw APIError.networkError(error)
        }
    }

    struct ChatMessage: Codable {
        let role: String
        let parts: String
    }

    struct ChatRequest: Codable {
        let message: String
        let history: [ChatMessage]
    }

    struct ChatResponse: Codable {
        let history: [ChatMessage]
    }
    
    struct DeleteResponse: Codable {
        let message: String
        let deleted_id: Int
    }
}
