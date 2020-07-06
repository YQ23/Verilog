`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/17 08:48:48
// Design Name: 
// Module Name: gametimer// Project Name: 
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


module gametimer(
  input clk,//系统时钟
  input clr,//清零端
  input state1,//状态1(10s倒计时)
  input state2,//状态2(30s倒计时)
  input [3:0] col,//列
  output [3:0] row,//行
  output [7:0] seg,//段码
  output [5:0] dig,//位码
  output led1,//a按下计时键的标志
  output led2,//b按下计时键的标志
  output leda,//a倒计时5s以内led灯闪烁
  output ledb,//b倒计时5s以内led灯闪烁
  output sa,//a按下暂停键
  output sb,//b按下暂停键
  output buzz//蜂鸣器
    );
    wire clk_1k;//1kHz时钟信号
    wire clk_10Hz;
    wire clk_50Hz;
    wire clk_1Hz;
    wire [15:0] btn_out;//矩阵的16个按键
    wire ea;//a认输标志
    wire eb;//b认输标志
    wire [9:0] Q1;//a输出值
    wire [9:0] Q2;//b输出值
    wire[5:0] d1; wire[5:0] d2; wire[5:0] d3;
    wire[5:0] d4; wire[5:0] d5;wire[5:0] d6;//六个数码管对应的值

   //分频,得到频率为1kHz,10Hz,50Hz,1Hz的信号
    FreDiv f1( .clk(clk), .frequency(1000),.clk_out(clk_1k));
    FreDiv f2( .clk(clk),.frequency(10),.clk_out(clk_10Hz));
    FreDiv f3( .clk(clk), .frequency(50),.clk_out(clk_50Hz));
    FreDiv f4( .clk(clk), .frequency(1), .clk_out(clk_1Hz));
    
    //按键模块,判断哪个键被按下
    ButtonInput  button( .clk_scan(clk_1k), .clk_judge(clk_50Hz), 
.col(col),.row(row), .btn_out(btn_out),.clr(clr));
    
    //按键状态显示模块,将按键信息反映到LED灯上
    ledab l1( .btn(btn_out), .leda(leda), .ledb(ledb),.clr(clr),
.clk_1k(clk_1k),.sa(sa),.sb(sb),.ea(ea),.eb(eb));     
    //计数器模块               
    counter_d cc(.clr(clr),.state1(state1),.state2(state2),.clk_10Hz(clk_10Hz),
    .leda(leda),.ledb(ledb),.Q1(Q1),.Q2(Q2),.sa(sa),.sb(sb),.ea(ea),.eb(eb));
    //输出值转换为六个数码管的状态
    disp dh(clk_1k,clr,Q1,Q2,d1,d2,d3,d4,d5,d6);
    
    //根据六个数码管状态显示相应信息
    dynamic_led6 dl(
    .disp_data_right0(d1), .disp_data_right1(d2), .disp_data_right2(d3),
    .disp_data_right3(d4), .disp_data_right4(d5), .disp_data_right5(d6),
    .clk(clk), .seg(seg), .dig(dig) );
    
     //LED灯闪烁模块
     ledss s1(.led(led1),.clk_1k(clk_1k),.clk_1Hz(clk_1Hz),.Q(Q1));
     ledss s2(.led(led2),.clk_1k(clk_1k),.clk_1Hz(clk_1Hz),.Q(Q2));
     
     //蜂鸣器发声模块
     buzzmusic bu(.Q1(Q1),.Q2(Q2),.buzz(buzz),.clk(clk),.clk_1Hz(clk_1Hz));
endmodule

module FreDiv( input clk, input [31:0] frequency, output reg clk_out);//分频
 
        integer count_max;
        integer count;
        integer cnt = 25000000;
		
        initial
            begin
                count_max=0;
                count=0;
            end
        
        always @ (posedge clk)
           begin
             count_max=cnt/frequency;
             if(count>=count_max)//计数到规定值就归零，时钟反向
              begin
                  count=0;
                  clk_out=~clk_out;
              end
             else 
                count=count+1'b1;
           end
endmodule
module ButtonInput(
        input clk_scan,
        input clk_judge,    
        input [3:0] col,    
        output reg [3:0] row,    
        output [15:0] btn_out,
        input clr
        );
        
        reg [15:0] btn=0;
        reg [15:0] btn0=0;
        reg [15:0] btn1=0;
        reg [15:0] btn2=0;
      
        initial row=4'b0001;
        //通过对行的输出值设定，依次选中各行
        always @ (posedge clk_scan)
        begin
            if(row==4'b1000)    row=4'b0001;
            else    row=row<<1;//向左移一位，0001-0010-0100-1000-0001...
        end
        
        always @ (negedge clk_scan)
        begin
            case(row)
                4'b0001:    btn[3:0]=col;//列输入值存至4位寄存器
                4'b0010:    btn[7:4]=col;
                4'b0100:    btn[11:8]=col;
                4'b1000:    btn[15:12]=col;
                default:    btn=0;
            endcase
        end
        
        always @ (posedge clk_judge)
          begin
            btn0<=btn;
            btn1<=btn0;
            btn2<=btn1;
          end
 
        assign btn_out=(btn2&btn1&btn0)|(~btn2&btn1&btn0);//按键消抖
    
endmodule
    
module ledab( btn, leda, ledb,clr,clk_1k,sa,sb,ea,eb);
input [15:0] btn;output reg leda;output reg ledb;
input clr;
input clk_1k;
output reg sa;output reg sb;
output reg ea;output reg eb;
always@(posedge clk_1k)
 begin
   if(btn[15]==1&&btn[14]==0&&clr==0)//如果a按下计时键
     begin
       leda = 1;
       ledb = 0;
       sa = 0;
       sb = 0;
       ea = 0;
       eb = 0;
     end
   else if(btn[14]==1&&btn[15]==0&&clr==0)//如果b按下计时键
     begin
       leda = 0;
       ledb = 1;
       sa = 0;
       sb = 0;
       ea = 0;
       eb = 0;
     end
    else if(btn[11]==1&&btn[10]==0&&clr==0)//如果a按下暂停键
    begin
      sa = 1;
    end
    else if(btn[10]==1&&btn[11]==0&&clr==0)//如果b按下暂停键
     begin
      sb = 1;
     end
    else if(btn[7]==1&&btn[6]==0&&clr==0)//如果a按下认输键
      begin
       ea = 1;
       eb = 0;
      end
    else if(btn[6]==1&&btn[7]==0&&clr==0)//如果b按下认输键
      begin
         eb = 1;
         ea = 0;
      end
   else if(clr==1)//如果清零端有效
      begin
       leda = 0;
       ledb = 0;
       sa = 0;
       sb = 0;
       ea = 0;
       eb = 0;
      end
 end
endmodule

module counter_d(clr,state1,state2,clk_10Hz,leda,ledb,Q1,Q2,sa,sb,ea,eb);
  input clr;
  input state1;//状态1(10s倒计时)
  input state2;//状态2(30s倒计时)
  input clk_10Hz;//10Hz时钟信号
  input leda;//a倒计时5s以内的LED灯
  input ledb;//b倒计时5s以内的LED灯
  input sa;//a是否按下暂停键
  input sb;//b是否按下暂停键
  input ea;//a是否认输
  input eb;//b是否认输

  reg [9:0] counter1;
  reg [9:0] counter2;
  output [9:0] Q1;
  output [9:0] Q2;
  
 
  always@(posedge clk_10Hz)
  begin
       //如果清零端有效且设置状态1则两个计数器均归为100(0.1s为计数周期)
      if((clr==1)&&(leda==0)&&(ledb==0)&&(state1==1)&&(state2==0)) 
        begin
           counter1 = 100;
           counter2 = 100;
        end
       //如果清零端有效且设置状态2则两个计数器均归为100(0.1s为计数周期)
      else if((clr==1)&&(leda==0)&&(ledb==0)&&(state1==0)&&(state2==1))
        begin
           counter1 = 300;
           counter2 = 300;
        end
       //如果清零端无效,且a按下了按键(leda=1)且计数没有到0且为状态一10s倒计时且无人按下暂停键（sa,sb=0）或投降键(ea,eb=0)
      else if((leda==1)&&(ledb==0)&&(clr==0)&&(counter1>0)&&(state1==1)&&(state2==0)&&(sa==0)&&(sb==0)&&(ea==0)&&(eb==0))
         begin
           counter1 = counter1 - 1;
           counter2 = 100;
         end
      //如果清零端无效,且b按下了按键(ledb=1)且计数没有到0且为状态一10s倒计时且无人按下暂停键（sa,sb=0）或投降键(ea,eb=0)
      else if((leda==0)&&(ledb==1)&&(clr==0)&&(counter2>0)&&(state1==1)&&(state2==0)&&(sa==0)&&(sb==0)&&(ea==0)&&(eb==0))
        begin
           counter2 = counter2 - 1;
           counter1 = 100;
        end
     //如果清零端无效,且a按下了按键(leda=1)且计数没有到0且为状态二30s倒计时且无人按下暂停键（sa,sb=0）或投降键(ea,eb=0)
      else if((leda==1)&&(ledb==0)&&(clr==0)&&(counter1>0)&&(state1==0)&&(state2==1)&&(sa==0)&&(sb==0)&&(ea==0)&&(eb==0))
         begin
           counter1 = counter1 - 1;
           counter2 = 300;
         end
    //如果清零端无效,且b按下了按键(ledb=1)且计数没有到0且为状态二30s倒计时且无人按下暂停键（sa,sb=0）或投降键(ea,eb=0)
      else if((leda==0)&&(ledb==1)&&(clr==0)&&(counter2>0)&&(state1==0)&&(state2==1)&&(sa==0)&&(sb==0)&&(ea==0)&&(eb==0))
         begin
           counter2 = counter2 - 1;
           counter1 = 300;
         end
      //如果清零端无效,在状态一10s倒计时情况下a按下了投降键(ea=1)
      else if((clr==0)&&(ea==1)&&(state1==1)&&(state2==0))
         begin
           counter1 = 0;
           counter2 = 100;
         end
      //如果清零端无效,在状态二30s倒计时情况下a按下了投降键(ea=1)
     else if((clr==0)&&(ea==1)&&(state1==0)&&(state2==1))
        begin
           counter1 = 0;
           counter2 = 300;
        end
     //如果清零端无效,在状态一10s倒计时情况下b按下了投降键(eb=1)
     else if((clr==0)&&(eb==1)&&(state1==1)&&(state2==0))
       begin
          counter2 = 0;
          counter1 = 100;
       end
     //如果清零端无效,在状态二30s倒计时情况下b按下了投降键(eb=1)
      else if((clr==0)&&(eb==1)&&(state1==0)&&(state2==1))
        begin
          counter2 = 0;
          counter1 = 300;
        end
  end
   assign Q1 = counter1[9:0];
   assign Q2 = counter2[9:0];
endmodule

module disp(clk_1k,clr,Q1,Q2,d1,d2,d3,d4,d5,d6);
  input clk_1k;input clr;
  input [9:0] Q1; input [9:0] Q2;
  output reg[5:0] d1; output reg[5:0] d2; output reg[5:0] d3;
  output reg[5:0] d4; output reg[5:0] d5; output reg[5:0] d6;
  always@(posedge clk_1k)
    begin
    if((Q1>0)&&(Q2>0))//如果计数器都大于0
      begin
         d1 = Q1/100;//第一个是十位,将计数器值整除100
         d2 = (Q1/10)%10;//第二个是个位,先整除10再求余
         d3 = Q1%10;//第三位是十分位,直接求余
         d4 = Q2/100;
         d5 = (Q2/10)%10;
         d6 = Q2%10;
      end
     else if((Q1==0)&&(Q2!=0))
       begin
         d1 = 11;//第一个数码管显示b(显示电路中设置11对应的显示结果为b)
         d2 = 15;//第二个数码管不显示
         d3 = 12;//第三个数码管显示U
         d4 = 12;//第四个数码管显示U
         d5 = 13;//第五个数码管显示I
         d6 = 14;//第六个数码管显示n
       end
      else if((Q2==0)&&(Q1!=0))
        begin
         d1 = 10;//第一个数码管显示a
         d2 = 15;
         d3 = 12;
         d4 = 12;
         d5 = 13;
         d6 = 14;
        end
    end
endmodule

module dynamic_led6(
input [5:0]disp_data_right0,
input [5:0]disp_data_right1,
input [5:0]disp_data_right2,
input [5:0]disp_data_right3,
input [5:0]disp_data_right4,
input [5:0]disp_data_right5,
input clk,
output  reg  [7:0] seg,
output  reg  [5:0] dig
	);
	
	//分频为1kHz
	reg[24:0] clk_div_cnt=0;
	reg clk_div=0;
	always @ (posedge clk)
	begin
		if (clk_div_cnt==24999)
		begin
			clk_div=~clk_div;
			clk_div_cnt=0;
		end
		else 
		    clk_div_cnt=clk_div_cnt+1;
	end
	
	//6进制计数器
	reg [2:0] num=0;
	always @ (posedge clk_div)
	begin
		if (num>=5)
			num=0;
		else
			num=num+1;
	end
	
	//轮流点亮数码管
	always @ (num)
	begin	
		case(num)
		0:dig=6'b011111;
		1:dig=6'b101111;
		2:dig=6'b110111;
		3:dig=6'b111011;
		4:dig=6'b111101;
		5:dig=6'b111110;     
		default: dig=0;
		endcase
	end
	
	//选择器，确定显示数据
	reg [3:0] disp_data;
	always @ (num)
	begin	
		case(num)
	    	0:disp_data=disp_data_right0;
	    	1:disp_data=disp_data_right1;
	       	2:disp_data=disp_data_right2;
		    3:disp_data=disp_data_right3;
            4:disp_data=disp_data_right4;
            5:disp_data=disp_data_right5;
		    default: disp_data=0;
		endcase
	end
	
	//显示译码器
	always@(disp_data)
	if((num!=1)&&(num!=4))//不显示小数点
	begin
		case(disp_data)
		4'h0: seg=8'h3f;// DP,GFEDCBA
		4'h1: seg=8'h06;
		4'h2: seg=8'h5b;
		4'h3: seg=8'h4f;
		4'h4: seg=8'h66;
		4'h5: seg=8'h6d;
		4'h6: seg=8'h7d;
		4'h7: seg=8'h07;
		4'h8: seg=8'h7f;
		4'h9: seg=8'h6f;
		4'ha: seg=8'h77;//显示A
		4'hb: seg=8'h7c;//显示b
		4'hc: seg=8'h3e;//显示U
		4'hd: seg=8'h06;//显示I
		4'he: seg=8'h37;//显示n
		default: seg=0;
		endcase
	end
    else if(num==1|num==4)//显示小数点
     begin
 		case(disp_data)
      4'h0: seg=8'hbf;// DP,GFEDCBA
      4'h1: seg=8'h86;
      4'h2: seg=8'hdb;
      4'h3: seg=8'hcf;
      4'h4: seg=8'he6;
      4'h5: seg=8'hed;
      4'h6: seg=8'hfd;
      4'h7: seg=8'h87;
      4'h8: seg=8'hff;
      4'h9: seg=8'hef;
      4'ha: seg=8'h77;
      4'hb: seg=8'h7c;
      4'hc: seg=8'h3e;
      4'hd: seg=8'h06;
      4'he: seg=8'h37;
     default: seg=0;
     endcase
     end
endmodule

module ledss(led,clk_1k,clk_1Hz,Q);
    input clk_1Hz;
    input clk_1k;
    output reg led;
    input [9:0] Q;
    always@(posedge clk_1k)
      begin
        if((Q<=50)&&(clk_1Hz==1)&&(Q>0))//如果倒计时在5s以内且大于0且时钟信号为1
            begin
                led = 1;
            end
       else if((Q<=50)&&(clk_1Hz==0)&&(Q>0))//如果倒计时在5s以内且大于0且时钟信号为0
           begin
                led = 0;
           end
       else if(Q==0)//如果倒计时为0
           begin
                 led = 1;
           end
       else
            led = 0;
      end
endmodule


module buzzmusic(Q1,Q2,buzz,clk,clk_1Hz);
input [9:0] Q1;
input [9:0] Q2;
output reg buzz;
input clk;
input clk_1Hz;

reg [18:0] count=0;
reg [18:0] buzzer_count_half;
integer music = 179979;

always@(posedge clk)
begin
if((Q1==0)|(Q2==0))//如果倒计时为0
 begin
 buzzer_count_half=music/2;
   if(music==0)//如果设置的频率值为0,蜂鸣器不响
   begin
     buzz = 0;
   end
   else
    begin
      count = count + 1;
      if(count>=music)//如果计数达到设定的频率值则归零
       begin
         count = 0;
       end
       else if(count<=buzzer_count_half)//如果计数值小于设置值一半buzz为1
        begin
          buzz = 1;
        end
       else//否则buzz为0
         begin
          buzz = 0;
         end
    end
 end
 else if((Q1>0)&&(Q2>0)&&(Q1<50|Q2<50)&&(clk_1Hz==1))//如果倒计时5s以内且1s方波信号为1
  begin
   buzzer_count_half=music/2;
    if(music==0)
    begin
      buzz = 0;
    end
    else
     begin
       count = count + 1;
       if(count>=music)
        begin
          count = 0;
        end
        else if(count<=buzzer_count_half)
         begin
           buzz = 1;
         end
        else
          begin
           buzz = 0;
          end
     end      
  end
end
endmodule





  

