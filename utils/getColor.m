function color = getColor(car_color)
    if car_color =="red_car"
        color = "red"; 
    elseif car_color =="blue_car"
        color = "blue";
    elseif car_color =="white_car"
        color = "white";
    elseif car_color =="green_car"
        color = "green";
    elseif car_color =="yellow_car"
        color = "yellow";
    elseif car_color =="purple_car"
        color = "magenta";
    elseif car_color =="gray_car"
        color = "black";
    else
        color = "cyan";
    end
end