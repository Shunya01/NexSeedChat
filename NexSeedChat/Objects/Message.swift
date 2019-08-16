//
//  Message.swift
//  NexSeedChat
//
//  Created by 渡邉舜也 on 15/08/2019.
//  Copyright © 2019 渡邉舜也. All rights reserved.
//

import MessageKit

struct Message : MessageType{

    //送信者
    let user: ChatUser
    
    //本文
    let text: String
    
    //メッセージごとに振られた固有ID
    let messageId: String
    
    //送信日時
    let  sentDate: Date
    
    var sender: SenderType{
        return Sender(id: user.uid, displayName: user.name)
    }
    
    //(text)は上で定義したtextを指す
    var kind: MessageKind{
        return .text(text)
    }

    
    
}
