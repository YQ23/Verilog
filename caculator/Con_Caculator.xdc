#分配输出引脚（时钟）和电平规范
set_property PACKAGE_PIN D4 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

#分配输出引脚（矩阵键盘列）和电平规范
set_property PACKAGE_PIN T10 [get_ports col[0]]
set_property IOSTANDARD LVCMOS33 [get_ports col[0]]
set_property PULLDOWN true [get_ports col[0]]

set_property PACKAGE_PIN R11 [get_ports col[1]]
set_property IOSTANDARD LVCMOS33 [get_ports col[1]]
set_property PULLDOWN true [get_ports col[1]]

set_property PACKAGE_PIN T12 [get_ports col[2]]
set_property IOSTANDARD LVCMOS33 [get_ports col[2]]
set_property PULLDOWN true [get_ports col[2]]

set_property PACKAGE_PIN R12 [get_ports col[3]]
set_property IOSTANDARD LVCMOS33 [get_ports col[3]]
set_property PULLDOWN true [get_ports col[3]]

#分配输出引脚（矩阵键盘行）和电平规范
set_property PACKAGE_PIN K3 [get_ports row[0]]
set_property IOSTANDARD LVCMOS33 [get_ports row[0]]

set_property PACKAGE_PIN M6 [get_ports row[1]]
set_property IOSTANDARD LVCMOS33 [get_ports row[1]]

set_property PACKAGE_PIN P10 [get_ports row[2]]
set_property IOSTANDARD LVCMOS33 [get_ports row[2]]

set_property PACKAGE_PIN R10 [get_ports row[3]]
set_property IOSTANDARD LVCMOS33 [get_ports row[3]]

#分配输出引脚（段码）和电平规范
set_property PACKAGE_PIN P11 [get_ports seg[0]]
set_property IOSTANDARD LVCMOS33 [get_ports seg[0]]

set_property PACKAGE_PIN N12 [get_ports seg[1]]
set_property IOSTANDARD LVCMOS33 [get_ports seg[1]]

set_property PACKAGE_PIN L14 [get_ports seg[2]]
set_property IOSTANDARD LVCMOS33 [get_ports seg[2]]

set_property PACKAGE_PIN K13 [get_ports seg[3]]
set_property IOSTANDARD LVCMOS33 [get_ports seg[3]]

set_property PACKAGE_PIN K12 [get_ports seg[4]]
set_property IOSTANDARD LVCMOS33 [get_ports seg[4]]

set_property PACKAGE_PIN P13 [get_ports seg[5]]
set_property IOSTANDARD LVCMOS33 [get_ports seg[5]]

set_property PACKAGE_PIN M14 [get_ports seg[6]]
set_property IOSTANDARD LVCMOS33 [get_ports seg[6]]

set_property PACKAGE_PIN L13 [get_ports seg[7]]
set_property IOSTANDARD LVCMOS33 [get_ports seg[7]]

#分配输出引脚（位码）和电平规范
set_property PACKAGE_PIN N11 [get_ports DIG[0]]
set_property IOSTANDARD LVCMOS33 [get_ports DIG[0]]

set_property PACKAGE_PIN N14 [get_ports DIG[1]]
set_property IOSTANDARD LVCMOS33 [get_ports DIG[1]]

set_property PACKAGE_PIN N13 [get_ports DIG[2]]
set_property IOSTANDARD LVCMOS33 [get_ports DIG[2]]

set_property PACKAGE_PIN M12 [get_ports DIG[3]]
set_property IOSTANDARD LVCMOS33 [get_ports DIG[3]]

set_property PACKAGE_PIN H13 [get_ports DIG[4]]
set_property IOSTANDARD LVCMOS33 [get_ports DIG[4]]

set_property PACKAGE_PIN G12 [get_ports DIG[5]]
set_property IOSTANDARD LVCMOS33 [get_ports DIG[5]]

#分配输出引脚（时钟）和电平规范
set_property PACKAGE_PIN L2 [get_ports buzzer]
set_property IOSTANDARD LVCMOS33 [get_ports buzzer]

#分配输出引脚（开关）和电平规范
set_property PACKAGE_PIN F3 [get_ports sw1]
set_property IOSTANDARD LVCMOS33 [get_ports sw1]

set_property PACKAGE_PIN H4 [get_ports sw2]
set_property IOSTANDARD LVCMOS33 [get_ports sw2]
