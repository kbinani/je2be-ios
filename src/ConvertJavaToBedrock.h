#import <UIKit/UIKit.h>
#import "Converter.h"

@interface ConvertJavaToBedrock : NSObject<Converter>
{
    
}
- (NSString * _Nullable)descriptionForStep:(int)step;
- (int)numProgressSteps;
- (void)startConvertingFile:(NSURL * _Nonnull)input delegate:(id<ConverterDelegate>)delegate;

@end
