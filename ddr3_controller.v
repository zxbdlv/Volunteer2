`timescale 1ns/10ps
`include "1024_ddr3_parameters.vh"

module ddr3_controller(
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

	input   rst_n;
    input   ck;
    input   ck_n;
    input   cke;
    input   cs_n;
    input   ras_n;
    input   cas_n;
    input   we_n;
    inout   [DM_BITS-1:0]   dm_tdqs;
    input   [BA_BITS-1:0]   ba;
    input   [ADDR_BITS-1:0] addr;
    inout   [DQ_BITS-1:0]   dq;
    inout   [DQS_BITS-1:0]  dqs;
    inout   [DQS_BITS-1:0]  dqs_n;
    output  [DQS_BITS-1:0]  tdqs_n;
    input   odt;
    output reg [15:0] row_addr;			//512MB config
    output reg [10:0] col_addr;			//512MB config

    reg   [DQ_BITS-1:0]   dq_reg;
    reg   [DQS_BITS-1:0]  dqs_reg;
    reg   [DQS_BITS-1:0]  dqs_n_reg;
    reg  [DQS_BITS-1:0]  tdqs_n_reg;

    wire [4:0] command;

	assign dq = dq_reg;
	assign dqs = dqs_reg;
	assign dqs_n = dqs_n_reg;
	assign tdqs_n = tdqs_n_reg;
	assign command = {cke, cs_n, ras_n, cas_n, we_n};

	////////////////////////////////////// Commands //////////////////////////////////////

	parameter ACTIVATE = 5'b10011,
			  WRT = 5'b10100,
			  RD = 5'b10101,
			  RFRSH = 5'b10001,
			  PRCHRG = 5'b10010,
			  ZQ = 5'b10110,
			  NOP = 5'b10111,
			  DES = 5'b11111,
			  PWR_DN = 5'b01111,
			  SF_RF = 5'b00001,
			  LD = 5'b10000,
			  WR_AP = 5'b10100,
			  RD_AP = 5'b10101;

    /////////////////////////////////////////////////////Controller States////////////////////////////////////////////////////////////////
    
    parameter SIZE = 5;			// 17 states in the state diagram for the controller
    parameter POWER_ON = 5'b00000,
    		  RESET = 5'b00001,
    		  INIT = 5'b00010,
    		  ZQ_CALIB = 5'b00011,
    		  MRS_SET = 5'b00100,
    		  IDLE = 5'b00101,
    		  SELF_REFR = 5'b00110,
    		  REFRESH = 5'b00111,
    		  ACTIVE = 5'b01000,
    		  ACTIVE_PWR_DN = 5'b01001,
    		  PRE_PWR_DN = 5'b01010,
    		  BANK_ACT = 5'b01011,
    		  WRITE = 5'b01100,
    		  READ = 5'b01101,
    		  WRITE_AP = 5'b01110,
    		  READ_AP = 5'b01111,
    		  PRECHARGE = 5'b10000;

    reg [SIZE-1:0] state, next_state;


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    always @(posedge ck or negedge rst_n) begin

    	if (!rst_n) state <= #1 RESET;
    	else state <= #1 next_state;
	end

	always @(*) begin

		case(state)
			RESET : begin
							//Drive ouputs to Z, ODT = Z, Reset all refresh counters
							dq = DQ_BITS'hZ;
							dqs = DQS_BITS'hZ;
							dqs_n = DQS_BITS'hZ;
							tdqs_n = DQS_BITS'hZ;
							//wait for 200us and then INIT
							next_state = INIT;
					end
			INIT: begin
							//Initialization sequence here
							dq = DQ_BITS'hZ;
							dqs = DQS_BITS'hZ;
							dqs_n = DQS_BITS'hZ;
							tdqs_n = DQS_BITS'hZ;
            				if (command = 5'b10110) next_state = ZQ_CALIB; else next_state = INIT;
				  end		
			ZQ_CALIB: begin
							//ZQ Calibration sequence here.
							dq = DQ_BITS'hZ;
							dqs = DQS_BITS'hZ;
							dqs_n = DQS_BITS'hZ;
							tdqs_n = DQS_BITS'hZ;
							// After Tzqinit goto idle state
							next_state = IDLE;
					  end
			IDLE: begin
							if(command = ACTIVATE) next_state = ACTIVE;
							else if(command = SF_RF) next_state = SELF_REFR;
							else if(command = RFRSH) next_state = REFRESH;
							else if(command = PWR_DN) next_state = PRE_PWR_DN;
							else if(command = ZQ) next_state = ZQ_CALIB;
							else if(command = LD) next_state = MRS_SET;
							else next_state = IDLE;
				  end		
			ACTIVE: begin
							

							next_state = BANK_ACT;
					end
			BANK_ACT: begin:
							if(command = WRT) next_state = WRITE;
							else if(command = WR_AP) next_state = WRITE_AP;
							else if(command = RD) next_state = READ;
							else if(command = RD_AP) next_state = READ_AP;
							else if(command = PRCHRG) next_state = PRECHARGE;
							else next_state = BANK_ACT;
					  end			    	
			WRITE: begin
							col_addr = addr;
							if(command = READ) next_state = READ;
							else if(command = PRCHRG) next_state = PRECHARGE;
							else if(command = WR_AP) next_state = WRITE_AP;
							else if(command = RD_AP) next_state = READ_AP;
							else if(command = WRT) next_state = WRITE;
							else next_state = BANK_ACT;	
					end
			READ: begin
							col_addr = addr;
							if(command = READ) next_state = READ;
							else if(command = PRCHRG) next_state = PRECHARGE;
							else if(command = WR_AP) next_state = WRITE_AP;
							else if(command = RD_AP) next_state = READ_AP;
							else if(command = WRT) next_state = WRITE;
							else next_state = BANK_ACT;	
					end				  
			WRITE_AP: begin
							col_addr = addr;
							// Wait for write to complete
							next_state = PRECHARGE;
					  end			
			READ_AP: begin
							col_addr = addr;
							// Wait for write to complete
							next_state = PRECHARGE;
					 end		  

			default: next_state = IDLE;
		endcase

	end


endmodule