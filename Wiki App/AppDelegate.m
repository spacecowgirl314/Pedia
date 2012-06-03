//
//  AppDelegate.m
//  Wiki App
//
//  Created by Chloe Stars on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ArticleViewController.h"
#import <CoreData/CoreData.h>

#define IOS_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define IOS_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IOS_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define IOS_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [TestFlight takeOff:@"753c33637a2c1537937bccda8bf49ec8_MTcyODAyMDEyLTA0LTIyIDE1OjU5OjIzLjc4NDIxNg"];
    // do remove this before uploading. this is a violation of app store policy using the UDID
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
    }

    return YES;
}

// load the article from the pedia url scheme
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (!url) {  return NO; }
    
    // pass the title of the current item to the app to be loaded as the next article
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_async(queue,^{
        // wait abit so that the observer exists
        sleep(1);
        [[NSNotificationCenter defaultCenter] 
         postNotificationName:@"gotoArticle" 
         object:[url host]];
    });

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data Stack -

- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil)
    {
        if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
            NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            
            [moc performBlockAndWait:^{
                [moc setPersistentStoreCoordinator: coordinator];
                
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
            }];
            __managedObjectContext = moc;
        } else {
            __managedObjectContext = [[NSManagedObjectContext alloc] init];
            [__managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
        
    }
    return __managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"History" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	
    return __managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"History.sqlite"];
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    
    NSPersistentStoreCoordinator* psc = __persistentStoreCoordinator;
    
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            // Migrate datamodel
            NSDictionary *options = nil;
            
            // this needs to match the entitlements and provisioning profile
            NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil];
            NSString* coreDataCloudContent = [[cloudURL path] stringByAppendingPathComponent:@"data"];
            if ([coreDataCloudContent length] != 0) {
                // iCloud is available
                cloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
                
                options = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                           [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                           @"Pedia.store", NSPersistentStoreUbiquitousContentNameKey,
                           cloudURL, NSPersistentStoreUbiquitousContentURLKey,
                           nil];
            } else {
                // iCloud is not available
                options = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                           [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                           nil];
            }
            
            NSError *error = nil;
            [psc lock];
            if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
            {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            [psc unlock];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"asynchronously added persistent store!");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RefetchAllDatabaseData" object:self userInfo:nil];
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                HistoryViewController *historyViewController = (HistoryViewController *)[HistoryViewController sharedInstance];
                NSNotification *notification = [NSNotification notificationWithName:@"RefetchAllDatabaseData" object:nil];
                [historyViewController reloadFetchedResults:notification];
                }
            });
            
        });
        
    } else {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                 nil];
        
        NSError *error = nil;
        if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return __persistentStoreCoordinator;
}

#pragma mark - Documents Directory -

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)mergeiCloudChanges:(NSNotification*)note forContext:(NSManagedObjectContext*)moc {
    [moc mergeChangesFromContextDidSaveNotification:note]; 
    NSLog(@"Hi. I'm iCloud");
    
    NSNotification* refreshNotification = [NSNotification notificationWithName:@"RefreshAllViews" object:self  userInfo:[note userInfo]];
    
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        NSLog(@"iCloud thing");
        HistoryViewController *historyViewController = (HistoryViewController *)[HistoryViewController sharedInstance];
        NSNotification *notification = [NSNotification notificationWithName:@"RefetchAllViews" object:nil];
        [historyViewController reloadTableView:notification];
    }
}

// NSNotifications are posted synchronously on the caller's thread
// make sure to vector this back to the thread we want, in this case
// the main thread for our views & controller
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification {
    NSManagedObjectContext* moc = [self managedObjectContext];
    
    // this only works if you used NSMainQueueConcurrencyType
    // otherwise use a dispatch_async back to the main thread yourself
    [moc performBlock:^{
        [self mergeiCloudChanges:notification forContext:moc];
    }];
}

@end
