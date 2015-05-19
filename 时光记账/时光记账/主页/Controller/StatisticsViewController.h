//
//  StatisticsViewController.h
//  时光记账
//
//  Created by 海若 on 15/5/19.
//  Copyright (c) 2015年 517na. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PercentageChart.h"
@interface StatisticsViewController : UIViewController{
    IBOutlet PercentageChart *chart;
    IBOutlet PercentageChart *chart1;
}


- (IBAction)backBtnClick:(UIButton *)sender;
@end
