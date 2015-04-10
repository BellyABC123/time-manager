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
+ (instancetype)sharedDBManager;

-(BOOL)createTable;
-(BOOL)insertInfoToTableWithParameters:(NSDictionary *)parameters;
-(BOOL)deleteTableDatawithID:(int)ID;
-(BOOL)editTableDataWithID:(NSDictionary *)dicInfo;

- (NSDictionary *)querywithID:(int)ID;
- (NSMutableArray *)queryAll;
@end
