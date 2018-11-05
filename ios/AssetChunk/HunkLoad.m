//
//  ChunkLoad.m
//  RCTVideo
//
//

#import <Foundation/Foundation.h>
#import "HunkLoad.h"
#import "SingleChunk.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation HunkLoad

-(id) initWithChunkRange:(long int)firstChunk to:(long int)lastChunk ownedBy:(ChunkAssetLoaderDelegate*)owner {
    if (self = [super init]) {
        _firstChunk = firstChunk;
        _lastChunk = lastChunk;
        _owner = owner;
        
        if (_firstChunk == _lastChunk) {
            NSLog(@"%li, // CHONK",_firstChunk);
        }
        
        NSLog(@"HUNKY LOAD REQUESTED %i to %i",_firstChunk,_lastChunk);


        NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:owner.fileUrl
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:60.0];
    
        _nextByte = FirstByteOfChunk(_firstChunk);
        
        long int lastByte =LastByteOfChunk(_lastChunk);
        if (owner.totalSize > -1) {
            if (owner.totalSize <= lastByte) lastByte = owner.totalSize - 1;
        }
        
        // Set the range for our request
        NSString *range = @"bytes=";
        range = [range stringByAppendingString:[[NSNumber numberWithLongLong:_nextByte]
                                                stringValue]];
        range = [range stringByAppendingString:@"-"];
        range = [range
                 stringByAppendingString:[[NSNumber numberWithLongLong:lastByte]
                                          stringValue]];
        NSLog(@"HUNKY - range: %@", range);
    
        [request setValue:range forHTTPHeaderField:@"Range"];
    
        self.connection = [[NSURLConnection alloc] initWithRequest:request
                                                          delegate:self
                                                  startImmediately:NO];
        [self.connection setDelegateQueue:[NSOperationQueue mainQueue]];
        [self.connection start];

    }
    
    return self;
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"HUNKY - connected");
    self.response = (NSHTTPURLResponse *)response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"RECCE - data");
    long int bytesLeft = data.length;
    long int dataPos = 0;
    
    // Offer the data up to the various chunks
    
    while (bytesLeft > 0) {
        long int targetChunkIdx = ByteToContainingChunk(_nextByte);
        NSLog(@"RECCE - target chunk:%li nextByte:%li size:%li",targetChunkIdx,_nextByte,data.length);
        
        // Grab our target chunk
        SingleChunk *targetChunk;
        if (_owner.chunks.count < targetChunkIdx) {
            NSLog(@"ERROR ASSETCHUNK - Try to send bytes to a chunk that's not allocated - idx %li",targetChunkIdx);
            return;
        }
        targetChunk = _owner.chunks[targetChunkIdx];
        
        // work out if this is a finishing move
        bool finishing = false;
        if (_owner.totalSize > -1) {
            if (_nextByte + bytesLeft >= _owner.totalSize-1) {
                NSLog(@"FINNISH_HIMMM");
                finishing = true;
            }
        }
        
        
        long int bytesTaken = [targetChunk loadBytesFrom:data maximum:bytesLeft filePos:_nextByte dataPos:dataPos owner:_owner hunk:self finishing:finishing];
        
        _nextByte += bytesTaken;
        bytesLeft -= bytesTaken;
        dataPos += bytesTaken;

        NSLog(@"RECCE - Bytes taken= %li bytesLeft %li dataPos %li",bytesTaken,bytesLeft,dataPos);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"RECCE - Connection is finished.");
//    NSLog(@"RECCE - done, length: %i requestedLength: %i requestedOffset: %i",
//          self.chunkData.length, self.loadingRequest.dataRequest.requestedLength,
//          self.loadingRequest.dataRequest.requestedOffset);

}

- (long int)getTotalSizeFromHeaders {
    NSDictionary *headers = [self.response allHeaderFields];
    NSString *range = [headers objectForKey:@"Content-Range"];
    NSRange slash = [range rangeOfString:@"/"];
    NSString *totalbit = [range substringFromIndex:slash.location + 1];
    return [totalbit integerValue];
}

//- (void)fillInContentInformation:
//(AVAssetResourceLoadingContentInformationRequest *)
//contentInformationRequest {
//    //    NSLog(@"FUDGE - five");
//
//    if (contentInformationRequest == nil || self.response == nil) {
//        return;
//    }
//
//    NSString *mimeType = [self.response MIMEType];
//    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(
//                                                                    kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
//
//    // Work out the length
//    long length = [self.response expectedContentLength];
//    NSDictionary *headers = [self.response allHeaderFields];
//    NSString *range = [headers objectForKey:@"Content-Range"];
//    NSRange slash = [range rangeOfString:@"/"];
//    NSString *totalbit = [range substringFromIndex:slash.location + 1];
//    length = [totalbit integerValue];
//
//    NSLog(@"RECCEFART range: %@ becomes %@ length:%i", range, totalbit, length);
//
//    //    if (range) {
//    //
//    //    }
//
//    if (headers)
//        NSLog(@"RECCE: Headers: %@", headers);
//
//    contentInformationRequest.byteRangeAccessSupported = YES;
//    //   contentInformationRequest.contentType = AVFileTypeAppleM4V;
//    contentInformationRequest.contentType = CFBridgingRelease(contentType);
//    contentInformationRequest.contentLength = length;
//
//    NSLog(@"RECCE: mimeType %@ length %i", mimeType,
//          contentInformationRequest.contentLength);
//}

@end
