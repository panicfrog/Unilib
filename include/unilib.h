#ifndef UNILIBT_H
#define UNILIBT_H

#include "moonbit.h"

#ifdef __cplusplus
extern "C" {
#endif

extern moonbit_bytes_t $panicfrog$unilib$greeting_native(void);
extern moonbit_bytes_t moonbit_init(void);

static inline moonbit_bytes_t greeting_native_raw(void)
{
    moonbit_bytes_t bytes = $panicfrog$unilib$greeting_native();
    return bytes;
}

static inline const char *greeting_native_cstr(void)
{
    return (const char *) greeting_native_raw();
}

void free_native_bytes(void *bytes)
{
    moonbit_decref(bytes);
}

#ifdef __cplusplus
}
#endif

#endif // UNILIBT_H