//
//  ChunkAssetLoaderDelegate.m
//  RCTVideo
//

#import <Foundation/Foundation.h>


#import "ChunkAssetLoaderDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation ChunkAssetLoaderDelegate

-(id) initWithUrl:(NSURL *)url {
    /*
     Initialise
     
     Get started straight away by loading in chunk number zero;
     */
    
    NSLog(@"FUDGE init this fucker");
    if (self = [super init]) {
        _chunks = [NSMutableArray array];
        _hunkLoads = [NSMutableArray array];
        _dataRequests = [NSMutableArray array];
        
        _fileUrl = url;
        
        SingleChunk * chunk0 = [[SingleChunk alloc] initWithIndex:0];
        [_chunks addObject:chunk0];
        chunk0.state = WANTED;
        
        [self startLoadingWantedChunks];
    }
    return self;
}


//#pragma mark - AVURLAsset resource loading
//
//- (void)processPendingRequests{
//    //    NSLog(@"FUDGE - four");
//    
//    NSLog(@"FUDGE processPendingRequests:%lu",(unsigned long)self.pendingRequests.count);
//    NSMutableArray *requestsCompleted = [NSMutableArray array];
//    
//    for (AVAssetResourceLoadingRequest *loadingRequest in self.pendingRequests){
//        [self fillInContentInformation:loadingRequest.contentInformationRequest];
//        
//        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest.dataRequest];
//        
//        if (didRespondCompletely){
//            [requestsCompleted addObject:loadingRequest];
//            
//            [loadingRequest finishLoading];
//        }
//    }
//    
//    [self.pendingRequests removeObjectsInArray:requestsCompleted];
//}
//
//- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest{
//    //    NSLog(@"FUDGE - five");
//    
//    if (contentInformationRequest == nil || self.response == nil){
//        return;
//    }
//    
//    NSString *mimeType = [self.response MIMEType];
//    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
//    
//    contentInformationRequest.byteRangeAccessSupported = YES;
//    contentInformationRequest.contentType = CFBridgingRelease(contentType);
//    contentInformationRequest.contentLength = [self.response expectedContentLength];
//}
//
//- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingDataRequest *)dataRequest{
//    //    NSLog(@"FUDGE - six");
//    
//    long long startOffset = dataRequest.requestedOffset;
//    if (dataRequest.currentOffset != 0){
//        startOffset = dataRequest.currentOffset;
//    }
//    
//    // Don't have any data at all for this request
//    if (self.movieData.length < startOffset){
//        return NO;
//    }
//    
//    // This is the total data we have from startOffset to whatever has been downloaded so far
//    NSUInteger unreadBytes = self.movieData.length - (NSUInteger)startOffset;
//    // Respond with whatever is available if we can't satisfy the request fully yet
//    NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)dataRequest.requestedLength, unreadBytes);
//    
//    NSLog(@"FUDGE data:%lu,,,(%lld,%lu)",(unsigned long)self.movieData.length,startOffset,(unsigned long)numberOfBytesToRespondWith);
//    [dataRequest respondWithData:[self.movieData subdataWithRange:NSMakeRange((NSUInteger)startOffset, numberOfBytesToRespondWith)]];
//    
//    long long endOffset = startOffset + dataRequest.requestedLength;
//    BOOL didRespondFully = self.movieData.length >= endOffset;
//    
//    return didRespondFully;
//}

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    
    /*
     When an asset request comes in:
     
     * Hold onto it
     * Make sure we are requesting the chunks in its range
     * Send it for processing in case we already have the data
    
     */
    
    NSLog(@"FUDGEPACK - Request Made - %i %i",loadingRequest.dataRequest.requestedOffset,loadingRequest.dataRequest.requestedLength);
    
    DataRequest * cDR = [[DataRequest alloc] initWithDR: loadingRequest];
    [_dataRequests addObject:cDR];
    
    // REQUEST SHIT IN RANGE
    // TRIGGER REQUESTOR REFRESH
    [self startLoadingWantedChunks];
    
    return YES;
    // NEW SHIT
//    ChunkLoader * loader = [[ChunkLoader alloc] init];
//    [loader LoadChunk: [NSURL URLWithString:self.fileUrl] startAt:loadingRequest.dataRequest.requestedOffset loadBytes:loadingRequest.dataRequest.requestedLength resource:loadingRequest];
//    [self.chunks addObject:loader];
//    return YES;
}

-(void)startLoadingWantedChunks{
    /*
     Go thru all of our chunks and make sure that anything wanted is loading. Create HunkLoads to do the work as necessary.
     */
    long int length = [_chunks count];
    long int startChunk = -1;
    
    NSLog(@"HUNKY START LOADING");
    
    for (long int n = 0; n < length; n++) {
        SingleChunk * cur = _chunks[n];
        NSLog(@"HUNKY STATE=%i",cur.state);

        if (cur.state == WANTED) {
            NSLog(@"HUNKY WANTED");
            // Start building our load request from this chunk
            if (startChunk == -1) {
                startChunk = n;
            }
            
            // Check the next to see if we should keep growing
            SingleChunk * next =nil;
            if (n < length-1){
                next = _chunks[n+1];
            }
            bool bKeepGrowing = false;
            
            if (next) {
                NSLog(@"HUNKY HAS NEXT");
                if (next.state == WANTED) bKeepGrowing = true;
            }
            
            if (!bKeepGrowing) {
                // We aren't growing so request this chunk range.
                NSLog(@"HUNKY LOAD THE MF");
                HunkLoad * Load = [[HunkLoad alloc] initWithChunkRange:startChunk to:n ownedBy:self];
                [_hunkLoads addObject:Load];
                startChunk = -1;
            }
        }
    }
}

- (void)chunkFinishedLoading:(SingleChunk*)who fromHunkLoad:(HunkLoad*)hunk {
    /*
     A chunk has finished loading.
     
     Special case for chunk 0:
     * We now know the length and headers so:
     * Allocate all the necessary chunks
     * Get the header information out
     * Also parse out the MP4 keyframe points which will get asked for.
     
     For every chunk:
     * Send to any assetRequests that may be asking for it
     
     */
    
    
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
        NSLog(@"PANTS - cancel received - TODO");
//    [self.pendingRequests removeObject:loadingRequest];
}


@end
