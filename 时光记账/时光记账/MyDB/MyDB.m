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

+(MyDB*)sharedDBManager{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedDB = [[MyDB alloc]init];
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
        NSString *sqlCreateTable =  @"CREATE TABLE IF NOT EXISTS myCheck (ID INTEGER PRIMARY KEY AUTOINCREMENT,DATE TEXT,KINDS TEXT,PRICE TEXT,NOTE TEXT,CONSUMPTIONIMG BLOB)";
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
        NSString *sqlInsertInfoToTable = @"INSERT INTO myCheck (DATE, KINDS, PRICE, NOTE, CONSUMPTIONIMG) VALUES (?, ?, ?, ?, ?)";
        BOOL result = [_db executeUpdate:sqlInsertInfoToTable,
                       [parameters objectForKey:@"date"],
                       [parameters objectForKey:@"kinds"],
                       [parameters objectForKey:@"price"],
                       [parameters objectForKey:@"note"],
                       [parameters objectForKey:@"consumptionimg"]
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
- (NSDictionary *)querywithID:(NSInteger )ID{
    NSMutableDictionary *infoOfID = [NSMutableDictionary dictionary];
    if ([_db open]) {
        NSString * sqlWithID = [NSString stringWithFormat:@"SELECT * FROM myCheck WHERE ID = %ld",ID];
        FMResultSet * result = [_db executeQuery:sqlWithID];
        [infoOfID setObject:[result stringForColumn:@"ID"] forKey:@"id"];
        [infoOfID setObject:[result dataForColumn:@"DATE"] forKey:@"date"];
        [infoOfID setObject:[result stringForColumn:@"KINDS"] forKey:@"kinds"];
        [infoOfID setObject:[result stringForColumn:@"PRICE"] forKey:@"price"];
        [infoOfID setObject:[result stringForColumn:@"NOTE"] forKey:@"note"];
        [infoOfID setObject:[result stringForColumn:@"CONSUMPTIONIMG"] forKey:@"consumptionimg"];
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
            NSMutableDictionary *peopleDic = [NSMutableDictionary dictionary];
            
            [peopleDic setObject:[result stringForColumn:@"ID"] forKey:@"id"];
            [peopleDic setObject:[result dataForColumn:@"DATE"] forKey:@"date"];
            [peopleDic setObject:[result stringForColumn:@"KINDS"] forKey:@"kinds"];
            [peopleDic setObject:[result stringForColumn:@"PRICE"] forKey:@"price"];
            [peopleDic setObject:[result stringForColumn:@"NOTE"] forKey:@"note"];
            [peopleDic setObject:[result stringForColumn:@"CONSUMPTIONIMG"] forKey:@"consumptionimg"];
            
            [checkAll addObject:peopleDic];
        }
        [_db close];
    }
    return checkAll;
}
@end
