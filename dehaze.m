%
% The method is described in the following paper:
% Xian-Shi Zhang, Shao-Bing Gao, Chao-Yi Li, Yong-Jie Li*,
% A Retina Inspired Model for Enhancing Visibility of Hazy Images,
% Frontiers in computational neuroscience, 2015, 9.
%
% Contact:
% Visual Cognition and Computation Laboratory(VCCL),
% Key Laboratory for Neuroinformation of Ministry of Education,
% School of Life Science and Technology,
% University of Electronic Science and Technology of China, Chengdu, 610054, China
% Website: http://www.neuro.uestc.edu.cn/vccl/home.html
% Xian-Shi Zhang <zhangxianshi@163.com>
% Yong-Jie Li <liyj@uestc.edu.cn>;
%
% Only for non-commercial usage.
% Please cite the above paper when you use these codes for academic research. Thanks.
% Feb 1, 2016
%=========================================================================%


function output_picture = dehze(input_picture)

%input
input_picture = im2double(input_picture);
L1 = mean2(input_picture);
%rod input
pic_temp = (input_picture(:,:,1) + input_picture(:,:,2) +input_picture(:,:,3))/3;
%Bipolar Cell
k=.3;
%Rod ON BC
pic_temp = myNCRF(pic_temp,1,3,1,1,k,0,pic_temp);
rod_bipolar(:,:,1) = pic_temp;
rod_bipolar(:,:,2) = pic_temp;
rod_bipolar(:,:,3) = pic_temp;
%Cone Off BC
input_picture_off = 1-input_picture;
bipolar_off(:,:,1) = myNCRF(input_picture_off(:,:,1),1,3,1,1,k,0,input_picture_off(:,:,1));
bipolar_off(:,:,2) = myNCRF(input_picture_off(:,:,2),1,3,1,1,k,0,input_picture_off(:,:,2));
bipolar_off(:,:,3) = myNCRF(input_picture_off(:,:,3),1,3,1,1,k,0,input_picture_off(:,:,3));
bipolar_off=bipolar_off/max(max(max(bipolar_off)));
%bipolar_yoff = (bipolar_on(:,:,1)+bipolar_on(:,:,2))/2;
%Cone On BC
bipolar_on(:,:,1) = myNCRF(input_picture(:,:,1),1,3,1,1,k,0,input_picture(:,:,1));
bipolar_on(:,:,2) = myNCRF(input_picture(:,:,2),1,3,1,1,k,0,input_picture(:,:,2));
bipolar_on(:,:,3) = myNCRF(input_picture(:,:,3),1,3,1,1,k,0,input_picture(:,:,3));
bipolar_on=bipolar_on/max(max(max(bipolar_on)));
%bipolar_yon = (bipolar_on(:,:,1)+bipolar_on(:,:,2))/2;
%Amacrine Cell modulation
LB = mean2(bipolar_off);
bipolar_off = bipolar_off./(.5+rod_bipolar);
LA = mean2(bipolar_off);
bipolar_off = (LB/LA).*bipolar_off;
LB = mean2(bipolar_on);
bipolar_on = bipolar_on.*(.5+rod_bipolar);
LA = mean2(bipolar_on);
bipolar_on = (LB/LA).*bipolar_on;
%Ganglion Cell
%Off GC
ganglion_off(:,:,1) = myNCRF(bipolar_off(:,:,1),1,3,1,2,2,.5,bipolar_off(:,:,2));
ganglion_off(:,:,2) = myNCRF(bipolar_off(:,:,2),1,3,1,2,2,.5,bipolar_off(:,:,1));
ganglion_off(:,:,3) = myNCRF(bipolar_off(:,:,3),1,3,1,2,2,.5,(bipolar_off(:,:,1)+bipolar_off(:,:,2))/2);
ganglion_off = 1 - ganglion_off;
ganglion_off(ganglion_off<0) = 0;
L3 = mean2(ganglion_off);
ganglion_off = (L1/L3)*ganglion_off;
%ON GC
ganglion_on(:,:,1) = myNCRF(bipolar_on(:,:,1),1,3,1,2,2,.7,bipolar_on(:,:,2));
ganglion_on(:,:,2) = myNCRF(bipolar_on(:,:,2),1,3,1,2,2,.7,bipolar_on(:,:,1));
ganglion_on(:,:,3) = myNCRF(bipolar_on(:,:,3),1,3,1,2,2,.7,(bipolar_on(:,:,1)+bipolar_on(:,:,2))/2);
L4 = mean2(ganglion_on);
ganglion_on = (L1/L4)*ganglion_on;
%output
t=2;
w = rod_bipolar.^t;
output_picture = (1-w).*ganglion_off + w.*ganglion_on;

L2 = mean2(output_picture);
output_picture = output_picture*(.8*L1/L2);
figure;imshow(output_picture);
