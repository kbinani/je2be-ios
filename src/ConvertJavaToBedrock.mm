
#import "ConvertJavaToBedrock.h"

@implementation ConvertJavaToBedrock

- (void)convert:(NSURL*)input delegate:(id<ConverterDelegate>)delegate {
    dispatch_queue_main_t main = dispatch_get_main_queue();
    //TODO:

    __weak id<ConverterDelegate> weakDelegate = delegate;
    dispatch_async(main, ^{
        id<ConverterDelegate> ref = weakDelegate;
        if (!ref) {
            return;
        }
        [ref converterDidFinishConversion:nil];
    });
}

@end
