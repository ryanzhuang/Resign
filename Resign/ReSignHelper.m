//
//  ReCodeSignHelper.m
//  ReCodeSign
//
//  Created by ryan on 15/12/18.
//  Copyright © 2015年 ryan. All rights reserved.
//

#import "ReSignHelper.h"
#import "Resign.h"
#import "UserDefault.h"
#import "NSError+JKAdd.h"

NSString *const kNotificationLogComing = @"logComming";

@interface ReSignHelper ()

@property (nonatomic, copy) SignCompletedBlock block;
@property (nonatomic, strong) NSTask *task;
@property (nonatomic, strong) NSTask *shellTask;
@property (nonatomic, strong) NSTask *codeSignTask;
@property (nonatomic, strong) UserDefault *userDefault;

@end

@implementation ReSignHelper

NSString *const kResignShellName = @"resign";
NSString *const kResourceRulesName = @"ResourceRules";

+ (void)startReCodeSign:(SignCompletedBlock)block
{
    ReSignHelper *helper = [[ReSignHelper alloc] init];
    helper.userDefault = [UserDefault userDefault];
    helper.block = block;
    [helper start];
}

+ (NSArray *)getCertifications
{
    NSTask *getCerTask = [[NSTask alloc] init];
    NSPipe *pie = [NSPipe pipe];
    [getCerTask setLaunchPath:@"/usr/bin/security"];
    [getCerTask setArguments:@[@"find-identity", @"-v", @"-p", @"codesigning"]];
    [getCerTask setStandardOutput:pie];
    [getCerTask setStandardError:pie];
    [getCerTask launch];
    [getCerTask waitUntilExit];
    
    NSFileHandle *fileHandle = [pie fileHandleForReading];
    NSString *securityResult = [[NSString alloc] initWithData:[fileHandle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
    // Verify the security result
    NSMutableArray *tempGetCertsResult = [NSMutableArray arrayWithCapacity:20];
    if (securityResult && securityResult.length > 0 && tempGetCertsResult.count > 0) {
        NSArray *rawResult = [securityResult componentsSeparatedByString:@"\""];
        for (int i = 0; i <= [rawResult count] - 2; i+=2) {
            if (rawResult.count - 1 < i + 1) {
                // Invalid array, don't add an object to that position
            } else {
                // Valid object
                [tempGetCertsResult addObject:[rawResult objectAtIndex:i+1]];
            }
        }
    }
    return tempGetCertsResult;
}

- (BOOL)validate:(NSError **)error
{
    if (self.userDefault.inputPath.length == 0) {
        *error = [NSError errorWithReason:@"缺少app目录"];
    }
    if (self.userDefault.outPath.length == 0) {
        *error = [NSError errorWithReason:@"缺少输出ipa目录"];
    }
    if (self.userDefault.provisionPath.length == 0) {
        *error = [NSError errorWithReason:@"缺少签名文件"];
    }
    if (self.userDefault.certificationName.length == 0) {
        *error = [NSError errorWithReason:@"缺少证书"];
    }
    return error != nil;
}

- (void)start
{
    NSError *error;
    [self validate:&error];
    if (!error) {
        NSString *inputFile = self.userDefault.inputPath;
        NSString *payloadPath = [self.userDefault.outPath stringByAppendingPathComponent:@"Payload"];
        NSFileManager *manager = [NSFileManager defaultManager];
        BOOL isDirectory;
        if ([manager fileExistsAtPath:payloadPath isDirectory:&isDirectory]) {
            [manager removeItemAtPath:payloadPath error:nil];
        }
        [manager createDirectoryAtPath:payloadPath withIntermediateDirectories:YES attributes:nil error:nil];
        [self.task setLaunchPath:@"/bin/cp"];
        [self.task setArguments:[NSArray arrayWithObjects:@"-r", inputFile, payloadPath, nil]];
        [self.task launch];
        [self.task waitUntilExit];
        [self initShell];
        [self codeSign];
        [self clean];
        if (_block) {
            _block(nil);
        }
    } else {
        if (_block) {
            _block(error);
        }
    }
}

- (void)codeSign
{
    NSString *resourceRulesArgument = [[Resign sharedPlugin].bundle pathForResource:kResourceRulesName
                                                                             ofType:@"plist"];
    [self.codeSignTask setLaunchPath:@"/bin/sh"];
    [self.codeSignTask setArguments:@[[self resignShellPath],
                                      self.userDefault.inputPath,
                                      self.userDefault.outPath,
                                      self.userDefault.provisionPath,
                                      self.userDefault.certificationName,
                                      [self appName],
                                      resourceRulesArgument]];
    [self.codeSignTask setCurrentDirectoryPath:self.userDefault.outPath];
    NSPipe *pie = [NSPipe pipe];
    [self.codeSignTask setStandardError:pie];
    [self.codeSignTask setStandardOutput:pie];
    [self.codeSignTask launch];
    [self.codeSignTask waitUntilExit];
    
    NSFileHandle *fileHandel = [pie fileHandleForReading];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLogComing object:fileHandel];
}

- (void)clean
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[self resignShellPath]]) {
        [fileManager removeItemAtPath:[self resignShellPath] error:nil];
    }
}

- (NSString *)appName
{
    NSArray *components = [self.userDefault.inputPath componentsSeparatedByString:@"/"];
    if (components.count > 0) {
        NSString *string = [components lastObject];
        NSArray *fileName = [string componentsSeparatedByString:@"."];
        if (fileName.count > 0) {
            return [fileName firstObject];
        }
    }
    return @"";
}

- (void)initShell
{
    NSString *shellPath = [[Resign sharedPlugin].bundle pathForResource:kResignShellName ofType:@"strings"];
    NSStringEncoding encoding;
    NSString *shellContent = [NSString stringWithContentsOfFile:shellPath usedEncoding:&encoding error:nil];
    NSString *shellOutputPath = [self resignShellPath];
    if (shellContent) {
        [[NSFileManager defaultManager] createFileAtPath:shellContent contents:nil attributes:nil];
        [shellContent writeToFile:shellOutputPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    [self.shellTask setLaunchPath:@"/bin/chmod"];
    [self.shellTask setArguments:@[@"+x",shellOutputPath]];
    [self.shellTask launch];
    [self.shellTask waitUntilExit];
}

- (void)alertError:(NSString *)error
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:error];
    [alert runModal];
}

#pragma mark - setter & getter
- (NSTask *)task
{
    if (_task == nil) {
        _task = [[NSTask alloc] init];
    }
    return _task;
}

- (NSTask *)shellTask
{
    if (_shellTask == nil) {
        _shellTask = [[NSTask alloc] init];
    }
    return _shellTask;
}

- (NSTask *)codeSignTask
{
    if (_codeSignTask == nil) {
        _codeSignTask = [[NSTask alloc] init];
    }
    return _codeSignTask;
}

- (NSString *)resignShellPath
{
    return [self.userDefault.outPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sh",kResignShellName]];
}

@end
