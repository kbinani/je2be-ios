#import "ConvertJavaToBedrock.h"
#import "Core.h"

@implementation ConvertJavaToBedrock

- (NSString * _Nullable)descriptionForStep:(int)step {
    switch (step) {
        case 0:
            return @"Unzip";
        case 1:
            return @"Conversion";
        case 2:
            return @"LevelDB Compaction";
        case 3:
            return @"Zip";
        default:
            return nil;
    }
}

- (int)numProgressSteps {
    return 4;
}

- (void)startConvertingFile:(NSURL * _Nonnull)input delegate:(id<ConverterDelegate>)delegate {
    JavaToBedrock(self, input, delegate);
}

@end
