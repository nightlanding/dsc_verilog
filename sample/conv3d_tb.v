`timescale 1us/1us

module TESTBENCH();
  
reg  signed  [7:0] TiData[1:3][1:6][1:6];  // Test input  Data
reg  signed [19:0] ToData[1:3][1:4][1:4];  // Test output Data
reg  signed  [7:0] TiDataSingle;  // for transmission
wire signed [19:0] ToDataSingle;  // for transmission
reg clk;
reg reset;
reg CONV_start;
wire CONV_finish;
reg [0:2] i;
reg [7:0] j;
reg [7:0] k;

parameter period = 10;
parameter hperiod = 5;

CONV3D CONV_T(
    .reset(reset),
    .clk(clk),
    .CONV_start(CONV_start),
    .CONV_finish(CONV_finish),
    .CONV_iData(TiDataSingle),
    .CONV_oData(ToDataSingle));
             
initial
begin
  
$display("0.Load  Data");
  $readmemh("Data3D_input.txt", TiData);
  for(i = 0; i < 4; i = i + 1)
    for(j = 1; j < 7; j = j + 1)
        $display("%d %d %d %d %d %d", TiData[i][j][1], TiData[i][j][2], TiData[i][j][3],
                                      TiData[i][j][4], TiData[i][j][5], TiData[i][j][6]);

  
  clk = 0;
  CONV_start = 0;  
  reset = 1;      // Reset Chip
  #period  
  reset = 0;      // Chip Working
  #period 
  CONV_start = 1; // CONV start and writing data
  // align test data to the negedge of clk

$display("1.Write Data");
  for(i = 0; i < 4; i = i + 1)
  for(j = 1; j < 7; j = j + 1)
  for(k = 1; k < 7; k = k + 1)
  begin
      TiDataSingle = TiData[i][j][k];
      #period;
  end
  CONV_start = 0; // finish writing data



$display("2.Convolution");
  while(!CONV_finish) #period;
  #period;


$display("3.Read  Data");
  for(i = 0; i < 4; i = i + 1)
  for(j = 1; j < 5; j = j + 1)
  for(k = 1; k < 5; k = k + 1)  
  begin
      ToData[i][j][k] = ToDataSingle;
      #period;
  end  
  for(i = 0; i < 4; i = i + 1)
  for(j = 1; j < 5; j = j + 1)
    $display("%d %d %d %d", ToData[i][j][1], ToData[i][j][2], ToData[i][j][3], ToData[i][j][4]);  

$display("End");

end

always #hperiod clk = !clk; 

endmodule