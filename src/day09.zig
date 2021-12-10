const std = @import("std");

pub fn day09() !void {
    var buf: [2048]u8 = undefined;
    var buf_reader = std.io.getStdIn().reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var reports = std.ArrayList(u32).init(&gpa.allocator);
    defer reports.deinit();

    var width: u8 = 0;
    while (try buf_reader.readUntilDelimiterOrEof(buf[0..], '\n')) |read| {
        width = @intCast(u8, read.len);
        //std.debug.print("{} - {s}\n", .{width, read});
        for (read[0..]) |digit| {
            //std.debug.print("{}", .{digit - '0'});
            try reports.append(digit - '0');
        }
        //std.debug.print("\n", .{});
        //const v = try std.fmt.parseInt(u32, read, 10);
    }


    const result1 = part1(reports.items, width);
    std.debug.print("Part 1: {d}\n", .{result1});

    //const result2 = part2(reports.items, width);
    //std.debug.print("Part 2: {d}\n", .{result2});
}

fn part1(reports: []const u32, width: u8) u32 {
    var hm = Heightmap{.cells = reports, .width = width};
    return hm.risk();
}

const Heightmap = struct {
    width: u8 = 0,
    cells: []const u32 = undefined,
    fn value(self: Heightmap, x: i32, y: i32) u32 {
        if ((x < 0) or (y < 0)) {
            return 9;
        } else if ((x >= self.width) or (y * self.width >= self.cells.len)) {
            return 9;
        }
        const pos = @intCast(usize, (y * self.width) + x);
        return self.cells[pos];
    }
    fn risk(self: Heightmap) u32 {
        var risk_sum: u32 = 0;
        var i: u32 = 0;
        while (i < self.cells.len) : (i += 1) {
            const x = @intCast(i32, i % self.width);
            const y = @intCast(i32, i / self.width);
            const v = self.value(x, y);
            if (
                (v < self.value(x - 1, y)) and
                (v < self.value(x, y - 1)) and
                (v < self.value(x + 1, y)) and
                (v < self.value(x, y + 1))
            ) {
                risk_sum += v + 1;
            }
        }
        return risk_sum;
    }
};

fn part2(reports: []const u32, width: u8) u32 {
    _ = reports;
    _ = width;
    return 0;
}

pub fn main() !void {
    try day09();
}

const test_input = [_]u32{ 
    2,1,9,9,9,4,3,2,1,0,
    3,9,8,7,8,9,4,9,2,1,
    9,8,5,6,7,8,9,8,9,2,
    8,7,6,7,8,9,6,7,8,9,
    9,8,9,9,9,6,5,6,7,8
};

test "part 1" {
    try std.testing.expect(part1(test_input[0..], 10) == 15);
}

//test "part 2" {
//    try std.testing.expect(part2(test_input[0..], 5) == 230);
//}
