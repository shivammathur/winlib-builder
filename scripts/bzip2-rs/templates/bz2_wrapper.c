#include "bzlib.h"

#ifdef _WIN32
#define BZIP2_RS_CALL __cdecl
#else
#define BZIP2_RS_CALL
#endif

extern int BZIP2_RS_CALL bzip2_rs_BZ2_bzCompressInit(bz_stream *strm, int blockSize100k, int verbosity, int workFactor);
extern int BZIP2_RS_CALL bzip2_rs_BZ2_bzCompress(bz_stream *strm, int action);
extern int BZIP2_RS_CALL bzip2_rs_BZ2_bzCompressEnd(bz_stream *strm);
extern int BZIP2_RS_CALL bzip2_rs_BZ2_bzDecompressInit(bz_stream *strm, int verbosity, int small);
extern int BZIP2_RS_CALL bzip2_rs_BZ2_bzDecompress(bz_stream *strm);
extern int BZIP2_RS_CALL bzip2_rs_BZ2_bzDecompressEnd(bz_stream *strm);
extern BZFILE * BZIP2_RS_CALL bzip2_rs_BZ2_bzReadOpen(int *bzerror, FILE *f, int verbosity, int small, void *unused, int nUnused);
extern void BZIP2_RS_CALL bzip2_rs_BZ2_bzReadClose(int *bzerror, BZFILE *b);
extern void BZIP2_RS_CALL bzip2_rs_BZ2_bzReadGetUnused(int *bzerror, BZFILE *b, void **unused, int *nUnused);
extern int BZIP2_RS_CALL bzip2_rs_BZ2_bzRead(int *bzerror, BZFILE *b, void *buf, int len);
extern BZFILE * BZIP2_RS_CALL bzip2_rs_BZ2_bzWriteOpen(int *bzerror, FILE *f, int blockSize100k, int verbosity, int workFactor);
extern void BZIP2_RS_CALL bzip2_rs_BZ2_bzWrite(int *bzerror, BZFILE *b, void *buf, int len);
extern void BZIP2_RS_CALL bzip2_rs_BZ2_bzWriteClose(int *bzerror, BZFILE *b, int abandon, unsigned int *nbytes_in, unsigned int *nbytes_out);
extern void BZIP2_RS_CALL bzip2_rs_BZ2_bzWriteClose64(int *bzerror, BZFILE *b, int abandon, unsigned int *nbytes_in_lo32, unsigned int *nbytes_in_hi32, unsigned int *nbytes_out_lo32, unsigned int *nbytes_out_hi32);
extern int BZIP2_RS_CALL bzip2_rs_BZ2_bzBuffToBuffCompress(char *dest, unsigned int *destLen, char *source, unsigned int sourceLen, int blockSize100k, int verbosity, int workFactor);
extern int BZIP2_RS_CALL bzip2_rs_BZ2_bzBuffToBuffDecompress(char *dest, unsigned int *destLen, char *source, unsigned int sourceLen, int small, int verbosity);
extern const char * BZIP2_RS_CALL bzip2_rs_BZ2_bzlibVersion(void);
extern BZFILE * BZIP2_RS_CALL bzip2_rs_BZ2_bzopen(const char *path, const char *mode);
extern BZFILE * BZIP2_RS_CALL bzip2_rs_BZ2_bzdopen(int fd, const char *mode);
extern int BZIP2_RS_CALL bzip2_rs_BZ2_bzread(BZFILE *b, void *buf, int len);
extern int BZIP2_RS_CALL bzip2_rs_BZ2_bzwrite(BZFILE *b, void *buf, int len);
extern int BZIP2_RS_CALL bzip2_rs_BZ2_bzflush(BZFILE *b);
extern void BZIP2_RS_CALL bzip2_rs_BZ2_bzclose(BZFILE *b);
extern const char * BZIP2_RS_CALL bzip2_rs_BZ2_bzerror(BZFILE *b, int *errnum);

int BZ_API(BZ2_bzCompressInit)(bz_stream *strm, int blockSize100k, int verbosity, int workFactor)
{
    return bzip2_rs_BZ2_bzCompressInit(strm, blockSize100k, verbosity, workFactor);
}

int BZ_API(BZ2_bzCompress)(bz_stream *strm, int action)
{
    return bzip2_rs_BZ2_bzCompress(strm, action);
}

int BZ_API(BZ2_bzCompressEnd)(bz_stream *strm)
{
    return bzip2_rs_BZ2_bzCompressEnd(strm);
}

