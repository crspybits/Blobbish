//
//  ViewController.m
//  Blobbish
//
//  Created by Christopher Prince on 12/29/16.
//  Copyright © 2016 Spastic Muffin, LLC. All rights reserved.
//

#import "ViewController.h"
#import "Blobbish.h"

@interface ViewController ()
@property (nonatomic, strong) Blobbish *blobbish;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.blobbish = [[Blobbish alloc] initWithCompletion:^(NSError *error) {
        if (error) {
            NSLog(@"Error connecting to Azure: %@", error);
        }
        else {
            NSLog(@"Success connecting to Azure!");
        }
    }];
}

- (IBAction)listBlobs:(id)sender {
    [self.blobbish getNextBlobs:50 withCompletion:^(NSArray<AZSCloudBlob *> *blobs, NSError *error) {
        if (error) {
            NSLog(@"Error getting next blobs: %@", error);
        }
        else {
            for (AZSCloudBlob *blob in blobs) {
                NSLog(@"%@", blob.blobName);
            }
        }
    }];
}

- (IBAction)uploadBlob:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"meowsie" ofType:@"jpg"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    [self.blobbish uploadBlob:@"Cute cat photo" fromData:data completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error uploading: %@", error);
        }
        else {
            NSLog(@"Success uploading!");
        }
    }];
}

@end
