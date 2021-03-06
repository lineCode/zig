// TODO https://github.com/zig-lang/zig/issues/305
// and then make the return types of some of these functions the enum instead of c_int
const LE_LESS = c_int(-1);
const LE_EQUAL = c_int(0);
const LE_GREATER = c_int(1);
const LE_UNORDERED = c_int(1);

const rep_t = u128;
const srep_t = i128;

const typeWidth = rep_t.bit_count;
const significandBits = 112;
const exponentBits = (typeWidth - significandBits - 1);
const signBit = (rep_t(1) << (significandBits + exponentBits));
const absMask = signBit - 1;
const implicitBit = rep_t(1) << significandBits;
const significandMask = implicitBit - 1;
const exponentMask = absMask ^ significandMask;
const infRep = exponentMask;

const builtin = @import("builtin");
const is_test = builtin.is_test;

export fn __letf2(a: f128, b: f128) -> c_int {
    @setDebugSafety(this, is_test);
    @setGlobalLinkage(__letf2, builtin.GlobalLinkage.LinkOnce);

    const aInt = @bitCast(rep_t, a);
    const bInt = @bitCast(rep_t, b);

    const aAbs: rep_t = aInt & absMask;
    const bAbs: rep_t = bInt & absMask;

    // If either a or b is NaN, they are unordered.
    if (aAbs > infRep or bAbs > infRep) return LE_UNORDERED;

    // If a and b are both zeros, they are equal.
    if ((aAbs | bAbs) == 0) return LE_EQUAL;

    // If at least one of a and b is positive, we get the same result comparing
    // a and b as signed integers as we would with a floating-point compare.
    return if ((aInt & bInt) >= 0) {
        if (aInt < bInt) {
            LE_LESS
        } else if (aInt == bInt) {
            LE_EQUAL
        } else {
            LE_GREATER
        }
    } else {
        // Otherwise, both are negative, so we need to flip the sense of the
        // comparison to get the correct result.  (This assumes a twos- or ones-
        // complement integer representation; if integers are represented in a
        // sign-magnitude representation, then this flip is incorrect).
        if (aInt > bInt) {
            LE_LESS
        } else if (aInt == bInt) {
            LE_EQUAL
        } else {
            LE_GREATER
        }
    };
}

// Alias for libgcc compatibility
// TODO https://github.com/zig-lang/zig/issues/420
export fn __cmptf2(a: f128, b: f128) -> c_int {
    @setGlobalLinkage(__cmptf2, builtin.GlobalLinkage.LinkOnce);
    @setDebugSafety(this, is_test);
    return __letf2(a, b);
}

// TODO https://github.com/zig-lang/zig/issues/305
// and then make the return types of some of these functions the enum instead of c_int
const GE_LESS = c_int(-1);
const GE_EQUAL = c_int(0);
const GE_GREATER = c_int(1);
const GE_UNORDERED = c_int(-1); // Note: different from LE_UNORDERED

export fn __getf2(a: f128, b: f128) -> c_int {
    @setGlobalLinkage(__getf2, builtin.GlobalLinkage.LinkOnce);
    @setDebugSafety(this, is_test);

    const aInt = @bitCast(srep_t, a);
    const bInt = @bitCast(srep_t, b);
    const aAbs = @bitCast(rep_t, aInt) & absMask;
    const bAbs = @bitCast(rep_t, bInt) & absMask;

    if (aAbs > infRep or bAbs > infRep) return GE_UNORDERED;
    if ((aAbs | bAbs) == 0) return GE_EQUAL;
    return if ((aInt & bInt) >= 0) {
        if (aInt < bInt) {
            GE_LESS
        } else if (aInt == bInt) {
            GE_EQUAL
        } else {
            GE_GREATER
        }
    } else {
        if (aInt > bInt) {
            GE_LESS
        } else if (aInt == bInt) {
            GE_EQUAL
        } else {
            GE_GREATER
        }
    };
}

export fn __unordtf2(a: f128, b: f128) -> c_int {
    @setGlobalLinkage(__unordtf2, builtin.GlobalLinkage.LinkOnce);
    @setDebugSafety(this, is_test);

    const aAbs = @bitCast(rep_t, a) & absMask;
    const bAbs = @bitCast(rep_t, b) & absMask;
    return c_int(aAbs > infRep or bAbs > infRep);
}

// The following are alternative names for the preceding routines.

export fn __eqtf2(a: f128, b: f128) -> c_int {
    @setGlobalLinkage(__eqtf2, builtin.GlobalLinkage.LinkOnce);
    @setDebugSafety(this, is_test);
    return __letf2(a, b);
}

export fn __lttf2(a: f128, b: f128) -> c_int {
    @setGlobalLinkage(__lttf2, builtin.GlobalLinkage.LinkOnce);
    @setDebugSafety(this, is_test);
    return __letf2(a, b);
}

export fn __netf2(a: f128, b: f128) -> c_int {
    @setGlobalLinkage(__netf2, builtin.GlobalLinkage.LinkOnce);
    @setDebugSafety(this, is_test);
    return __letf2(a, b);
}

export fn __gttf2(a: f128, b: f128) -> c_int {
    @setGlobalLinkage(__gttf2, builtin.GlobalLinkage.LinkOnce);
    @setDebugSafety(this, is_test);
    return __getf2(a, b);
}
