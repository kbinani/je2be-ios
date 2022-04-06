#import "Converter.h"

#if defined(__cplusplus)
extern "C" {
#endif

void JavaToBedrock(id<Converter> converter, NSURL* input, __weak id<ConverterDelegate> delegate);
void BedrockToJava(id<Converter> converter, NSURL* input, __weak id<ConverterDelegate> delegate);

#if defined(__cplusplus)
} // extern "C"
#endif
