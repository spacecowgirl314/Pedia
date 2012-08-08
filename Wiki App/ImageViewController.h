//
//  ImageViewController.h
//  Pedia
//
//  Created by Chloe Stars on 5/11/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDownloadBar.h"
#import "ImageScrollView.h"

@interface ImageViewController : UIViewController <UIScrollViewDelegate, UIDownloadBarDelegate, ImageScrollViewDelegate> {
    IBOutlet ImageScrollView *scrollView;
    IBOutlet UIImageView *imageView;
    UIDownloadBar *imageBar;
    UILabel *titleLabel;
    BOOL imageIsDownloaded;
    BOOL imageIsVector;
}

- (void)imageLoadWithName:(NSString*)name;

@property (nonatomic, retain) IBOutlet ImageScrollView *scrollView;

@end
