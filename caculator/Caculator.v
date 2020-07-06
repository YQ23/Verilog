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
    input clk,//ϵͳʱ��
    output buzzer,//������
    output [3:0] row,//���������
   	input [3:0] col,//���������
   	output [7:0] seg,//����
    output [5:0] DIG,//λ��
    input sw1,//��һ�����ĸ�λ��ʮλ�Ƿ����
    input sw2//�ڶ������ĸ�λ��ʮλ�Ƿ����
    );
    wire clk_1kHz;//Ƶ��Ϊ1kHz��ʱ��
    wire clk_50Hz;//Ƶ��Ϊ50Hz��ʱ��
    wire [15:0] btn;//����
    
   //1kHzʱ�ӷ�Ƶģ��
      FreDiv d1(
            .clk(clk),
            .frequency(1000),
            .clk_out(clk_1kHz)
        );
        
    //50Hzʱ�ӷ�Ƶģ��
        FreDiv d2(
            .clk(clk),
            .frequency(50),
            .clk_out(clk_50Hz)
        );
        
       //�жϰ����Ƿ��µ�ģ��
      button b1(
            .clk_1kHz(clk_1kHz),
            .clk_50Hz(clk_50Hz),
            .col(col),
            .row(row),
            .btn_out(btn)
        );
        
        //�������������ʾģ��
        cal c1(
          .clk_in(clk_1kHz),
          .DIG(DIG),
          .seg(seg),
          .btn(btn),
          .sw1(sw1),
          .sw2(sw2)
          );
          
         //����������ģ��
         buzzermusic m1(
           .clk(clk),
           .btn(btn),
           .buzzer(buzzer)
         );
        
endmodule


