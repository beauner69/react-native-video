#import <Foundation/Foundation.h>
#import "ChunkLoader.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation ChunkLoader



- (id)init{
    NSLog(@"RECCE ChunkLoader INIT");
//    if (self = [super init]) {
//        self.cacheDir = [AssetLoaderDelegate cacheDirectory];
//        self.pendingRequests = [NSMutableArray array];
//        NSLog(@"FUDGE cache = %@",self.cacheDir);
//    }

    return self;
}

- (void)LoadChunk: (NSURL*)url startAt:(long long)offset loadBytes:(long long)size resource:(AVAssetResourceLoadingRequest *)loadingRequest{
    self.loadingRequest = loadingRequest;
    
    NSLog(@"RECCEU CHUNK URL %@",url);
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:60.0];
    
    // Set the range for our request
    NSString* range = @"bytes=";
    range = [range stringByAppendingString:[[NSNumber numberWithLongLong:offset] stringValue]];
    range = [range stringByAppendingString:@"-"];
    range = [range stringByAppendingString:[[NSNumber numberWithLongLong:(offset + size - 1)] stringValue]];
    NSLog(@"RECCE - range: %@", range);
    
    [request setValue:range forHTTPHeaderField:@"Range"];

    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection setDelegateQueue:[NSOperationQueue mainQueue]];
    [self.connection start];
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"RECCE - connected");
    self.chunkData = [NSMutableData data];
    self.response = (NSHTTPURLResponse *)response;
    [self fillInContentInformation:self.loadingRequest.contentInformationRequest];
//    [self processPendingRequests];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
//    NSLog(@"RECCE - data");
    [self.chunkData appendData:data];
//    [self processPendingRequests];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"RECCE - done, length: %i requestedLength: %i requestedOffset: %i",self.chunkData.length,self.loadingRequest.dataRequest.requestedLength,self.loadingRequest.dataRequest.requestedOffset);
    //    NSLog(@"FUDGE - three");
    
//    [self processPendingRequests];
//    NSLog(@"FUDGE Download complete");
//    NSString *fileName = [NSURL URLWithString:self.fileUrl].absoluteString.lastPathComponent;
//    NSString *cachedFilePath = [[NSString alloc] initWithFormat:@"%@/%@",self.cacheDir,[fileName componentsSeparatedByString:@"?"].firstObject];
//    BOOL writen = [self.movieData writeToFile:cachedFilePath atomically:YES];
//    if(!writen){
//        NSLog(@"FUDGE Error writing cache, what a surprise");
//
//    }
    
    
    [self fillInContentInformation:self.loadingRequest.contentInformationRequest];
    
    
    
    
    
    
//    BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest.dataRequest];
//    //    NSLog(@"FUDGE - six");
//
//    long long startOffset = dataRequest.requestedOffset;
//    if (dataRequest.currentOffset != 0){
//        startOffset = dataRequest.currentOffset;
//    }
    
    // Don't have any data at all for this request
//    if (self.movieData.length < startOffset){
//        return NO;
//    }
    
    // This is the total data we have from startOffset to whatever has been downloaded so far
//    NSUInteger unreadBytes = self.movieData.length - (NSUInteger)startOffset;
    // Respond with whatever is available if we can't satisfy the request fully yet
//    NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)dataRequest.requestedLength, unreadBytes);
    
//    NSLog(@"FUDGE data:%lu,,,(%lld,%lu)",(unsigned long)self.movieData.length,startOffset,(unsigned long)numberOfBytesToRespondWith);
//    [self.loadingRequest.dataRequest respondWithData:[self.chunkData subdataWithRange:NSMakeRange(0, self.chunkData.length)]];
    
    [self.loadingRequest.dataRequest respondWithData:self.chunkData];

    
   
    
    
    
    
    
        [self.loadingRequest finishLoading];
    [self.connection cancel];
}



- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest{
    //    NSLog(@"FUDGE - five");
    
    if (contentInformationRequest == nil || self.response == nil){
        return;
    }
    
    NSString *mimeType = [self.response MIMEType];
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);

    // Work out the length
    long length = [self.response expectedContentLength];
    NSDictionary * headers = [self.response allHeaderFields];
    NSString * range = [headers objectForKey:@"Content-Range"];
    NSRange slash = [range rangeOfString:@"/"];
    NSString * totalbit = [range substringFromIndex:slash.location+1];
    length = [totalbit integerValue];

    NSLog(@"RECCEFART range: %@ becomes %@ length:%i",range,totalbit,length);

    //    if (range) {
//
//    }
    
    if (headers)
    NSLog(@"RECCE: Headers: %@",headers);
        
    contentInformationRequest.byteRangeAccessSupported = YES;
    contentInformationRequest.contentType = CFBridgingRelease(contentType);
    contentInformationRequest.contentLength = length;

    NSLog(@"RECCE: mimeType %@ length %i",mimeType,contentInformationRequest.contentLength);
}

@end
