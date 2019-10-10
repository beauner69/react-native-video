//
//  AssetLoaderDelegate.m
//  TimeTag
//
//  Created by Renjith N on 23/02/15.
//  Copyright (c) 2015 MBP1. All rights reserved.
//

#import "AssetLoaderDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ChunkLoader.h"


@implementation AssetLoaderDelegate


- (id)init{
    NSLog(@"FUDGE init this fucker");
    if (self = [super init]) {
        self.cacheDir = [AssetLoaderDelegate cacheDirectory];
        self.pendingRequests = [NSMutableArray array];
        NSLog(@"FUDGE cache = %@",self.cacheDir);
    }
    return self;
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"FUDGE - connected");
    self.movieData = [NSMutableData data];
    self.response = (NSHTTPURLResponse *)response;
    [self processPendingRequests];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
//    NSLog(@"FUDGE - two");
    [self.movieData appendData:data];
    [self processPendingRequests];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    NSLog(@"FUDGE - three");

    [self processPendingRequests];
    NSLog(@"FUDGE Download complete");
    NSString *fileName = [NSURL URLWithString:self.fileUrl].absoluteString.lastPathComponent;
    NSString *cachedFilePath = [[NSString alloc] initWithFormat:@"%@/%@",self.cacheDir,[fileName componentsSeparatedByString:@"?"].firstObject];
    BOOL writen = [self.movieData writeToFile:cachedFilePath atomically:YES];
    if(!writen){
        NSLog(@"FUDGE Error writing cache, what a surprise");
        
    }
}

#pragma mark - AVURLAsset resource loading

- (void)processPendingRequests{
//    NSLog(@"FUDGE - four");

    NSLog(@"FUDGE processPendingRequests:%lu",(unsigned long)self.pendingRequests.count);
    NSMutableArray *requestsCompleted = [NSMutableArray array];
    
    for (AVAssetResourceLoadingRequest *loadingRequest in self.pendingRequests){
        [self fillInContentInformation:loadingRequest.contentInformationRequest];
        
        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest.dataRequest];
        
        if (didRespondCompletely){
            [requestsCompleted addObject:loadingRequest];
            
            [loadingRequest finishLoading];
        }
    }
    
    [self.pendingRequests removeObjectsInArray:requestsCompleted];
}

- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest{
//    NSLog(@"FUDGE - five");

    if (contentInformationRequest == nil || self.response == nil){
        return;
    }
    
    NSString *mimeType = [self.response MIMEType];
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    
    contentInformationRequest.byteRangeAccessSupported = YES;
    contentInformationRequest.contentType = CFBridgingRelease(contentType);
    contentInformationRequest.contentLength = [self.response expectedContentLength];
}

- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingDataRequest *)dataRequest{
//    NSLog(@"FUDGE - six");

    long long startOffset = dataRequest.requestedOffset;
    if (dataRequest.currentOffset != 0){
        startOffset = dataRequest.currentOffset;
    }
    
    // Don't have any data at all for this request
    if (self.movieData.length < startOffset){
        return NO;
    }
    
    // This is the total data we have from startOffset to whatever has been downloaded so far
    NSUInteger unreadBytes = self.movieData.length - (NSUInteger)startOffset;
    // Respond with whatever is available if we can't satisfy the request fully yet
    NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)dataRequest.requestedLength, unreadBytes);
    
    NSLog(@"FUDGE data:%lu,,,(%lld,%lu)",(unsigned long)self.movieData.length,startOffset,(unsigned long)numberOfBytesToRespondWith);
    [dataRequest respondWithData:[self.movieData subdataWithRange:NSMakeRange((NSUInteger)startOffset, numberOfBytesToRespondWith)]];
    
    long long endOffset = startOffset + dataRequest.requestedLength;
    BOOL didRespondFully = self.movieData.length >= endOffset;
    
    return didRespondFully;
}

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSLog(@"FUDGEPACK - Request Made - %i %i",loadingRequest.dataRequest.requestedOffset,loadingRequest.dataRequest.requestedLength);
    
    // NEW SHIT
    ChunkLoader * loader = [[ChunkLoader alloc] init];
    [loader LoadChunk: [NSURL URLWithString:self.fileUrl] startAt:loadingRequest.dataRequest.requestedOffset loadBytes:loadingRequest.dataRequest.requestedLength resource:loadingRequest];
    [self.chunks addObject:loader];
    return YES;
    
    
    // OLD SHIT
    
    

//    if (self.connection == nil){
//        NSURL *interceptedURL = [loadingRequest.request URL];
//        NSURLComponents *actualURLComponents = [[NSURLComponents alloc] initWithURL:interceptedURL resolvingAgainstBaseURL:NO];
//        actualURLComponents.scheme = @"https";
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.fileUrl]];
//        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
//        [self.connection setDelegateQueue:[NSOperationQueue mainQueue]];
//        [self.connection start];
//    }
//
//    NSLog(@"FUDGE SWFLORR pendingRequests:%@",loadingRequest);
//    [self.pendingRequests addObject:loadingRequest];
//    [self processPendingRequests];
//    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
//    NSLog(@"FUDGE - eight");
    [self.pendingRequests removeObject:loadingRequest];
}

+ (NSString*) preViewFoundInCacheDirectory:(NSString*) url{
//    NSLog(@"FUDGE - nine");

    NSString *fileName = [NSURL URLWithString:url].absoluteString.lastPathComponent;
    
    NSString *cachedFilePath = [[NSString alloc] initWithFormat:@"%@/%@",[AssetLoaderDelegate cacheDirectory],[fileName componentsSeparatedByString:@"?"].firstObject];
    if([[NSFileManager defaultManager] fileExistsAtPath:cachedFilePath]){
        return cachedFilePath;
    }
    else{
        return nil;
    }
}

+ (NSString *)cacheDirectory{
//    NSLog(@"FUDGE - ten");

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDir = [paths objectAtIndex:0];
    NSString *videoCacheDir = [NSString stringWithFormat:@"%@/%@",cacheDir,@"Previews"];
    
    BOOL isDir = NO;
    NSError *error;
    if (! [[NSFileManager defaultManager] fileExistsAtPath:videoCacheDir isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:videoCacheDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return videoCacheDir;
}

@end
