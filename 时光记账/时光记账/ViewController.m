//
//  ViewController.m
//  时光记账
//
//  Created by 海若 on 15-1-28.
//  Copyright (c) 2015年 517na. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){

    NSMutableDictionary *witchIsClicked;
    NSInteger count;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    count = 10;
    
    witchIsClicked = [NSMutableDictionary dictionaryWithCapacity:10];
    
    //去除tableviewcell的分割线
    [_mainTableVie setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //把Button设置成原型，直接把圆角设置成正方形边长的一半即可
    _addNewCountButton.layer.cornerRadius = _addNewCountButton.frame.size.width/2;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

#pragma mark UITableVie回调
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    for (int j = 0; j<count; j++) {
        [witchIsClicked setValue:@0 forKey:[NSString stringWithFormat:@"%d",j]];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseID = @"maintableviewcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    return  cell;
}

//点击消费类型图标按键
- (IBAction)titleIconBtnClick:(UIButton *)sender {
    BOOL stillClicked = NO;
    //直至获取到sender的父ViewUITableViewCell
    id tempView = [sender superview];
    while (![tempView isKindOfClass:[UITableViewCell class]]){
        
        tempView = [tempView superview];
    }
    UITableViewCell *cell = (UITableViewCell*)tempView;
    NSIndexPath *path = [_mainTableVie indexPathForCell:cell];
    //消费
    UILabel *expenditureLabel = (UILabel*)[cell viewWithTag:101];
    //收入
    UILabel *incomeLabel = (UILabel*)[cell viewWithTag:100];
    //删除
    UIButton *deleteButton = (UIButton*)[cell viewWithTag:104];
    //编辑
    UIButton *editButton = (UIButton*)[cell viewWithTag:105];
    
    if ([[witchIsClicked valueForKey:[NSString stringWithFormat:@"%ld",(long)path.row]] isEqualToValue:@0]) {
        
        [witchIsClicked setValue:@1 forKey:[NSString stringWithFormat:@"%ld",(long)path.row]];
        [_mainTableVie setScrollEnabled:NO];
        
        [UIView animateWithDuration:0.1 animations:^{
            expenditureLabel.alpha = 0.0;
            incomeLabel.alpha = 0.0;
        }completion:^(BOOL finished) {
            //取消隐藏
            deleteButton.hidden = NO;
            editButton.hidden = NO;
            //变化位置
            CGRect rectDeleteButton = deleteButton.frame;
            CGRect rectEditButton = editButton.frame;
            rectDeleteButton.origin.x = rectDeleteButton.origin.x - (self.view.frame.size.width)/3;
            rectEditButton.origin.x = rectEditButton.origin.x + (self.view.frame.size.width)/3;
            [UIView animateWithDuration:0.4 animations:^{
                deleteButton.frame = rectDeleteButton;
                editButton.frame = rectEditButton;
            }];
        }];
    }else{
         [witchIsClicked setValue:@0 forKey:[NSString stringWithFormat:@"%ld",(long)path.row]];
        //恢复位置
        CGRect rectDeleteButton = deleteButton.frame;
        CGRect rectEditButton = editButton.frame;
        rectDeleteButton.origin.x = rectDeleteButton.origin.x + (self.view.frame.size.width)/3;
        rectEditButton.origin.x = rectEditButton.origin.x - (self.view.frame.size.width)/3;
        
        [UIView animateWithDuration:0.4 animations:^{
            deleteButton.frame = rectDeleteButton;
            editButton.frame = rectEditButton;
        }completion:^(BOOL finished) {
            deleteButton.hidden = YES;
            editButton.hidden = YES;
            [UIView animateWithDuration:0.2 animations:^{
                expenditureLabel.alpha = 1.0;
                incomeLabel.alpha = 1.0;
            }];
        }];
        for (NSValue *value in witchIsClicked) {
            if([[witchIsClicked valueForKey:[NSString stringWithFormat:@"%@",value]] isEqualToValue:@1]){
                stillClicked =  YES;
            }
        }
        if (!stillClicked) {
            [_mainTableVie setScrollEnabled:YES];
        }
    }
}

- (IBAction)addNewCount:(UIButton *)sender {
    
    NSArray *arr = [witchIsClicked allKeys];
    for (NSString *key in arr) {
        if ([[witchIsClicked valueForKey:key] isEqualToValue:@1]) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:[key integerValue] inSection:0];

            UITableViewCell *myCell = [_mainTableVie cellForRowAtIndexPath:path];
            
            [witchIsClicked setValue:@0 forKey:[NSString stringWithFormat:@"%ld",(long)path.row]];
            //消费
            UILabel *expenditureLabel = (UILabel*)[myCell viewWithTag:101];
            //收入
            UILabel *incomeLabel = (UILabel*)[myCell viewWithTag:100];
            //删除
            UIButton *deleteButton = (UIButton*)[myCell viewWithTag:104];
            //编辑
            UIButton *editButton = (UIButton*)[myCell viewWithTag:105];
            //恢复位置
            CGRect rectDeleteButton = deleteButton.frame;
            CGRect rectEditButton = editButton.frame;
            rectDeleteButton.origin.x = rectDeleteButton.origin.x + (self.view.frame.size.width)/3;
            rectEditButton.origin.x = rectEditButton.origin.x - (self.view.frame.size.width)/3;
            
            [UIView animateWithDuration:0.4 animations:^{
                deleteButton.frame = rectDeleteButton;
                editButton.frame = rectEditButton;
            }completion:^(BOOL finished) {
                deleteButton.hidden = YES;
                editButton.hidden = YES;
                [UIView animateWithDuration:0.2 animations:^{
                    expenditureLabel.alpha = 1.0;
                    incomeLabel.alpha = 1.0;
                }];
            }];
        }
    }
    
    
    BOOL stillClicked = NO;
    for (NSValue *value in witchIsClicked) {
        if([[witchIsClicked valueForKey:[NSString stringWithFormat:@"%@",value]] isEqualToValue:@1]){
            stillClicked =  YES;
        }
    }
    if (!stillClicked) {
        [_mainTableVie setScrollEnabled:YES];
        [UIView animateWithDuration:0.5 animations:^{
            CABasicAnimation* rotationAnimation;
            rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 0.5 ];
            [sender.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        } completion:^(BOOL finished) {
            [self performSegueWithIdentifier:@"showcreateitemviewcontroller" sender:self];
        }];
    }
   
}

@end
