//////////////////////////////////////////////////
//// signed add of 7.20 format 2's complement ////
//////////////////////////////////////////////////
module signed_add (out, a, b);
    output signed [26:0] out;
    input  signed [26:0] a;
    input  signed [26:0] b;

    // Intermediate full bit length
    wire signed [27:0] add_out; // 1 extra bit for overflow

    assign add_out = a + b;

    // Select bits for 7.20 fixed-point
    assign out = {add_out[27], add_out[26:0]}; // Sign bit and fractional part
endmodule
