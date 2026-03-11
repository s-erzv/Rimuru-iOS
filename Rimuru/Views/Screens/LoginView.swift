import SwiftUI

struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    @State private var glowPulse: Bool = false
    @State private var cardAppeared: Bool = false
    @State private var logoAppeared: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#060C1A"), Color(hex: "#0B1428"), Color(hex: "#0A1020")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#2563EB").opacity(0.45), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: geo.size.width * 0.55
                        )
                    )
                    .frame(width: geo.size.width * 1.1, height: geo.size.width * 1.1)
                    .blur(radius: 40)
                    .offset(x: -geo.size.width * 0.35, y: -geo.size.height * 0.15)
                    .scaleEffect(glowPulse ? 1.08 : 1.0)
                    .animation(.easeInOut(duration: 4.2).repeatForever(autoreverses: true), value: glowPulse)

                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#7C3AED").opacity(0.35), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: geo.size.width * 0.45
                        )
                    )
                    .frame(width: geo.size.width * 0.9, height: geo.size.width * 0.9)
                    .blur(radius: 50)
                    .offset(x: geo.size.width * 0.4, y: geo.size.height * 0.52)
                    .scaleEffect(glowPulse ? 0.93 : 1.0)
                    .animation(.easeInOut(duration: 5.5).repeatForever(autoreverses: true), value: glowPulse)

                Circle()
                    .fill(Color(hex: "#0EA5E9").opacity(0.12))
                    .frame(width: geo.size.width * 0.6)
                    .blur(radius: 60)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.38)
                    .scaleEffect(glowPulse ? 1.12 : 1.0)
                    .animation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true), value: glowPulse)
            }
            .ignoresSafeArea()

            // ── Content ────────────────────────────────────────────────
            VStack(spacing: 0) {
                Spacer()

                // Logo + branding
                VStack(spacing: 18) {
                    ZStack {
                        // Outer glow ring
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color(hex: "#3B82F6").opacity(0.5), .clear],
                                    center: .center,
                                    startRadius: 48,
                                    endRadius: 72
                                )
                            )
                            .frame(width: 144, height: 144)
                            .blur(radius: 12)

                        // Glass ring
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.55),
                                        .white.opacity(0.1),
                                        .clear,
                                        Color(hex: "#3B82F6").opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                            .frame(width: 108, height: 108)

                        Image("rimuru")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    }
                    .scaleEffect(logoAppeared ? 1.0 : 0.7)
                    .opacity(logoAppeared ? 1.0 : 0.0)
                    .animation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.1), value: logoAppeared)

                    VStack(spacing: 6) {
                        Text("Rimuru")
                            .font(.custom("Poppins-Bold", size: 34))
                            .tracking(3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color(hex: "#93C5FD")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text("Personal Hub & Assistant")
                            .font(.custom("Poppins-Light", size: 13))
                            .foregroundColor(.white.opacity(0.4))
                            .tracking(1.2)
                    }
                    .opacity(logoAppeared ? 1.0 : 0.0)
                    .offset(y: logoAppeared ? 0 : 10)
                    .animation(.easeOut(duration: 0.6).delay(0.3), value: logoAppeared)
                }

                Spacer()

                // ── Glass action card ──────────────────────────────────
                ZStack(alignment: .top) {
                    // Multi-layer glass background
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 36, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.07),
                                            Color(hex: "#1E3A8A").opacity(0.08),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))

                    // Shimmer border
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.35),
                                    .white.opacity(0.08),
                                    Color(hex: "#3B82F6").opacity(0.25),
                                    .clear,
                                    .white.opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )

                    // Inner top shine
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.06), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )

                    VStack(spacing: 22) {
                        // Pill handle
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.15))
                            .frame(width: 36, height: 4)
                            .padding(.top, 4)

                        // Error state
                        if let error = viewModel.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red.opacity(0.7))
                                    .font(.system(size: 12))
                                Text(error)
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(.red.opacity(0.7))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                        }

                        // Google sign-in button
                        Button {
                            Task {
                                if await viewModel.signInWithGoogle() {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                        isLoggedIn = true
                                    }
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "#2563EB").opacity(0.75),
                                                Color(hex: "#1D4ED8").opacity(0.55)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        // Frosted top shine
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.2), .clear],
                                                    startPoint: .top,
                                                    endPoint: .center
                                                )
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(.white.opacity(0.25), lineWidth: 1)
                                    )
                                    .shadow(color: Color(hex: "#2563EB").opacity(0.5), radius: 20, x: 0, y: 12)
                                    .shadow(color: Color(hex: "#2563EB").opacity(0.2), radius: 4, x: 0, y: 2)

                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(1.1)
                                } else {
                                    HStack(spacing: 14) {
                                        // Google logo in mini glass pill
                                        ZStack {
                                            Circle()
                                                .fill(.white.opacity(0.15))
                                                .frame(width: 36, height: 36)
                                            Image("google_logo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                        }

                                        Text("Continue with Google")
                                            .font(.custom("Poppins-SemiBold", size: 16))
                                            .foregroundColor(.white)

                                        Spacer()

                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    .padding(.horizontal, 18)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                        }
                        .disabled(viewModel.isLoading)
                        .buttonStyle(GlassButtonStyle())

                        // Separator
                        HStack {
                            Rectangle()
                                .fill(.white.opacity(0.08))
                                .frame(height: 0.5)
                            Text("secured & private")
                                .font(.custom("Poppins-Light", size: 10))
                                .foregroundColor(.white.opacity(0.25))
                                .padding(.horizontal, 10)
                                .fixedSize()
                            Rectangle()
                                .fill(.white.opacity(0.08))
                                .frame(height: 0.5)
                        }

                        // Disclaimer
                        Text("By signing in, you grant Rimuru access to your Calendar and Workspace. Your data is never shared.")
                            .font(.custom("Poppins-Regular", size: 10))
                            .foregroundColor(.white.opacity(0.28))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                    .padding(.top, 16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 48)
                .opacity(cardAppeared ? 1.0 : 0.0)
                .offset(y: cardAppeared ? 0 : 40)
                .animation(.spring(response: 0.7, dampingFraction: 0.78).delay(0.2), value: cardAppeared)
            }
        }
        .onAppear {
            glowPulse = true
            withAnimation { logoAppeared = true }
            withAnimation { cardAppeared = true }
        }
    }
}

// ── Button press scale feedback ────────────────────────────────────────────
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
