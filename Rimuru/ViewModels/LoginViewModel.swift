import Foundation
import Observation
import Supabase
import GoogleSignIn
import CryptoKit

@Observable
class LoginViewModel {
    var isLoading = false
    var errorMessage: String?
    
    // 1. Helper buat bikin random string (Nonce)
    private func generateNonce() -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String((0..<32).map { _ in charset.randomElement()! })
    }
    
    // 2. Helper buat hashing SHA256 (Dibutuhkan Google SDK)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func signInWithGoogle() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            errorMessage = "UI Context Error"
            isLoading = false
            return false
        }
        
        // --- PROSES SECURITY HANDSHAKE ---
        let rawNonce = generateNonce() // Kunci mentah
        let hashedNonce = sha256(rawNonce) // Kunci yang udah di-hash buat Google
        
        do {
            // 3. Google Sign-In dengan menyertakan Hashed Nonce
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: rootVC,
                hint: nil,
                additionalScopes: ["https://www.googleapis.com/auth/calendar.events"],
                nonce: hashedNonce // <--- TITIP KUNCI KE GOOGLE
            )
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "ID Token missing"])
            }
            
            let accessToken = result.user.accessToken.tokenString
            
            // 4. Masuk ke Supabase dengan menyertakan RAW Nonce
            // Supabase bakal nge-hash rawNonce ini dan nyocokin sama yang ada di dalam idToken
            try await SupabaseService.shared.client.auth.signInWithIdToken(
                credentials: .init(
                    provider: .google,
                    idToken: idToken,
                    accessToken: accessToken,
                    nonce: rawNonce // <--- KASIH KUNCI MENTAH KE SUPABASE
                )
            )
            
            isLoading = false
            return true
            
        } catch {
            isLoading = false
            self.errorMessage = error.localizedDescription
            print("Login Error: \(error)")
            return false
        }
    }
}
