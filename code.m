imgSize=512;
maskSize=50; % change for mask size
img = imread("img4.png");
mask=imread("img4.jpg");
%format mask and input image
mask=imbinarize(rgb2gray(mask),0.6);
mask=imresize(mask,[maskSize,maskSize]);
img=imresize(img,[imgSize,imgSize]);
img=rgb2gray(img);
imgin=img;
imgPossible=zeros([imgSize,imgSize,8]);
key=[4,3,2]; % key for which layers to encode watermark
 
simVal=1;
bits=max(key);
%Check positions where encoding is possible
for i=1:imgSize
    disp(i)
   for j=1:imgSize
       % Cycle through each layer
       for b=1:bits
           val=extractBit(img,b,[i,j]);
           flag=0;
           % if rest of bits are opposit to considered bit
           for n = simVal:(b-1)
               if(val==extractBit(img,n,[i,j]))
                   flag=1;
                   break
               end
           end
           if(flag==0)
               img=addToBit(img,b,[i,j],0);
               for n = simVal:(b-1)
                    img=addToBit(img,n,[i,j],1);
               end
               imgPossible(i,j,b)=1;
           end
       end
   end
end
% add the mask to image
for i=1:imgSize
    disp(i)
    for j=1:imgSize
        m=mod(i,maskSize)+1;
        n=mod(j,maskSize)+1;
        b=key(mod((i*imgSize)+j,length(key))+1);
        if(imgPossible(i,j,b)==1)
            img=addToBit(img,b,[i,j],mask(m,n));
            for k = simVal:(b-1)
                if(k==0&&k+n<maskSize)
                    % little variation for JPEG compression
                    img=addToBit(img,k,[i,j],1-mask(m,k+n));
                else
                    img=addToBit(img,k,[i,j],1-mask(m,k));
                end
                
            end
        end
    end
end
%Getting watermark from image
imgout=zeros([maskSize,maskSize]);
for i = 1:imgSize
    for j = 1:imgSize
        m=mod(i,maskSize)+1;
        n=mod(j,maskSize)+1;
        b=key(mod((i*imgSize)+j,length(key))+1);
        if(imgPossible(i,j,b)==1)
            imgout(m,n)=imgout(m,n)+extractBit(img,b,[i,j]);
        end
    end
end
imgwater=imgout;
img2=img;
%Compressing as JPEG
imwrite(img,"imJPG.jpg");
img=imread("imJPG.jpg");
% Getting watermark from JPEG image
imgout=zeros([maskSize,maskSize]);
for i = 1:imgSize
    for j = 1:imgSize
        m=mod(i,maskSize)+1;
        n=mod(j,maskSize)+1;
        b=key(mod((i*imgSize)+j,length(key))+1);
        if(imgPossible(i,j,b)==1)
            imgout(m,n)=imgout(m,n)+extractBit(img,b,[i,j]);
        end
    end
end
imgJPG=imgout;
%Plotting images
subplot(1,4,1)
imshow(imgin,[])
subplot(1,4,2)
imshow(img,[])
subplot(1,4,3)
imshow(imgwater,[])
subplot(1,4,4)
imshow(imgJPG,[])
 
%PSNR Calculation
k=sum(double(img2-imgin).^2,'all')/(imgSize*imgSize);
s=double(255);
disp(20*log(s/k))
 
%For adding to bit location
function img = addToBit(img,bit,pos,val)
    imgb=extractBit(img,bit,pos);
    if(imgb~=val)
        if(val>imgb)
            img(pos(1),pos(2))=img(pos(1),pos(2))+(2^bit);
        else
            img(pos(1),pos(2))=img(pos(1),pos(2))-(2^bit);
        end
    end
end
%For extracting bit from location
function val = extractBit(img,bit,pos)
    imgb=double(img(pos(1),pos(2)))/(2^bit);
    imgb=fix(mod(imgb,2));
    val=imgb;
end
 
 
 
 
 
 
