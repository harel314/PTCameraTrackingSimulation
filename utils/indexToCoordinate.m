function [x_coord, y_coord] = indexToCoordinate(index_i, index_j, width, height, im_height,im_width)
    step_x = width / im_width;
    step_y = height / im_height;

    x_coord =  (index_i - im_width / 2)* step_x ;
    y_coord =  -(index_j - im_height / 2) * step_y ;
end

