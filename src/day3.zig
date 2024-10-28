const std = @import("std");

const Cell = union(enum) {
    digit: u4,
    dot,
    symbol,
    gear,

    pub fn format(
        value: Cell,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        switch (value) {
            .digit => |d| try std.fmt.format(writer, "{}", .{d}),
            .dot => try std.fmt.format(writer, ".", .{}),
            .symbol => try std.fmt.format(writer, "@", .{}),
            .gear => try std.fmt.format(writer, "*", .{}),
        }
    }
};

fn parseAlloc(
    allocator: std.mem.Allocator,
    input: []const u8,
) error{OutOfMemory}!struct { std.ArrayList(Cell), usize, usize } {
    var it = std.mem.tokenizeScalar(u8, input, '\n');

    // account for paddings
    const width = 1 + it.peek().?.len + 1;
    const height = 1 + std.mem.count(u8, input, "\n") + 1;

    var cells: std.ArrayList(Cell) = try .initCapacity(allocator, width * height);

    // no more allocation error from this point onwards
    errdefer unreachable;

    // pad the first line
    for (0..width) |_| cells.appendAssumeCapacity(.dot);

    while (it.next()) |line| {

        // pad left
        cells.appendAssumeCapacity(.dot);

        for (line) |c| {
            cells.appendAssumeCapacity(switch (c) {
                '0'...'9' => .{ .digit = @intCast(c - '0') },
                '.' => .dot,
                '*' => .gear,
                else => .symbol,
            });
        }

        // pad right
        cells.appendAssumeCapacity(.dot);
    }

    // pad the last line
    for (0..width) |_| cells.appendAssumeCapacity(.dot);

    return .{ cells, height, width };
}

// fn print(cells: []const Cell, height: usize, width: usize) void {
//     for (1..height - 1) |y| {
//         for (1..width - 1) |x| {
//             std.debug.print("{}", .{cells[y * width + x]});
//         }
//         std.debug.print("\n", .{});
//     }
// }

fn probe(cells: []const Cell, anchor: usize) ?struct { usize, u32 } {
    if (cells[anchor] != .digit)
        return null;

    var i = anchor;
    while (cells[i - 1] == .digit) : (i -= 1) {}

    var j = anchor;
    while (cells[j] == .digit) : (j += 1) {}

    var num: u32 = 0;
    for (cells[i..j]) |cell| {
        num *= 10;
        num += cell.digit;
    }

    return .{ i, num };
}

fn part1(
    allocator: std.mem.Allocator,
    input: []const u8,
) error{OutOfMemory}!u32 {
    const cells, const height, const width = try parseAlloc(allocator, input);
    defer cells.deinit();

    var map: std.AutoHashMap(usize, u32) = .init(allocator);
    defer map.deinit();

    for (1..height - 1) |y| {
        for (1..width - 1) |x| {
            switch (cells.items[y * width + x]) {
                .symbol, .gear => inline for (.{ std.math.maxInt(usize), 0, 1 }) |dy| {
                    inline for (.{ std.math.maxInt(usize), 0, 1 }) |dx| {
                        if (!(dx == 0 and dy == 0)) blk: {
                            const id, const num = probe(
                                cells.items,
                                (y +% dy) * width + (x +% dx),
                            ) orelse break :blk;
                            try map.put(id, num);
                        }
                    }
                },
                else => {},
            }
        }
    }

    var sum: u32 = 0;
    {
        var it = map.valueIterator();
        while (it.next()) |v| {
            sum += v.*;
        }
    }

    return sum;
}

fn part2(
    allocator: std.mem.Allocator,
    input: []const u8,
) error{OutOfMemory}!u32 {
    const cells, const height, const width = try parseAlloc(allocator, input);
    defer cells.deinit();

    var sum: u32 = 0;

    for (1..height - 1) |y| {
        for (1..width - 1) |x| {
            if (cells.items[y * width + x] == .gear) {
                var map: std.AutoHashMap(usize, u32) = .init(allocator);
                defer map.deinit();

                inline for (.{ std.math.maxInt(usize), 0, 1 }) |dy| {
                    inline for (.{ std.math.maxInt(usize), 0, 1 }) |dx| {
                        if (!(dx == 0 and dy == 0)) blk: {
                            const id, const num = probe(
                                cells.items,
                                (y +% dy) * width + (x +% dx),
                            ) orelse break :blk;
                            try map.put(id, num);
                        }
                    }
                }

                if (map.count() == 2) {
                    var it = map.valueIterator();
                    var gear_ratio: u32 = 1;
                    while (it.next()) |v| {
                        gear_ratio *= v.*;
                    }
                    sum += gear_ratio;
                }
            }
        }
    }

    return sum;
}

test "example part 1" {
    try std.testing.expectEqual(@as(u32, 4361), part1(std.testing.allocator,
        \\467..114..
        \\...*......
        \\..35..633.
        \\......#...
        \\617*......
        \\.....+.58.
        \\..592.....
        \\......755.
        \\...$.*....
        \\.664.598..
        \\
    ));
}

test "part 1" {
    try std.testing.expectEqual(
        @as(u32, 544664),
        part1(std.testing.allocator, @embedFile("inputs/day3.txt")),
    );
}

test "example part 2" {
    try std.testing.expectEqual(@as(u32, 467835), part2(std.testing.allocator,
        \\467..114..
        \\...*......
        \\..35..633.
        \\......#...
        \\617*......
        \\.....+.58.
        \\..592.....
        \\......755.
        \\...$.*....
        \\.664.598..
        \\
    ));
}

test "part 2" {
    try std.testing.expectEqual(
        @as(u32, 84495585),
        part2(std.testing.allocator, @embedFile("inputs/day3.txt")),
    );
}
