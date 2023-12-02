const std = @import("std");

const embeddedData = @embedFile("data/day2p2.txt");

pub fn main() !void {
    const result: i32 = try sumPowers();
    std.debug.print("{d}\n", .{result});
}

pub fn sumPowers() !i32 {
    var powerSums: i32 = 0;

    var lines = std.mem.split(u8, embeddedData, "\n");

    while (lines.next()) |line| {
        var fewestRed: i32 = 0;
        var fewestBlue: i32 = 0;
        var fewestGreen: i32 = 0;

        var gameIterator = std.mem.split(u8, line, ": ");
        const gameId = gameIterator.next().?;
        _ = gameId;
        const hands = gameIterator.next().?;

        var handsIterator = std.mem.split(u8, hands, "; ");
        while (handsIterator.next()) |hand| {
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
