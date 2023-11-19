function rTVs = CameraMeasurements(TIs,Tc_v,CI,f,S)
rTVs=[];
for ix=1:size(TIs,2)
    % get the point
    Tcv = Tc_v(:,ix);
    TI = TIs(:,ix);
    rTI = [TI(1:2);0] - CI;
    qTB = WorldToBody(rTI,S(2),S(1));%qTB = [qx;qy;qz]
    rTV = BodyToVirtual(qTB,f);
    % get the velocity
    H_mat  = H(rTV,qTB(3),f);
    Rv = [Hphi(S(2))'*Hpsi(S(1))',zeros(3,3);zeros(3,3),-Hphi(S(2))'];
    rTV_dot = H_mat*Rv*[Tcv(1:2);0;S(4);0;S(3)];
    rTV = [rTV ;rTV_dot];
    rTVs = cat(2,rTVs,rTV);
end
end

