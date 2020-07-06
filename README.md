# Verilog
使用Verilog语言编写代码。

#caculator
计算机功能操作说明：
上电之后，默认数码管全部不显示，sw11,sw10均拨在下面，当按下0-9中任一位数字时，、数码管4显示相应的数字，再按下0-9中且与第一次输入不同的数字时，数码管4和数码管5点亮，两位数码管显示的数字构成参与运算的第一个数（如果只输入一次数字，则只显示数码管4），如果输入的数字是个位和十位相同的情况，则必须在按下第一个数字之后、在按下第二个数字之前将左下角拨码开关sw11拨上去，才能正常输入第二个数字（输入完成后将拨码开关再拨下去），输入完参与运算的第一个数之后，按下“＋”“－”“×”“÷”其中一个键后，数码管3点亮，显示相应运算符，这时按照输入第一个数的方法输入第二个数（如果该数的个位和十位相同则拨动拨码开关sw10），输入完毕后按下“=”，则数码管5显示“=”，数码管4显示正负（如果是正则不显示，如果是负则显示“-”），后四位数码管显示运算结果（结果如果是小数，则精确到小数点后两位）。得到运算结果后，还可实现连续运算的功能，按下“＋”“－”“×”“÷”键后，可以接着输入数字进行运算（输入方式同最开始输入第二个数字的方式相同，这里只显示最新输入的数字）。当按下清零键后，数码管将全部不显示，回到初始状态。
计算器设计结果：
设计实现了两位数的加减乘除运算，输出显示最多可以达到四位，如果出现小数，结果可以精确到小数点后两位，如果除数为0，可以显示错误“×”，同时也可以实现连续运算，并且连续运算中出现负数也可以正常运算，在连续运算中，只要结果不超过四位数码管都可以正常显示，超过四位则只能显示最后四位。当按下按键的时候，数码管可以显示相应的数值，蜂鸣器也会发出相应的响声。

#gametimer
秒表具有10s倒计时和30s倒计时两个模式可以进行选择。计时功能体现为：当A棋手落子后按下A键，此时B棋手的秒表开始倒计时，A棋手的秒表恢复为倒计时初始值；当B棋手落子后按下B键，A棋手的秒表开始倒计时，B棋手的秒表恢复为倒计时初始值。当倒计时达到5s以内时，蜂鸣器将会每秒响一下，对应的LED灯也会每秒闪烁一次。当计时到0之后，蜂鸣器将变成长响，同时LED灯持续闪烁，数码管上显示出获胜棋手win的字样(“A win”或者“b win”)。在此基础上，本实验还实现了倒计时过程中可以使用暂停键进行暂停，当再次按下计时键后又可以继续计时。此外，本实验也设置了认输键，当倒计时过程中某一方按下认输键之后，数码管将会直接显示另一方获胜，蜂鸣器常响，LED灯持续闪烁。

