//
//  MainViewController.h
//  时光记账
//
//  Created by 海若 on 15-1-28.
//  Copyright (c) 2015年 517na. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTableVie;
@property (weak, nonatomic) IBOutlet UIButton *addNewCountButton;

- (IBAction)titleIconBtnClick:(UIButton *)sender;
- (IBAction)addNewCount:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *totalIncomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalOutcomeLabel;
- (IBAction)editBtnClick:(UIButton *)sender;
- (IBAction)deleteBtnClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;

@end

