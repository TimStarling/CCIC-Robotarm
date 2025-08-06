% 定义 MIF 文件的参数
width = 21;           % 数据宽度（20 位无符号数）
depth = 4096;         % 深度
address_radix = 'UNS'; % 地址基数
data_radix = 'UNS';    % 数据基数
% 地址 12 位 前6位 x 后6位 y 返回值21位 前9位投影长1 后12位位置信息
% 生成 MIF 文件内容
mif_content = sprintf('WIDTH=%d;\nDEPTH=%d;\nADDRESS_RADIX=%s;\nDATA_RADIX=%s;\nCONTENT BEGIN\n', width, depth, address_radix, data_radix);
for i = 0 : 53

    x = i; %0 ~ 53 位
    realx = x * 5 - 132.5;%中间为初始值和偏差修正
    for j = 0 : 35

        y = j;%0 ~ 35 6位
        realy = y * 5 + 85;
        %----------pwm获取与计算---------
        range0 = rad2deg(atan(realx/realy));
        l1 = round(sqrt(realx^2 + realy^2));%0~300 9位
        pwm_out0 = round((range0*4096/360)+1024 - 23);%0~4096 12位

        store_value = bitshift(uint32(l1), 12);
        store_value = bitor(store_value,uint32(pwm_out0));

        address = bitshift(uint32(x), 6);
        address = bitor(address, uint32(y));
        mif_content = [mif_content, sprintf('  %d : %d;\n',address,store_value)];
    end
end
% 结束 MIF 文件内容
mif_content = [mif_content, 'END;'];

% 写入 MIF 文件
fid = fopen('bottom_rom.mif', 'w');
fwrite(fid, mif_content, 'char');
fclose(fid);

disp('MIF 文件生成成功！');
