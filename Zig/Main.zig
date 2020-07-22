const std = @import("std");
const warn = @import("std").debug.warn;
const process = std.process;

const Arguments = struct {
    numData: i32,
    initialValue: f32,
    incrementPerValue: f32,
    multiplyAllBy: f32,
    printSummation: bool
};

pub fn main() !void {
    warn("Language Tests\n", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var args_it = process.args();
    if (!args_it.skip()) @panic("expected self arg");

    const first_arg = try (args_it.next(allocator) orelse @panic("Expected argument"));
    // No need to free; arena allocator will do it for me
    // defer allocator.free(first_arg);

    warn("Got {}\n", .{first_arg});
}
