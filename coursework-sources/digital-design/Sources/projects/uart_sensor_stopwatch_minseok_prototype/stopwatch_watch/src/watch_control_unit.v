module watch_control_unit (
    input  clk,
    input  reset,
    input  i_h_up,
    input  i_m_up,
    input  i_s_up,
    input  opt,
    output o_run_enable,
    output o_h_up,
    output o_m_up,
    output o_s_up
);

    parameter RUN = 0, EDIT = 1, H_UP = 2, M_UP = 3, S_UP = 4;

    reg [2:0] c_state, n_state;
    reg run_stop_reg, run_stop_next;
    reg h_up_reg, h_up_next;
    reg m_up_reg, m_up_next;
    reg s_up_reg, s_up_next;

    // output CL
    assign o_run_enable = run_stop_reg;
    assign o_h_up = h_up_reg;
    assign o_m_up = m_up_reg;
    assign o_s_up = s_up_reg;

    // State Register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state      <= RUN;
            run_stop_reg <= 1'b1;  // start : RUN
            h_up_reg     <= 1'b0;
            m_up_reg     <= 1'b0;
            s_up_reg     <= 1'b0;
        end else begin
            c_state      <= n_state;
            run_stop_reg <= run_stop_next;
            h_up_reg     <= h_up_next;
            m_up_reg     <= m_up_next;
            s_up_reg     <= s_up_next;
        end
    end

    // Next CL
    always @(*) begin
        n_state       = c_state;
        run_stop_next = run_stop_reg;
        h_up_next     = h_up_reg;
        m_up_next     = m_up_reg;
        s_up_next     = s_up_reg;
        case (c_state)
            RUN: begin
                run_stop_next = 1'b1;
                if (opt) n_state = EDIT;
            end
            EDIT: begin
                run_stop_next = 1'b0;
                h_up_next = 1'b0;
                m_up_next = 1'b0;
                s_up_next = 1'b0;
                if (opt) n_state = RUN;
                else if (i_h_up) n_state = H_UP;
                else if (i_m_up) n_state = M_UP;
                else if (i_s_up) n_state = S_UP;
                else n_state = c_state;
            end
            H_UP: begin
                h_up_next = 1'b1;
                n_state   = EDIT;
            end
            M_UP: begin
                m_up_next = 1'b1;
                n_state   = EDIT;
            end
            S_UP: begin
                s_up_next = 1'b1;
                n_state   = EDIT;
            end
        endcase
    end

endmodule

