module PmodJSTK
  (input [0:0]    clk_12mhz_i
   ,input [0:0]   reset_i
   ,input [39:0]  data_i
   ,input [0:0]   spi_sd_i
   ,output [0:0]  spi_cs_o
   ,output [0:0]  spi_sck_o
   ,output [0:0]  spi_sd_o
   ,output [39:0] data_o
   );

   wire [7:0]    tx_data_o;
   wire [7:0]    rx_data_i;
   wire [0:0]    busy_o;

   // 20 Hz clock, alternates between send/rec
   wire [0:0]    clk_20hz_o;
   wire [0:0]    tx_not_rx;

   // 66.67kHz Clock Divider, period 15us
   wire [0:0]    clk_66_67khz_o;

   // DR: Unfortunately, these two modules still use the classic SPI
   // naming. I have not had time to update them.
   spiCtrl
     #()
   SPI_Ctrl
     (.clk_i(clk_66_67khz_o)
     ,.reset_i(reset_i)
     ,.sndRec(clk_20hz_o)
     ,.BUSY(busy_o)
     ,.DIN(data_i)
     ,.RxData(rx_data_i)
     ,.SS(spi_cs_o)
     ,.getByte(tx_not_rx)
     ,.sndData(tx_data_o)
     ,.DOUT(data_o)
     );

   spiMode0 
     #()
   SPI_Int
     (.CLK(clk_66_67khz_o)
     ,.RST(reset_i)
     ,.sndRec(tx_not_rx)
     ,.DIN(tx_data_o)
     ,.MISO(spi_sd_i)
     ,.MOSI(spi_sd_o)
     ,.SCLK(spi_sck_o)
     ,.BUSY(busy_o)
     ,.DOUT(rx_data_i)
      );

   // 66.67kHz Clock Divider, period 15us, for serial clock timing
   ClkDiv_66_67kHz
     #()
   SerialClock
     (.clk_i(clk_12mhz_i)
     ,.reset_i(reset_i)
     ,.clk_o(clk_66_67khz_o)
     );

   // 20Hz Clock Divider Generates timing to initiate Send/Receive
   ClkDiv_20Hz
     #()
   genSndRec
     (.clk_i(clk_12mhz_i)
     ,.reset_i(reset_i)
     ,.clk_o(clk_20hz_o)
     );

endmodule

