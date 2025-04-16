import SwiftUI

struct MainTabView: View {
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingChatView = false
    
    var body: some View {
        ZStack {
            TabView {
                // 首页/日记页面
                DiaryView()
                    .tabItem {
                        Image(systemName: "house.fill")food
                        Text("Home")
                }
                
                // 扫描/拍照记录页面
                FoodRecognitionView()
                    .tabItem {
                        Image(systemName: "barcode.viewfinder")
                        Text("Scan")
                }
                
                // 个性化推荐页面
                RecommendFoodView()
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text("Recommend")
                }
                
                // 统计/图表页面
                StatsView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Stats")
                    }
                
                // 更多/设置页面
                MoreView()
                    .environmentObject(userProfileViewModel)
                    .environmentObject(authViewModel)
                    .tabItem {
                        Image(systemName: "ellipsis")
                        Text("More")
                    }
            }
            .environmentObject(userProfileViewModel)
            .environmentObject(authViewModel)
            .accentColor(AppTheme.primary)
            
            // Floating Chat Button
            if !showingChatView {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingChatView = true
                        }) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(AppTheme.primary)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 140)
                    }
                }
            }
        }
        .sheet(isPresented: $showingChatView) {
            ChatView()
        }
    }
}

struct AddFoodView: View {
    var body: some View {
        Text("Add Food View")
    }
}

struct StatisticsView: View {
    var body: some View {
        Text("Statistics View")
    }
}




#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}

