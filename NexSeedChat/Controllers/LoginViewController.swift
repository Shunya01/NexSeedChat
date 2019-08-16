//
//  LoginViewController.swift
//  NexSeedChat
//
//  Created by 渡邉舜也 on 15/08/2019.
//  Copyright © 2019 渡邉舜也. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //おまじない
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
    }

}

extension LoginViewController: GIDSignInDelegate,GIDSignInUIDelegate{
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        //エラーの確認
        //エラーがnilでない場合）(エラーがある場合)
        if let error = error {
            print("Google Sign In でエラーが出ました")
            print(error.localizedDescription)
            //処理の中断
            return
        }
        
        //ユーザー情報の取得
        let authentication = user.authentication
        
        //Googleのトークンの取得
        let credential = GoogleAuthProvider.credential(withIDToken: authentication!.idToken, accessToken: authentication!.accessToken)
        
        //Googleでログインする。Firebaseにログイン情報を書き込む
        Auth.auth().signIn(with: credential) {(AuthDataResult,error) in
            
            if let error = error {
                print("失敗")
                print(error.localizedDescription)
            }else{
                print("成功")
                //selfはLoginViewControllerを指す。Authではないと教える
                self.performSegue(withIdentifier: "toChat", sender: nil)
            }
        }
        
    }
}
