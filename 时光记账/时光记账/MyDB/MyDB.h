//
//  MyDB.h
//  时光记账
//
//  Created by 海若 on 15-1-30.
//  Copyright (c) 2015年 517na. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
@interface MyDB : NSObject{
    FMDatabase *_db;
    NSString *_tableName;
}

@end
