#import <Foundation/Foundation.h>

@class Converter;

@protocol ConverterDelegate
- (BOOL)converterDidUpdateProgress:(id _Null_unspecified)converter done:(double)done total:(double)total;
- (void)converterDidFinishConversion:(NSURL* _Nullable)output;
@end


@protocol Converter
- (void)convert:(NSURL* _Null_unspecified)input delegate:(id<ConverterDelegate> _Null_unspecified)delegate;
@end
