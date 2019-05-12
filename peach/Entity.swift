//
//  Entity.swift
//  peach
//
//  Created by matsumura shiori on 2019/04/29.
//  Copyright © 2019 matsumura shiori. All rights reserved.
//
import UIKit

class Task : NSObject, Codable {
    // タスクID
    var task_id : Int!
    // プロジェクトID
    var project_id : Int!
    // 優先フラグ
    var priority_flg : String!
    // タスク名
    var name : String!
    // 開始日
    var date : String!
    // 開始時刻
    var start_time : String!
    // 予定時間
    var estimated_time : String!
    // 終了フラグ
    var done_flg : String!
    // 経過時間
    var duration : String!
    // ラベル
    var label : String!
}

class Project : NSObject, Codable {
    // プロジェクトID
    var project_id : Int!
    // プロジェクト名
    var project_name : String!
    // タスクオブジェクト
    var tasks : [Task] = []
    // プロジェクトカラー番号
    var color_index : Int = 0
}

class ProjectColor {
    // プロジェクトカラー
    var primary : UIColor!
    //　プロジェクトカラー（ちょっと薄めのやつ）
    var secondary: UIColor!
    // プロジェクトらカラーの背景に映える 文字色
    var textColor: UIColor!
}
