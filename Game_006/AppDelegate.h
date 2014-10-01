//
//  AppDelegate.h
//  Game_006
//
//  Created by 寺内 信夫 on 2014/10/01.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{

	EKCalendar *calendar;
	
}

@property (strong, nonatomic) UIWindow *window;

@end
