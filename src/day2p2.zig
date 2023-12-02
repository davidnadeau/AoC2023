const std = @import("std");

pub fn main() !void {
    const result: i32 = try sumPowers("input/day2p2.txt");
    std.debug.print("{d}\n", .{result});
}

pub fn sumPowers(filename: []const u8) !i32 {
    var file = try std.fs.cwd().openFile(filename, .{});

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var powerSums: i32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var fewestRed: i32 = 0;
        var fewestBlue: i32 = 0;
        var fewestGreen: i32 = 0;

        var iter = std.mem.split(u8, line, ": ");
        const gameId = iter.next().?;
        _ = gameId;
        const handsIterator = iter.next().?;

        var hands = std.mem.split(u8, handsIterator, "; ");
        while (hands.next()) |hand| {
            var rolls = std.mem.split(u8, hand, ", ");
            while (rolls.next()) |roll| {
                var dieValues = std.mem.split(u8, roll, " ");
                const countSlice = dieValues.next().?;
                const count: u8 = try std.fmt.parseInt(u8, countSlice, 10);
                const colour = dieValues.next().?;
                if (std.mem.eql(u8, colour, "red")) {
                    fewestRed = @max(fewestRed, count);
                } else if (std.mem.eql(u8, colour, "blue")) {
                    fewestBlue = @max(fewestBlue, count);
                } else if (std.mem.eql(u8, colour, "green")) {
                    fewestGreen = @max(fewestGreen, count);
                }
            }
        }

        const power = fewestRed * fewestGreen * fewestBlue;
        powerSums = powerSums + power;
    }
    return powerSums;
}
