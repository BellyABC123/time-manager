//
//  MainViewController
//  时光记账
//
//  Created by 海若 on 15-1-28.
//  Copyright (c) 2015年 517na. All rights reserved.
//

#import "MainViewController.h"
#import "CreateItemViewController.h"
#import "MyDB.h"
@interface MainViewController (){
    
    NSMutableDictionary *witchIsClicked;
    NSMutableArray *arrayWithAllResult;
    UIScrollView *detailImageScrollView;
    NSString *dateStr;
    float totalIncome;
    float totalOutcome;
    MyDB *myDB;
}
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     myDB = [MyDB sharedDBManager];
    
    witchIsClicked = [NSMutableDictionary dictionaryWithCapacity:10];
    //去除tableviewcell的分割线
    [_mainTableVie setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //把Button设置成原型，直接把圆角设置成正方形边长的一半即可
    _addNewCountButton.layer.cornerRadius = _addNewCountButton.frame.size.width/2;
    _cktjLabel.layer.cornerRadius = 10;
    _cktjLabel.layer.borderWidth = 1;
    _cktjLabel.layer.borderColor = [UIColor greenColor].CGColor;
    [self queryTableAndUpdateTableView];
    
}
-(void)viewWillAppear:(BOOL)animated{
    dateStr = @"";
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"isNeedRefresh"] integerValue] == 1) {
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"isNeedRefresh"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self queryTableAndUpdateTableView];
    }
}
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

