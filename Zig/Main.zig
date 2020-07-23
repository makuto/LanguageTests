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

pub fn helpArgs(comptime T: type) void {
    const type_info = @typeInfo(T);

    warn("Expected:\n\tMain argument value (for as many arguments as desired)\n", .{});
    warn("\nAvailable Arguments:\n", .{});
    
    switch (type_info) {
        .Struct => {
            // This must be inline to function: the length can't be known at runtime. I'm not sure
            // my understanding is correct; see https://github.com/ziglang/zig/issues/1435
            inline for (type_info.Struct.fields) |field| {
                warn("\t{}\n", .{field.name});
            }
        },
        else => {
            @compileError("Unsupported type '" ++ @typeName(T) ++ "'");
        }
    }
}

pub fn setArgFromString(comptime T: type, output : T, arg_name : []u8, arg_value : []u8) void {
    const type_info = @typeInfo(T);
    
    switch (type_info) {
        .Struct => {
            // This must be inline to function: the length can't be known at runtime. I'm not sure
            // my understanding is correct; see https://github.com/ziglang/zig/issues/1435
            inline for (type_info.Struct.fields) |field| {
                if (std.mem.eql(u8, arg_name, field.name)) {
                    switch (field.field_type) {
                        .Float => {
                            @field(output, field.name) =
                                try (std.fmt.parseFloat(field.field_type, arg_value)
                                         orelse
                                         warn("Expected {}, but string '{}' was not parseable\n", .{@typeName(field.field_type), arg_value}));
                        },
                        .Int => {
                            @field(output, field.name) = try (std.fmt.parseInt(field.field_type, arg_value) orelse warn("Expected {}, but string '{}' was not parseable\n", .{@typeName(field.field_type), arg_value}));
                        },
                        else => {
                            @compileError("Unsupported type '" ++ @typeName(T) ++ "'");
                        }
                    }
                    return;
                }
            }
        },
        else => {
            @compileError("Expected Struct, got '" ++ @typeName(T) ++ "'");
        }
    }
}

pub fn main() !void {
    warn("Language Tests\n", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var args_it = process.args();
    if (!args_it.skip()) @panic("expected self arg");

    var args_list = std.ArrayList([]const u8).init(allocator);

    var current_arg = try (args_it.next(allocator) orelse {
        helpArgs(Arguments);
        @panic("Requires some arguments");
    });
    // No need to free; arena allocator will do it for me
    // defer allocator.free(first_arg);

    var args : Arguments = .{
        .numData = 10000,
        .initialValue = 0,
        .incrementPerValue = 1.0,
        .multiplyAllBy = 1.0,
        .printSummation = false,
    };

    var is_field_name = false;
    var field_name = current_arg;
    while (current_arg[0] != 0) :
        ({current_arg = try (args_it.next(allocator) orelse "");}){
            if (is_field_name) {
                setArgFromString(Arguments, args, field_name, current_arg);
                is_field_name = false;
            } else {
                field_name = current_arg;
                is_field_name = true;
            }
    }

    if (is_field_name) {
        helpArgs(Arguments);
        @panic("Expected pairs of 'fieldName value'");
    }

}
