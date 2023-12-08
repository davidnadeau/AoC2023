const std = @import("std");

const embeddedData = @embedFile("data/day7.txt");
const allocator = std.heap.page_allocator;

const HandData = struct { hand: []const u8, bid: u32, score: u8 };
const Hand = struct { card: u8, count: u8 };

var hands = std.ArrayList(HandData).init(allocator);
var handsWithJokers = std.ArrayList(HandData).init(allocator);

var cardScores = std.AutoHashMap(u8, u8).init(allocator);

pub fn main() !void {
    try cardScores.put('J', 1);
    try cardScores.put('2', 2);
    try cardScores.put('3', 3);
    try cardScores.put('4', 4);
    try cardScores.put('5', 5);
    try cardScores.put('6', 6);
    try cardScores.put('7', 7);
    try cardScores.put('8', 8);
    try cardScores.put('9', 9);
    try cardScores.put('T', 10);
    try cardScores.put('Q', 12);
    try cardScores.put('K', 13);
    try cardScores.put('A', 14);

    try parseFiles();
    try part1();
    try part2();
}

pub fn part1() !void {
    std.mem.sort(HandData, hands.items, {}, compareHands);
    var totalWinning: u64 = 0;
    for (hands.items, 1..) |item, rank| {
        totalWinning += item.bid * @as(u32, @truncate(rank));
    }
    std.debug.print("part 1 {d}\n", .{totalWinning});
}

pub fn part2() !void {
    std.mem.sort(HandData, handsWithJokers.items, {}, compareHands);
    var totalWinning: u64 = 0;
    for (handsWithJokers.items, 1..) |item, rank| {
        totalWinning += item.bid * @as(u32, @truncate(rank));
    }
    std.debug.print("part 2 {d}\n", .{totalWinning});
}

fn compareHands(context: void, a: HandData, b: HandData) bool {
    _ = context;
    if (a.score == b.score) {
        for (0..a.hand.len) |i| {
            const scoreA = cardScores.get(a.hand[i]).?;
            const scoreB = cardScores.get(b.hand[i]).?;
            if (scoreA == scoreB) {
                continue;
            } else {
                return scoreA < scoreB;
            }
        }
        return true;
    } else {
        return a.score < b.score;
    }
}

fn getScore(data: []const u8) !u8 {
    var counts = std.AutoHashMap(u8, u8).init(allocator);

    for (0..5) |i| {
        const card = data[i];
        if (counts.get(card)) |count| {
            try counts.put(card, count + 1);
        } else {
            try counts.put(card, 1);
        }
    }

    var keys = [_]u8{ 0, 0, 0, 0, 0 };

    var keysIter = counts.iterator();

    var i: u8 = 0;
    while (keysIter.next()) |entry| {
        keys[i] = entry.value_ptr.*;
        i += 1;
    }

    if (keys[0] == 5) {
        return 7;
    } else if (keys[0] == 4) {
        return 6;
    } else if (keys[0] == 3 and keys[1] == 2) {
        return 5;
    } else if (keys[0] == 3) {
        return 4;
    } else if (keys[0] == 2 and keys[1] == 2) {
        return 3;
    } else if (keys[0] == 2) {
        return 2;
    } else {
        return 1;
    }
}

fn compareHand(context: void, a: Hand, b: Hand) bool {
    _ = context;
    return a.count > b.count;
}

fn getScoreWithJokers(data: []const u8) !u8 {
    var counts = std.AutoHashMap(u8, u8).init(allocator);
    defer counts.deinit();

    var numberOfJokers: u8 = 0;
    for (0..5) |i| {
        const card = data[i];
        if (card == 'J') {
            numberOfJokers += 1;
        }
        if (counts.get(card)) |count| {
            try counts.put(card, count + 1);
        } else {
            try counts.put(card, 1);
        }
    }

    var keysList = std.ArrayList(Hand).init(allocator);
    defer keysList.deinit();

    var keysIter = counts.iterator();

    while (keysIter.next()) |entry| {
        try keysList.append(Hand{ .card = entry.key_ptr.*, .count = entry.value_ptr.* });
    }

    const keys = keysList.items;
    std.mem.sort(Hand, keys, {}, compareHand);

    if (keys[0].count == 5) {
        return 7;
    } else if (keys[0].count == 4) {
        if (keys[0].card == 'J') {
            return 7;
        } else {
            return 6 + numberOfJokers;
        }
    } else if (keys[0].count == 3 and keys[1].count == 2) {
        if (keys[0].card == 'J' or keys[1].card == 'J') {
            return 7;
        } else {
            return 5;
        }
    } else if (keys[0].count == 3) {
        if (keys[0].card == 'J') {
            return 6;
        } else if (numberOfJokers > 0) {
            return 4 + 1 + numberOfJokers;
        } else {
            return 4;
        }
    } else if (keys[0].count == 2 and keys[1].count == 2) {
        if (keys[0].card == 'J' or keys[1].card == 'J') {
            return 6;
        } else if (numberOfJokers > 0) {
            return 5;
        } else {
            return 3;
        }
    } else if (keys[0].count == 2) {
        if (keys[0].card == 'J' or numberOfJokers > 0) {
            return 4;
        } else {
            return 2;
        }
    } else {
        return 1 + numberOfJokers;
    }
}

pub fn parseFiles() !void {
    var lines = std.mem.split(u8, embeddedData, "\n");
    while (lines.next()) |line| {
        var lineParts = std.mem.tokenize(u8, line, " ");
        const hand = lineParts.next().?;
        const bid = try std.fmt.parseInt(u32, lineParts.next().?, 10);
        const score = try getScore(hand);
        const scoreWithJoker = try getScoreWithJokers(hand);
        try hands.append(HandData{ .hand = hand, .bid = bid, .score = score });
        try handsWithJokers.append(HandData{ .hand = hand, .bid = bid, .score = scoreWithJoker });
    }
}
