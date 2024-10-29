const std = @import("std");

fn nums(input: []const u8, counts: []u2) void {
    var splits = std.mem.tokenizeScalar(u8, input, ' ');
    while (splits.next()) |n_raw| {
        const n = std.fmt.parseInt(u8, n_raw, 10) catch unreachable;
        // std.debug.print("{}", .{n});
        counts[n] += 1;
    }
}

fn part1(input: []const u8) u32 {
    var total: u32 = 0;
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        var counts = std.mem.zeroes([100]u2);
        const line_body = blk: {
            var splits = std.mem.tokenizeScalar(u8, line, ':');
            _ = splits.next().?;
            break :blk splits.next().?;
        };
        const left, const right = blk: {
            var splits = std.mem.tokenizeScalar(u8, line_body, '|');
            break :blk .{ splits.next().?, splits.next().? };
        };
        nums(left, &counts);
        nums(right, &counts);

        var boths: u5 = 0;
        for (counts) |count| if (count == 2) {
            boths += 1;
        };

        total += if (boths == 0) 0 else @as(u32, 1) << (boths - 1);
    }
    return total;
}

fn part2(input: []const u8) usize {
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');

    var copies: [1024]usize = undefined;
    for (&copies) |*c| {
        c.* = 1;
    }

    var game_id: usize = 0;
    while (line_it.next()) |line| : (game_id += 1) {
        var counts = std.mem.zeroes([100]u2);
        const line_body = blk: {
            var splits = std.mem.tokenizeScalar(u8, line, ':');
            _ = splits.next().?;
            break :blk splits.next().?;
        };
        const left, const right = blk: {
            var splits = std.mem.tokenizeScalar(u8, line_body, '|');
            break :blk .{ splits.next().?, splits.next().? };
        };
        nums(left, &counts);
        nums(right, &counts);

        var boths: u5 = 0;
        for (counts) |count| if (count == 2) {
            boths += 1;
        };

        for (game_id + 1.., 0..boths) |i, _| {
            copies[i] += copies[game_id];
        }
    }

    var total: usize = 0;
    // game_id now is the len
    for (0..game_id) |i| {
        total += copies[i];
    }
    return total;
}

test "part 1 example" {
    try std.testing.expectEqual(@as(u32, 13), part1(
        \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
        \\
    ));
}

test "part 1" {
    try std.testing.expectEqual(
        @as(u32, 25004),
        part1(@embedFile("inputs/day4.txt")),
    );
}

test "part 2 example" {
    try std.testing.expectEqual(@as(usize, 30), part2(
        \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
        \\
    ));
}

test "part 2" {
    try std.testing.expectEqual(
        @as(usize, 14427616),
        part2(@embedFile("inputs/day4.txt")),
    );
}
