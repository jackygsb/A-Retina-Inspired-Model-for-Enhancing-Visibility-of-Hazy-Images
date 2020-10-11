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


function outImg = myFilterGbyQDis(Img,rr_RF,rr_IF,r_D,m_qA1,m_qA2,m_qA3,antImg)

%---------------------------------------------
[row,col] = size(Img);

%---------------------------------------------
th1 = 2*rr_RF + 1; %diameter

%-----RF center----------------------------------------
    hsize = th1;
    pa_gauss1 = GaussFun2D(hsize);
    
    for i=1:th1
        for j=1:th1
            di = i-rr_RF-1;
            dj = j-rr_RF-1;
            tmpV = di*di + dj*dj;
            if tmpV>rr_RF*rr_RF
                pa_gauss1(i,j) = 0.0;
            end
        end
    end
    
    pa_gauss1 = m_qA1*pa_gauss1/sum(sum(pa_gauss1));

%-----RF surround----------------------------------------
th2  = 2*rr_IF + 1;

    hsize = th2;
    pa_gauss2 = GaussFun2D(hsize);
    
    for i=1:th2
        for j=1:th2
            di = i-rr_IF-1;
            dj = j-rr_IF-1;
            tmpV = di*di + dj*dj;
            if tmpV>rr_IF*rr_IF | tmpV<=rr_RF*rr_RF
                pa_gauss2(i,j) = 0.0;
            end
        end
    end
    
    pa_gauss2 = m_qA2*pa_gauss2/sum(sum(pa_gauss2));

%-----Surround subunits----------------------------------------
th3 = 2*r_D + 1;
hsize = th3;
pa_gauss3 = GaussFun2D(hsize);

for i=1:th3
    for j=1:th3
        di = i-r_D-1;
        dj = j-r_D-1;
        tmpV = di*di + dj*dj;
        if tmpV>r_D*r_D | tmpV==0
            pa_gauss3(i,j) = 0.0;
        end
    end
end
pa_gauss3 = m_qA3*pa_gauss3/sum(sum(pa_gauss3));
    

%--disinhibition among subunits:-------------------------------------------
imgDisinh = imfilter(antImg,pa_gauss3,'conv','symmetric');
imgDisinh = antImg - imgDisinh;
imgDisinh(imgDisinh<0.0) = 0.0;

%-------surrund inhibition by summing all the subunits:
SurroundImgLists = imfilter(imgDisinh,pa_gauss2,'conv','symmetric');

%-------response of RF center:
CenterImgLists = imfilter(Img,pa_gauss1,'conv','symmetric');


%--
outImg = CenterImgLists - SurroundImgLists;
outImg(outImg<0.0) = 0.0;
%outImg(outImg>1) = 1;

