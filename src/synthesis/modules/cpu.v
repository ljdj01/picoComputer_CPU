module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [DATA_WIDTH - 1:0] mem_in,
    input [DATA_WIDTH - 1:0] in,
    output mem_we,
    output [ADDR_WIDTH - 1:0] mem_addr,
    output [DATA_WIDTH - 1:0] mem_data,
    output [DATA_WIDTH - 1:0] out,
    output [ADDR_WIDTH - 1:0] pc,
    output [ADDR_WIDTH - 1:0] sp
);

    reg mem_we_reg, mem_we_next;
    reg [ADDR_WIDTH - 1:0] mem_addr_reg, mem_addr_next;
    reg [DATA_WIDTH - 1:0] mem_data_reg, mem_data_next;
    reg [DATA_WIDTH - 1:0] out_reg, out_next;
    //reg [ADDR_WIDTH - 1:0] pc_reg, pc_next;
    //reg [ADDR_WIDTH - 1:0] sp_reg, sp_next;

    assign mem_we = mem_we_reg;
    assign mem_addr = mem_addr_reg;
    assign mem_data = mem_data_reg;
    assign out = out_reg;
    
    reg nula = 1'b0;
    
    reg pc_cl = 1'b0, pc_ld = 1'b0, pc_inc = 1'b0, pc_dec = 1'b0;
    reg [6 - 1:0] pc_in = 6'd0;
    wire [6 - 1:0] pc_out;
    register #(6) pc_reg (clk, rst_n, pc_cl, pc_ld, pc_in, pc_inc, pc_dec, nula, nula, nula, nula, pc_out);

    reg sp_cl = 1'b0, sp_ld = 1'b0, sp_inc = 1'b0, sp_dec = 1'b0;
    reg [6 - 1:0] sp_in = 6'd0;
    wire [6 - 1:0] sp_out;
    register #(6) sp_reg (clk, rst_n, sp_cl, sp_ld, sp_in, sp_inc, sp_dec, nula, nula, nula, nula, sp_out);

    reg ir_high_cl = 1'b0, ir_high_ld = 1'b0, ir_high_inc = 1'b0, ir_high_dec = 1'b0;
    reg [16 - 1:0] ir_high_in = 16'd0;
    wire [16 - 1:0] ir_high_out;
    register #(16) ir_high_reg (clk, rst_n, ir_high_cl, ir_high_ld, mem_in, ir_high_inc, ir_high_dec, nula, nula, nula, nula, ir_high_out);

    reg ir_low_cl, ir_low_ld = 1'b0, ir_low_inc = 1'b0, ir_low_dec = 1'b0;
    reg [16 - 1:0] ir_low_in = 16'd0;
    wire [16 - 1:0] ir_low_out;
    register #(16) ir_low_reg (clk, rst_n, ir_low_cl, ir_low_ld, mem_in, ir_low_inc, ir_low_dec, nula, nula, nula, nula, ir_low_out);

    reg acc_cl = 1'b0, acc_ld = 1'b0, acc_inc = 1'b0, acc_dec = 1'b0, acc_sr = 1'b0, acc_ir = 1'b0, acc_sl = 1'b0, acc_il = 1'b0;
    reg [16 - 1:0] acc_in = 16'd0;
    wire [16 - 1:0] acc_out;
    register #(16) acc_reg (clk, rst_n, acc_cl, acc_ld, acc_in, acc_inc, acc_dec, acc_sr, acc_ir, acc_sl, acc_il, acc_out);

    assign pc = pc_out;
    assign sp = sp_out;

    localparam START = 0;
    localparam FETCH_INSTR_1 = 1;
    localparam FETCH_INSTR_2 = 2;
    localparam FETCH_INSTR_3 = 3;
    localparam FETCH_OPER = 4;
    localparam ACCESS_MEM = 5;
    localparam FETCH_A = 6;
    localparam FETCH_B = 7;
    localparam FETCH_B_PREPARE = 8;
    localparam FETCH_C = 9;
    localparam FETCH_C_PREPARE = 10; 
    localparam ABC_READY = 11;
    localparam FETCH_OUT_DATA = 12;
    localparam ALU_DONE = 13;
    localparam STOP = 14;
    localparam STOP_A = 15;
    localparam STOP_B = 16;
    localparam STOP_C = 17;

    localparam FETCH_OUT_DATA_WAIT= 18;
    localparam FETCH_INSTR_3_WAIT = 19;
    localparam FETCH_B_PREPARE_WAIT = 20;
    localparam FETCH_INSTR_2_WAIT = 21;
    localparam FETCH_C_WAIT = 22;
    localparam FETCH_C_IND_WAIT = 23;
    localparam FETCH_OPER_WAIT = 24;
    localparam FETCH_B_WAIT = 25;

    integer state_reg, state_next;

    reg [DATA_WIDTH - 1:0] a_reg, a_next;
    reg [DATA_WIDTH - 1:0] b_reg, b_next;
    reg [DATA_WIDTH - 1:0] c_reg, c_next;

    reg [2:0] alu_oc_reg, alu_oc_next;
    wire [DATA_WIDTH - 1:0] alu_out;
    alu #(DATA_WIDTH) my_alu(alu_oc_reg, b_reg, c_reg, alu_out);

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            state_reg <= START;
            mem_we_reg <= 1'b0;
            mem_addr_reg <= {ADDR_WIDTH{1'b0}};
            mem_data_reg <= {DATA_WIDTH{1'b0}};
            out_reg <= {DATA_WIDTH{1'b0}};
            a_reg <= {DATA_WIDTH{1'b0}};
            b_reg <= {DATA_WIDTH{1'b0}};
            c_reg <= {DATA_WIDTH{1'b0}};
            alu_oc_reg <= {3{1'b0}};
        end
        else begin
            state_reg <= state_next;
            mem_we_reg <= mem_we_next;
            mem_addr_reg <= mem_addr_next;
            mem_data_reg <= mem_data_next;
            out_reg <= out_next;
            a_reg <= a_next;
            b_reg <= b_next;
            c_reg <= c_next;
            alu_oc_reg <= alu_oc_next;

            /*{pc_cl, pc_ld, pc_inc, pc_dec} = 4'b0000;
            {sp_cl, sp_ld, sp_inc, sp_dec} = 4'b0000;
            {ir_high_cl, ir_high_ld, ir_high_inc, ir_high_dec} = 4'b0000;
            {ir_low_cl, ir_low_ld, ir_low_inc, ir_low_dec} = 4'b0000;
            {acc_cl, acc_ld, acc_inc, acc_dec, acc_sr, acc_ir, acc_sl, acc_il} = 8'b00000000;*/
            //mozda i za in al videcemo
        end
    end

    always @(*) begin
        state_next = state_reg;
        mem_we_next = mem_we_reg;
        mem_addr_next = mem_addr_reg;
        mem_data_next = mem_data_reg;
        out_next = out_reg;
        a_next = a_reg;
        b_next = b_reg;
        c_next = c_reg;
        alu_oc_next = alu_oc_reg;

        pc_in = 6'd0;
        sp_in = 6'd0;
        acc_in = 16'd0;
        {pc_cl, pc_ld, pc_inc, pc_dec} = 4'b0000;
        {sp_cl, sp_ld, sp_inc, sp_dec} = 4'b0000;
        {ir_high_cl, ir_high_ld, ir_high_inc, ir_high_dec} = 4'b0000;
        {ir_low_cl, ir_low_ld, ir_low_inc, ir_low_dec} = 4'b0000;
        {acc_cl, acc_ld, acc_inc, acc_dec, acc_sr, acc_ir, acc_sl, acc_il} = 8'b00000000;

        case (state_reg)
            START: begin
                {pc_ld, sp_ld, ir_high_ld, ir_low_ld, acc_ld, ir_high_ld, ir_low_ld} = 7'b1111111; 
                pc_in = 6'd8;
                sp_in = 6'b111111;
                ir_high_in = 16'd0;
                ir_low_in = 16'd0;
                acc_in = 16'd0;

                //out_next = 5'b10101;

                state_next = FETCH_INSTR_1;
            end
            FETCH_INSTR_1: begin
                mem_we_next = 1'b0;
                mem_addr_next = pc_out;
                pc_inc = 1'b1;


                ir_high_ld = 1'b1;
                state_next = FETCH_INSTR_2_WAIT; //da li imamo podatak u sledecem taktu ili treba cekati jos jedan
            end
            FETCH_INSTR_2_WAIT: begin
                ir_high_ld = 1'b1;
                //out_next = mem_in[15:12];
                state_next = FETCH_INSTR_2;
            end
            FETCH_INSTR_2: begin
                //out_next = mem_in[15:12];
                //out_next = ir_high_out[15:12];
                ir_high_ld = 1'b1;
                if(mem_in[3:0] == 4'b1000) begin//ako je potrebno dohvati i drugu rec
                    mem_we_next = 1'b0;
                    mem_addr_next = pc_out;
                    pc_inc = 1'b1;
                    ir_low_ld = 1'b1;
                    state_next = FETCH_INSTR_3_WAIT;
                end
                else begin //ako ne onda odma dohvati regA ako je ind
                    if(mem_in[11]) begin
                        mem_addr_next = {{(ADDR_WIDTH - 3){1'b0}}, mem_in[10:8]};
                        mem_we_next = 1'b0;
                        state_next = FETCH_OPER_WAIT;
                    end
                    else begin // posto A nije ind onda mogu da dovlacim B reg
                        //out_next = 4'b1010;
                        a_next = mem_in[10:8];
                        mem_addr_next = {{(ADDR_WIDTH - 3){1'b0}}, mem_in[6:4]};
                        mem_we_next = 1'b0;
                        state_next = FETCH_B_PREPARE_WAIT;
                    end
                end
            end
            FETCH_INSTR_3_WAIT: begin
                //ir_low_ld = 1'b1;
                state_next = FETCH_INSTR_3;
            end
            FETCH_INSTR_3: begin//dohvacena je druga rec ajde dohvati i regA ako je ind
                ir_low_ld = 1'b1;
                if(ir_high_out[11]) begin
                    //out_next = ir_high_out[10:8];
                    mem_addr_next = {{(ADDR_WIDTH - 3){1'b0}}, ir_high_out[10:8]};
                    mem_we_next = 1'b0;
                end
                state_next = FETCH_OPER_WAIT;
            end
            FETCH_OPER_WAIT: begin
                //ir_high_ld = 1'b1;
                state_next = FETCH_OPER;
            end
            FETCH_OPER: begin //prv oda dohvatim operande a onda izvrsavanje
                //out_next =mem_in;
                if(ir_high_out[11]) begin
                    //out_next = mem_in;
                    a_next = mem_in;
                end
                else begin
                    a_next = ir_high_out[10:8];//da posle ne gleadm da je ind ili dir vec samo da smemstim na mem[A]
                end
               
                if(ir_high_out[3:0] != 4'b1000) begin // bice potreban i B operand
                    mem_addr_next = {{(ADDR_WIDTH - 3){1'b0}}, ir_high_out[6:4]};
                    mem_we_next = 1'b0;
                    state_next = FETCH_B_PREPARE_WAIT;
                end
                else begin //C je nepotreban, kao i B, koristi se samo vredmnost iz druge reci
                    state_next = ABC_READY;
                end
            end
            FETCH_B_PREPARE_WAIT: begin
                state_next = FETCH_B_PREPARE;
            end
            FETCH_B_PREPARE: begin
                b_next = mem_in;
                if(ir_high_out[7]) begin
                    mem_addr_next = mem_in[ADDR_WIDTH - 1:0];
                    mem_we_next = 1'b0;
                    state_next = FETCH_B_WAIT;
                end
                else begin//dohvatam C
                    //out_next = 4'b1010;
                    mem_addr_next = {{(ADDR_WIDTH - 3){1'b0}}, ir_high_out[2:0]};
                    mem_we_next = 1'b0;
                    state_next = FETCH_C_WAIT;
                end
            end
            FETCH_B_WAIT: begin
                state_next = FETCH_B;
            end
            FETCH_B: begin//fal istanje cekanja
                b_next = mem_in;
                mem_addr_next = {{(ADDR_WIDTH - 3){1'b0}}, ir_high_out[2:0]};
                mem_we_next = 1'b0;
                state_next = FETCH_C_WAIT;
            end
            FETCH_C_PREPARE: begin
                c_next = mem_in;
                if(ir_high_out[3]) begin
                    mem_addr_next = mem_in[ADDR_WIDTH - 1:0];
                    mem_we_next = 1'b0;
                    state_next = FETCH_C_IND_WAIT;
                end
                else begin
                    if(ir_high_out[15:12] == 4'b1111) begin
                        //if(ir_high_out[11]) begin
                            mem_addr_next = a_reg[ADDR_WIDTH - 1:0];//svavk omoram da dohvatim vrednost u regA
                            mem_we_next = 1'b0;
                        //end
                        state_next = STOP;
                    end
                    else begin
                        state_next = ABC_READY;
                    end
                end
            end
            FETCH_C_WAIT: begin
                state_next = FETCH_C_PREPARE;
            end
            FETCH_C_IND_WAIT: begin
                state_next = FETCH_C;
            end
            FETCH_C: begin
                c_next = mem_in;
                /*if(ir_high_out[15:12] == 4'b0010) begin
                    out_next = mem_in;
                end*/
                
                if(ir_high_out[15:12] == 4'b1111) begin
                    //if(ir_high_out[11]) begin
                        mem_addr_next = a_reg[ADDR_WIDTH - 1:0];//svavk omoram da dohvatim vrednost u regA
                        mem_we_next = 1'b0;
                    //end
                    state_next = STOP;
                end
                else begin
                    state_next = ABC_READY;
                end
            end
            ABC_READY: begin
                //out_next = ir_high_out[15:12];
                //out_next = c_reg;
                case (ir_high_out[15:12])
                    4'b0000: begin //MOVE
                        if(ir_high_out[3:0] == 4'b1000) begin
                            mem_addr_next = a_reg[ADDR_WIDTH - 1:0];
                            mem_data_next = ir_low_out;
                            mem_we_next = 1'b1;//upis
                            state_next = ACCESS_MEM;
                        end
                        if(ir_high_out[3:0] == 4'b0000) begin//mozda je nepotrebno ucitam C al nmvz
                            mem_addr_next = a_reg[ADDR_WIDTH - 1:0];
                            mem_data_next = b_reg;
                            mem_we_next = 1'b1;//upis
                            state_next = ACCESS_MEM;
                        end
                    end
                    4'b0001: begin //ADD
                        alu_oc_next = 3'b000;
                        state_next = ALU_DONE;
                    end
                    4'b0010: begin //SUB
                        alu_oc_next = 3'b001;
                        state_next = ALU_DONE;
                        //out_next = 4'b1111;
                        //out_next = c_reg;
                    end
                    4'b0011: begin //MUL
                        alu_oc_next = 3'b010;
                        state_next = ALU_DONE;

                    end
                    4'b0100: begin //DIV koji ne radi nista
                        state_next = FETCH_INSTR_1;
                    end
                    4'b0101: begin
                        state_next = FETCH_INSTR_1;
                    end
                    4'b0110: begin
                        state_next = FETCH_INSTR_1;
                    end
                    4'b0111: begin //IN
                        mem_addr_next = a_reg[ADDR_WIDTH - 1:0];
                        mem_data_next = in;
                        mem_we_next = 1'b1;//upis
                        state_next = ACCESS_MEM;
                    end
                    4'b1000: begin //OUT
                        //out_next = 4'b1010;
                        mem_addr_next = a_reg[ADDR_WIDTH - 1:0];
                        mem_we_next = 1'b0;
                        state_next = FETCH_OUT_DATA_WAIT;
                    end
                    4'b1001: begin
                        state_next = FETCH_INSTR_1;
                    end
                    4'b1010: begin
                        state_next = FETCH_INSTR_1;
                    end
                    4'b1011: begin
                        state_next = FETCH_INSTR_1;
                    end
                    4'b1100: begin
                        state_next = FETCH_INSTR_1;
                    end
                    4'b1101: begin
                        state_next = FETCH_INSTR_1;
                    end
                    4'b1110: begin
                        state_next = FETCH_INSTR_1;
                    end
                    4'b1111: begin //STOP
                        
                        state_next = STOP_C;
                    end
                endcase
            end
            FETCH_OUT_DATA_WAIT: begin
                state_next = FETCH_OUT_DATA;
            end
            FETCH_OUT_DATA: begin
                out_next = mem_in;
                state_next = ACCESS_MEM;
            end
            ALU_DONE: begin
                mem_addr_next = a_reg[ADDR_WIDTH - 1:0];
                mem_data_next = alu_out;
                mem_we_next = 1'b1;//upis
                state_next = ACCESS_MEM;
            end
            STOP: begin
                state_next = STOP_C;
            end
            STOP_A: begin
                if(ir_high_out[11:8] != 4'b0000) begin
                    out_next = a_reg;
                    //out_next = 4'b1010;
                end
                state_next = STOP_C;
            end
            STOP_B: begin
                if(ir_high_out[7:4] != 4'b0000) begin
                    out_next = b_reg;
                    //out_next = 4'b1011;
                end
                state_next = STOP_A;
            end
            STOP_C: begin
                //if(ir_high_out[11]) begin//pisem ih C B A
                    a_next = mem_in;
                //end
                if(ir_high_out[3:0] != 4'b0000) begin
                    out_next = c_reg;
                    //out_next = 4'b1100;
                end
                state_next = STOP_B;
            end
            ACCESS_MEM: begin
                mem_we_next = 1'b0;
                state_next = FETCH_INSTR_1;
            end
        endcase
    end

    
endmodule