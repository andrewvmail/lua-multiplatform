const std = @import("std");

pub export fn main() void {
    std.io.getStdOut().writeAll(
        "i am a stub only",
    ) catch unreachable;
}
