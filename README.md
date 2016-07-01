# GetStepsFromHealthKitSwift2

Swift2でHealthKitから指定日１日分の歩数を取得サンプルです。

```ViewController.swift
    @IBAction func getSteps(sender: UIButton) {
        healthKit.recentStepsOfDay(dtpDate.date, completion: {steps, error in
            // Autolayoutを使っているとき、データの変更がAutolayoutの監視対象にはいるようで、
            // データの反映がかなり遅れる（体感で30秒くらい時間がかかる）ので、
            // ここの反映に関してはAutolayoutの非同期処理を実装する
            dispatch_async(dispatch_get_main_queue(), {
                self.lblSteps.text = steps.description
            })
        })
    }
```

``` HealthKit.swift
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
```

つまづいたところはHealthKitから取得した歩数をUILabelやUITextViewに設定しても描画されなかった現象に遭遇したところです。
それを回避するためにdispatch_asyncブロックでデータのセットを行っています。

歩数の取得条件に関してはPredicateで範囲指定ができるので、ある程度自由に取得が可能です。
