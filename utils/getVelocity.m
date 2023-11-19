function v = getVelocity(pts_prev,pts_cur,S2,S1,f,CI,dt)
pts_prev= [pts_prev;f];
pts_cur = [pts_cur;f];
rho_p = -CI(3)/ ((pts_prev(2))*sin(S2)+f*cos(S2));
rho_c = -CI(3)/ ((pts_cur(2))*sin(S2)+f*cos(S2));
pts_prev_world = rho_p*BodyToWorld(pts_prev,S2,S1)+CI;
pts_cur_world = rho_c*BodyToWorld(pts_cur,S2,S1)+CI;
v = (pts_cur_world - pts_prev_world)/dt;
v=v';
return

