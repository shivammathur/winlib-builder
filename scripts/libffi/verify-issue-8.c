#include <ffi.h>

#include <stdint.h>
#include <stdio.h>

#ifdef _MSC_VER
# define NOINLINE __declspec(noinline)
#else
# define NOINLINE __attribute__((noinline))
#endif

static NOINLINE int64_t add_int64(int64_t a, int64_t b)
{
    return a + b;
}

static NOINLINE int64_t sum_five_int64(int64_t a, int64_t b, int64_t c, int64_t d, int64_t e)
{
    return a + b + c + d + e;
}

static NOINLINE double mix_double_int(double a, int32_t b, double c, int64_t d)
{
    return a + (double) b + c + (double) d;
}

static int check_int64_add(void)
{
    ffi_cif cif;
    ffi_type *args[2] = { &ffi_type_sint64, &ffi_type_sint64 };
    int64_t left = 3;
    int64_t right = 4;
    int64_t result = 0;
    void *values[2] = { &left, &right };

    if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 2, &ffi_type_sint64, args) != FFI_OK) {
        puts("ffi_prep_cif failed for int64 add");
        return 1;
    }

    ffi_call(&cif, FFI_FN(add_int64), &result, values);
    if (result != 7) {
        printf("int64 add mismatch: expected 7, got %lld\n", (long long) result);
        return 1;
    }

    return 0;
}

static int check_stack_int64_args(void)
{
    ffi_cif cif;
    ffi_type *args[5] = {
        &ffi_type_sint64,
        &ffi_type_sint64,
        &ffi_type_sint64,
        &ffi_type_sint64,
        &ffi_type_sint64
    };
    int64_t a = 10;
    int64_t b = 20;
    int64_t c = 30;
    int64_t d = 40;
    int64_t e = 50;
    int64_t result = 0;
    void *values[5] = { &a, &b, &c, &d, &e };

    if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 5, &ffi_type_sint64, args) != FFI_OK) {
        puts("ffi_prep_cif failed for five int64 args");
        return 1;
    }

    ffi_call(&cif, FFI_FN(sum_five_int64), &result, values);
    if (result != 150) {
        printf("five int64 mismatch: expected 150, got %lld\n", (long long) result);
        return 1;
    }

    return 0;
}

static int check_mixed_float_int_args(void)
{
    ffi_cif cif;
    ffi_type *args[4] = {
        &ffi_type_double,
        &ffi_type_sint32,
        &ffi_type_double,
        &ffi_type_sint64
    };
    double a = 1.25;
    int32_t b = 2;
    double c = 3.5;
    int64_t d = 4;
    double result = 0.0;
    void *values[4] = { &a, &b, &c, &d };

    if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 4, &ffi_type_double, args) != FFI_OK) {
        puts("ffi_prep_cif failed for mixed args");
        return 1;
    }

    ffi_call(&cif, FFI_FN(mix_double_int), &result, values);
    if (result != 10.75) {
        printf("mixed args mismatch: expected 10.75, got %.17g\n", result);
        return 1;
    }

    return 0;
}

int main(void)
{
    int failures = 0;

    failures += check_int64_add();
    failures += check_stack_int64_args();
    failures += check_mixed_float_int_args();

    if (failures != 0) {
        printf("libffi issue 8 verification failed: %d failure(s)\n", failures);
        return 1;
    }

    puts("libffi issue 8 verification passed");
    return 0;
}
