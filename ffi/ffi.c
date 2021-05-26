#include <ffi_platypus_bundle.h>
#include <string.h>
#include <stdint.h>
#include <sodium.h>

#define _str(name) c->set_str(#name, name)
#define _sint(name) c->set_sint(#name, name)

void
ffi_pl_bundle_constant(const char* package, ffi_platypus_constant_t* c)
{
    _str(SODIUM_VERSION_STRING);

    _sint(SODIUM_LIBRARY_VERSION_MAJOR);
    _sint(SODIUM_LIBRARY_VERSION_MINOR);
}

void
ffi_pl_bundle_init(const char* package, int argc, void* argv[])
{
    /* printf("Begin with sodium_init()\n"); */
    if (sodium_init() < 0) {
        printf("Could not initialize libsodium.");
    }
}
