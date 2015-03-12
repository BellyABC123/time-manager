//
//  CreateItemViewController.m
//  时光记账
//
//  Created by 海若 on 15-1-29.
//  Copyright (c) 2015年 517na. All rights reserved.
//

#import "CreateItemViewController.h"

@interface CreateItemViewController (){
    BOOL _isTaped;
    UIView *newView;
    BOOL isPointClick;
    

    float price;
    float totalPrice;
}

@end

@implementation CreateItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     // Do any additional setup after loading the view.
    _isTaped = NO;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired = 1;
    [_topViewOfKeyboardView addGestureRecognizer:tapGesture];
   
    //初始化日历控件的承载视图时 在屏幕下方并没有显示出来
    newView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    newView.backgroundColor = [UIColor blackColor];
    newView.alpha = 0.8;
    [self.view addSubview:newView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidethecalendarview)];
    tap.numberOfTapsRequired = 1;
    [newView addGestureRecognizer:tap];
    CalendarView *calendarView = [[CalendarView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 250, self.view.frame.size.width, 250)];
    calendarView.calendarDate = [NSDate date];
    calendarView.alpha = 1;
    
    [newView addSubview:calendarView];
    isPointClick = NO;
}

//手势识别调用方法
-(void)handleTapGesture{
    _isTaped = !_isTaped;
    if (_isTaped) {
        [self hidenTopViewAndKeyboardView];
    }else{
        [self showTopViewAndKeyboardView];
    }
}
//隐藏
-(void)hidenTopViewAndKeyboardView{
    CGRect topViewFrame = _topView.frame;
    CGRect keyboardViewFrame = _keboardView.frame;
    topViewFrame.origin.y -= 58;
    keyboardViewFrame.origin.y += 172;
    [UIView animateWithDuration:0.2 animations:^{
        _topView.frame = topViewFrame;
        _keboardView.frame = keyboardViewFrame;
    }];
}
//显示
-(void)showTopViewAndKeyboardView{
    CGRect topViewFrame = _topView.frame;
    CGRect keyboardViewFrame = _keboardView.frame;
    topViewFrame.origin.y += 58;
    keyboardViewFrame.origin.y -= 172;
    [UIView animateWithDuration:0.2 animations:^{
        _topView.frame = topViewFrame;
        _keboardView.frame = keyboardViewFrame;
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
//数字键盘
- (IBAction)keboardBtnClick:(UIButton *)sender {

    float priceFloatNum = [[_priceLabel.text substringFromIndex:1] floatValue];
    
    switch (sender.tag) {
        //逐个删除 →
        case 13:

            break;
        //归零 C
        case 11:
            isPointClick = NO;
            [_priceLabel setText:@"¥0.0"];
            break;
        //加  +
        case 14:
            [_okBtnTitle setTitle:@"=" forState:UIControlStateNormal];
            price = priceFloatNum;
            [_priceLabel setText:@"¥0.0"];
            
            isPointClick = NO;
            break;
        //OK // =
        case 15:
            isPointClick = NO;
            if ([sender.titleLabel.text isEqualToString:@"="]) {
                totalPrice = price+priceFloatNum;
                [_priceLabel setText:[NSString stringWithFormat:@"¥%.1f",totalPrice]];
                [sender setTitle:@"OK" forState:UIControlStateNormal];
            }else{
                _isTaped = YES;
                [self hidenTopViewAndKeyboardView];
                
                NSLog(@"就是这么多钱 -------> %0.1f",priceFloatNum);
            }
            break;
        //小数点 。
        case 12:
            isPointClick = YES;
            
            break;
        default:
            if (isPointClick) {
                if ((priceFloatNum - (int)priceFloatNum) > 0 ) {
                    [self shakeView:(UILabel*)_priceLabel];
                }else{
                    if (priceFloatNum <= 999999.0) {
                        priceFloatNum = priceFloatNum + sender.tag *0.1;
                    }else{
                        [self shakeView:(UILabel*)_priceLabel];
                    }
                }

            }else{
                if ((priceFloatNum*10 + sender.tag) <= 999999.0) {
                     priceFloatNum = priceFloatNum*10 + sender.tag;
                }else{
                    [self shakeView:(UILabel*)_priceLabel];
                }
            }
            [_priceLabel setText:[NSString stringWithFormat:@"¥%.1f",priceFloatNum]];
            break;
    }
}
//日历
- (IBAction)calendarBtnClick:(UIButton *)sender {
    [UIView animateWithDuration:0.1 animations:^{
        newView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    
}
//取消日历的显示
-(void)hidethecalendarview{
    [UIView animateWithDuration:0.1 animations:^{
        newView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    }];
}
//添加备注
- (IBAction)remarkBtnClick:(UIButton *)sender {
}
//相机
- (IBAction)cameraBtnClick:(UIButton *)sender {
}
#pragma mark UIcolloctionView && MasonryViewLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 40;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectioncell" forIndexPath:indexPath];
    UILabel *label = (UILabel*)[cell viewWithTag:5];
    label.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell;
}

//确定每一个cell的高度
- (CGFloat) collectionView:(UICollectionView*) collectionView layout:(MasonryViewLayout*) layout heightForItemAtIndexPath:(NSIndexPath*) indexPath{
    return (self.view.frame.size.width-6)/5;
}

//选择collectionview中某一项
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_isTaped) {
        _isTaped = !_isTaped;
        [self showTopViewAndKeyboardView];
    }
    NSLog(@"%ld",(long)indexPath.row);
}

#pragma mark UIScrollView 拖拽scrollview时的回调
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    //滑到顶部
    if (scrollView.contentOffset.y < 0) {
        //如果处于隐藏状态，那么就显示
        if (_isTaped) {
            _isTaped = !_isTaped;
            [self showTopViewAndKeyboardView];
        }
    }
    //滑动底部
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
        //如果处于显示状态就隐藏
        if (!_isTaped) {
            _isTaped = !_isTaped;
            [self hidenTopViewAndKeyboardView];
        }
    }
}
-(void)shakeView:(UIView*)viewToShake
{
    CGFloat t =2.0;
    CGAffineTransform translateRight  =CGAffineTransformTranslate(CGAffineTransformIdentity, t,0.0);
    CGAffineTransform translateLeft =CGAffineTransformTranslate(CGAffineTransformIdentity,-t,0.0);
    
    viewToShake.transform = translateLeft;
    
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        viewToShake.transform = translateRight;
    } completion:^(BOOL finished){
        if(finished){
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                viewToShake.transform =CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
}
@end