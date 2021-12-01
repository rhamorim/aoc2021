const std = @import("std");

pub fn day01() !void {
    var buf: [2048]u8 = undefined;
    var buf_reader = std.io.getStdIn().reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var reports = std.ArrayList(u32).init(&gpa.allocator);
    defer reports.deinit();

    while (try buf_reader.readUntilDelimiterOrEof(buf[0..], '\n')) |read| {
        const v = try std.fmt.parseInt(u32, read, 10);
        try reports.append(v);
    }

    const increased = part1(reports.items);
    std.debug.print("Part 1: {d}\n", .{increased});

    const increased2 = part2(reports.items);
    std.debug.print("Part 2: {d}\n", .{increased2});
}

fn part1(reports: []const u32) u32 {
    var last_report: ?u32 = null;
    var increased: u32 = 0;
    for (reports) |report| {
        if (report > (last_report orelse report)) {
            increased += 1;
        }
        last_report = report;
    }
    return increased;
}

fn SlidingWindow(comptime size: u8) type {
    return struct {
        const Self = @This();
        values: [size]u32 = undefined,
        pos: u32 = 0,
        fn sum(self: Self) ?u32 {
            if (self.pos < size) {
                return null;
            } else {
                var s: u32 = 0;
                for (self.values) |v| s += v;
                return s;
            }
        }
        fn add(self: *Self, value: u32) void {
            self.values[self.pos % size] = value;
            self.pos += 1;
        }
    };
}

fn part2(reports: []const u32) u32 {
    var last_report: ?u32 = null;
    var increased: u32 = 0;
    var sliding_window = SlidingWindow(3){};
    for (reports) |value| {
        sliding_window.add(value);
        if (sliding_window.sum()) |report| {
            if (report > (last_report orelse report)) {
                increased += 1;
            }
            last_report = report;
        }
    }
    return increased;
}

pub fn main() !void {
    try day01();
}

const test_input = [_]u32{ 199, 200, 208, 210, 200, 207, 240, 269, 260, 263 };

test "part 1" {
    try std.testing.expect(part1(test_input[0..]) == 7);
}

test "part 2" {
    try std.testing.expect(part2(test_input[0..]) == 5);
}
