#import "Core.h"
#import "Converter.h"
#include <je2be.hpp>


static std::filesystem::path PathFromNSURL(NSURL * _Nonnull url) {
    return std::filesystem::path([[url path] cStringUsingEncoding:NSUTF8StringEncoding]);
}


static NSURL *_Nonnull NSURLFromPath(std::filesystem::path const& path) {
    NSString *nsPath = [NSString stringWithUTF8String:(char const*)path.u8string().c_str()];
    return [[NSURL alloc] initFileURLWithPath: nsPath];
}


static std::string StringFromNSString(NSString *_Nonnull s) {
    std::string str([s UTF8String]);
    return str;
}

static NSError * _Nonnull Error(NSInteger code, std::string const& fileName, int lineNumber) {
    NSString * file = [NSString stringWithUTF8String:fileName.c_str()];
    NSNumber * line = [[NSNumber alloc] initWithInt:lineNumber];
    return [[NSError alloc] initWithDomain:kJe2beErrorDomain code:code userInfo:@{@"file": file, @"line": line}];
}


struct Result {
    NSURL * _Nullable fOutput;
    NSInteger fErrorCode;
    std::string fFile;
    int fLineNumber;

private:
    explicit Result(NSURL * _Nullable output, NSInteger code, std::string const& file, int lineNumber) : fOutput(output), fErrorCode(code), fFile(file), fLineNumber(lineNumber) {}

public:
    static Result Ok(NSURL * _Nonnull output) {
        return Result(output, 0, {}, 0);
    }
    
    static Result Error(NSInteger code, std::string const& file, int lineNumber) {
        return Result(nil, code, file, lineNumber);
    }
    
    static Result Error(je2be::Status::Where error) {
      return Result(nil, kJe2beErrorCodeConverterError, error.fFile, error.fLine);
    }
};


static std::string const sBasename = std::filesystem::path(__FILE__).filename().string();


struct UnzipProgress {
    UnzipProgress(int step, id<Converter> converter, id<ConverterDelegate> delegate) : fStep(step), fConverter(converter), fDelegate(delegate), fCancelled(false) {}
    
    bool operator() (uint64_t done, uint64_t total) {
        id<ConverterDelegate> d = fDelegate;
        if (d) {
            NSString *description = [fConverter descriptionForStep:fStep];
            NSString *unit = [fConverter displayUnitForStep:fStep];
            bool ok = [d converterDidUpdateProgress:done total:total step:fStep description:description displayUnit:unit];
            if (ok) {
                return true;
            } else {
                fCancelled = true;
                return false;
            }
        } else {
            fCancelled = true;
            return false;
        }
    }

    int fStep;
    id<Converter> fConverter;
    __weak id<ConverterDelegate> fDelegate;
    bool fCancelled;
};


struct ZipProgress {
    ZipProgress(int step, id<Converter> converter, id<ConverterDelegate> delegate) : fStep(step), fConverter(converter), fDelegate(delegate), fCancelled(false) {}

    bool operator() (int done, int total) {
        id<ConverterDelegate> d = fDelegate;
        if (d) {
            NSString *description = [fConverter descriptionForStep:fStep];
            NSString *unit = [fConverter displayUnitForStep:fStep];
            bool ok = [d converterDidUpdateProgress:done total:total step:fStep description:description displayUnit:unit];
            if (ok) {
                return true;
            } else {
                fCancelled = true;
                return false;
            }
        } else {
            fCancelled = true;
            return false;
        }
    }

    int fStep;
    id<Converter> fConverter;
    __weak id<ConverterDelegate> fDelegate;
    bool fCancelled;
};


struct ToJeProgress : public je2be::toje::Progress {
    ToJeProgress(int step, id<Converter> converter, id<ConverterDelegate> delegate) : fStep(step), fConverter(converter), fDelegate(delegate), fCancelled(false) {}

