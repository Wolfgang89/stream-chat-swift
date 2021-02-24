//
//  Copyright © 2021 Stream.io Inc. All rights reserved.
//

import UIKit
import StreamChat
import StreamChatUI

final class ContactsViewController: ChatChannelListVC {
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let channelListController = ChatClient
            .shared
            .channelListController(
                query: ChannelListQuery(
                    filter: .containMembers(
                        userIds: [ChatClient.shared.currentUserId!]
                    )
                )
            )
        self.controller = channelListController
    }
    
    override func setUpLayout() {
        super.setUpLayout()
        
        title = "Messages"
    }
    
    override func setUpAppearance() {
        super.setUpAppearance()
        
        title = "Messages"
        
        userAvatarView.isHidden = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        
        createNewChannelButton
            .setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        
        view.directionalLayoutMargins.leading = 24
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    @objc
    private func editButtonTapped() {
    }
}
