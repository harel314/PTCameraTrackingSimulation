function H_mat = H(p,q3,f)
H_mat  = [-f/q3, 0 , p(1)/q3 , p(1)*p(2)/f , -(f^2+p(1)^2)/f , p(2);
            0 , -f/q3 , p(2)/q3 , (f^2+p(1)^2)/f , -p(1)*p(2)/f , -p(1)];
end

