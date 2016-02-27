//
//  AOAMainViewController.m
//  DescargasSegundoPlano
//
//  Created by Akixe on 27/2/16.
//  Copyright © 2016 AOA. All rights reserved.
//

#import "AOAMainViewController.h"

@interface AOAMainViewController ()

@property (strong, nonatomic) NSURL * spawnURL;
@property (strong, nonatomic) NSURL * clownURL;


@property (strong, nonatomic) NSURLSession * downloadSession;
@property (strong, nonatomic) NSURLSession * backgroundDownloadSession;

@property (strong, nonatomic) NSOperationQueue *delegateQueue;

@end

@implementation AOAMainViewController

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [self setupButtons];
    
    self.spawnURL= [NSURL URLWithString:@"http://static.comicvine.com/uploads/original/11117/111178572/4688458-2787111141-spawn.jpg"];
    self.clownURL= [NSURL URLWithString:@"http://static.comicvine.com/uploads/original/6/67602/3289224-47.jpg"];
    
    [self setupDownloadSession];
    [self setupBackgroundDownloadSession];
    
    self.delegateQueue = [[NSOperationQueue alloc] init];
}

#pragma mark - Actions
- (void) crashApp: (id) sender {
    [self performSelector:@selector(sayonaraBaby)
               withObject:nil];
}

- (void) download :(id) sender{
    [self cleanupUI];
    
    NSURLSessionDownloadTask *task = [self.downloadSession downloadTaskWithURL:self.clownURL];
    [task resume];
}

- (void) downloadInBackground : (id) sender {
    NSURLSessionDownloadTask *task = [self.backgroundDownloadSession downloadTaskWithURL:self.spawnURL];
    [task resume];
    
}

#pragma mark - utils


- (void) cleanupUI {
    self.imageView.image = nil;
    self.progressView.progress = 0.0f;
    [self.activitiView startAnimating];
}

- (float) progressWithBytesSoFar: (int64_t)soFar
              totalExpectedBytes: (int64_t) totalBytes {
    return (soFar *1.0f)/(totalBytes*1.0);
}

- (void) setupDownloadSession {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    self.downloadSession = [NSURLSession sessionWithConfiguration:configuration
                                                         delegate:self
                                                    delegateQueue:self.delegateQueue];
}

- (void) setupBackgroundDownloadSession {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"me.aoa.descargas.spawn"];
    
    self.backgroundDownloadSession = [NSURLSession sessionWithConfiguration:configuration
                                                         delegate:self
                                                    delegateQueue:self.delegateQueue];
   
    
}

- (void) setupButtons {
    
    UIBarButtonItem * crashApp = [[UIBarButtonItem alloc]initWithTitle:@"Crash me!"
                                                                 style:UIBarButtonItemStylePlain
                                                                target: self
                                                                action: @selector(crashApp:)];
    
    UIBarButtonItem * foregroundDownload = [[UIBarButtonItem alloc]initWithTitle:@"Download"
                                                                 style:UIBarButtonItemStylePlain
                                                                target: self
                                                                action: @selector(download:)];
    
    UIBarButtonItem * backgroundDownload = [[UIBarButtonItem alloc]initWithTitle:@"Background Download!"
                                                                 style:UIBarButtonItemStylePlain
                                                                target: self
                                                                action: @selector(downloadInBackground:)];
    
    [self.navigationItem setLeftBarButtonItem: crashApp];
    [self.navigationItem setRightBarButtonItems: @[foregroundDownload, backgroundDownload]];
    
}


#pragma mark  - NSURLSessionDownloadDelegate
- (void) URLSession: (NSURLSession *) session
       downloadTask:(NSURLSessionDownloadTask *)downloadTask
       didWriteData:(int64_t)bytesWritten
  totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = [self progressWithBytesSoFar:totalBytesWritten
                                               totalExpectedBytes:totalBytesExpectedToWrite];
    });
}

- (void) URLSession:(NSURLSession *)session
       downloadTask:(NSURLSessionDownloadTask *)downloadTask
didResumeAtOffset:(int64_t)fileOffset
 expectedTotalBytes:(int64_t)expectedTotalBytes {
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = [self progressWithBytesSoFar:fileOffset
                                               totalExpectedBytes:expectedTotalBytes];

    });
}


-(void) URLSession:(NSURLSession *)session
      downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(nonnull NSURL *)location {
    
    
    NSData *data = [NSData dataWithContentsOfURL:location];
    UIImage *image = [UIImage imageWithData:data];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
        [self.activitiView stopAnimating];
    });
}

- (void) URLSession:(NSURLSession *)session
               task:(nonnull NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    if (error){
        NSLog(@"Error en sesión: %@ \n %@", session, error );
    } else {
        NSLog(@"Session %@ finished", session);
        
        if(self.sessionCompletionHandler){
            self.sessionCompletionHandler();
        }
    }
}
@end