    bool report(double progress, double total) override {
        id<ConverterDelegate> d = fDelegate;
        if (d) {
            NSString *description = [fConverter descriptionForStep:fStep];
            NSString *unit = [fConverter displayUnitForStep:fStep];
            bool ok = [d converterDidUpdateProgress:progress total:total step:fStep description:description displayUnit:unit];
            if (ok) {
                return true;
            } else {
                fCancelled = true;
                return false;
            }
        } else {
            fCancelled = true;
            return false;
        }
    }

    int fStep;
    id<Converter> fConverter;
    __weak id<ConverterDelegate> fDelegate;
    bool fCancelled;
};


struct ToBeProgress : public je2be::tobe::Progress {
    ToBeProgress(int step, id<Converter> converter, id<ConverterDelegate> delegate) : fStep(step), fConverter(converter), fDelegate(delegate), fCancelled(false) {}

    bool report(Phase phase, double progress, double total) override {
        int step = fStep;
        switch (phase) {
            case Phase::LevelDbCompaction:
                fStep += 1;
                break;
            case Phase::Convert:
            default:
                break;
        }
        id<ConverterDelegate> d = fDelegate;
        if (d) {
            NSString *description = [fConverter descriptionForStep:step];
            NSString *unit = [fConverter displayUnitForStep:step];
            bool ok = [d converterDidUpdateProgress:progress total:total step:step description:description displayUnit:unit];
            if (ok) {
                return true;
            } else {
                fCancelled = true;
                return false;
            }
        } else {
            fCancelled = true;
            return false;
        }
    }

    int fStep;
    id<Converter> fConverter;
    __weak id<ConverterDelegate> fDelegate;
    bool fCancelled;
};


struct Box360Progress : public je2be::box360::Progress {
    Box360Progress(int step, id<Converter> converter, id<ConverterDelegate> delegate) : fStep(step), fConverter(converter), fDelegate(delegate), fCancelled(false) {}
    
    bool report(double progress, double total) override {
        id<ConverterDelegate> d = fDelegate;
        if (!d) {
            fCancelled = true;
            return false;
        }
        NSString *description = [fConverter descriptionForStep:fStep];
        NSString *unit = [fConverter displayUnitForStep:fStep];
        bool ok = [d converterDidUpdateProgress:progress total:total step:fStep description:description displayUnit:unit];
        if (ok) {
            return true;
        } else {
            fCancelled = true;
            return false;
        }
    }

    int fStep;
    id<Converter> fConverter;
    __weak id<ConverterDelegate> fDelegate;
    bool fCancelled;
};


Result UnsafeJavaToBedrock(id<Converter> converter, NSURL* input, NSURL *tempDirectory, id<ConverterDelegate> delegate) {
    namespace fs = std::filesystem;
    
    fs::path fsTempRoot = PathFromNSURL(tempDirectory);
    
    fs::path fsInput = PathFromNSURL(input);
    fs::path fsTempInput = fsTempRoot / "unzip";
    if (!je2be::Fs::CreateDirectories(fsTempInput)) {
        return Result::Error(kJe2beErrorCodeIOError, sBasename, __LINE__);
    }

    UnzipProgress unzipProgress(0, converter, delegate);
    if (!je2be::ZipFile::Unzip(fsInput, fsTempInput, unzipProgress)) {
        if (unzipProgress.fCancelled) {
            return Result::Error(kJe2beErrorCodeCancelled, sBasename, __LINE__);
        } else {
            return Result::Error(kJe2beErrorCodeUnzipZipError, sBasename, __LINE__);
        }
    }
    
    fs::path fsOutput = fsTempRoot / "output";
    if (!je2be::Fs::CreateDirectories(fsOutput)) {
        return Result::Error(kJe2beErrorCodeIOError, sBasename, __LINE__);
    }
    
    std::error_code ec;
    auto iterator = fs::recursive_directory_iterator(fsTempInput, ec);
    if (ec) {
        return Result::Error(kJe2beErrorCodeIOError, sBasename, __LINE__);
    }
    std::optional<fs::path> fsActualInput;
    for (auto it : iterator) {
        auto p = it.path();
        if (!fs::is_regular_file(p)) {
            continue;
        }
        auto fileName = p.filename().string();
        if (fileName != "level.dat") {
            continue;
        }
        if (fsActualInput) {
            return Result::Error(kJe2beErrorCodeMultipleLevelDatFound, sBasename, __LINE__);
        }
        fsActualInput = p.parent_path();
    }
    if (!fsActualInput) {
        return Result::Error(kJe2beErrorCodeLevelDatNotFound, sBasename, __LINE__);
    }
    
    je2be::tobe::Options options;
    options.fTempDirectory = fsTempRoot;
    je2be::tobe::Converter c(*fsActualInput, fsOutput, options);
    
    ToBeProgress progress(1, converter, delegate);
    auto st = c.run(std::thread::hardware_concurrency(), &progress);
    if (!st) {
        if (progress.fCancelled) {
            return Result::Error(kJe2beErrorCodeCancelled, sBasename, __LINE__);
        } else {
            return Result::Error(kJe2beErrorCodeConverterError, sBasename, __LINE__);
        }
    } else if (!st->fErrors.empty()) {
        return Result::Error(st->fErrors[0].fWhere);
    }
    
    ZipProgress zipProgress(3, converter, delegate);
    fs::path fsZipOut = fsTempRoot / fsInput.filename().replace_extension(".mcworld");
    NSURL *zipOut = NSURLFromPath(fsZipOut);
    if (!je2be::ZipFile::Zip(fsOutput, fsZipOut, zipProgress)) {
        if (zipProgress.fCancelled) {
            return Result::Error(kJe2beErrorCodeCancelled, sBasename, __LINE__);
        } else {
            return Result::Error(kJe2beErrorCodeIOError, sBasename, __LINE__);
        }
    }
    return Result::Ok(zipOut);
}


