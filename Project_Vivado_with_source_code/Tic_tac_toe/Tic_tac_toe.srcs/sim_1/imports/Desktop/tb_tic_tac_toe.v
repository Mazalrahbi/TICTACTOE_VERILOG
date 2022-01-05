`timescale 1ns/10ps

module tb_tic_tac_toe ();

reg clk=0         ;
reg reset         ;
reg start_game    ;

reg T1, T2, T3    ;
reg C1, C2, C3    ;
reg B1, B2, B3    ;

wire P1_turn       ;
wire P2_turn       ;

wire T1_LED_R, T1_LED_B;
wire T2_LED_R, T2_LED_B;
wire T3_LED_R, T3_LED_B;

wire C1_LED_R, C1_LED_B;
wire C2_LED_R, C2_LED_B;
wire C3_LED_R, C3_LED_B;

wire B1_LED_R, B1_LED_B;
wire B2_LED_R, B2_LED_B;
wire B3_LED_R, B3_LED_B;

wire P1_win        ;
wire P2_win        ;
wire taken_err_flag;


always #5 clk = ~clk;

tic_tac_toe i_tic_tac_toe (
  .clk           (clk           ),
  .reset         (reset         ),
  .start_game    (start_game    ),
  .T1            (T1            ),
  .T2            (T2            ),
  .T3            (T3            ),
  .C1            (C1            ),
  .C2            (C2            ),
  .C3            (C3            ),
  .B1            (B1            ),
  .B2            (B2            ),
  .B3            (B3            ),
  .P1_turn       (P1_turn       ),
  .P2_turn       (P2_turn       ),
  .T1_LED_R      (T1_LED_R      ),
  .T1_LED_B      (T1_LED_B      ),
  .T2_LED_R      (T2_LED_R      ),
  .T2_LED_B      (T2_LED_B      ),
  .T3_LED_R      (T3_LED_R      ),
  .T3_LED_B      (T3_LED_B      ),
  .C1_LED_R      (C1_LED_R      ),
  .C1_LED_B      (C1_LED_B      ),
  .C2_LED_R      (C2_LED_R      ),
  .C2_LED_B      (C2_LED_B      ),
  .C3_LED_R      (C3_LED_R      ),
  .C3_LED_B      (C3_LED_B      ),
  .B1_LED_R      (B1_LED_R      ),
  .B1_LED_B      (B1_LED_B      ),
  .B2_LED_R      (B2_LED_R      ),
  .B2_LED_B      (B2_LED_B      ),
  .B3_LED_R      (B3_LED_R      ),
  .B3_LED_B      (B3_LED_B      ),
  .P1_win        (P1_win        ),
  .P2_win        (P2_win        ),
  .taken_err_flag(taken_err_flag) 
);

initial
begin
  T1 = 0;
  T2 = 0;
  T3 = 0;
  C1 = 0;
  C2 = 0;
  C3 = 0;
  B1 = 0;
  B2 = 0;
  B3 = 0;

  // Combination - 1 (Player-1 Wins)
  reset = 1'b1;
  repeat(5) @(posedge clk);
  reset = 1'b0;

  repeat(1) @(posedge clk);
  start_game = 1'b1;
  repeat(1) @(posedge clk);
  start_game = 1'b0;

  repeat(5) @(posedge clk);

  T3 = 1'b1;
  @(posedge clk);
  T3 = 1'b0;
  repeat (5) @(posedge clk);

  B3 = 1'b1;
  @(posedge clk);
  B3 = 1'b0;
  repeat (5) @(posedge clk);

  T1 = 1'b1;
  @(posedge clk);
  T1 = 1'b0;
  repeat (5) @(posedge clk);

  T2 = 1'b1;
  @(posedge clk);
  T2 = 1'b0;
  repeat (5) @(posedge clk);

  C1 = 1'b1;
  @(posedge clk);
  C1 = 1'b0;
  repeat (5) @(posedge clk);

  C2 = 1'b1;
  @(posedge clk);
  C2 = 1'b0;
  repeat (5) @(posedge clk);

  B1 = 1'b1;
  @(posedge clk);
  B1 = 1'b0;
  repeat (5) @(posedge clk);

  // Combination - 2 (Player-2 Wins)
  repeat(1) @(posedge clk);
  start_game = 1'b1;
  repeat(1) @(posedge clk);
  start_game = 1'b0;

  repeat(5) @(posedge clk);

  B3 = 1'b1;
  @(posedge clk);
  B3 = 1'b0;
  repeat (5) @(posedge clk);

  T3 = 1'b1;
  @(posedge clk);
  T3 = 1'b0;
  repeat (5) @(posedge clk);

  C3 = 1'b1;
  @(posedge clk);
  C3 = 1'b0;
  repeat (5) @(posedge clk);

  T1 = 1'b1;
  @(posedge clk);
  T1 = 1'b0;
  repeat (5) @(posedge clk);

  C2 = 1'b1;
  @(posedge clk);
  C2 = 1'b0;
  repeat (5) @(posedge clk);

  C1 = 1'b1;
  @(posedge clk);
  C1 = 1'b0;
  repeat (5) @(posedge clk);

  B1 = 1'b1;
  @(posedge clk);
  B1 = 1'b0;
  repeat (5) @(posedge clk);

  T2 = 1'b1;
  @(posedge clk);
  T2 = 1'b0;
  repeat (5) @(posedge clk);

  // Combination - 3 (DRAW)
  repeat(1) @(posedge clk);
  start_game = 1'b1;
  repeat(1) @(posedge clk);
  start_game = 1'b0;

  repeat(5) @(posedge clk);

  B2 = 1'b1;
  @(posedge clk);
  B2 = 1'b0;
  repeat (5) @(posedge clk);

  B2 = 1'b1;
  @(posedge clk);
  B2 = 1'b0;
  repeat (5) @(posedge clk);

  T1 = 1'b1;
  @(posedge clk);
  T1 = 1'b0;
  repeat (5) @(posedge clk);

  T3 = 1'b1;
  @(posedge clk);
  T3 = 1'b0;
  repeat (5) @(posedge clk);

  B1 = 1'b1;
  @(posedge clk);
  B1 = 1'b0;
  repeat (5) @(posedge clk);
  
  C1 = 1'b1;
  @(posedge clk);
  C1 = 1'b0;
  repeat (5) @(posedge clk);
  
  C2 = 1'b1;
  @(posedge clk);
  C2 = 1'b0;
  repeat (5) @(posedge clk);
  
  B3 = 1'b1;
  @(posedge clk);
  B3 = 1'b0;
  repeat (5) @(posedge clk);

  // Combination - 4 (Player-1 wins)
  repeat(1) @(posedge clk);
  start_game = 1'b1;
  repeat(1) @(posedge clk);
  start_game = 1'b0;

  repeat(5) @(posedge clk);
  T3 = 1'b1;
  @(posedge clk);
  T3 = 1'b0;
  repeat (5) @(posedge clk);

  C2 = 1'b1;
  @(posedge clk);
  C2 = 1'b0;
  repeat (5) @(posedge clk);

  T1 = 1'b1;
  @(posedge clk);
  T1 = 1'b0;
  repeat (5) @(posedge clk);

  C3 = 1'b1;
  @(posedge clk);
  C3 = 1'b0;
  repeat (5) @(posedge clk);

  T2 = 1'b1;
  @(posedge clk);
  T2 = 1'b0;

  repeat (5) @(posedge clk);
  repeat(1) @(posedge clk);
  start_game = 1'b1;
  repeat(3) @(posedge clk);
  start_game = 1'b0;

  repeat (52) @(posedge clk);
  $stop();

end


endmodule