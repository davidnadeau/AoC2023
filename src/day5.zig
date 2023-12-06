const std = @import("std");

const embeddedData = @embedFile("data/day5.txt");
const allocator = std.heap.page_allocator;

var part1Seeds = std.ArrayList(u64).init(allocator);
var part2Seeds = std.ArrayList(u64).init(allocator);
var almanac = std.ArrayList(std.AutoHashMap(Range, u8)).init(allocator);

const Range = struct {
    src: u64,
    dest: u64,
    length: u64,
    fn inRange(self: *Range, i: u64) bool {
        return (i >= self.src) and (i < self.src + self.length);
    }
    fn convert(self: *Range, i: u64) u64 {
        if (self.src > self.dest) {
            return i - (self.src - self.dest);
        } else {
            return i + (self.dest - self.src);
        }
    }
};

pub fn main() !void {
    try parseFile();

    const part1 = try findSmallestLocation(part1Seeds);
    std.debug.print("part 1: {d}\n", .{part1});
    const part2 = try findSmallestLocation(part2Seeds);
    std.debug.print("part 2: {d}\n", .{part2});
}

pub fn findSmallestLocation(seeeds: std.ArrayList(u64)) !u64 {
    for (almanac.items) |mapping| {
        for (seeeds.items, 0..) |seed, i| {
            var mappingIterator = mapping.iterator();
            while (mappingIterator.next()) |entry| {
                var range = entry.key_ptr.*;
                if (range.inRange(seed)) {
                    seeeds.items[i] = range.convert(seed);
                    break;
                }
            }
        }
    }
    return std.mem.min(u64, seeeds.items);
}

pub fn parseFile() !void {
    var lines = std.mem.split(u8, embeddedData, "\n\n");
    var seedsSection = lines.next().?;

    // part 1 seed data
    var seedsIterator = std.mem.tokenize(u8, seedsSection[6..], " ");
    while (seedsIterator.next()) |seed| {
        const seedValue = try std.fmt.parseInt(u64, seed, 10);
        try part1Seeds.append(seedValue);
    }

    // part 2 seed data
    var seedsIterator2 = std.mem.tokenize(u8, seedsSection[6..], " ");
    while (seedsIterator2.next()) |seed| {
        const seedValue = try std.fmt.parseInt(u64, seed, 10);
        const length = try std.fmt.parseInt(u64, seedsIterator2.next().?, 10);
        var i: u64 = 0;
        while (i < length) {
            try part2Seeds.append(seedValue + i);
            i += 1;
        }
    }

    // parse almanac
    while (lines.next()) |line| {
        var mappingIterator = std.mem.split(u8, line, "\n");
        var mappingNameIterator = std.mem.split(u8, mappingIterator.next().?, " ");
        var mappingName = std.mem.split(u8, mappingNameIterator.next().?, "-");
        const mappingKey = mappingName.next().?;
        _ = mappingKey;
        var ranges = std.AutoHashMap(Range, u8).init(allocator);
        while (mappingIterator.next()) |mappingEntry| {
            var submapping = std.mem.split(u8, mappingEntry, " ");
            const destinationRangeStart = try std.fmt.parseInt(u64, submapping.next().?, 10);
            const sourceRangeStart = try std.fmt.parseInt(u64, submapping.next().?, 10);
            const rangeLength = try std.fmt.parseInt(u64, submapping.next().?, 10);
            try ranges.put(Range{ .src = sourceRangeStart, .dest = destinationRangeStart, .length = rangeLength }, ' ');
        }
        try almanac.append(ranges);
    }
}
