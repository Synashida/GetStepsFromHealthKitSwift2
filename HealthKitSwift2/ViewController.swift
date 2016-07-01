//
//  ViewController.swift
//  HealthKitSwift2
//
//  Created by ashida on 2016/06/29.
//  Copyright © 2016年 v-force.co.jp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var lblSteps: UILabel!
    @IBOutlet weak var btnGetSteps: UIButton!
    @IBOutlet weak var dtpDate:UIDatePicker!
    
    let healthKit = HealthKit()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

