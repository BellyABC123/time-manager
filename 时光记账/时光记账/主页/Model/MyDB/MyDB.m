//
//  MyDB.m
//  时光记账
//
//  Created by 海若 on 15-1-30.
//  Copyright (c) 2015年 517na. All rights reserved.
//

#import "MyDB.h"

static MyDB * sharedDB;

@implementation MyDB

+ (instancetype)sharedDBManager{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedDB = [[MyDB alloc]init];
        [sharedDB createTable];
    });
    return sharedDB;
}
-(instancetype)init{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths firstObject];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"MyDatabase.db"];
    _db = [FMDatabase databaseWithPath:dbPath];
    _tableName = @"myCheck";
    return self;
}
//创建表
-(BOOL)createTable{
    if ([_db open]) {
        NSString *sqlCreateTable =  @"CREATE TABLE IF NOT EXISTS myCheck (ID INTEGER PRIMARY KEY AUTOINCREMENT,DATE TEXT,KINDS TEXT,PRICE TEXT,NOTE TEXT,PICTURE BLOB)";
        BOOL result = [_db executeUpdate:sqlCreateTable];
        
        if (!result) {
            NSLog(@"error when creating db table");
        } else {
            NSLog(@"success to creating db table");
        }
        [_db close];
    }
    return YES;
}
//把消费项目添加到数据库当中
-(BOOL)insertInfoToTableWithParameters:(NSDictionary *)parameters{
    if ([_db open]) {
        NSString *sqlInsertInfoToTable = @"INSERT INTO myCheck (DATE, KINDS, PRICE, NOTE,PICTURE) VALUES (?, ?, ?, ?, ?)";
        BOOL result = [_db executeUpdate:sqlInsertInfoToTable,
                       [parameters valueForKey:@"date"],
                       [parameters valueForKey:@"kinds"],
                       [parameters valueForKey:@"price"],
                       [parameters valueForKey:@"note"],
                       [parameters valueForKey:@"picture"]
                       ];
        if (!result) {
            NSLog(@"error when insert db table");
        } else {
            NSLog(@"success to insert db table");
        }
        [_db close];
    }
    return YES;
}
//根据ID查询数据
- (NSDictionary *)querywithID:(int)ID{
    NSMutableDictionary *infoOfID = [NSMutableDictionary dictionary];
    if ([_db open]) {
        NSString * sqlWithID = [NSString stringWithFormat:@"SELECT * FROM myCheck WHERE ID = %d",ID];
        FMResultSet * result = [_db executeQuery:sqlWithID];
        [infoOfID setValue:[result stringForColumn:@"ID"] forKey:@"id"];
        [infoOfID setValue:[result stringForColumn:@"DATE"] forKey:@"date"];
        [infoOfID setValue:[result stringForColumn:@"KINDS"] forKey:@"kinds"];
        [infoOfID setValue:[result stringForColumn:@"PRICE"] forKey:@"price"];
        [infoOfID setValue:[result stringForColumn:@"NOTE"] forKey:@"note"];
        [infoOfID setValue:[result dataForColumn:@"PICTURE"] forKey:@"picture"];
        [_db close];
    }
    return infoOfID;
}
//查询全部数据
- (NSMutableArray *)queryAll{
    NSMutableArray *checkAll = [NSMutableArray array];
    if ([_db open]) {
        NSString * sqlQueryAll = [NSString stringWithFormat:@"SELECT * FROM myCheck"];
        FMResultSet * result = [_db executeQuery:sqlQueryAll];
        while ([result next]) {
            NSMutableDictionary *someoneDic = [NSMutableDictionary dictionary];
            
            [someoneDic setValue:[result stringForColumn:@"ID"] forKey:@"id"];
            [someoneDic setValue:[result stringForColumn:@"DATE"] forKey:@"date"];
            [someoneDic setValue:[result stringForColumn:@"KINDS"] forKey:@"kinds"];
            [someoneDic setValue:[result stringForColumn:@"PRICE"] forKey:@"price"];
            [someoneDic setValue:[result stringForColumn:@"NOTE"] forKey:@"note"];
            [someoneDic setValue:[result dataForColumn:@"PICTURE"] forKey:@"picture"];
            [checkAll addObject:someoneDic];
        }
        [_db close];
    }
    return checkAll;
}
//根据ID删除数据
- (BOOL)deleteTableDatawithID:(int)ID{
    if ([_db open]) {
        
        NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM myCheck WHERE ID = %ld",(long)ID];
        BOOL res = [_db executeUpdate:deleteSql];
        
        if (res) {
            NSLog(@"删除ID:%d成功",ID);
            [_db close];
            return YES;
        }else {
            NSLog(@"删除ID:%d失败",ID);
            [_db close];
        }
        
    }
    return NO;
}
//根据id修改数据
-(BOOL)editTableDataWithID:(NSDictionary *)dicInfo{
    if ([_db open]) {
        NSString *editSql = [NSString stringWithFormat:@"UPDATE myCheck SET DATE = ?,KINDS = ?,PRICE = ?,NOTE = ?,PICTURE = ? WHERE ID = %d",[dicInfo[@"id"]intValue]];
        BOOL isSuccess = [_db executeUpdate:editSql,
                          dicInfo[@"date"],
                          dicInfo[@"kinds"],
                          dicInfo[@"price"],
                          dicInfo[@"note"],
                          dicInfo[@"picture"]
                          ];
        if (isSuccess) {
            [_db close];
            return YES;
        }else{
            [_db close];
        }
    }
    return NO;
}
@end
