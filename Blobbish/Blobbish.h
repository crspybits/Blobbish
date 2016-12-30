//
//  Blobbish.h
//  Blobbish
//
//  Created by Christopher Prince on 12/29/16.
//  Copyright © 2016 Spastic Muffin, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AZSClient/AZSClient.h>

@interface Blobbish : NSObject

// Check the error in the completion handler. If it's nil, you're good to go to call other methods of this class.
- (instancetype) initWithCompletion: (void (^)(NSError *))completion;

// Get a list of blobs
- (void) getNextBlobs: (NSInteger) maxNumberBlobs withCompletion:
        (void (^)(NSArray<AZSCloudBlob *> *blobs, NSError *error)) completion;

- (void) uploadBlob: (NSString *) blobName fromText:(NSString *) text completion: (void (^)(NSError *)) completion;

- (void) uploadBlob: (NSString *) blobName fromData:(NSData *) data completion: (void (^)(NSError *)) completion;

- (void) deleteBlob: (AZSCloudBlob *) blob completion: (void (^)(NSError *error)) completion;

@end