#pragma mark UITableVie回调
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    for (int j = 0; j<arrayWithAllResult.count; j++) {
        [witchIsClicked setValue:@0 forKey:[NSString stringWithFormat:@"%d",j]];
    }
    return arrayWithAllResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseID = @"maintableviewcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    UILabel *inCome = (UILabel*)[cell viewWithTag:100];
    UILabel *outCome = (UILabel*)[cell viewWithTag:101];
    UIButton *kindButton = (UIButton*)[cell viewWithTag:103];
    UILabel *remarkIncome = (UILabel*)[cell viewWithTag:201];
    UILabel *remarkOutcome = (UILabel*)[cell viewWithTag:200];
    UIImageView *imageIncome = (UIImageView *)[cell viewWithTag:202];
    UIImageView *imageOutcome = (UIImageView *)[cell viewWithTag:203];
    
    UILabel *dateLabel = (UILabel*)[cell viewWithTag:110];
    UILabel *pointLabel = (UILabel*)[cell viewWithTag:111];
    
    
    //设置两个imageView的单机手势
    imageOutcome.userInteractionEnabled = YES;
    imageIncome.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showImageDetail:)];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showImageDetail:)];
    tap1.numberOfTapsRequired = 1;
    tap2.numberOfTapsRequired = 1;
    [imageIncome addGestureRecognizer:tap1];
    [imageOutcome addGestureRecognizer:tap2];
    
    [imageIncome setImage:nil];
    [imageOutcome setImage:nil];
    
    NSDictionary *dic  = [NSDictionary dictionaryWithDictionary:[arrayWithAllResult objectAtIndex:indexPath.row]];
    
    if ([dateStr isEqualToString:[dic valueForKey:@"date"]]) {
        pointLabel.hidden = YES;
        dateLabel.hidden = YES;
    }else{
        pointLabel.hidden = NO;
        dateLabel.hidden = NO;
        dateLabel.text = [dic valueForKey:@"date"];
        dateStr = [dic valueForKey:@"date"];
    }
    
    if ([[dic valueForKey:@"kinds"] isEqualToString:@"收入"]) {
        [imageIncome setImage:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithData:[dic valueForKey:@"picture"]];
            if (image) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [imageIncome setImage:image];
                });
            }
            
        });
        
        [kindButton setBackgroundImage:[UIImage imageNamed:@"income"] forState:UIControlStateNormal];
        inCome.text = [NSString stringWithFormat:@"￥%@ 收入",[dic valueForKey:@"price"]];
        outCome.text = nil;
        remarkIncome.text = [dic valueForKey:@"note"];
        remarkOutcome.text = nil;
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithData:[dic valueForKey:@"picture"]];
            if (image) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [imageOutcome setImage:image];
                });
            }
            
        });
        [kindButton setBackgroundImage:[UIImage imageNamed:@"custom"] forState:UIControlStateNormal];
        inCome.text = nil;
        outCome.text = [NSString stringWithFormat:@"%@ ￥%@",[dic valueForKey:@"kinds"],[dic valueForKey:@"price"]];
        remarkIncome.text  = nil;
        remarkOutcome.text = [dic valueForKey:@"note"];
    }
    return  cell;
}
//UITableView是允许编辑的
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//编辑时的回调方法
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //删除数据库内容和数组的内容
    int Id = [arrayWithAllResult[indexPath.row][@"id"] intValue];
    [myDB deleteTableDatawithID:Id];
    [arrayWithAllResult removeObjectAtIndex:indexPath.row];
    
    //更新数据----------------------------------------------------------------------------
    totalIncome = 0;
    totalOutcome = 0;
    if (arrayWithAllResult.count) {
        _lineLabel.hidden = NO;
    }else{
        _lineLabel.hidden = YES;
    }
    for (NSDictionary *perDic in arrayWithAllResult) {
        if ([[perDic valueForKey:@"kinds"] isEqualToString:@"收入"]) {
            totalIncome +=  [[perDic valueForKey:@"price"] floatValue];
        }else{
            totalOutcome += [[perDic valueForKey:@"price"] floatValue];
        }
    }
    _totalIncomeLabel.text = [NSString stringWithFormat:@"%0.1f",totalIncome];
    _totalOutcomeLabel.text = [NSString stringWithFormat:@"%0.1f",totalOutcome];
    //------------------------------------------------------------------------------------
    
    [_mainTableVie deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
//点击cell中的图片，放大，可以滚动查看
-(void)showImageDetail:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    UIImageView *imageView = (UIImageView*)tap.view;
    
    NSIndexPath *path = [self getIndexPath:imageView];
    UIImage *detailImage = [UIImage imageWithData:[[arrayWithAllResult objectAtIndex:path.row] valueForKey:@"picture"]];
    
    CGPoint location = [tap locationInView:self.view];
    UIImageView *detailImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, detailImage.size.width, detailImage.size.height)];
    [detailImageView setImage:detailImage];
    
    detailImageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(location.x - 5, location.y - 5, imageView.frame.size.width, imageView.frame.size.height)];
    
    NSArray *numArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f",location.x-5],[NSString stringWithFormat:@"%f",location.y-5], [NSString stringWithFormat:@"%f",imageView.frame.size.width],[NSString stringWithFormat:@"%f",imageView.frame.size.height],nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:numArray forKey:@"originframe"];
    
    
    [detailImageScrollView addSubview:detailImageView];
    [self.view addSubview:detailImageScrollView];
    
    [UIView animateWithDuration:0.3 animations:^{
        detailImageScrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    }completion:^(BOOL finished) {
        detailImageScrollView.contentSize = detailImage.size;
        //添加手势以便在次点击消失
        UITapGestureRecognizer *tapHide = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideScrollView:)];
        tapHide.numberOfTapsRequired = 1;
        [detailImageScrollView addGestureRecognizer:tapHide];
    }];
    
}
//点击放大到全屏幕的图片 让其消失
-(void)hideScrollView:(id)sender{
    UITapGestureRecognizer *tapHide = (UITapGestureRecognizer*)sender;
    UIScrollView *myWantView = (UIScrollView*)tapHide.view;
    NSArray *numArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"originframe"];
    
    [UIView animateWithDuration:0.3 animations:^{
        detailImageScrollView.frame = CGRectMake([[numArray objectAtIndex:0] floatValue], [[numArray objectAtIndex:1]floatValue], [[numArray objectAtIndex:2]floatValue], [[numArray objectAtIndex:3]floatValue]);
    }completion:^(BOOL finished) {
        [myWantView removeFromSuperview];
    }];
    
}
//点击消费类型图标按键
- (IBAction)titleIconBtnClick:(UIButton *)sender {
    
    
    NSIndexPath *path = [self getIndexPath:sender];
    UITableViewCell *cell = [_mainTableVie cellForRowAtIndexPath:path];
    //消费
    UILabel *expenditureLabel = (UILabel*)[cell viewWithTag:101];
    //收入
    UILabel *incomeLabel = (UILabel*)[cell viewWithTag:100];
    //删除
    UIButton *deleteButton = (UIButton*)[cell viewWithTag:104];
    //编辑
    UIButton *editButton = (UIButton*)[cell viewWithTag:105];
    
    UILabel *remarkIncome = (UILabel*)[cell viewWithTag:201];
    UILabel *remarkOutcome = (UILabel*)[cell viewWithTag:200];
    UIImageView *imageIncome = (UIImageView *)[cell viewWithTag:202];
    UIImageView *imageOutcome = (UIImageView *)[cell viewWithTag:203];
    if ([[witchIsClicked valueForKey:[NSString stringWithFormat:@"%ld",(long)path.row]] isEqualToValue:@0]) {
        [self closeAlready];
        [witchIsClicked setValue:@1 forKey:[NSString stringWithFormat:@"%ld",(long)path.row]];
        [_mainTableVie setScrollEnabled:NO];
        
        [UIView animateWithDuration:0.1 animations:^{
            expenditureLabel.alpha = 0.0;
            incomeLabel.alpha = 0.0;
            remarkIncome.alpha = 0.0;
            remarkOutcome.alpha = 0.0;
            imageIncome.alpha = 0.0;
            imageOutcome.alpha = 0.0;
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
                remarkIncome.alpha = 1.0;
                remarkOutcome.alpha = 1.0;
                imageIncome.alpha = 1.0;
                imageOutcome.alpha = 1.0;
            }];
        }];
        
        BOOL stillClicked = NO;
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
//点击 +  号按钮
- (IBAction)addNewCount:(UIButton *)sender {
    
    [self closeAlready];
    
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
//关闭其他所有已经展开的
-(void)closeAlready{
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
    [_mainTableVie setScrollEnabled:YES];
}
- (IBAction)editBtnClick:(UIButton *)sender {
    //关闭已经展开的
    [self closeAlready];
    [[NSUserDefaults standardUserDefaults]setValue:@"1" forKey:@"edit"];
    NSIndexPath *path = [self getIndexPath:sender];
    NSMutableDictionary *clickItemInfo = [arrayWithAllResult objectAtIndex:path.row];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CreateItemViewController *createItemViewController = [storyBoard instantiateViewControllerWithIdentifier:@"createitemviewcontroller"];
    createItemViewController.collectInfoDictionary = clickItemInfo;
    [self presentViewController:createItemViewController animated:YES completion:nil];
}
//点击删除按钮
- (IBAction)deleteBtnClick:(UIButton *)sender {
    [self closeAlready];
    NSIndexPath *path = [self getIndexPath:sender];
    [self tableView:_mainTableVie commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:path];
}
//根据view获取到view所在的tableViewcell，方法返回cell的indexpath
-(NSIndexPath*)getIndexPath:(UIView*)view{
    id tempView = [view superview];
    while (![tempView isKindOfClass:[UITableViewCell class]]){
        
        tempView = [tempView superview];
    }
    UITableViewCell *cell = (UITableViewCell*)tempView;
    NSIndexPath *path = [_mainTableVie indexPathForCell:cell];
    
    return path;
}
//查询数据库，并更新更新视图
-(void)queryTableAndUpdateTableView{
    [arrayWithAllResult removeAllObjects];
    arrayWithAllResult = [NSMutableArray arrayWithArray:[myDB queryAll]];
    totalIncome = 0;
    totalOutcome = 0;
    if (arrayWithAllResult.count) {
        _lineLabel.hidden = NO;
    }else{
        _lineLabel.hidden = YES;
    }
    for (NSDictionary *perDic in arrayWithAllResult) {
        if ([[perDic valueForKey:@"kinds"] isEqualToString:@"收入"]) {
            totalIncome +=  [[perDic valueForKey:@"price"] floatValue];
        }else{
            totalOutcome += [[perDic valueForKey:@"price"] floatValue];
        }
    }
    _totalIncomeLabel.text = [NSString stringWithFormat:@"3%0.1f",totalIncome];
    _totalOutcomeLabel.text = [NSString stringWithFormat:@"%0.1f",totalOutcome];
    //
    [arrayWithAllResult sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]]];
    [_mainTableVie reloadData];
}
@end
