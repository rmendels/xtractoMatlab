function [ perp ] = upwell( ektrx,ektry,coast_angle )
%upwell Summary of this function goes here
%   Detailed explanation goes here
   pi = 3.1415927;
   degtorad = pi/180.;
   alpha = (360-coast_angle)*degtorad;
   s1 = cos(alpha);
   t1 = sin(alpha);
   s2 = -1*t1;
   t2 = s1;
   perp = s1*ektrx+t1*ektry;
   para = s2*ektrx+t2*ektry;
   perp=perp/10;
   
