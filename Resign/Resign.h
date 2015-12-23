//
//  Resign.h
//  Resign
//
//  Created by ryan on 15/12/18.
//  Copyright © 2015年 ryan. All rights reserved.
//

#import <AppKit/AppKit.h>

@class Resign;

static Resign *sharedPlugin;

@interface Resign : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end