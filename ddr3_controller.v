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

    /////////////////////////////////////////////////////Controller States ////////////////////////////////////////////////////////////////
    
    parameter SIZE = 5;			// 17 states in the state diagram for the controller
    parameter POWER_ON = 5'b00000, RESET = 5'b00001, INIT = 5'b00010, ZQ_CALIB = 5'b00011, MRS_SET = 5'b00100, IDLE = 5'b00101, SELF_REFR = 5'b00110, REFRESH = 5'b00111, ACTIVE = 5'b01000, ACTIVE_PWR_DN = 5'b01001, PRE_PWR_DN = 5'b01010, BANK_ACT = 5'b01011, WRITE = 5'b01100, READ = 5'b01101, WRITE_AP = 5'b01110, READ_AP = 5'b01111, PRECHARGE = 5'b10000;

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
					end
			default: next_state = IDLE;
		endcase

	end


endmodule