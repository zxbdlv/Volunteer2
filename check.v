`timescale 1ns/10ps

// Cycle time 0.938ns

module check();

    reg   rst_n;
    reg   ck;
    reg   ck_n;
    reg   cke;
    reg   cs_n;
    reg   ras_n;
    reg   cas_n;
    reg   we_n;
    wire   [DM_BITS-1:0]   dm_tdqs;
    reg   [BA_BITS-1:0]   ba;
    reg   [ADDR_BITS-1:0] addr;
    wire   [DQ_BITS-1:0]   dq;
    wire   [DQS_BITS-1:0]  dqs;
    wire   [DQS_BITS-1:0]  dqs_n;
    wire  [DQS_BITS-1:0]  tdqs_n;
    reg   odt;


    ddr3 control(
				    rst_n,
				    ck,
				    ck_n,
				    cke,
				    cs_n,
				    ras_n,
				    cas_n,
				    we_n,
				    dm_tdqs,
				    ba,
				    addr,
				    dq,
				    dqs,
				    dqs_n,
				    tdqs_n,
				    odt
	);

// Reset sequence test
    /*initial begin

    	rst_n = 1'b0; #199990;
    	cke = 1'b0; #10 rst_n = 1'b1;
    	#500000;
    	@(posedge ck) cke = 1'b1;
    	#10 odt = 1'b0;
    	//TIS = IS time = 35
    	#35 cke = 1'b1;
    	


    end
*/

	reg reset_done;
	reg [19:0] count_200us, count_500us, count_TIS, count_10ns_1, count_10ns_2, count_txpr;

	
///////////////////////////////////////// clock generation //////////////////////////////////////

	initial begin
		ck_n = 0;
		
	end

	always #0.469 ck_n = ~ck_n;
//////////////////////////////////////////////////////////////////////////////////////////////////
	/*
    		 repeat(213209) begin 
				@(negedge(ck_n)); cke = 1'b0;
			 end
    		 repeat(11) @(negedge(ck_n)); rst_n = 1'b1;
    		 repeat(533049) @(negedge(ck_n)); cke = 1'b1;
    		 repeat(11) @(negedge(ck_n)); odt = 1'b0;
    		 repeat(38) @(negedge(ck_n)); cke = 1'b1;
    		 */

/////////////////////////////////////////////// Reset sequence ///////////////////////////////////////////////////////////

   		 always @(*) begin
    		 
			 ck = ~ck_n;
	    		 reset_done = 0;
	    		// 
	    		 /*rst_n = 1'b0;
			 cke     = 1'b0;
		    	 cs_n    = 1'b1;
		   	 odt = 1'b0;*/
			cke = (count_200us == 20'd213208) ? 0 : cke;	//213208
			rst_n = (count_10ns_1 == 20'd213219) ? 1'b1 : rst_n;	//213219
			cke = (count_500us == 20'd746268) ? 1'b1 : cke;
			odt = (count_10ns_2 == 20'd746279) ? 1'b0 : odt;
			{cke, reset_done} = (count_TIS == 20'd746317) ? 2'b11 : {cke, reset_done}; //746317
			{cke, cs_n, ras_n, cas_n, we_n} = (count_txpr == 20'd128) ? 5'b10110 : {cke, cs_n, ras_n, cas_n, we_n};	//ZQ
			//#81386;
			
			{cke, cs_n, ras_n, cas_n, we_n, addr, ba} =  {5'b10000, $random, $random};	//
			//{cke, cs_n, ras_n, cas_n, we_n, addr, ba} = {5'b10011, addr, ba};
			#0.5;
		end

    		 always @(negedge(ck_n)) begin
			if (!reset_done) begin
	    		 	count_200us <= count_200us + 1'd1;
	    		 	
	    		 	
	    		 	count_10ns_1 <= count_10ns_1 + 1'd1;
	    		 		    		 	

	    		 	count_500us <= count_500us + 1'd1;
	    		 	

	    		 	count_10ns_2 <= count_10ns_2 + 1'd1;
	    		 	

	    		 	count_TIS <= count_TIS + 1'd1;
				
				count_txpr <= count_txpr + 1'd1;
	    		end 	
				
	    			
    		 end

		initial begin
			{count_200us, count_500us, count_TIS, count_10ns_1, count_10ns_2, count_txpr} = 0;
		end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    		 
    	

endmodule

