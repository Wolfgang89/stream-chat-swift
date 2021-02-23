//
//  Copyright © 2021 Stream.io Inc. All rights reserved.
//

import UIKit
import StreamChat
import StreamChatUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIConfig.default.channelList.channelListItemView.defaultAppearance.addRule {
            $0.titleLabel.textColor = .black
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            
            $0.timestampLabel.font = .systemFont(ofSize: 15)
            $0.timestampLabel.textColor = .gray
        }

        UIConfig.default.images.newChat = UIImage(systemName: "square.and.pencil")!
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(
            rootViewController: ContactsViewController()
        )

        return true
    }
}

extension ChatClient {
    /// The singleton instance of `ChatClient`
    static let shared: ChatClient = {
        let config = ChatClientConfig(apiKey: APIKey("q95x9hkbyd6p"))
        return ChatClient(config: config, tokenProvider: .static("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiY2lsdmlhIn0.jHi2vjKoF02P9lOog0kDVhsIrGFjuWJqZelX5capR30"))
    }()
}
