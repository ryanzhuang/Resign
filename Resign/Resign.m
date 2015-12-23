//
//  Resign.m
//  Resign
//
//  Created by ryan on 15/12/18.
//  Copyright © 2015年 ryan. All rights reserved.
//

#import "Resign.h"
#import "MainWindow.h"

@interface Resign()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong) MainWindow *mainWindow;

@end

@implementation Resign

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[Resign alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    if (menuItem) {
        
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *resignMenu = [[NSMenuItem alloc] initWithTitle:@"Resign" action:@selector(resignAction) keyEquivalent:@"R"];
        [resignMenu setTarget:self];
        [resignMenu setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [[menuItem submenu] addItem:resignMenu];
    }
}

- (void)resignAction
{
    [self.mainWindow showWindow:nil];
    [self.mainWindow becomeFirstResponder];
}
// Sample Action, for menu item:
//- (void)doMenuAction
//{
//    NSAlert *alert = [[NSAlert alloc] init];
//    [alert setMessageText:@"Hello, World"];
//    [alert runModal];
//}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - setter & getter
- (MainWindow *)mainWindow
{
    if (_mainWindow == nil) {
        _mainWindow = [[MainWindow alloc] initWithWindowNibName:@"MainWindow"];
    }
    return _mainWindow;
}

@end