Result UnsafeBedrockToJava(id<Converter> converter, NSURL* input, NSString* playerUuidString, NSURL *tempDirectory, id<ConverterDelegate> delegate) {
    namespace fs = std::filesystem;

    fs::path fsInput = PathFromNSURL(input);

    fs::path fsTempRoot = PathFromNSURL(tempDirectory);
    fs::path fsTempUnzip = fsTempRoot / "unzip";
    if (!je2be::Fs::CreateDirectories(fsTempUnzip)) {
        return Result::Error(kJe2beErrorCodeIOError, sBasename, __LINE__);
    }
    
    UnzipProgress unzipProgress(0, converter, delegate);
    if (!je2be::ZipFile::Unzip(fsInput, fsTempUnzip, unzipProgress)) {
        if (unzipProgress.fCancelled) {
            return Result::Error(kJe2beErrorCodeCancelled, sBasename, __LINE__);
        } else {
            return Result::Error(kJe2beErrorCodeUnzipMcworldError, sBasename, __LINE__);
        }
    }
    
    fs::path fsTempOutput = fsTempRoot / "output";
    if (!je2be::Fs::CreateDirectories(fsTempOutput)) {
        return Result::Error(kJe2beErrorCodeIOError, sBasename, __LINE__);
    }
    je2be::toje::Options options;
    options.fTempDirectory = fsTempRoot;
    if (playerUuidString) {
        options.fLocalPlayer = je2be::Uuid::FromString(StringFromNSString(playerUuidString));
    }
    je2be::toje::Converter c(fsTempUnzip, fsTempOutput, options);
    
    ToJeProgress progress(1, converter, delegate);
    if (auto st = c.run(std::thread::hardware_concurrency(), &progress); !st.ok()) {
        if (progress.fCancelled) {
            return Result::Error(kJe2beErrorCodeCancelled, sBasename, __LINE__);
        } else {
            return Result::Error(*st.error());
        }
    }

    ZipProgress zipProgress(2, converter, delegate);
    fs::path fsZipOut = fsTempRoot / fsInput.filename().replace_extension(".zip");
    NSURL *zipOut = NSURLFromPath(fsZipOut);
    if (!je2be::ZipFile::Zip(fsTempOutput, fsZipOut, zipProgress)) {
        if (zipProgress.fCancelled) {
            return Result::Error(kJe2beErrorCodeCancelled, sBasename, __LINE__);
        } else {
            return Result::Error(kJe2beErrorCodeIOError, sBasename, __LINE__);
        }
    }
    return Result::Ok(zipOut);
}


