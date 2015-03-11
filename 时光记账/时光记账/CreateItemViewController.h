//
//  CreateItemViewController.h
//  时光记账
//
//  Created by 海若 on 15-1-29.
//  Copyright (c) 2015年 517na. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarView.h"
#import "MasonryViewLayout.h"
@interface CreateItemViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,MasonryViewLayoutDelegate>

@property (weak, nonatomic) IBOutlet UIView *keboardView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *topViewOfKeyboardView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

- (IBAction)backBtnClick:(UIButton *)sender;
- (IBAction)keboardBtnClick:(UIButton *)sender;
- (IBAction)calendarBtnClick:(UIButton *)sender;
- (IBAction)remarkBtnClick:(UIButton *)sender;
- (IBAction)cameraBtnClick:(UIButton *)sender;
@end
