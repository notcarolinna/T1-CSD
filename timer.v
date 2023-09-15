module timer
  #(parameter HALF_MS_CONT = 50_000_000)
(
  // Declara??o das portas
  input [2:0] cont,
  input [6:0] min,
  input [6:0] sec,
  input [6:0] hora,
  input reset,
  input clock,
  output [7:0] an,  // qual display ta selecionadp
  output [7:0] dec_cat, // numero q vai ser mostrado
  output reg [6:0] hora_left, min_left, sec_left
);

    // Declara??o dos sinais
    // essas vari?veis s?o declaradas como fio pq s?o os bot?es, os valores delas n?o precisam ser guardados em nunhum lugar
    //wire [3:0] uni_hora, dez_hora, uni_min, dez_min, uni_seg, dez_seg;
    reg clk_1;
    reg [31:0] cont_50K;
    //reg [6:0] hora_left, min_left, sec_left;
     
    // Instancia??o dos edge_detectors
    // isso ta no arquivo edge_detector.v aqui ? s? chamada dele
    edge_detector startf (.clock(clock), .reset(reset), .din(start), .rising(start_ed)); // o sinal clock conectado ao pino de entrada clock que est?o instanciados no aruqivo do edge detec
   
    // Divisor de clock para gerar o ck1seg
    always @(posedge clock or posedge reset)
    begin

      if (reset == 1'b1) begin //se o reset for ativado
        clk_1   <= 1'b0;
        cont_50K <= 32'd0; // o contador reinicia
      end

      else begin
        if (cont_50K == HALF_MS_CONT-1) begin
          clk_1  <= ~clk_1; // invers?o do sinal de clock
          cont_50K <= 32'd0; // contador reiniciado
       end

      else begin
    
        cont_50K <= cont_50K + 1'b1; // o contador ? incrementado em 1 a cada ciclo de clock
        
      end

    end

end

always @(posedge clk_1 or posedge reset)
begin
  if(reset)begin
    hora_left <= 7'd0;
    min_left <= 7'd0;
    sec_left <= 7'd0;
  end
  else begin
    if(cont != 2'd0)begin
      hora_left <= hora;
      min_left <= min;
      sec_left <= sec;
    end
    else begin
      if(hora_left == 7'd23 && min_left == 7'd59 && sec_left == 7'd59)
      begin
          hora_left <= 7'd0;
          min_left <= 7'd0;
          sec_left <= 7'd0;
      end
      else if (min_left == 7'd59 && sec_left == 7'd59)
      begin
          hora_left <= hora_left + 1'b1;
          min_left <= 7'd0;
          sec_left <= 7'd0;
      end
      else if (sec_left == 7'd59)
      begin
          min_left <= min_left + 1'b1;
          sec_left <= 7'd0;
      end
      else begin
          sec_left <= sec_left + 1'b1;
      end
    end
  end
end


endmodule                                                  
