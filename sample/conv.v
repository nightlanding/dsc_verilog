//CONV build in a 3*3 convolution core 
//for 6*6 input data

module CONV(
input wire reset,
input wire clk,
input wire CONV_start,
output reg CONV_finish,
input wire signed  [7:0] CONV_iData,
output reg signed [19:0] CONV_oData
);
  
reg signed [3:0]CONV_core[1:9];
  
reg  [3:0] ii_count;
reg  [3:0] ij_count;
reg  [3:0] ci_count;
reg  [3:0] cj_count;
reg  [3:0] oi_count;
reg  [3:0] oj_count;

reg  signed  [7:0] CONV_iArrayData[1:6][1:6];  // input  Data
reg  signed [19:0] CONV_oArrayData[1:4][1:4];  // output Data
reg  CONV_StartCal;  // Start convolution

// For ReConstruct
wire signed  [7:0] CONV_iReCon[1:9];  // input ReConstruct Temp
wire signed [19:0] CONV_mul[1:9];
wire signed [19:0] CONV_result;

// Calculating Convolution
assign CONV_iReCon[1] = CONV_iArrayData[ci_count+0][cj_count+0];
assign CONV_iReCon[2] = CONV_iArrayData[ci_count+0][cj_count+1];
assign CONV_iReCon[3] = CONV_iArrayData[ci_count+0][cj_count+2];
assign CONV_iReCon[4] = CONV_iArrayData[ci_count+1][cj_count+0];
assign CONV_iReCon[5] = CONV_iArrayData[ci_count+1][cj_count+1];
assign CONV_iReCon[6] = CONV_iArrayData[ci_count+1][cj_count+2];
assign CONV_iReCon[7] = CONV_iArrayData[ci_count+2][cj_count+0];
assign CONV_iReCon[8] = CONV_iArrayData[ci_count+2][cj_count+1];
assign CONV_iReCon[9] = CONV_iArrayData[ci_count+2][cj_count+2];

assign CONV_mul[1] = CONV_core[1]*CONV_iReCon[1];
assign CONV_mul[2] = CONV_core[2]*CONV_iReCon[2];
assign CONV_mul[3] = CONV_core[3]*CONV_iReCon[3];
assign CONV_mul[4] = CONV_core[4]*CONV_iReCon[4];
assign CONV_mul[5] = CONV_core[5]*CONV_iReCon[5];
assign CONV_mul[6] = CONV_core[6]*CONV_iReCon[6];
assign CONV_mul[7] = CONV_core[7]*CONV_iReCon[7];
assign CONV_mul[8] = CONV_core[8]*CONV_iReCon[8];
assign CONV_mul[9] = CONV_core[9]*CONV_iReCon[9];

assign CONV_result = CONV_mul[1] + CONV_mul[2] + CONV_mul[3] + 
                     CONV_mul[4] + CONV_mul[5] + CONV_mul[6] + 
                     CONV_mul[7] + CONV_mul[8] + CONV_mul[9];
    
                
// Init Core
always @(posedge reset)
begin
  CONV_core[1] <= 4'h0;
  CONV_core[2] <= 4'h1;
  CONV_core[3] <= 4'h2;
  CONV_core[4] <= 4'h2;
  CONV_core[5] <= 4'h2;
  CONV_core[6] <= 4'h0;
  CONV_core[7] <= 4'h0;
  CONV_core[8] <= 4'h1;
  CONV_core[9] <= 4'h2;
end


// Load input Data
always @(posedge clk or posedge reset or posedge CONV_finish)
begin
  if(reset || CONV_finish)
  begin
    ii_count <= 1;
    ij_count <= 1;  
    CONV_StartCal <= 0;
  end
  else if(CONV_start && (ii_count < 7))
  begin
    if(ij_count < 6)  ij_count <= ij_count + 1;
    else  
    begin
      if(ii_count < 6)begin ii_count <= ii_count + 1; ij_count <= 1;  end
      else            begin CONV_StartCal <= 1; end
    end
    CONV_iArrayData[ii_count][ij_count] <= CONV_iData;  // Load Data
  end
end


// Convolution
always @(posedge clk or posedge reset)
begin
  if(reset)
  begin
    ci_count <= 1;
    cj_count <= 1;  
    CONV_finish <= 0;

  end
  else if(CONV_StartCal && (ci_count < 5))
  begin
    if(cj_count < 4)            cj_count <= cj_count + 1;
    else 
    begin
      if(ci_count < 4)  begin ci_count <= ci_count + 1; cj_count <= 1;  end
      else              begin CONV_finish <= 1; end
    end
      
    CONV_oArrayData[ci_count][cj_count] <= CONV_result; // Record the Result
  end
end
  
// Output Data
always @(posedge clk or posedge reset or posedge CONV_start)
begin
  if(reset || CONV_start)
  begin
    oi_count <= 1;
    oj_count <= 1;
  end
  else if(CONV_finish && (oi_count < 5))
  begin  
    if(oj_count < 4)  oj_count <= oj_count + 1;
    else  
    begin
      if(oi_count < 4)begin oi_count <= oi_count + 1; oj_count <= 1;  end

    end
    CONV_oData <= CONV_oArrayData[oi_count][oj_count];  // Output Data
  end
  
end
  
  
endmodule
