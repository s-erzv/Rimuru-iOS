import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0F182B").ignoresSafeArea()
                
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 400)
                    .blur(radius: 100)
                    .offset(x: -150, y: -200)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CURRENT BALANCE")
                                .font(.custom("Poppins-Medium", size: 12))
                                .foregroundColor(.white.opacity(0.5))
                                .tracking(1.5)
                            
                            Text(formatRupiah(viewModel.balance))
                                .font(.custom("Poppins-Bold", size: 36))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                Label("+\(formatRupiah(viewModel.totalIncome))", systemImage: "arrow.up.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.green.opacity(0.8))
                                Label("-\(formatRupiah(viewModel.totalExpense))", systemImage: "arrow.down.left")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.red.opacity(0.8))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)

                        DashboardSection(title: "TODAY'S SCHEDULE") {
                            if viewModel.schedules.isEmpty {
                                EmptyState(text: "No events for today.")
                            } else {
                                ForEach(viewModel.schedules) { event in
                                    ScheduleCard(event: event)
                                }
                            }
                        }

                        DashboardSection(title: "PENDING TASKS") {
                            if viewModel.tasks.isEmpty {
                                EmptyState(text: "All caught up!")
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(viewModel.tasks.prefix(3)) { task in
                                        TaskRow(task: task)
                                    }
                                }
                            }
                        }

                        // --- UPCOMING EVENTS ---
                        DashboardSection(title: "UPCOMING") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.upcomingSchedules) { event in
                                        UpcomingCard(event: event)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.horizontal, -16)
                        }
                    }
                    .padding(.bottom, 100)
                }
                .refreshable {
                    await viewModel.fetchDashboardData()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                            // Sisi Kiri: Tombol Chat
                            ToolbarItem(placement: .navigationBarLeading) {
                                NavigationLink(destination: ChatView()) {
                                    ZStack {
                                        Circle()
                                            .fill(.white.opacity(0.1))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "bubble.left.and.bubble.right.fill")
                                            .symbolRenderingMode(.hierarchical)
                                            .foregroundColor(.blue)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                }
                            }

                            // Sisi Kanan: Profile & Logout
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: { isLoggedIn = false }) {
                                    ZStack {
                                        Circle()
                                            .fill(.white.opacity(0.1))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "person.circle.fill")
                                            .symbolRenderingMode(.hierarchical)
                                            .foregroundColor(.white)
                                            .font(.title3)
                                    }
                                }
                            }
                        }
                        .task { await viewModel.fetchDashboardData() }
        }
    }
    
    func formatRupiah(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "Rp 0"
    }
}

// --- SUB COMPONENTS ---

struct ScheduleCard: View {
    let event: GoogleCalendarEvent
    var body: some View {
        HStack(spacing: 16) {
            VStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                Rectangle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.summary)
                    .font(.custom("Poppins-SemiBold", size: 15))
                    .foregroundColor(.white)
                Text(event.start.dateTime ?? "All Day")
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
    }
}

struct EmptyState: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.custom("Poppins-Light", size: 13))
            .foregroundColor(.white.opacity(0.3))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), style: StrokeStyle(lineWidth: 1, dash: [5])))
    }
}
// --- REUSABLE COMPONENTS ---

struct DashboardSection<Content: View>: View {
    let title: String
    let content: Content
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.custom("Poppins-Bold", size: 14))
                .foregroundColor(.white.opacity(0.4))
                .padding(.horizontal)
            content
                .padding(.horizontal)
        }
    }
}

struct TaskRow: View {
    let task: RimuruTask
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: task.status == "completed" ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.status == "completed" ? .green : .white.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.custom("Poppins-Medium", size: 14))
                    .foregroundColor(.white)
                if let due = task.due {
                    Text("Deadline: \(due)")
                        .font(.system(size: 11))
                        .foregroundColor(.red.opacity(0.6))
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

struct UpcomingCard: View {
    let event: GoogleCalendarEvent
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(event.summary)
                .font(.custom("Poppins-SemiBold", size: 14))
                .foregroundColor(.white)
                .lineLimit(2)
            
            Text(event.start.dateTime ?? "TBA")
                .font(.system(size: 11))
                .foregroundColor(.blue.opacity(0.7))
        }
        .frame(width: 150, height: 100, alignment: .topLeading)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}
