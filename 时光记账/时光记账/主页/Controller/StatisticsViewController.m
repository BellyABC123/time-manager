//
//  StatisticsViewtrollerViewController.m
//  时光记账
//
//  Created by 海若 on 15/5/19.
//  Copyright (c) 2015年 517na. All rights reserved.
//

#import "StatisticsViewController.h"
#import "MyDB.h"
@interface StatisticsViewController (){
    MyDB *myDB;
    float totalIncome;
    float totalOutcome;
    float totalIncomeMonth;
    float totalOutcomeMonth;
    NSMutableArray *arrayWithAllResult;
    BOOL anyItem;
}


@end

@implementation StatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    myDB = [MyDB sharedDBManager];
    totalIncome = 0;
    totalOutcome = 0;
    totalIncomeMonth = 0;
    totalOutcomeMonth = 0;
    
    arrayWithAllResult = [NSMutableArray arrayWithArray:[myDB queryAll]];
    
    //默认日期为当前
    NSDate *today = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:today];
    NSDate *selectedDate = [today  dateByAddingTimeInterval: interval];
    NSString *select = [[NSString stringWithFormat:@"%@",selectedDate]substringToIndex:7];
    
    if (arrayWithAllResult.count) {
        anyItem = YES;
        for (NSDictionary *perDic in arrayWithAllResult) {
            if ([[perDic valueForKey:@"kinds"] isEqualToString:@"收入"]) {
                totalIncome +=  [[perDic valueForKey:@"price"] floatValue];
            }else{
                totalOutcome += [[perDic valueForKey:@"price"] floatValue];
            }
            
            if ([[perDic valueForKey:@"date"] rangeOfString:select].location != NSNotFound) {
                if ([[perDic valueForKey:@"kinds"] isEqualToString:@"收入"]) {
                    totalIncomeMonth +=  [[perDic valueForKey:@"price"] floatValue];
                }else{
                    totalOutcomeMonth += [[perDic valueForKey:@"price"] floatValue];
                }
            }
        }
    }else{
       anyItem = NO;
    }
    [chart setMainColor:[UIColor redColor]];
    [chart setSecondaryColor:[UIColor greenColor]];
    [chart setLineColor:[UIColor redColor]];
    [chart setFontSize:13.0];
    [chart setText:@"(支出占收入的百分比)"];
    
    [chart1 setMainColor:[UIColor redColor]];
    [chart1 setSecondaryColor:[UIColor greenColor]];
    [chart1 setLineColor:[UIColor redColor]];
    [chart1 setFontSize:13.0];
    [chart1 setText:@"(支出占收入的百分比)"];
    if (anyItem) {
        if (totalIncome != 0) {
            [chart setPercentage:(totalOutcome/totalIncome)*100];
            
        }else{
            [chart setPercentage:99.9];
        }
        _allOutComeLabel.text = [NSString stringWithFormat:@"总支出:￥%0.1f",totalOutcome];
        _allIncomeLabel.text = [NSString stringWithFormat:@"总收入:￥%0.1f",totalIncome];
        
        if (totalIncomeMonth != 0) {
            [chart1 setPercentage:(totalOutcomeMonth/totalIncomeMonth)*100];
        }else{
            [chart1 setPercentage:99.9];
        }
        
        _thisMonthOutcomeLabel.text = [NSString stringWithFormat:@"总支出:￥%0.1f",totalOutcomeMonth];
        _thisMonthIncomeLabel.text = [NSString stringWithFormat:@"总收入:￥%0.1f",totalIncomeMonth];

    }else{
        [chart setPercentage:0.0];
        [chart1 setPercentage:0.0];
        _allIncomeLabel.text = @"总支出:￥0.0";
        _allOutComeLabel.text = @"总收入:￥0.0";
        _thisMonthIncomeLabel.text = @"总收入:￥0.0";
        _thisMonthOutcomeLabel.text = @"总支出:￥0.0";
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
