`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/26 22:32:30
// Design Name: 
// Module Name: Caculator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Caculator(
    input clk,//系统时钟
    output buzzer,//蜂鸣器
    output [3:0] row,//矩阵键盘行
   	input [3:0] col,//矩阵键盘列
   	output [7:0] seg,//段码
    output [5:0] DIG,//位码
    input sw1,//第一个数的个位和十位是否相等
    input sw2//第二个数的个位和十位是否相等
    );
    wire clk_1kHz;//频率为1kHz的时钟
    wire clk_50Hz;//频率为50Hz的时钟
    wire [15:0] btn;//按键
    
   //1kHz时钟分频模块
      FreDiv d1(
            .clk(clk),
            .frequency(1000),
            .clk_out(clk_1kHz)
        );
        
    //50Hz时钟分频模块
        FreDiv d2(
            .clk(clk),
            .frequency(50),
            .clk_out(clk_50Hz)
        );
        
       //判断按键是否按下的模块
      button b1(
            .clk_1kHz(clk_1kHz),
            .clk_50Hz(clk_50Hz),
            .col(col),
            .row(row),
            .btn_out(btn)
        );
        
        //计算器运算和显示模块
        cal c1(
          .clk_in(clk_1kHz),
          .DIG(DIG),
          .seg(seg),
          .btn(btn),
          .sw1(sw1),
          .sw2(sw2)
          );
          
         //蜂鸣器奏乐模块
         buzzermusic m1(
           .clk(clk),
           .btn(btn),
           .buzzer(buzzer)
         );
        
endmodule


module cal(
    input clk_in, //输入的1kHz时钟
    output reg [5:0] DIG,//位码
    output reg [7:0] seg,//段码
    input [15:0] btn,//按键
    input sw1,//开关1
    input sw2//开关2
 );
   reg [4:0] i;  //定义一个计数寄存器变量
   reg [3:0] disp_dat1=0,disp_dat2=0,disp_dat3=0,disp_dat4=0,disp_dat5=0;//前五个数码管显示值
   reg [2:0] state=0;//判断按键处于什么状态
   reg [3:0] op = 0; // 判断是哪种运算关系
   reg [3:0] key_buf=4'b0000,key_buf2=4'b0000,key2_buf=4'b0000,key2_buf2=4'b0000;//存储两个数的个位和十位
   reg eco=0;//判断“=”是否按下
   reg [2:0] dig_count;//位码计数器
   reg [20:0] result;//存储结果
   reg  result_reg1 = 0,result_reg2 = 0;//判断连加和连减过程中是否有新的按键被按下
   reg [3:0] h_bit2,h_bit,l_bit;//计算结果后三位显示值
   wire [20:0] a;
   wire [6:0] b;//参与运算的第一个数为a,第二个数为b，因为a可能大于99，故位数较大
   reg [3:0] res;//除法中的余数
   reg [3:0] ch=4'b1111;//判断第一次按键和第二次按键的情况
   reg [20:0] a_reg;
   reg [6:0] b_reg;//存储a和b
   reg flag=0;//判断是否处于连加、连减、连乘、连除
   reg minus=0;//判断是否有“-”号出现
   parameter add=4'b1010,sub=4'b1011,mult=4'b1100,div=4'b1101;//定义加减乘除
   assign a = a_reg;
   assign b = b_reg;

   
   always@(posedge clk_in)
     begin
       for(i=0;i<=15;i=i+1)
         if(btn[i]==1)
          begin
             if(i>=0 && i<=9) //如果0-9的数被按下
               begin
                if(state == 0) //如果之前没有按键被按下
                 begin
                     ch <= i; 
                     state <= 1;
                     key_buf2 <= i; 
                     disp_dat1 <= 0;
                     key_buf <= 0;
                     disp_dat2 <= i;
                     a_reg <= i;
                 end
                 
                else if((ch != i && state == 1) | (state == 1 && sw1 == 1)) //如果第一个数a是两位数
                  begin
                    state <= 2;
                    key_buf <= key_buf2;
                    key_buf2 <= i;                   
                    disp_dat1 <= disp_dat2;
                    disp_dat2 <= i; 
                    a_reg <= 10 * ch + i;
                    ch <= 4'b1111;
                  end
                 else if(state == 3 ) //如果第二个数的第一位被按下
                   begin
                     state <= 4;
                     key2_buf2 <= i; 
                     key_buf <= 0;
                     ch <= i;
                     disp_dat4 <= 0;
                     disp_dat5 <= i;
                   end
               
                 else if((state == 4 && ch != i)| (state == 4 && sw2 == 1)) //如果第二个数的第二位被按下
                   begin
                     state <= 5;
                     key2_buf <= key2_buf2;
                     key2_buf2 <= i;
                     disp_dat4 <= disp_dat5;
                     disp_dat5 <= i;
                     ch <= 4'b1111;
                   end
                 
                 end
                 
               else if(i>=10 && i<=13) //如果加减乘除键其中一个被按下
                 begin
                  if(state != 6)
                    begin
                      op <= i;
                    end
                  else if(state == 6)
                    begin
                      a_reg <= result;
                      b_reg <= 0;
                      key2_buf <= 0;
                      key2_buf2 <= 0;
                      disp_dat3 <= 0;
                      disp_dat4 <= 0;
                      flag <= 1;
                      eco <= 0;
                    end
                    state <= 3;
                 end
                
               else if(i == 14) //如果“=”被按下
                 begin
                   eco <= 1;
                   state <= 6;
                   b_reg = 10 * key2_buf + key2_buf2;
                 end
                 
               else if(i == 15) //如果清零键被按下，所有值恢复到初始状态
                 begin
                   eco = 0;
                   flag = 0;
                   state = 0;
                   a_reg = 0;
                   b_reg = 0;
                   disp_dat1 = 0;
                   disp_dat2 = 0;
                   disp_dat3 = 0;
                   disp_dat4 = 0;
                   op = 0;
                   ch = 4'b1111;
                   key_buf = 0;
                   key_buf2 = 0;
                   key2_buf = 0;
                   key2_buf2 = 0;
                 end
           end
       begin
        case(dig_count)//数码管扫描
         3'b000:
         begin
          DIG = 6'b111110;//第一个数码管亮
          if(eco == 0 && state != 0 && state != 6 && flag == 0 )//如果“=”键未按下并且不是初始状态
          begin
            case(disp_dat1)
                 4'h0:seg = 0; //8'h3f;  //显示0；
                 4'h1:seg = 8'h06;  //显示1；
                 4'h2:seg = 8'h5b;  //显示2；
                 4'h3:seg = 8'h4f;
                 4'h4:seg = 8'h66;
                 4'h5:seg = 8'h6d;
                 4'h6:seg = 8'h7d;
                 4'h7:seg = 8'h07;
                 4'h8:seg = 8'h7f;
                 4'h9:seg = 8'h6f;
                 4'ha:seg = 8'h77;
                 4'hb:seg = 8'h7c;
                 4'hc:seg = 8'h39;
                 4'hd:seg = 8'h5e;
                 4'he:seg = 8'h79;
                 4'hf:seg = 8'h71;
               endcase
             end
           else if(eco == 1 && b==0 && op == div)//如果“=”键被按下并且如果是除法情况下除数不为0
              begin
                seg = 8'b01110110;
              end
           else if(eco == 1 && op != 0)//如果除法中除数为0，显示×
             begin
               seg = 8'b01001000;
             end
           else 
               seg = 0;
              dig_count = dig_count + 1'b1;
             end
           3'b001:
             begin
               DIG = 6'b111101;//点亮第二个数码管
               if(eco == 0 && state != 0 && state != 6 && flag == 0)//如果"="键未按下并且不是初始状态
                begin
                 case(disp_dat2)
                 4'h0:seg = 8'h3f;  //显示0；
                 4'h1:seg = 8'h06;  //显示1；
                 4'h2:seg = 8'h5b;  //显示2；
                 4'h3:seg = 8'h4f;
                 4'h4:seg = 8'h66;
                 4'h5:seg = 8'h6d;
                 4'h6:seg = 8'h7d;
                 4'h7:seg = 8'h07;
                 4'h8:seg = 8'h7f;
                 4'h9:seg = 8'h6f;
                 4'ha:seg = 8'h77;
                 4'hb:seg = 8'h7c;
                 4'hc:seg = 8'h39;
                 4'hd:seg = 8'h5e;
                 4'he:seg = 8'h79;
                 4'hf:seg = 8'h71;               
               endcase
              end
            else if(eco == 1 && minus == 1 )//如果“=”键被按下并且减法中结果不为负数
               begin
                 seg = 8'b01000000;
               end
              else 
                 seg = 0;
         
              dig_count = dig_count + 1'b1;
             end
           3'b010:
             begin
               DIG = 6'b111011;//点亮第三个数码管
            if(eco == 0)//如果“=”键未被按下
             begin
              case(op)
               add:seg = 8'b01000110;
               sub:seg = 8'b01000000;
               mult:seg = 8'b01110110;
               div:seg = 8'b01001001;
               default:seg = 0;
              endcase
             end
             else if(eco == 1 && res == 0 && op != div)//如果“=”按下并且除法中是整除
               begin
                 disp_dat3 = (result / 1000) % 10;
                 case(disp_dat3)
                  4'h0:seg = 0;//8'h3f;  //显示0；
                  4'h1:seg = 8'h06;  //显示1；
                  4'h2:seg = 8'h5b;  //显示2；
                  4'h3:seg = 8'h4f;
                  4'h4:seg = 8'h66;
                  4'h5:seg = 8'h6d;
                  4'h6:seg = 8'h7d;
                  4'h7:seg = 8'h07;
                  4'h8:seg = 8'h7f;
                  4'h9:seg = 8'h6f;     
                  default:seg = 0;
                endcase            
              end
              else if(eco == 1 && res != 0 && op == div)//如果除法中出现不是整除的情况
                begin
                  disp_dat3 = (result / 10) % 10;//取出结果的十位
                  case(disp_dat3)
                  4'h0:seg = 0;//8'h3f;  //显示0；
                  4'h1:seg = 8'h06;  //显示1；
                  4'h2:seg = 8'h5b;  //显示2；
                  4'h3:seg = 8'h4f;
                  4'h4:seg = 8'h66;
                  4'h5:seg = 8'h6d;
                  4'h6:seg = 8'h7d;
                  4'h7:seg = 8'h07;
                  4'h8:seg = 8'h7f;
                  4'h9:seg = 8'h6f;     
                  default:seg = 0;
                  endcase 
                end
              else
                seg = 0;
              dig_count = dig_count + 1'b1;
             end
           3'b011:
             begin
               DIG = 6'b110111;
            if(op != 0 && eco == 0 )//如果“=”未被按下并且加减乘除其中一个键被按下
              begin
              case(disp_dat4)
                 4'h0:seg = 0;//8'h3f;  //显示0；
                 4'h1:seg = 8'h06;  //显示1；
                 4'h2:seg = 8'h5b;  //显示2；
                 4'h3:seg = 8'h4f;
                 4'h4:seg = 8'h66;
                 4'h5:seg = 8'h6d;
                 4'h6:seg = 8'h7d;
                 4'h7:seg = 8'h07;
                 4'h8:seg = 8'h7f;
                 4'h9:seg = 8'h6f;
                 4'ha:seg = 8'h77;
                 4'hb:seg = 8'h7c;
                 4'hc:seg = 8'h39;
                 4'hd:seg = 8'h5e;
                 4'he:seg = 8'h79;
                 4'hf:seg = 8'h71;       
                 default:seg = 0;        
               endcase          
              end
             else if(op != 0 && eco == 1 && res == 0)//如果“=”号被按下并且未出现除法不整除的情况
              begin
                 h_bit2 = (result / 100) % 10;
                 case(h_bit2)
                 4'h0:seg = 8'h3f;  //显示0；
                 4'h1:seg = 8'h06;  //显示1；
                 4'h2:seg = 8'h5b;  //显示2；
                 4'h3:seg = 8'h4f;
                 4'h4:seg = 8'h66;
                 4'h5:seg = 8'h6d;
                 4'h6:seg = 8'h7d;
                 4'h7:seg = 8'h07;
                 4'h8:seg = 8'h7f;
                 4'h9:seg = 8'h6f; 
                 default:seg = 0;
                 endcase
              end                  
            else if(eco == 1 && res != 0 && op == div)//如果“=”号被按下并且出现除法不整除的情况
              begin
                h_bit2 = result % 10;
                case(h_bit2)
                  4'h0:seg = 8'hbf;  //显示0.；
                  4'h1:seg = 8'h86;  //显示1.；
                  4'h2:seg = 8'hdb;  //显示2.；
                  4'h3:seg = 8'hcf;
                  4'h4:seg = 8'he6;
                  4'h5:seg = 8'hed;
                  4'h6:seg = 8'hfd;
                  4'h7:seg = 8'h87;
                  4'h8:seg = 8'hff;
                  4'h9:seg = 8'hef; 
                  default:seg = 0;               
                endcase
              end
            else
              seg = 0;
             
                dig_count = dig_count + 1'b1;
             end
           3'b100:
             begin
               DIG = 6'b101111;
                if(eco == 0 && op != 0 && (state == 4|state == 5))//如果第二个数被赋值
                  begin
                  case(disp_dat5)
                  4'h0:seg = 8'h3f;  //显示0；
                  4'h1:seg = 8'h06;  //显示1；
                  4'h2:seg = 8'h5b;  //显示2；
                  4'h3:seg = 8'h4f;
                  4'h4:seg = 8'h66;
                  4'h5:seg = 8'h6d;
                  4'h6:seg = 8'h7d;
                  4'h7:seg = 8'h07;
                  4'h8:seg = 8'h7f;
                  4'h9:seg = 8'h6f;
                  4'ha:seg = 8'h77;
                  4'hb:seg = 8'h7c;
                  4'hc:seg = 8'h39;
                  4'hd:seg = 8'h5e;
                  4'he:seg = 8'h79;
                  4'hf:seg = 8'h71;               
                endcase
                end
             else if(eco == 1 && op != 0  && res == 0)//如果“=“号被按下并且不出现除法不整除的情况
               begin
                 h_bit = (result / 10) % 10;//取出结果的第二位
                case(h_bit)
                 4'h0:seg = 8'h3f;  //显示0；
                 4'h1:seg = 8'h06;  //显示1；
                 4'h2:seg = 8'h5b;  //显示2；
                 4'h3:seg = 8'h4f;
                 4'h4:seg = 8'h66;
                 4'h5:seg = 8'h6d;
                 4'h6:seg = 8'h7d;
                 4'h7:seg = 8'h07;
                 4'h8:seg = 8'h7f;
                 4'h9:seg = 8'h6f;     
                 default:seg = 0;           
                 endcase
               end
             else if(eco == 1 && op==div && res != 0)//如果出现除法不整除的情况
              begin
                  h_bit = res * 10 / b;
                 case(h_bit)
                   4'h0:seg = 8'h3f;  //显示0；
                   4'h1:seg = 8'h06;  //显示1；
                   4'h2:seg = 8'h5b;  //显示2；
                   4'h3:seg = 8'h4f;
                   4'h4:seg = 8'h66;
                   4'h5:seg = 8'h6d;
                   4'h6:seg = 8'h7d;
                   4'h7:seg = 8'h07;
                   4'h8:seg = 8'h7f;
                   4'h9:seg = 8'h6f; 
                   default:seg = 0;               
                 endcase               
              end
             else
               seg = 0;
       
            dig_count = dig_count + 1'b1;
          end
             3'b101:
               begin
                 DIG = 6'b011111;//点亮最后一个数码管
                if(eco == 1  && res == 0)//如果“=”被按下并且不出现不整除的情况
                  begin
                  l_bit = result % 10;
                 case(l_bit)
                  4'h0:seg = 8'h3f;  //显示0；
                  4'h1:seg = 8'h06;  //显示1；
                  4'h2:seg = 8'h5b;  //显示2；
                  4'h3:seg = 8'h4f;
                  4'h4:seg = 8'h66;
                  4'h5:seg = 8'h6d;
                  4'h6:seg = 8'h7d;
                  4'h7:seg = 8'h07;
                  4'h8:seg = 8'h7f;
                  4'h9:seg = 8'h6f;                  
                  endcase                   
                 end
               else if(eco == 1  && res != 0 && op == div)//如果”=“被按下并且除法不整除
                begin
                 l_bit = ((res * 10) % b) * 10 / b;
                case(l_bit)
                  4'h0:seg = 8'h3f;  //显示0；
                  4'h1:seg = 8'h06;  //显示1；
                  4'h2:seg = 8'h5b;  //显示2；
                  4'h3:seg = 8'h4f;
                  4'h4:seg = 8'h66;
                  4'h5:seg = 8'h6d;
                  4'h6:seg = 8'h7d;
                  4'h7:seg = 8'h07;
                  4'h8:seg = 8'h7f;
                  4'h9:seg = 8'h6f; 
                  default:seg = 0;               
                 endcase                   
                end
               else
                 seg = 0;
       
                 dig_count = dig_count + 1'b1;
               end
              default:begin dig_count = dig_count + 1'b1; seg = 0; end
           endcase
       end
     end
          always@(negedge clk_in)
            begin  
             if(state != 0 && state != 3)
             begin
              if(eco == 1)
                begin
               case(op)//运算模块
                add:
                  if(flag == 0)//如果是第一次按“=”
                   begin
                     result = a + b;
                     minus = 0;
                   end
                  else if(flag == 1)//如果是处于连续运算
                   begin
                      if(minus == 0 && result_reg1 != 1)//如果不为负
                        begin result = a + b; minus = 0;end
                      else if(minus == 1)
                        begin
                          if(b >= a)
                            begin
                              result = b - a;
                              minus = 0;
                              result_reg1 = 1;
                            end
                         else if(b < a)
                          begin
                             result = a - b;
                             minus = 1;
                          end
                       end
                    end
                sub:
                  if(flag == 0)
                   begin
                     if(a >= b)
                       begin
                         result = a - b;
                         minus = 0;
                       end
                     else if(a < b)
                        begin
                          result = b - a;
                          minus = 1;
                        end  
                   end
                else  if(flag == 1)
                 begin
                    begin 
                     if(minus == 0)
                     begin
                        if(a >= b)
                           begin
                                result = a - b;
                                minus = 0;
                           end
                        else if(a < b)
                           begin
                               result = b - a;
                               minus = 1;
                               result_reg2 = 1;
                            end
                   end
                      else if(minus == 1 && result_reg2 != 1)
                        begin
                          result = b + a;
                          minus = 1;
                        end
                   end
                end
                    mult:
                        begin
                          if(minus == 0)
                             minus <= 0;
                          else if(minus == 1)
                              minus <= 1;
                          result <= a * b;
                         end
                    div:
                     begin
                       if(minus == 0)
                        minus <= 0;
                       else 
                        minus <= 1;
                        result <= a / b;
                        res <= a % b;
                      end
             endcase
         end
        else if(eco == 0)
          begin
            result <= 0;
            res <= 0;
          end
        end
        else if(state == 0 & state != 3)
          begin
            minus <= 0;//符号位清零
          end
        else if(state == 3)
         begin
            result_reg1 <= 0;
            result_reg2 <= 0;
         end
    end
       
endmodule

module FreDiv(
	input clk,	
	input [31:0] frequency,
	output reg clk_out
    );
	//分频模块
	integer count_max;
	integer count;
	
	initial
		begin
			count_max=0;
			count=0;
		end
	
	always @ (posedge clk)
	begin
		count_max = 25'b1011111010111100001000000 / frequency;
		if(count >= count_max)
		begin
			count = 0;
			clk_out = ~clk_out;
		end
		else	
		  count = count+1'b1;
	end
endmodule

module button(
	input clk_1kHz,
	input clk_50Hz,	
	input [3:0] col,	
	output reg [3:0] row,	
	output [15:0] btn_out
    );
	//判断按键是否被按下的模块
	reg [15:0] btn=0;
	reg [15:0] btn0=0;
	reg [15:0] btn1=0;
	reg [15:0] btn2=0;
	
	initial row=4'b0001;
	
	always @ (posedge clk_1kHz)
	begin
		if(row==4'b1000)	
		   row=4'b0001;
		else	
		  row = row << 1;
	end
	
	always @ (negedge clk_1kHz)
	begin
		case(row)
			4'b0001:	btn[3:0] = col;
			4'b0010:	btn[7:4] = col;
			4'b0100:	btn[11:8] = col;
			4'b1000:	btn[15:12] = col;
			default:	btn = 0;
		endcase
	end
	
	always @ (posedge clk_50Hz)
	begin
		btn0 <= btn;
		btn1 <= btn0;
		btn2 <= btn1;
	end
	
	assign btn_out=(btn2&btn1&btn0)|(~btn2&btn1&btn0);

endmodule

module buzzermusic(
    input clk,	
    input [15:0] btn,
    output buzzer
    );
    //蜂鸣器奏乐模块
        integer i;
        reg [5:0] multiplier;
        integer mus_fre;
        reg [18:0] music;
        reg [4:0] mid;
        
        initial 
            begin
               multiplier=5'b00100;
               mus_fre=50000;
              music=19'd50000;
            end
               
      always @ (btn)
        begin    
          mid=5'b10001;
          multiplier=5'b00100;
            
            for(i=0;i<=15;i=i+1)
            begin:one
              if(btn[i]==1)
                begin         
                    mid=i;  
                end
            end
            
             case(mid)
                5'b00000:    mus_fre=19'd214519;    
                5'b00001:    mus_fre=19'd202478;
                5'b00010:    mus_fre=19'd191100;
                5'b00011:    mus_fre=19'd179979;
                5'b00100:    mus_fre=19'd170265;
                5'b00101:    mus_fre=19'd160705;
                5'b00110:    mus_fre=19'd151685;          
                5'b00111:    mus_fre=19'd143172;
                5'b01000:    mus_fre=19'd135139;
                5'b01001:    mus_fre=19'd127551;
                5'b01010:    mus_fre=19'd120395;
                5'b01011:    mus_fre=19'd113636;
                5'b01100:    mus_fre=19'd107259;
                5'b01101:    mus_fre=19'd101239;
                5'b01110:    mus_fre=19'd95555;
                5'b01111:    mus_fre=19'd89990;
                default:     mus_fre=19'd0;
            endcase
            music = mus_fre / multiplier;
        end
        
        //根据哪个按键确定奏乐的频率
            Buzzercontrol bc(
           .clk(clk),
           .buzzer_count(music),
           .buzzer(buzzer)

    );
endmodule


module Buzzercontrol(
  input clk,  
  input [18:0] buzzer_count,  
  output reg buzzer
    );
    
    reg [18:0] count;
    reg [18:0] buzzer_count_half;

    
    always @ (posedge clk)
    begin
        buzzer_count_half = buzzer_count / 2;
        if(buzzer_count==0)
        	buzzer = 0;
            else   
             begin
                count=count+1'b1;
                if(count>=buzzer_count)     
                  count=0;
                else  if(count<=buzzer_count_half)   
                 buzzer=1;
                else   
                 buzzer=0;
            end

     end
endmodule
