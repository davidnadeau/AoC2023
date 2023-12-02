const std = @import("std");

const numbers = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

const allocator = std.heap.page_allocator;
var numbers_map = std.StringHashMap(u8).init(allocator);

pub fn main() !void {
    try numbers_map.put("one", '1');
    try numbers_map.put("two", '2');
    try numbers_map.put("three", '3');
    try numbers_map.put("four", '4');
    try numbers_map.put("five", '5');
    try numbers_map.put("six", '6');
    try numbers_map.put("seven", '7');
    try numbers_map.put("eight", '8');
    try numbers_map.put("nine", '9');

    const result: i32 = try decode_calibration_values("input/day1p2.txt");

    std.debug.print("{d}\n", .{result});
}

pub fn decode_calibration_values(filename: []const u8) !i32 {
    var file = try std.fs.cwd().openFile(filename, .{});

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var calibration_buffer: [2]u8 = undefined;
    var sum: i32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const first_digit: u8 = try find_first(line, false);
        std.mem.reverse(u8, line);
        const last_digit: u8 = try find_first(line, true);

        calibration_buffer[0] = first_digit;
        calibration_buffer[1] = last_digit;
        const calibration_string: []u8 = calibration_buffer[0..2];

        const calibration_value = try std.fmt.parseInt(i32, calibration_string, 10);
        sum = sum + calibration_value;
    }
    return sum;
}

pub fn find_first(line: []const u8, reversed: bool) !u8 {
    var concat_alpha: [100]u8 = undefined;
    var index: u8 = 0;

    for (line) |c| {
        if (c >= '0' and c <= '9') {
            return c;
        } else {
            concat_alpha[index] = c;
            index = index + 1;
            const byte_slice = concat_alpha[0..index];
            const is_valid_substring = try is_substring_valid(byte_slice, reversed);
            if (is_valid_substring) {
                for (numbers) |number| {
                    const tmp_number = try allocator.dupe(u8, number);
                    if (reversed) {
                        std.mem.reverse(u8, tmp_number);
                    }
                    if (std.mem.eql(u8, byte_slice, tmp_number)) {
                        return numbers_map.get(number).?;
                    }
                }
            } else {
                concat_alpha[0] = undefined;
                index = index - 1;
                for (concat_alpha, 0..) |element, i| {
                    if (i > 0) {
                        concat_alpha[i - 1] = element;
                    }
                }
            }
        }
    }
    return '0';
}

pub fn is_substring_valid(substring: []u8, reversed: bool) !bool {
    for (numbers) |number| {
        const tmp_number = try allocator.dupe(u8, number);
        if (reversed) {
            std.mem.reverse(u8, tmp_number);
        }
        if (std.mem.startsWith(u8, tmp_number, substring)) {
            return true;
        }
    }
    return false;
}
