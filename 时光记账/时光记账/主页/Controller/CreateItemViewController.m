//
//  CreateItemViewController.m
//  时光记账
//
//  Created by 海若 on 15-1-29.
//  Copyright (c) 2015年 517na. All rights reserved.
//

#import "CreateItemViewController.h"
#import "AudioToolbox/AudioToolbox.h"
#import "MyDB.h"

@interface CreateItemViewController (){
    
    CalendarView *calendarView;
    UIPickerView *selectGetPictureMethod;
    
    NSMutableArray *typeArray;
    NSMutableDictionary *collectInfoDictionary;
    float price;
    float totalPrice;
    BOOL _isTaped;
    BOOL isPointClick;
    MyDB *_myDB;
}

@end

@implementation CreateItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    collectInfoDictionary = [NSMutableDictionary dictionary];
    _isTaped = NO;
    isPointClick = NO;
    //读取plist文件内容
    NSString *pathForPlist = [[NSBundle mainBundle]pathForResource:@"consumptiontype" ofType:@"plist"];
    typeArray = [[NSMutableArray alloc]initWithContentsOfFile:pathForPlist];
    
    
    //默认是一般的消费类型
    [collectInfoDictionary setValue:typeArray[0] forKey:@"kinds"];
    
    //默认日期为当前
    NSDate *today = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:today];
    NSDate *selectedDate = [today  dateByAddingTimeInterval: interval];
    NSString *select = [[NSString stringWithFormat:@"%@",selectedDate]substringToIndex:10];
    [collectInfoDictionary setValue:select forKey:@"date"];
    
    //默认备注为空
    [collectInfoDictionary setValue:@"" forKey:@"note"];
    
    //默认拍照片为空
    [collectInfoDictionary setValue:[NSData data] forKey:@"picture"];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired = 1;
    [_topViewOfKeyboardView addGestureRecognizer:tapGesture];
    
    //初始化日历控件视图时 在屏幕下方并没有显示出来
    calendarView = [[CalendarView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 250)];
    calendarView.calendarDate = [NSDate date];
    calendarView.delegate = self;
    [calendarView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:calendarView];
    
    //给 collectionView添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [_collectionView addGestureRecognizer:longPress];
    
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
            if ((priceFloatNum - (int)priceFloatNum) > 0 ) {
                priceFloatNum = (int)priceFloatNum;
                isPointClick = NO;
            }else{
                priceFloatNum = (int)priceFloatNum/10;
            }
            [_priceLabel setText:[NSString stringWithFormat:@"¥%.1f",priceFloatNum]];
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
                if (priceFloatNum == 0.0) {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请输入金额" message:nil delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                    [alertView show];
                }else{
                    _isTaped = YES;
                    [self hidenTopViewAndKeyboardView];
                    [collectInfoDictionary setValue:@(priceFloatNum) forKey:@"price"];
                    
                    _myDB = [MyDB sharedDBManager];
                    if([_myDB insertInfoToTableWithParameters:collectInfoDictionary]){
                        //跳转到首页
                        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"isNeedRefresh"];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }
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
        calendarView.frame = CGRectMake(0, self.view.frame.size.height - 250, self.view.frame.size.width, 250);
    }];
    
}
//取消日历的显示
-(void)hidethecalendarview{
    [UIView animateWithDuration:0.1 animations:^{
        calendarView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 250);
    }];
}
//添加备注
- (IBAction)remarkBtnClick:(UIButton *)sender {
    //ios8建议使用UIAlertController
    UIAlertController *remarkController = [UIAlertController alertControllerWithTitle:@"添加备注信息" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [remarkController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"备注信息";
    }];
    //添加取消确定按钮并设置点击确定按钮的回调事件
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UITextField * remarkField = remarkController.textFields.firstObject;
        NSString *getRemarkText = [remarkField.text description];
        if (getRemarkText.length != 0) {
            [collectInfoDictionary setValue:getRemarkText forKey:@"note"];
        }
    }];
    [remarkController addAction:cancelAction];
    [remarkController addAction:okAction];
    
   [self presentViewController:remarkController animated:YES completion:nil];
}
//相机
- (IBAction)cameraBtnClick:(UIButton *)sender {
    UIAlertController *pickPictureController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        //调用相机
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing=YES;
        [self presentViewController:imagePickerController animated:YES completion:nil];

    }];
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        //调用相册
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        imagePickerController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing=YES;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }];
    [pickPictureController addAction:cancelAction];
    [pickPictureController addAction:deleteAction];
    [pickPictureController addAction:archiveAction];

    [self presentViewController:pickPictureController animated:YES completion:nil];
}

