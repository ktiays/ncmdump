#include "libncmdump.h"
#include "ncmcrypt_core.hpp"

#include <filesystem>
#include <new>
#include <stdexcept>
#include <string>

namespace fs = std::filesystem;

struct NeteaseCrypt
{
    NeteaseCryptCore *core{nullptr};
    int lastErrorCode{NCMDUMP_ERROR_NONE};
    std::string lastErrorMessage;
};

static void clearError(NeteaseCrypt *handle)
{
    if (handle == nullptr)
    {
        return;
    }
    handle->lastErrorCode = NCMDUMP_ERROR_NONE;
    handle->lastErrorMessage.clear();
}

static void setError(NeteaseCrypt *handle, int code, const char *message)
{
    if (handle == nullptr)
    {
        return;
    }
    handle->lastErrorCode = code;
    handle->lastErrorMessage = (message != nullptr) ? message : "";
}

extern "C"
{
    API NeteaseCrypt *CreateNeteaseCrypt(const char *path)
    {
        if (path == nullptr)
        {
            return nullptr;
        }

        NeteaseCrypt *handle = new (std::nothrow) NeteaseCrypt();
        if (handle == nullptr)
        {
            return nullptr;
        }

        try
        {
            fs::path filePath = fs::u8path(path);
            handle->core = new NeteaseCryptCore(filePath.u8string());
            clearError(handle);
            return handle;
        }
        catch (...)
        {
            delete handle->core;
            delete handle;
            return nullptr;
        }
    }

    API int Dump(NeteaseCrypt *neteaseCrypt, const char *outputPath)
    {
        if (neteaseCrypt == nullptr || neteaseCrypt->core == nullptr)
        {
            return 1;
        }

        try
        {
            clearError(neteaseCrypt);
            const char *targetDir = (outputPath == nullptr) ? "" : outputPath;
            neteaseCrypt->core->Dump(targetDir);
            return 0;
        }
        catch (const std::invalid_argument &e)
        {
            setError(neteaseCrypt, NCMDUMP_ERROR_INVALID_ARGUMENT, e.what());
            return 1;
        }
        catch (const std::runtime_error &e)
        {
            setError(neteaseCrypt, NCMDUMP_ERROR_RUNTIME, e.what());
            return 1;
        }
        catch (const std::exception &e)
        {
            setError(neteaseCrypt, NCMDUMP_ERROR_UNKNOWN, e.what());
            return 1;
        }
        catch (...)
        {
            setError(neteaseCrypt, NCMDUMP_ERROR_UNKNOWN, "Unknown exception");
            return 1;
        }
    }

    API void FixMetadata(NeteaseCrypt *neteaseCrypt)
    {
        if (neteaseCrypt == nullptr || neteaseCrypt->core == nullptr)
        {
            return;
        }

        try
        {
            clearError(neteaseCrypt);
            neteaseCrypt->core->FixMetadata();
        }
        catch (const std::invalid_argument &e)
        {
            setError(neteaseCrypt, NCMDUMP_ERROR_INVALID_ARGUMENT, e.what());
        }
        catch (const std::runtime_error &e)
        {
            setError(neteaseCrypt, NCMDUMP_ERROR_RUNTIME, e.what());
        }
        catch (const std::exception &e)
        {
            setError(neteaseCrypt, NCMDUMP_ERROR_UNKNOWN, e.what());
        }
        catch (...)
        {
            setError(neteaseCrypt, NCMDUMP_ERROR_UNKNOWN, "Unknown exception");
        }
    }

    API void DestroyNeteaseCrypt(NeteaseCrypt *neteaseCrypt)
    {
        if (neteaseCrypt == nullptr)
        {
            return;
        }

        delete neteaseCrypt->core;
        neteaseCrypt->core = nullptr;
        delete neteaseCrypt;
    }

    API int GetLastErrorCode(const NeteaseCrypt *neteaseCrypt)
    {
        if (neteaseCrypt == nullptr)
        {
            return NCMDUMP_ERROR_INVALID_HANDLE;
        }
        return neteaseCrypt->lastErrorCode;
    }

    API const char *GetLastErrorMessage(const NeteaseCrypt *neteaseCrypt)
    {
        if (neteaseCrypt == nullptr)
        {
            return "Invalid handle";
        }
        return neteaseCrypt->lastErrorMessage.c_str();
    }
}
