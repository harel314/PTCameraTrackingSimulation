function updatedS = BoundTest(S,psi_l,phi_l)
    b1 = [0,pi/2,-psi_l,-phi_l]';
    b2 = [2*pi,pi,psi_l,phi_l]';
    updatedS = min(b2,max(b1,S));
end

