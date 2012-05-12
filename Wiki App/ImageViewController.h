//
//  ImageViewController.h
//  Pedia
//
//  Created by Chloe Stars on 5/11/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDownloadBar.h"

@interface ImageViewController : UIViewController <UIScrollViewDelegate, UIDownloadBarDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *imageView;
    UIDownloadBar *imageBar;
    UILabel *titleLabel;
}

- (void)imageLoadWithName:(NSString*)name;

@end
