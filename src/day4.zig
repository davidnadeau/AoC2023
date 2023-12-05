const std = @import("std");

const embeddedData = @embedFile("data/day4.txt");
const allocator = std.heap.page_allocator;

const Ticket = struct { id: u16, winningNumbers: std.AutoHashMap(u8, void), picks: std.AutoHashMap(u8, void) };

pub fn main() !void {
    const tickets = try parseFile();

    const totalTicketScore: u16 = try calculateTicketScore(tickets);
    std.debug.print("part 1: {d}\n", .{totalTicketScore});
    const totalTicketCount: u32 = try countNumberOfTickets(tickets);
    std.debug.print("part 2: {d}\n", .{totalTicketCount});
}

// part 1
pub fn calculateTicketScore(
    tickets: std.ArrayList(Ticket),
) !u16 {
    var totalTicketScore: u16 = 0;
    for (tickets.items) |ticket| {
        const ticketScore: u16 = try getTicketScore(ticket);
        totalTicketScore = totalTicketScore + ticketScore;
    }
    return totalTicketScore;
}
pub fn getTicketScore(ticket: Ticket) !u16 {
    var ticketScore: u16 = 0;
    var winningNumbersIterator = ticket.winningNumbers.iterator();
    while (winningNumbersIterator.next()) |number| {
        const matchingValue = ticket.picks.get(number.key_ptr.*);
        if (matchingValue) |_| {
            if (ticketScore == 0) {
                ticketScore = ticketScore + 1;
            } else {
                ticketScore = ticketScore * 2;
            }
        }
    }
    return ticketScore;
}

// part 2
pub fn countNumberOfTickets(
    tickets: std.ArrayList(Ticket),
) !u32 {
    var copies = std.AutoHashMap(u16, u32).init(allocator);
    for (tickets.items) |ticket| {
        try copies.put(ticket.id, 1);
    }

    const numberOfTickets = tickets.items.len;
    for (tickets.items) |ticket| {
        const matchingNumbers: u16 = try countWinningNumbers(ticket);
        const extraTicketsIndex: u16 = @intCast(@min(matchingNumbers + ticket.id + 1, numberOfTickets + 1));
        const thisTicketsNumberOfCopies = copies.get(ticket.id).?;
        for (@min(ticket.id + 1, numberOfTickets + 1)..extraTicketsIndex) |i| {
            const currentNumberOfCopies = copies.get(@intCast(i)).?;
            const newNumberOfCopies: u32 = currentNumberOfCopies + thisTicketsNumberOfCopies;
            try copies.put(@intCast(i), newNumberOfCopies);
        }
    }

    var totalTickets: u32 = 0;
    var copiesIterator = copies.iterator();
    while (copiesIterator.next()) |copy| {
        totalTickets = totalTickets + copy.value_ptr.*;
    }
    return totalTickets;
}

pub fn countWinningNumbers(ticket: Ticket) !u16 {
    var matchingNumbers: u16 = 0;
    var winningNumbersIterator = ticket.winningNumbers.iterator();
    while (winningNumbersIterator.next()) |number| {
        const matchingValue = ticket.picks.get(number.key_ptr.*);
        if (matchingValue) |_| {
            matchingNumbers = matchingNumbers + 1;
        }
    }
    return matchingNumbers;
}

pub fn parseFile() !std.ArrayList(Ticket) {
    var tickets = std.ArrayList(Ticket).init(allocator);

    var lines = std.mem.split(u8, embeddedData, "\n");

    while (lines.next()) |line| {
        var cardIterator = std.mem.split(u8, line, ": ");
        var cardNumberPortion = cardIterator.next().?;
        const cardNumber = std.mem.trim(u8, cardNumberPortion[4..], " ");
        const cardId = try std.fmt.parseInt(u8, cardNumber, 10);

        const gameInformation = cardIterator.next().?;
        var gameInformationIterator = std.mem.split(u8, gameInformation, " | ");
        var winningNumbers = std.mem.split(u8, gameInformationIterator.next().?, " ");
        var picks = std.mem.split(u8, gameInformationIterator.next().?, " ");

        var winningNumberSet = std.AutoHashMap(u8, void).init(allocator);
        var picksSet = std.AutoHashMap(u8, void).init(allocator);

        while (winningNumbers.next()) |number| {
            const numericValue = std.fmt.parseInt(u8, number, 10) catch 0;
            if (numericValue != 0) {
                try winningNumberSet.put(numericValue, {});
            }
        }

        while (picks.next()) |number| {
            const numericValue = std.fmt.parseInt(u8, number, 10) catch 0;
            if (numericValue != 0) {
                try picksSet.put(numericValue, {});
            }
        }

        try tickets.append(Ticket{ .id = cardId, .winningNumbers = winningNumberSet, .picks = picksSet });
    }
    return tickets;
}
