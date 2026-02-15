#pragma once

#ifdef _WIN32
#define API __declspec(dllexport)
#else
#define API
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct NeteaseCrypt NeteaseCrypt;

enum
{
    NCMDUMP_ERROR_NONE = 0,
    NCMDUMP_ERROR_INVALID_ARGUMENT = 1,
    NCMDUMP_ERROR_RUNTIME = 2,
    NCMDUMP_ERROR_UNKNOWN = 3,
    NCMDUMP_ERROR_INVALID_HANDLE = 4
};

API NeteaseCrypt *CreateNeteaseCrypt(const char *path);
API int Dump(NeteaseCrypt *neteaseCrypt, const char *outputPath);
API void FixMetadata(NeteaseCrypt *neteaseCrypt);
API void DestroyNeteaseCrypt(NeteaseCrypt *neteaseCrypt);

API int GetLastErrorCode(const NeteaseCrypt *neteaseCrypt);
API const char *GetLastErrorMessage(const NeteaseCrypt *neteaseCrypt);

#ifdef __cplusplus
}
#endif
