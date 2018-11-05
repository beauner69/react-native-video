//
//  DataRequest.m
//  RCTVideo
//

#import <Foundation/Foundation.h>
#import "DataRequest.h"

@implementation DataRequest


- (id) initWithDR:(AVAssetResourceLoadingRequest*) DR{
    NSLog(@"FUDGE DataRequest init");
    if (self = [super init]) {
        self.DR = DR;
    }
    return self;
}

@end
