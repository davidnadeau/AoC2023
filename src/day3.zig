const std = @import("std");

const embeddedData = @embedFile("data/day3.txt");

const Point = struct { x: usize, y: usize };

const allocator = std.heap.page_allocator;
var gearMap = std.AutoHashMap(Point, i32).init(allocator);
var gearRatioMap = std.AutoHashMap(Point, i32).init(allocator);

pub fn main() !void {
    try calculateGearRatio();
}

pub fn calculateGearRatio() !void {
    var lines = std.mem.split(u8, embeddedData, "\n");
    var schematic: [200][]const u8 = undefined;

    // parse schematic
    var lineNumber: u8 = 0;
    while (lines.next()) |line| {
        schematic[lineNumber] = line;
        lineNumber = lineNumber + 1;
    }

    const numberOfRows = lineNumber;
    const numberOfColumns = schematic[0].len;

    var numberBuffer: [4]u8 = undefined;
    var numberLength: u8 = 0;

    var currentRow: i16 = 0;

    var part1Sum: i32 = 0;
    // check schematic
    for (schematic) |row| {
        if (currentRow == numberOfRows) break;

        for (row, 0..numberOfColumns) |c, columnIndex| {
            // build the numbers
            if (isDigit(c)) {
                numberBuffer[numberLength] = c;
                numberLength = numberLength + 1;
            }
            if ((!isDigit(c) and numberLength > 0) or (columnIndex == numberOfColumns - 1 and numberLength > 0)) {
                const number = try std.fmt.parseInt(i32, numberBuffer[0..numberLength], 10);
                const partNumber = try findPartAndGears(number, numberLength, currentRow, @truncate(columnIndex), schematic, numberOfRows);
                // part 1
                if (partNumber) {
                    part1Sum = part1Sum + number;
                }
                numberBuffer = undefined;
                numberLength = 0;
            }
        }
        currentRow = currentRow + 1;
    }

    // part 2
    var part2Sum: i32 = 0;
    var gearRatioIter = gearRatioMap.iterator();
    while (gearRatioIter.next()) |gear_ratio| {
        part2Sum = part2Sum + gear_ratio.value_ptr.*;
    }

    std.debug.print("part 1: {d}\n", .{part1Sum});
    std.debug.print("part 2: {d}\n", .{part2Sum});
}

pub fn findPartAndGears(number: i32, numberLength: u8, rowNumber: i16, columnNumber: u8, schematic: [200][]const u8, numberOfRows: u8) !bool {
    const minRow = @max(rowNumber - 1, 0);
    const maxRow = @min(rowNumber + 1, numberOfRows - 1) + 1;

    const startingIndex: i16 = @intCast(columnNumber - numberLength);
    const minColumn: usize = @max(startingIndex - 1, 0);
    const maxColumn: usize = @min(columnNumber + 1, schematic[0].len);

    var neigbourToASymbol = false;
    for (@intCast(minColumn)..@intCast(maxColumn)) |columnIndex| {
        for (@intCast(minRow)..@intCast(maxRow)) |rowIndex| {
            // part 1
            neigbourToASymbol = neigbourToASymbol or isSymbol(schematic[rowIndex][columnIndex]);
            // part 2
            try putInGearMap(rowIndex, columnIndex, number, schematic);
        }
    }
    return neigbourToASymbol;
}

pub fn putInGearMap(rowIndex: usize, columnIndex: usize, number: i32, schematic: [200][]const u8) !void {
    if (isGear(schematic[rowIndex][columnIndex])) {
        const gearAddress = Point{ .x = rowIndex, .y = columnIndex };
        const value = gearMap.get(gearAddress);
        if (value) |v| {
            // 2nd number neighbouring the gear, store the gear ratio
            try gearRatioMap.put(gearAddress, number * v);
        } else {
            // this is just 1 of potentially 2 numbers neighbouring the gear
            try gearMap.put(gearAddress, number);
        }
    }
}

pub fn isGear(c: u8) bool {
    return c == '*';
}

pub fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

pub fn isSymbol(c: u8) bool {
    return !((isDigit(c)) or (c == '.'));
}
