#import "Core.h"
#import "Converter.h"
#include <je2be.hpp>

static NSURL* _Nullable CreateTempDir() {
    NSFileManager* manager = [NSFileManager defaultManager];
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString* path = [manager.temporaryDirectory.path stringByAppendingPathComponent:[uuid UUIDString]];
    BOOL ok = [manager createDirectoryAtPath:path
                 withIntermediateDirectories:FALSE
                                  attributes:nil
                                       error:nil];
    if (!ok) {
        return nil;
    }
    return [[NSURL alloc] initFileURLWithPath:path];
}

static NSURL* _Nonnull CreateTempFile(NSString * _Nonnull extWithDot) {
    NSFileManager* manager = [NSFileManager defaultManager];
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString* path = [manager.temporaryDirectory.path stringByAppendingPathComponent:[[uuid UUIDString] stringByAppendingString:extWithDot]];
    return [[NSURL alloc] initFileURLWithPath:path];
}

static std::filesystem::path PathFromNSURL(NSURL * _Nonnull url) {
    return std::filesystem::path([[url path] cStringUsingEncoding:NSUTF8StringEncoding]);
}


void UnsafeJavaToBedrock(id<Converter> converter, NSURL* input, __weak id<ConverterDelegate> delegate) {
    namespace fs = std::filesystem;

    id<ConverterDelegate> d = delegate;
    if (!d) {
        return;
    }
    
    fs::path fsInput = PathFromNSURL(input);
    NSURL* tempInput = CreateTempDir();
    if (!tempInput) {
        return;
    }
    fs::path fsTempInput = PathFromNSURL(tempInput);
    NSURL* output = nullptr;
    defer {
        [d converterDidFinishConversion:output];
        je2be::Fs::DeleteAll(fsTempInput);
    };
    auto unzipProgress = [d, converter](uint64_t done, uint64_t total) {
        return [d converterDidUpdateProgress:converter step:0 done:done total:total];
    };
    if (!je2be::ZipFile::Unzip(fsInput, fsTempInput, unzipProgress)) {
        return;
    }
    
    NSURL* tempOutput = CreateTempDir();
    if (!tempOutput) {
        return;
    }
    fs::path fsOutput = PathFromNSURL(tempOutput);
    defer {
        je2be::Fs::DeleteAll(fsOutput);
    };
    fs::path fsActualInput = fsTempInput;
    std::error_code ec;
    for (auto it : fs::recursive_directory_iterator(fsTempInput, ec)) {
        auto p = it.path();
        if (!fs::is_regular_file(p)) {
            continue;
        }
        auto fileName = p.filename().string();
        if (fileName == "level.dat") {
            fsActualInput = p.parent_path();
            break;
        }
    }
    if (ec) {
        return;
    }
    
    je2be::tobe::Options options;
    je2be::tobe::Converter c(fsActualInput, fsOutput, options);
    
    struct Progress : public je2be::tobe::Progress {
        id<Converter> fConverter;
        id<ConverterDelegate> fDelegate;
        Progress(id<Converter> converter, id<ConverterDelegate> delegate) : fConverter(converter), fDelegate(delegate) {
        }
        bool report(Phase phase, double progress, double total) override {
            int step = 1;
            switch (phase) {
                case Phase::LevelDbCompaction:
                    step = 2;
                    break;
                case Phase::Convert:
                default:
                    step = 1;
                    break;
            }
            bool ok = [fDelegate converterDidUpdateProgress:fConverter step:step done:progress total:total];
            return ok;
        }
    } progress(converter, delegate);
    
    auto st = c.run(std::thread::hardware_concurrency(), &progress);
    if (!st) {
        return;
    }
    if (!st->fErrors.empty()) {
        return;
    }
    
    auto zipProgress = [d, converter](int done, int total) {
        return [d converterDidUpdateProgress:converter step:3 done:done total:total];
    };
    NSURL *zipOut = CreateTempFile(@".mcworld");
    if (!je2be::ZipFile::Zip(fsOutput, PathFromNSURL(zipOut), zipProgress)) {
        return;
    }
    output = zipOut;
}


extern "C" void JavaToBedrock(id<Converter> converter, NSURL* input, __weak id<ConverterDelegate> delegate) {
    try {
        UnsafeJavaToBedrock(converter, input, delegate);
    } catch (...) {
    }
}
