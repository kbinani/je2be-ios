#import "Core.h"
#include <je2be.hpp>

static NSURL* CreateTempDir() {
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

static NSURL* CreateTempFile(NSString * _Nonnull extWithDot) {
    NSFileManager* manager = [NSFileManager defaultManager];
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString* path = [manager.temporaryDirectory.path stringByAppendingPathComponent:[[uuid UUIDString] stringByAppendingString:extWithDot]];
    return [[NSURL alloc] initFileURLWithPath:path];
}

static std::filesystem::path PathFromNSURL(NSURL * _Nonnull url) {
    return std::filesystem::path([[url path] cStringUsingEncoding:NSUTF8StringEncoding]);
}

static bool Unzip(NSURL *input, NSURL *directory, id<Converter> converter, int step, id<ConverterDelegate> delegate) {
    namespace fs = std::filesystem;

    if (!input) {
        return false;
    }
    if (!directory) {
        return false;
    }
    void *handle = nullptr;
    void *stream = nullptr;
    uint64_t numEntries = 0;
    uint64_t done = 0;

    handle = mz_zip_create(nullptr);
    if (!handle) {
        goto fail;
    }
    stream = mz_stream_os_create(nullptr);
    if (!stream) {
        goto fail;
    }
    if (mz_stream_os_open(stream, [input.path cStringUsingEncoding:NSUTF8StringEncoding], MZ_OPEN_MODE_READ) != MZ_OK) {
        goto fail;
    }
    if (mz_zip_open(handle, stream, MZ_OPEN_MODE_READ) != MZ_OK) {
        goto fail;
    }
    if (mz_zip_get_number_entry(handle, &numEntries) != MZ_OK) {
        goto fail;
    }
    
    if (mz_zip_goto_first_entry(handle) != MZ_OK) {
        // no entry in file
        goto ok;
    }
    if (![delegate converterDidUpdateProgress:converter step:step done:0 total:numEntries]) {
        goto fail;
    }
    do {
        if (mz_zip_entry_is_dir(handle) == MZ_OK) {
            done++;
            continue;
        }
        mz_zip_file* fileInfo = nullptr;
        if (mz_zip_entry_get_info(handle, &fileInfo) != MZ_OK) {
            goto fail;
        }
        if (mz_zip_entry_read_open(handle, 0, nullptr) != MZ_OK) {
            goto fail;
        }
        defer {
            mz_zip_entry_close(handle);
        };
        int64_t remaining = fileInfo->uncompressed_size;
        NSString* relFilePath = [[NSString alloc] initWithUTF8String:fileInfo->filename];
        NSString* fullFilePath = [directory.path stringByAppendingPathComponent:relFilePath];
        fs::path parentDir = fs::path([fullFilePath cStringUsingEncoding:NSUTF8StringEncoding]).parent_path();
        je2be::Fs::CreateDirectories(parentDir);
        je2be::ScopedFile fp(fopen([fullFilePath cStringUsingEncoding:NSUTF8StringEncoding], "w+b"));
        if (!fp) {
            goto fail;
        }
        std::vector<uint8_t> chunk(1024);
        while (remaining > 0) {
            int32_t amount = (int32_t)(std::min)(remaining, (int64_t)chunk.size());
            int32_t read = mz_zip_entry_read(handle, chunk.data(), amount);
            if (read < 0) {
                goto fail;
            }
            if (fwrite(chunk.data(), 1, read, fp) != read) {
                goto fail;
            }
            remaining -= amount;
        }
        done++;
        if (![delegate converterDidUpdateProgress:converter step:step done:done total:numEntries]) {
            goto fail;
        }
    } while (mz_zip_goto_next_entry(handle) == MZ_OK);
    
    goto ok;
    
fail:
    if (stream) {
        mz_stream_os_delete(&stream);
    }
    if (handle) {
        mz_zip_delete(&handle);
    }
    return false;
ok:
    if (stream) {
        mz_stream_os_delete(&stream);
    }
    if (handle) {
        mz_zip_delete(&handle);
    }
    return true;
}

void JavaToBedrock(id<Converter> converter, NSURL* input, __weak id<ConverterDelegate> delegate) {
    namespace fs = std::filesystem;
    
    id<ConverterDelegate> d = delegate;
    if (!d) {
        return;
    }
    
    NSURL* tempInput = CreateTempDir();
    if (!tempInput) {
        return;
    }
    fs::path fsInput = PathFromNSURL(tempInput);
    NSURL* output = nullptr;
    defer {
        [d converterDidFinishConversion:output];
        je2be::Fs::DeleteAll(fsInput);
    };
    if (![input startAccessingSecurityScopedResource]) {
        return;
    }
    if (!Unzip(input, tempInput, converter, 0, delegate)) {
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
    fs::path fsActualInput = fsInput;
    std::error_code ec;
    for (auto it : fs::recursive_directory_iterator(fsInput, ec)) {
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

    int totalFiles = 0;
    for (auto it : fs::recursive_directory_iterator(fsOutput, ec)) {
        if (fs::is_regular_file(it.path())) {
            totalFiles++;
        }
    }
    if (ec) {
        return;
    }
    if (![delegate converterDidUpdateProgress:converter step:3 done:0 total:totalFiles]) {
        return;
    }
    
    NSURL *zipOut = CreateTempFile(@".mcworld");
    je2be::ZipFile zipOutFile(PathFromNSURL(zipOut));
    int totalZippedFiles = 0;
    for (auto it : fs::recursive_directory_iterator(fsOutput, ec)) {
        auto path = it.path();
        if (!fs::is_regular_file(path)) {
            continue;
        }
        std::error_code ec1;
        fs::path rel = fs::relative(path, fsOutput, ec1);
        if (ec1) {
            return;
        }
        std::vector<uint8_t> buffer;
        auto stream = std::make_shared<mcfile::stream::FileInputStream>(path);
        mcfile::stream::InputStream::ReadUntilEos(*stream, buffer);
        if (!zipOutFile.store(buffer, rel.string())) {
            return;
        }
        totalZippedFiles++;
        if (![delegate converterDidUpdateProgress:converter step:3 done:totalZippedFiles total:totalFiles]) {
            return;
        }
    }
    if (ec) {
        return;
    }
    if (!zipOutFile.close()) {
        return;
    }
    output = zipOut;
}
