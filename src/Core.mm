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
    
    NSURL* temp = CreateTempDir();
    NSURL* output = nullptr;
    defer {
        [d converterDidFinishConversion:output];
        je2be::Fs::DeleteAll(fs::path([temp.path cStringUsingEncoding:NSUTF8StringEncoding]));
    };
    if (![input startAccessingSecurityScopedResource]) {
        return;
    }
    if (!temp) {
        return;
    }
    if (!Unzip(input, temp, converter, 0, delegate)) {
        return;
    }
}
