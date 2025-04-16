import SwiftUI

struct AppTheme {
    // MARK: - 主要颜色
    static let primary = Color(hex: "FF9999")  // 主要强调色
    
    // MARK: - 背景颜色
    static let background = Color(uiColor: .systemBackground)  // 自动适应深色模式
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    
    // MARK: - 文字颜色
    static let textPrimary = Color(uiColor: .label)
    static let textSecondary = Color(uiColor: .secondaryLabel)
    
    // MARK: - 边框颜色
    static let border = Color(uiColor: .separator)
    
    // MARK: - 状态颜色
    static let success = Color.green
    static let warning = Color.yellow
    static let error = Color.red
    
    // MARK: - 输入框相关
    static let inputBackground = Color(uiColor: .secondarySystemBackground)
    static let inputBorder = Color(uiColor: .separator)
    static let inputText = Color(uiColor: .label)
    static let inputPlaceholder = Color(uiColor: .placeholderText)
    
    // MARK: - 按钮相关
    static let buttonPrimary = Color(hex: "FF9999")
    static let buttonSecondary = Color(uiColor: .secondarySystemBackground)
    static let buttonText = Color.white
    static let buttonTextSecondary = Color(uiColor: .label)
}

// 用于支持十六进制颜色代码的扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Font scaling modifier
struct ScaledFont: ViewModifier {
    @AppStorage("fontSize") private var fontSize: Double = 1.0
    let baseSize: Double
    
    func body(content: Content) -> some View {
        content.font(.system(size: baseSize * fontSize))
    }
}

extension View {
    func scaledFont(baseSize: Double) -> some View {
        modifier(ScaledFont(baseSize: baseSize))
    }
}