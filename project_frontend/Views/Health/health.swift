import SwiftUI
import HealthKit

class HealthManager: ObservableObject {
    private var healthStore: HKHealthStore?
    @Published var weightRecords: [(date: Date, weight: Double)] = []
    @Published var caloriesRecords: [(date: Date, calories: Double)] = []
    @Published var exerciseRecords: [(date: Date, minutes: Double)] = []
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        print("[HealthKit] 开始请求健康数据权限")
        guard HKHealthStore.isHealthDataAvailable() else {
            print("[HealthKit] 设备不支持 HealthKit")
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        guard let healthStore = healthStore else {
            print("[HealthKit] HealthStore 初始化失败")
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        guard let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
              let exerciseTimeType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) else {
            print("[HealthKit] 无法获取所需的数据类型")
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        // 检查是否已经获得权限
        let status = healthStore.authorizationStatus(for: weightType)
        print("[HealthKit] 当前权限状态: \(status.rawValue)")
        if status == .sharingAuthorized {
            print("[HealthKit] 已获得权限访问")
            DispatchQueue.main.async {
                completion(true)
            }
            return
        }
        
        // 请求权限
        print("[HealthKit] 开始请求用户授权")
        healthStore.requestAuthorization(toShare: [], read: [weightType, activeEnergyType, exerciseTimeType]) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[HealthKit] 授权错误: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                print("[HealthKit] 用户授权结果: \(success ? "成功" : "失败")")
                completion(success)
            }
        }
    }
    
    func fetchWeightData(completion: @escaping ([(Date, Double)]) -> Void) {
        print("[HealthKit] 开始获取体重数据")
        guard let healthStore = healthStore,
              let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            print("[HealthKit] 无法访问 HealthStore 或体重数据类型")
            DispatchQueue.main.async {
                completion([])
            }
            return
        }
        
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: weightType,
                                 predicate: predicate,
                                 limit: HKObjectQueryNoLimit,
                                 sortDescriptors: [sortDescriptor]) { _, samples, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("[HealthKit] 查询错误: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }
                
                guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
                    print("[HealthKit] 未找到体重数据记录")
                    completion([])
                    return
                }
                
                print("[HealthKit] 成功获取 \(samples.count) 条体重记录")

                
                let weightData = samples.compactMap { sample -> (Date, Double)? in
                    let weight = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                    guard weight > 0 && weight < 500 else { return nil } // 添加合理的体重范围检查
                    return (sample.startDate, weight)
                }
                
                completion(weightData)
            }
        }
        
        healthStore.execute(query)
    }
    
    func mergeWeightData(healthKitData: [(Date, Double)], backendData: [WeightRecord]) -> [(Date, Double)] {
        print("\n[数据合并] 开始合并 HealthKit 和后台数据")
        print("[数据合并] HealthKit 数据数量: \(healthKitData.count)")
        print("[数据合并] 后台数据数量: \(backendData.count)")
        
        var mergedData: [(Date, Double)] = []
        
        // 添加后台数据，并进行数据验证
        let validBackendData = backendData.compactMap { record -> (Date, Double)? in
            guard let date = dateFromString(record.date),
                  record.weight > 0 && record.weight < 500 else { return nil }
            return (date, Double(record.weight))
        }
        print("[数据合并] 有效后台数据数量: \(validBackendData.count)")

        
        // 添加有效的 HealthKit 数据
        let validHealthKitData = healthKitData.filter { $0.1 > 0 && $0.1 < 500 }
        print("[数据合并] 有效 HealthKit 数据数量: \(validHealthKitData.count)")
        
        // 合并数据并去重
        let allData = validBackendData + validHealthKitData
        let uniqueData = Dictionary(grouping: allData) { $0.0 }
            .mapValues { values in
                values.reduce(0.0) { $0 + $1.1 } / Double(values.count)
            }
            .map { ($0.key, $0.value) }
        
        // 按日期排序
        mergedData = uniqueData.sorted { $0.0 < $1.0 }
        print("[数据合并] 最终合并后的数据数量: \(mergedData.count)\n")
        
        // 打印合并后的数据示例
        if !mergedData.isEmpty {
            print("[数据合并] 最新的体重记录:")
            if let latest = mergedData.last {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                print("日期: \(dateFormatter.string(from: latest.0)), 体重: \(String(format: "%.1f", latest.1)) kg")
            }
        }
        
        return mergedData
    }
    
    func fetchCaloriesData(completion: @escaping ([(Date, Double)]) -> Void) {
        print("[HealthKit] 开始获取卡路里消耗数据")
        guard let healthStore = healthStore,
              let caloriesType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("[HealthKit] 无法访问 HealthStore 或数据类型")
            DispatchQueue.main.async {
                completion([])
            }
            return
        }
        
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: caloriesType,
                                 predicate: predicate,
                                 limit: HKObjectQueryNoLimit,
                                 sortDescriptors: [sortDescriptor]) { _, samples, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("[HealthKit] 查询错误: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }
                
                guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
                    print("[HealthKit] 未找到卡路里消耗数据记录")
                    completion([])
                    return
                }
                
                print("[HealthKit] 成功获取 \(samples.count) 条卡路里消耗记录")
                
                let caloriesData = samples.map { sample -> (Date, Double) in
                    let calories = sample.quantity.doubleValue(for: .kilocalorie())
                    return (sample.startDate, calories)
                }
                
                // 合并同一天的卡路里消耗
                let calendar = Calendar.current
                let groupedData = Dictionary(grouping: caloriesData) { calendar.startOfDay(for: $0.0) }
                let dailyCalories = groupedData.map { (date, records) -> (Date, Double) in
                    let totalCalories = records.reduce(0) { $0 + $1.1 }
                    return (date, totalCalories)
                }
                
                completion(dailyCalories)
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchExerciseData(completion: @escaping ([(Date, Double)]) -> Void) {
        print("[HealthKit] 开始获取运动时间数据")
        guard let healthStore = healthStore,
              let exerciseType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) else {
            print("[HealthKit] 无法访问 HealthStore 或运动时间数据类型")
            DispatchQueue.main.async {
                completion([])
            }
            return
        }
        
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: exerciseType,
                                 predicate: predicate,
                                 limit: HKObjectQueryNoLimit,
                                 sortDescriptors: [sortDescriptor]) { _, samples, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("[HealthKit] 查询错误: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }
                
                guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
                    print("[HealthKit] 未找到运动时间数据记录")
                    completion([])
                    return
                }
                
                print("[HealthKit] 成功获取 \(samples.count) 条运动时间记录")
                
                let exerciseData = samples.map { sample -> (Date, Double) in
                    let minutes = sample.quantity.doubleValue(for: .minute())
                    return (sample.startDate, minutes)
                }
                
                // 按天分组并合并数据
                let calendar = Calendar.current
                let groupedData = Dictionary(grouping: exerciseData) { calendar.startOfDay(for: $0.0) }
                let dailyExercise = groupedData.map { (date, records) -> (Date, Double) in
                    let totalMinutes = records.reduce(0.0) { $0 + $1.1 }
                    return (date, totalMinutes)
                }.sorted { $0.0 < $1.0 }
                
                print("[HealthKit] 合并后的运动时间数据: \(dailyExercise.count) 天")
                if let latest = dailyExercise.last {
                    print("[HealthKit] 今日运动时间: \(Int(latest.1)) 分钟")
                }
                
                completion(dailyExercise)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}