int BZ_API(BZ2_bzDecompressInit)(bz_stream *strm, int verbosity, int small)
{
    return bzip2_rs_BZ2_bzDecompressInit(strm, verbosity, small);
}

int BZ_API(BZ2_bzDecompress)(bz_stream *strm)
{
    return bzip2_rs_BZ2_bzDecompress(strm);
}

int BZ_API(BZ2_bzDecompressEnd)(bz_stream *strm)
{
    return bzip2_rs_BZ2_bzDecompressEnd(strm);
}

BZFILE * BZ_API(BZ2_bzReadOpen)(int *bzerror, FILE *f, int verbosity, int small, void *unused, int nUnused)
{
    return bzip2_rs_BZ2_bzReadOpen(bzerror, f, verbosity, small, unused, nUnused);
}

void BZ_API(BZ2_bzReadClose)(int *bzerror, BZFILE *b)
{
    bzip2_rs_BZ2_bzReadClose(bzerror, b);
}

void BZ_API(BZ2_bzReadGetUnused)(int *bzerror, BZFILE *b, void **unused, int *nUnused)
{
    bzip2_rs_BZ2_bzReadGetUnused(bzerror, b, unused, nUnused);
}

int BZ_API(BZ2_bzRead)(int *bzerror, BZFILE *b, void *buf, int len)
{
    return bzip2_rs_BZ2_bzRead(bzerror, b, buf, len);
}

BZFILE * BZ_API(BZ2_bzWriteOpen)(int *bzerror, FILE *f, int blockSize100k, int verbosity, int workFactor)
{
    return bzip2_rs_BZ2_bzWriteOpen(bzerror, f, blockSize100k, verbosity, workFactor);
}

void BZ_API(BZ2_bzWrite)(int *bzerror, BZFILE *b, void *buf, int len)
{
    bzip2_rs_BZ2_bzWrite(bzerror, b, buf, len);
}

void BZ_API(BZ2_bzWriteClose)(int *bzerror, BZFILE *b, int abandon, unsigned int *nbytes_in, unsigned int *nbytes_out)
{
    bzip2_rs_BZ2_bzWriteClose(bzerror, b, abandon, nbytes_in, nbytes_out);
}

void BZ_API(BZ2_bzWriteClose64)(int *bzerror, BZFILE *b, int abandon, unsigned int *nbytes_in_lo32, unsigned int *nbytes_in_hi32, unsigned int *nbytes_out_lo32, unsigned int *nbytes_out_hi32)
{
    bzip2_rs_BZ2_bzWriteClose64(bzerror, b, abandon, nbytes_in_lo32, nbytes_in_hi32, nbytes_out_lo32, nbytes_out_hi32);
}

int BZ_API(BZ2_bzBuffToBuffCompress)(char *dest, unsigned int *destLen, char *source, unsigned int sourceLen, int blockSize100k, int verbosity, int workFactor)
{
    return bzip2_rs_BZ2_bzBuffToBuffCompress(dest, destLen, source, sourceLen, blockSize100k, verbosity, workFactor);
}

int BZ_API(BZ2_bzBuffToBuffDecompress)(char *dest, unsigned int *destLen, char *source, unsigned int sourceLen, int small, int verbosity)
{
    return bzip2_rs_BZ2_bzBuffToBuffDecompress(dest, destLen, source, sourceLen, small, verbosity);
}

const char * BZ_API(BZ2_bzlibVersion)(void)
{
    return bzip2_rs_BZ2_bzlibVersion();
}

BZFILE * BZ_API(BZ2_bzopen)(const char *path, const char *mode)
{
    return bzip2_rs_BZ2_bzopen(path, mode);
}

BZFILE * BZ_API(BZ2_bzdopen)(int fd, const char *mode)
{
    return bzip2_rs_BZ2_bzdopen(fd, mode);
}

int BZ_API(BZ2_bzread)(BZFILE *b, void *buf, int len)
{
    return bzip2_rs_BZ2_bzread(b, buf, len);
}

int BZ_API(BZ2_bzwrite)(BZFILE *b, void *buf, int len)
{
    return bzip2_rs_BZ2_bzwrite(b, buf, len);
}

int BZ_API(BZ2_bzflush)(BZFILE *b)
{
    return bzip2_rs_BZ2_bzflush(b);
}

void BZ_API(BZ2_bzclose)(BZFILE *b)
{
    bzip2_rs_BZ2_bzclose(b);
}

const char * BZ_API(BZ2_bzerror)(BZFILE *b, int *errnum)
{
    return bzip2_rs_BZ2_bzerror(b, errnum);
}
