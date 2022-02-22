//
//  AppDelegate.m
//  CLPhotoCropDemo
//
//  Created by 雷玉宇 on 2022/2/21.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _window = [[UIWindow alloc] init];
    _window.frame = [UIScreen mainScreen].bounds;
    _window.rootViewController = [[ViewController alloc] init];
    [_window makeKeyAndVisible];
    
    return YES;
}


@end
