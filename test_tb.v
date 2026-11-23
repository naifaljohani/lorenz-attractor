module signed_mult_tb;

  // Inputs
  reg signed [26:0] a;
  reg signed [26:0] b;

  // Outputs
  wire signed [26:0] out;

  // Instantiate the signed_mult module
  signed_sub uut (
    .out(out),
    .a(a),
    .b(b)
  );

  // Test procedure
  initial begin
    // Display header
    $display("Time | a                | b                | out");
    $display("-----------------------------------------------------");

    // Test Case 1: Positive * Positive
    a = 27'sd100; b = 27'sd50;
    #10 $display("%0t | %d | %d | %d", $time, a, b, out);

    // Test Case 2: Negative * Positive
    a = -27'sd100; b = 27'sd50;
    #10 $display("%0t | %d | %d | %d", $time, a, b, out);

    // Test Case 3: Positive * Negative
    a = 27'sd100; b = -27'sd50;
    #10 $display("%0t | %d | %d | %d", $time, a, b, out);

    // Test Case 4: Negative * Negative
    a = -27'sd100; b = -27'sd50;
    #10 $display("%0t | %d | %d | %d", $time, a, b, out);

    // Test Case 5: Zero * Positive
    a = 27'sd0; b = 27'sd50;
    #10 $display("%0t | %d | %d | %d", $time, a, b, out);

    // Test Case 6: Positive * Zero
    a = 27'sd100; b = 27'sd0;
    #10 $display("%0t | %d | %d | %d", $time, a, b, out);

    // Test Case 7: Zero * Zero
    a = 27'sd0; b = 27'sd0;
    #10 $display("%0t | %d | %d | %d", $time, a, b, out);

    // Test Case 8: Large positive * Small positive
    a = 27'sd13421772; b = 27'sd2; // Near max positive value for 7.20
    #10 $display("%0t | %d | %d | %d", $time, a, b, out);

    // Test Case 9: Large negative * Small negative
    a = -27'sd13421772; b = -27'sd2; // Near max negative value for 7.20
    #10 $display("%0t | %d | %d | %d", $time, a, b, out);

    // Test Case 10: Large positive * Large negative
    a = 27'sd13421772; b = -27'sd13421772;
    #10 $display("%0t | %d | %d | %d", $time, a, b, out);

    // End simulation
    $finish;
  end

endmodule
