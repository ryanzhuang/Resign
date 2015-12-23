//
//  MainWindow.m
//  Resign
//
//  Created by ryan on 15/12/21.
//  Copyright © 2015年 ryan. All rights reserved.
//

#import "MainWindow.h"
#import "UserDefault.h"
#import "ReSignHelper.h"

@interface MainWindow ()<NSComboBoxDataSource, NSComboBoxDelegate>

@property (weak) IBOutlet NSTextField *inputPathField;
@property (weak) IBOutlet NSTextField *outputField;
@property (weak) IBOutlet NSTextField *provisionField;
@property (weak) IBOutlet NSButton *resignButton;
@property (weak) IBOutlet NSProgressIndicator *indicator;
@property (weak) IBOutlet NSComboBox *cerComboBox;
@property (nonatomic, strong) NSArray *certifications;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;

@end

@implementation MainWindow

- (void)windowDidLoad {
    [super windowDidLoad];
    
    @try {
        _inputPathField.stringValue = [UserDefault userDefault].inputPath;
        _outputField.stringValue = [UserDefault userDefault].outPath;
        _provisionField.stringValue = [UserDefault userDefault].provisionPath;
    }
    @finally {
        
    }
    
    _certifications = [ReSignHelper getCertifications];
    [_cerComboBox reloadData];
    
    NSInteger index = [_certifications indexOfObject:[UserDefault userDefault].certificationName];
    if (index != NSNotFound) {
        [_cerComboBox selectItemAtIndex:index];
    }
    
    _resignButton.hidden = NO;
    _indicator.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLog:) name:kNotificationLogComing object:nil];
}

- (void)handleLog:(NSNotification *)notification
{
    NSFileHandle *fileHandle = notification.object;
    NSString *string = [[NSString alloc] initWithData:fileHandle.availableData encoding:NSUTF8StringEncoding];
    _logTextView.string = [NSString stringWithFormat:@"%@%@",_logTextView.string,string];
}

- (void)clean
{
    _logTextView.string = @"";
}

- (IBAction)chooseInputPath:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setTitle:_inputPathField.placeholderString];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[@"app"]];
    NSInteger index = [panel runModal];
    if (index == NSModalResponseOK) {
        NSURL *fileURL = [panel URL];
        _inputPathField.stringValue = fileURL.relativePath;
        [UserDefault userDefault].inputPath = fileURL.relativePath;
    }
}

- (IBAction)chooseOutputPath:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setTitle:_outputField.placeholderString];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    NSInteger index = [panel runModal];
    if (index == NSModalResponseOK) {
        NSURL *fileURL = [panel URL];
        _outputField.stringValue = fileURL.relativePath;
        [UserDefault userDefault].outPath = fileURL.relativePath;
    }
}

- (IBAction)chooseProvisingPath:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setTitle:_provisionField.placeholderString];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[@"mobileprovision", @"MOBILEPROVISION"]];
    NSInteger index = [panel runModal];
    if (index == NSModalResponseOK) {
        NSURL *fileURL = [panel URL];
        _provisionField.stringValue = fileURL.relativePath;
        [UserDefault userDefault].provisionPath = fileURL.relativePath;
    }
}

- (IBAction)resign:(id)sender {
    [self clean];
    _resignButton.hidden = YES;
    _indicator.hidden = NO;
    [_indicator startAnimation:_resignButton];
    [ReSignHelper startReCodeSign:^(NSError *error) {
        _resignButton.hidden = NO;
        _indicator.hidden = YES;
        [_indicator stopAnimation:_resignButton];
        if (error) {
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert runModal];
        } else {
//            [self close];
        }
    }];
}

#pragma mark - NSComboBox delegate
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return _certifications.count;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    return _certifications[index];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    NSComboBox *comboBox = notification.object;
    NSInteger index = [comboBox indexOfSelectedItem];
    [UserDefault userDefault].certificationName = _certifications[index];
}

@end
