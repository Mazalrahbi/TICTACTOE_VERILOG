module tic_tac_toe (
  // Input Clock and reset
  input  clk           ,
  input  reset         ,

  // Input to reset the gaming sequence
  input  start_game    ,

  // One-cycle signals respresenting the button press
  input  T1, T2, T3    ,
  input  C1, C2, C3    ,
  input  B1, B2, B3    ,

  // Latched signal representing the which player's turn it is
  output P1_turn       ,
  output P2_turn       ,

  // Output lines to the LED Matrix
  output reg T1_LED_R, T1_LED_B,
  output reg T2_LED_R, T2_LED_B,
  output reg T3_LED_R, T3_LED_B,
  output reg C1_LED_R, C1_LED_B,
  output reg C2_LED_R, C2_LED_B,
  output reg C3_LED_R, C3_LED_B,
  output reg B1_LED_R, B1_LED_B,
  output reg B2_LED_R, B2_LED_B,
  output reg B3_LED_R, B3_LED_B,

  // Output latched signal to declare winner
  output reg P1_win        ,
  output reg P2_win        ,

  // Output Error flag if a button for a occupied LED is pressed
  output reg taken_err_flag

);

// States
localparam IDLE         = 6'b000001; // Wait for start_game to start accepting player inputs
localparam PLAYER_TURN  = 6'b000010; // Waiting for player input and validating input
localparam ASSERT_LED   = 6'b000100; // Logic to assert the relevant LED in the matrix
localparam ASSERT_ERR   = 6'b001000; // Asserting Error when the validation in PLAYER_TURN has failed
localparam CHECK_WINNER = 6'b010000; // Logic to check if the latest turn has determined the winner
localparam DEC_WINNER   = 6'b100000; // Assert the winner signal

// LED matrix in Hardware:
// [T1] [T2] [T3]
// [C1] [C2] [C3]
// [B1] [B2] [B3]

// LED matrix for each player:
// [0] [1] [2]
// [3] [4] [5]
// [6] [7] [8]

wire  [8:0] p1_led_matrix;
wire  [8:0] p2_led_matrix;

wire [8:0] taken_led_matrix;
reg        curr_turn_comb;
reg        curr_turn;
reg  [5:0] state_next;
reg  [5:0] state_reg;
reg        clear_err;
reg        clear_leds;

reg        P1_win_comb;
reg        P2_win_comb;
wire       winner_detected;

wire [8:0] input_matrix;
reg [8:0] input_matrix_latched_comb;
reg [8:0] input_matrix_latched;

reg T1_LED_R_comb;
reg T2_LED_R_comb;
reg T3_LED_R_comb;
reg C1_LED_R_comb;
reg C2_LED_R_comb;
reg C3_LED_R_comb;
reg B1_LED_R_comb;
reg B2_LED_R_comb;
reg B3_LED_R_comb;
reg T1_LED_B_comb;
reg T2_LED_B_comb;
reg T3_LED_B_comb;
reg C1_LED_B_comb;
reg C2_LED_B_comb;
reg C3_LED_B_comb;
reg B1_LED_B_comb;
reg B2_LED_B_comb;
reg B3_LED_B_comb;

// Aligning the input button signals in an organized bus, where:
// LED Matrix:
// Top    Row : input_matrix[0]  input_matrix[1]  input_matrix[2]
// Center Row : input_matrix[3]  input_matrix[4]  input_matrix[5]
// Bottom Row : input_matrix[6]  input_matrix[7]  input_matrix[8]
assign input_matrix = {B3,B2,B1,C3,C2,C1,T3,T2,T1};

