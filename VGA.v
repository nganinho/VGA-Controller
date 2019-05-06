`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Degic Lab
// Engineer: Admin
// www.degic.freeforums.net
//////////////////////////////////////////////////////////////////////////////////
// http://tinyvga.com/vga-timing
// https://reference.digilentinc.com/learn/programmable-logic/tutorials/vga-display-congroller/start


//		2'b00: ram_line = (pixel_counter > 10'd143 && pixel_counter < 10'd264) ? 1'b1 : 1'b0;
//		2'b01: ram_line = (pixel_counter > 10'd143 && pixel_counter < 10'd384) ? 1'b1 : 1'b0;
//		2'b11: ram_line = (pixel_counter > 10'd143 && pixel_counter < 10'd504) ? 1'b1 : 1'b0;
//		default: ram_line = (pixel_counter > 10'd143 && pixel_counter < 10'd264) ? 1'b1 : 1'b0;
//
//		2'b00: ram_col = (line_counter  > 10'd35  && line_counter  < 10'd156) ? 1'b1  : 1'b0;
//		2'b01: ram_col = (line_counter  > 10'd35  && line_counter  < 10'd276) ? 1'b1  : 1'b0;
//		2'b11: ram_col = (line_counter  > 10'd35  && line_counter  < 10'd396) ? 1'b1  : 1'b0;
//		default: ram_col = (line_counter  > 10'd35  && line_counter  < 10'd156) ? 1'b1  : 1'b0;

`define PIXEL_CNT 		10'd799
`define LINE_CNT  		10'd524

// pixel count for zoom
`define PIX_CNT_LOW 	10'd143
`define PIX_CNT_HI_1X 	10'd264
`define PIX_CNT_HI_2X	10'd384
`define PIX_CNT_HI_3X	10'd504

// line count for zoom
`define LIN_CNT_LOW 	10'd35
`define LIN_CNT_HI_1X 	10'd156
`define LIN_CNT_HI_2X	10'd276
`define LIN_CNT_HI_3X	10'd396

module VGA_IMG(   
    clock,
    reset,
    switch0,
    switch1,
    vsync,
    hsync,
    red,
    gre,
    blu
    );
input    clock;
input    reset;
input    switch0;
input    switch1;
output   vsync;
output   hsync;
output [3:0]    red;
output [3:0]    gre;
output [3:0]    blu;

wire    clock;
wire    reset;
wire    switch0;
wire    switch1;
reg     vsync;
reg     hsync;
reg  [3:0]    red;
reg  [3:0]    gre;
reg  [3:0]    blu;

// resolution: 640 x 480
// 
//Description	          Notation	Time	Width/Freq
//Pixel Clock	          tclk	    \39.7 ns (± 0.5%)	25.175MHz
//Hor Sync Time	          ths	    3.813 ?s	96 Pixels
//Hor Back Porch	      thbp	    1.907 ?s	48 Pixels
//Hor Front Porch	      thfp	    0.636 ?s	16 Pixels
//Hor Addr Video Time	  thaddr	25.422 ?s	640 Pixels
//Hor L/R Border	      thbd	        0 ?s	0 Pixels
//V Sync Time	          tvs	    0.064 ms	2 Lines
//V Back Porch	          tvbp	    1.048 ms	33 Lines
//V Front Porch	          tvfp	    0.318 ms	10 Lines
//V Addr Video Time	      tvaddr	15.253 ms	480 Lines
//V T/B Border	          tvbd	        0 ms	0 Lines

reg [9:0] pixel_counter;
reg [9:0] line_counter;
reg ram_line, ram_col;

wire hsync_act;
wire vsync_act;

//wire line_on;
wire vga_reset_n;
wire pix_clk0;


reg [13:0] addr;
//wire [13:0]BLUE_addr;
//wire BLUE_clk;
//wire [3:0]BLUE_din;
wire [3:0]BLUE_dout;
//wire [0:0]BLUE_we;
//wire [13:0]GREEN_addr;
//wire GREEN_clk;
//wire [3:0]GREEN_din;
wire [3:0]GREEN_dout;
//wire [0:0]GREEN_we;
//wire [13:0]RED_addr;
//wire RED_clk;
//wire [3:0]RED_din;
wire [3:0]RED_dout;
//wire [0:0]RED_we;

// image ram
RAM_wrapper image_ram (
	.BLUE_addr	(addr),
	.BLUE_clk	(pix_clk0),
	.BLUE_din	(),
	.BLUE_dout	(BLUE_dout),
	.BLUE_we	(0),
	.GREEN_addr	(addr),
	.GREEN_clk	(pix_clk0),
	.GREEN_din	(),
	.GREEN_dout	(GREEN_dout),
	.GREEN_we	(0),
	.RED_addr	(addr),
	.RED_clk	(pix_clk0),
	.RED_din	(),
	.RED_dout	(RED_dout),
	.RED_we		(0)
);

// clock generator:
PPLL_wrapper ppll (
    .board100   (clock),
    .locked     (vga_reset_n),
    .pix_clk0   (pix_clk0), // 21.175Mhz
    .reset      (reset)
    );
    
assign hsync_act = ( pixel_counter >= 10'd0 &&  pixel_counter <= 10'd95) ? 1'b1: 1'b0;
assign vsync_act = ( line_counter  >= 10'd0 &&  line_counter  <= 10'd1 ) ? 1'b1: 1'b0;


// pixel counter
always @ ( posedge pix_clk0 ) begin
    if (vga_reset_n == 1'b0 ) begin
        pixel_counter <= #1 10'd0;
    end
    else begin
        if ( pixel_counter < `PIXEL_CNT ) 
            pixel_counter <= pixel_counter + 10'd1;
        else  pixel_counter <= #1 10'd0;
    end 
