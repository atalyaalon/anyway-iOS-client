//
//  MainViewOutput.swift
//  Anyway
//
//  Created by Yigal Omer on 28/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit


protocol MainViewOutput {


    func handleFilterTap()
    
    func handleHelpTap()

    func getAnnotations(_ edges: Edges, anotations: (( [NewMarker]?)->Void )? )

    func closeImagePicker()

//    func obtainChatId() -> Id<Chat>?
//
//    func obtainParticipantId() -> Id<Adult>?
//
//    func setChatTitle(_ title: String)
//
//    func setChatSubtitle(_ subtitle: String)
//
//    func setupView(messageList: [Message])
//
//    func appendView(withPreviousMessagesList: [Message])

}

