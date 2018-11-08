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
    static int hunknum = 0;
    
    if (self = [super init]) {
        _firstChunk = firstChunk;
        _lastChunk = lastChunk;
        _owner = owner;
        _cancelled = false;
        
//        if (_firstChunk == _lastChunk) {
//            NSLog(@"%li, // CHONK",_firstChunk);
//        }
        
//        NSLog(@"HUNKY LOAD REQUESTED %i to %i",_firstChunk,_lastChunk);

        NSURL * theUrl = owner.fileUrl;
        
//        hunknum++;
//        if (hunknum == 100) {
//            theUrl = [NSURL URLWithString:@"http://thepisspot.org/asfjkl"];
//        }
//        NSLog(@"HUNKNUM:%i%",hunknum);

        NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:theUrl
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
//        NSLog(@"HUNKY - range: %@", range);
    
        [request setValue:range forHTTPHeaderField:@"Range"];
    
        
        _session = [NSURLSession sessionWithConfiguration:[HunkLoad getSessionConfig]
                                                delegate:self
                                           delegateQueue:[NSOperationQueue mainQueue]];
        _task = [_session dataTaskWithRequest:request];
        [_task resume];
    }
    
    return self;
}

-(void)cleanup {
    _cancelled = true;
    if (_task) {
        [_task cancel];
        _task = nil;
    }
    if (_session) {
        [_session invalidateAndCancel];
        _session = nil;
    }
}

#pragma mark - NSURLConnection delegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    self.response = (NSHTTPURLResponse *)response;
    completionHandler(NSURLSessionResponseAllow);
}

    - (void)URLSession:(NSURLSession *)session
dataTask:(NSURLSessionDataTask *)dataTask
        didReceiveData:(NSData *)data{
    
        if (_cancelled) {
            return;
        }
    
    long int bytesLeft = data.length;
    long int dataPos = 0;
    
    // Offer the data up to the various chunks
    
    while (bytesLeft > 0) {
        long int targetChunkIdx = ByteToContainingChunk(_nextByte);
        
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
                finishing = true;
            }
        }
        
        
        long int bytesTaken = [targetChunk loadBytesFrom:data maximum:bytesLeft filePos:_nextByte dataPos:dataPos owner:_owner hunk:self finishing:finishing];
        
        _nextByte += bytesTaken;
        bytesLeft -= bytesTaken;
        dataPos += bytesTaken;

    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error; {
    _owner = nil; // Hopefully garbage will get collected.
    [self cleanup];
}


- (long int)getTotalSizeFromHeaders {
    NSDictionary *headers = [self.response allHeaderFields];
    NSString *range = [headers objectForKey:@"Content-Range"];
    NSRange slash = [range rangeOfString:@"/"];
    NSString *totalbit = [range substringFromIndex:slash.location + 1];
    
//    NSString *mimeType = [self.response MIMEType];
//    NSLog(@"KEVIN MIMETYPE: %@",mimeType);
    
    return [totalbit integerValue];
}

+ (NSURLSessionConfiguration*) getSessionConfig
{
    static NSURLSessionConfiguration* sessionConfig;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        sessionConfig.timeoutIntervalForRequest = 30.0;
        sessionConfig.HTTPMaximumConnectionsPerHost = 15;
        sessionConfig.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
        sessionConfig.HTTPShouldUsePipelining = NO;
//        sessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
    });
    return sessionConfig;
}

@end
