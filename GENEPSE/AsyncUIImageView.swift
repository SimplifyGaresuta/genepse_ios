//
//  AsyncUIImageView.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/02.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit

class AsyncUIImageView: UIImageView {
    let CACHE_SEC : TimeInterval = 5 * 60; //5分キャッシュ
    
    //画像を非同期で読み込む
    func loadImage(urlString: String){
        let req = URLRequest(url: NSURL(string:urlString)! as URL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: CACHE_SEC)
        let conf =  URLSessionConfiguration.default
        let session = URLSession(configuration: conf, delegate: nil, delegateQueue: OperationQueue.main)
        
        session.dataTask(with: req, completionHandler:
            { (data, resp, err) in
                if((err) == nil){ //Success
                    let image = UIImage(data:data!)
                    self.image = image;
                    
                }else{ //Error
                    print("AsyncImageView:Error \(String(describing: err?.localizedDescription))");
                }
        }).resume();
    }
    
    func loadImageWithHandler(urlString: String, handler: @escaping (Data?, URLResponse?, Error?) -> Void ) {
        let req = URLRequest(url: NSURL(string:urlString)! as URL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: CACHE_SEC)
        let conf =  URLSessionConfiguration.default
        let session = URLSession(configuration: conf, delegate: nil, delegateQueue: OperationQueue.main)
        
        session.dataTask(with: req, completionHandler: handler).resume()
    }
}