//输入框抖动
-(void)shakeView:(UIView*)viewToShake
{
    CGFloat t =2.0;
    CGAffineTransform translateRight  = CGAffineTransformTranslate(CGAffineTransformIdentity, t,0.0);
    CGAffineTransform translateLeft = CGAffineTransformTranslate(CGAffineTransformIdentity,-t,0.0);
    
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
#pragma mark 日历选择时间的回掉
-(void)tappedOnDate:(NSDate *)selectedDate{
    
    NSTimeInterval secondsBetweenDates= [selectedDate timeIntervalSinceDate:[NSDate date]];
    //如果选择的日期大于今天
    if (secondsBetweenDates > 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请选择当前或之前的日期作为消费日期" delegate:self cancelButtonTitle:@"重新选择" otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        NSLog(@"选择的日期为--------->%@",selectedDate);
        NSDate *today = [NSDate date];
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate:today];
        selectedDate = [selectedDate  dateByAddingTimeInterval: interval];
        
        NSString *select = [[NSString stringWithFormat:@"%@",selectedDate]substringToIndex:10];
        [collectInfoDictionary setValue:select forKey:@"date"];
        [self hidethecalendarview];
    }
}
#pragma mark UIcolloctionView && MasonryViewLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return typeArray.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectioncell" forIndexPath:indexPath];
    UILabel *label = (UILabel*)[cell viewWithTag:5];
    label.text = typeArray[indexPath.row];
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
    //得到点击cell的快照 实现动画效果
    UIView *snapshot = [self customSnapshoFromView:[_collectionView cellForItemAtIndexPath:indexPath]];
    __block CGPoint center = [_collectionView cellForItemAtIndexPath:indexPath].center;
    center.y += 58;
    snapshot.center = center;
    [self.view addSubview:snapshot];
    center.x = 25;
    center.y = self.view.bounds.size.height - 193;
    
    [UIView animateWithDuration:0.5 animations:^{
        snapshot.center = center;
        snapshot.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
    }completion:^(BOOL finished) {
        _itemTitleLabel.text = typeArray[indexPath.row];
        
        //把消费者种类加入到搜集字典中
        [collectInfoDictionary setValue:[typeArray objectAtIndex:indexPath.row] forKey:@"kinds"];
        
        [UIView animateWithDuration:0.2 animations:^{
            snapshot.alpha = 0.0;
        }completion:^(BOOL finished) {
            [snapshot removeFromSuperview];
        }];
    }];
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
#pragma mark collectionview长按的回调
//collectionView长按回调
- (IBAction)longPressGestureRecognized:(id)sender {
    _topView.alpha = 0.0;
    _keboardView.alpha = 0.0;
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:_collectionView];
    //通过点找到cell所在的indexPath
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:location];
    
    static UIView       *snapshot = nil;        ///被选择cell的快照
    static NSIndexPath  *sourceIndexPath = nil; ///被选择cell的位置，会不断的变化
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
                //得到被选择cell的快照
                snapshot = [self customSnapshoFromView:cell];
                //把这个快照作为子视图加入到collection当中
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [_collectionView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    //把快照移动到长按的位置并放大1.05倍，透明度设成0.98，把被点击cell消失掉
                    center.y = location.y;
                    center.x = location.x;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    cell.alpha = 0.0;
                    cell.hidden = YES;
                }];
            }
            break;
        }
            //长按状态发生改变
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            center.x = location.x;
            snapshot.center = center;
            [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            // 拖动到的位置是同一个collectonview吗？是有效的cell位置吗？
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                //升级下位置改变之后的源数据顺序
                //                [self.objects exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                //把cell从初始位置移动到当前停留位置
                [_collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                // 不断变化初始位置
                sourceIndexPath = indexPath;
            }
            break;
        }
        default: {
            // 长按结束.
            UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
            } completion:^(BOOL finished) {
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                //这里是为了解决长按弹出的bug。
                if (_isTaped) {
                    CGRect topViewFrame = _topView.frame;
                    CGRect keyboardViewFrame = _keboardView.frame;
                    topViewFrame.origin.y -= 58;
                    keyboardViewFrame.origin.y += 172;
                    [UIView animateWithDuration:0.01 animations:^{
                        _topView.frame = topViewFrame;
                        _keboardView.frame = keyboardViewFrame;
                    }completion:^(BOOL finished) {
                        if (finished) {
                            [UIView animateWithDuration:0.5 animations:^{
                                _topView.alpha = 1.0;
                                _keboardView.alpha = 1.0;
                            }];
                        }
                    }];
                }else{
                    [UIView animateWithDuration:0.5 animations:^{
                        _topView.alpha = 1.0;
                        _keboardView.alpha = 1.0;
                    }];
                }
            }];
            break;
        }
    }
}
//根据传入的view得到快照
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // 通过传入view得到图片
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 把这个图片加入到view当中并设置阴影
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}
//相机或相册选择图片之后的回调方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //得到的是编辑后的图片
    UIImage *image=[info objectForKey:@"UIImagePickerControllerEditedImage"];
    //把图片转化成二进制
    NSData *dataImg = UIImagePNGRepresentation(image);
    [collectInfoDictionary setValue:dataImg forKey:@"picture"];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end