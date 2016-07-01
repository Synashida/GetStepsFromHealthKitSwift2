//
//  HealthKitLib.swift
//  HealthKitSwift2
//
//  Created by ashida on 2016/06/29.
//  Copyright © 2016年 v-force.co.jp. All rights reserved.
//

import Foundation
import HealthKit

/// HealthKitから歩数を取得するサンプルプログラム
class HealthKit {
    /// HealthKitストレージにアクセスする
    var storage:HKHealthStore = HKHealthStore()
    
    /**
     HealthKitへのアクセス許可を確認
     
     - returns:
     */
    init() {
        checkAuthorization()
    }
    
    /**
     HealthKitへのアクセス許可確認
     
     - returns: true = 許可 / false = 不許可
     */
    func checkAuthorization() -> Bool {
        var isEnabled = true
        
        // 利用しているデバイスでHealthKitが利用可能か調べる
        if HKHealthStore.isHealthDataAvailable()
        {
            // 歩数の取得をリクエスト
            let steps = NSSet(object: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!)
            
            // 許可されているかどうかを確認
            storage.requestAuthorizationToShareTypes(nil, readTypes: steps as? Set<HKObjectType>) { (success, error) -> Void in
                isEnabled = success
            }
        }
        else
        {
            isEnabled = false
        }
        
        return isEnabled
    }
    
    /**
     指定日１日分の歩数をHealthKitから取得する
     
     - parameter findDate:   検索対象日
     - parameter completion: データ取得後に呼び出されるデリゲート関数
     */
    func recentStepsOfDay(findDate: NSDate, completion: ((steps:Int, error:NSError!) -> Void)!) {
        // HKSampleから歩数の取得をリクエスト
        let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        // 対象日の24時間分の歩数を取得する
        let predicate = HKQuery.predicateForSamplesWithStartDate(findDate, endDate: NSDate(timeIntervalSince1970: findDate.timeIntervalSince1970 + 86400), options: .None)
        
        // 指定期間内のデータを取得する
        let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
            var steps: Int = 0
            
            // 指定期間で取得できた歩数の合計を計算
            if results?.count > 0
            {
                for result in results as! [HKQuantitySample]
                {
                    steps += Int(result.quantity.doubleValueForUnit(HKUnit.countUnit()))
                }
            }
            // 合計歩数をコールバック関数へ返す
            completion(steps: steps, error: error)
        }
        
        storage.executeQuery(query)
    }
}