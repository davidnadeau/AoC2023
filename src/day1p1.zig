const std = @import("std");

pub fn main() !void {
    const result: i32 = try readInput("input/day1.txt");
    std.debug.print("{d}\n", .{result});
}

pub fn readInput(filename: []const u8) !i32 {
    var file = try std.fs.cwd().openFile(filename, .{});

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var calibration_buffer: [2]u8 = undefined;
    var sum: i32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var first_digit: u8 = 0;
        var last_digit: u8 = 0;
        for (line) |c| {
            if (c >= '0' and c <= '9') {
                if (first_digit == 0) {
                    first_digit = c;
                    last_digit = c;
                } else {
                    last_digit = c;
                }
            }
        }
        calibration_buffer[0] = first_digit;
        calibration_buffer[1] = last_digit;
        const calibration_string: []u8 = calibration_buffer[0..2];

        const calibration_value = try std.fmt.parseInt(i32, calibration_string, 10);
        first_digit = 0;
        last_digit = 0;
        sum = sum + calibration_value;
    }
    return sum;
}
