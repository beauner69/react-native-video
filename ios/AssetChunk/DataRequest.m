//
//  DataRequest.m
//  RCTVideo
//

#import <Foundation/Foundation.h>
#import "DataRequest.h"
#import "SingleChunk.h"

@implementation DataRequest


- (id) initWithDR:(AVAssetResourceLoadingRequest*) DR owner:(ChunkAssetLoaderDelegate*)owner{
    if (self = [super init]) {
        _DR = DR;

        long int chunkCount = [owner.chunks count];

        _nextByteToSend = DR.dataRequest.requestedOffset;
        _bytesRemaining = DR.dataRequest.requestedLength;
        _nextChunkToSendFrom = ByteToContainingChunk(_nextByteToSend);
        
        _firstChunk = ByteToContainingChunk(_nextByteToSend);
        _lastChunk = ByteToContainingChunk(StartAndLengthToLastByte(_nextByteToSend,_bytesRemaining));
        
        if (_firstChunk >= owner.highestChunkRequestedSoFar) {
//            NSLog(@"ROGER: RISING %i %i",_firstChunk,owner.highestChunkRequestedSoFar);
            owner.highestChunkRequestedSoFar = _firstChunk;
        } else {
//            NSLog(@"ROGER: FALLING %i %i",_firstChunk,owner.highestChunkRequestedSoFar);
            SingleChunk * fosty = owner.chunks[_firstChunk];
            if (fosty.state == EMPTY) {
                
                if (_lastChunk - _firstChunk < 4) {
                    _lastChunk = _firstChunk + 4;
                    if (_lastChunk >= chunkCount) _lastChunk = chunkCount-1;
                }
            }
        }
        
        // Make sure the chunks are booked in
        for (long int n = _firstChunk; n <= _lastChunk; n++) {
            if (n < chunkCount) {
                SingleChunk * c = owner.chunks[n];
                if (c.state == EMPTY) c.state = WANTED;
            } else {
                NSLog(@"ERROR ASSETCHUNK - DataRequest is asking for chunks we havent allocated - want = %li max = %li",n,chunkCount);
            }
        }
    }
    return self;
}

- (bool) chanceToSendData:(ChunkAssetLoaderDelegate*)owner{
    long int chunkCount = [owner.chunks count];

    while (_bytesRemaining > 0) {
        // Check if chunk is ready
        if (chunkCount <= _nextChunkToSendFrom) {
            NSLog(@"ERROR ASSETCHUNK - DataRequest wants to send from chunk %li but maximum is %li",_nextChunkToSendFrom,chunkCount);
            return false;
        }
        
        SingleChunk * chunk = owner.chunks[_nextChunkToSendFrom];
        if (chunk.state != READY) {
//            NSLog(@"NATTY: Cant send chunk yet its not ready");
            return false;
        }
        
        // Chunk is ready so let 'er rip
        long int byteInsideChunk = ByteToByteInsideChunk(_nextByteToSend);
        long int bytesToSendFromChunk = chunk.loaded - byteInsideChunk;
        long int bytesSent;
        
        if ((byteInsideChunk == 0) && (bytesToSendFromChunk <= _bytesRemaining)) {
            // We can take them all
            [self.DR.dataRequest respondWithData:chunk.chunkData];

            bytesSent = bytesToSendFromChunk;
        } else {
            // We need to chop out the bytes we are taking
            long int bytesToTake = (_bytesRemaining < bytesToSendFromChunk) ? _bytesRemaining:bytesToSendFromChunk;
//            NSLog(@"NATTY: Partial - taking %li",bytesToTake);
            [self.DR.dataRequest respondWithData:[chunk.chunkData subdataWithRange:NSMakeRange(byteInsideChunk, bytesToTake)]];
            bytesSent = bytesToTake;
        }

        _nextByteToSend += bytesSent;
        _bytesRemaining -= bytesSent;
        _nextChunkToSendFrom++;
    }
    
    // If we make it out of the while loop, we are DONE
    
    [self fillInContentInformation:owner];
    [_DR finishLoading];
    return true;
}

-(void) fillInContentInformation:(ChunkAssetLoaderDelegate*)owner{
    if (_DR.contentInformationRequest == nil) {
        return;
    }
    
    _DR.contentInformationRequest.byteRangeAccessSupported = YES;
    _DR.contentInformationRequest.contentType = owner.format == VIDEO ? AVFileTypeMPEG4 : AVFileTypeAppleM4A; // Hardcoded - we ignore response content type
    _DR.contentInformationRequest.contentLength = owner.totalSize;
}

@end
