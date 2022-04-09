#import <Foundation/Foundation.h>

@protocol Converter;

@protocol ConverterDelegate
- (BOOL)converterDidUpdateProgress:(id<Converter> _Nonnull)converter step:(int)step done:(double)done total:(double)total;
- (void)converterDidFinishConversion:(NSURL* _Nullable)output error:(NSError * _Nullable) error;
@end


@protocol Converter
- (void)startConvertingFile:(NSURL* _Nonnull)input usingTempDirectory:(NSURL* _Nonnull)tempDirectory delegate:(__weak id<ConverterDelegate> _Nullable)delegate;
- (int)numProgressSteps;
- (NSString* _Nullable)descriptionForStep:(int)step;
- (NSString* _Nullable)displayUnitForStep:(int)step;
@end


NSString * _Nonnull const kJe2beErrorDomain = @"com.github.kbinani.je2be-ios";


enum Je2beErrorCode {
    kJe2beErrorCodeUnknown = -1,
    
    kJe2beErrorCodeCancelled = 1,
    kJe2beErrorCodeCxxStdException = 2,
    kJe2beErrorCodeGeneralException = 3,
    kJe2beErrorCodeIOError = 4,
    kJe2beErrorCodeConverterError = 5,
};
