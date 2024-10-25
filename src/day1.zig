const std = @import("std");

fn part1(input: [:0]const u8) i32 {
    var value: i32 = 0;
    var i: usize = 0;

    var digits: [2]i32 = .{ 0, 0 };

    outer: switch (input[i]) {
        '0'...'9' => |c0| {
            digits[0] = c0 - '0';
            digits[1] = digits[0];
            i += 1;
            inner: switch (input[i]) {
                '0'...'9' => |c1| {
                    digits[1] = c1 - '0';
                    i += 1;
                    continue :inner input[i];
                },
                '\n' => {
                    // std.debug.print("{}{}\n", .{ digits[0], digits[1] });
                    value += 10 * digits[0] + digits[1];
                    i += 1;
                    continue :outer input[i];
                },
                else => {
                    i += 1;
                    continue :inner input[i];
                },
            }
        },
        else => {
            i += 1;
            continue :outer input[i];
        },
        0 => break :outer,
    }

    return value;
}

const spelling = [_]struct { []const u8, i32 }{
    .{ "one", 1 },
    .{ "two", 2 },
    .{ "three", 3 },
    .{ "four", 4 },
    .{ "five", 5 },
    .{ "six", 6 },
    .{ "seven", 7 },
    .{ "eight", 8 },
    .{ "nine", 9 },
};

fn part2Inner(input: [:0]const u8, i: usize, digit0: i32) struct { usize, i32 } {
    var j = i;
    var digits: [2]i32 = .{ digit0, digit0 };
    inner: switch (input[j]) {
        '\n' => {
            // std.debug.print("{}{}\n", .{ digits[0], digits[1] });
            j += 1;
            return .{ j, 10 * digits[0] + digits[1] };
        },
        '0'...'9' => |c1| {
            digits[1] = c1 - '0';
            j += 1;
            continue :inner input[j];
        },
        else => {
            inline for (spelling) |b| {
                const spell2, const digit2 = b;
                if (std.mem.startsWith(u8, input[j..input.len], spell2)) {
                    digits[1] = digit2;
                    j += 1;
                    continue :inner input[j];
                }
            }
            j += 1;
            continue :inner input[j];
        },
    }
}

fn part2(input: [:0]const u8) i32 {
    var value: i32 = 0;
    var i: usize = 0;
    outer: switch (input[i]) {
        '0'...'9' => |c0| {
            i += 1;
            i, const inner_val = part2Inner(input, i, c0 - '0');
            value += inner_val;
            continue :outer input[i];
        },
        else => {
            inline for (spelling) |a| {
                const spell, const digit = a;
                if (std.mem.startsWith(u8, input[i..input.len], spell)) {
                    i += 1;
                    i, const inner_val = part2Inner(input, i, digit);
                    value += inner_val;
                    continue :outer input[i];
                }
            }
            i += 1;
            continue :outer input[i];
        },
        0 => break :outer,
    }
    return value;
}

test "part 1 example" {
    try std.testing.expectEqual(@as(i32, 142), part1(
        \\1abc2
        \\pqr3stu8vwx
        \\a1b2c3d4e5f
        \\treb7uchet
        \\
    ));
}

test "part 1" {
    try std.testing.expectEqual(@as(i32, 52974), part1(@embedFile("inputs/day1.txt")));
}

test "part 2 example" {
    try std.testing.expectEqual(@as(i32, 281), part2(
        \\two1nine
        \\eightwothree
        \\abcone2threexyz
        \\xtwone3four
        \\4nineeightseven2
        \\zoneight234
        \\7pqrstsixteen
        \\
    ));
}

test "part 2" {
    try std.testing.expectEqual(@as(i32, 53340), part2(@embedFile("inputs/day1.txt")));
}