Result UnsafeXbox360ToJava(id<Converter> converter, NSURL* input, NSString *playerUuidString, NSURL *tempDirectory, id<ConverterDelegate> delegate) {
    namespace fs = std::filesystem;

    fs::path fsTempRoot = PathFromNSURL(tempDirectory);
    fs::path fsInput = PathFromNSURL(input);
    
    fs::path fsTempOutput = fsTempRoot / "output";
    if (!je2be::Fs::CreateDirectories(fsTempOutput)) {
        return Result::Error(kJe2beErrorCodeIOError, sBasename, __LINE__);
    }
    
    je2be::box360::Options options;
    options.fTempDirectory = fsTempRoot;
    if (playerUuidString) {
        options.fLocalPlayer = je2be::Uuid::FromString(StringFromNSString(playerUuidString));
    }
    Box360Progress progress(0, converter, delegate);
    je2be::Status st;
    st = je2be::box360::Converter::Run(fsInput, fsTempOutput, std::thread::hardware_concurrency(), options, &progress);
    if (!st.ok()) {
        if (progress.fCancelled) {
            return Result::Error(kJe2beErrorCodeCancelled, sBasename, __LINE__);
        } else {
            return Result::Error(*st.error());
        }
    }

    ZipProgress zipProgress(1, converter, delegate);
    fs::path fsZipOut = fsTempRoot / fsInput.filename().replace_extension(".zip");
    NSURL *zipOut = NSURLFromPath(fsZipOut);
    if (!je2be::ZipFile::Zip(fsTempOutput, fsZipOut, zipProgress)) {
        if (zipProgress.fCancelled) {
            return Result::Error(kJe2beErrorCodeCancelled, sBasename, __LINE__);
        } else {
            return Result::Error(kJe2beErrorCodeIOError, sBasename, __LINE__);
        }
    }
    return Result::Ok(zipOut);
}


Result UnsafeXbox360ToBedrock(id<Converter> converter, NSURL* input, NSURL *tempDirectory, id<ConverterDelegate> delegate) {
    namespace fs = std::filesystem;

    fs::path fsTempRoot = PathFromNSURL(tempDirectory);
    fs::path fsInput = PathFromNSURL(input);
    
    fs::path fsJavaOutput = fsTempRoot / "java";
    if (!je2be::Fs::CreateDirectories(fsJavaOutput)) {
        return Result::Error(kJe2beErrorCodeIOError, sBasename, __LINE__);
    }
    
    {
        je2be::box360::Options options;
        options.fTempDirectory = fsTempRoot;
        Box360Progress progress(0, converter, delegate);
        je2be::Status st = je2be::box360::Converter::Run(fsInput, fsJavaOutput, std::thread::hardware_concurrency(), options, &progress);
        if (!st.ok()) {
            if (progress.fCancelled) {
                return Result::Error(kJe2beErrorCodeCancelled, sBasename, __LINE__);
            } else {
                return Result::Error(*st.error());
            }
        }
    }

    fs::path fsTempOutput = fsTempRoot / "output";
    if (!je2be::Fs::CreateDirectories(fsTempOutput)) {
        return Result::Error(kJe2beErrorCodeIOError, sBasename, __LINE__);
    }
    
    {
        je2be::tobe::Options options;
        options.fTempDirectory = fsTempRoot;
        je2be::tobe::Converter c(fsJavaOutput, fsTempOutput, options);
        ToBeProgress progress(1, converter, delegate);
        auto st = c.run(std::thread::hardware_concurrency(), &progress);
        if (!st) {
            if (progress.fCancelled) {
                return Result::Error(kJe2beErrorCodeCancelled, sBasename, __LINE__);
            } else {
                return Result::Error(kJe2beErrorCodeConverterError, sBasename, __LINE__);
            }
        } else if (!st->fErrors.empty()) {
            return Result::Error(st->fErrors[0].fWhere);
        }
    }
    
    ZipProgress zipProgress(3, converter, delegate);
    fs::path fsZipOut = fsTempRoot / fsInput.filename().replace_extension(".mcworld");
    NSURL *zipOut = NSURLFromPath(fsZipOut);
    if (!je2be::ZipFile::Zip(fsTempOutput, fsZipOut, zipProgress)) {
        if (zipProgress.fCancelled) {
            return Result::Error(kJe2beErrorCodeCancelled, sBasename, __LINE__);
        } else {
            return Result::Error(kJe2beErrorCodeIOError, sBasename, __LINE__);
        }
    }
    return Result::Ok(zipOut);
}