// curr_turn indicates which player has the turn
// When curr_turn is 0 then it is the Player 1's turn
// When curr_turn is 1 then it is the Player 2's turn
assign P1_turn = (curr_turn == 1'b0);
assign P2_turn = (curr_turn == 1'b1);

// Checking if Player 1 has won
always @(posedge clk)
  if (start_game)
    P1_win <= 1'b0;
  else if ( (state_reg == DEC_WINNER) && P1_win_comb)
    P1_win <= P1_win_comb;

// Checking if Player 2 has won
always @(posedge clk)
  if (start_game)
    P2_win <= 1'b0;
  else if ( (state_reg == DEC_WINNER) && P2_win_comb)
    P2_win <= P2_win_comb;

// Registering the state_variable
always @(posedge clk)
  if(reset)
    state_reg <= IDLE;
  else
    state_reg <= state_next;

always @(posedge clk)
begin
  curr_turn <= curr_turn_comb;
  input_matrix_latched <= input_matrix_latched_comb;
end

always @(*)
begin
  state_next     = state_reg;
  curr_turn_comb = curr_turn;
  clear_err      = 1'b0;
  clear_leds     = 1'b0;
  case (state_reg)

    // The state machine rests in IDLE state until the input start_game is received.
    // When the input is received, the curr_turn is set to 0 for the Player 1, the LEDsare cleared,
    // and the next state is changed for the logic to receive input from the buttons
    IDLE         :
                  begin
                    if (start_game)
                    begin
                      clear_err      = 1'b1;
                      clear_leds     = 1'b1;
                      curr_turn_comb = 1'b0;
                      state_next     = PLAYER_TURN;
                    end
                  end

    // In PLAYER_TURN, the input from the buttons is checked against the already taken
    // LEDs to ensure that an unclaimed LED is choosen, if passed, then the input is latched
    // and the state machine moves to ASSERT_LED, if failed it moves to ASSERT_ERR
    // If instead of pressing the matrix button, the user/s press the start_game button then
    // LEDs are reset and wait for the first input for a new game
    PLAYER_TURN  :
                  begin
                    if (|input_matrix)
                    begin
                      if (|(input_matrix & taken_led_matrix) == 1'b0)
                      begin
                        clear_err                 = 1'b1;
                        input_matrix_latched_comb = input_matrix;
                        state_next                = ASSERT_LED;
                      end
                      else
                      begin
                        state_next = ASSERT_ERR;
                      end
                    end
                    else if (start_game)
                    begin
                      clear_leds = 1'b1;
                      curr_turn_comb = 1'b0;
                      state_next = PLAYER_TURN;
                    end
                    else
                      state_next = PLAYER_TURN;
                  end

    // In ASSERT_LED, the relevant LED signal are asserted
    ASSERT_LED   :
                  begin
                    curr_turn_comb = ~curr_turn;
                    state_next     = CHECK_WINNER;
                  end

    // In ASSERT_ERR, the error signal is asserted 
    ASSERT_ERR   : state_next = PLAYER_TURN;

    // In CHECK_WINNER, the combination of occupied LEDs is checked to see if the latest
    // turn is helped determined the winner. If there is a winner, the next state is DEC_WINNER,
    // otherwise, the state machine goes back to expecting more input from the user/s
    CHECK_WINNER :
                  begin
                    if (winner_detected)
                      state_next = DEC_WINNER;
                    else
                      state_next = PLAYER_TURN;
                  end

    // In DEC_WINNER, the winner signal for the player is asserted and then the state machine
    // moves back to the IDLE state.
    DEC_WINNER : state_next = IDLE;

    default : state_next = IDLE;
  endcase
end

// Output signal to alert the user that the last input was illegal
always @(posedge clk)
  if (start_game)
    taken_err_flag <= 1'b0;
  else if (state_reg == ASSERT_ERR)
    taken_err_flag <= 1'b1;
  else if (clear_err)
    taken_err_flag <= 1'b0;

// The latched input matrix signal is used to assert the relevant LED
always @(*)
begin
  T1_LED_R_comb = 1'b0;
  T2_LED_R_comb = 1'b0;
  T3_LED_R_comb = 1'b0;
  C1_LED_R_comb = 1'b0;
  C2_LED_R_comb = 1'b0;
  C3_LED_R_comb = 1'b0;
  B1_LED_R_comb = 1'b0;
  B2_LED_R_comb = 1'b0;
  B3_LED_R_comb = 1'b0;

  T1_LED_B_comb = 1'b0;
  T2_LED_B_comb = 1'b0;
  T3_LED_B_comb = 1'b0;
  C1_LED_B_comb = 1'b0;
  C2_LED_B_comb = 1'b0;
  C3_LED_B_comb = 1'b0;
  B1_LED_B_comb = 1'b0;
  B2_LED_B_comb = 1'b0;
  B3_LED_B_comb = 1'b0;

  if (state_reg == ASSERT_LED)
    case (input_matrix_latched)
      9'b000_000_001 : if (~curr_turn) T1_LED_R_comb = 1'b1; else T1_LED_B_comb = 1'b1;
      9'b000_000_010 : if (~curr_turn) T2_LED_R_comb = 1'b1; else T2_LED_B_comb = 1'b1;
      9'b000_000_100 : if (~curr_turn) T3_LED_R_comb = 1'b1; else T3_LED_B_comb = 1'b1;
      9'b000_001_000 : if (~curr_turn) C1_LED_R_comb = 1'b1; else C1_LED_B_comb = 1'b1;
      9'b000_010_000 : if (~curr_turn) C2_LED_R_comb = 1'b1; else C2_LED_B_comb = 1'b1;
      9'b000_100_000 : if (~curr_turn) C3_LED_R_comb = 1'b1; else C3_LED_B_comb = 1'b1;
      9'b001_000_000 : if (~curr_turn) B1_LED_R_comb = 1'b1; else B1_LED_B_comb = 1'b1;
      9'b010_000_000 : if (~curr_turn) B2_LED_R_comb = 1'b1; else B2_LED_B_comb = 1'b1;
      9'b100_000_000 : if (~curr_turn) B3_LED_R_comb = 1'b1; else B3_LED_B_comb = 1'b1;
    endcase
end

// Arranging both the players' occupied LEDs to maintain a context to declare a winner
assign p1_led_matrix    = {B3_LED_R,B2_LED_R,B1_LED_R,C3_LED_R,C2_LED_R,C1_LED_R,T3_LED_R,T2_LED_R,T1_LED_R};
assign p2_led_matrix    = {B3_LED_B,B2_LED_B,B1_LED_B,C3_LED_B,C2_LED_B,C1_LED_B,T3_LED_B,T2_LED_B,T1_LED_B};

// Sum of all the occupied LEDs to validate incoming button signal
assign taken_led_matrix = p1_led_matrix | p2_led_matrix;

// Output LED Assignment by latching the combinational signal generated above
always @(posedge clk) if (clear_leds) T1_LED_R <= 1'b0; else if (T1_LED_R_comb) T1_LED_R <= 1'b1;

always @(posedge clk) if (clear_leds) T2_LED_R <= 1'b0; else if (T2_LED_R_comb) T2_LED_R <= 1'b1;

always @(posedge clk) if (clear_leds) T3_LED_R <= 1'b0; else if (T3_LED_R_comb) T3_LED_R <= 1'b1;

always @(posedge clk) if (clear_leds) C1_LED_R <= 1'b0; else if (C1_LED_R_comb) C1_LED_R <= 1'b1;

always @(posedge clk) if (clear_leds) C2_LED_R <= 1'b0; else if (C2_LED_R_comb) C2_LED_R <= 1'b1;

always @(posedge clk) if (clear_leds) C3_LED_R <= 1'b0; else if (C3_LED_R_comb) C3_LED_R <= 1'b1;

always @(posedge clk) if (clear_leds) B1_LED_R <= 1'b0; else if (B1_LED_R_comb) B1_LED_R <= 1'b1;

always @(posedge clk) if (clear_leds) B2_LED_R <= 1'b0; else if (B2_LED_R_comb) B2_LED_R <= 1'b1;

always @(posedge clk) if (clear_leds) B3_LED_R <= 1'b0; else if (B3_LED_R_comb) B3_LED_R <= 1'b1;

always @(posedge clk) if (clear_leds) T1_LED_B <= 1'b0; else if (T1_LED_B_comb) T1_LED_B <= 1'b1;

always @(posedge clk) if (clear_leds) T2_LED_B <= 1'b0; else if (T2_LED_B_comb) T2_LED_B <= 1'b1;

always @(posedge clk) if (clear_leds) T3_LED_B <= 1'b0; else if (T3_LED_B_comb) T3_LED_B <= 1'b1;

always @(posedge clk) if (clear_leds) C1_LED_B <= 1'b0; else if (C1_LED_B_comb) C1_LED_B <= 1'b1;

always @(posedge clk) if (clear_leds) C2_LED_B <= 1'b0; else if (C2_LED_B_comb) C2_LED_B <= 1'b1;

always @(posedge clk) if (clear_leds) C3_LED_B <= 1'b0; else if (C3_LED_B_comb) C3_LED_B <= 1'b1;

always @(posedge clk) if (clear_leds) B1_LED_B <= 1'b0; else if (B1_LED_B_comb) B1_LED_B <= 1'b1;

always @(posedge clk) if (clear_leds) B2_LED_B <= 1'b0; else if (B2_LED_B_comb) B2_LED_B <= 1'b1;

always @(posedge clk) if (clear_leds) B3_LED_B <= 1'b0; else if (B3_LED_B_comb) B3_LED_B <= 1'b1;

// combinational logic to declare the winner by mapping out winning combinations
always @(*)
begin
  casez (p1_led_matrix)
    9'b???_???_111 : P1_win_comb = 1'b1; // Top Horizontal Row
    9'b???_111_??? : P1_win_comb = 1'b1; // Center Horizontal Row
    9'b111_???_1?? : P1_win_comb = 1'b1; // Bottom Horizontal Row
    9'b??1_??1_??1 : P1_win_comb = 1'b1; // Left Vertical Row
    9'b?1?_?1?_?1? : P1_win_comb = 1'b1; // Center Vertical Row
    9'b1??_1??_1?? : P1_win_comb = 1'b1; // Right Vertical Row
    9'b1??_?1?_??1 : P1_win_comb = 1'b1; // Diagonal Combination 1
    9'b??1_?1?_1?? : P1_win_comb = 1'b1; // Diagonal Combination 2
    default        : P1_win_comb = 1'b0;
   endcase 
end

always @(*)
begin
  casez (p2_led_matrix)
    9'b???_???_111 : P2_win_comb = 1'b1; // Top Horizontal Row
    9'b???_111_??? : P2_win_comb = 1'b1; // Center Horizontal Row
    9'b111_???_1?? : P2_win_comb = 1'b1; // Bottom Horizontal Row
    9'b??1_??1_??1 : P2_win_comb = 1'b1; // Left Vertical Row
    9'b?1?_?1?_?1? : P2_win_comb = 1'b1; // Center Vertical Row
    9'b1??_1??_1?? : P2_win_comb = 1'b1; // Right Vertical Row
    9'b1??_?1?_??1 : P2_win_comb = 1'b1; // Diagonal Combination 1
    9'b??1_?1?_1?? : P2_win_comb = 1'b1; // Diagonal Combination 2
    default        : P2_win_comb = 1'b0;
   endcase 
end

// Trigger to declare a winner
assign winner_detected = P1_win_comb | P2_win_comb;

endmodule