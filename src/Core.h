#import "Converter.h"

#if defined(__cplusplus)
extern "C" {
#endif

void JavaToBedrock(id<Converter> _Nonnull converter,
                   NSURL* _Nonnull input,
                   NSURL* _Nonnull tempDirectory,
                   __weak id<ConverterDelegate> _Nullable delegate);
void BedrockToJava(id<Converter> _Nonnull converter,
                   NSURL* _Nonnull input,
                   NSString *_Nullable playerUuidString,
                   NSURL* _Nonnull tempDirectory,
                   __weak id<ConverterDelegate> _Nullable delegate);
void Xbox360ToBedrock(id<Converter> _Nonnull converter,
                      NSURL* _Nonnull input,
                      NSURL* _Nonnull tempDirectory,
                      __weak id<ConverterDelegate> _Nullable delegate);
void Xbox360ToJava(id<Converter> _Nonnull converter,
                   NSURL* _Nonnull input,
                   NSString *_Nullable playerUuidString,
                   NSURL* _Nonnull tempDirectory,
                   __weak id<ConverterDelegate> _Nullable delegate);

#if defined(__cplusplus)
} // extern "C"
#endif
