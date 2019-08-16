//
//  ChatViewController.swift
//  NexSeedChat
//
//  Created by 渡邉舜也 on 15/08/2019.
//  Copyright © 2019 渡邉舜也. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {

    //全メッセージを保持する変数
    var messages: [Message] = []{
        //変数の中身が書き換わったとき
        didSet{
            //画面を更新する
            messagesCollectionView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self
        
        //Firebaseへ接続
        let db = Firestore.firestore()
        
        //"messages"の部屋を監視し変更がされたら
        db.collection("messages").order(by: "sentDate", descending: false).addSnapshotListener { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else{
                    //roomの中に何もない場合処理を中断
                    return
            }
            
            //上とは別のmessagesと使う
            var messages:[Message] = []
            
            //documentの中身を全て取得してfor文で回す
            for document in documents{
                
                let uid = document.get("uid") as! String
                let name = document.get("name") as! String
                let photoUrl = document.get("photoUrl") as! String
                let text = document.get("text") as! String
                let sentDate = document.get("sentDate") as! Timestamp
                
                //該当メッセージの送信者の作成
                let chatUser = ChatUser(uid: uid, name: name, photoUrl: photoUrl)
                
                //該当のメッセージを作成
                let message = Message(user: chatUser, text: text, messageId: document.documentID, sentDate: sentDate.dateValue())
                
                //作成したメッセージを配列に入れる
                messages.append(message)
            }
            
            self.messages = messages
        }
        
    }

}

extension ChatViewController:MessagesDataSource{
    
    //送信者（ログインユーザー）
    func currentSender() -> SenderType {
        //現在ログインしている人を取得
        let user = Auth.auth().currentUser!
        
        //ログイン中のユーザーのUID、displayNameを使って、MessageKit用に送信者の情報を作成
        return Sender(id: user.uid, displayName: user.displayName!)
    }
    
    //画面に表示するメッセージ
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    //画面に表示するメッセージの件数
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}

//画面のデザインを変えることができる
extension ChatViewController: MessagesDisplayDelegate{
    
    //メッセージの矢印の形を変える
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let corner: MessageStyle.TailCorner!
        
        if isFromCurrentSender(message: message) {
            //メッセージの送信者が自分の場合
            corner = .bottomRight
        }else{
            //メッセージの送信者が自分以外の場合
            corner = .bottomLeft
        }
        
        return .bubbleTail(corner, .curved)
    }
    
    //メッセージの背景色を設定
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        if isFromCurrentSender(message: message){
            return UIColor(red: 100/255, green: 63/255, blue: 222/255, alpha: 1)
        }else{
            return UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        //全メッセージのうち対象の一つを取得
        let message = messages[indexPath.section]
        
        //取得したメッセージの送信者を取得
        let user = message.user
        
        //photoUrlは文字列型なのでURL型に変換
        let url = URL(string: user.photoUrl)
        
        do{
            //URLを元に画像のデータを取得
            let data = try Data(contentsOf: url!)
            //取得したデータを元にImageViewを作成
            let image = UIImage(data: data)
            //ImageViewと名前を元にアバターアイコン作成
            let avatar = Avatar(image: image, initials: user.name)
            
            avatarView.set(avatar: avatar)
            return
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
}

//画面のデザインを書き換える
extension ChatViewController: MessageCellDelegate{
    
}

extension ChatViewController: MessagesLayoutDelegate{
    
}

//送信バーに関する設定
extension ChatViewController: InputBarAccessoryViewDelegate{
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        //ログインユーザーの取得
        let user = Auth.auth().currentUser!
        
        //Firestoreに接続
        let db = Firestore.firestore()

        //Firestoreにメッセージや送信者の情報を登録
        db.collection("messages").addDocument(data: [
            "uid" : user.uid,
            "name" : user.displayName as Any,
            "photoUrl" : user.photoURL?.absoluteString as Any,
            "text" : text,
            //送信ボタンを押した時間を取得する。
            "sentDate" : Date()
            ])
        
        //メッセージの入力欄を空にする
        inputBar.inputTextView.text = ""
        
    }
}
