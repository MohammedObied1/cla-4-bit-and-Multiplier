module full_Adder_1bit(a,b,C_in,sum,C_out);
    input a;
    input b;
    input C_in;
    output sum;
    output C_out;
    wire w1, w2, w3, w4, w5;
    // XOR gate with 6 time units delay
    xor #6 (w1, a, b);
    xor #6 (sum, w1, C_in);
    // AND gates with 3 time units delay
    and #3 (w2, a, b);
    and #3 (w3, a, C_in);
    and #3 (w4, b, C_in);
    // OR gates with 4 time units delay
    or  #4 (w5, w2, w3);
    or  #4 (C_out, w5, w4);
endmodule
module adder_4_bit ( a,b,C_in, sum,C_out);
    input [3:0] a; 
    input [3:0] b;
    input C_in;
    output [3:0] sum;
    output C_out;
    wire [3:0] carry;
    full_Adder_1bit FA0 (.a(a[0]),.b(b[0]),.C_in(C_in),.sum(sum[0]),.C_out(carry[0]));
    full_Adder_1bit FA1 (.a(a[1]),.b(b[1]),.C_in(carry[0]),.sum(sum[1]),.C_out(carry[1]));
    full_Adder_1bit FA2 (.a(a[2]),.b(b[2]),.C_in(carry[1]),.sum(sum[2]),.C_out(carry[2]));
    full_Adder_1bit FA3 (.a(a[3]),.b(b[3]),.C_in(carry[2]),.sum(sum[3]),.C_out(C_out));
endmodule

/////////////////////////////////////////////////////////////
module D_flip_flopinputreg (d ,clk ,Q );
	input d;
	input clk ;
	output reg  Q ;
  always @ (posedge clk ) 
    Q=d;
endmodule 

module D_flip_flopoutputreg (d ,clk , Q );
	input d ;
	input clk ;
	output reg  Q ;
  always @ (posedge clk ) 
    Q=d;
