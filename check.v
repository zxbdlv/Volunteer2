`timescale 1ns/10ps

module check;

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


    initial begin

    	rst_n = 1'b0; #199990;
    	cke = 1'b0; #10 rst_n = 1'b1;
    	#500000;
    	@(posedge ck) cke = 1'b1;
    	#10 odt = 1'b0;
    	//TIS = IS time = 35
    	#35 cke = 1'b1;
    	


    end


endmodule

