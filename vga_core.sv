module vga_core #(
    parameter MEM_INIT_FILE = "default.mem" // Default memory initialization file
)(
    input wire clk,                        // Clock input
    input wire resetn,                     // resetn signal
    input wire [7:0] x,                    // X-coordinate (8 bits for 160)
    input wire [6:0] y,                    // Y-coordinate (7 bits for 120)
    input wire [2:0] color,                // Pixel color input (3 bits)
    input wire plot,                       // Write enable
    output wire [3:0] VGA_R,               // VGA red channel
    output wire [3:0] VGA_G,               // VGA green channel
    output wire [3:0] VGA_B,               // VGA blue channel
    output wire VGA_HS,                    // Horizontal sync
    output wire VGA_VS                     // Vertical sync
);

    // VGA timing signals
    wire video_on;
    wire [9:0] current_x;                  // Current X-coordinate (8 bits)
    wire [9:0] current_y;                  // Current Y-coordinate (7 bits)
    
    // VGA timing logic from vga_controller
    vga_controller vga_timing (
        .clk_100MHz(clk),
        .reset(~resetn),
        .video_on(video_on),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .x(current_x),
        .y(current_y)
    );

    // Adjust the coordinates for scaling
    wire [7:0] x_scaled = current_x[9:2]; // Scale down X-coordinate
    wire [6:0] y_scaled = current_y[8:2]; // Scale down Y-coordinate

    // Video memory instance
    wire [2:0] pixel_data;                 // Data read from memory
    wire [15:0] read_address;

    // Compute read address using scaled coordinates
    assign read_address = (y_scaled * 160 + x_scaled);

    // Video memory module for storing and retrieving pixel data
    video_memory video_mem (
        .clk_write(clk),
        .resetn(resetn),
        .write_enable(plot),    // Write enable
        .write_address(y * 160 + x),       // Compute address for writing
        .read_address(read_address), // Compute address for reading
        .data_in(color),                // Input color
        .data_out(pixel_data)              // Output color
    );

    // Map 3-bit pixel data to VGA signals
    assign VGA_R = video_on ? {pixel_data[2], pixel_data[2], pixel_data[2], pixel_data[2]} : 4'b000;
    assign VGA_G = video_on ? {pixel_data[1], pixel_data[1], pixel_data[1], pixel_data[1]} : 4'b000;
    assign VGA_B = video_on ? {pixel_data[0], pixel_data[0], pixel_data[0], pixel_data[0]} : 4'b000;

endmodule
