//
//  AlamofireTest.swift
//  Pokedex
//
//  Created by Johnfil Initan on 6/29/23.
//

import UIKit
import Alamofire

struct Post: Decodable {
    let id: Int
    let title: String
    let body: String
}

class AlamofireTest {
    static func testGetRequest() {
        let url = "https://jsonplaceholder.typicode.com/posts/1"
        
        AF.request(url).responseDecodable(of: Post.self) { response in
            switch response.result {
            case .success(let post):
                print("Request was successful. Response: \(post)")
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
}

