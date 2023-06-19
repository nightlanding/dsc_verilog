//TESTBENCH 
`timescale 1us/1us


module TESTBENCH();
  
reg  signed  [7:0] TiData[1:6][1:6];  // Test input  Data
reg  signed [19:0] ToData[1:4][1:4];  // Test output Data
reg  signed  [7:0] TiDataSingle;  // for transmission
wire signed [19:0] ToDataSingle;  // for transmission
reg clk;
reg reset;
reg CONV_start;
wire CONV_finish;
reg [7:0] i;
reg [7:0] j;

parameter period = 10;
parameter hperiod = 5;

CONV CONV_T(
    .reset(reset),
    .clk(clk),
    .CONV_start(CONV_start),
    .CONV_finish(CONV_finish),
    .CONV_iData(TiDataSingle),
    .CONV_oData(ToDataSingle));
             
initial
begin
  
$display("0.Load  Data");
  $readmemh("Data_input.txt", TiData);
  for(i = 1; i < 7; i = i + 1)
    $display("%d %d %d %d %d %d", TiData[i][1], TiData[i][2], TiData[i][3],
                                  TiData[i][4], TiData[i][5], TiData[i][6]);
  
  
  clk = 0;
  CONV_start = 0;  
  reset = 1;      // Reset Chip
  #period  
  reset = 0;      // Chip Working
  #period 
  CONV_start = 1; // CONV start and writing data
  // align test data to the negedge of clk
  
$display("1.Write Data");
  for(i = 1; i < 7; i = i + 1)
  for(j = 1; j < 7; j = j + 1)
  begin
      TiDataSingle = TiData[i][j];
      #period;
  end
  CONV_start = 0; // finish writing data
  
  
  
$display("2.Convolution");
  while(!CONV_finish) #period;
  #period;
  
  
$display("3.Read  Data");
  for(i = 1; i < 5; i = i + 1)
  for(j = 1; j < 5; j = j + 1)  
  begin
      ToData[i][j] = ToDataSingle;
      #period;
  end  
  for(i = 1; i < 5; i = i + 1)
    $display("%d %d %d %d", ToData[i][1], ToData[i][2], ToData[i][3], ToData[i][4]);  
  
$display("End");

end

always #hperiod clk = !clk; 

  
endmodule

