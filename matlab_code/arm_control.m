% 定义 MIF 文件的参数
clc
clear
width = 36;           % 数据宽度（20 位无符号数）
depth = 1024;         % 深度
address_radix = 'UNS'; % 地址基数
data_radix = 'UNS';    % 数据基数
% 地址 17位 pwm值 数据 分为三段 前12位 后12位 前12位
% 生成 MIF 文件内容
mif_content = sprintf('WIDTH=%d;\nDEPTH=%d;\nADDRESS_RADIX=%s;\nDATA_RADIX=%s;\nCONTENT BEGIN\n', width, depth, address_radix, data_radix);
 
% 机械参数设置 (mm)
L0 = 95;
L1 = 104;
L2 = 193;
L3 = 159;

for i = 0:1
    flag = i; %0~1 1位
    Z = 0;
    if(flag==0)
        Z = 0 * 10; %0~128 7位 2位 5~7位
    else
        Z = 3 * 10;
    end
    for j = 85 : 288
        L = j - 12; %85~288 9位
        % 计算伸展长度
        L5 = sqrt(L^2 + (L3 + Z - L0)^2);
        
        % 计算关节角度
        cos_theta3 = (L1^2 + L2^2 - L5^2) / (2*L1*L2);
        theta3 = rad2deg(acos(cos_theta3));
        cos_theta1 = (L1^2 + L5^2 - L2^2) / (2*L1*L5);
        theta1 = rad2deg(acos(cos_theta1));
        theta2 = rad2deg(acos(L / L5));

        % 计算最终角度
        J1 = 90 - theta1 - theta2;
        J2 = 180 - theta3;
        J3 = theta1 + theta2 + theta3 - 90;

        % 计算PWM输出
        pwm_out1 = round((J1/360)*4096 + 2048); %0~2500 12位
        pwm_out2 = round((J2/360)*4096 + 2048);
        if(L < 125)
            pwm_out3 = round((J3/360)*4096 + 2048 + 35);
        elseif(L < 155)
            pwm_out3 = round((J3/360)*4096 + 2048 + 70);
        elseif(L < 185)
            pwm_out3 = round((J3/360)*4096 + 2048 + 75);
        else
            pwm_out3 = round((J3/360)*4096 + 2048 + 85);
        end
        
        % 组装存储值
        store_value = bitshift(uint64(pwm_out1), 24);
        store_value = bitor(store_value, bitshift(uint64(pwm_out2), 12)); % 使用 uint64 类型
        store_value = bitor(store_value, uint64(pwm_out3));
        store_value_bin = dec2bin(store_value, 36);

        address = bitshift(uint32(flag), 9); 
        address = bitor(address, uint32(L));
        address_bin = dec2bin(address, 10);
        mif_content = [mif_content, sprintf('  %d : %d;\n', address, store_value)];
    end
end

% 结束 MIF 文件内容
mif_content = [mif_content, 'END;'];

% 写入 MIF 文件
fid = fopen('arm_rom.mif', 'w');
fwrite(fid, mif_content, 'char');
fclose(fid);

disp('MIF 文件生成成功！');
