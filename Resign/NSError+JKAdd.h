//
//  NSError+JKAdd.h
//  Resign
//
//  Created by ryan on 15/12/21.
//  Copyright © 2015年 ryan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JKErrorCode){
    JKErrorCodeDefault = -100
};

extern NSString *const JKDomain;

@interface NSError (JKAdd)

+ (NSError *)errorWithReason:(NSString *)reason;

@end
