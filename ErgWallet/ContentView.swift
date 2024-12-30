import SwiftUI

struct ContentView: View {
    @State private var balance: String = "Loading..."
    @State private var wallet: String = "Loading..."
    @State private var seed: String = "Loading..."

    let notificationCenter = UNUserNotificationCenter.current()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(getBalance(address: "9grWzUzkzQaqizwa2Jr2gkLq9H6NxHJ6THzoKfu1L1sKs4tvYyn").balanceInNano.formatted())

            Text(balance)
                .padding()
            Button("fetchUnspentBoxes") {
                fetchBalance()
            }.buttonStyle(.borderedProminent)
            
            Text(wallet)
                .padding()
            Button("create wallet") {
                createWallet()
            }.buttonStyle(.borderedProminent)

            Text(seed)
                .padding()
            Button("save seed") {
                saveSeed()
            }.buttonStyle(.bordered)
            Button("get seed") {
                getSeed()
            }.buttonStyle(.bordered)

            Button("connect phoenix") {
                connect()
            }.buttonStyle(.borderedProminent)
        }
        .onAppear {
            Task {
                await authorizeNotifications()
            }
        }
        .padding()
    }

    func authorizeNotifications() async {
        do {
            try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("Request authorization error")
        }
    }

    func fetchBalance() {
        NodeClient.shared.fetchUnspentBoxes(address: "9grWzUzkzQaqizwa2Jr2gkLq9H6NxHJ6THzoKfu1L1sKs4tvYyn") { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let boxes):
                        let nano = NodeClient.shared.sumBoxValues(boxes: boxes)
                        let erg = NodeClient.shared.toNano(nano: nano)
                        self.balance = String(erg) + " ERG"
                    case .failure(let error):
                        self.balance =  "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    func createWallet() {
        self.wallet = getWallet().mnemonicPhrase
    }

    func saveSeed() {
        do {
            try SecureStorage.shared.saveString(self.wallet, forKey: "seed")
        } catch {
            print("Error saving to keychain: \(error)")
        }
    }

    func getSeed() {
        do {
            self.seed = try SecureStorage.shared.loadString(forKey: "seed")
        } catch {
            print("Error loading from keychain: \(error)")
        }
    }

    func connect() {
        SocketChat.shared.connect()
    }
}

#Preview {
    ContentView()
}
