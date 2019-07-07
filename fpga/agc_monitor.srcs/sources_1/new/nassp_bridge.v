`timescale 1ns / 1ps
`default_nettype none

`include "monitor_defs.v"

module nassp_bridge(
    input wire clk,
    input wire rst_n,

    input wire read_en,
    input wire write_en,
    output reg write_done,
    input wire [15:0] addr,
    input wire [15:0] data_in,
    output wire [15:0] data_out,

    input wire e_cycle_starting,
    input wire [11:1] e_cycle_addr,

    input wire [12:1] mt,
    input wire mnisq,
    input wire minkl,
    input wire [3:1] mst,
    input wire msqext,
    input wire mrgg,
    input wire mwbg,
    input wire mwsg,
    input wire mrchg,
    input wire mwchg,
    input wire [9:1] ch,
    input wire [16:1] g,
    input wire [16:1] mwl,
    output wire [16:1] mdt,

    input wire ems_bank0_en,
    output reg ems_write_en,
    output reg [11:1] ems_addr,
    output reg [16:1] ems_data,

    output reg periph_load,
    output reg [12:1] periph_s,
    output reg [15:1] periph_bb,
    output reg [16:1] periph_data,
    input wire periph_complete
);

reg [15:0] read_data;
reg read_done;
assign data_out = read_done ? read_data : 16'b0;

reg ch30_en;
reg [15:1] ch30;

reg ch31_en;
reg [15:1] ch31;

reg ch32_en;
reg [15:1] ch32;

reg ch33_en;
reg [15:1] ch33;

reg [16:1] mdt_redirect;
reg [16:1] mdt_channel;
assign mdt = mdt_redirect | mdt_channel;

always @(*) begin
    if (mrchg) begin
        case (ch)
        9'o70: mdt_channel = {ch30[15], ch30};
        9'o71: mdt_channel = {ch31[15], ch31};
        9'o72: mdt_channel = {ch32[15], ch32};
        9'o73: mdt_channel = {ch33[15], ch33};
        default: mdt_channel = 16'o0;
        endcase
    end else begin
        mdt_channel = 16'o0;
    end
end

reg nisql;
reg mt1_r;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        nisql <= 1'b0;
        mt1_r <= 1'b0;
    end else begin
        mt1_r <= mt[1];
        if (mnisq) begin
            nisql <= 1'b1;
        end else if (mt1_r & ~mt[1]) begin
            nisql <= 1'b0;
        end
    end
end

reg ext;
reg ndxx;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ext <= 1'b0;
    end else begin
        if (msqext & (mst == 3'd2) & nisql & mt[1]) begin
            ext <= 1'b1;
        end else if (mt[12] & ~ndxx) begin
            ext <= 1'b0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mdt_redirect <= 16'o0;
        ndxx <= 1'b0;
    end else begin
        if ((ext && mrgg && mwbg && mwsg && (mwl[16:13] == 4'b0) && (mwl[12:10] != 3'o7) && (mwl[9:7] == 3'o0)) &&
            ((ch30_en && (mwl[5:1] == 5'o30)) || (ch31_en && (mwl[5:1] == 5'o31)) ||
             (ch32_en && (mwl[5:1] == 5'o32)) || (ch33_en && (mwl[5:1] == 5'o33)))) begin
            mdt_redirect <= 16'o40;
        end else begin
            mdt_redirect <= 16'o0;
        end

        if (ext & mrgg & mwbg & mwsg & (mwl[16:13] == 4'b1101)) begin
            ndxx <= 1'b1;
        end else if (mt[1]) begin
            ndxx <= 1'b0;
        end
    end
end

reg [15:1] agc_pipax;
reg [15:1] agc_pipay;
reg [15:1] agc_pipaz;
reg [15:1] agc_thrust;
reg [15:1] agc_altm;

wire [15:1] agc_pipa;
reg [12:1] target_addr;

reg thrust_changed;
reg new_thrust;

reg altm_changed;
reg new_altm;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        agc_pipax <= 15'b0;
        agc_pipay <= 15'b0;
        agc_pipaz <= 15'b0;
        agc_thrust <= 15'b0;
        thrust_changed <= 1'b0;
        agc_altm <= 15'b0;
        altm_changed <= 1'b0;
        target_addr <= 12'o0;
    end else begin
        if (ems_write_en) begin
            case (ems_addr)
            `PIPAX:  agc_pipax  <= pipa_sum;
            `PIPAY:  agc_pipay  <= pipa_sum;
            `PIPAZ:  agc_pipaz  <= pipa_sum;
            endcase
        end
        if (target_addr == 12'o0) begin
            if (e_cycle_starting & (((e_cycle_addr >= `PIPAX) & (e_cycle_addr <= `PIPAZ)) |
                (e_cycle_addr == `THRUST) | (e_cycle_addr == `ALTM)))  begin
                target_addr <= e_cycle_addr;
            end
        end else begin
            if (new_thrust) begin
                thrust_changed <= 1'b0;
            end
            if (mt[11]) begin
                case (target_addr)
                `PIPAX:  agc_pipax  <= {g[16], g[14:1]};
                `PIPAY:  agc_pipay  <= {g[16], g[14:1]};
                `PIPAZ:  agc_pipaz  <= {g[16], g[14:1]};
                `THRUST: begin
                    if (~minkl) begin
                        thrust_changed <= 1'b1;
                        agc_thrust <= {g[16], g[14:1]};
                    end
                end
                `ALTM: begin
                    if (~minkl) begin
                        altm_changed <= 1'b1;
                        agc_altm <= {g[16], g[14:1]};
                    end
                end
                endcase
                target_addr <= 12'o0;
            end
        end
    end
end

reg [15:1] agc_pipa_value;
always @(*) begin
    case (addr)
    `NASSP_REG_PIPAX: agc_pipa_value = agc_pipax;
    `NASSP_REG_PIPAY: agc_pipa_value = agc_pipay;
    `NASSP_REG_PIPAZ: agc_pipa_value = agc_pipaz;
    default: agc_pipa_value = 15'b0;
    endcase
end


wire [15:1] pipa_sum;
ones_comp_adder adder(agc_pipa_value, data_in[14:0], pipa_sum);

reg [15:1] latched_thrust;
reg [15:1] latched_altm;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        latched_thrust <= 15'o0;
        new_thrust <= 1'b0;

        latched_altm <= 15'o0;
        new_altm <= 1'b0;
    end else begin
        if (mwchg && (ch == 9'o14) && (mwl & 16'o10)) begin
            latched_thrust <= agc_thrust;
            new_thrust <= thrust_changed;
        end else if (read_en & (addr == `NASSP_REG_THRUST)) begin
            new_thrust <= 1'b0;
        end

        if (mwchg && (ch == 9'o14) && (mwl & 16'o4)) begin
            latched_altm <= agc_altm;
            new_altm <= altm_changed;
        end else if (read_en & (addr == `NASSP_REG_ALTM)) begin
            new_altm <= 1'b0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        write_done <= 1'b0;

        ch30_en <= 1'b0;
        ch31_en <= 1'b0;
        ch32_en <= 1'b0;
        ch33_en <= 1'b0;

        ch30 <= 15'b0;
        ch31 <= 15'b0;
        ch32 <= 15'b0;
        ch33 <= 15'b0;

        periph_load <= 1'b0;
        periph_s <= 12'b0;
        periph_bb <= 15'b0;
        periph_data <= 16'b0;

        ems_write_en <= 1'b0;
        ems_addr <= 11'b0;
        ems_data <= 16'b0;
    end else begin
        write_done <= 1'b0;
        periph_load <= 1'b0;
        periph_s <= 12'b0;
        periph_bb <= 15'b0;
        periph_data <= 16'b0;

        ems_write_en <= 1'b0;
        ems_addr <= 11'b0;
        ems_data <= 16'b0;

        if (write_en) begin
            if (addr < `NASSP_REG_PIPAX) begin
                write_done <= 1'b1;
                case (addr)
                `NASSP_REG_CH30: begin
                    ch30_en <= data_in[15];
                    ch30 <= data_in[14:0];
                end

                `NASSP_REG_CH31: begin
                    ch31_en <= data_in[15];
                    ch31 <= data_in[14:0];
                end

                `NASSP_REG_CH32: begin
                    ch32_en <= data_in[15];
                    ch32 <= data_in[14:0];
                end

                `NASSP_REG_CH33: begin
                    ch33_en <= data_in[15];
                    ch33 <= data_in[14:0];
                end
                endcase
            end else begin
                if (ems_bank0_en) begin
                    write_done <= 1'b1;
                    ems_write_en <= 1'b1;
                    ems_data <= {pipa_sum, 1'b0};
                    case (addr)
                    `NASSP_REG_PIPAX: ems_addr <= `PIPAX;
                    `NASSP_REG_PIPAY: ems_addr <= `PIPAY;
                    `NASSP_REG_PIPAZ: ems_addr <= `PIPAZ;
                    default: ems_addr <= 12'o7;
                    endcase
                end else begin
                    if (periph_complete) begin
                        write_done <= 1'b1;
                    end else begin
                        periph_load <= 1'b1;
                        periph_bb <= 15'b0;
                        periph_data <= {pipa_sum[15], pipa_sum[15:1]};
                        case (addr)
                        `NASSP_REG_PIPAX: periph_s <= `PIPAX;
                        `NASSP_REG_PIPAY: periph_s <= `PIPAY;
                        `NASSP_REG_PIPAZ: periph_s <= `PIPAZ;
                        default: periph_s <= 12'o7;
                        endcase
                    end
                end
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        read_data <= 16'b0;
        read_done <= 1'b0;
    end else if (read_en) begin
        read_done <= 1'b1;
        case (addr)
        `NASSP_REG_CH30:   read_data <= {ch30_en, ch30};
        `NASSP_REG_CH31:   read_data <= {ch31_en, ch31};
        `NASSP_REG_CH32:   read_data <= {ch32_en, ch32};
        `NASSP_REG_CH33:   read_data <= {ch33_en, ch33};
        `NASSP_REG_THRUST: read_data <= {new_thrust, latched_thrust};
        `NASSP_REG_ALTM:   read_data <= {new_altm, latched_altm};
        endcase
    end else begin
        read_done <= 1'b0;
    end
end

endmodule
`default_nettype wire
