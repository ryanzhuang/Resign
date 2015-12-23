//
//  NSError+JKAdd.m
//  Resign
//
//  Created by ryan on 15/12/21.
//  Copyright © 2015年 ryan. All rights reserved.
//

#import "NSError+JKAdd.h"

NSString *const JKDomain = @"JK";

@implementation NSError (JKAdd)

+ (NSError *)errorWithReason:(NSString *)reason
{
    NSError *error = [[NSError alloc] initWithDomain:JKDomain
                                                code:JKErrorCodeDefault
                                            userInfo:@{NSLocalizedDescriptionKey :reason}];
    return error;
}

@end
