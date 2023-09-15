`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module tb;
    reg clock, reset,start;
    
    wire [7:0] an, dec_cat;
	reg soma,subtracao,cont;

    localparam PERIOD = 2;  
    
    initial begin
        clock <= 1'b0;
        forever #1 clock <= ~clock;
    end

    initial
    begin
        reset <= 1'b1;
        start <= 1'b0;
		
		
        #127
        reset <= 0'b0;
        #184
        start <= 1'b1;
        #700
        start <= 1'b0;
        #3850
        cont <= 1'b1;
		#700
		cont <= 1'b0;
        #700
        soma <= 1'd1;
		#10
		soma <= 1'd0;
		#10
		soma <= 1'd1;
		#10
		soma <= 1'd0;
		#10
		soma <= 1'd1;
		#10
		soma <= 1'd0;
		#10
		soma <= 1'd1;
		#10
		soma <= 1'd0;
		#1000
        
        cont <= 1'b1;
		#700
		cont <= 1'b0;
        #700
        soma <= 1'd1;
		#10
		soma <= 1'd0;
		#10
		soma <= 1'd1;
		#10
		soma <= 1'd0;
		#10
		soma <= 1'd1;
		#10
		soma <= 1'd0;
		#10
		soma <= 1'd1;
		#10
		soma <= 1'd0;
		#1000

		cont <= 1'b1;
		#700
		cont <= 1'b0;
        #700
        soma <= 1'd1;
		#10
		soma <= 1'd0;
		#10
		soma <= 1'd1;
		#10
		soma <= 1'd0;
		#10
		soma <= 1'd1;
		#10
		soma <= 1'd0;
		#10
		soma <= 1'd1;
		#10
		soma <= 1'd0;
		#1000
		cont <= 1'b1;
		#500
		cont <= 1'b0;
		//#2500
	end

	relogio DUT (.clock(clock), .reset(reset), .soma(soma), .subtracao(subtracao),.cont(cont), .an(an), .dec_cat(dec_cat));

endmodule


