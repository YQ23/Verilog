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
  input clk,//ϵͳʱ��
  input clr,//�����
  input state1,//״̬1(10s����ʱ)
  input state2,//״̬2(30s����ʱ)
  input [3:0] col,//��
  output [3:0] row,//��
  output [7:0] seg,//����
  output [5:0] dig,//λ��
  output led1,//a���¼�ʱ���ı�־
  output led2,//b���¼�ʱ���ı�־
  output leda,//a����ʱ5s����led����˸
  output ledb,//b����ʱ5s����led����˸
  output sa,//a������ͣ��
  output sb,//b������ͣ��
  output buzz//������
    );
    wire clk_1k;//1kHzʱ���ź�
    wire clk_10Hz;
    wire clk_50Hz;
    wire clk_1Hz;
    wire [15:0] btn_out;//�����16������
    wire ea;//a�����־
    wire eb;//b�����־
    wire [9:0] Q1;//a���ֵ
    wire [9:0] Q2;//b���ֵ
    wire[5:0] d1; wire[5:0] d2; wire[5:0] d3;
    wire[5:0] d4; wire[5:0] d5;wire[5:0] d6;//��������ܶ�Ӧ��ֵ

   //��Ƶ,�õ�Ƶ��Ϊ1kHz,10Hz,50Hz,1Hz���ź�
    FreDiv f1( .clk(clk), .frequency(1000),.clk_out(clk_1k));
    FreDiv f2( .clk(clk),.frequency(10),.clk_out(clk_10Hz));
    FreDiv f3( .clk(clk), .frequency(50),.clk_out(clk_50Hz));
    FreDiv f4( .clk(clk), .frequency(1), .clk_out(clk_1Hz));
    
    //����ģ��,�ж��ĸ���������
    ButtonInput  button( .clk_scan(clk_1k), .clk_judge(clk_50Hz), 
.col(col),.row(row), .btn_out(btn_out),.clr(clr));
    
    //����״̬��ʾģ��,��������Ϣ��ӳ��LED����
    ledab l1( .btn(btn_out), .leda(leda), .ledb(ledb),.clr(clr),
.clk_1k(clk_1k),.sa(sa),.sb(sb),.ea(ea),.eb(eb));     
    //������ģ��               
    counter_d cc(.clr(clr),.state1(state1),.state2(state2),.clk_10Hz(clk_10Hz),
    .leda(leda),.ledb(ledb),.Q1(Q1),.Q2(Q2),.sa(sa),.sb(sb),.ea(ea),.eb(eb));
    //���ֵת��Ϊ��������ܵ�״̬
    disp dh(clk_1k,clr,Q1,Q2,d1,d2,d3,d4,d5,d6);
    
    //�������������״̬��ʾ��Ӧ��Ϣ
    dynamic_led6 dl(
    .disp_data_right0(d1), .disp_data_right1(d2), .disp_data_right2(d3),
    .disp_data_right3(d4), .disp_data_right4(d5), .disp_data_right5(d6),
    .clk(clk), .seg(seg), .dig(dig) );
    
     //LED����˸ģ��
     ledss s1(.led(led1),.clk_1k(clk_1k),.clk_1Hz(clk_1Hz),.Q(Q1));
     ledss s2(.led(led2),.clk_1k(clk_1k),.clk_1Hz(clk_1Hz),.Q(Q2));
     
     //����������ģ��
     buzzmusic bu(.Q1(Q1),.Q2(Q2),.buzz(buzz),.clk(clk),.clk_1Hz(clk_1Hz));
endmodule