endmodule 
////////////////////////////////////
module multiplier (x, y, res, clk);                                                                                 
  parameter n = 6;      // Define a parameter for the size of input y                                                                                            
  input [0:3] x;        // 4-bit input x                                                                                            
  input [n-1:0] y;      // n-bit input y                                                                                            
  input clk;            // Clock                                                                                            
  output [n+3:0] res;   // Output result size (n+4) bits                                                                                            
  wire [0:3] x1;        // wire value of x                                                                                            
  wire [0:n+3] y1;      // wire value of y                                                                                            

  // Generate flip-flops to register the input x                                                                                  
  genvar i , j;                                                                                                     
  generate                                                                                                          
    for (i = 0; i < 4; i = i + 1) begin                                                                             
      D_flip_flopinputreg x_reg (.d(x[i]), .clk(clk), .Q(x1[i])); // Register each bit of x                                                                            
    end                                                                                                             
  endgenerate                                                                                                       
  // Generate flip-flops to register the input y                                                                                  
  generate                                                                                                          
    for (i = 0; i < n; i = i + 1) begin                                                                             
      D_flip_flopinputreg y_reg (.d(y[i]), .clk(clk), .Q(y1[i])); // Register each bit of y                                                                            
    end                                                                                                             
  endgenerate                                                                                                       
  wire [0:n][0:3] sum1; // Internal 2D array to hold partial products                                                                                             
  wire [0:4] s;         // Internal wire to hold intermediate sum                                                                                                

  // Generate the partial products                                                                                  
  generate                                                                                                          
    for (i = 0; i < n; i = i + 1) begin                                                                             
      for (j = 0; j < 4; j = j + 1) begin                                                                                   
        assign sum1[i][j] = y1[i] & x1[j]; // Compute partial product                                                                             
      end                                                                                                         
    end                                                                                                             
  endgenerate                                                                                                      
  assign s = {1'b0, sum1[0]}; // Initial sum with zero bit                                                                                      
  wire [0:n][0:3] sum;    // Internal 2D array to hold sums of partial products                                                                                              
  reg [0:n] c_out;        // Internal array to hold carry-out values                                                                                                  

  // 4-bit adder for the first partial product and sum                                                                                    
  adder_4_bit adder (.a(s[0:3]), .b(sum1[1]), .C_in(1'b0), .sum(sum[0]), .C_out(c_out[0])); // First adder operation                            
  reg [0:n][0:4] z;                                                                                               
                                                                                 
  generate                                                                                                         
    for (i = 2; i <= n; i = i + 1) begin                                                                           
      assign z[i-2] = {c_out[i-2], sum[i-2]}; // Concatenate carry and sum                                                                      
      adder_4_bit adder1 (.a(z[i-2][0:3]), .b(sum1[i]), .C_in(1'b0), .sum(sum[i-1]), .C_out(c_out[i-1]));             
    end                                                                                                   
  endgenerate                                                                                                    
  wire [n-3:0] out;                                                                                                                                                             
  generate                                                                                                            
    for (i = 0; i <= n-3; i = i + 1) begin                                                                
      assign out[i] = sum[i][3];                                                                                     
    end                                                                                                               
  endgenerate                                                                                                         
  wire [0:n-1+4] res1;                                                                                               
  wire [0:n-1+4] res2;                                                                                 
  assign res1 = { z[n-2], out, s[4] }; // Concatenate results and sum                                                                                 
  // Generate flip-flops to register the final result                                                                                  
  generate                                                                                                           
    for (i = 0; i < n+4; i = i + 1) begin                                                                            
      D_flip_flopoutputreg outputt (.d(res1[i]), .clk(clk), .Q(res2[i])); // Register each bit of the final result                                          
    end                                                                                                             
  endgenerate                                                                                                       
  assign res = res2; // Assign the final  result to the output                                                                                           
endmodule                                                                                                           

///////////////////////////////////////*///
module carry_lookahead_adder_4bit(a,b,cin, sum,cout);
    input [3:0] a; // 4-bit input a
    input [3:0] b; // 4-bit input b
    input cin;     // Carry input
    output [3:0] sum; // 4-bit sum output
    output cout;      // Carry output
    wire [3:0] p, g; // propagate and generate
    wire [3:0] c;    // internal carry

    // Propagate and Generate signals
    xor #6 (p[0], a[0], b[0]); // Propagate: p0 = a0 ^ b0
    xor #6(p[1], a[1], b[1]); // Propagate: p1 = a1 ^ b1
    xor #6(p[2], a[2], b[2]); // Propagate: p2 = a2 ^ b2
    xor #6(p[3], a[3], b[3]); // Propagate: p3 = a3 ^ b3

    and #3 (g[0], a[0], b[0]); // Generate: g0 = a0 & b0
    and  #3(g[1], a[1], b[1]); // Generate: g1 = a1 & b1
    and  #3(g[2], a[2], b[2]); // Generate: g2 = a2 & b2
    and #3 (g[3], a[3], b[3]); // Generate: g3 = a3 & b3

    // Carry signals
    assign c[0] = cin; // c0 is the input carry
    // Internal carry calculations
    wire p0_and_c0, p1_and_c1, p2_and_c2, p3_and_c3;
    and #3 (p0_and_c0, p[0], c[0]); // p0 & c0
    or  #4  (c[1], g[0], p0_and_c0); // c1 = g0 | (p0 & c0)
    and  #3(p1_and_c1, p[1], c[1]); // p1 & c1
    or   #4 (c[2], g[1], p1_and_c1); // c2 = g1 | (p1 & c1)
    and #3 (p2_and_c2, p[2], c[2]); // p2 & c2
    or  #4  (c[3], g[2], p2_and_c2); // c3 = g2 | (p2 & c2)
    and #3 (p3_and_c3, p[3], c[3]); // p3 & c3
    or #4   (cout, g[3], p3_and_c3); // cout = g3 | (p3 & c3)
    // Sum bits
    xor #6(sum[0], p[0], c[0]); // s0 = p0 ^ c0
    xor #6(sum[1], p[1], c[1]); // s1 = p1 ^ c1
    xor#6 (sum[2], p[2], c[2]); // s2 = p2 ^ c2
    xor #6(sum[3], p[3], c[3]); // s3 = p3 ^ c3

endmodule
  /////////////////////////////////*///
  module multipliercarryheadadder (x, y, res, clk);                                                                  
    parameter n = 4;       // Define a parameter for the size of input y                                                                              
    input [0:3] x;         // 4-bit input x                                                                                                           
    input [n-1:0] y;       // n-bit input y                                                                                                           
    input clk;             // Clock                                                                                                                   
    output [n+3:0] res;    // Output result size (n+4) bits                                                                                           
    wire [0:3] x1;         // wire value of x                                                                                                         
    wire [0:n+3] y1; // wire value of y  
	// Generate flip-flops to register the input x  
    genvar i , j;                                                                                      
    generate                                                                                           
      for (i = 0; i < 4; i = i + 1) begin                                                              
        D_flip_flopinputreg x (.d(x[i]), .clk(clk), .Q(x1[i]));                                        
      end                                                                                              
    endgenerate                                                                                        
    generate                                                                                           
      for (i = 0; i < n; i = i + 1) begin // Generate flip-flops to register the input y                                                               
       D_flip_flopinputreg y (.d(y[i]), .clk(clk), .Q(y1[i]));                                         
      end                                                                                              
    endgenerate                                                                                        
    wire [0:n][0:3] sum1;                                                                              
    wire  [0:4] s  ;                                                                                   
    generate                                                                                           
      for (i = 0; i < n; i = i + 1) begin                                                              
        for ( j =0 ; j <4  ; j=j+1)                                                                    
          begin                                                                                                                                                                                    
   assign sum1[i][j] = y1[i] & x1[j];                                                                                                                                                             
          end                                                                                          
      end                                                                                                                                                                                             
      endgenerate                                                                                      
    assign s = {1'b0, sum1[0]};                                                                                                                                                                       
    wire [0:n][0:3] sum;                                                                               
    reg [0:n] c_out;                                                                                                                                                                                    
    carry_lookahead_adder_4bit adder (.a(s[0:3]),.b(sum1[1]),.cin(1'b0),.sum(sum[0]),.cout(c_out[0])); // First carrylookadder operation                                                                                                  
    reg [0:n] [0:4]z ;                                                                                                                                                                                 
     generate                                                                                          
       for (i = 2; i <= n; i = i + 1) begin                                                                                                                                                         
         assign z[i-2] = {c_out[i-2],sum[i-2]} ;                                                                                                                                                 
        carry_lookahead_adder_4bit adder1( .a(z[i-2][0:3]),.b(sum1[i]),.cin(1'b0),.sum(sum[i-1]),.cout(c_out[i-1])) ;                                                                        
      end                                                                                                                                                                                            
       endgenerate                                                                                                                                                                                 
    wire[n-3:0]  out ;                                                                                 
  generate                                                                                             
    for (i =0; i <= n-3; i = i + 1) begin                                                  
      assign out[i] = sum[i][3];                                                                       
    end                                                                                                
  endgenerate                                                                                                                                                                                         
    wire [0:n-1+4] res1;                                                                               
    wire [0:n-1+4] res2;                                                                               
    assign res1 ={ z[n-2] ,out ,s[4]} ;                                                                                                                                                                  
   generate                                                                                            
     for (i = 0; i < n+4; i = i + 1) begin                                                             
         D_flip_flopoutputreg outputt (.d(res1[i]), .clk(clk), .Q(res2[i]));                           
      end                                                                                              
    endgenerate                                                                                        
    assign res = res2 ;                                                                                                                                      
                                                                                                       
  endmodule	
  //////////////////////////////////////// 
  
  module tb_multiplier;                                                                                                                                                            
    parameter n = 6; // Parameters                                                   
    // Inputs                                                          
    reg [0:3] x;                                                       
    reg [n-1:0] y;                                                     
    reg clk;                                                           
                                                                       
    // Outputs                                                         
    wire [n+3:0] res;                                                                                                            
    // Instantiate the Unit Under Test (UUT)                           
      multiplier uut ( .x(x), .y(y), .clk(clk), .res(res));            
                                                                       
    // Clock generation                                                
    initial begin                                                      
      clk = 0;                                                         
      forever #5 clk = ~clk;                     
    end                                                                                                             
    initial begin                                                                                          
      x = 4'b0000;                                                     
      y = 4'b0000;                                                                                           
      #1000;                                                                                                                                                         
      x = 4'b0011;                                               
      y = 4'b0101;                                               
      #100;                                                            
      $display("Test Case 1: x = %b, y = %b, res = %b", x, y, res);                                                       
      x = 4'b1111;                                                
      y = 4'b0001;                                               
      #100;                                                            
      $display("Test Case 2: x = %b, y = %b, res = %b", x, y, res);                                                   
      x = 4'b0011;                                                
      y = 4'b0011;                                                
      #100;                                                            
      $display("Test Case 3: x = %b, y = %b, res = %b", x, y, res);                                                     
      x = 4'b0010;                                                
      y = 4'b0011;                                                 
      #100;                                                            
      $display("Test Case 4: x = %b, y = %b, res = %b", x, y, res);    
  	 x = 4'b0101;                                            
  	 y = 4'b0010;                                            
      #100;                                                       
      $display("Test Case 5: x = %b, y = %b, res = %b", x, y, res);    
  	   $stop;                                                        
                                                                       
      		                                                         
    end                                                                
           
  endmodule