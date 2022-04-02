#import <UIKit/UIKit.h>
#import "Converter.h"

@interface ConvertJavaToBedrock : NSObject<Converter>
{
    
}
- (void)convert:(NSURL*)input delegate:(id<ConverterDelegate>)delegate;

@end
