//
//  UserDefault.h
//  Resign
//
//  Created by ryan on 15/12/21.
//  Copyright © 2015年 ryan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefault : NSObject

@property (nonatomic, copy) NSString *inputPath;
@property (nonatomic, copy) NSString *outPath;
@property (nonatomic, copy) NSString *provisionPath;
@property (nonatomic, copy) NSString *certificationName;

+ (UserDefault *)userDefault;

@end
