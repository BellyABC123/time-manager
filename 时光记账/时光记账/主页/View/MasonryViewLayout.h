//
//  MasonryViewLayout.h
//  时光记账
//
//  Created by 海若 on 15-1-28.
//  Copyright (c) 2015年 517na. All rights reserved.
//


#import <UIKit/UIKit.h>

@class MasonryViewLayout;

@protocol MasonryViewLayoutDelegate <NSObject>
@required
- (CGFloat) collectionView:(UICollectionView*) collectionView
                   layout:(MasonryViewLayout*) layout
 heightForItemAtIndexPath:(NSIndexPath*) indexPath;
@end

@interface MasonryViewLayout : UICollectionViewLayout
@property (nonatomic, assign) NSUInteger numberOfColumns;
@property (nonatomic, assign) CGFloat interItemSpacing;
@property (weak, nonatomic) IBOutlet id<MasonryViewLayoutDelegate> delegate;
@end
