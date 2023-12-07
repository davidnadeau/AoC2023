const std = @import("std");

const embeddedData = @embedFile("data/day6.txt");
const allocator = std.heap.page_allocator;

const Race = struct { time: u64, distance: u64 };
var races = std.ArrayList(Race).init(allocator);

pub fn main() !void {
    try parseFiles();
    try part1();
    try part2();
}

pub fn part1() !void {
    var product: u64 = 1;
    for (races.items) |race| {
        product *= try getWaysToBeat(race);
    }
    std.debug.print("part 1 {d}\n", .{product});
}

pub fn part2() !void {
    var time: u64 = 0;
    var distance: u64 = 0;
    for (races.items) |race| {
        if (time == 0) {
            time = race.time;
            distance = race.distance;
        } else {
            const timeAsString = try std.fmt.allocPrint(allocator, "{d}", .{race.time});
            const distanceAsString = try std.fmt.allocPrint(allocator, "{d}", .{race.distance});
            time = (time * (std.math.pow(u32, 10, @as(u32, @intCast(timeAsString.len))))) + race.time;
            distance = (distance * (std.math.pow(u32, 10, @as(u32, @intCast(distanceAsString.len))))) + race.distance;
        }
    }
    const waystoBeat = try getWaysToBeat(Race{ .time = time, .distance = distance });
    std.debug.print("part 2 {d}\n", .{waystoBeat});
}

pub fn getWaysToBeat(race: Race) !u32 {
    var waysToBeat: u32 = 0;

    // stop iterating after we've crossed over the winning combinations
    var startedWinning = false;
    for (0..race.time) |i| {
        const wait = i;
        const timeLeft = race.time - wait;
        const distance = timeLeft * wait;
        if (distance > race.distance) {
            if (!startedWinning) {
                startedWinning = true;
            }
            waysToBeat += 1;
        } else if (startedWinning) {
            break;
        }
    }
    return waysToBeat;
}

pub fn parseFiles() !void {
    var lines = std.mem.split(u8, embeddedData, "\n");
    const timesSection = lines.next().?;
    const distanceSection = lines.next().?;

    var timeParts = std.mem.tokenize(u8, timesSection, " ");
    const timeString = timeParts.next();
    _ = timeString;
    var distanceParts = std.mem.tokenize(u8, distanceSection, " ");
    const distanceString = distanceParts.next();
    _ = distanceString;

    while (timeParts.next()) |part| {
        const distance = try std.fmt.parseInt(u16, distanceParts.next().?, 10);
        const time = try std.fmt.parseInt(u16, part, 10);
        try races.append(Race{ .time = time, .distance = distance });
    }
}
