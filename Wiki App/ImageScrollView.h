//
//  ImageScrollView.h
//  Wiki App
//
//  Created by Chloe Stars on 4/24/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageScrollView : UIScrollView {
    IBOutlet UIImageView *tileContainerView;
    CGPoint originalImagePos;
}

@end
