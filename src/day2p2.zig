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
        var gameIdBuffer: [3]u8 = undefined;
        var idSize: usize = 0;
        var searchingForGameId = true;
        var searchingColourCount = false;
        var searchingColourName = false;

        var colourBuffer: [2]u8 = undefined;
        var colourCountSize: usize = 0;

        var colourNameBuffer: [5]u8 = undefined;
        var colourNameSize: usize = 0;

        var fewestRed: i32 = 0;
        var fewestBlue: i32 = 0;
        var fewestGreen: i32 = 0;

        for (4..line.len) |i| {
            if (searchingForGameId) {
                if (line[i] == ':') {
                    searchingForGameId = false;
                    searchingColourCount = true;
                } else if (!(line[i] == ' ')) {
                    gameIdBuffer[idSize] = line[i];
                    idSize = idSize + 1;
                }
            } else if (searchingColourCount) {
                if (line[i] >= '0' and line[i] <= '9') {
                    colourBuffer[colourCountSize] = line[i];
                    colourCountSize = colourCountSize + 1;
                } else if (colourCountSize > 0 and line[i] == ' ') {
                    searchingColourCount = false;
                    searchingColourName = true;
                }
            } else if (searchingColourName) {
                if (line[i] >= 'b' and line[i] <= 'u') {
                    colourNameBuffer[colourNameSize] = line[i];
                    colourNameSize = colourNameSize + 1;
                }
                if (line[i] == ',' or line[i] == ';' or line[i] == '\n' or i == line.len - 1) {
                    const dieRollSlice = colourBuffer[0..colourCountSize];
                    const dieRoll: u8 = try std.fmt.parseInt(u8, dieRollSlice, 10);
                    const colour = colourNameBuffer[0..colourNameSize];

                    if (std.mem.eql(u8, colour, "red")) {
                        fewestRed = @max(fewestRed, dieRoll);
                    } else if (std.mem.eql(u8, colour, "blue")) {
                        fewestBlue = @max(fewestBlue, dieRoll);
                    } else if (std.mem.eql(u8, colour, "green")) {
                        fewestGreen = @max(fewestGreen, dieRoll);
                    }

                    colourBuffer = undefined;
                    colourCountSize = 0;
                    colourNameBuffer = undefined;
                    colourNameSize = 0;
                    searchingColourCount = true;
                    searchingColourName = false;
                }
            }
        }
        const power = fewestRed * fewestGreen * fewestBlue;
        powerSums = powerSums + power;
    }
    return powerSums;
}
