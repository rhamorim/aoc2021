const std = @import("std");

pub fn day10() !void {
    var buf: [2048]u8 = undefined;
    var buf_reader = std.io.getStdIn().reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var p1 = Day10{};
    while (try buf_reader.readUntilDelimiterOrEof(buf[0..], '\n')) |read| {
        //std.debug.print("{s}\n", .{read});
        try p1.process_line(read);
    }
    std.debug.print("Part 1: {}\n", .{p1.part1()});
    std.debug.print("Part 2: {}\n", .{p1.part2()});
}

const Day10 = struct {
    pos: u8 = 0,
    stack: [256]u8 = undefined,
    illegals: [256]u8 = undefined,
    num_illegals: u8 = 0,
    scores: [256]u64 = undefined,
    num_scores: u8 = 0,
    fn reset(self: *Day10) void {
        self.pos = 0;
        self.num_illegals = 0;
    }
    fn append(self: *Day10, value: u8) void {
        self.stack[self.pos] = value;
        self.pos += 1;
    }
    fn top(self: Day10) ?u8 {
        if (self.pos > 0) return self.stack[self.pos - 1] else return null;
    }
    fn pop(self: *Day10) ?u8 {
        if (self.pos > 0) {
            self.pos -= 1;
            return self.stack[self.pos];
        } else return null;
    }
    fn illegal(self: *Day10, value: u8) void {
        //std.debug.print("FOUND: '{c}'\n", .{value});
        self.illegals[self.num_illegals] = value;
        self.num_illegals += 1;
    }
    fn process_line(self: *Day10, line: []const u8) !void {
        self.pos = 0;
        var illegal_line = false;
        // first check for illegal;
        for (line) |char| {
            switch (char) {
                '(', '[', '{', '<' => {
                    self.append(char);
                },
                ')', ']', '}', '>' => {
                    if (self.top()) |last| {
                        if ((last == '(') and (char != ')')) {
                            self.illegal(char);
                            illegal_line = true;
                            break;
                        } else if ((last == '[') and (char != ']')) {
                            self.illegal(char);
                            illegal_line = true;
                            break;
                        } else if ((last == '{') and (char != '}')) {
                            self.illegal(char);
                            illegal_line = true;
                            break;
                        } else if ((last == '<') and (char != '>')) {
                            self.illegal(char);
                            illegal_line = true;
                            break;
                        } else _ = self.pop();
                    }
                },
                else => {},
            }
        }
        if (!illegal_line) {
            // calculate score and add to results of incomplete lines
            var score: u64 = 0;
            const stack_max: u8 = self.pos - 1;
            var i: u8 = 0;
            while (i <= stack_max) : (i += 1) {
                const v: u32 =
                    switch (self.stack[stack_max - i]) {
                    '(' => 1,
                    '[' => 2,
                    '{' => 3,
                    '<' => 4,
                    else => 0,
                };
                score = (score * 5) + v;
            }
            self.scores[self.num_scores] = score;
            self.num_scores += 1;
        }
    }
    fn part1(self: Day10) u32 {
        var sum: u32 = 0;
        var i: u8 = 0;
        while (i < self.num_illegals) : (i += 1) {
            const v: u32 =
                switch (self.illegals[i]) {
                ')' => 3,
                ']' => 57,
                '}' => 1197,
                '>' => 25137,
                else => 0,
            };
            sum += v;
        }
        return sum;
    }
    fn part2(self: *Day10) u64 {
        const s = self.num_scores;
        std.sort.sort(u64, self.scores[0..s], {}, comptime std.sort.asc(u64));
        return self.scores[s / 2];
    }
};

pub fn main() !void {
    try day10();
}

const test_input =
    \\[({(<(())[]>[[{[]{<()<>>
    \\[(()[<>])]({[<{<<[]>>(
    \\{([(<{}[<>[]}>{[]{[(<()>
    \\(((({<>}<{<{<>}{[]{[]{}
    \\[[<[([]))<([[{}[[()]]]
    \\[{[{({}]{}}([{[{{{}}([]
    \\{<[[]]>}<{[{[{[]{()[[[]
    \\[<(<(<(<{}))><([]([]()
    \\<{([([[(<>()){}]>(<<{{
    \\<{([{{}}[<[[[<>{}]]]>[]
;

test "part 1" {
    var p1 = Day10{};
    var parts = std.mem.tokenize(u8, test_input, "\n");
    while (parts.next()) |line| {
        //std.debug.print("{s}\n", .{line});
        try p1.process_line(line);
    }
    try std.testing.expect(p1.part1() == 26397);
}

test "part 2" {
    var p1 = Day10{};
    var parts = std.mem.tokenize(u8, test_input, "\n");
    while (parts.next()) |line| {
        //std.debug.print("{s}\n", .{line});
        try p1.process_line(line);
    }
    try std.testing.expect(p1.part2() == 288957);
}
