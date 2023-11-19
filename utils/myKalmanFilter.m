classdef myKalmanFilter

    properties

    dt %sampling time
    u %conrol input
    x %initial state
    A %State Transition matrix
    B %Control Input matrix
    H %Mapping Matrix
    Q % Noise Covariance
    R %Measurement Noise
    P %Initial Covariance matrix

    end

    methods
        function obj = myKalmanFilter(dt,init_x,init_u,std_acc,std_x,std_y)
                obj.dt = dt;

                obj.u = init_u; % (ux,uy)

                obj.x = init_x; % (x,y)

                obj.A =   [1,0,dt,0;
                           0,1,0,dt;
                           0,0,1,0 ;
                           0,0,0,1  ];

                obj.B =   [dt^2/2,0;
                             0,dt^2/2;
                             dt,  0  ;
                             0,  dt  ] ;

                obj.H = [1,0,0,0;
                        0,1,0,0 ];

                obj.Q = [dt^4/4,0,dt^3/2,0;
                         0,dt^4/4,0,dt^3/2;
                         dt^3/2,0,dt^2, 0 ;
                         0 ,dt^3/2,0, dt^2 ] * std_acc^2;

                obj.R =  [std_x^2,0;
                           0,std_y^2];

                obj.P  = eye(size(obj.A,1));
        end
        
        function obj = predict(obj)
            obj.x = obj.A*obj.x + obj.B*obj.u;
            obj.P = (obj.A*obj.P)*obj.A'+obj.Q;
        end

        function obj = update(obj,z)
            S = obj.H*(obj.P*obj.H')+obj.R;
            K = (obj.P*obj.H')*inv(S);
            obj.x = obj.x + K*(z-obj.H*obj.x);
            I = eye(size(obj.A,1));
            obj.P = (I-(K*obj.H))*obj.P;
        end

    end
end
