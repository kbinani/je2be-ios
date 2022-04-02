#import <Foundation/Foundation.h>

@class Converter;

@protocol ConverterDelegate
- (BOOL)converterDidUpdateProgress:(id _Nonnull)converter step:(int)step done:(double)done total:(double)total;
- (void)converterDidFinishConversion:(NSURL* _Nullable)output;
@end


@protocol Converter
- (void)startConvertingFile:(NSURL* _Nonnull)input delegate:(__weak id<ConverterDelegate> _Nullable)delegate;
- (int)numProgressSteps;
- (NSString* _Nullable)descriptionForStep:(int)step;
@end
