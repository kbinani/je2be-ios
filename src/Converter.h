#import <Foundation/Foundation.h>

@protocol Converter;

@protocol ConverterDelegate
- (BOOL)converterDidUpdateProgress:(double)progress
                             count:(uint64_t)count
                              step:(int)step
                       description:(NSString *_Nullable)description
                       displayUnit:(NSString *_Nullable)unit;
- (void)converterDidFinishConversion:(NSURL* _Nullable)output error:(NSError * _Nullable) error;
@end


@protocol Converter
- (void)startConvertingFile:(NSURL* _Nonnull)input usingTempDirectory:(NSURL* _Nonnull)tempDirectory delegate:(id<ConverterDelegate> _Nullable)delegate;
- (int)numProgressSteps;
- (NSString* _Nullable)descriptionForStep:(int)step;
- (NSString* _Nullable)displayUnitForStep:(int)step;
@end


#define kJe2beErrorDomain @"com.github.kbinani.je2be-ios"


enum Je2beErrorCode {
    kJe2beErrorCodeUnknown = -1,
    
    kJe2beErrorCodeCancelled = 1,
    kJe2beErrorCodeCxxStdException = 2,
    kJe2beErrorCodeGeneralException = 3,
    kJe2beErrorCodeIOError = 4,
    kJe2beErrorCodeConverterError = 5,
    kJe2beErrorCodeUnzipZipError = 6,
    kJe2beErrorCodeUnzipMcworldError = 7,
    kJe2beErrorCodeLevelDatNotFound = 8,
    kJe2beErrorCodeMultipleLevelDatFound = 9,
    kJe2beErrorCodeMcworldTooLarge = 10,
};
