#import "Converter.h"

#if defined(__cplusplus)
extern "C" {
#endif

void JavaToBedrock(id<Converter> _Nonnull converter, NSURL* _Nonnull input, NSURL* _Nonnull tempDirectory, __weak id<ConverterDelegate> delegate);
void BedrockToJava(id<Converter> _Nonnull converter, NSURL* _Nonnull input, NSURL* _Nonnull tempDirectory, __weak id<ConverterDelegate> delegate);

#if defined(__cplusplus)
} // extern "C"
#endif
