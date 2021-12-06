const std = @import("std");

pub fn day03() !void {
    var buf: [2048]u8 = undefined;
    var buf_reader = std.io.getStdIn().reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var reports = std.ArrayList(u32).init(&gpa.allocator);
    defer reports.deinit();

    var word_size: u5 = 0;
    while (try buf_reader.readUntilDelimiterOrEof(buf[0..], '\n')) |read| {
        word_size = @intCast(u5, read.len);
        const v = try std.fmt.parseInt(u32, read, 2);
        try reports.append(v);
    }


    const result1 = part1(reports.items, word_size);
    std.debug.print("Part 1: {d}\n", .{result1});

    //const result2 = part2(reports.items, word_size);
    //std.debug.print("Part 2: {d}\n", .{result2});
}

const RateCalculator = struct {
    word_size: u5 = 16,
    number_entries: u32 = 0,
    //sums: [32]u32 = undefined,
    sums: [32]u32 = [_]u32{0} ** 32,
    fn add_entry(self: *RateCalculator, entry: u32) void {
        var i: u5 = 0;
        while (i < self.word_size): (i += 1) {
            const bit: u32 = (entry >> i) & 1;
            self.sums[i] += bit;
        }
        self.number_entries += 1;
    }
    fn result(self: RateCalculator) u32 {
        var gamma_rate: u32 = 0;
        var i: u5 = 0;
        while (i < self.word_size): (i += 1) {
            if (self.sums[i] >= (self.number_entries / 2)) {
                const mask: u32 = 1;
                gamma_rate += (mask << i);
            }
        }
        const mask_bit: u32 = 1;
        const mask: u32 = (mask_bit << self.word_size) - 1;
        const epsilon_rate = ~gamma_rate & mask;
        const r = gamma_rate * epsilon_rate;
        return r;
        //return gamma_rate * epsilon_rate;
    }
};

fn part1(reports: []const u32, word_size: u5) u32 {
    var rc = RateCalculator{ .word_size = word_size };
    for (reports) |report| rc.add_entry(report);
    return rc.result();
}

// Part 2 is not working. I thought of an easier way to implement
// this (that's also more effective), so I'll return later.
fn part2(reports: []const u32, word_size: u5) u32 {
    var i = word_size;
    const number_entries = reports.len;
    var oxygen: u32 = 0;
    var carbon: u32 = 0;
    const mask_bit: u32 = 1;
    var mask: u32 = mask_bit << word_size;
    while(i > 0) : (i -= 1) {
        var sum_o2: u32 = 0;
        var sum_co2: u32 = 0;
        std.debug.print("---\n", .{});
        for (reports) |report| {
            const bit: u32 = (report >> (i - 1)) & 1;
            if ((report & mask) == oxygen) {
                sum_o2 += bit;
            }
            if ((report & mask) == carbon) {
                sum_co2 += bit;
            }
        }
        if (sum_o2 >= (number_entries / 2)) {
            oxygen |= (mask_bit << (i-1));
        }
        if (sum_co2 >= (number_entries / 2)) {
            carbon |= (mask_bit << (i-1));
        }
        std.debug.print("{b:0>5}\n", .{mask});
        std.debug.print("{b:0>5}\n", .{oxygen});
        std.debug.print("{b:0>5}\n", .{carbon});
        mask |= mask_bit << (i-1);
        std.debug.print("---\n", .{});
    }
    return oxygen * carbon;
}

pub fn main() !void {
    try day03();
}

const test_input = [_]u32{ 
    0b00100,
    0b11110,
    0b10110,
    0b10111,
    0b10101,
    0b01111,
    0b00111,
    0b11100,
    0b10000,
    0b11001,
    0b00010,
    0b01010
};

test "part 1" {
    try std.testing.expect(part1(test_input[0..], 5) == 198);
}

//test "part 2" {
//    try std.testing.expect(part2(test_input[0..], 5) == 230);
//}
