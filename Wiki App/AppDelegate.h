//
//  AppDelegate.h
//  Wiki App
//
//  Created by Chloe Stars on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectContext *archiveManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *archiveManagedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *archivePersistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectContext *wikiManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *wikiManagedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *wikiPersistentStoreCoordinator;

@end
