clear;
clc;
filenamex = 'input.txt';
filenamey = 'output.txt';
filenameb = 'coefficient.txt';
filenamec = 'dout_values.txt';
input_file = fopen(filenamex, "w");
output_file = fopen(filenamey, "w");
coefficient_file = fopen(filenameb, 'w');
dout_file = fopen(filenamec,"rb");
%dout = fread(dout_file,16,"uint8");
fileID = fopen('dout_values.txt', 'r');
bin_data = textscan(fileID, '%s');
fclose(fileID);
binArray = bin_data{1};
numValues = length(binArray);
halfPrecisionFloat = zeros(1,numValues+1);
%%
binaryInput = '1100000100000000'; % 二进制输入
halfPrecisionFloat(1,1) = 0;
for i = 2 : numValues+1
     halfPrecisionFloat(1,i) = binaryToHalfPrecision(binArray{i-1,1});
end
%%halfPrecisionFloat = binaryToHalfPrecision(binaryInput);
disp(halfPrecisionFloat);
%%
fs=100000;%Nyquist frequency=5kHZ
ts=1/fs;
t = 0 : ts : 0.1-ts;
N = 63;%64 tap
Wn = 0.2;%1kHz filter

b = fir1(N, Wn, "low", "scale");
for i = 1 : length(b)
    bit_b = bin(fi(b(i), 1, 16, 8));
    fwrite(coefficient_file, bit_b);
    fwrite(coefficient_file, newline);
end
%% input data convertion to 2bit

d_in = (1.7)*sin(2*pi*300*t) ...
  + (1.5)*sin(2*pi*500*t) ...
  + (1.3)*sin(2*pi*20000*t)+5;
for i = 1 : length(d_in)
    bit_rep_d_in = bin(fi(d_in(i), 1, 16,8));
    fwrite(input_file, bit_rep_d_in);
    fwrite(input_file, newline);
end
%%
y = filter(b, 1, d_in);
y_half = half(y);
for i = 1 : length(d_in)
    yin = bin(fi(y(i), 1, 37, 18));
    fwrite(output_file, yin);
    fwrite(output_file, newline);
end
%%
rmse = sqrt(mean((y_half - halfPrecisionFloat).^2));
nrmse = rmse / (max(y_half) - min(y_half));
%%
function halfFloat = binaryToHalfPrecision(binaryInput)
    % 输入为 16 位二进制数，格式为字符串，例如 '1100000000000000'
    if length(binaryInput) ~= 16
        error('输入必须为 16 位二进制字符串');
    end

    % 符号位
    signBit = str2double(binaryInput(1));
    sign = (-1)^signBit;

    % 指数部分（5 位）
    expBits = binaryInput(2:6);
    expValue = bin2dec(expBits) - 15; % 偏移量为 15

    % 尾数部分（10 位）
    mantissaBits = binaryInput(7:16);
    mantissa = 1 + bin2dec(mantissaBits) / 1024; % 规格化尾数，尾数占 10 位

    % 特殊情况处理
    if bin2dec(expBits) == 0
        % 次规格化数（Subnormal Number）
        mantissa = bin2dec(mantissaBits) / 1024;
        expValue = -14; % 次规格化指数
    elseif bin2dec(expBits) == 31
        % 无穷大或 NaN
        if bin2dec(mantissaBits) == 0
            halfFloat = sign * Inf; % 无穷大
        else
            halfFloat = NaN; % 非数字
        end
        return;
    end

    % 计算浮点数值
    halfFloat = sign * mantissa * 2^expValue;
end
