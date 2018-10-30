#ifndef AssetLoaderDelegate_h
#define AssetLoaderDelegate_h

//
//  AssetLoaderDelegate.h
//  TimeTag
//
//  Created by Renjith N on 23/02/15.
//  Copyright (c) 2015 MBP1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AssetLoaderDelegate : NSObject <AVAssetResourceLoaderDelegate,NSURLConnectionDelegate>

@property (nonatomic, strong) NSMutableData *movieData;
@property (nonatomic, strong) NSURLConnection *connection;

@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSMutableArray *pendingRequests;

@property (nonatomic, strong) NSMutableArray *chunks;

@property (nonatomic,strong) NSString *cacheDir;
@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) NSString *fileUrl;

+ (NSString*) preViewFoundInCacheDirectory:(NSString*) url;
- (id)init;

@end

#endif /* AssetLoaderDelegate_h */
