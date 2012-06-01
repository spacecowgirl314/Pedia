//
//  GettingStartedViewController.h
//  Pedia
//
//  Created by Chloe Stars on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GettingStartedViewController : UIViewController <UIScrollViewDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    BOOL pageControlBeingUsed;
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;

@end
