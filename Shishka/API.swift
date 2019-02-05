//
//  API.swift
//  Shishka
//
//  Created by Daria Tsenter on 10/18/18.
//  Copyright © 2018 DariaTsenter. All rights reserved.
//

import Foundation
public struct API{
    static let INSTAGRAM_AUTHURL = "https://api.instagram.com/oauth/authorize/"
    static let INSTAGRAM_CLIENT_ID = "5ce06e66ce66410dbd11a6c1793b90e3"
    static let INSTAGRAM_CLIENTSERCRET = "83dbf33f5eb549b0ba7a300bd4048405"
    static let INSTAGRAM_REDIRECT_URI = "http://apple.com"
    static let INSTAGRAM_ACCESS_TOKEN = "access_token"
    static let INSTAGRAM_SCOPE = "follower_list+public_content"
    static let YOUTUBE_AUTHURL = "https://accounts.google.com/o/oauth2/v2/auth"
    static let YOUTUBE_CLIENT_ID = "10127282178-jfqoqqfe9vo75dnhkhtg7ckk099dsh3u.apps.googleusercontent.com"
    static let YOUTUBE_REDIRECT_URI = "http://apple.com"
    static let YOUTUBE_SCOPE = "https://www.googleapis.com/auth/youtube.readonly"
    static let YOUTUBE_RESPONSE_TYPE = "code"
    static let YOUTUBE_POST_URL = "https://www.googleapis.com/oauth2/v4/token"
    /* add whatever scope you need https://www.instagram.com/developer/authorization/ */
}
