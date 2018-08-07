//
//  AppDelegate.h
//  JSBinding
//
//  Created by huanglongshan on 2018/8/4.
//  Copyright © 2018年 huanglongshan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

