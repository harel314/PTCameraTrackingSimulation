function pti = BodyToWorld(ptb,phi,psi)

Hphi_mat = Hphi(phi);
Hpsi_mat = Hpsi(psi);

pti =  Hpsi_mat'* Hphi_mat' * ptb;

end

