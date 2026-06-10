module axis_hmm_classifier #
(
    parameter DATA_WIDTH = 32
)
(
    input wire clk,
    input wire rst,

    input wire s_axis_tvalid,
    output reg s_axis_tready,
    input wire [DATA_WIDTH-1:0] s_axis_tdata,

    output reg m_axis_tvalid,
    input wire m_axis_tready,
    output reg [DATA_WIDTH-1:0] m_axis_tdata
);

reg [7:0] feature_reg;

reg [15:0] likelihood_bpsk;
reg [15:0] likelihood_qpsk;
reg [15:0] likelihood_qam;
reg [15:0] likelihood_fsk;

reg [1:0] modulation_id;

reg [1:0] state;

localparam IDLE=0, COMPUTE=1, OUTPUT=2;

always @(posedge clk)
begin
    if(rst)
        s_axis_tready <= 1;
    else if(state==IDLE)
        s_axis_tready <= 1;
    else
        s_axis_tready <= 0;
end

always @(posedge clk)
begin
    if(rst)
    begin
        state <= IDLE;
        m_axis_tvalid <= 0;
        m_axis_tdata <= 0;
    end
    else
    begin
        case(state)

        IDLE:
        begin
            m_axis_tvalid <= 0;

            if(s_axis_tvalid && s_axis_tready)
            begin
                feature_reg <= s_axis_tdata[7:0];
                state <= COMPUTE;
            end
        end

        COMPUTE:
        begin
            likelihood_bpsk <= (feature_reg < 64)?200:50;
            likelihood_qpsk <= (feature_reg>=64 && feature_reg<128)?200:50;
            likelihood_qam  <= (feature_reg>=128 && feature_reg<192)?200:50;
            likelihood_fsk  <= (feature_reg>=192)?200:50;

            state <= OUTPUT;
        end

        OUTPUT:
        begin

            if(likelihood_bpsk >= likelihood_qpsk &&
               likelihood_bpsk >= likelihood_qam &&
               likelihood_bpsk >= likelihood_fsk)
                modulation_id <= 2'b00;

            else if(likelihood_qpsk >= likelihood_qam &&
                    likelihood_qpsk >= likelihood_fsk)
                modulation_id <= 2'b01;

            else if(likelihood_qam >= likelihood_fsk)
                modulation_id <= 2'b10;

            else
                modulation_id <= 2'b11;

            m_axis_tdata <= {30'b0, modulation_id};

            m_axis_tvalid <= 1;

            if(m_axis_tvalid && m_axis_tready)
            begin
                m_axis_tvalid <= 0;
                state <= IDLE;
            end
        end

        endcase
    end
end

endmodule