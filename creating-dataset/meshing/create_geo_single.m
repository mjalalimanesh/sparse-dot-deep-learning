function [ index , status ] = create_geo_single(total_num, single_num, index, status)

    % create single inclusion .geo files
    num = 1e5 ;
    phantom_radius = 16.1 ;
    inclusion_radii = [2, 3 , 4 , 5 ] ;
    rng(1);
    inclusion_radius = inclusion_radii(randi( 4 , [1, num] ))  ;
    scale_factor = inclusion_radius ./ phantom_radius ;

    dis = 1 ; % to determine minimum distance between enclusion and phantum adge (dis)*(max(inclusion_radii))

    rng(2);
    rand_xy = rand( 2 , num ) ; % create position vector
    scaled_xy = ( rand_xy - 0.5 ) * 2 * phantom_radius ;
    %%
    %pre_xy = round( scaled_xy , 2) ;
    
    Ndecimals = 2 ;
    f = 10.^Ndecimals ; 
    pre_xy = round(f*scaled_xy)/f ;
    %%
    % condition for inclusion to be in phantom .. and more
    selection_bool = sqrt( pre_xy(1,:).^2 + pre_xy(2,:).^2 ) <   ...
                     (phantom_radius - (dis)*max(inclusion_radii)) ;
    % apply condition
    xy = pre_xy( : , selection_bool ) ;


    for  i=1:single_num 
        x = xy( 1 , i )  ;
        y = xy( 2 , i ) ;
        z = 0 ;

        str1 = 'powershell -Command "(gc circle_single.geo) -replace ''x,y,z}, radius'', ''  ' ; 
        str2 = num2str(x/(1-scale_factor(i))) ;
        str3 = ',' ;
        str4 = num2str(y/(1-scale_factor(i)));
        str5 = ',' ;
        str6 = num2str(z) ;
        str7 = '}, ' ;
        str8 = num2str(scale_factor(i)) ;
        str9 = ' '' | Out-File geos/mesh_geo_' ;
        str10 = num2str(index) ;
        str11 = '.geo -encoding utf8"' ;
        command = strcat( str1, str2, str3, str4, str5, str6, str7, str8, str9, str10, str11) ;
        
        status(index) = system(command) ;
        index = index + 1 ;

        if rem(index,100) == 0
            disp(['index :  ' num2str(index)])
        end

    end

    xy_save = xy(:, 1:single_num ) ;
    scale_radius_save = scale_factor( : , 1:single_num ) ;
    save('data/single_data.mat', 'xy_save' , 'scale_radius_save' ) ; 

end

