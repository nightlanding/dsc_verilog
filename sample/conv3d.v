module CONV3D(
input wire reset,
input wire clk,
input wire CONV_start,
output reg CONV_finish,
input wire signed [7:0] CONV_iData[1:3],  // Now input has 3 channels
output reg signed [19:0] CONV_oData[1:3]   // Now output has 3 channels
);

// Now convolution core has 3 sets for 3 channels
reg signed [3:0]CONV_core[1:3][1:9];

reg [3:0] ii_count;
reg [3:0] ij_count;
reg [3:0] ci_count;
reg [3:0] cj_count;
reg [3:0] oi_count;
reg [3:0] oj_count;
reg [1:0] ch_count;  // Channel count

reg signed [7:0] CONV_iArrayData[1:3][1:6][1:6];  // input Data
reg signed [19:0] CONV_oArrayData[1:3][1:4][1:4];  // output Data
reg CONV_StartCal;  // Start convolution

// For ReConstruct
wire signed [7:0] CONV_iReCon[1:3][1:9];  // input ReConstruct Temp for each channel
wire signed [19:0] CONV_mul[1:3][1:9];    // intermediate multiplication results
wire signed [19:0] CONV_result[1:3];      // convolution result for each channel

// Calculating Convolution
// Multiply convolution core with 3x3 input data for each channel
generate
for (genvar ch = 1; ch <= 3; ch = ch + 1) 
begin
  assign CONV_iReCon[ch][1] = CONV_iArrayData[ch][ci_count+0][cj_count+0];
  assign CONV_iReCon[ch][2] = CONV_iArrayData[ch][ci_count+0][cj_count+1];
  assign CONV_iReCon[ch][3] = CONV_iArrayData[ch][ci_count+0][cj_count+2];
  assign CONV_iReCon[ch][4] = CONV_iArrayData[ch][ci_count+1][cj_count+0];
  assign CONV_iReCon[ch][5] = CONV_iArrayData[ch][ci_count+1][cj_count+1];
  assign CONV_iReCon[ch][6] = CONV_iArrayData[ch][ci_count+1][cj_count+2];
  assign CONV_iReCon[ch][7] = CONV_iArrayData[ch][ci_count+2][cj_count+0];
  assign CONV_iReCon[ch][8] = CONV_iArrayData[ch][ci_count+2][cj_count+1];
  assign CONV_iReCon[ch][9] = CONV_iArrayData[ch][ci_count+2][cj_count+2];

  assign CONV_mul[ch][1] = CONV_core[ch][9]*CONV_iReCon[ch][1];
  assign CONV_mul[ch][2] = CONV_core[ch][8]*CONV_iReCon[ch][2];
  assign CONV_mul[ch][3] = CONV_core[ch][7]*CONV_iReCon[ch][3];
  assign CONV_mul[ch][4] = CONV_core[ch][6]*CONV_iReCon[ch][4];
  assign CONV_mul[ch][5] = CONV_core[ch][5]*CONV_iReCon[ch][5];
  assign CONV_mul[ch][6] = CONV_core[ch][4]*CONV_iReCon[ch][6];
  assign CONV_mul[ch][7] = CONV_core[ch][3]*CONV_iReCon[ch][7];
  assign CONV_mul[ch][8] = CONV_core[ch][2]*CONV_iReCon[ch][8];
  assign CONV_mul[ch][9] = CONV_core[ch][1]*CONV_iReCon[ch][9];

  assign CONV_result[ch] = CONV_mul[ch][1] + CONV_mul[ch][2] + CONV_mul[ch][3] 
                           + CONV_mul[ch][4] + CONV_mul[ch][5] + CONV_mul[ch][6]
                           + CONV_mul[ch][7] + CONV_mul[ch][8] + CONV_mul[ch][9];
end
endgenerate

always @(posedge clk or posedge reset)
begin
  if (reset)
  begin
    // init code omitted for brevity
  end
  else if (CONV_start)
  begin
    // init code omitted for brevity
    for (ch_count = 1; ch_count < 4; ch_count = ch_count + 1) 
    begin
      // loop for Convolution Calculation
      // inside the loop
      CONV_oArrayData[ch_count][oi_count][oj_count] = CONV_result[ch_count];
    end
    // loop end
  end
end

// Output Logic
always @(posedge clk or posedge reset)
begin
  if (reset)
  begin
    // init code omitted for brevity
  end
  else if (CONV_StartCal)
  begin
    // init code omitted for brevity
    for (ch_count = 1; ch_count < 4; ch_count = ch_count + 1) 
    begin
      // loop for output data
      // inside the loop
      CONV_oData[ch_count] = CONV_oArrayData[ch_count][oi_count][oj_count];
    end
    // loop end
  end
end

// Init Core for each channel
always @(posedge reset)
begin
  // For channel 1
  CONV_core[1][1] <= 4'h0;
  CONV_core[1][2] <= 4'h1;
  CONV_core[1][3] <= 4'h2;
  CONV_core[1][4] <= 4'h2;
  CONV_core[1][5] <= 4'h2;
  CONV_core[1][6] <= 4'h0;
  CONV_core[1][7] <= 4'h0;
  CONV_core[1][8] <= 4'h1;
  CONV_core[1][9] <= 4'h2;

  // For channel 2
  // Here you need to specify your own core data
  CONV_core[2][1] <= 4'h1;
  CONV_core[2][2] <= 4'h2;
  CONV_core[2][3] <= 4'h3;
  CONV_core[2][4] <= 4'h4;
  CONV_core[2][5] <= 4'h5;
  CONV_core[2][6] <= 4'h6;
  CONV_core[2][7] <= 4'h7;
  CONV_core[2][8] <= 4'h8;
  CONV_core[2][9] <= 4'h9;

  // For channel 3
  // Here you need to specify your own core data
  CONV_core[3][1] <= 4'h2;
  CONV_core[3][2] <= 4'h0;
  CONV_core[3][3] <= 4'h2;
  CONV_core[3][4] <= 4'h3;
  CONV_core[3][5] <= 4'h0;
  CONV_core[3][6] <= 4'h6;
  CONV_core[3][7] <= 4'h1;
  CONV_core[3][8] <= 4'h5;
  CONV_core[3][9] <= 4'h0;
end

endmodule
