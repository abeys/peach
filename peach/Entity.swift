//
//  Entity.swift
//  peach
//
//  Created by matsumura shiori on 2019/04/29.
//  Copyright © 2019 matsumura shiori. All rights reserved.
//
import Foundation

class Task {
    // タスクID
    var task_id : Int!
    // プロジェクトID
    var project_id : Int!
    // プロジェクト名
    var project_name : String!
    // タスク名
    var name : String!
    // 開始日
    var date : String!
    // 開始時刻
    var start_time : String!
    // 終了フラグ
    var done_flg : String!
    // 経過時間
    var duration : String!
    // ラベル
    var rabel : String!
}

class Project {
    // プロジェクトID
    var project_id : Int!
    // タスクオブジェクト
    var tasks : [Task] = []
}
