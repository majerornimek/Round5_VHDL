/*
 * Copyright (c) 2018, PQShield
 * Markku-Juhani O. Saarinen
 *
 * All rights reserved. A copyright license for redistribution and use in
 * source and binary forms, with or without modification, is hereby granted for
 * non-commercial, experimental, research, public review and evaluation
 * purposes, provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

//  Endian-neutral parametrized reference implementation of the XEf codes.

#include <stdint.h>
#include <stddef.h>
#include <string.h>

// register lengths

const unsigned xef_reg[5][3][10] = {
    {
        { 11, 13 }, // XE1-24
        { 13, 15 }, // XE1-28
        { 16, 16 }  // XE1-32
    }, {
        { 11, 13, 14, 15 }, // XE2-53
        { 13, 15, 16, 17 }, // XE2-61
        { 16, 16, 17, 19 }  // XE2-68
    }, {
        { 11, 13, 15, 16, 17, 19 }, // XE3-91
        { 13, 15, 16, 17, 19, 23 }, // XE3-103
        { 16, 16, 17, 19, 21, 23 }  // XE3-112
    }, {
        { 11, 13, 16, 17, 19, 21, 23, 29 }, // XE4-149
        { 13, 15, 16, 17, 19, 23, 29, 31 }, // XE4-163
        { 16, 16, 17, 19, 21, 23, 25, 29 }  // XE4-166
    }, {
        { 16, 11, 13, 16, 17, 19, 21, 23, 25, 29 }, // XE5-190
        { 24, 13, 16, 17, 19, 21, 23, 25, 29, 31 }, // XE5-218
        { 16, 16, 17, 19, 21, 23, 25, 29, 31, 37 }  // XE5-234
    }
};

//      { {16, 11, 13, 16, 17, 19, 21, 23, 25, 29 },

//  Computes the parity code, XORs it at the end of payload
//  len = payload (bytes). Returns (payload | xef) length in *bits*.

size_t xef_compute(size_t len, unsigned f)
{
    //uint8_t *v = (uint8_t *) block;
    size_t i, j, l, bit, pl;
    uint64_t x, t, r[10];

    if (f <= 0 || f > 5)
        return len;

    if (len <= 16) {
        pl = 0;
    } else {
        if (len <= 24) {
            pl = 1;
        } else {
            if (len <= 32) {
                pl = 2;
            } else {
                return len;
            }
        }
    }

    memset(r, 0, sizeof(r));

    // reduce the polynomials
    bit = 0;
    for (i = 0; i < len; i++) {
        //x = (uint64_t) v[i];

        // special parity
        if (pl == 2 || f == 5) {
           // t = x;
           // t ^= t >> 4;
           // t ^= t >> 2;
           // t ^= t >> 1;

            //if (pl == 2)
             //   r[0] ^= (t & 1) << (i >> 1);
            //else
              //  r[0] ^= (t & 1) << i;
            j = 1;
        } else {
            j = 0;
        }

        // cyclic polynomial case
        for (; j < 2 * f; j++) {
           // r[j] ^= x << (bit % xef_reg[f - 1][pl][j]);
            printf("%d, ", bit % xef_reg[f-1][pl][j]);

        }
        printf("|\n");
        bit += 8;
    }

    // pack the result (or rather, XOR over the original)

    for (i = 0; i < 2 * f; i++) {

        l = xef_reg[f - 1][pl][i];      // len
        //x = r[i];
        //x ^= x >> l;

        for (j = 0; j < l; j++) {
           // v[bit >> 3] = (uint8_t) (v[bit >> 3] ^ (((x >> j) & 1) << (bit & 7)));
            printf("%d, %d, %d, %d, %d, %d\n", i, j, l, bit, bit>>3, bit & 7);
            bit++;
        }
    }

    // return the true length
    printf("BIT LEN: %d\n", bit);
    return bit;
}

//  Fixes errors based on parity code. Call xef_compute() first to get delta.
//  len = payload (bytes). Returns (payload | xef) length in *bits*.

size_t xef_fixerr(size_t len, unsigned f)
{
    //uint8_t *v = (uint8_t *) block;
    size_t i, j, l, bit;
    uint64_t r[10];
    unsigned pl, th;

    if (f <= 0 || f > 5)
        return len;

    if (len <= 16) {
        pl = 0;
    } else {
        if (len <= 24) {
            pl = 1;
        } else {
            if (len <= 32) {
                pl = 2;
            } else {
                return len;
            }
        }
    }

    // unpack the registers
    //memset(r, 0, sizeof(r));
    bit = len << 3;
    for (i = 0; i < 2 * f; i++) {
        l = xef_reg[f - 1][pl][i];      // len
        for (j = 0; j < l; j++) {
            //r[i] ^= ((uint64_t) ((v[bit >> 3] >> (bit & 7)) & 1)) << j;
            printf("%d, %d, %d, %d, %d\n", i, j, l, bit>>3, bit & 7);

            bit++;
        }
    }
    printf("-------------------------\n");
    // fix errors
    for (i = 0; i < (len << 3); i++) {
        //printf("\nDla i = %d, ",i);
        //printf("%d, ",i);
        th = 7 - f;

        if (pl == 2) {
            //th += (unsigned) (r[0] >> (i >> 4)) & 1;
            printf(" %d, ",i>>4);
            //printf("(std_logic_vector(to_unsigned(%d,6)), ", i>>4);
            j = 1;
        } else {
            if (f == 5) {
                //th += (unsigned) (r[0] >> (i >> 3)) & 1;
                j = 1;
            } else {
                j = 0;
            }
        }
        //printf(" przesuniecia w for: ");
        for (; j < 2 * f; j++) {
            //th += (unsigned) (r[j] >> (i %  xef_reg[f - 1][pl][j])) & 1;
            printf("%d, ", i%xef_reg[f-1][pl][j]);
            //printf("std_logic_vector(to_unsigned(%d,6)), ", i%xef_reg[f-1][pl][j]);
        }
        // if th > f
//        v[i >> 3] = (uint8_t) (v[i >> 3] ^ ((th >> 3) << (i & 7)));
        //printf("std_logic_vector(to_unsigned(%d,6))),\n",i&7);
        printf("%d, %d \n", i >>3, i&7);
    }

    // return the true length
    printf("BIT LEN: %d\n", bit);
    return bit;
}


void main()
{
    
    printf("FIXERR: ======================================\n");
    xef_fixerr(32,5);
    printf("COMPUTE: =====================================\n");
    xef_compute(32,5);
    return 0;

}