module cal(
    input clk_in, //�����1kHzʱ��
    output reg [5:0] DIG,//λ��
    output reg [7:0] seg,//����
    input [15:0] btn,//����
    input sw1,//����1
    input sw2//����2
 );
   reg [4:0] i;  //����һ�������Ĵ�������
   reg [3:0] disp_dat1=0,disp_dat2=0,disp_dat3=0,disp_dat4=0,disp_dat5=0;//ǰ����������ʾֵ
   reg [2:0] state=0;//�жϰ�������ʲô״̬
   reg [3:0] op = 0; // �ж������������ϵ
   reg [3:0] key_buf=4'b0000,key_buf2=4'b0000,key2_buf=4'b0000,key2_buf2=4'b0000;//�洢�������ĸ�λ��ʮλ
   reg eco=0;//�жϡ�=���Ƿ���
   reg [2:0] dig_count;//λ�������
   reg [20:0] result;//�洢���
   reg  result_reg1 = 0,result_reg2 = 0;//�ж����Ӻ������������Ƿ����µİ���������
   reg [3:0] h_bit2,h_bit,l_bit;//����������λ��ʾֵ
   wire [20:0] a;
   wire [6:0] b;//��������ĵ�һ����Ϊa,�ڶ�����Ϊb����Ϊa���ܴ���99����λ���ϴ�
   reg [3:0] res;//�����е�����
   reg [3:0] ch=4'b1111;//�жϵ�һ�ΰ����͵ڶ��ΰ��������
   reg [20:0] a_reg;
   reg [6:0] b_reg;//�洢a��b
   reg flag=0;//�ж��Ƿ������ӡ����������ˡ�����
   reg minus=0;//�ж��Ƿ��С�-���ų���
   parameter add=4'b1010,sub=4'b1011,mult=4'b1100,div=4'b1101;//����Ӽ��˳�
   assign a = a_reg;
   assign b = b_reg;

   
   always@(posedge clk_in)
     begin
       for(i=0;i<=15;i=i+1)
         if(btn[i]==1)
          begin
             if(i>=0 && i<=9) //���0-9����������
               begin
                if(state == 0) //���֮ǰû�а���������
                 begin
                     ch <= i; 
                     state <= 1;
                     key_buf2 <= i; 
                     disp_dat1 <= 0;
                     key_buf <= 0;
                     disp_dat2 <= i;
                     a_reg <= i;
                 end
                 
                else if((ch != i && state == 1) | (state == 1 && sw1 == 1)) //�����һ����a����λ��
                  begin
                    state <= 2;
                    key_buf <= key_buf2;
                    key_buf2 <= i;                   
                    disp_dat1 <= disp_dat2;
                    disp_dat2 <= i; 
                    a_reg <= 10 * ch + i;
                    ch <= 4'b1111;
                  end
                 else if(state == 3 ) //����ڶ������ĵ�һλ������
                   begin
                     state <= 4;
                     key2_buf2 <= i; 
                     key_buf <= 0;
                     ch <= i;
                     disp_dat4 <= 0;
                     disp_dat5 <= i;
                   end
               
                 else if((state == 4 && ch != i)| (state == 4 && sw2 == 1)) //����ڶ������ĵڶ�λ������
                   begin
                     state <= 5;
                     key2_buf <= key2_buf2;
                     key2_buf2 <= i;
                     disp_dat4 <= disp_dat5;
                     disp_dat5 <= i;
                     ch <= 4'b1111;
                   end
                 
                 end
                 
               else if(i>=10 && i<=13) //����Ӽ��˳�������һ��������
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
                
               else if(i == 14) //�����=��������
                 begin
                   eco <= 1;
                   state <= 6;
                   b_reg = 10 * key2_buf + key2_buf2;
                 end
                 
               else if(i == 15) //�������������£�����ֵ�ָ�����ʼ״̬
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
        case(dig_count)//�����ɨ��
         3'b000:
         begin
          DIG = 6'b111110;//��һ���������
          if(eco == 0 && state != 0 && state != 6 && flag == 0 )//�����=����δ���²��Ҳ��ǳ�ʼ״̬
          begin
            case(disp_dat1)
                 4'h0:seg = 0; //8'h3f;  //��ʾ0��
                 4'h1:seg = 8'h06;  //��ʾ1��
                 4'h2:seg = 8'h5b;  //��ʾ2��
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
           else if(eco == 1 && b==0 && op == div)//�����=���������²�������ǳ�������³�����Ϊ0
              begin
                seg = 8'b01110110;
              end
           else if(eco == 1 && op != 0)//��������г���Ϊ0����ʾ��
             begin
               seg = 8'b01001000;
             end
           else 
               seg = 0;
              dig_count = dig_count + 1'b1;
             end
           3'b001:
             begin
               DIG = 6'b111101;//�����ڶ��������
               if(eco == 0 && state != 0 && state != 6 && flag == 0)//���"="��δ���²��Ҳ��ǳ�ʼ״̬
                begin
                 case(disp_dat2)
                 4'h0:seg = 8'h3f;  //��ʾ0��
                 4'h1:seg = 8'h06;  //��ʾ1��
                 4'h2:seg = 8'h5b;  //��ʾ2��
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
            else if(eco == 1 && minus == 1 )//�����=���������²��Ҽ����н����Ϊ����
               begin
                 seg = 8'b01000000;
               end
              else 
                 seg = 0;
         
              dig_count = dig_count + 1'b1;
             end
           3'b010:
             begin
               DIG = 6'b111011;//���������������
            if(eco == 0)//�����=����δ������
             begin
              case(op)
               add:seg = 8'b01000110;
               sub:seg = 8'b01000000;
               mult:seg = 8'b01110110;
               div:seg = 8'b01001001;
               default:seg = 0;
              endcase
             end
             else if(eco == 1 && res == 0 && op != div)//�����=�����²��ҳ�����������
               begin
                 disp_dat3 = (result / 1000) % 10;
                 case(disp_dat3)
                  4'h0:seg = 0;//8'h3f;  //��ʾ0��
                  4'h1:seg = 8'h06;  //��ʾ1��
                  4'h2:seg = 8'h5b;  //��ʾ2��
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
              else if(eco == 1 && res != 0 && op == div)//��������г��ֲ������������
                begin
                  disp_dat3 = (result / 10) % 10;//ȡ�������ʮλ
                  case(disp_dat3)
                  4'h0:seg = 0;//8'h3f;  //��ʾ0��
                  4'h1:seg = 8'h06;  //��ʾ1��
                  4'h2:seg = 8'h5b;  //��ʾ2��
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
            if(op != 0 && eco == 0 )//�����=��δ�����²��ҼӼ��˳�����һ����������
              begin
              case(disp_dat4)
                 4'h0:seg = 0;//8'h3f;  //��ʾ0��
                 4'h1:seg = 8'h06;  //��ʾ1��
                 4'h2:seg = 8'h5b;  //��ʾ2��
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
             else if(op != 0 && eco == 1 && res == 0)//�����=���ű����²���δ���ֳ��������������
              begin
                 h_bit2 = (result / 100) % 10;
                 case(h_bit2)
                 4'h0:seg = 8'h3f;  //��ʾ0��
                 4'h1:seg = 8'h06;  //��ʾ1��
                 4'h2:seg = 8'h5b;  //��ʾ2��
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
            else if(eco == 1 && res != 0 && op == div)//�����=���ű����²��ҳ��ֳ��������������
              begin
                h_bit2 = result % 10;
                case(h_bit2)
                  4'h0:seg = 8'hbf;  //��ʾ0.��
                  4'h1:seg = 8'h86;  //��ʾ1.��
                  4'h2:seg = 8'hdb;  //��ʾ2.��
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
                if(eco == 0 && op != 0 && (state == 4|state == 5))//����ڶ���������ֵ
                  begin
                  case(disp_dat5)
                  4'h0:seg = 8'h3f;  //��ʾ0��
                  4'h1:seg = 8'h06;  //��ʾ1��
                  4'h2:seg = 8'h5b;  //��ʾ2��
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
             else if(eco == 1 && op != 0  && res == 0)//�����=���ű����²��Ҳ����ֳ��������������
               begin
                 h_bit = (result / 10) % 10;//ȡ������ĵڶ�λ
                case(h_bit)
                 4'h0:seg = 8'h3f;  //��ʾ0��
                 4'h1:seg = 8'h06;  //��ʾ1��
                 4'h2:seg = 8'h5b;  //��ʾ2��
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
             else if(eco == 1 && op==div && res != 0)//������ֳ��������������
              begin
                  h_bit = res * 10 / b;
                 case(h_bit)
                   4'h0:seg = 8'h3f;  //��ʾ0��
                   4'h1:seg = 8'h06;  //��ʾ1��
                   4'h2:seg = 8'h5b;  //��ʾ2��
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
                 DIG = 6'b011111;//�������һ�������
                if(eco == 1  && res == 0)//�����=�������²��Ҳ����ֲ����������
                  begin
                  l_bit = result % 10;
                 case(l_bit)
                  4'h0:seg = 8'h3f;  //��ʾ0��
                  4'h1:seg = 8'h06;  //��ʾ1��
                  4'h2:seg = 8'h5b;  //��ʾ2��
                  4'h3:seg = 8'h4f;
                  4'h4:seg = 8'h66;
                  4'h5:seg = 8'h6d;
                  4'h6:seg = 8'h7d;
                  4'h7:seg = 8'h07;
                  4'h8:seg = 8'h7f;
                  4'h9:seg = 8'h6f;                  
                  endcase                   
                 end
               else if(eco == 1  && res != 0 && op == div)//�����=�������²��ҳ���������
                begin
                 l_bit = ((res * 10) % b) * 10 / b;
                case(l_bit)
                  4'h0:seg = 8'h3f;  //��ʾ0��
                  4'h1:seg = 8'h06;  //��ʾ1��
                  4'h2:seg = 8'h5b;  //��ʾ2��
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
               case(op)//����ģ��
                add:
                  if(flag == 0)//����ǵ�һ�ΰ���=��
                   begin
                     result = a + b;
                     minus = 0;
                   end
                  else if(flag == 1)//����Ǵ�����������
                   begin
                      if(minus == 0 && result_reg1 != 1)//�����Ϊ��
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
            minus <= 0;//����λ����
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
	//��Ƶģ��
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
	//�жϰ����Ƿ񱻰��µ�ģ��
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
    //����������ģ��
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
        
        //�����ĸ�����ȷ�����ֵ�Ƶ��
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
