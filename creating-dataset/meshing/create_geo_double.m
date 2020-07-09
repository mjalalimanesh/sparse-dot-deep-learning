function  [index, status] = create_geo_double(total_num, double_num, index , status)

% create double inclusion .geo files
    num = 1e5 ;
    phantom_radius = 16.1 ;
    inclusion_radius = 3.5 ;
    scale_factor = inclusion_radius ./ phantom_radius ; % to use in dialte

    
    dis = 1 ; % to determine minimum distance between enclusion and phantum adge (dis)*(max(inclusion_radii))

    % Inclusion ONE
    rng(1);
    rand_xy1 = rand( 2 , num ) ;  % create position vector
    scaled_xy1 = ( rand_xy1 - 0.5 ) * 2 * phantom_radius ; 
    
    %%   
 %   pre_xy1 = round( scaled_xy1 , 2) ;
    Ndecimals = 2 ;
    f = 10.^Ndecimals ; 
    pre_xy1 = round(f*scaled_xy1)/f ;

    %%
    % condition for inclusion one to be in phantom .. and more
    selection_bool_1 = sqrt( pre_xy1(1,:).^2 + pre_xy1(2,:).^2 ) <   ...
                     (phantom_radius - (dis)*inclusion_radius) ;
    % applying condition
    pre_xy1 = pre_xy1( : , selection_bool_1 ) ;


    % Inclusion TWO
    rng(2);
    rand_xy2 = rand( 2 , num ) ; 
    scaled_xy2 = ( rand_xy2 - 0.5 ) * 2 * phantom_radius ;
    %%
%    pre_xy2 = round( scaled_xy2 , 2) ;
    Ndecimals = 2 ;
    f = 10.^Ndecimals ; 
    pre_xy2 = round(f*scaled_xy2)/f ;

    %%
    % condition for inclusion two to be in phantom .. and more
    selection_bool_2 = sqrt( pre_xy2(1,:).^2 + pre_xy2(2,:).^2 ) <   ...
                     (phantom_radius - (dis)*inclusion_radius) ;
    % apply condition
    pre_xy2 = pre_xy2( : , selection_bool_2 ) ;

    % making position vectors of same length to compute distances of all points
    % at once
    pre_xy1 = pre_xy1( : , 1:min([ size(pre_xy1,2) , size(pre_xy2,2) ])) ;
    pre_xy2 = pre_xy2( : , 1:min([ size(pre_xy1,2) , size(pre_xy2,2) ])) ;
    % condition preventing inclusions of collision
    selection_bool_3 = sqrt( (pre_xy2(2,:)-pre_xy1(2,:)).^2 + (pre_xy2(1,:)-pre_xy1(1,:)).^2 ) > ...
                        (2 * inclusion_radius) ;
    % applying 3rd condition
    xy_1 = pre_xy1( : , selection_bool_3 ) ;
    xy_2 = pre_xy2( : , selection_bool_3 ) ;


    for  i=1:double_num 
        x1 = xy_1( 1 , i )  ;
        y1 = xy_1( 2 , i ) ;
        z1 = 0 ;


        x2 = xy_2( 1 , i )  ;
        y2 = xy_2( 2 , i ) ;
        z2 = 0 ;


        str1 = 'powershell -Command "(gc circle_double.geo) -replace ''x1,y1,z1}, radius1'', ''  ' ; 
        str2 = num2str(x1/(1-scale_factor)) ;
        str3 = ',' ;
        str4 = num2str(y1/(1-scale_factor));
        str5 = ',' ;
        str6 = num2str(z1) ;
        str7 = '}, ' ;
        str8 = num2str(scale_factor) ;
        str9 = ' '' ' ;
        str10 = '-replace ''x2,y2,z2}, radius2'', ''  ' ;
        str11 = num2str(x2/(1-scale_factor)) ;
        str12 = ',' ;
        str13 = num2str(y2/(1-scale_factor));
        str14 = ',' ;
        str15 = num2str(z2) ;
        str16 = '}, ' ;
        str17 = num2str(scale_factor) ;
        str18 = ' '' | Out-File geos/mesh_geo_' ;
        str19 = num2str(index) ;
        str20 = '.geo -encoding utf8"' ;
        command = strcat( str1, str2, str3, str4, str5, str6, str7, str8, ...
                str9, str10, str11, str12, str13, str14, str15, str16, ...
                str17, str18, str19, str20) ;

        status(index) = system(command) ;
        index = index + 1 ;
        if rem(index,100) == 0
            disp(['index :  ' num2str(index)])
        end

    end
    
    xy_1_save = xy_1(:,1:double_num) ;
    xy_2_save = xy_2(:,1:double_num) ;
    save('data/double_data.mat', 'xy_1_save' , 'xy_2_save' ) 
end