static void NotifyFinishConversion(std::function<Result(void)> convert, id<ConverterDelegate> delegate) {
    try {
        auto result = convert();
        id<ConverterDelegate> d = delegate;
        if (!d) {
            return;
        }
        if (result.fOutput) {
            [d converterDidFinishConversion:result.fOutput error:nil];
        } else if (result.fErrorCode != 0) {
            [d converterDidFinishConversion:nil error:Error(result.fErrorCode, result.fFile, result.fLineNumber)];
        } else {
            [d converterDidFinishConversion:nil error:Error(kJe2beErrorCodeUnknown, sBasename, __LINE__)];
        }
    } catch (std::exception &e) {
        char const* what = e.what();
        NSDictionary *info = nil;
        if (what) {
            info = @{@"what": [[NSString alloc] initWithUTF8String:what]};
        }
        NSError * error = [[NSError alloc] initWithDomain:kJe2beErrorDomain code:kJe2beErrorCodeCxxStdException userInfo:info];
        id<ConverterDelegate> d = delegate;
        if (!d) {
            return;
        }
        [d converterDidFinishConversion:nil error:error];
    } catch (char const* what) {
        NSDictionary *info = nil;
        if (what) {
            info = @{@"what": [[NSString alloc] initWithUTF8String:what]};
        }
        NSError * error = [[NSError alloc] initWithDomain:kJe2beErrorDomain code:kJe2beErrorCodeCxxStdException userInfo:info];
        id<ConverterDelegate> d = delegate;
        if (!d) {
            return;
        }
        [d converterDidFinishConversion:nil error:error];
    } catch (...) {
        NSError * error = [[NSError alloc] initWithDomain:kJe2beErrorDomain code:kJe2beErrorCodeGeneralException userInfo:nil];
        id<ConverterDelegate> d = delegate;
        if (!d) {
            return;
        }
        [d converterDidFinishConversion:nil error:error];
    }
}


extern "C" {

void JavaToBedrock(id<Converter> converter, NSURL* input, NSURL *tempDirectory, id<ConverterDelegate> delegate) {
    NotifyFinishConversion([converter, input, tempDirectory, delegate]() {
        return UnsafeJavaToBedrock(converter, input, tempDirectory, delegate);
    }, delegate);
}


void BedrockToJava(id<Converter> converter, NSURL* input, NSString *playerUuidString, NSURL *tempDirectory, id<ConverterDelegate> delegate) {
    NotifyFinishConversion([converter, input, playerUuidString, tempDirectory, delegate]() {
        return UnsafeBedrockToJava(converter, input, playerUuidString, tempDirectory, delegate);
    }, delegate);
}


void Xbox360ToJava(id<Converter> converter, NSURL* input, NSString *playerUuidString, NSURL *tempDirectory, id<ConverterDelegate> delegate) {
    NotifyFinishConversion([converter, input, playerUuidString, tempDirectory, delegate]() {
        return UnsafeXbox360ToJava(converter, input, playerUuidString, tempDirectory, delegate);
    }, delegate);
}


void Xbox360ToBedrock(id<Converter> converter, NSURL* input, NSURL *tempDirectory, id<ConverterDelegate> delegate) {
    NotifyFinishConversion([converter, input, tempDirectory, delegate]() {
        return UnsafeXbox360ToBedrock(converter, input, tempDirectory, delegate);
    }, delegate);
}

} // extern "C"
