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


static NSURL *_Nonnull NSURLFromPath(std::filesystem::path const& path) {
    NSString *nsPath = [NSString stringWithUTF8String:(char const*)path.u8string().c_str()];
    return [[NSURL alloc] initFileURLWithPath: nsPath];
}


void UnsafeJavaToBedrock(id<Converter> converter, NSURL* input, NSURL *tempDirectory, __weak id<ConverterDelegate> delegate) {
    namespace fs = std::filesystem;

    NSURL* output = nullptr;
    defer {
        id<ConverterDelegate> d = delegate;
        if (d) {
            [d converterDidFinishConversion:output];
        }
    };

    fs::path fsTempRoot = PathFromNSURL(tempDirectory);
    
    fs::path fsInput = PathFromNSURL(input);
    fs::path fsTempInput = fsTempRoot / "unzip";
    if (!je2be::Fs::CreateDirectories(fsTempInput)) {
        return;
    }
    
    auto unzipProgress = [delegate, converter](uint64_t done, uint64_t total) {
        id<ConverterDelegate> d = delegate;
        if (d) {
            return [d converterDidUpdateProgress:converter step:0 done:done total:total];
        } else {
            return false;
        }
    };
    if (!je2be::ZipFile::Unzip(fsInput, fsTempInput, unzipProgress)) {
        return;
    }
    
    fs::path fsOutput = fsTempRoot / "output";
    if (!je2be::Fs::CreateDirectories(fsOutput)) {
        return;
    }
    
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
        __weak id<ConverterDelegate> fDelegate;
        Progress(id<Converter> converter, __weak id<ConverterDelegate> delegate) : fConverter(converter), fDelegate(delegate) {
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
            id<ConverterDelegate> d = fDelegate;
            if (d) {
                return [d converterDidUpdateProgress:fConverter step:step done:progress total:total];
            } else {
                return false;
            }
        }
    } progress(converter, delegate);
    
    auto st = c.run(std::thread::hardware_concurrency(), &progress);
    if (!st) {
        return;
    }
    if (!st->fErrors.empty()) {
        return;
    }
    
    auto zipProgress = [delegate, converter](int done, int total) {
        id<ConverterDelegate> d = delegate;
        if (d) {
            return [d converterDidUpdateProgress:converter step:3 done:done total:total];
        } else {
            return false;
        }
    };
    fs::path fsZipOut = fsTempRoot / fsInput.filename().replace_extension(".mcworld");
    NSURL *zipOut = NSURLFromPath(fsZipOut);
    if (!je2be::ZipFile::Zip(fsOutput, fsZipOut, zipProgress)) {
        return;
    }
    bool exists = fs::exists(fsZipOut);
    output = zipOut;
}


void UnsafeBedrockToJava(id<Converter> converter, NSURL* input, NSURL *tempDirectory, __weak id<ConverterDelegate> delegate) {
    namespace fs = std::filesystem;

    NSURL *output = nil;
    defer {
        id<ConverterDelegate> d = delegate;
        if (d) {
            [d converterDidFinishConversion: output];
        }
    };

    fs::path fsInput = PathFromNSURL(input);

    fs::path fsTempRoot = PathFromNSURL(tempDirectory);
    fs::path fsTempUnzip = fsTempRoot / "unzip";
    if (!je2be::Fs::CreateDirectories(fsTempUnzip)) {
        return;
    }
    
    auto unzipProgress = [delegate, converter](uint64_t done, uint64_t total) {
        id<ConverterDelegate> d = delegate;
        if (d) {
            return [d converterDidUpdateProgress:converter step:0 done:done total:total];
        } else {
            return false;
        }
    };
    if (!je2be::ZipFile::Unzip(fsInput, fsTempUnzip, unzipProgress)) {
        return;
    }
    
    fs::path fsTempOutput = fsTempRoot / "output";
    if (!je2be::Fs::CreateDirectories(fsTempOutput)) {
        return;
    }
    je2be::toje::Options options;
    je2be::toje::Converter c(fsTempUnzip, fsTempOutput, options);
    
    struct Progress : public je2be::toje::Progress {
        id<Converter> fConverter;
        __weak id<ConverterDelegate> fDelegate;
        Progress(id<Converter> converter, __weak id<ConverterDelegate> delegate) : fConverter(converter), fDelegate(delegate) {
        }
        bool report(double progress, double total) override {
            id<ConverterDelegate> d = fDelegate;
            if (d) {
                return [d converterDidUpdateProgress:fConverter step:1 done:progress total:total];
            } else {
                return false;
            }
        }
    } progress(converter, delegate);
    
    if (!c.run(std::thread::hardware_concurrency(), &progress)) {
        return;
    }

    auto zipProgress = [delegate, converter](int done, int total) {
        id<ConverterDelegate> d = delegate;
        if (d) {
            return [d converterDidUpdateProgress:converter step:2 done:done total:total];
        } else {
            return false;
        }
    };
    fs::path fsZipOut = fsTempRoot / fsInput.filename().replace_extension(".zip");
    NSURL *zipOut = NSURLFromPath(fsZipOut);
    if (!je2be::ZipFile::Zip(fsTempOutput, fsZipOut, zipProgress)) {
        return;
    }
    bool exists = fs::exists(fsZipOut);
    output = zipOut;
}


extern "C" {

void JavaToBedrock(id<Converter> converter, NSURL* input, NSURL *tempDirectory, __weak id<ConverterDelegate> delegate) {
    try {
        UnsafeJavaToBedrock(converter, input, tempDirectory, delegate);
    } catch (...) {
    }
}


void BedrockToJava(id<Converter> converter, NSURL* input, NSURL *tempDirectory, __weak id<ConverterDelegate> delegate) {
    try {
        UnsafeBedrockToJava(converter, input, tempDirectory, delegate);
    } catch (...) {
    }
}

} // extern "C"
