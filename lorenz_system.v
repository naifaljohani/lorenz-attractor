//////////////////////////////////////////////////
//// lorenz_system ////
//////////////////////////////////////////////////
module lorenz_system (clk,reset,x_out,y_out,z_out);
   input clk, reset;
	output signed [26:0] x_out ;
	output signed [26:0] y_out ;
	output signed [26:0] z_out ;
	
	reg signed [26:0] x; 		//the state variable x
	reg signed [26:0] y; 		//the state variable y
	reg signed [26:0] z; 		//the state variable z
	parameter signed [26:0] dt = 27'sd1044480 ;    //the dt 
	parameter signed [26:0] segma = 27'sd10485760;    //the segma 
	parameter signed [26:0] beta = 27'sd2796202;     //the beta
	parameter signed [26:0] rho = 27'sd29360128;      //the rho 	
	

	// Outputs
   wire signed [26:0] y_x , dt_dx,dt_dy,dt_dz , x_integ,y_integ,z_integ , rho_z,x_rho_z, beta_z , x_y; // temp wires 

	wire signed	[26:0] d_x, d_y , d_z ;
	
	//reg signed [26:0] x_new,y_new , z_new;


	
////////////x culculations///////////////  
signed_sub y_minus_x ( // y - x 
    .out(y_x),
    .a(y),
    .b(x)
  );


signed_mult segma_times_y_x ( // segma * (y - x )
.out(d_x) ,
.a(y_x >>> 7),
.b(segma));

	
/* signed_mult dt_times_dx ( // dt * dx
.out(dt_dx) ,
.a(dt),
.b(d_x));	 */
	
/* signed_add x_accum(  // x[i] + dt*dx
.out(x_integ),
.a(x),
.b(d_x >>> 8)); */	
	
///////////////////////////////////////////////// end x culculations

////////////y culculations///////////////  
signed_sub rho_minus_z ( // rho - z 
    .out(rho_z),
    .a(rho),
    .b(z)
  );


signed_mult x_times_rho_z ( // x * (rho- z )
.out(x_rho_z) ,
.a(rho_z),
.b(x >>> 7));

signed_sub x_times_rho_z_y ( // x * (rho- z )-y
    .out(d_y),
    .a(x_rho_z),
    .b(y >>> 7)
  );	

/* signed_mult dt_times_dy ( // dt * d_y
.out(dt_dy) ,
.a(d_y),
.b(dt)); */

	
/* signed_add y_accum(  // y[i] + dt*dy
.out(y_integ),
.a(y),
.b(d_y >>> 8));	 */
	
///////////////////////////////////////////////// end y culculations

////////////z culculations///////////////  

signed_mult beta_times_z ( //  beta * z
.out(beta_z) ,
.a(beta),
.b(z>>> 7));


signed_mult x_times_y ( // x * y
.out(x_y) ,
.a(y),
.b(x >>> 7));

signed_sub x_times_y_minus_beta_times_z( //x*y - beta*z
    .out(d_z),
    .a(x_y),
    .b(beta_z)
  );	

/* signed_mult dt_times_dz ( // dt * dz
.out(dt_dz) ,
.a(d_z),
.b(dt)); */

  
/* signed_add z_accum(  // y[i] + dt*dy
.out(z_integ),
.a(z),
.b(d_z >>> 8));	 */
	
///////////////////////////////////////////////// end z culculations

  
always @(posedge clk ) begin 

if(reset)	begin /////////Initialize registers
	
	x <= -27'sd1048576;  
    y <=  27'sd104857;  
    z <=  27'sd26214400;

 
 end // end if 
	else begin
	
     
x <= (x + (d_x )); // Update x 
//x_new <= x_integ;  // Update x_new with the same value as x
 
y <= (y + (d_y));  // Update y
//y_new <= y_integ;  // Update x_new with the same value as y
 
z <= (z + (d_z )); // Update z
//z_new <= z_integ;  // Update x_new with the same value as z


	end // end else 
	
	end ///end always
	
	
assign x_out = x ;
assign y_out = y ;  
assign z_out = z ; 

endmodule
