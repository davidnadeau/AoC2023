const std = @import("std");

const allocator = std.heap.page_allocator;
var colours_map = std.StringHashMap(u8).init(allocator);

pub fn main() !void {
    try colours_map.put("red", 12);
    try colours_map.put("green", 13);
    try colours_map.put("blue", 14);

    const result: i32 = try countGames("input/day2p1.txt");
    std.debug.print("{d}\n", .{result});
}

pub fn countGames(filename: []const u8) !i32 {
    var file = try std.fs.cwd().openFile(filename, .{});

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var validGameTally: i32 = 0;

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

        var isValidGame = true;

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
                } else if (line[i] == ',' or line[i] == ';' or line[i] == '\n') {
                    isValidGame = try isValidDie(colourBuffer[0..colourCountSize], colourNameBuffer[0..colourNameSize]);
                    colourBuffer = undefined;
                    colourCountSize = 0;
                    colourNameBuffer = undefined;
                    colourNameSize = 0;
                    searchingColourCount = true;
                    searchingColourName = false;

                    if (!isValidGame) {
                        break;
                    }
                }
            }
        }
        const gameId = gameIdBuffer[0..idSize];
        if (isValidGame) {
            const gameValue = try std.fmt.parseInt(u8, gameId, 10);
            validGameTally = validGameTally + gameValue;
        }
    }
    return validGameTally;
}
pub fn isValidDie(colourCount: []u8, colourName: []u8) !bool {
    const count = try std.fmt.parseInt(u8, colourCount, 10);
    const maxCount = colours_map.get(colourName).?;
    return count <= maxCount;
}
