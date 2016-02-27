//
//  AOAMainViewController.h
//  DescargasSegundoPlano
//
//  Created by Akixe on 27/2/16.
//  Copyright © 2016 AOA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AOAMainViewController : UIViewController <NSURLSessionDownloadDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitiView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) void (^sessionCompletionHandler)(void);
@end
