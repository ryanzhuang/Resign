//
//  ReCodeSignHelper.h
//  ReCodeSign
//
//  Created by ryan on 15/12/18.
//  Copyright © 2015年 ryan. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kNotificationLogComing;

typedef void (^SignCompletedBlock) (NSError *error);

@interface ReSignHelper : NSObject

+ (void)startReCodeSign:(SignCompletedBlock)block;

+ (NSArray *)getCertifications;

@end
