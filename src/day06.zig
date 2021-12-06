const std = @import("std");

pub fn day06() !void {
    var buf: [2048]u8 = undefined;
    var buf_reader = std.io.getStdIn().reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var reports = std.ArrayList(u32).init(&gpa.allocator);
    defer reports.deinit();

    while (try buf_reader.readUntilDelimiterOrEof(buf[0..], '\n')) |read| {
        var parts = std.mem.tokenize(u8, read, ",");

        while(parts.next()) |report| {
            const v = try std.fmt.parseInt(u8, report, 10);
            try reports.append(v);
        }
    }

    const result1 = part1(reports.items);
    std.debug.print("Part 1: {d}\n", .{result1});

    const result2 = part2(reports.items);
    std.debug.print("Part 2: {d}\n", .{result2});
}

// We could keep all lanternfish in an array, but that would need lots of CPU
// and memory (a loop every day, lots of allocations for new lanternfish, etc)
// There must be a better way!
//
// Well, there is. We don't need to track each lanternfish, only how many there
// are in each "days left" category. That means we need only a simple size 9
// (0-8) array. And, to prevent useless memory copying, we can treat it as a
// kind of circular buffer - so each day we add what's in "virtual position 0"
// to virtual position 7, and then increase the day, this increasing the
// virtual position 0. So 0 will become 8 (hi, new lanternfish) and the fish
// we added to virtual position 7 will be in 6 (hi, reset lanternfish!).
// Simple, easy, efficient, effective.

// To make things even easier, we'll encapsulate that behavior in a struct.
fn part1(reports: []const u32) u64 {
    var simulator = LanternFishSim{};
    for (reports) |report| simulator.add(report);
    simulator.simulate_days(80);
    return simulator.population();
}

const LanternFishSim = struct {
    fish: [9]u64 = [_]u64{0} ** 9,
    day: u32 = 0,
    fn add(self: *LanternFishSim, value: u32) void {
        const idx = (self.day + value) % 9;
        self.fish[idx] += 1;
    }
    fn simulate(self: *LanternFishSim) void {
        // no need to add lanternfish, since 0 will become 8
        // when the day flips. Just add the current number of
        // fish in 0 to 7 (because when day flips, that will
        // become 6), and then flip the day
        self.fish[(self.day + 7) % 9] += self.fish[self.day % 9];
        self.day += 1;
    }
    fn simulate_days(self: *LanternFishSim, days: u32) void {
        var i: u32 = 0;
        while (i < days) : (i += 1) {
            self.simulate();
        }
    }
    fn population(self: LanternFishSim) u64 {
        var sum: u64 = 0;
        for (self.fish) |fishes| {
            sum += fishes;
        }
        return sum;
    }
};

// For part 2, I just changed u32 to u64 in a few places. Easy. ;)
fn part2(reports: []const u32) u64 {
    var simulator = LanternFishSim{};
    for (reports) |report| simulator.add(report);
    simulator.simulate_days(256);
    return simulator.population();
}

pub fn main() !void {
    try day06();
}

const test_input = [_]u32{3,4,3,1,2};

test "part 1" {
    try std.testing.expect(part1(test_input[0..]) == 5934);
}

test "part 2" {
    try std.testing.expect(part2(test_input[0..]) == 26984457539);
}
