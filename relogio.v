module relogio
#(parameter HALF_MS_COUNT = 50_000_000)
(
        input clock,
        input reset,
        input soma,
        input subtracao,
        input cont,
        input start,
        

        output [7:0]an,
        output [7:0]dec_cat
 
    );
   
    reg [1:0]EA; // Estado atual
    reg [2:0]cont_a; // para saber qual parte da r_hora est? sendo ajustada
    reg [6:0] r_hora,r_min,r_sec; // 7 bits para representar do 0 ao 59
    wire soma_ed, subtracao_ed,cont_ed,luz_h,luz_m,luz_s;
    wire [7:0] an_s, dec_cat_timer;
    reg clock500ms;
    reg [31:0] count;
    wire [3:0] uni_hora, dez_hora, uni_min, dez_min, uni_seg, dez_seg;
    wire [6:0] hora, min, sec;


    // gerando um clock de 500ms
     always @(posedge clock or posedge reset)
  begin
    if (reset == 1'b1) 
    begin
      clock500ms <= 1'b0;
      count <= 32'd0;
    end
    else 
    begin
            if (count == (HALF_MS_COUNT/2)-1 || cont_ed == 1'b1) 
      begin
        clock500ms <= ~clock500ms;
        count <= 32'd0;
      end
      else 
      begin
        count <= count + 32'd1;
      end
    end
  end

  

    assign luz_h = (clock500ms == 1'b0 && EA == 2'd1) ? 1'b0 :
                    1'b1;
    assign luz_m = (clock500ms == 1'b0 && EA == 2'd2) ? 1'b0 :
                    1'b1;
    assign luz_s = (clock500ms == 1'b0 && EA == 2'd3) ? 1'b0 :
                    1'b1;
    assign dec_cat = dec_cat_timer;


    //instancia??o do timer
    timer timepp (.clock(clock), .reset(reset), .hora(r_hora), .min(r_min), .sec(r_sec), .an(an_s), .dec_cat(dec_cat_timer), .cont(cont_a), .hora_left(hora), .min_left(min), .sec_left(sec)); 
    // r_min daqui vira o do timer


    //EDGE DETECTOR INSTANCIA??O
    edge_detector menosf (.clock(clock), .reset(reset), .din(subtracao), .rising(subtracao_ed));
    edge_detector maisf (.clock(clock), .reset(reset), .din(soma), .rising(soma_ed));
    edge_detector contf (.clock(clock), .reset(reset), .din(cont), .rising(cont_ed));

    //m?quina de estados -------------------
    always@(posedge reset or posedge clock)begin  //qual o proximo estado

    // EA = 2'd0 -> IDLE
    // EA = 2'd1 -> r_hora
    // EA = 2'd2 -> r_min
    // EA = 2'd3 -> r_sec


    if(reset == 1 )begin
        EA <= 2'd0;
    end 
 
    else begin
    case(EA)
      2'd0: //
        begin
          if(cont_a == 1)begin 
            EA <= 2'd1;
          end
        end

      2'd1: // 
        begin
          if(cont_a == 2)begin 
            EA <= 2'd2; 
          end
        end
 
      2'd2: // 
        begin
          if(cont_a == 3)begin 
            EA <= 2'd3; 
          end
        end
      
      2'd3: // wire
      begin
          if(cont_a == 4)begin 
            EA <= 2'd0;
          end 
       end
          
       default: begin
            EA <= 2'd0; 
       end 
    endcase
    end
    end

always @(posedge clock or posedge reset)
begin
    if(reset == 1'b1)
    begin
        r_hora <= 7'd0;
        r_min <= 7'd0;
        r_sec <= 7'd0;
    end
    else
    begin
         if(EA == 2'd0)
         begin
             r_hora <= hora;
             r_min <= min;
             r_sec <= sec;
         end
        else
        if(EA == 2'd1)
        begin
           if(soma_ed == 1'b1)
           begin
                if(r_hora < 7'd23)
                begin
                     r_hora <= r_hora + 7'd1;
                end
                else
                begin
                     r_hora <= 7'd23;
                end
              end
              else if(subtracao_ed == 1'b1)
              begin
                if(r_hora > 7'd0)
                begin
                     r_hora <= r_hora - 7'd1;
                end
                else
                begin
                     r_hora <= 7'd0;
                end
              end
        end
        else if(EA == 2'd2)
        begin
            if(soma_ed == 1'b1)
           begin
                if(r_min < 7'd59)
                begin
                     r_min <= r_min + 7'd1;
                end
                else
                begin
                     r_min <= 7'd59;
                end
              end
              else if(subtracao_ed == 1'b1)
              begin
                if(r_min > 7'd0)
                begin
                     r_min <= r_min - 7'd1;
                end
                else
                begin
                     r_min <= 7'd0;
                end
              end
        end
        else if(EA == 2'd3)
        begin
            if(soma_ed == 1'b1)
           begin
                if(r_sec < 7'd59)
                begin
                     r_sec <= r_sec + 7'd1;
                end
                else
                begin
                     r_sec <= 7'd59;
                end
              end
              else if(subtracao_ed == 1'b1)
              begin
                if(r_sec > 7'd0)
                begin
                     r_sec <= r_sec - 7'd1;
                end
                else
                begin
                     r_sec <= 7'd0;
                end
              end
        end
    end
end

always @(posedge clock or posedge reset)
begin
    if(reset == 1'b1)
    begin
        cont_a <= 3'd0;
    end
    else
    begin
        if(cont_ed == 1'b1)
        begin
            cont_a <= cont_a + 1;
    end
        if(EA == 2'd0 && cont_a == 3'd4)
        begin
            cont_a <= 3'd0;
        end
    end
end

assign dez_hora = (r_hora/10);
assign uni_hora = (r_hora%10);
assign uni_min = (r_min%10);
assign dez_min = (r_min/10);
assign uni_seg = (r_sec%10);
assign dez_seg = (r_sec/10);

dspl_drv_NexysA7 driver (.reset(reset), .clock(clock), .d1({luz_s,uni_seg[3:0],1'b0}), .d2({luz_s,dez_seg[3:0],1'b0}), .d3({luz_m,uni_min[3:0],1'b0}), .d4({luz_m,dez_min[3:0],1'b0}), .d5({luz_h,uni_hora[3:0],1'b0}), .d6({luz_h,dez_hora[3:0],1'b0}), .d8({1'b1,2'b0, EA[1:0],1'b0}), .d7(6'd0), .an(an), .dec_cat(dec_cat));
  
  
endmodule
