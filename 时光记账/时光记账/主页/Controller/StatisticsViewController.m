//
//  StatisticsViewtrollerViewController.m
//  时光记账
//
//  Created by 海若 on 15/5/19.
//  Copyright (c) 2015年 517na. All rights reserved.
//

#import "StatisticsViewController.h"

@interface StatisticsViewController ()

@end

@implementation StatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [chart setMainColor:[UIColor redColor]];
    [chart setSecondaryColor:[UIColor greenColor]];
    [chart setLineColor:[UIColor redColor]];
    [chart setFontSize:13.0];
    [chart setText:@"(支出占收入的百分比)"];
    [chart setPercentage:59.0];
    
    [chart1 setMainColor:[UIColor redColor]];
    [chart1 setSecondaryColor:[UIColor greenColor]];
    [chart1 setLineColor:[UIColor redColor]];
    [chart1 setFontSize:13.0];
    [chart1 setText:@"(支出占收入的百分比)"];
    [chart1 setPercentage:36.0];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
