%The skin detection needs to be caliberated using HSV values
%A lot of variables depend on image size-need to implement them as ratios

video1 = videoinput('winvideo');
start(video1);
while 1
  K=getsnapshot(video1);
  count = 0; 
  imshow(K);
  hold on;

  J = rgb2hsv(K);
  h =J(:,:,1);
  s =J(:,:,2);
  v =J(:,:,3);
   
  I = [(h>=0.01 & h<=0.99) & (s>=0.01 & s<=0.65) & (v>=0.35 & v<=1)];                    %Detecting skin color by HSV
  
  I = imfill(I,'holes');
  I = bwmorph(I,'erode');                                                                %Morphological operations
      
  I = bwareaopen(I, 2000);                                                               %Remove small detected areas-dependant on size of image-need to implement as ratio
  hold on;
  img2 = I;
  
  BW = bwmorph(img2,'remove');                                                           %Find edge of image  
  s=size(BW);
  flag = 0;
  for row = s(1):-1:1                                                                    %Finding the lowest point in detected image
     for col=1:s(2)
        if BW(row,col)
            contour = bwtraceboundary(BW, [row, col], 'W', 8,4000,...                    %4000- No of pixels in boundary- again depends on size of image
                                     'clockwise');
            flag = 1;
            break;
        end
     end
     if flag==1
         break;
     end
  end

  [x,y]=size(contour);
  plot(contour(:,2),contour(:,1),'g','LineWidth',2);
  step = 150;                                                                               %step=150 is the step bw two pixels on boundary considered
  prev = 0;
  k=1;
  for i=step+1:step:x-step
     a = [contour(i,2) contour(i,1) 0];
     b = [contour(i+step,2) contour(i+step,1) 0];
     c = [contour(i-step,2) contour(i-step,1) 0];
     X1 = a-c;
     X2 = b-c;
     flag = 0;
     a = cross(X1,X2);                                                                      %Making the image boundary into vectors and finding cross - Maximum at finger tips- value depends on image size
     save(i) = a(3);  
    
     if (save(i)) > 7000
           if i-prev>150                                                                    %Making sure there is a min distance between two detected fingers - Depends on image size
              count = count+1;
              prev = i;
              circle(contour(i,2),contour(i,1),40);                                         %plotting circle
            end
      end
  end
  disp(count);                                                                              %Display no of detected fingers
 
  hold off;
  pause(0.1);
end
          