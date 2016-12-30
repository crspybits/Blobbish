//
//  Blobbish.m
//  Blobbish
//
//  Created by Christopher Prince on 12/29/16.
//  Copyright © 2016 Spastic Muffin, LLC. All rights reserved.
//

#import "Blobbish.h"

// This assumes the non-Sas style of access on Azure
static NSString *accountKey = @"<YourAccountKeyHere>";
static NSString *accountName = @"<YourAccountNameHere>";
static NSString *connectionStringFormat = @"DefaultEndpointsProtocol=https;AccountName=%@;AccountKey=%@";
static NSString *containerName = @"<YourContainerNameHere>";

@interface Blobbish()
@property (nonatomic, strong) AZSCloudBlobContainer *container;
@property (nonatomic, strong) AZSContinuationToken *continuationToken;
@end

@implementation Blobbish

- (instancetype) initWithCompletion: (void (^)(NSError *))completion;
{
    self = [super init];
    if (self) {
        NSString *connectionString = [NSString stringWithFormat:connectionStringFormat, accountName, accountKey];
        NSError *error = nil;
        AZSCloudStorageAccount *storageAccount = [AZSCloudStorageAccount accountFromConnectionString:connectionString error:&error];
        if (error) {
            completion(error);
        }
        else {
            AZSCloudBlobClient *blobClient = [storageAccount getBlobClient];
            self.container = [blobClient containerReferenceFromName:containerName];
            
            [self.container createContainerIfNotExistsWithCompletionHandler:
                ^(NSError *error, BOOL created) {
                
                if (!error) {
                    NSString *notCreated = @"";
                    if (!created) {
                        notCreated = @"not ";
                    }
                    
                    NSLog(@"Container was %@created.", notCreated);
                }
                completion(error);
            }];
        }
    }
    
    return self;
}

- (void) getNextBlobs: (NSInteger) maxNumberBlobs withCompletion:
        (void (^)(NSArray<AZSCloudBlob *> *blobs, NSError *error)) completion;
{
    [self.container listBlobsSegmentedWithContinuationToken:self.continuationToken prefix:nil useFlatBlobListing:YES blobListingDetails:AZSBlobListingDetailsNone maxResults:maxNumberBlobs completionHandler:^(NSError *error, AZSBlobResultSegment *resultSegment) {
        
        NSArray<AZSCloudBlob *> *blobs = nil;
        if (!error) {
            blobs = resultSegment.blobs;
            self.continuationToken = resultSegment.continuationToken;
        }
        
        completion(blobs, error);
    }];
}

- (void) deleteBlob: (AZSCloudBlob *) blob completion: (void (^)(NSError *error)) completion;
{
    [blob deleteWithCompletionHandler:^(NSError *error) {
        completion(error);
    }];
}

- (void) uploadBlob: (NSString *) blobName fromText:(NSString *) text completion: (void (^)(NSError *)) completion;
{
    AZSCloudBlockBlob *blob = [self.container blockBlobReferenceFromName:blobName];

    if (blob) {
        [blob uploadFromText:text completionHandler:^(NSError *error) {
            completion(error);
        }];
    }
    else {
        NSError *error = [[NSError alloc] initWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Could not obtain reference to blob"}];
        completion(error);
    }
}

- (void) uploadBlob: (NSString *) blobName fromData:(NSData *) data completion: (void (^)(NSError *)) completion;
{
    AZSCloudBlockBlob *blob = [self.container blockBlobReferenceFromName:blobName];
    
    if (blob) {
        [blob uploadFromData:data completionHandler:^(NSError *error) {
            completion(error);
        }];
    }
    else {
        NSError *error = [[NSError alloc] initWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Could not obtain reference to blob"}];
        completion(error);
    }
}


@end