end
// line counter
always @ ( posedge pix_clk0 ) begin
    if (vga_reset_n == 1'b0 ) begin
        line_counter <= #1 10'd0;
    end
    else begin
        if (pixel_counter == `PIXEL_CNT ) begin
            if ( line_counter < `LINE_CNT ) line_counter <= #1 line_counter + 10'd1;
            else                            line_counter <= #1 10'd0;
        end
    end 
end

// vsync
always @ (posedge pix_clk0) begin
    if ( vga_reset_n == 1'b0 )   vsync <= #1 1'b1;
    else begin
        if ( vsync_act == 1'b1 ) vsync <= #1 1'b0;
        else                     vsync <= #1 1'b1;
    end
end
// hsync
always @ (posedge pix_clk0) begin
    if ( vga_reset_n == 1'b0 )   hsync <= #1 1'b1;
    else begin
        if ( hsync_act == 1'b1 ) hsync <= #1 1'b0;
        else                     hsync <= #1 1'b1;
    end
end

// Logic of ram line enable when zoom and display. 
always @ (*) begin
	case ({switch1, switch0})
		2'b00:   ram_line = (pixel_counter > `PIX_CNT_LOW && pixel_counter < `PIX_CNT_HI_1X ) ? 1'b1 : 1'b0;
		2'b01:   ram_line = (pixel_counter > `PIX_CNT_LOW && pixel_counter < `PIX_CNT_HI_2X ) ? 1'b1 : 1'b0;
		2'b11:   ram_line = (pixel_counter > `PIX_CNT_LOW && pixel_counter < `PIX_CNT_HI_3X ) ? 1'b1 : 1'b0;
		default: ram_line = (pixel_counter > `PIX_CNT_LOW && pixel_counter < `PIX_CNT_HI_1X ) ? 1'b1 : 1'b0;
	endcase
end

// Logic of ram col enable when zoom and display.
always @ (*) begin
	case ({switch1, switch0})
		2'b00:   ram_col = (line_counter  > `LIN_CNT_LOW  && line_counter  < `LIN_CNT_HI_1X) ? 1'b1  : 1'b0;
		2'b01:   ram_col = (line_counter  > `LIN_CNT_LOW  && line_counter  < `LIN_CNT_HI_2X) ? 1'b1  : 1'b0;
		2'b11:   ram_col = (line_counter  > `LIN_CNT_LOW  && line_counter  < `LIN_CNT_HI_3X) ? 1'b1  : 1'b0;
		default: ram_col = (line_counter  > `LIN_CNT_LOW  && line_counter  < `LIN_CNT_HI_1X) ? 1'b1  : 1'b0;
	endcase
end

// addr of memory read.
always @ (*) begin 
	if (ram_col && ram_line) begin
		if (switch0 == 1'b0 && switch1 == 1'b0) begin
			addr = (( pixel_counter - 10'd144)*120) + (line_counter - 10'd36);
		end
		else begin
			if (switch0 == 1'b1 && switch1 == 1'b0) begin
				addr = (((pixel_counter - 10'd144)/2)*120) + ((line_counter - 10'd36)/2);
			end
			else begin
				if (switch0 == 1'b1 && switch1 == 1'b1)
					addr = (((pixel_counter - 10'd144)/3)*120) + ((line_counter - 10'd36)/3);
				else addr = 14'd0;
			end
		end
	end
	else 	addr = 14'd0;
end

// color data output
always @ (posedge pix_clk0 ) begin
    if ( vga_reset_n == 1'b0 ) begin
        red <= #1 4'h0;
        gre <= #1 4'h0;
        blu <= #1 4'h0;
    end
    else begin 
		red <= #1 (ram_col && ram_line ) ? RED_dout   : 4'h0;
        gre <= #1 (ram_col && ram_line ) ? GREEN_dout : 4'h0;
        blu <= #1 (ram_col && ram_line ) ? BLUE_dout  : 4'h0;
	end
end
	
// color code 	
endmodule
