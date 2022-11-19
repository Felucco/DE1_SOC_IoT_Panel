module Txt_Renderer(

	input              CLOCK_50,
	
	output      [6:0]  HEX0,
	output      [6:0]  HEX1,
	output      [6:0]  HEX2,
	output      [6:0]  HEX3,
	output      [6:0]  HEX4,
	output      [6:0]  HEX5,
	
	inout              HPS_CONV_USB_N,
	output      [14:0] HPS_DDR3_ADDR,
	output      [2:0]  HPS_DDR3_BA,
	output             HPS_DDR3_CAS_N,
	output             HPS_DDR3_CKE,
	output             HPS_DDR3_CK_N, //1.5V
	output             HPS_DDR3_CK_P, //1.5V
	output             HPS_DDR3_CS_N,
	output      [3:0]  HPS_DDR3_DM,
	inout       [31:0] HPS_DDR3_DQ,
	inout       [3:0]  HPS_DDR3_DQS_N,
	inout       [3:0]  HPS_DDR3_DQS_P,
	output             HPS_DDR3_ODT,
	output             HPS_DDR3_RAS_N,
	output             HPS_DDR3_RESET_N,
	input              HPS_DDR3_RZQ,
	output             HPS_DDR3_WE_N,
	output             HPS_ENET_GTX_CLK,
	inout              HPS_ENET_INT_N,
	output             HPS_ENET_MDC,
	inout              HPS_ENET_MDIO,
	input              HPS_ENET_RX_CLK,
	input       [3:0]  HPS_ENET_RX_DATA,
	input              HPS_ENET_RX_DV,
	output      [3:0]  HPS_ENET_TX_DATA,
	output             HPS_ENET_TX_EN,
	inout       [3:0]  HPS_FLASH_DATA,
	output             HPS_FLASH_DCLK,
	output             HPS_FLASH_NCSO,
	inout              HPS_GSENSOR_INT,
	inout              HPS_I2C1_SCLK,
	inout              HPS_I2C1_SDAT,
	inout              HPS_I2C2_SCLK,
	inout              HPS_I2C2_SDAT,
	inout              HPS_I2C_CONTROL,
	inout              HPS_KEY,
	inout              HPS_LED,
	inout              HPS_LTC_GPIO,
	output             HPS_SD_CLK,
	inout              HPS_SD_CMD,
	inout       [3:0]  HPS_SD_DATA,
	output             HPS_SPIM_CLK,
	input              HPS_SPIM_MISO,
	output             HPS_SPIM_MOSI,
	inout              HPS_SPIM_SS,
	input              HPS_UART_RX,
	output             HPS_UART_TX,
	input              HPS_USB_CLKOUT,
	inout       [7:0]  HPS_USB_DATA,
	input              HPS_USB_DIR,
	input              HPS_USB_NXT,
	output             HPS_USB_STP,
	
	input       [9:0]  SW,
	input			[3:0]  KEY,
	output		[9:0]	 LEDR,
	
	output VGA_CLK,
	output VGA_BLANK_N,
	output VGA_SYNC_N,
	
	output VGA_HS,
	output VGA_VS,
	
	output [7:0]VGA_R,
	output [7:0]VGA_B,
	output [7:0]VGA_G
	
); 

	wire [31:0] to_HPS, from_HPS;

	wire [7:0] p1_r, p1_w, p2_r, p2_w;
	wire [12:0] p1_addr, p2_addr, p2_char_addr, p2_graph_addr;
	wire p1_we, p2_we;

	wire [511:0] font_data;
	wire [6:0] font_addr;

	core_sys core (
        .clk_clk                         ( CLOCK_50 ),               //     clk.clk
        .reset_reset_n                   ( KEY[0] ),                   //     reset.reset_n
        
		  .memory_mem_a                    ( HPS_DDR3_ADDR ),          //      memory.mem_a
        .memory_mem_ba                   ( HPS_DDR3_BA ),            //     .mem_ba
        .memory_mem_ck                   ( HPS_DDR3_CK_P ),          //     .mem_ck
        .memory_mem_ck_n                 ( HPS_DDR3_CK_N ),          //     .mem_ck_n
        .memory_mem_cke                  ( HPS_DDR3_CKE ),           //     .mem_cke
        .memory_mem_cs_n                 ( HPS_DDR3_CS_N ),          //     .mem_cs_n
        .memory_mem_ras_n                ( HPS_DDR3_RAS_N ),         //     .mem_ras_n
        .memory_mem_cas_n                ( HPS_DDR3_CAS_N ),         //     .mem_cas_n
        .memory_mem_we_n                 ( HPS_DDR3_WE_N ),          //     .mem_we_n
        .memory_mem_reset_n              ( HPS_DDR3_RESET_N ),       //     .mem_reset_n
        .memory_mem_dq                   ( HPS_DDR3_DQ ),            //     .mem_dq
        .memory_mem_dqs                  ( HPS_DDR3_DQS_P ),         //     .mem_dqs
        .memory_mem_dqs_n                ( HPS_DDR3_DQS_N ),         //     .mem_dqs_n
        .memory_mem_odt                  ( HPS_DDR3_ODT ),           //     .mem_odt
        .memory_mem_dm                   ( HPS_DDR3_DM ),            //     .mem_dm
        .memory_oct_rzqin                ( HPS_DDR3_RZQ ),           //     .oct_rzqin
		  
		  .hps_io_hps_io_emac1_inst_TX_CLK ( HPS_ENET_GTX_CLK ),      //       hps_io.hps_io_emac1_inst_TX_CLK
        .hps_io_hps_io_emac1_inst_TXD0   ( HPS_ENET_TX_DATA[0] ),   //      .hps_io_emac1_inst_TXD0
        .hps_io_hps_io_emac1_inst_TXD1   ( HPS_ENET_TX_DATA[1] ),   //      .hps_io_emac1_inst_TXD1
        .hps_io_hps_io_emac1_inst_TXD2   ( HPS_ENET_TX_DATA[2] ),   //      .hps_io_emac1_inst_TXD2
        .hps_io_hps_io_emac1_inst_TXD3   ( HPS_ENET_TX_DATA[3] ),   //      .hps_io_emac1_inst_TXD3
        .hps_io_hps_io_emac1_inst_RXD0   ( HPS_ENET_RX_DATA[0] ),   //      .hps_io_emac1_inst_RXD0
        .hps_io_hps_io_emac1_inst_MDIO   ( HPS_ENET_MDIO ),         //      .hps_io_emac1_inst_MDIO
        .hps_io_hps_io_emac1_inst_MDC    ( HPS_ENET_MDC ),          //      .hps_io_emac1_inst_MDC
        .hps_io_hps_io_emac1_inst_RX_CTL ( HPS_ENET_RX_DV ),        //      .hps_io_emac1_inst_RX_CTL
        .hps_io_hps_io_emac1_inst_TX_CTL ( HPS_ENET_TX_EN ),        //      .hps_io_emac1_inst_TX_CTL
        .hps_io_hps_io_emac1_inst_RX_CLK ( HPS_ENET_RX_CLK ),       //      .hps_io_emac1_inst_RX_CLK
        .hps_io_hps_io_emac1_inst_RXD1   ( HPS_ENET_RX_DATA[1] ),   //      .hps_io_emac1_inst_RXD1
        .hps_io_hps_io_emac1_inst_RXD2   ( HPS_ENET_RX_DATA[2] ),   //      .hps_io_emac1_inst_RXD2
        .hps_io_hps_io_emac1_inst_RXD3   ( HPS_ENET_RX_DATA[3] ),   //      .hps_io_emac1_inst_RXD3
        
        
		  .hps_io_hps_io_sdio_inst_CMD     ( HPS_SD_CMD ),          //      .hps_io_sdio_inst_CMD
        .hps_io_hps_io_sdio_inst_D0      ( HPS_SD_DATA[0] ),      //      .hps_io_sdio_inst_D0
        .hps_io_hps_io_sdio_inst_D1      ( HPS_SD_DATA[1] ),      //      .hps_io_sdio_inst_D1
        .hps_io_hps_io_sdio_inst_CLK     ( HPS_SD_CLK ),          //      .hps_io_sdio_inst_CLK
        .hps_io_hps_io_sdio_inst_D2      ( HPS_SD_DATA[2] ),      //      .hps_io_sdio_inst_D2
        .hps_io_hps_io_sdio_inst_D3      ( HPS_SD_DATA[3] ),      //      .hps_io_sdio_inst_D3
        
		  .hps_io_hps_io_usb1_inst_D0      ( HPS_USB_DATA[0] ),     //      .hps_io_usb1_inst_D0
        .hps_io_hps_io_usb1_inst_D1      ( HPS_USB_DATA[1] ),     //      .hps_io_usb1_inst_D1
        .hps_io_hps_io_usb1_inst_D2      ( HPS_USB_DATA[2] ),     //      .hps_io_usb1_inst_D2
        .hps_io_hps_io_usb1_inst_D3      ( HPS_USB_DATA[3] ),     //      .hps_io_usb1_inst_D3
        .hps_io_hps_io_usb1_inst_D4      ( HPS_USB_DATA[4] ),     //      .hps_io_usb1_inst_D4
        .hps_io_hps_io_usb1_inst_D5      ( HPS_USB_DATA[5] ),     //      .hps_io_usb1_inst_D5
        .hps_io_hps_io_usb1_inst_D6      ( HPS_USB_DATA[6] ),     //      .hps_io_usb1_inst_D6
        .hps_io_hps_io_usb1_inst_D7      ( HPS_USB_DATA[7] ),     //      .hps_io_usb1_inst_D7
        .hps_io_hps_io_usb1_inst_CLK     ( HPS_USB_CLKOUT ),      //      .hps_io_usb1_inst_CLK
        .hps_io_hps_io_usb1_inst_STP     ( HPS_USB_STP ),         //      .hps_io_usb1_inst_STP
        .hps_io_hps_io_usb1_inst_DIR     ( HPS_USB_DIR ),         //      .hps_io_usb1_inst_DIR
        .hps_io_hps_io_usb1_inst_NXT     ( HPS_USB_NXT ),         //      .hps_io_usb1_inst_NXT
         
		  .hps_io_hps_io_uart0_inst_RX     ( HPS_UART_RX ),         //      .hps_io_uart0_inst_RX
        .hps_io_hps_io_uart0_inst_TX     ( HPS_UART_TX ),         //      .hps_io_uart0_inst_TX
        
		  .from_hps_ext_export					( from_HPS ),         //  sw_external_connection.export
        .to_hps_ext_export						( to_HPS ),    //  hex_external_connection.export
		  
		  .char_mem_p2_address               (p2_addr),               //    amm_port2.address
        .char_mem_p2_chipselect            (1'b1),            //             .chipselect
        .char_mem_p2_clken                 (1'b1),                 //             .clken
        .char_mem_p2_write                 (p2_we),                 //             .write
        .char_mem_p2_readdata              (p2_r),              //             .readdata
        .char_mem_p2_writedata             (p2_w),             //             .writedata
        .char_mem_p1_address               (p1_addr),               //    amm_port1.address
        .char_mem_p1_clken                 (1'b1),                 //             .clken
        .char_mem_p1_chipselect            (1'b1),            //             .chipselect
        .char_mem_p1_write                 (p1_we),                 //             .write
        .char_mem_p1_readdata              (p1_r),              //             .readdata
        .char_mem_p1_writedata             (p1_w),
		  
		  .font_mem_p_address              (font_addr),              //   font_mem_p.address
        .font_mem_p_debugaccess          (1'b0),          //             .debugaccess
        .font_mem_p_clken                (1'b1),                //             .clken
        .font_mem_p_chipselect           (1'b1),           //             .chipselect
        .font_mem_p_write                (1'b0),                //             .write
        .font_mem_p_readdata             (font_data),             //             .readdata
        .font_mem_p_writedata            (512'd0),            //             .writedata
        .font_mem_p_byteenable           (64'hff_ff_ff_ff) 
    );  
	 
	 Mem_Controller #(.M_WIDTH(8),.M_DEPTH(8192)) mem_controller 
	(
		.clk(CLOCK_50), .rst(~KEY[0]),
		.cmd(from_HPS[31:29]),
		.addr(from_HPS[28:16]),
		.din1(from_HPS[7:0]),
		.din2(from_HPS[15:8]),
		.mem_out(p1_r),
		.dout1(to_HPS[7:0]),
		.dout2(to_HPS[15:8]),
		.mem_in(p1_w),
		.mem_w_nr(p1_we),
		.mem_addr(p1_addr),
		.op_cplt_flag(to_HPS[31])
	);
	
	wire screen_eof;
	wire [9:0] px_x, px_x_p1;
	wire [8:0] px_y;

	 VGA_Sync vga_sync (
		.clk(CLOCK_50), .rst(~KEY[0]), .en(SW[9]),
		.vga_blank_n(VGA_BLANK_N), .vga_sync_n(VGA_SYNC_N),
		.vga_hsync(VGA_HS),.vga_vsync(VGA_VS),.eof(screen_eof),
		.x_coord(px_x), .y_coord(px_y));
	
	assign px_x_p1 = px_x + 1; //Per considerare i due colpi di clock di ritardo ma con clock a frequenza doppia
		
	wire [9:0] ci; // 42 x 22 caratteri = 924 -> 10 bit
	wire px_off_lims;
	
	CI_Gen #(.FONT_W(15),.FONT_H(21),.SCREEN_W(640),.SCREEN_H(480)) char_index_gen (
		.px(px_x_p1), .py(px_y), .ci(ci),.off_limits(px_off_lims));
	
	wire [8:0] fi; // Font 15 x 21 -> 315px -> 9 bit
	
	FI_Gen #(.FONT_W(15),.FONT_H(21),.SCREEN_W(640),.SCREEN_H(480)) font_index_gen (
		.px(px_x_p1), .py(px_y), .fi(fi));
		
	// Char memory Lookup
	wire [6:0] px_char;
	
	assign p2_char_addr = {3'b000,ci};
	assign px_char = p2_r[6:0];
	
	wire pxi;
	
	Font_BMP #(.FONT_W(15),.FONT_H(21)) font_bitmap_mem (
		.en(SW[9]),
		.off_limits(px_off_lims), .cc(px_char), .fi(fi),
		.font_mem_dout(font_data[511:197]), .font_mem_addr(font_addr),
		.pxi(pxi));
	
	wire th_switcher;
	wire [2:0] th;
	
	Edge_Trigger TH_SW (.clk(CLOCK_50),.rst(~KEY[0]),.in(~KEY[3]),.out(th_switcher));
	
	CNT #(.N_BIT(3)) theme (.clk(CLOCK_50), .rst(~KEY[0]), .en(th_switcher), .d_nu(1'b0), .cnt(th));
	
	wire [7:0] txt_R, txt_G, txt_B;
	
	Theme_Handler TH (
		.pxi(pxi),.theme(th),.R(txt_R),.G(txt_G),.B(txt_B));
	
	T_FF TFF (.clk(CLOCK_50),.rst(~KEY[0]),.t(1'b1),.q(VGA_CLK));
	
	// Sensor mode handler
	
	wire sens_mode_en;
	wire [2:0] sens_mode;
	
	Edge_Trigger sens_mode_SW (.clk(CLOCK_50), .rst(~KEY[0]), .in(~KEY[2]), .out(sens_mode_en));
	CNT #(.N_BIT(3)) sens_mode_CNT (.clk(CLOCK_50), .rst(~KEY[0]), .en(sens_mode_en), .d_nu(1'b0), .cnt(sens_mode));
	
	assign to_HPS[30:28] = sens_mode;
	
	BCD_7Seg sens_mode_7seg (.A({1'b0,sens_mode}),.HEX0(HEX5));
	assign HEX4=7'b111_1111;
	
	// Sensor update period handler
	
	wire sens_t_en;
	wire [3:0] sens_t, sens_t_mod;
	assign sens_t[3]=1'b0;
	
	Edge_Trigger sens_t_SW (.clk(CLOCK_50), .rst(~KEY[0]), .in(~KEY[1]), .out(sens_t_en));
	UDL_CNT #(.N_BIT(3)) sens_t_CNT (.clk(CLOCK_50), .rst(~KEY[0]), .en(sens_t_en), .d_nu(1'b0),
											.pl(sens_t[2:0]==3'b110),.pin(3'h0),.cnt(sens_t[2:0]));
	
	assign sens_t_mod = (sens_t+1)<<1;
	
	assign to_HPS[27:24] = sens_t_mod;
	
	BCD_7Seg sens_t_7seg (.A(sens_t_mod),.HEX0(HEX3));
	
	
	assign p2_addr = SW[0] ? p2_graph_addr : p2_char_addr;
	
	// Graph mode: set switch 0 to go to graph mode from text mode
	
	//1: Update trigger generator
	
	wire hs_update_trg, trg_addr;
	assign trg_addr = p1_addr==13'h8A0;
	Edge_Trigger hs_update_ET (.clk(CLOCK_50), .rst(~KEY[0]), .in(trg_addr),.out(hs_update_trg));
	
	reg led_set;
	assign LEDR[0]=led_set;
	always @(posedge CLOCK_50 or posedge ~KEY[0]) begin
		if (~KEY[0]) led_set <= 1'b0;
		else if (hs_update_trg) led_set<=1'b1;
	end
	
	assign p2_we = 0;
	
	//2: Column heights buffer
	
	wire [100*8-1:0] hs_buf;
	
	Buff_Controller Buff_CNTL(
		.clk(CLOCK_50), .rst(~KEY[0]), .en(SW[0]), .trg(hs_update_trg),
		.data_in(p2_r),
		.mem_addr(p2_graph_addr),
		.out(hs_buf)
	);
	
	//3: Linear interpolators + Pixel checkers
	
	wire [4:0] pxy_control;
	
	genvar interpol_idx;
	generate
		for (interpol_idx=0;interpol_idx<5;interpol_idx=interpol_idx+1) begin: PX_Interpolator_Gen
			if (interpol_idx<2) begin
				PX_Lin_Interpol #(
					 .N_COLS(20),
					 .SCREEN_W(640),
					 .SCREEN_H(480)
				) PX_Interpol (
					 .col_hs(hs_buf[(20*(interpol_idx+1)*8)-1:(20*interpol_idx*8)]),
					 .px(px_x),.py(480-px_y),.en(SW[0]&sens_mode[interpol_idx]),
					 .pxy_line(pxy_control[interpol_idx])
				);
			end else begin
				PX_Lin_Interpol #(
					 .N_COLS(20),
					 .SCREEN_W(640),
					 .SCREEN_H(480)
				) PX_Interpol (
					 .col_hs(hs_buf[(20*(interpol_idx+1)*8)-1:(20*interpol_idx*8)]),
					 .px(px_x),.py(480-px_y),.en(SW[0]&sens_mode[2]),
					 .pxy_line(pxy_control[interpol_idx])
				);
			end
		end
	endgenerate
	
	
	//4: Pixel Theme Handler
	
	wire [7:0] graph_R, graph_G, graph_B;
	
	Graph_TH_Handler G_TH_Handler (.px_code(pxy_control),
												.graph_R(graph_R), .graph_G(graph_G), .graph_B(graph_B));
									
	//Graph mode switching
	
	assign VGA_R = SW[0] ? graph_R : txt_R;
	assign VGA_G = SW[0] ? graph_G : txt_G;
	assign VGA_B = SW[0] ? graph_B : txt_B;
	
	BCD_7Seg h2_7s (.A(p2_addr[11:8]),.HEX0(HEX2));
	BCD_7Seg h1_7s (.A(p2_addr[7:4]),.HEX0(HEX1));
	BCD_7Seg h0_7s (.A(p2_addr[3:0]),.HEX0(HEX0));
	assign to_HPS[23] = SW[0];
	
	
endmodule