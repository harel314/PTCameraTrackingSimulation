function ptb = WorldToBody(pti,phi,psi)

Hphi_mat = Hphi(phi);
Hpsi_mat = Hpsi(psi);

ptb = Hphi_mat* Hpsi_mat * pti;

end

