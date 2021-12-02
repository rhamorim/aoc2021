const std = @import("std");

pub fn day02() !void {
    var buf: [2048]u8 = undefined;
    var buf_reader = std.io.getStdIn().reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var commands = std.ArrayList(Command).init(&gpa.allocator);
    defer commands.deinit();

    while (try buf_reader.readUntilDelimiterOrEof(buf[0..], '\n')) |read| {
        var parts = std.mem.tokenize(u8, read, " ");

        const command_str = parts.next() orelse "";
        var command = Command{};
        if (std.mem.eql(u8, command_str, "forward")) {
            command.direction = Direction.forward;
        } else if (std.mem.eql(u8, command_str, "up")) {
            command.direction = Direction.up;
        } else if (std.mem.eql(u8, command_str, "down")) {
            command.direction = Direction.down;
        } else return error.InvalidCommand;

        const distance_str = parts.next() orelse "";
        command.distance = try std.fmt.parseInt(u8, distance_str, 10);

        try commands.append(command);
    }

    const result1 = part1(commands.items);
    std.debug.print("Part 1: {d}\n", .{result1});

    const result2 = part2(commands.items);
    std.debug.print("Part 2: {d}\n", .{result2});
}

const Direction = enum { forward, down, up };

const Command = struct { direction: Direction = undefined, distance: u8 = undefined };

const Submarine = struct {
    hpos: u32 = 0,
    vpos: u32 = 0,
    fn execute(self: *Submarine, command: Command) void {
        switch (command.direction) {
            Direction.forward => self.hpos += command.distance,
            Direction.down => self.vpos += command.distance,
            Direction.up => self.vpos -= command.distance,
        }
    }
    fn result(self: Submarine) u32 {
        return self.hpos * self.vpos;
    }
};

fn part1(commands: []const Command) u32 {
    var sub = Submarine{};
    for (commands) |command| {
        sub.execute(command);
    }
    const result = sub.result();
    return result;
}

const Submarine2 = struct {
    hpos: u32 = 0,
    vpos: u32 = 0,
    aim: u32 = 0,
    fn execute(self: *Submarine2, command: Command) void {
        switch (command.direction) {
            Direction.down => self.aim += command.distance,
            Direction.up => self.aim -= command.distance,
            Direction.forward => {
                self.hpos += command.distance;
                self.vpos += command.distance * self.aim;
            },
        }
    }
    fn result(self: Submarine2) u32 {
        return self.hpos * self.vpos;
    }
};

fn part2(commands: []const Command) u32 {
    var sub = Submarine2{};
    for (commands) |command| {
        sub.execute(command);
    }
    const result = sub.result();
    return result;
}

pub fn main() !void {
    try day02();
}

const test_input = [_]Command{
    Command{ .direction = Direction.forward, .distance = 5 },
    Command{ .direction = Direction.down,    .distance = 5 },
    Command{ .direction = Direction.forward, .distance = 8 },
    Command{ .direction = Direction.up,      .distance = 3 },
    Command{ .direction = Direction.down,    .distance = 8 },
    Command{ .direction = Direction.forward, .distance = 2 }
};

test "part 1" {
    try std.testing.expect(part1(test_input[0..]) == 150);
}

test "part 2" {
    try std.testing.expect(part2(test_input[0..]) == 900);
}
