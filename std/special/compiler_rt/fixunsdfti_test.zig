const __fixunsdfti = @import("fixunsdfti.zig").__fixunsdfti;
const assert = @import("../../debug.zig").assert;

fn test__fixunsdfti(a: f64, expected: u128) {
    const x = __fixunsdfti(a);
    assert(x == expected);
}

test "fixunsdfti" {
    test__fixunsdfti(0.0, 0);

    test__fixunsdfti(0.5, 0);
    test__fixunsdfti(0.99, 0);
    test__fixunsdfti(1.0, 1);
    test__fixunsdfti(1.5, 1);
    test__fixunsdfti(1.99, 1);
    test__fixunsdfti(2.0, 2);
    test__fixunsdfti(2.01, 2);
    test__fixunsdfti(-0.5, 0);
    test__fixunsdfti(-0.99, 0);
    test__fixunsdfti(-1.0, 0);
    test__fixunsdfti(-1.5, 0);
    test__fixunsdfti(-1.99, 0);
    test__fixunsdfti(-2.0, 0);
    test__fixunsdfti(-2.01, 0);

    test__fixunsdfti(0x1.FFFFFEp+62, 0x7FFFFF8000000000);
    test__fixunsdfti(0x1.FFFFFCp+62, 0x7FFFFF0000000000);

    test__fixunsdfti(-0x1.FFFFFEp+62, 0);
    test__fixunsdfti(-0x1.FFFFFCp+62, 0);

    test__fixunsdfti(0x1.FFFFFFFFFFFFFp+63, 0xFFFFFFFFFFFFF800);
    test__fixunsdfti(0x1.0000000000000p+63, 0x8000000000000000);
    test__fixunsdfti(0x1.FFFFFFFFFFFFFp+62, 0x7FFFFFFFFFFFFC00);
    test__fixunsdfti(0x1.FFFFFFFFFFFFEp+62, 0x7FFFFFFFFFFFF800);

    test__fixunsdfti(0x1.FFFFFFFFFFFFFp+127, 0xFFFFFFFFFFFFF8000000000000000000);
    test__fixunsdfti(0x1.0000000000000p+127, 0x80000000000000000000000000000000);
    test__fixunsdfti(0x1.FFFFFFFFFFFFFp+126, 0x7FFFFFFFFFFFFC000000000000000000);
    test__fixunsdfti(0x1.FFFFFFFFFFFFEp+126, 0x7FFFFFFFFFFFF8000000000000000000);
    test__fixunsdfti(0x1.0000000000000p+128, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

    test__fixunsdfti(-0x1.FFFFFFFFFFFFFp+62, 0);
    test__fixunsdfti(-0x1.FFFFFFFFFFFFEp+62, 0);
}

