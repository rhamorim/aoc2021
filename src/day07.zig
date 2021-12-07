const std = @import("std");

pub fn day07() !void {
    var buf: [8192]u8 = undefined;
    var buf_reader = std.io.getStdIn().reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var reports = std.ArrayList(u32).init(&gpa.allocator);
    defer reports.deinit();

    while (try buf_reader.readUntilDelimiterOrEof(buf[0..], '\n')) |read| {
        var parts = std.mem.tokenize(u8, read, ",");

        while(parts.next()) |report| {
            const v = try std.fmt.parseInt(u32, report, 10);
            try reports.append(v);
        }
    }

    const result1 = part1(reports.items);
    std.debug.print("Part 1: {d}\n", .{result1});

    const result2 = part2(reports.items);
    std.debug.print("Part 2: {d}\n", .{result2});
}

// Ok, calculating all the possible fuel combinations would be terrible;
// it's exponential, and the larger the set AND the number variation,
// the worst it gets. That's not an option. We should do something else
// to limit those computations.

// One way would be to calculate the average, but the average is vulnerable
// to outlier values. So let's calculate the median and assume that is the
// "mid" value. Maybe it's the optimal value?

// (spoiler: in this particular case, it is, at least for part 1 and the
// input data I got; YMMV)
fn part1(reports: [] u32) u64 {
    // calculate median; first we sort
    std.sort.sort(u32, reports[0..], {}, comptime std.sort.asc(u32));
    var med: u32 = undefined;

    // then we find the midpoint and calculate the median
    const midpoint = reports.len / 2;
    if ((reports.len % 2) == 0) {
        med = (reports[midpoint - 1] + reports[midpoint]) / 2;
    } else {
        med = reports[midpoint];
    }

    // now calculate sum of distance to median, which is the fuel usage!
    var fuel: u32 = 0;
    for (reports) |report| {
        if (report >= med) fuel += report - med
        else fuel += med - report;
    }

    return fuel;
}

// now part 2 seems to be a case in which the arithmetic average would
// fit a lot better. Let's try that! Though we'll have to use floats now.
fn part2(reports: []const u32) u64 {
    var sum: f64 = 0;
    //var avg: f64 = 0;
    for (reports) |report| {
        sum += @intToFloat(f64, report);
    }
    const avg = sum / @intToFloat(f64, reports.len);
    const avgi = @floatToInt(u32, std.math.floor(avg));
    //std.debug.print("AVG: {}, {}\n", .{avg, avgi});

    // now calculate sum of distance to avg, which is the fuel usage!
    // We calculate two values here; one for the floored avg, and one
    // for the ceil avg, because there might be slight deviations, and
    // then we pick the smallest as the answer. Better than a brute force
    // approach.
    var fuel1: u32 = 0;
    var fuel2: u32 = 0;
    for (reports) |report| {
        var a1: u32 = undefined;
        var b1: u32 = undefined;
        var a2: u32 = undefined;
        var b2: u32 = undefined;
        if (report > avgi) {
            a1 = report;
            b1 = avgi;
            a2 = report;
            b2 = avgi + 1;
        } else {
            a1 = avgi;
            b1 = report;
            a2 = avgi + 1;
            b2 = report;
        }

        const f1 = ((a1 - b1) * (a1 - b1 + 1)) / 2;
        const f2 = ((a2 - b2) * (a2 - b2 + 1)) / 2;
        
        fuel1 += f1;
        fuel2 += f2;
    }

    //std.debug.print("{}, {}\n", .{fuel1, fuel2});
    if (fuel1 > fuel2) return fuel2 else return fuel1;
}

pub fn main() !void {
    try day07();
}

var test_input = [_]u32{16,1,2,0,4,2,7,1,2,14};

test "part 1" {
    try std.testing.expect(part1(test_input[0..]) == 37);
}

test "part 2" {
    try std.testing.expect(part2(test_input[0..]) == 168);
}