module FreDiv( input clk, input [31:0] frequency, output reg clk_out);//��Ƶ
 
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
             if(count>=count_max)//�������涨ֵ�͹��㣬ʱ�ӷ���
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
        //ͨ�����е����ֵ�趨������ѡ�и���
        always @ (posedge clk_scan)
        begin
            if(row==4'b1000)    row=4'b0001;
            else    row=row<<1;//������һλ��0001-0010-0100-1000-0001...
        end
        
        always @ (negedge clk_scan)
        begin
            case(row)
                4'b0001:    btn[3:0]=col;//������ֵ����4λ�Ĵ���
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
 
        assign btn_out=(btn2&btn1&btn0)|(~btn2&btn1&btn0);//��������
    
endmodule
    
module ledab( btn, leda, ledb,clr,clk_1k,sa,sb,ea,eb);
input [15:0] btn;output reg leda;output reg ledb;
input clr;
input clk_1k;
output reg sa;output reg sb;
output reg ea;output reg eb;
always@(posedge clk_1k)
 begin
   if(btn[15]==1&&btn[14]==0&&clr==0)//���a���¼�ʱ��
     begin
       leda = 1;
       ledb = 0;
       sa = 0;
       sb = 0;
       ea = 0;
       eb = 0;
     end
   else if(btn[14]==1&&btn[15]==0&&clr==0)//���b���¼�ʱ��
     begin
       leda = 0;
       ledb = 1;
       sa = 0;
       sb = 0;
       ea = 0;
       eb = 0;
     end
    else if(btn[11]==1&&btn[10]==0&&clr==0)//���a������ͣ��
    begin
      sa = 1;
    end
    else if(btn[10]==1&&btn[11]==0&&clr==0)//���b������ͣ��
     begin
      sb = 1;
     end
    else if(btn[7]==1&&btn[6]==0&&clr==0)//���a���������
      begin
       ea = 1;
       eb = 0;
      end
    else if(btn[6]==1&&btn[7]==0&&clr==0)//���b���������
      begin
         eb = 1;
         ea = 0;
      end
   else if(clr==1)//����������Ч
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
  input state1;//״̬1(10s����ʱ)
  input state2;//״̬2(30s����ʱ)
  input clk_10Hz;//10Hzʱ���ź�
  input leda;//a����ʱ5s���ڵ�LED��
  input ledb;//b����ʱ5s���ڵ�LED��
  input sa;//a�Ƿ�����ͣ��
  input sb;//b�Ƿ�����ͣ��
  input ea;//a�Ƿ�����
  input eb;//b�Ƿ�����

  reg [9:0] counter1;
  reg [9:0] counter2;
  output [9:0] Q1;
  output [9:0] Q2;
  
 
  always@(posedge clk_10Hz)
  begin
       //����������Ч������״̬1����������������Ϊ100(0.1sΪ��������)
      if((clr==1)&&(leda==0)&&(ledb==0)&&(state1==1)&&(state2==0)) 
        begin
           counter1 = 100;
           counter2 = 100;
        end
       //����������Ч������״̬2����������������Ϊ100(0.1sΪ��������)
      else if((clr==1)&&(leda==0)&&(ledb==0)&&(state1==0)&&(state2==1))
        begin
           counter1 = 300;
           counter2 = 300;
        end
       //����������Ч,��a�����˰���(leda=1)�Ҽ���û�е�0��Ϊ״̬һ10s����ʱ�����˰�����ͣ����sa,sb=0����Ͷ����(ea,eb=0)
      else if((leda==1)&&(ledb==0)&&(clr==0)&&(counter1>0)&&(state1==1)&&(state2==0)&&(sa==0)&&(sb==0)&&(ea==0)&&(eb==0))
         begin
           counter1 = counter1 - 1;
           counter2 = 100;
         end
      //����������Ч,��b�����˰���(ledb=1)�Ҽ���û�е�0��Ϊ״̬һ10s����ʱ�����˰�����ͣ����sa,sb=0����Ͷ����(ea,eb=0)
      else if((leda==0)&&(ledb==1)&&(clr==0)&&(counter2>0)&&(state1==1)&&(state2==0)&&(sa==0)&&(sb==0)&&(ea==0)&&(eb==0))
        begin
           counter2 = counter2 - 1;
           counter1 = 100;
        end
     //����������Ч,��a�����˰���(leda=1)�Ҽ���û�е�0��Ϊ״̬��30s����ʱ�����˰�����ͣ����sa,sb=0����Ͷ����(ea,eb=0)
      else if((leda==1)&&(ledb==0)&&(clr==0)&&(counter1>0)&&(state1==0)&&(state2==1)&&(sa==0)&&(sb==0)&&(ea==0)&&(eb==0))
         begin
           counter1 = counter1 - 1;
           counter2 = 300;
         end
    //����������Ч,��b�����˰���(ledb=1)�Ҽ���û�е�0��Ϊ״̬��30s����ʱ�����˰�����ͣ����sa,sb=0����Ͷ����(ea,eb=0)
      else if((leda==0)&&(ledb==1)&&(clr==0)&&(counter2>0)&&(state1==0)&&(state2==1)&&(sa==0)&&(sb==0)&&(ea==0)&&(eb==0))
         begin
           counter2 = counter2 - 1;
           counter1 = 300;
         end
      //����������Ч,��״̬һ10s����ʱ�����a������Ͷ����(ea=1)
      else if((clr==0)&&(ea==1)&&(state1==1)&&(state2==0))
         begin
           counter1 = 0;
           counter2 = 100;
         end
      //����������Ч,��״̬��30s����ʱ�����a������Ͷ����(ea=1)
     else if((clr==0)&&(ea==1)&&(state1==0)&&(state2==1))
        begin
           counter1 = 0;
           counter2 = 300;
        end
     //����������Ч,��״̬һ10s����ʱ�����b������Ͷ����(eb=1)
     else if((clr==0)&&(eb==1)&&(state1==1)&&(state2==0))
       begin
          counter2 = 0;
          counter1 = 100;
       end
     //����������Ч,��״̬��30s����ʱ�����b������Ͷ����(eb=1)
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
    if((Q1>0)&&(Q2>0))//���������������0
      begin
         d1 = Q1/100;//��һ����ʮλ,��������ֵ����100
         d2 = (Q1/10)%10;//�ڶ����Ǹ�λ,������10������
         d3 = Q1%10;//����λ��ʮ��λ,ֱ������
         d4 = Q2/100;
         d5 = (Q2/10)%10;
         d6 = Q2%10;
      end
     else if((Q1==0)&&(Q2!=0))
       begin
         d1 = 11;//��һ���������ʾb(��ʾ��·������11��Ӧ����ʾ���Ϊb)
         d2 = 15;//�ڶ�������ܲ���ʾ
         d3 = 12;//�������������ʾU
         d4 = 12;//���ĸ��������ʾU
         d5 = 13;//������������ʾI
         d6 = 14;//�������������ʾn
       end
      else if((Q2==0)&&(Q1!=0))
        begin
         d1 = 10;//��һ���������ʾa
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
	
	//��ƵΪ1kHz
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
	
	//6���Ƽ�����
	reg [2:0] num=0;
	always @ (posedge clk_div)
	begin
		if (num>=5)
			num=0;
		else
			num=num+1;
	end
	
	//�������������
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
	
	//ѡ������ȷ����ʾ����
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
	
	//��ʾ������
	always@(disp_data)
	if((num!=1)&&(num!=4))//����ʾС����
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
		4'ha: seg=8'h77;//��ʾA
		4'hb: seg=8'h7c;//��ʾb
		4'hc: seg=8'h3e;//��ʾU
		4'hd: seg=8'h06;//��ʾI
		4'he: seg=8'h37;//��ʾn
		default: seg=0;
		endcase
	end
    else if(num==1|num==4)//��ʾС����
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
        if((Q<=50)&&(clk_1Hz==1)&&(Q>0))//�������ʱ��5s�����Ҵ���0��ʱ���ź�Ϊ1
            begin
                led = 1;
            end
       else if((Q<=50)&&(clk_1Hz==0)&&(Q>0))//�������ʱ��5s�����Ҵ���0��ʱ���ź�Ϊ0
           begin
                led = 0;
           end
       else if(Q==0)//�������ʱΪ0
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
if((Q1==0)|(Q2==0))//�������ʱΪ0
 begin
 buzzer_count_half=music/2;
   if(music==0)//������õ�Ƶ��ֵΪ0,����������
   begin
     buzz = 0;
   end
   else
    begin
      count = count + 1;
      if(count>=music)//��������ﵽ�趨��Ƶ��ֵ�����
       begin
         count = 0;
       end
       else if(count<=buzzer_count_half)//�������ֵС������ֵһ��buzzΪ1
        begin
          buzz = 1;
        end
       else//����buzzΪ0
         begin
          buzz = 0;
         end
    end
 end
 else if((Q1>0)&&(Q2>0)&&(Q1<50|Q2<50)&&(clk_1Hz==1))//�������ʱ5s������1s�����ź�Ϊ1
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





  

