//
//  UserDefault.m
//  Resign
//
//  Created by ryan on 15/12/21.
//  Copyright © 2015年 ryan. All rights reserved.
//

#import "UserDefault.h"

@implementation UserDefault

NSString *const kJKResign = @"kJKResign";
NSString *const kProvisionPath = @"kProvision";
NSString *const KInputPath = @"KInputPath";
NSString *const kOutputPath = @"kOutputPath";
NSString *const kCertificationName = @"kCertificationName";

static UserDefault *_userDefault;

+ (UserDefault *)userDefault
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _userDefault = [[self alloc] init];
    });
    return _userDefault;
}

#pragma mark - private method

- (NSMutableDictionary *)jkResignDic
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:kJKResign];
    return dic.mutableCopy;
}

- (id)objectForKey:(NSString *)key
{
    NSDictionary *dic = [self jkResignDic];
    return dic[key];
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    NSMutableDictionary *dic = [self jkResignDic];
    if (dic == nil) {
        dic = [NSMutableDictionary new];
    }
    [dic setValue:object forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kJKResign];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - getter & setter
- (NSString *)inputPath
{
    return [self objectForKey:KInputPath] ? : @"";
}

- (void)setInputPath:(NSString *)inputPath
{
    [self setObject:inputPath forKey:KInputPath];
}

- (NSString *)outPath
{
    return [self objectForKey:kOutputPath] ? : @"";
}

- (void)setOutPath:(NSString *)outPath
{
    [self setObject:outPath forKey:kOutputPath];
}

- (NSString *)provisionPath
{
    return [self objectForKey:kProvisionPath] ? : @"";
}

- (void)setProvisionPath:(NSString *)provisionPath
{
    [self setObject:provisionPath forKey:kProvisionPath];
}

- (NSString *)certificationName
{
    return [self objectForKey:kCertificationName] ? : @"";
}

- (void)setCertificationName:(NSString *)certificationName
{
    [self setObject:certificationName forKey:kCertificationName];
}

@end
