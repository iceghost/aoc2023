const std = @import("std");

var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
var allocator = gpa.allocator();

const Cube = struct { Color, usize };
const Color = enum { red, green, blue };

fn parse(input: []const u8) struct {
    std.ArrayList(usize),
    std.ArrayList(usize),
    std.ArrayList(Cube),
} {
    var game_groups: std.ArrayList(usize) = .init(allocator);
    var set_groups: std.ArrayList(usize) = .init(allocator);
    var cubes: std.ArrayList(Cube) = .init(allocator);
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        _, const subsets = blk: {
            var it = std.mem.tokenizeScalar(u8, line, ':');
            break :blk .{ it.next().?, it.next().? };
        };
        var subset_it = std.mem.tokenizeScalar(u8, subsets, ';');

        var i: usize = 0;
        while (subset_it.next()) |subset| : (i += 1) {
            var cube_it = std.mem.tokenizeScalar(u8, subset, ',');
            var j: usize = 0;
            while (cube_it.next()) |cube| : (j += 1) {
                cubes.append(parseCube(std.mem.trim(u8, cube, " "))) catch @panic("OOM");
            }
            set_groups.append(j) catch @panic("OOM");
        }
        game_groups.append(i) catch @panic("OOM");
    }
    return .{ game_groups, set_groups, cubes };
}

fn parseCube(input: []const u8) Cube {
    // could probably use some builtin to get the name
    inline for (.{ .red, .green, .blue }) |color| {
        const name = @tagName(color);
        if (std.mem.endsWith(u8, input, name)) {
            const count = std.fmt.parseInt(usize, input[0 .. input.len - name.len - 1], 10) catch @panic("cannot read int");
            return .{ color, count };
        }
    }
    @panic("no known color");
}

fn part1(
    input: []const u8,
    max_red: usize,
    max_green: usize,
    max_blue: usize,
) usize {
    var sum_id: usize = 0;

    const game_groups, const set_groups, const cubes = parse(input);

    var i: usize = 0;
    var j: usize = 0;
    for (1.., game_groups.items) |game_id, game_group| {
        defer i += game_group;

        var possible = true;
        defer sum_id += if (possible) game_id else 0;

        inner: for (set_groups.items[i..][0..game_group]) |set_group| {
            defer j += set_group;
            for (cubes.items[j..][0..set_group]) |cube| {
                const color, const count = cube;
                switch (color) {
                    .red => if (count > max_red) {
                        possible = false;
                        continue :inner;
                    },
                    .green => if (count > max_green) {
                        possible = false;
                        continue :inner;
                    },
                    .blue => if (count > max_blue) {
                        possible = false;
                        continue :inner;
                    },
                }
            }
        }
    }

    return sum_id;
}

fn part2(input: []const u8) usize {
    var res: usize = 0;

    const game_groups, const set_groups, const cubes = parse(input);

    var i: usize = 0;
    var j: usize = 0;
    for (game_groups.items) |game_group| {
        defer i += game_group;

        var max_red: usize = 0;
        var max_green: usize = 0;
        var max_blue: usize = 0;

        for (set_groups.items[i..][0..game_group]) |set_group| {
            defer j += set_group;
            for (cubes.items[j..][0..set_group]) |cube| {
                const color, const count = cube;
                switch (color) {
                    .red => max_red = @max(max_red, count),
                    .green => max_green = @max(max_green, count),
                    .blue => max_blue = @max(max_blue, count),
                }
            }
        }

        res += max_red * max_green * max_blue;
    }

    return res;
}

test "example part 1" {
    try std.testing.expectEqual(@as(usize, 8), part1(
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
        \\
    , 12, 13, 14));
}

test "part 1" {
    try std.testing.expectEqual(
        @as(usize, 2406),
        part1(@embedFile("inputs/day2.txt"), 12, 13, 14),
    );
}

test "example part 2" {
    try std.testing.expectEqual(@as(usize, 2286), part2(
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
        \\
    ));
}

test "part 2" {
    try std.testing.expectEqual(
        @as(usize, 78375),
        part2(@embedFile("inputs/day2.txt")),
    );
}
